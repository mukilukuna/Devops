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

@description('Optional. Enable admin user that have push / pull permission to the registry')
param acrAdminUserEnabled bool = false

@description('Optional. Enables registry-wide pull from unauthenticated clients')
param anonymousPullEnabled bool = false

@description('Optional. Location for all resources')
param location string = resourceGroup().location

@description('Optional. Specify the SKU for the ACR')
@allowed([
  'Basic'
  'Classic'
  'Premium'
  'Standard'
])
param acrSku string = 'Standard'

@description('Optional. Location for ACR replica')
param acrReplicaLocation array = []

@description('Optional. Diagnostic settings configuration')
param diagnosticSettings array = []

@description('Optional. The IP ACL rules')
param ipRules array = []

@allowed([
  'AzureServices'
  'None'
])
@description('Optional. Bypass the network rules')
param networkRuleBypassOptions string = 'AzureServices'

@description('Optional. Enable Data endpoint')
param dataEndpointEnabled bool = false

@allowed([
  'Enabled'
  'Disabled'
])
@description('Optional. Enable zone Redundancy')
param zoneRedundancy string = 'Enabled'

@allowed([
  'Enabled'
  'Disabled'
])
@description('Optional. Enable Public network access to \'Selected networks\'')
param publicNetworkAccess string = 'Disabled'

@allowed([
  'Allow'
  'Deny'
])
@description('Optional. Enable Public network access to \'All networks\'')
param defaultAction string = 'Deny'

@description('Optional. Specifies whether the replications regional endpoint is enabled')
param regionEndpointEnabled bool = false

@description('Optional. Managed Identity')
param identity bool = true

@description('Optional. Array of Role Assignments to deploy')
param permissions array = []

var acrName_var = empty(customName) ? toLower('cr${workloadName}${applicationName}${environmentName}${regionName}${padLeft(index, 2, '0')}') : customName

resource acr 'Microsoft.ContainerRegistry/registries@2021-12-01-preview' = {
  name: acrName_var
  location: location
  tags: tags
  sku: {
    name: acrSku
  }
  identity: {
    type: identity ? 'SystemAssigned' : 'None'
  }
  properties: {
    adminUserEnabled: acrAdminUserEnabled
    anonymousPullEnabled: anonymousPullEnabled
    networkRuleSet: !contains(acrSku, 'Premium') ? null : {
      defaultAction: defaultAction
      ipRules: ipRules
    }
    dataEndpointEnabled: dataEndpointEnabled
    zoneRedundancy: !contains(acrSku, 'Premium') ? null : zoneRedundancy
    publicNetworkAccess: acrSku == 'Premium' ? publicNetworkAccess : 'Enabled'
    networkRuleBypassOptions: networkRuleBypassOptions
  }

  resource acrReplica 'replications@2021-09-01' = [for replica in acrReplicaLocation: if (!empty(acrReplicaLocation)) {
    name: replica
    location: replica
    tags: tags
    properties: {
      zoneRedundancy: zoneRedundancy
      regionEndpointEnabled: regionEndpointEnabled
    }
  }]
}

resource diagSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = [for diag in diagnosticSettings: if (!empty(diagnosticSettings)) {
  name: diag.name
  scope: acr
  properties: {
    workspaceId: contains(diag, 'workspaceId') ? diag.workspaceId : null
    storageAccountId: contains(diag, 'diagnosticsStorageAccountId') ? diag.diagnosticsStorageAccountId : null
    logs: contains(diag, 'logs') ? diag.logs : null
    metrics: contains(diag, 'metrics') ? diag.metrics : null
  }
}]

resource roleAssignments 'Microsoft.Authorization/roleAssignments@2022-01-01-preview' = [for item in permissions: {
  name: guid(resourceGroup().id, item.name, item.roleDefinitionId)
  scope: acr
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
output resourceName string = acr.name
@description('The resource-id of the Azure resource')
output resourceID string = acr.id
@description('The FQDN of the ACR login server')
output acrLoginServer string = reference(acr.id, '2019-05-01').loginServer
