@description('Required. Specifies the name of the Azure Storage account')
param storageAccountName string

@description('Required. Properties of the fileshare')
param fileShares array

@description('Optional. Diagnostic settings configuration')
param diagnosticSettings array = []

@description('Optional. Array of Role Assignments to deploy')
param permissions array = []

var fileShareNames = [for item in fileShares: item.fileShareName]
var fileShareResourceIds = [for item in fileShares: resourceId('Microsoft.Storage/storageAccounts/fileServices/shares', storageAccountName, 'default', item.fileShareName)]

resource sa 'Microsoft.Storage/storageAccounts@2021-06-01' existing = {
  name: storageAccountName
}

resource service 'Microsoft.Storage/storageAccounts/fileServices@2021-06-01' = {
  name: 'default'
  parent: sa

  resource fileShare 'shares@2021-06-01' = [for item in fileShares: {
    name: item.fileShareName
    properties: {
      shareQuota: item.fileShareQuota
    }
  }]
}

resource diagSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = [for setting in diagnosticSettings: if (!empty(diagnosticSettings)) {
  name: setting.name
  scope: service
  properties: {
    workspaceId: contains(setting, 'workspaceId') ? setting.workspaceId : null
    storageAccountId: contains(setting, 'diagnosticsStorageAccountId') ? setting.diagnosticsStorageAccountId : null
    logs: contains(setting, 'logs') ? setting.logs : null
    metrics: contains(setting, 'metrics') ? setting.metrics : null
  }
}]

resource roleAssignments 'Microsoft.Authorization/roleAssignments@2022-01-01-preview' = [for item in permissions: {
  name: guid(resourceGroup().id, item.name, item.roleDefinitionId)
  scope: service
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

@description('Name of the resource')
output resourceName array = fileShareNames

@description('ID of the resource')
output resourceID array = fileShareResourceIds
