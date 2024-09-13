@description('Required. Specifies the name of the Azure Storage account')
param storageAccountName string

@description('Required. Properties of the containers')
param containers array

@description('Optional. Enables the delete retention policy')
param blobDeleteRetentionPolicy bool = true

@description('Optional. Indicates the number of days that the deleted item should be retained')
@minValue(1)
@maxValue(365)
param blobRetentionDays int = 30

@description('Optional. Diagnostic settings configuration')
param diagnosticSettings array = []

@description('Optional. Array of Role Assignments to deploy')
param permissions array = []

var containerNames = [for item in containers: item.containerName]
var containerResourceIds = [for item in containers: resourceId('Microsoft.Storage/storageAccounts/fileServices/shares', storageAccountName, 'default', item.containerName)]

resource sa 'Microsoft.Storage/storageAccounts@2022-05-01' existing = {
  name: storageAccountName
}

resource service 'Microsoft.Storage/storageAccounts/blobServices@2022-05-01' = {
  name: 'default'
  properties: {
    deleteRetentionPolicy: {
      enabled: blobDeleteRetentionPolicy
      days: blobRetentionDays
    }
  }
  parent: sa

  resource container 'containers@2022-05-01' = [for item in containers: {
    name: item.containerName
    properties: {
      publicAccess: item.publicAccess
      defaultEncryptionScope: contains(item, 'defaultEncryptionScope') ? item.defaultEncryptionScope : null
      denyEncryptionScopeOverride: contains(item, 'denyEncryptionScopeOverride') ? item.denyEncryptionScopeOverride : null
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
output resourceName array = containerNames

@description('ID of the resource')
output resourceID array = containerResourceIds
