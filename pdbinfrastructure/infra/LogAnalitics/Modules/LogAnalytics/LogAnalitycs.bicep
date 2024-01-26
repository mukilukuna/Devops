@description('tags benodigd voor resources')
param tags object

@description('locatie van de loganalytics resource')
param location string

@description('naam van de loganalytics Workspace')
param loganalyticsWSName string

@description('RetentionInDays')
param RetentionInDays int = 30

@description('Log analytics SKU')
param sku string = 'PerGB2018'

@allowed([
  'Enabled'
  'Disabled'
])
@description('publicNetworkAccessforIngestion')
param publicNetworkAccessforIngestion string = 'Enabled'

@allowed([
  'Enabled'
  'Disabled'
])
@description('publicNetworkAccessforQuery')
param publicNetworkAccessforQuery string = 'Enabled'

resource logAnalytics 'Microsoft.OperationalInsights/workspaces@2021-12-01-preview' = {
  name: loganalyticsWSName
  location: location
  tags: tags
  properties: {
    publicNetworkAccessForIngestion: publicNetworkAccessforIngestion
    publicNetworkAccessForQuery: publicNetworkAccessforQuery
    retentionInDays: RetentionInDays
    sku: {
      name: sku
    }
  }
}

output logAnalyticsWSName string = logAnalytics.name
output logAnalyticsWSResourceId string = logAnalyticsWS.id
