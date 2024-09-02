@description('Required. The workload name of the resource.')
param workloadName string

@description('Required. The application name of the resource.')
param applicationName string

@description('Required. The environment letter of the resource.')
@maxLength(1)
param environmentName string

@description('Required. The index of the resource.')
param index int

@description('Required. The region this resource will be deployed in.')
@maxLength(4)
param regionName string

@description('Optional. Custom name for the resource.')
param customName string = ''

@description('Optional. Location of the resource.')
param location string = resourceGroup().location

@description('Optional. Array of Role Assignments to deploy')
param permissions array = []

@description('Required. Resource ID of the Virtual Wan Hub.')
param virtualWanHubResourceId string

@description('Optional. Array of BGP peering addresses.')
param bgpPeeringAddresses array = []

@description('Optional. Scale unit for the gateway.')
param scaleUnits int = 1

@description('Optional. Tags to apply to all resources.')
param tags object = {}

@description('Optional. Diagnostic settings configuration.')
param diagnosticSettings array = []

@description('Optional. Array containing the VPN connections.')
param connections array = []

var VpnGatewayName = empty(customName) ? toLower('vng-${workloadName}-${applicationName}-${environmentName}-${regionName}-${padLeft(index, 2, '0')}') : customName

resource hubvpngw 'Microsoft.Network/vpnGateways@2023-05-01' = {
  name: VpnGatewayName
  location: location
  tags: tags
  properties: {
    virtualHub: {
      id: virtualWanHubResourceId
    }
    vpnGatewayScaleUnit: scaleUnits
    bgpSettings: {
      asn: 65515
      peerWeight: 0
      bgpPeeringAddresses: bgpPeeringAddresses
    }
    connections: connections
  }
}

resource diagSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = [for setting in diagnosticSettings: if (!empty(diagnosticSettings)) {
  name: setting.name
  scope: hubvpngw
  properties: {
    workspaceId: contains(setting, 'workspaceId') ? setting.workspaceId : null
    storageAccountId: contains(setting, 'diagnosticsStorageAccountId') ? setting.diagnosticsStorageAccountId : null
    logs: contains(setting, 'logs') ? setting.logs : null
    metrics: contains(setting, 'metrics') ? setting.metrics : null
  }
}]

resource roleAssignments 'Microsoft.Authorization/roleAssignments@2022-04-01' = [for item in permissions: {
  name: guid(resourceGroup().id, item.name, item.roleDefinitionId)
  scope: hubvpngw
  properties: {
    principalId: item.principalId
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', item.roleDefinitionId)
    condition: contains(item, 'condition') && item.condition != '' ? item.condition : null
    conditionVersion: contains(item, 'conditionVersion') && item.conditionVersion != '' ? item.conditionVersion : null
    delegatedManagedIdentityResourceId: contains(item, 'delegatedManagedIdentityResourceId') && item.delegatedManagedIdentityResourceId != '' ? item.delegatedManagedIdentityResourceId : null
    description: item.description
    principalType: item.principalType
  }
}]

@description('ID of the resource')
output resourceID string = hubvpngw.id
@description('Name of the resource')
output resourceName string = hubvpngw.name
@description('Public IP of the of the gateway')
output gwpublicip string = hubvpngw.properties.ipConfigurations[0].publicIpAddress
@description('Private IP of the of the gateway')
output gwprivateip string = hubvpngw.properties.ipConfigurations[0].privateIpAddress
