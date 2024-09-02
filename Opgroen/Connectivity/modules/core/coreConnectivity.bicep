targetScope = 'resourceGroup'

@description('Optional. Time parameter to create unique deployment. Do not set in parameter file!')
param time string = replace(utcNow(), ':', '-')

@description('JSON configuration object for bicep deployments')
var subscriptionConfig = loadJsonContent('../../configs/subscriptionConfig.jsonc')
var namingConvention = subscriptionConfig.namingConvention
var tags = subscriptionConfig.Governance.tags
var networkingSettings = subscriptionConfig.networking

@description('Location of the resource group')
var location = subscriptionConfig.Governance.location

module resourceGroupConnectivityLock '../../../Templates/Features/ResourceGroupLock/template.bicep' = {
  name: 'resourceGroupConnectivityLock-${time}'
  params: {
    level: 'CanNotDelete'
  }
}

module peeringUserAssignedIdentity '../../../Templates/Features/UserAssignedIdentity/template.bicep' = {
  name: 'peeringUserAssignedIdentity-${time}'
  params: {
    workloadName: namingConvention.workloadName
    applicationName: 'peering'
    environmentName: namingConvention.environmentName
    regionName: namingConvention.regionName
    index: 1
    location: location
    tags: tags
  }
}

module peeringUserAssignedIdentityRoleAssignment '../../../Templates/Features/RoleAssignmentRG/template.bicep' = {
  name: 'peeringUserAssignedIdentityRoleAssignment-${time}'
  params: {
    permissions: subscriptionConfig.networking.permissions
  }
}

module VirtualNetwork '../../../Templates/Features/VirtualNetwork/template.bicep' = {
  name: 'VirtualNetwork-${time}'
  params: {
    workloadName: namingConvention.workloadName
    applicationName: namingConvention.applicationName
    environmentName: namingConvention.environmentName
    regionName: namingConvention.regionName
    index: 1
    location: location
    tags: tags
    vNetPrefix: [
      '${networkingSettings.addressSpacePrefix}.0/23'
    ]
    vNetDnsServers: networkingSettings.vNetDnsServers
    subnets: [ {
        name: 'GatewaySubnet'
        properties: {
          addressPrefix: '${networkingSettings.addressSpacePrefix}.0/27'
          routeTable: {
            id: '*<connWeu-routeTableGateway_ResourceId>*'
          }
          privateEndpointNetworkPolicies: 'Enabled'
          privateLinkServiceNetworkPolicies: 'Enabled'
        }
      }
      {
        name: 'AzureFirewallSubnet'
        properties: {
          addressPrefix: '${networkingSettings.addressSpacePrefix}.64/26'
          delegations: []
          privateEndpointNetworkPolicies: 'Enabled'
          privateLinkServiceNetworkPolicies: 'Enabled'
        }
      } ]
  }
}

module AzureFirewallPolicyFoundation '../../../Templates/Features/AzureFirewallPolicy/template.bicep' = {
  name: 'AzureFirewallPolicyPlatform-${time}'
  params: {
    workloadName: namingConvention.workloadName
    applicationName: 'foundation'
    environmentName: namingConvention.environmentName
    regionName: namingConvention.regionName
    location: location
    index: 1
    sku: 'Standard'
    threatIntelMode: 'Deny'
    dnsSettings: {
      servers: networkingSettings.firewallDnsServers
      enableProxy: true
    }
    basePolicyResourceId: ''
    policyAnalyticsEnabled: true
    policyAnalyticsdefaultWorkspaceId: '*<mgmtWeu-LogAnalytics_ResourceId>*'
    policyAnalyticsWorkspaces: [
      {
        region: '*<location>*'
        workspaceId: {
          id: '*<mgmtWeu-LogAnalytics_ResourceId>*'
        }
      }
    ]
    tags: tags
  }
}

module AzureFirewallPolicyLandingZones '../../../Templates/Features/AzureFirewallPolicy/template.bicep' = {
  name: 'AzureFirewallPolicyLandingZones-${time}'
  dependsOn: [
    AzureFirewallPolicyFoundation
    VirtualNetwork
  ]
  params: {
    workloadName: namingConvention.workloadName
    applicationName: 'landingzones'
    environmentName: namingConvention.environmentName
    regionName: namingConvention.regionName
    location: location
    index: 1
    sku: 'Standard'
    threatIntelMode: 'Deny'
    dnsSettings: {
      servers: networkingSettings.firewallDnsServers
      enableProxy: true
    }
    basePolicyResourceId: AzureFirewallPolicyFoundation.outputs.resourceID
    policyAnalyticsEnabled: true
    policyAnalyticsdefaultWorkspaceId: '*<mgmtWeu-LogAnalytics_ResourceId>*'
    policyAnalyticsWorkspaces: [
      {
        region: '*<location>*'
        workspaceId: {
          id: '*<mgmtWeu-LogAnalytics_ResourceId>*'
        }
      }
    ]
    tags: tags
  }
}

module AzureFirewall '../../../Templates/Features/AzureFirewall/template.bicep' = {
  name: 'AzureFirewall-${time}'
  dependsOn: [
    AzureFirewallPolicyLandingZones
    AzureFirewallPolicyFoundation
  ]
  params: {
    workloadName: namingConvention.workloadName
    applicationName: namingConvention.applicationName
    environmentName: namingConvention.environmentName
    regionName: namingConvention.regionName
    location: location
    index: 1
    availabilityZones: [
      1
      2
      3
    ]
    numberOfPublicIPAddresses: 1
    virtualNetworkId: VirtualNetwork.outputs.resourceID
    firewallSkuName: 'AZFW_VNet'
    firewallSkuTier: 'Standard'
    firewallPolicyResourceId: AzureFirewallPolicyLandingZones.outputs.resourceID
    tags: tags
  }
}

module ExpressRouteGateway '../../../Templates/Features/ExpressRouteGateway/template.bicep' = if (networkingSettings.deployExpressRouteGateway == 'yes') {
  name: 'ExpressRouteGateway-${time}'
  dependsOn: [
    VirtualNetwork
  ]
  params: {
    workloadName: namingConvention.workloadName
    applicationName: namingConvention.applicationName
    environmentName: namingConvention.environmentName
    regionName: namingConvention.regionName
    location: location
    index: 1
    vNetId: VirtualNetwork.outputs.resourceID
    gatewaySku: 'ErGw1AZ'
    tags: tags
  }
}

module VirtualNetworkGateway '../../../Templates/Features/VirtualNetworkGateway/template.bicep' = if (networkingSettings.deployVPNGateway == 'yes') {
  name: 'VirtualNetworkGateway-${time}'
  dependsOn: [
    VirtualNetwork
  ]
  params: {
    workloadName: namingConvention.workloadName
    applicationName: namingConvention.applicationName
    environmentName: namingConvention.environmentName
    regionName: namingConvention.regionName
    location: location
    index: 1
    gatewaySku: 'VpnGw1AZ'
    vpnGatewayGeneration: 'Generation1'
    activeActive: false
    enableBgp: true
    vpnType: 'RouteBased'
    asn: 65515
    peerWeight: 0
    customBgpIpAddresses: []
    vNetId: VirtualNetwork.outputs.resourceID
    enablePrivateIpAddress: false
    tags: tags
  }
}

@description('ID of the peeringUserAssignedIdentity')
output peeringUserAssignedIdentity_PrincipalId string = peeringUserAssignedIdentity.outputs.userAssignedIdentityPrincipalId

output virtualNetwork_ResourceId string = VirtualNetwork.outputs.resourceID
output virtualNetwork_ResourceName string = VirtualNetwork.outputs.resourceName

output virtualNetworkGateway_ResourceId string = networkingSettings.deployVPNGateway == 'yes' ? VirtualNetworkGateway.outputs.resourceID : ''
output virtualNetworkGateway_ResourceName string = networkingSettings.deployVPNGateway == 'yes' ? VirtualNetworkGateway.outputs.resourceName : ''

output expressRouteGateway_ResourceId string = networkingSettings.deployExpressRouteGateway == 'yes' ? ExpressRouteGateway.outputs.resourceID : ''
output expressRouteGateway_ResourceName string = networkingSettings.deployExpressRouteGateway == 'yes' ? ExpressRouteGateway.outputs.resourceName : ''

output azureFirewall_ResourceId string = AzureFirewall.outputs.resourceID
output azureFirewall_ResourceName string = AzureFirewall.outputs.resourceName
output azureFirewall_PrivateIp string = AzureFirewall.outputs.privateIPFirewall

output azureFirewallPolicyFoundation_ResourceName string = AzureFirewallPolicyFoundation.outputs.resourceName
output azureFirewallPolicyFoundation_ResourceId string = AzureFirewallPolicyFoundation.outputs.resourceID
output azureFirewallPolicyLandingZones_ResourceName string = AzureFirewallPolicyLandingZones.outputs.resourceName
output azureFirewallPolicyLandingZones_ResourceId string = AzureFirewallPolicyLandingZones.outputs.resourceID
