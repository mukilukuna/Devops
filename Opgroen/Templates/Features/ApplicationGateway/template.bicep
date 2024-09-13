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

@description('Required. index of the resource')
param index int

@description('Optional. Location of the Application Gateway')
param location string = resourceGroup().location

@description('Optional. Resource Tags')
param tags object = {}

@description('Optional. The name to use if not using the normal naming convention')
param customName string = ''

@description('Optional. The name to use if not using the normal naming convention')
param customNamePIP string = ''

@description('Optional. Name of an application gateway SKU')
@allowed([
  'Standard_Small'
  'Standard_Medium'
  'Standard_Large'
  'WAF_Medium'
  'WAF_Large'
  'Standard_v2'
  'WAF_v2'
])
param applicationGatewaySize string = 'WAF_v2'

@description('Optional. Tier of an application gateway')
@allowed([
  'Standard'
  'WAF'
  'Standard_v2'
  'WAF_v2'
])
param applicationGatewayTier string = 'WAF_v2'

@description('Optional. Availability zones numbers to use')
param zones array = [
  '1'
  '2'
  '3'
]

@description('Optional. Capacity (instance count) of an application gateway')
param capacity int = 2

@description('Optional. Maximum auto-scale capacity (instance count) of an application gateway')
param autoScaleMaxCapacity int = 10

@description('Optional. Whether the application gateway can auto scale or uses fixed number of instances')
param enableAppGatewayV2AutoScaling bool = true

@description('Optional. Deploy an managed identity')
param enableManagedIdentity bool = false

@description('Required. The resourceID of the subnet')
param subnetId string

@description('Optional. public or private')
param frontEndType string = 'public'

@description('Optional. Static private IP-address for frontend listner. Choose last IP-address from CIDR address space')
param frontEndPrivateIpAddress string = ''

@description('Optional. Dynamic or Static')
@allowed([
  'Dynamic'
  'Static'
])
param publicIPAllocation string = 'Static'

@description('Optional. Idle timeout in minutes for public IP')
param publicIpIdleTimeoutInMinutes int = 10

@description('Optional. Domain label for fqdn of application gateway')
param domainNameLabel string = ''

@description('Optional. Whether http and or https ports are enabled for frontend ip configuration ')
param appGatewayFrontendPorts string = 'httpAndHttps'

@description('Optional. SSL certificates of the application gateway resource')
param sslCertificates array = []

@allowed([
  'Custom'
  'Predefined'
])
@description('Optional. Type of SSL policy, predefined or custom')
param sslPolicyType string = 'Predefined'

@allowed([
  'AppGwSslPolicy20150501'
  'AppGwSslPolicy20170401'
  'AppGwSslPolicy20170401S'
])
@description('Optional. Type of Ssl Policy - Predefined or Custom')
param sslPolicyName string = 'AppGwSslPolicy20170401S'

@description('Optional. Minimum TLS version custom SSL policy')
@allowed([
  'TLSv1_0'
  'TLSv1_1'
  'TLSv1_2'
])
param customSSLMinProtocolVersion string = 'TLSv1_2'

@description('Optional. SSL cipher suites to be enabled in the specified order to application gateway')
param customSSLCipherSuites array = []

@description('Optional. Whether HTTP2 is enabled on the application gateway resource')
param enableHttp2 bool = true

@description('Optional. Reference to the Web Application Firewall policy resource')
param wafPolicyID string = ''

@description('Optional. Associates the application gateway with a firewall policy regardless whether the policy differs from the WAF Config')
param forceFirewallPolicyAssociation bool = true

@description('Optional. Default WAF configuration')
param webApplicationFirewallConfiguration object = {
  enabled: true
  firewallMode: 'Prevention'
  ruleSetType: 'OWASP'
  ruleSetVersion: '3.1'
  disabledRuleGroups: []
}

@description('Required. Properties of load balancer backend address pool')
param backendAddressPools array

@description('Required. Backend http settings of the application gateway resource')
param backendHttpSettingsCollection array

@description('Required. Http listeners of the application gateway resource')
param httpListeners array

@description('Optional. Probes of the application gateway resource')
param probes array = []

@description('Optional. Redirect configurations of the application gateway resource')
param redirectConfigurations array = []

@description('Required. Request routing rules of the application gateway resource')
param requestRoutingRules array

//TODO @description('Optional. Request routing rules of the application gateway resource')
// param urlPathMaps array = []

@description('Optional. Rewrite rules for the application gateway resource')
param rewriteRuleSets array = []

@description('Optional. Array of Role Assignments to deploy')
param permissions array = []

@description('Optional. Microsoft Insights diagnosticSettings configuration')
param diagnosticSettings array = []

var applicationGatewayNamevar = empty(customName) ? toLower('agw-${workloadName}-${applicationName}-${environmentName}-${regionName}-${index}') : customName

var publicIPAddressNamevar = empty(customNamePIP) ? toLower('pip-${workloadName}-${applicationName}-${environmentName}-${regionName}-${padLeft(index, 2, '0')}') : customNamePIP
var domainNameLabelvar = toLower('${applicationGatewayNamevar}-${uniqueString(resourceGroup().id)}')

var appGatewayFrontendPortsHttpName = toLower('${applicationName}${regionName}appgw${environmentName}FrontendHttpPort')
var appGatewayFrontendPortsHttpsName = toLower('${applicationName}${regionName}appgw${environmentName}FrontendHttpsPort')
var appGatewayFrontendPublicIPName = toLower('${applicationName}-${regionName}-appgw-${environmentName}-FrontendPublicIpName')
var appGatewayFrontendPrivateIPName = toLower('${applicationName}-${regionName}-appgw-${environmentName}-FrontendPrivateIpName')
var safeRedirectConfigurations = empty(redirectConfigurations) ? [
  {
    name: 'emptyPlaceholder'
    redirectType: 'found'
    targeturl: 'https://www.kpn.com'
    requestRoutingRules: ''
    includePath: true
    includeQueryString: false
  }
] : redirectConfigurations

var safeProbes = empty(probes) ? [
  {
    name: 'emptyPlaceHolder'
    protocol: 'http'
    path: '/'
    interval: 5
    timeout: 5
    unhealthyThreshold: 2
    pickHostNameFromBackendHttpSettings: true
    minServers: 0
    match: {
      statusCodes: [
        '200-399'
      ]
    }
  }
] : probes

// #TODO var safeUrlPathMaps = empty(urlPathMaps) ? [
//   {
//     name: 'emptyPlaceholder'
//     defaultBackendAddressPool: 'emptyPlaceHolder'
//     defaultBackendHttpSettings: 'emptyPlaceHolder'
//     pathRules: 'emptyPlaceHolder'
//   }
// ] : urlPathMaps

var safeRewriteRuleSets = empty(rewriteRuleSets) ? [
  {
    name: 'emptyPlaceholder'
    rewriteRules: [
      {
        ruleSequence: 100
        conditions: []
        name: 'NewRewrite'
        actionSet: {
          requestHeaderConfigurations: [
            {
              headerName: 'X-Forwarded-For'
              headerValue: '{var_add_x_forwarded_for_proxy}'
            }
          ]
          responseHeaderConfigurations: []
        }
      }
    ]
  }
] : rewriteRuleSets

var safeDiagnosticSettings = empty(diagnosticSettings) ? [
  {
    name: 'workspace1'
    logs: []
    metrics: []
  }
] : diagnosticSettings

var autoScaleConfiguration = {
  minCapacity: capacity
  maxCapacity: autoScaleMaxCapacity
}

var appGatewayV2Sku = endsWith(applicationGatewaySize, 'V2')

var sslPolicy = {
  policyType: sslPolicyType
  policyName: sslPolicyType == 'Predefined' ? sslPolicyName : null
  minProtocolVersion: sslPolicyType == 'Custom' ? customSSLMinProtocolVersion : null
}

var customSslPolicy = {
  policyType: sslPolicyType
  policyName: sslPolicyType == 'Predefined' ? sslPolicyName : null
  minProtocolVersion: sslPolicyType == 'Custom' ? customSSLMinProtocolVersion : null
  cipherSuites: sslPolicyType == 'Custom' ? customSSLCipherSuites : null
}

var frontendPorts = [
  {
    name: appGatewayFrontendPortsHttpName
    properties: {
      Port: 80
    }
  }
  {
    name: appGatewayFrontendPortsHttpsName
    properties: {
      Port: 443
    }
  }
]

var frontendPortsHttpOnly = [
  {
    name: appGatewayFrontendPortsHttpName
    properties: {
      Port: 80
    }
  }
]

var frontendPortsHttpsOnly = [
  {
    name: appGatewayFrontendPortsHttpsName
    properties: {
      Port: 443
    }
  }
]

var frontendIPConfigurationsPublic = [
  {
    name: appGatewayFrontendPublicIPName
    properties: {
      PublicIPAddress: {
        id: pipModule.outputs.resourceID
      }
    }
  }
]

var frontendIPConfigurationsPrivate = [
  {
    name: appGatewayFrontendPrivateIPName
    properties: {
      privateIPAddress: frontEndPrivateIpAddress
      privateIPAllocationMethod: 'static'
      subnet: {
        id: subnetId
      }
    }
  }
]

var frontendIPConfigurationsBoth = [
  {
    name: appGatewayFrontendPublicIPName
    properties: {
      PublicIPAddress: {
        id: pipModule.outputs.resourceID
      }
    }
  }
  {
    name: appGatewayFrontendPrivateIPName
    properties: {
      privateIPAddress: frontEndPrivateIpAddress
      privateIPAllocationMethod: 'static'
      subnet: {
        id: subnetId
      }
    }
  }
]

var backendAddressPoolsvar = [for item in backendAddressPools: {
  name: item.name
  properties: {
    backendAddresses: contains(item, 'backendAddresses') ? item.backendAddresses : null
  }
}]

var redirectConfigurationsvar = [for item in safeRedirectConfigurations: {
  name: item.name
  properties: {
    redirectType: item.redirectType
    targetListener: contains(item, 'targetListener') ? {
      id: resourceId('Microsoft.Network/applicationGateways/httpListeners', applicationGatewayNamevar, item.targetListener)
    } : null
    targetUrl: contains(item, 'targetUrl') ? item.targetUrl : null
    includePath: contains(item, 'includePath') ? item.includePath : null
    includeQueryString: item.includeQueryString
    requestRoutingRules: contains(item, 'requestRoutingRules') ? [
      {
        id: resourceId('Microsoft.Network/applicationGateways/requestRoutingRules', applicationGatewayNamevar, item.requestRoutingRules)
      }
    ] : null
    pathRules: contains(item, 'pathRules') ? item.pathRules : null
  }
}]

var httpSettings = [for item in backendHttpSettingsCollection: {
  name: item.name
  properties: {
    port: item.port
    protocol: item.protocol
    cookieBasedAffinity: item.cookieBasedAffinity
    pickHostNameFromBackendAddress: item.pickHostNameFromBackendAddress
    connectionDraining: item.connectionDrainingEnabled == 'enabled' ? {
      drainTimeoutInSec: item.drainTimeoutInSec
      enabled: item.connectionDrainingEnabled
    } : null
    requestTimeout: item.requestTimeout
    path: contains(item, 'overridePath') ? item.overridePath : null
    probeEnabled: item.probeEnabled
  }
}]

var httpSettingsWithHostname = [for item in backendHttpSettingsCollection: {
  name: item.name
  properties: {
    port: item.port
    protocol: item.protocol
    cookieBasedAffinity: item.cookieBasedAffinity
    hostName: item.pickHostNameFromBackendAddress == 'false' && contains(item, 'overrideHostName') ? item.overrideHostName : null
    pickHostNameFromBackendAddress: item.pickHostNameFromBackendAddress
    connectionDraining: item.connectionDrainingEnabled == 'enabled' ? {
      drainTimeoutInSec: item.drainTimeoutInSec
      enabled: item.connectionDrainingEnabled
    } : null
    requestTimeout: item.requestTimeout
    path: contains(item, 'overridePath') ? item.overridePath : null
    probeEnabled: item.probeEnabled
  }
}]

module pipModule '../PublicIP/template.bicep' = {
  name: publicIPAddressNamevar
  params: {
    applicationName: applicationName
    environmentName: environmentName
    workloadName: workloadName
    regionName: regionName
    index: index
    customName: customNamePIP
    tags: tags
    zones: zones
    location: location
    publicIPSku: publicIPAllocation == 'Static' ? 'Standard' : 'Basic'
    publicIPAllocationMethod: publicIPAllocation
    publicIPDomainNameLabel: empty(domainNameLabel) ? domainNameLabelvar : domainNameLabel
    publicIPIdleTimeoutInMinutes: publicIpIdleTimeoutInMinutes
  }
}

resource diagSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = [for item in safeDiagnosticSettings: if (!empty(diagnosticSettings)) {
  name: item.name
  scope: appGateway
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

resource appGateway 'Microsoft.Network/applicationGateways@2022-01-01' = {
  name: applicationGatewayNamevar
  tags: tags
  location: location
  zones: zones
  identity: enableManagedIdentity ? {
    type: 'SystemAssigned'
  } : null
  properties: {
    firewallPolicy: !empty(wafPolicyID) ? {
      id: wafPolicyID
    } : null
    forceFirewallPolicyAssociation: forceFirewallPolicyAssociation
    webApplicationFirewallConfiguration: webApplicationFirewallConfiguration
    enableHttp2: enableHttp2
    sslPolicy: sslPolicyType == 'Predefined' ? sslPolicy : customSslPolicy
    sku: {
      name: applicationGatewaySize
      tier: applicationGatewayTier
      capacity: enableAppGatewayV2AutoScaling ? null : capacity
    }
    autoscaleConfiguration: enableAppGatewayV2AutoScaling ? autoScaleConfiguration : null
    gatewayIPConfigurations: [
      {
        name: 'appGatewayIpConfig'
        properties: {
          subnet: {
            id: subnetId
          }
        }
      }
    ]
    sslCertificates: empty(sslCertificates) ? null : sslCertificates
    frontendIPConfigurations: frontEndType == 'private' && appGatewayV2Sku ? frontendIPConfigurationsBoth : frontEndType == 'private' ? frontendIPConfigurationsPrivate : frontendIPConfigurationsPublic
    frontendPorts: appGatewayFrontendPorts == 'httpsOnly' ? frontendPortsHttpsOnly : appGatewayFrontendPorts == 'httpOnly' ? frontendPortsHttpOnly : frontendPorts
    backendAddressPools: backendAddressPoolsvar
    backendHttpSettingsCollection: [for (item, i) in backendHttpSettingsCollection: contains(item, 'overrideHostName') ? httpSettingsWithHostname[i] : httpSettings[i]]
    httpListeners: [for item in httpListeners: {
      name: item.name
      properties: {
        frontendIPConfiguration: {
          id: contains(item, 'frontEndType') ? item.frontEndType : frontEndType == 'public' ? resourceId('Microsoft.Network/applicationGateways/frontendIPConfigurations', applicationGatewayNamevar, appGatewayFrontendPublicIPName) : resourceId('Microsoft.Network/applicationGateways/frontendIPConfigurations', applicationGatewayNamevar, appGatewayFrontendPrivateIPName)
        }
        frontendPort: {
          id: item.protocol == 'http' ? resourceId('Microsoft.Network/applicationGateways/frontendPorts', applicationGatewayNamevar, appGatewayFrontendPortsHttpName) : resourceId('Microsoft.Network/applicationGateways/frontendPorts', applicationGatewayNamevar, appGatewayFrontendPortsHttpsName)
        }
        protocol: item.protocol
        hostName: contains(item, 'hostName') ? item.hostname : null
        sslCertificate: item.protocol == 'http' ? null : {
          id: resourceId('Microsoft.Network/applicationGateways/sslCertificates', applicationGatewayNamevar, item.sslCertificateName)
        }
        requireServerNameIndication: item.protocol == 'http' ? null : item.requireServerNameIndication
      }
    }]
    probes: [for item in safeProbes: {
      name: item.name
      properties: {
        protocol: item.protocol
        host: item.pickHostNameFromBackendHttpSettings == false ? item.host : null
        path: item.path
        interval: item.interval
        timeout: item.timeout
        unhealthyThreshold: item.unhealthyThreshold
        pickHostNameFromBackendHttpSettings: item.pickHostNameFromBackendHttpSettings
        minServers: item.minServers
        match: item.match
      }
    }]
    requestRoutingRules: [for item in requestRoutingRules: {
      name: item.name
      properties: {
        ruleType: item.ruleType
        priority: item.priority
        httpListener: contains(item, 'httpListener') ? {
          id: resourceId('Microsoft.Network/applicationGateways/httpListeners', applicationGatewayNamevar, item.httpListener)
        } : null
        redirectConfiguration: contains(item, 'redirectConfiguration') ? {
          id: resourceId('Microsoft.Network/applicationGateways/redirectConfigurations', applicationGatewayNamevar, item.name)
        } : null
        backendAddressPool: contains(item, 'backendAddressPool') ? {
          id: resourceId('Microsoft.Network/applicationGateways/backendAddressPools', applicationGatewayNamevar, item.backendAddressPool)
        } : null
        backendHttpSettings: contains(item, 'backendHttpSettings') ? {
          id: resourceId('Microsoft.Network/applicationGateways/backendHttpSettingsCollection', applicationGatewayNamevar, item.backendHttpSettings)
        } : null
        rewriteRuleSet: contains(item, 'rewriteRuleSet') ? {
          id: resourceId('Microsoft.Network/applicationGateways/rewriteRuleSets', applicationGatewayNamevar, item.rewriteRuleSet)
        } : null
        urlPathMap: contains(item, 'urlPathMap') ? {
          id: resourceId('Microsoft.Network/applicationGateways/urlPathMaps', applicationGatewayNamevar, item.urlPathMap)
        } : null
      }
    }]
    urlPathMaps: []
    // TODO urlPathMaps: [for item in safeUrlPathMaps: {
    //   name: item.name
    //   properties: {
    //     defaultBackendAddressPool: {
    //       id: resourceId('Microsoft.Network/applicationGateways/backendAddressPools', applicationGatewayNamevar, item.defaultBackendAddressPool)
    //     }
    //     defaultBackendHttpSettings: {
    //       id: resourceId('Microsoft.Network/applicationGateways/backendHttpSettingsCollection', applicationGatewayNamevar, item.defaultBackendHttpSettings)
    //     }
    //     pathRules: item.pathRules
    //   }
    // }]
    redirectConfigurations: empty(redirectConfigurations) ? null : redirectConfigurationsvar
    rewriteRuleSets: [for item in safeRewriteRuleSets: {
      name: item.name
      properties: {
        rewriteRules: item.rewriteRules
      }
    }]
  }
}

resource roleAssignments 'Microsoft.Authorization/roleAssignments@2022-01-01-preview' = [for item in permissions: {
  name: guid(resourceGroup().id, item.name, item.roleDefinitionId)
  scope: appGateway
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
output resourceName string = appGateway.name
@description('The resource-id of the Azure resource')
output resourceID string = appGateway.id
