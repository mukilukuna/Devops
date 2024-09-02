targetScope = 'resourceGroup'

@description('Optional. Time parameter to create unique deployment. Do not set in parameter file!')
param time string = replace(utcNow(), ':', '-')

@description('JSON configuration object for bicep deployments')
var subscriptionConfig = loadJsonContent('../../configs/subscriptionConfig.jsonc')
var tags = subscriptionConfig.Governance.tags

@description('JSON configuration objects for connectionMonitor bicep deployments')
var connectionMonitorConfig = loadJsonContent('../../configs/connectionMonitor/connectionMonitor.platform.jsonc')

@description('Location of the resource group')
var location = subscriptionConfig.Governance.location

module NetworkWatcherConnectionMonitor '../../../Templates/Features/NetworkWatcherConnectionMonitor/template.bicep' = {
  name: 'NetworkWatcher-${time}'
  params: {
    name: 'nw-infr-monitoring-p-weu-01'
    networkWatcherName: 'NetworkWatcher_westeurope'
    endpoints: connectionMonitorConfig.endpoints
    testConfigurations: connectionMonitorConfig.testConfigurations
    testGroups: connectionMonitorConfig.testGroups
    workspaceResourceId: '*<mgmtWeu-logAnalytics_ResourceId>*'
    tags: tags
    location: location
  }
}
