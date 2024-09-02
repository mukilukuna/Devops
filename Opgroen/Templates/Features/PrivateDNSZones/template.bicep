@description('Required. Is used to create Microsoft private link endpoint DNS zones and custom name zones. Parameter needs to contain the entire dns zone name e.g. privatelink.azurewebsites.net')
param customName string = ''

@description('Optional. Object containing the tags to apply to all resources')
param tags object = {}

@description('Optional. Location of the resource')
param location string = 'global'

@description('Optional. Diagnostic settings configuration')
param diagnosticSettings array = []

@description('Optional. Array of Role Assignments to deploy')
param permissions array = []

resource privatednszone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: customName
  location: location
  tags: tags
  properties: {}
}

resource diagSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = [for diag in diagnosticSettings: if (!empty(diagnosticSettings)) {
  name: diag.name
  scope: privatednszone
  properties: {
    workspaceId: (contains(diag, 'workspaceId') ? diag.workspaceId : json('null'))
    storageAccountId: (contains(diag, 'diagnosticsStorageAccountId') ? diag.diagnosticsStorageAccountId : json('null'))
    logs: (contains(diag, 'logs') ? diag.logs : json('null'))
    metrics: (contains(diag, 'metrics') ? diag.metrics : json('null'))
  }
}]

resource roleAssignments 'Microsoft.Authorization/roleAssignments@2022-04-01' = [for item in permissions: {
  name: guid(resourceGroup().id, item.name, item.roleDefinitionId)
  scope: privatednszone
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
output resourceName string = privatednszone.name

@description('The resource-id of the Azure resource')
output resourceID string = privatednszone.id
