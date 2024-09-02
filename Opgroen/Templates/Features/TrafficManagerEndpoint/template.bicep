@description('Required. The application name of the resource.')
param applicationName string

@description('Required. The environment letter of the resource.')
@maxLength(1)
param environmentName string

@description('Required. The workload name of the resource')
param workloadName string

@description('Required. The region of the resource')
@maxLength(4)
param regionName string

@description('Required. The index of the resource')
param index int

@description('Optional. The Custom name of the resource')
param customName string = ''

@description('Required. Name of the Traffic Manager profile for which the endpoint will be created.')
param trafficManagerName string

@description('Required. The type of traffic manager endpoint')
@allowed([
  'ExternalEndpoints'
  'AzureEndpoints'
  'NestedEndpoints'
])
param trafficManagerEndpointType string

@description('Optional. The status of the endpoint. If the endpoint is Enabled, it is probed for endpoint health and is included in the traffic routing method')
param endpointStatus string = 'enabled'

@description('Required. The fully-qualified DNS name of the endpoint. Traffic Manager returns this value in DNS responses to direct traffic to this endpoint.')
param target string

@description('Optional. The Azure Resource URI of the of the endpoint. Not applicable to endpoints of type \'ExternalEndpoints\'.')
param targetResourceId string = 'json(\'null\')'

@description('Required. Specifies the location of the external or nested endpoints when using the ‘Performance’ traffic routing method.')
param endpointLocation string

@description('Optional. The list of countries/regions mapped to this endpoint when using the ‘Geographic’ traffic routing method.')
param geoMapping array = []

@description('Optional. The minimum number of endpoints that must be available in the child profile in order for the parent profile to be considered available')
param minChildEndpoints int = 1

@description('Required. The weight of this endpoint when using the \'Weighted\' traffic routing method')
param weight int

@description('Required. The priority of this endpoint when using the ‘Priority’ traffic routing method. ')
param priority int

@description('Optional. List of custom headers')
param customHeaders array = []

@description('Optional. Array of Role Assignments to deploy')
param permissions array = []

var nameVar = empty(customName) ? toLower('trafe-${workloadName}-${applicationName}-${environmentName}-${regionName}-${padLeft(index, 2, '0')}') : customName

// TODO
resource trafficManager 'Microsoft.Network/trafficmanagerprofiles@2018-08-01' existing = {
  name: trafficManagerName

  resource azureEndpoints 'azureEndpoints@2018-08-01' = if (contains(trafficManagerEndpointType, 'AzureEndpoints')) {
    name: nameVar
    properties: {
      endpointStatus: endpointStatus
      targetResourceId: targetResourceId
      target: target
      endpointLocation: endpointLocation
      weight: weight
      priority: priority
      geoMapping: empty(geoMapping) ? null : geoMapping
      minChildEndpoints: trafficManagerEndpointType == 'nestedEndpoints' ? minChildEndpoints : null
      customHeaders: customHeaders
    }
  }

  resource externalEndpoints 'externalEndpoints@2018-08-01' = if (contains(trafficManagerEndpointType, 'ExternalEndpoints')) {
    name: nameVar
    properties: {
      endpointStatus: endpointStatus
      target: target
      endpointLocation: endpointLocation
      weight: weight
      priority: priority
      geoMapping: empty(geoMapping) ? null : geoMapping
      minChildEndpoints: trafficManagerEndpointType == 'nestedEndpoints' ? minChildEndpoints : null
      customHeaders: customHeaders
    }
  }

  resource nestedEndpoints 'nestedEndpoints@2018-08-01' = if (contains(trafficManagerEndpointType, 'NestedEndpoints')) {
    name: nameVar
    properties: {
      endpointStatus: endpointStatus
      targetResourceId: targetResourceId
      target: target
      endpointLocation: endpointLocation
      weight: weight
      priority: priority
      geoMapping: empty(geoMapping) ? null : geoMapping
      minChildEndpoints: trafficManagerEndpointType == 'NestedEndpoints' ? minChildEndpoints : null
      customHeaders: customHeaders
    }
  }
}

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
output resourceName string = nameVar
@description('The resource-id of the Azure resource')
output resourceID string = resourceId('Microsoft.Network/trafficManagerProfiles', nameVar)
