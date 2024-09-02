@description('Required. The name of the application')
param applicationName string

@description('Required. The code of the environment this resource will be used in')
@maxLength(1)
param environmentName string

@description('Required. The name of the workload this resource will be used for')
param workloadName string

@description('Required. region of the resource')
@maxLength(4)
param regionName string

@description('Optional. The name to use if not using the normal naming convention')
param customName string = ''

@description('Optional. Resource tags')
param tags object = {}

@description('Optional. Operational status of the Front Door load balancer')
@allowed([
  'Enabled'
  'Disabled'
])
param enabledState string = 'Enabled'

@description('Optional. Health probe settings associated with this Front Door instance')
param healthProbeSettings array = []

@description('Required. Backend pools available to routing rules')
param backendPools array

@description('Required. Load balancing settings associated with this Front Door instance')
param loadBalancingSettings array

@description('Required. Frontend endpoints available to routing rules')
param frontEndPoints array

@description('Required. Routing rules associated with this Front Door')
param routingRules array

@description('Optional. Routing rule Engine associated with this Front Door')
param routingRulesEngine array = []

@description('Optional. Microsoft Insights diagnosticSettings configuration')
param diagnosticSettings array = []

@description('Optional. Array of Role Assignments to deploy')
param permissions array = []

var nameVar = toLower('fd-${workloadName}-${applicationName}-${environmentName}-${regionName}-${uniqueString(resourceGroup().id)}')
var uniqueNameVar = empty(customName) ? '${nameVar}-${uniqueString(resourceGroup().id, nameVar)}' : customName
var safeDiagnosticSettings = empty(diagnosticSettings) ? [
  {
    name: 'workspace1'
    logs: []
    metrics: []
  }
] : diagnosticSettings

var healthProbeSettings_var = [for item in healthProbeSettings: {
  name: item.name
  properties: {
    protocol: item.protocol
    path: item.path
    intervalInSeconds: item.intervalInSeconds
    healthProbeMethod: item.healthProbeMethod
    enabledState: item.enabledState
  }
}]

var frontEndPoints_var = [for item in frontEndPoints: {
  name: item.name
  properties: {
    hostName: item.hostname
    sessionAffinityEnabledState: item.sessionAffinityEnabledState
    sessionAffinityTtlSeconds: item.sessionAffinityTtlSeconds
    webApplicationFirewallPolicyLink: contains(item, 'webApplicationFirewallPolicyLink') ? {
      id: item.webApplicationFirewallPolicyLink
    } : null
  }
}]

var loadBalancingSettings_var = [for item in loadBalancingSettings: {
  name: item.name
  properties: {
    additionalLatencyMilliseconds: item.additionalLatencyMilliseconds
    sampleSize: item.sampleSize
    successfulSamplesRequired: item.successfulSamplesRequired
  }
}]

var routeConfForward = [for item in routingRules: {
  name: item.name
  properties: {
    frontendEndpoints: item.frontendEndpoints
    acceptedProtocols: item.acceptedProtocols
    patternsToMatch: item.patternsToMatch
    enabledState: item.enabledState
    rulesEngine: contains(item, 'rulesEngine') && !empty(item.rulesEngine) ? {
      id: '${resourceId('Microsoft.Network/frontdoors', uniqueNameVar)}/RulesEngines/${item.rulesEngine}'
    } : null
    routeConfiguration: {
      '@odata.type': '#Microsoft.Azure.FrontDoor.Models.FrontdoorForwardingConfiguration'
      customForwardingPath: contains(item, 'customForwardingPath') ? item.customForwardingPath : null
      forwardingProtocol: contains(item, 'customForwardingPath') ? item.forwardingProtocol : null
      backendPool: contains(item, 'backendPool') ? {
        id: resourceId('Microsoft.Network/frontDoors/backendPools', uniqueNameVar, item.backendPool)
      } : null
      cacheConfiguration: contains(item, 'cacheConfiguration') ? item.cacheConfiguration : null
    }
  }
}]

var routeConfRedirect = [for item in routingRules: {
  name: item.name
  properties: {
    frontendEndpoints: item.frontendEndpoints
    acceptedProtocols: item.acceptedProtocols
    patternsToMatch: item.patternsToMatch
    enabledState: item.enabledState
    rulesEngine: contains(item, 'rulesEngine') && !empty(item.rulesEngine) ? {
      id: '${resourceId('Microsoft.Network/frontdoors', uniqueNameVar)}/RulesEngines/${item.rulesEngine}'
    } : null
    routeConfiguration: {
      '@odata.type': '#Microsoft.Azure.FrontDoor.Models.FrontdoorRedirectConfiguration'
      redirectType: contains(item, 'redirectType') ? item.redirectType : null
      redirectProtocol: contains(item, 'redirectProtocol') ? item.redirectProtocol : null
      customHost: contains(item, 'customHost') ? item.customHost : null
      customPath: contains(item, 'customPath') ? item.customPath : null
      customQueryString: contains(item, 'customQueryString') ? item.customQueryString : null
      customFragment: contains(item, 'customFragment') ? item.customFragment : null
    }
  }
}]

resource frontdoor 'Microsoft.Network/frontDoors@2020-05-01' = {
  name: uniqueNameVar
  location: 'Global'
  tags: tags
  properties: {
    backendPools: [for item in backendPools: {
      name: item.name
      properties: {
        backends: item.backends
        healthProbeSettings: contains(item, 'healthProbeSettings') ? {
          id: resourceId('Microsoft.Network/frontDoors/healthProbeSettings', uniqueNameVar, item.healthProbeSettings)
        } : null
        loadBalancingSettings: contains(item, 'loadBalancingSettings') ? {
          id: resourceId('Microsoft.Network/frontDoors/loadBalancingSettings', uniqueNameVar, item.loadBalancingSettings)
        } : null
      }
    }]
    healthProbeSettings: healthProbeSettings_var
    frontendEndpoints: frontEndPoints_var
    loadBalancingSettings: loadBalancingSettings_var
    routingRules: [for (item, i) in routingRules: item.odataType == 'forward' ? routeConfForward[i] : routeConfRedirect[i]]
    enabledState: enabledState
    friendlyName: uniqueNameVar
  }

  resource rulesEngines 'rulesEngines' = [for item in routingRulesEngine: {
    name: item.name
    properties: {
      rules: item.rules
    }
  }]
}

resource diagSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = [for item in safeDiagnosticSettings: if (!empty(diagnosticSettings)) {
  name: item.name
  scope: frontdoor
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

resource roleAssignments 'Microsoft.Authorization/roleAssignments@2022-01-01-preview' = [for item in permissions: {
  name: guid(resourceGroup().id, item.name, item.roleDefinitionId)
  scope: frontdoor
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
output resourceName string = frontdoor.name
@description('The resource-id of the Azure resource')
output resourceID string = frontdoor.id
