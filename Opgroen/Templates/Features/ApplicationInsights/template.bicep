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

@description('Optional. Resource tags')
param tags object = {}

@description('Optional. The kind of application that this component refers to, used to customize UI')
@allowed([
  'web'
  'ios'
  'other'
  'store'
  'java'
  'phone'
])
param kind string = 'web'

@description('Optional. The kind of application being monitored')
@allowed([
  'web'
  'other'
])
param applicationType string = 'web'

@description('Optional. Enables/Disabled IP masking property')
param disableIpMasking bool = false

@description('Required. Resource Id of the log analytics workspace which the data will be ingested to')
param workspaceResourceId string

@description('Optional. The Retention period of ingested data in days')
param retentionInDays int = 90

@description('Optional. Percentage of the data produced by the application being monitored that is sampled')
param samplingPercentage int = 100

@description('Optional. Array of Role Assignments to deploy')
param permissions array = []

@description('Optional. Microsoft Insights diagnosticSettings configuration')
param diagnosticSettings array = []

var insightsNamevar = empty(customName) ? toLower('appi-${workloadName}-${applicationName}-${environmentName}-${regionName}-${padLeft(index, 2, '0')}') : customName

resource insightsName 'Microsoft.Insights/components@2020-02-02' = {
  name: insightsNamevar
  location: location
  tags: tags
  kind: kind
  properties: {
    Application_Type: applicationType
    DisableIpMasking: disableIpMasking
    WorkspaceResourceId: workspaceResourceId
    RetentionInDays: retentionInDays
    SamplingPercentage: samplingPercentage
  }
}

resource roleAssignments 'Microsoft.Authorization/roleAssignments@2022-01-01-preview' = [for item in permissions: {
  name: guid(resourceGroup().id, item.name, item.roleDefinitionId)
  scope: insightsName
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

resource diagSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = [for item in diagnosticSettings: if (!empty(diagnosticSettings)) {
  name: item.name
  scope: insightsName
  properties: {
    storageAccountId: contains(item, 'storageAccountId') ? item.storageAccountId : null
    serviceBusRuleId: contains(item, 'serviceBusRuleId') ? item.serviceBusRuleId : null
    eventHubName: contains(item, 'eventHubName') ? item.eventHubName : null
    eventHubAuthorizationRuleId: contains(item, 'eventHubAuthorizationRuleId') ? item.eventHubAuthorizationRuleId : null
    workspaceId: contains(item, 'workspaceId') ? item.workspaceId : null
    logs: contains(item, 'logs') ? item.logs : null
    metrics: contains(item, 'metrics') ? item.metrics : null
  }
}]

@description('The name of the Azure resource')
output resourceName string = insightsName.name
@description('The resource-id of the Azure resource')
output resourceID string = insightsName.id
