@description('Required. Name of the connection monitor')
param name string

@description('Optional. Name of the networkwatcher')
param networkWatcherName string = 'NetworkWatcher_westeurope'

@description('Required. List of connection monitor endpoints')
param endpoints array

@description('Required. List of connection monitor test configurations')
param testConfigurations array

@description('Required. List of connection monitor test groups')
param testGroups array

@description('Optional. Location of the connection monitor')
param location string = resourceGroup().location

@description('Optional. Workspace resource ID')
param workspaceResourceId string = ''

@description('Optional. Resource tags')
param tags object = {}

@description('Optional. Microsoft Insights diagnosticSettings configuration')
param diagnosticSettings array = []

resource networkWatcher 'Microsoft.Network/networkWatchers@2021-12-01' existing = {
  name: networkWatcherName

  resource connectionMonitor 'connectionMonitors' = {
    name: name
    location: location
    tags: tags
    properties: {
      endpoints: endpoints
      testConfigurations: testConfigurations
      testGroups: testGroups
      outputs: [
        {
          type: 'Workspace'
          workspaceSettings: {
            workspaceResourceId: workspaceResourceId
          }
        }
      ]
    }
  }
}

resource diagSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = [for item in diagnosticSettings: if (!empty(diagnosticSettings)) {
  name: item.name
  scope: networkWatcher::connectionMonitor
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

@description('Id of the resource')
output resourceId string = networkWatcher::connectionMonitor.id
@description('Name of the resource')
output resourceName string = networkWatcher::connectionMonitor.name
