targetScope = 'subscription'

@description('Required. Resource ID of the central log analytics workspace')
param logAnalyticsResourceId string

@description('Optional. Diagnostics category configuration')
param logs array = [
  {
    category: 'Administrative'
    enabled: true
  }
  {
    category: 'Security'
    enabled: true
  }
  {
    category: 'ServiceHealth'
    enabled: true
  }
  {
    category: 'Policy'
    enabled: true
  }
  {
    category: 'ResourceHealth'
    enabled: true
  }
  {
    category: 'Alert'
    enabled: true
  }
  {
    category: 'Recommendation'
    enabled: true
  }
  {
    category: 'Autoscale'
    enabled: true
  }
]

resource subscriptionLogsToLogAnalytics 'Microsoft.Insights/diagnosticSettings@2017-05-01-preview' = {
  name: 'subscriptionLogsToLogAnalytics'
  properties: {
    workspaceId: logAnalyticsResourceId
    logs: logs
  }
}

@description('Target Subscription resourceId')
output resourceId string = subscriptionLogsToLogAnalytics.id

@description('Target Subscription Name')
output resourceName string = subscriptionLogsToLogAnalytics.name
