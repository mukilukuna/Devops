@description('Required. The application name of the resource.')
param applicationName string

@description('Required. The environment letter of the resource.')
@maxLength(1)
param environmentName string

@description('Required. The workload name of the resource.')
param workloadName string

@description('Required. The region of the resource.')
@maxLength(4)
param regionName string

@description('Required. The index of the resource.')
param index int

@description('Optional. Custom name of the resource.')
param customName string = ''

@description('Required. Address of the subnet.')
param addressPrefix string

@description('Optional. An array of service endpoints.')
param serviceEndpoints array = []

@description('Optional. ID of the network security group.')
param networkSecurityGroupId string = ''

@description('Optional. ID of the route table.')
param routeTableId string = ''

@description('Optional. ID of the virtual network.')
param virtualNetworkId string = ''

@description('Optional. Enable/Disable private endpoint network policies.')
@allowed([
  'Enabled'
  'Disabled'
])
param privateEndpointNetworkPolicies string = 'Disabled'

@description('Optional. Enable/Disable private link network policies.')
@allowed([
  'Enabled'
  'Disabled'
])
param privateLinkServiceNetworkPolicies string = 'Disabled'

@description('Optional. Array of delegations.')
param delegations array = []

resource vnet 'Microsoft.Network/virtualNetworks@2021-08-01' existing = {
  name: last(split(virtualNetworkId, '/'))
}

resource subnet 'Microsoft.Network/virtualNetworks/subnets@2021-08-01' = {
  parent: vnet
  name: empty(customName) ? toLower('sub-${workloadName}-${applicationName}-${environmentName}-${regionName}-${padLeft(index, 2, '0')}') : customName
  properties: {
    addressPrefix: addressPrefix
    serviceEndpoints: serviceEndpoints
    networkSecurityGroup: !empty(networkSecurityGroupId) ? {
      id: networkSecurityGroupId
    } : null
    routeTable: !empty(routeTableId) ? {
      id: routeTableId
    } : null
    privateEndpointNetworkPolicies: privateEndpointNetworkPolicies
    privateLinkServiceNetworkPolicies: privateLinkServiceNetworkPolicies
    delegations: delegations
  }
}

@description('The name of the Azure resource')
output resourceName string = subnet.name
@description('The resource-id of the Azure resource')
output resourceID string = subnet.id
