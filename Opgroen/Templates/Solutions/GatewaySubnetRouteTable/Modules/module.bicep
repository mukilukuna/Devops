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

@description('Optional. Object containing the tags to apply to all resources.')
param tags object = {}

@description('Optional. Location of the resource')
param disableBgp bool = false

@description('Required. Internal IP Address of the firewall')
param nextHopIpAddress string

@description('Required. Array of virtual network peerings from virtual network resource')
param virtualNetworkPeerings array

@description('Optional. Additional custom routes that need to be added to the route table')
param routes array = []

@description('Optional. Location of the resource')
param location string = resourceGroup().location

var peeringRoutes = [for (peering, i) in virtualNetworkPeerings: {
  name: 'rt${i}-onpremise-to-${!empty(peering) ? last(split(peering.RemoteVirtualNetwork.id, '/')) : 'no-rt'}'
  properties: {
    nextHopType: 'VirtualAppliance'
    addressPrefix: !empty(peering) ? peering.RemoteVirtualNetworkAddressSpace.AddressPrefixes[0] : '0.0.0.0/0' // Requires a CIDR
    nextHopIpAddress: nextHopIpAddress
  }
}]

resource GatewaySubnetRouteTable 'Microsoft.Network/routeTables@2021-08-01' = {
  name: empty(customName) ? toLower('rt-${workloadName}-${applicationName}-${environmentName}-${regionName}-${padLeft(index, 2, '0')}') : customName
  location: location
  tags: tags
  properties: {
    disableBgpRoutePropagation: disableBgp
    routes: !empty(virtualNetworkPeerings) ? union(peeringRoutes, routes) : routes
  }
}

@description('ID of the resource')
output resourceID string = GatewaySubnetRouteTable.id

@description('Name of the resource')
output resourceName string = GatewaySubnetRouteTable.name
