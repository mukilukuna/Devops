@description('Required. The name of the workload this resource will be used for')
param workloadName string

@description('Required. The name of the application')
param applicationName string

@description('Required. The code of the environment this resource will be used in')
@maxLength(1)
param environmentName string

@description('Required. The region this resource will be deployed in')
@maxLength(4)
param regionName string

@description('Required. Index of the resource')
param index int

@description('Optional. The name to use if not using the normal naming convention')
param customName string = ''

@description('Optional. Location of the resource')
param location string = resourceGroup().location

@description('Optional. ID of the Vnet to deploy in')
param vnetId string

@description('Optional. Public IP zones')
param zones array = [
  '1'
  '2'
  '3'
]

@description('Optional. Resource tags')
param tags object = {}

@description('Optional. Microsoft Insights diagnosticSettings configuration')
param diagnosticsSettings array = []

@description('Optional. Array of Role Assignments to deploy')
param permissions array = []

var nameVar = empty(customName) ? toLower('bas-${workloadName}-${applicationName}-${environmentName}-${regionName}-${padLeft(index, 2, '0')}') : customName
var AzureBastionSubnet = '${vnetId}/subnets/AzureBastionSubnet'

module PublicIP '../PublicIP/template.bicep' = {
  name: 'PublicIP'
  params: {
    zones: zones
    applicationName: applicationName
    workloadName: workloadName
    regionName: regionName
    index: index
    environmentName: environmentName
    customName: customName
    tags: tags
    publicIPSku: 'Standard'
    publicIPAllocationMethod: 'Static'
    location: location
  }
}

resource bastionHost 'Microsoft.Network/bastionHosts@2021-12-01' = {
  name: nameVar
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'IpConf'
        properties: {
          subnet: {
            id: AzureBastionSubnet
          }
          publicIPAddress: {
            id: PublicIP.outputs.resourceID
          }
        }
      }
    ]
  }
  tags: tags
}

resource diagSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = [for diag in diagnosticsSettings: if (!empty(diagnosticsSettings)) {
  scope: bastionHost
  name: diag.name
  properties: {
    workspaceId: contains(diag, 'workspaceId') ? diag.workspaceId : null
    storageAccountId: contains(diag, 'diagnosticStorageAccountId') ? diag.diagnosticsStorageAccountId : null
    serviceBusRuleId: contains(diag, 'serviceBusRuleId') ? diag.serviceBusRuleId : null
    eventHubName: contains(diag, 'eventHubName') ? diag.eventHubName : null
    eventHubAuthorizationRuleId: contains(diag, 'eventHubAuthorizationRuleId') ? diag.eventHubAuthorizationRuleId : null
    logs: contains(diag, 'logs') ? diag.logs : null
    metrics: contains(diag, 'metrics') ? diag.metrics : null
  }
}]

resource roleAssignments 'Microsoft.Authorization/roleAssignments@2022-01-01-preview' = [for item in permissions: {
  name: guid(resourceGroup().id, item.name, item.roleDefinitionId)
  scope: bastionHost
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

@description('The name of the Azure resource')
output resourceName string = bastionHost.name

@description('The resource-id of the Azure resource')
output resourceID string = bastionHost.id
