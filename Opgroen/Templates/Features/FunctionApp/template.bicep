@description('Required. The name of the application')
param applicationName string

@description('Required. The code of the environment this resource will be used in')
@maxLength(1)
param environmentName string

@description('Required. The name of the workload this resource will be used for')
param workloadName string

@description('Required. Region of the resource')
@maxLength(4)
param regionName string

@description('Optional. The name to use if not using the normal naming convention')
param customName string = ''

@description('Optional. Resource tags')
param tags object = {}

@description('Required. The Operating System the function app will run on')
param operatingSystem string

@description('Optional. Kind of resource. If left empty, kind will be `linux,functionapp` for linux, and `functionapp` for windows')
param kind string = ''

@description('Required. The runtime to use for this function app')
param workerRuntime string

@description('Optional. Indicates if 32-bits worker processes should be used')
param use32BitsWorkers bool = true

@description('Optional. The version of Node.js to use (in case of a Node.js app)')
param nodeVersion string = '10.14.1'

@description('Required. The resource ID of the App Service Plan to use')
param appServicePlanId string

@description('Required. The resource ID of the storage account to be used')
param storageAccountId string

@description('Optional. The instrumentation key for Application Insights')
param applicationInsightsId string = ''

@description('Optional. Settings for the Function App')
param appSettings array = []

@description('Optional. Indicates if a system assigned managed identity should be created for the function app')
param enableManagedIdentity bool = true

@description('Optional. Indicates if web sockets will be enabled on the function app')
param webSocketsEnabled bool = false

@description('Optional. Indicates if Always On will be enabled on the function app')
param alwaysOn bool = true

@description('Optional. The managed pipeline mode that will be used on the function app')
@allowed([
  'Integrated'
  'Classic'
])
param managedPipelineMode string = 'Integrated'

@description('Optional. Http20Enabled: configures a web site to allow clients to connect over http 2.0')
param http20Enabled bool = true

@description('Optional. Indicates if remote debugging will be enabled on the function app')
param remoteDebuggingEnabled bool = false

@description('Optional. Enables Logic App resource to access the website content over VNET traffic i.e. on service endpoints or private endpoints')
param contentOverVnet bool = false

@description('Optional. The Visual Studio version that will be used for remote debugging')
param remoteDebuggingVersion string = 'VS2019'

@description('Optional. State of FTP / FTPS service')
@allowed([
  'AllAllowed'
  'Disabled'
  'FtpsOnly'
])
param ftpsState string = 'FtpsOnly'

@description('Optional. turn on HTTPS only')
param httpsOnly bool = true

@description('Optional. turn on clientAffinityEnabled')
param clientAffinityEnabled bool = false

@description('Optional. Select the minimum TLS version')
@allowed([
  '1.0'
  '1.1'
  '1.2'
])
param minTlsVersion string = '1.2'

@description('Optional. The resource ID of the subnet this function app should integrate with')
param subnetResourceId string = ''

@description('Optional. Endpoint suffix of the private endpoint`s dns zone, e.g. core.windows.net')
param endpointSuffix string = ''

@description('Optional. ID of the extension bundle')
param extensionBundleId string = ''

@description('Optional. Version of the extension bundle')
param extensionBundleVersion string = ''

@description('Optional. Virtual Network Route All enabled. This causes all outbound traffic to have Virtual Network Security Groups and User Defined Routes applied')
param vnetRouteAllEnabled bool = false

@description('Optional. Location of the resource')
param location string = resourceGroup().location

@description('Optional. Array of Role Assignments to deploy')
param permissions array = []

@description('Optional. Diagnostic settings configuration')
param diagnosticSettings array = []

var nameVar = empty(customName) ? toLower('func-${workloadName}-${applicationName}-${environmentName}-${regionName}-${uniqueString(resourceGroup().id)}') : customName

resource stg 'Microsoft.Storage/storageAccounts@2021-09-01' existing = {
  name: last(split(storageAccountId, '/'))
  scope: resourceGroup(split(storageAccountId, '/')[4])
}

resource applicationInsights 'Microsoft.Insights/components@2020-02-02' existing = if (!empty(applicationInsightsId)) {
  name: last(split(applicationInsightsId, '/'))
  scope: resourceGroup(split(applicationInsightsId, '/')[4])
}

resource functionApp 'Microsoft.Web/sites@2022-03-01' = {
  name: nameVar
  location: location
  tags: tags
  kind: !empty(kind) ? kind : (operatingSystem == 'linux') ? 'functionapp,linux' : 'functionapp'
  identity: enableManagedIdentity ? {
    type: 'SystemAssigned'
  } : null
  properties: {
    serverFarmId: appServicePlanId
    httpsOnly: httpsOnly
    virtualNetworkSubnetId: !empty(subnetResourceId) ? subnetResourceId : null
    clientAffinityEnabled: clientAffinityEnabled
    siteConfig: {
      minTlsVersion: minTlsVersion
      appSettings: concat(appSettings, [
          {
            name: 'AzureWebJobsStorage'
            value: 'DefaultEndpointsProtocol=https;AccountName=${last(split(storageAccountId, '/'))};AccountKey=${stg.listKeys().keys[0].value}${!empty(endpointSuffix) ? ';EndpointSuffix=${endpointSuffix}' : null}'
          }
          {
            name: 'FUNCTIONS_WORKER_RUNTIME'
            value: workerRuntime
          }
          {
            name: 'FUNCTIONS_EXTENSION_VERSION'
            value: '~4'
          }
          !empty(applicationInsightsId) ? {
            name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
            value: applicationInsights.properties.InstrumentationKey
          } : {
            name: 'AzureWebJobsDashboard'
            value: 'DefaultEndpointsProtocol=https;AccountName=${last(split(storageAccountId, '/'))};AccountKey=${stg.listKeys().keys[0].value}${!empty(endpointSuffix) ? ';EndpointSuffix=${endpointSuffix}' : null}'
          }
          {
            name: 'WEBSITE_CONTENTAZUREFILECONNECTIONSTRING'
            value: 'DefaultEndpointsProtocol=https;AccountName=${last(split(storageAccountId, '/'))};AccountKey=${stg.listKeys().keys[0].value}${!empty(endpointSuffix) ? ';EndpointSuffix=${endpointSuffix}' : null}'
          }
          {
            name: 'WEBSITE_CONTENTSHARE'
            value: nameVar
          }
          !empty(applicationInsightsId) ? {
            name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
            value: applicationInsights.properties.ConnectionString
          } : []
          workerRuntime == 'node' ? {
            name: 'WEBSITE_NODE_DEFAULT_VERSION'
            value: nodeVersion
          } : []
          contentOverVnet == true ? {
            name: 'WEBSITE_CONTENTOVERVNET'
            value: '1'
          } : []
          !empty(extensionBundleId) ? {
            name: 'AzureFunctionsJobHost__extensionBundle__id'
            value: extensionBundleId
          } : []
          !empty(extensionBundleVersion) ? {
            name: 'AzureFunctionsJobHost__extensionBundle__version'
            value: extensionBundleVersion
          } : []
          kind == 'workflowapp' || kind == 'functionapp,workflowapp' ? {
            name: 'APP_KIND'
            value: 'workflowApp'
          } : []
        ])
      use32BitWorkerProcess: use32BitsWorkers
      webSocketsEnabled: webSocketsEnabled
      alwaysOn: alwaysOn
      managedPipelineMode: managedPipelineMode
      http20Enabled: http20Enabled
      vnetRouteAllEnabled: vnetRouteAllEnabled
      remoteDebuggingEnabled: remoteDebuggingEnabled
      remoteDebuggingVersion: remoteDebuggingVersion
      ftpsState: ftpsState
      linuxFxVersion: operatingSystem == 'linux' ? workerRuntime == 'python' ? 'python|3.6' : workerRuntime == 'node' ? 'node|8' : 'dotnet|2.2' : null
    }
  }
}

resource networkconfig 'Microsoft.Web/sites/networkConfig@2021-02-01' = if (!empty(subnetResourceId)) {
  parent: functionApp
  name: 'virtualNetwork'
  properties: {
    subnetResourceId: subnetResourceId
    swiftSupported: true
  }
}

resource diagSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = [for setting in diagnosticSettings: if (!empty(diagnosticSettings)) {
  name: setting.name
  scope: functionApp
  properties: {
    workspaceId: contains(setting, 'workspaceId') ? setting.workspaceId : null
    storageAccountId: contains(setting, 'diagnosticsStorageAccountId') ? setting.diagnosticsStorageAccountId : null
    logs: contains(setting, 'logs') ? setting.logs : null
    metrics: contains(setting, 'metrics') ? setting.metrics : null
  }
}]

resource roleAssignments 'Microsoft.Authorization/roleAssignments@2022-04-01' = [for item in permissions: {
  name: guid(resourceGroup().id, item.name, item.roleDefinitionId)
  scope: functionApp
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
output resourceName string = functionApp.name
@description('The resource-id of the Azure resource')
output resourceID string = functionApp.id
