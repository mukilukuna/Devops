@description('Required. The application name of the resource.')
param applicationName string

@description('Required. The environment letter of the resource.')
@maxLength(1)
param environmentName string

@description('Required. The workload name of the resource.')
param workloadName string

@description('Required. The region of the resource.')
@maxLength(4)
param regionName string

@description('Required. The index of the resource.')
param index int

@description('Optional. Custom name of the resource.')
param customName string = ''

@description('Optional. Object containing the tags to apply to all resources.')
param tags object = {}

@description('Required. The address space that contains an array of IP address ranges that can be used by subnets.')
param vNetPrefix array

@description('Optional. Array of DNS Servers to be used by the vNet. When none are specified, Azure DNS is used.')
param vNetDnsServers array = []

@description('Optional. Array of subnets.')
param subnets array = []

@description('Optional. Location of the resource')
param location string = resourceGroup().location

@description('Optional. Array of Role Assignments to deploy')
param permissions array = []

@description('Optional. Diagnostic settings configuration')
param diagnosticSettings array = []

resource vNet 'Microsoft.Network/virtualNetworks@2021-08-01' = {
  name: empty(customName) ? toLower('vnet-${workloadName}-${applicationName}-${environmentName}-${regionName}-${padLeft(index, 2, '0')}') : customName
  location: location
  tags: tags
  properties: {
    addressSpace: {
      addressPrefixes: vNetPrefix
    }
    dhcpOptions: {
      dnsServers: vNetDnsServers
    }
    subnets: subnets
  }
}

resource diagSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = [for setting in diagnosticSettings: if (!empty(diagnosticSettings)) {
  name: empty(diagnosticSettings) ? 'outOfBoundsError' : setting.name
  scope: vNet
  properties: {
    workspaceId: contains(setting, 'workspaceId') ? setting.workspaceId : null
    storageAccountId: contains(setting, 'diagnosticsStorageAccountId') ? setting.diagnosticsStorageAccountId : null
    logs: contains(setting, 'logs') ? setting.logs : null
    metrics: contains(setting, 'metrics') ? setting.metrics : null
  }
}]

resource roleAssignments 'Microsoft.Authorization/roleAssignments@2022-04-01' = [for item in permissions: {
  name: guid(resourceGroup().id, item.name, item.roleDefinitionId)
  scope: vNet
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
output resourceName string = vNet.name
@description('The resource-id of the Azure resource')
output resourceID string = vNet.id
