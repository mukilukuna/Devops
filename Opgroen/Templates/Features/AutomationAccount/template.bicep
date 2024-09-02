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

@description('Optional. Resource tags')
param tags object = {}

@description('Optional. The SKU for this automation account')
@allowed([
  'Basic'
  'Free'
])
param sku string = 'Free'

@description('Optional. An array of objects specifying the runbooks that should be created in this automation account')
param runbooks array = []

@description('Optional. An array of objects specifying which modules should be imported in this automation account')
param modules array = []

@description('Optional. Specify if a Managed Identity should be assigned')
param assignManagedIdentity bool = true

@description('Optional. The list of user identities associated with the resource. The user identity dictionary key references will be ARM resource ids in the form: \'/subscriptions/{subscriptionId}/resourceGroups/{resourceGroupName}/providers/Microsoft.ManagedIdentity/userAssignedIdentities/{identityName}\'')
param userAssignedIdentities object = {}

@description('Optional. Enables public access to the automation account')
param publicNetworkAccess bool = true

@description('Optional. Location of the resource')
param location string = resourceGroup().location

@description('Optional. Diagnostic settings configuration')
param diagnosticSettings array = []

@description('Optional. Array of Role Assignments to deploy')
param permissions array = []

var automationAccountName = empty(customName)
  ? toLower('aa-${workloadName}-${applicationName}-${environmentName}-${regionName}-${padLeft(index, 2, '0')}')
  : customName

var identityType = assignManagedIdentity
  ? (!empty(userAssignedIdentities) ? 'SystemAssigned,UserAssigned' : 'SystemAssigned')
  : (!empty(userAssignedIdentities) ? 'UserAssigned' : 'None')

var identity = identityType != 'None'
  ? {
      type: identityType
      userAssignedIdentities: !empty(userAssignedIdentities) ? userAssignedIdentities : null
    }
  : null

resource automationAccount 'Microsoft.Automation/automationAccounts@2021-06-22' = {
  name: automationAccountName
  location: location
  #disable-next-line BCP036
  identity: identity
  tags: tags
  properties: {
    publicNetworkAccess: publicNetworkAccess
    sku: {
      name: sku
    }
  }
}

resource automationAccountName_safeRunbooks_name 'Microsoft.Automation/automationAccounts/runbooks@2019-06-01' = [
  for (item, i) in runbooks: if (!empty(runbooks)) {
    parent: automationAccount
    name: '${item[i].name}'
    location: location
    tags: item[i].runbookTags
    properties: {
      runbookType: item[i].runbookType
      description: item[i].description
      logVerbose: item[i].logVerbose
      logProgress: item[i].logProgress
      publishContentLink: {
        uri: item[i].content.uri
        version: item[i].content.version
      }
    }
  }
]

@batchSize(1)
resource automationAccountName_safeModules_name 'Microsoft.Automation/automationAccounts/modules@2019-06-01' = [
  for (item, i) in modules: if (!empty(modules)) {
    parent: automationAccount
    name: '${item[i].name}'
    location: location
    properties: {
      contentLink: {
        uri: item[i].uri
      }
    }
  }
]

resource diagSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = [
  for diag in diagnosticSettings: if (!empty(diagnosticSettings)) {
    name: diag.name
    scope: automationAccount
    properties: {
      workspaceId: contains(diag, 'workspaceId') ? diag.workspaceId : null
      storageAccountId: contains(diag, 'diagnosticsStorageAccountId') ? diag.diagnosticsStorageAccountId : null
      logs: contains(diag, 'logs') ? diag.logs : null
      metrics: contains(diag, 'metrics') ? diag.metrics : null
    }
  }
]

resource roleAssignments 'Microsoft.Authorization/roleAssignments@2022-04-01' = [
  for item in permissions: {
    name: guid(resourceGroup().id, item.name, item.roleDefinitionId)
    scope: automationAccount
    properties: {
      principalId: item.principalId
      roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', item.roleDefinitionId)
      condition: contains(item, 'condition') && item.condition != '' ? item.condition : null
      conditionVersion: contains(item, 'conditionVersion') && item.conditionVersion != '' ? item.conditionVersion : null
      delegatedManagedIdentityResourceId: contains(item, 'delegatedManagedIdentityResourceId') && item.delegatedManagedIdentityResourceId != ''
        ? item.delegatedManagedIdentityResourceId
        : null
      description: item.description
      principalType: item.principalType
    }
  }
]

@description('The name of the Azure resource')
output resourceName string = automationAccount.name
@description('The resource-id of the Azure resource')
output resourceID string = automationAccount.id
