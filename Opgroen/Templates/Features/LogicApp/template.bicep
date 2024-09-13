@description('Required. The name of the application')
param applicationName string

@description('Required. The code of the environment this resource will be used in')
@maxLength(1)
param environmentName string

@description('Required. The name of the workload this resource will be used for')
param workloadName string

@description('Required. Region of the Logic App')
@maxLength(4)
param regionName string

@description('Optional. The name to use if not using the normal naming convention')
param customName string = ''

@description('Optional. Resource tags')
param tags object = {}

@description('Optional. Indicates if the Logic App should be enabled after deployment')
@allowed([
  'Disabled'
  'Enabled'
  'Completed'
  'Deleted'
  'NotSpecified'
  'Suspended'
])
param enableLogicApp string = 'Enabled'

@description('Optional. Object describing the managed identity to be used (if any)')
param managedIdentity object = {}

@description('Required. Object describing the contents of the Logic App')
param definition object

@description('Optional. Array of objects describing the connections')
param connections array = []

@description('Optional. Location of the resource')
param location string = resourceGroup().location

@description('Optional. Array of Role Assignments to deploy')
param permissions array = []

@description('Optional. Diagnostic settings configuration')
param diagnosticSettings array = []

var nameVar = toLower('logic-${workloadName}-${applicationName}-${environmentName}-${regionName}-${uniqueString(resourceGroup().id)}')

resource conn 'Microsoft.Web/connections@2016-06-01' = [for conn in connections: if (!empty(connections)) {
  name: empty(connections) ? 'dummy' : conn.displayName
  location: location
  tags: tags
  properties: empty(connections) ? null : conn
}]

resource logicApp 'Microsoft.Logic/workflows@2019-05-01' = {
  name: empty(customName) ? nameVar : customName
  location: location
  tags: tags
  properties: {
    state: enableLogicApp
    definition: empty(definition) ? null : definition
  }
  identity: empty(managedIdentity) ? null : managedIdentity
}

resource diagSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = [for setting in diagnosticSettings: if (!empty(diagnosticSettings)) {
  name: setting.name
  scope: logicApp
  properties: {
    workspaceId: contains(setting, 'workspaceId') ? setting.workspaceId : null
    storageAccountId: contains(setting, 'diagnosticsStorageAccountId') ? setting.diagnosticsStorageAccountId : null
    logs: contains(setting, 'logs') ? setting.logs : null
    metrics: contains(setting, 'metrics') ? setting.metrics : null
  }
}]

resource roleAssignments 'Microsoft.Authorization/roleAssignments@2022-01-01-preview' = [for item in permissions: {
  name: guid(resourceGroup().id, item.name, item.roleDefinitionId)
  scope: logicApp
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
output resourceName string = logicApp.name
@description('The resource-id of the Azure resource')
output resourceID string = logicApp.id
