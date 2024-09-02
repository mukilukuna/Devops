targetScope = 'resourceGroup'

@description('Optional. Time parameter to create unique deployment. Do not set in parameter file!')
param time string = replace(utcNow(), ':', '-')

@description('JSON configuration object for bicep deployments')
var subscriptionConfig = loadJsonContent('../../configs/subscriptionConfig.jsonc')
var namingConvention = subscriptionConfig.namingConvention
var tags = subscriptionConfig.Governance.tags
var networkingSettings = subscriptionConfig.networking

@description('JSON configuration objects for networkSecurityGroup bicep deployments')
var nsgNpmConfig = loadJsonContent('../../configs/networkSecurityGroups/networkSecurityGroup.npmSubnet.json')
var nsgAciConfig = loadJsonContent('../../configs/networkSecurityGroups/networkSecurityGroup.aciSubnet.json')
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

module networkSecurityGroupNpm '../../../Templates/Features/NetworkSecurityGroup/template.bicep' = {
  name: 'networkSecurityGroupNpm-${time}'
  params: {
    workloadName: namingConvention.workloadName
    applicationName: 'npmsubnet'
    environmentName: namingConvention.environmentName
    regionName: namingConvention.regionName
    index: 1
    securityRules: nsgNpmConfig.securityRules
    location: location
  }
}

module networkSecurityGroupAcisubnet '../../../Templates/Features/NetworkSecurityGroup/template.bicep' = {
  name: 'networkSecurityGroupAcisubnet-${time}'
  params: {
    workloadName: namingConvention.workloadName
    applicationName: 'acisubnet'
    environmentName: namingConvention.environmentName
    regionName: namingConvention.regionName
    index: 1
    securityRules: nsgAciConfig.securityRules
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
    subnets: [
      {
        name: 'NpmSubnet'
        properties: {
          addressPrefix: '${networkingSettings.addressSpacePrefix}.0/29'
          networkSecurityGroup: {
            id: networkSecurityGroupNpm.outputs.resourceID
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
        name: 'AciSubnet'
        properties: {
          addressPrefix: '${networkingSettings.addressSpacePrefix}.16/28'
          networkSecurityGroup: {
            id: networkSecurityGroupAcisubnet.outputs.resourceID
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
        name: 'DeploymentScriptSubnet'
        properties: {
          addressPrefix: '${networkingSettings.addressSpacePrefix}.32/28'
          networkSecurityGroup: {
            id: networkSecurityGroupPE.outputs.resourceID
          }
          routeTable: {
            id: routeTable.outputs.resourceID
          }
          serviceEndpoints: [
            {
              service: 'Microsoft.Storage'
            }
          ]
          delegations: [
            {
              name: 'Microsoft.ContainerInstance.containerGroups'
              properties: {
                serviceName: 'Microsoft.ContainerInstance/containerGroups'
              }
            }
          ]
          privateEndpointNetworkPolicies: 'Disabled'
          privateLinkServiceNetworkPolicies: 'Disabled'
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

@description('ID of the resource')
output virtualNetwork_ResourceId string = virtualNetwork.outputs.resourceID
@description('Name of the resource')
output virtualNetwork_ResourceName string = virtualNetwork.outputs.resourceName
