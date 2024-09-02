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

@description('Required. Resource tags')
param tags object = {}

@description('Required. Define the kind app service, Linux or App')
@allowed([
  'Linux'
  'App'
])
param kind string

@description('Optional. If Linux app service plan; true, false otherwise')
param reserved bool = false

@description('Optional. Resource ID of the ASE this App Service Plan should use')
param appServiceEnvironmentId string = ''

@description('Optional. Current number of instances assigned to the resource')
param capacity int = 2

@description('Required. The SKU object of the App Service Plan')
param skuName string

@description('Required. The SKU object of the App Service Plan')
param skuTier string = 'Standard'

@description('Optional. If true, apps assigned to this App Service plan can be scaled independently. If false, apps assigned to this App Service plan will scale to all instances of the plan')
param perSiteScaling bool = true

@description('Optional. If true, this App Service Plan will perform availability zone balancing. If false, this App Service Plan will not perform availability zone balancing')
param zoneRedundant bool = false

@description('Optional. Location of the resource')
param location string = resourceGroup().location

@description('Optional. Diagnostic settings configuration')
param diagnosticSettings array = []

@description('Optional. Array of Role Assignments to deploy')
param permissions array = []

var appServicePlanName_var = empty(customName) ? toLower('plan-${workloadName}-${applicationName}-${environmentName}-${regionName}-${padLeft(index, 2, '0')}') : customName

resource appServicePlan 'Microsoft.Web/serverfarms@2021-03-01' = {
  name: appServicePlanName_var
  location: location
  tags: tags
  kind: kind
  properties: {
    reserved: reserved
    hostingEnvironmentProfile: empty(appServiceEnvironmentId) ? null : {
      id: appServiceEnvironmentId
    }
    perSiteScaling: perSiteScaling
    zoneRedundant: zoneRedundant
  }
  sku: {
    name: skuName
    capacity: capacity
    tier: skuTier
  }
}

resource diagSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = [for diag in diagnosticSettings: if (!empty(diagnosticSettings)) {
  name: diag.name
  scope: appServicePlan
  properties: {
    workspaceId: contains(diag, 'workspaceId') ? diag.workspaceId : null
    storageAccountId: contains(diag, 'diagnosticsStorageAccountId') ? diag.diagnosticsStorageAccountId : null
    logs: contains(diag, 'logs') ? diag.logs : null
    metrics: contains(diag, 'metrics') ? diag.metrics : null
  }
}]

resource roleAssignments 'Microsoft.Authorization/roleAssignments@2022-01-01-preview' = [for item in permissions: {
  name: guid(resourceGroup().id, item.name, item.roleDefinitionId)
  scope: appServicePlan
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
output resourceName string = appServicePlan.name
@description('The resource-id of the Azure resource')
output resourceID string = appServicePlan.id
