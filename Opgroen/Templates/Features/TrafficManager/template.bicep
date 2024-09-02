@description('Required. The application name of the resource')
param applicationName string

@description('Required. The environment letter of the resource')
@maxLength(1)
param environmentName string

@description('Required. The workload name of the resource')
param workloadName string

@description('Required. The region of the resource')
@maxLength(4)
param regionName string

@description('Required. The index of the resource')
param index int

@description('Optional. Custom name of the resource')
param customName string = ''

@description('Optional. Object containing the tags to apply to all resources.')
param tags object = {}

@description('Optional. The traffic routing method of the Traffic Manager profile.')
@allowed([
  'Performance'
  'Priority'
  'Weighted'
  'Geographic'
  'MultiValue'
  'Subnet'
])
param trafficRoutingMethod string = 'Performance'

@description('Optional. Maximum number of endpoints to be returned for MultiValue routing type.')
param maxReturn int = 2

@description('Optional. The DNS Time-To-Live (TTL), in seconds. This informs the local DNS resolvers and DNS clients how long to cache DNS responses provided by this Traffic Manager profile.')
param dnsTtl int = 60

@description('Optional. The protocol used to probe for endpoint health.')
@allowed([
  'HTTPS'
  'HTTP'
  'TCP'
])
param monitorConfigProtocol string = 'HTTPS'

@description('Optional. The TCP port used to probe for endpoint health.')
param monitorConfigPort int = 443

@description('Optional. The path relative to the endpoint domain name used to probe for endpoint health.')
param monitorConfigPath string = '/'

@description('Optional. The monitor interval for endpoints in this profile. This is the interval at which Traffic Manager will check the health of each endpoint in this profile.')
param intervalInSeconds int = 30

@description('Optional. The monitor interval for endpoints in this profile. This is the time that Traffic Manager allows endpoints in this profile to response to the health check.')
param timeoutInSeconds int = 10

@description('Optional. The number of consecutive failed health check that Traffic Manager tolerates before declaring an endpoint in this profile Degraded after the next failed health check.')
param toleratedNumberOfFailures int = 3

@description('Optional. List of custom headers.')
param customHeaders array = []

@description('Optional. List of expected status code ranges.')
param expectedStatusCodeRanges array = []

@description('Optional. Indicates whether Traffic View is \'Enabled\' or \'Disabled\' for the Traffic Manager profile.')
@allowed([
  'Disabled'
  'Enabled'
])
param trafficViewEnrollmentStatus string = 'Disabled'

@description('Optional. Diagnostic settings configuration.')
param diagnosticSettings array = []

@description('Optional. Array of Role Assignments to deploy')
param permissions array = []

var trafficManagerNamevar = toLower('trafp-${workloadName}-${applicationName}-${environmentName}-${regionName}-${padLeft(index, 2, '0')}')

resource trafficManager 'Microsoft.Network/trafficmanagerprofiles@2018-08-01' = {
  name: empty(customName) ? '${trafficManagerNamevar}-${uniqueString(resourceGroup().id, trafficManagerNamevar)}' : customName
  tags: tags
  location: 'global'
  properties: {
    trafficRoutingMethod: trafficRoutingMethod
    maxReturn: maxReturn
    trafficViewEnrollmentStatus: trafficViewEnrollmentStatus
    dnsConfig: {
      relativeName: trafficManagerNamevar
      ttl: dnsTtl
    }
    monitorConfig: {
      protocol: monitorConfigProtocol
      port: monitorConfigPort
      path: monitorConfigPath
      intervalInSeconds: intervalInSeconds
      timeoutInSeconds: timeoutInSeconds
      toleratedNumberOfFailures: toleratedNumberOfFailures
      customHeaders: customHeaders
      expectedStatusCodeRanges: expectedStatusCodeRanges
    }
  }
}

resource diagSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = [for setting in diagnosticSettings: if (!empty(diagnosticSettings)) {
  name: setting.name
  scope: trafficManager
  properties: {
    workspaceId: contains(setting, 'workspaceId') ? setting.workspaceId : null
    storageAccountId: contains(setting, 'diagnosticsStorageAccountId') ? setting.diagnosticsStorageAccountId : null
    logs: contains(setting, 'logs') ? setting.logs : null
    metrics: contains(setting, 'metrics') ? setting.metrics : null
  }
}]

resource roleAssignments 'Microsoft.Authorization/roleAssignments@2022-01-01-preview' = [for item in permissions: {
  name: guid(resourceGroup().id, item.name, item.roleDefinitionId)
  scope: trafficManager
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
output resourceID string = trafficManager.id
@description('The resource-id of the Azure resource')
output resourceName string = trafficManager.name
@description('The FQDN of the Azure Traffic Manager Instance')
output trafficManagerFqdn string = trafficManager.properties.dnsConfig.fqdn
