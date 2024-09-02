targetScope = 'resourceGroup'

@description('Required. The name of the application')
param applicationName string

@description('Required. The code of the environment this resource will be used in')
@maxLength(1)
param environmentName string

@description('Required. The name of the workload this resource will be used for')
param workloadName string

@description('Required. The region this resource will be deployed in')
@maxLength(4)
param regionName string

@description('Required. Index of the resource')
param index int

@description('Optional. The name to use if not using the normal naming convention')
param customName string = ''

@description('Optional. Resource tags')
param tags object = {}

@description('Optional. The name of the SKU')
@allowed([
  'CapacityReservation'
  'Free'
  'LACluster'
  'PerGB2018'
  'PerNode'
  'Premium'
  'Standalone'
  'Standard'
])
param serviceTier string = 'PerGB2018'

@description('Optional. The workspace data retention in days. Allowed values are per pricing plan. See pricing tiers documentation for details')
param retentionInDays int = 30

@description('Optional. The network access type for operating on the Log Analytics Workspace')
@allowed([
  'Enabled'
  'Disabled'
])
param publicNetworkAccessForIngestion string = 'Enabled'

@description('Optional. The network access type for operating on the Log Analytics Workspace')
@allowed([
  'Enabled'
  'Disabled'
])
param publicNetworkAccessForQuery string = 'Enabled'

@description('Optional. Flag that indicate which permission to use - resource or workspace or both')
param enableLogAccessUsingOnlyResourcePermissions bool = false

@description('Required. The solution names')
param solutionTypes array

@description('Optional. The subscription IDs that you want to monitor')
param subscriptions array = []

@description('Optional. Resource ID of the automation account you want to link to the workspace')
param linkAutomationAccountResourceId string = ''

@description('Optional. Location of the resource')
param location string = resourceGroup().location

@description('Optional. Array of Role Assignments to deploy')
param permissions array = []

var nameVar = empty(customName) ? toLower('log-${workloadName}-${applicationName}-${environmentName}-${regionName}-${padLeft(index, 2, '0')}') : customName

resource workspace 'Microsoft.OperationalInsights/workspaces@2021-06-01' = {
  name: nameVar
  location: location
  tags: tags
  properties: {
    sku: {
      name: serviceTier
    }
    retentionInDays: retentionInDays
    publicNetworkAccessForIngestion: publicNetworkAccessForIngestion
    publicNetworkAccessForQuery: publicNetworkAccessForQuery
    features: {
      enableLogAccessUsingOnlyResourcePermissions: enableLogAccessUsingOnlyResourcePermissions
    }
  }

  resource datasources 'dataSources@2020-08-01' = [for item in subscriptions: if (length(subscriptions) != 0) {
    name: empty(subscriptions) ? '${nameVar}/empty1' : '${nameVar}/${replace(item.name, '&', '')}'
    kind: 'AzureActivityLog'
    properties: {
      #disable-next-line use-resource-id-functions
      linkedResourceId: '/subscriptions/${string(item.value)}/providers/microsoft.insights/eventTypes/management'
    }
  }]

  resource linkedServices 'linkedServices@2020-08-01' = if (!empty(linkAutomationAccountResourceId)) {
    name: 'Automation'
    properties: {
      resourceId: linkAutomationAccountResourceId
    }
  }
}

resource solution 'Microsoft.OperationsManagement/solutions@2015-11-01-preview' = [for item in solutionTypes: {
  name: '${item}(${nameVar})'
  location: location
  tags: tags
  plan: {
    name: '${item}(${nameVar})'
    product: 'OMSGallery/${item}'
    promotionCode: ''
    publisher: 'Microsoft'
  }
  properties: {
    workspaceResourceId: workspace.id
  }
}]

resource AutomationAccount 'Microsoft.Automation/automationAccounts@2021-06-22' existing = {
  name: last(split(linkAutomationAccountResourceId, '/'))
}

resource diagSettings1 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if (!empty(linkAutomationAccountResourceId)) {
  name: 'setByFoundationPolicy'
  scope: AutomationAccount
  properties: {
    workspaceId: workspace.id
    logs: [
      {
        category: 'JobLogs'
        enabled: true
      }
      {
        category: 'JobStreams'
        enabled: true
      }
      {
        category: 'DscNodeStatus'
        enabled: true
      }
      {
        category: 'AuditEvent'
        enabled: true
      }
    ]
  }
}

resource roleAssignments 'Microsoft.Authorization/roleAssignments@2022-04-01' = [for item in permissions: {
  name: guid(resourceGroup().id, item.name, item.roleDefinitionId)
  scope: workspace
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
output resourceName string = workspace.name
@description('The resource-id of the Azure resource')
output resourceID string = workspace.id
@description('Workspace ID of the Log Analytics workspace')
output workspaceId string = workspace.properties.customerId
