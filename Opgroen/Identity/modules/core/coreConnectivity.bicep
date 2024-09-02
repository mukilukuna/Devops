targetScope = 'resourceGroup'

@description('Optional. Time parameter to create unique deployment. Do not set in parameter file!')
param time string = replace(utcNow(), ':', '-')

@description('JSON configuration object for bicep deployments')
var subscriptionConfig = loadJsonContent('../../configs/subscriptionConfig.jsonc')
var namingConvention = subscriptionConfig.namingConvention
var tags = subscriptionConfig.Governance.tags
var networkingSettings = subscriptionConfig.networking

@description('JSON configuration objects for networkSecurityGroup bicep deployments')
var nsgIdentityConfig = loadJsonContent('../../configs/networkSecurityGroups/networkSecurityGroup.identitySubnet.jsonc')
var nsgAadConnectConfig = loadJsonContent('../../configs/networkSecurityGroups/networkSecurityGroup.aadConnectSubnet.jsonc')
var nsgOutboundDNSResolverEndpoints = loadJsonContent('../../configs/networkSecurityGroups/networkSecurityGroup.OutboundDNSResolverEndpointSubnet.json')
var nsgInboundDNSResolverEndpoints = loadJsonContent('../../configs/networkSecurityGroups/networkSecurityGroup.InboundDNSResolverEndpointSubnet.json')
var nsgBastion = loadJsonContent('../../configs/networkSecurityGroups/networkSecurityGroup.bastionSubnet.json')
var nsgPrivateEndpointParams = loadJsonContent('../../configs/networkSecurityGroups/networkSecurityGroup.privateEndpointSubnet.json')

@description('Location of the resource group')
var location = subscriptionConfig.Governance.location

module resourceGroupConnectivityLock '../../../Templates/Features/ResourceGroupLock/template.bicep' = {
  name: 'resourceGroupConnectivityLock-${time}'
  params: {
    level: 'CanNotDelete'
  }
}

module routeTable '../../../Templates/Features/RouteTable/template.bicep' = {
  name: 'routeTable-${time}'
  params: {
    workloadName: namingConvention.workloadName
    applicationName: 'defaultroutetable'
    environmentName: namingConvention.environmentName
    regionName: namingConvention.regionName
    index: 1
    disableBgp: true
    routes: networkingSettings.defaultRoutes
    location: location
    tags: tags
  }
}

module networkSecurityGroupIdentity '../../../Templates/Features/NetworkSecurityGroup/template.bicep' = {
  name: 'networkSecurityGroupIdentity-${time}'
  params: {
    workloadName: namingConvention.workloadName
    applicationName: 'identitysubnet'
    environmentName: namingConvention.environmentName
    regionName: namingConvention.regionName
    index: 1
    securityRules: nsgIdentityConfig.securityRules
    location: location
  }
}

module networkSecurityGroupAadconnectsubnet '../../../Templates/Features/NetworkSecurityGroup/template.bicep' = {
  name: 'networkSecurityGroupAadconnectsubnet-${time}'
  params: {
    workloadName: namingConvention.workloadName
    applicationName: 'aadconnectsubnet'
    environmentName: namingConvention.environmentName
    regionName: namingConvention.regionName
    index: 1
    securityRules: nsgAadConnectConfig.securityRules
    location: location
  }
}

module networkSecurityGroupInboundDnsResolver '../../../Templates/Features/NetworkSecurityGroup/template.bicep' = {
  name: 'networkSecurityGroupInboundDnsResolver-${time}'
  params: {
    workloadName: namingConvention.workloadName
    applicationName: 'inbounddnsresolverendpoints'
    environmentName: namingConvention.environmentName
    regionName: namingConvention.regionName
    index: 1
    securityRules: nsgInboundDNSResolverEndpoints.securityRules
    location: location
  }
}

module networkSecurityGroupOutboundDNSResolver '../../../Templates/Features/NetworkSecurityGroup/template.bicep' = {
  name: 'networkSecurityGroupOutboundDNSResolver-${time}'
  params: {
    workloadName: namingConvention.workloadName
    applicationName: 'outbounddnsresolverendpoints'
    environmentName: namingConvention.environmentName
    regionName: namingConvention.regionName
    index: 1
    securityRules: nsgOutboundDNSResolverEndpoints.securityRules
    location: location
  }
}

module networkSecurityGroupBastion '../../../Templates/Features/NetworkSecurityGroup/template.bicep' = {
  name: 'networkSecurityGroupBastion-${time}'
  params: {
    workloadName: namingConvention.workloadName
    applicationName: 'azurebastionsubnet'
    environmentName: namingConvention.environmentName
    regionName: namingConvention.regionName
    index: 1
    securityRules: nsgBastion.securityRules
    location: location
  }
}

module networkSecurityGroupPE '../../../Templates/Features/NetworkSecurityGroup/template.bicep' = {
  name: 'NetworkSecurityGroupPE-${time}'
  params: {
    workloadName: namingConvention.workloadName
    applicationName: 'privateendpointsubnet'
    environmentName: namingConvention.environmentName
    regionName: namingConvention.regionName
    index: 1
    securityRules: nsgPrivateEndpointParams.securityRules
    location: location
  }
}

module virtualNetwork '../../../Templates/Features/VirtualNetwork/template.bicep' = {
  name: 'virtualNetwork-${time}'
  params: {
    workloadName: namingConvention.workloadName
    applicationName: namingConvention.applicationName
    environmentName: namingConvention.environmentName
    regionName: namingConvention.regionName
    index: 1
    location: location
    tags: tags
    vNetPrefix: [
      '${networkingSettings.addressSpacePrefix}.0/24'
    ]
    vNetDnsServers: networkingSettings.vNetDnsServers
    subnets: [ {
        name: 'IdentitySubnet'
        properties: {
          addressPrefix: '${networkingSettings.addressSpacePrefix}.0/28'
          networkSecurityGroup: {
            id: networkSecurityGroupIdentity.outputs.resourceID
          }
          routeTable: {
            id: routeTable.outputs.resourceID
          }
          delegations: []
          privateEndpointNetworkPolicies: 'Enabled'
          privateLinkServiceNetworkPolicies: 'Enabled'
        }
      }
      {
        name: 'AadConnectSubnet'
        properties: {
          addressPrefix: '${networkingSettings.addressSpacePrefix}.16/28'
          networkSecurityGroup: {
            id: networkSecurityGroupAadconnectsubnet.outputs.resourceID
          }
          routeTable: {
            id: routeTable.outputs.resourceID
          }
          delegations: []
          privateEndpointNetworkPolicies: 'Enabled'
          privateLinkServiceNetworkPolicies: 'Enabled'
        }
      }
      {
        name: 'InboundDNSResolverEndpoints'
        properties: {
          addressPrefix: '${networkingSettings.addressSpacePrefix}.32/28'
          networkSecurityGroup: {
            id: networkSecurityGroupInboundDnsResolver.outputs.resourceID
          }
          routeTable: {
            id: routeTable.outputs.resourceID
          }
          delegations: [
            {
              name: 'Microsoft.Network.dnsResolvers'
              properties: {
                serviceName: 'Microsoft.Network/dnsResolvers'
              }
            }
          ]
          privateEndpointNetworkPolicies: 'Enabled'
          privateLinkServiceNetworkPolicies: 'Enabled'
        }
      }
      {
        name: 'OutboundDNSResolverEndpoints'
        properties: {
          addressPrefix: '${networkingSettings.addressSpacePrefix}.48/28'
          networkSecurityGroup: {
            id: networkSecurityGroupOutboundDNSResolver.outputs.resourceID
          }
          routeTable: {
            id: routeTable.outputs.resourceID
          }
          delegations: [
            {
              name: 'Microsoft.Network.dnsResolvers'
              properties: {
                serviceName: 'Microsoft.Network/dnsResolvers'
              }
            }
          ]
          privateEndpointNetworkPolicies: 'Enabled'
          privateLinkServiceNetworkPolicies: 'Enabled'
        }
      }
      {
        name: 'AzureBastionSubnet'
        properties: {
          addressPrefix: '${networkingSettings.addressSpacePrefix}.64/26'
          networkSecurityGroup: {
            id: networkSecurityGroupBastion.outputs.resourceID
          }
          delegations: []
          privateEndpointNetworkPolicies: 'Enabled'
          privateLinkServiceNetworkPolicies: 'Enabled'
        }
      }
      {
        name: 'PrivateEndpointSubnet'
        properties: {
          addressPrefix: '${networkingSettings.addressSpacePrefix}.128/26'
          networkSecurityGroup: {
            id: networkSecurityGroupPE.outputs.resourceID
          }
          routeTable: {
            id: routeTable.outputs.resourceID
          }
          delegations: []
          privateEndpointNetworkPolicies: 'Disabled'
          privateLinkServiceNetworkPolicies: 'Disabled'
        }
      }
    ]
  }
}

module VirtualNetworkPeering '../../../Templates/Features/VirtualNetworkPeering/template.bicep' = {
  name: 'VirtualNetworkPeering-${time}'
  params: {
    virtualNetworkID1: virtualNetwork.outputs.resourceID
    allowVirtualNetworkAccess1: true
    allowForwardedTraffic1: true
    allowGatewayTransit1: false
    useRemoteGateways1: true
    virtualNetworkID2: '*<connWeu-virtualNetwork_ResourceId>*'
    allowVirtualNetworkAccess2: true
    allowForwardedTraffic2: true
    allowGatewayTransit2: true
    useRemoteGateways2: false
  }
}

module DnsResolver '../../../Templates/Features/DnsResolver/template.bicep' = if (networkingSettings.deployDnsResolver == 'yes') {
  name: 'DnsResolver-${time}'
  params: {
    workloadName: namingConvention.workloadName
    applicationName: namingConvention.applicationName
    environmentName: namingConvention.environmentName
    regionName: namingConvention.regionName
    index: 1
    location: location
    tags: tags
    inboundEndpointsName: 'DefaultInboundDnsEndpoint'
    inboundEndpointSubnetName: 'InboundDNSResolverEndpoints'
    outboundEndpointName: 'DefaultOutboundDnsEndpoint'
    outboundEndpointSubnetName: 'OutboundDNSResolverEndpoints'
    vNetId: virtualNetwork.outputs.resourceID
  }
}

module dnsForwardingRulesets '../../../Templates/Features/DnsForwardingRulesets/template.bicep' = if (networkingSettings.deployDnsResolver == 'yes') {
  name: 'dnsForwardingRulesets-${time}'
  params: {
    workloadName: namingConvention.workloadName
    applicationName: namingConvention.applicationName
    environmentName: namingConvention.environmentName
    regionName: namingConvention.regionName
    index: 1
    location: location
    tags: tags
    vNetId: networkingSettings.deployDnsResolver == 'yes' ? virtualNetwork.outputs.resourceID : ''
    forwardingRules: [
      {
        ruleName: 'cia-local'
        domainName: 'cia.local.'
        targetDnsServers: [
          {
            ipAddress: '172.21.2.250'
            port: 53
          }
          {
            ipAddress: '172.21.2.251'
            port: 53
          }
        ]
        forwardingRuleState: 'Enabled'
      }
    ]
    outboundEndpointResourceId: networkingSettings.deployDnsResolver == 'yes' ? DnsResolver.outputs.outboundEndpointsID : ''
  }
}

@description('ID of the resource')
output virtualNetwork_ResourceId string = virtualNetwork.outputs.resourceID
@description('Name of the resource')
output virtualNetwork_ResourceName string = virtualNetwork.outputs.resourceName
