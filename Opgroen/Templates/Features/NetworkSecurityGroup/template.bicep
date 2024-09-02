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

@description('Optional. Location of the resource')
param location string = resourceGroup().location

@description('Optional. Array of Role Assignments to deploy')
param permissions array = []

@description('Optional. Location of the resource')
param securityRules array

@description('Optional. Diagnostic settings configuration')
param diagnosticSettings array = []

resource nsg 'Microsoft.Network/networkSecurityGroups@2021-12-01' = {
  name: empty(customName) ? toLower('nsg-${workloadName}-${applicationName}-${environmentName}-${regionName}-${padLeft(index, 2, '0')}') : customName
  tags: tags
  location: location
  properties: {
    securityRules: securityRules
  }
}

resource diagSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = [for setting in diagnosticSettings: if (!empty(diagnosticSettings)) {
  name: empty(diagnosticSettings) ? 'outOfBoundsError' : setting.name
  scope: nsg
  properties: {
    workspaceId: contains(setting, 'workspaceId') ? setting.workspaceId : null
    storageAccountId: contains(setting, 'diagnosticsStorageAccountId') ? setting.diagnosticsStorageAccountId : null
    logs: contains(setting, 'logs') ? setting.logs : null
    metrics: contains(setting, 'metrics') ? setting.metrics : null
  }
}]

resource roleAssignments 'Microsoft.Authorization/roleAssignments@2022-01-01-preview' = [for item in permissions: {
  name: guid(resourceGroup().id, item.name, item.roleDefinitionId)
  scope: nsg
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
output resourceName string = nsg.name
@description('The resource-id of the Azure resource')
output resourceID string = nsg.id
