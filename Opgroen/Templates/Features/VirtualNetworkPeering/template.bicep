@description('Required. Resource ID of the first virtual network')
param virtualNetworkID1 string

@description('Required. Whether the VMs in the local virtual network space would be able to access the VMs in remote virtual network space')
param allowVirtualNetworkAccess1 bool

@description('Required. Whether the forwarded traffic from the VMs in the local virtual network will be allowed/disallowed in remote virtual network')
param allowForwardedTraffic1 bool

@description('Required. If gateway links can be used in remote virtual networking to link to this virtual network')
param allowGatewayTransit1 bool

@description('Required. If remote gateways can be used on this virtual network. If the flag is set to true, and allowGatewayTransit on remote peering is also true, virtual network will use gateways of remote virtual network for transit. Only one peering can have this flag set to true. This flag cannot be set if virtual network already has a gateway')
param useRemoteGateways1 bool

@description('Optional. Custom name of the resource')
param customName1 string = ''

@description('Required. Resource ID of the second virtual network')
param virtualNetworkID2 string

@description('Required. Whether the VMs in the local virtual network space would be able to access the VMs in remote virtual network space')
param allowVirtualNetworkAccess2 bool

@description('Required. Whether the forwarded traffic from the VMs in the local virtual network will be allowed/disallowed in remote virtual network')
param allowForwardedTraffic2 bool

@description('Required. If gateway links can be used in remote virtual networking to link to this virtual network')
param allowGatewayTransit2 bool

@description('Required. If remote gateways can be used on this virtual network. If the flag is set to true, and allowGatewayTransit on remote peering is also true, virtual network will use gateways of remote virtual network for transit. Only one peering can have this flag set to true. This flag cannot be set if virtual network already has a gateway')
param useRemoteGateways2 bool

@description('Optional. Custom name of the resource')
param customName2 string = ''

module VirtualNetworkPeering1 '../VnetPeering/template.bicep' = {
  name: 'VirtualNetworkPeering1'
  scope: resourceGroup(split(virtualNetworkID1, '/')[2], split(virtualNetworkID1, '/')[4])
  params: {
    localVirtualNetworkID: virtualNetworkID1
    remoteVirtualNetworkID: virtualNetworkID2
    allowForwardedTraffic: allowForwardedTraffic1
    allowGatewayTransit: allowGatewayTransit1
    allowVirtualNetworkAccess: allowVirtualNetworkAccess1
    useRemoteGateways: useRemoteGateways1
    customName: !empty(customName1) ? customName1 : ''
  }
}

module VirtualNetworkPeering2 '../VnetPeering/template.bicep' = {
  name: 'VirtualNetworkPeering2'
  scope: resourceGroup(split(virtualNetworkID2, '/')[2], split(virtualNetworkID2, '/')[4])
  params: {
    localVirtualNetworkID: virtualNetworkID2
    remoteVirtualNetworkID: virtualNetworkID1
    allowForwardedTraffic: allowForwardedTraffic2
    allowGatewayTransit: allowGatewayTransit2
    allowVirtualNetworkAccess: allowVirtualNetworkAccess2
    useRemoteGateways: useRemoteGateways2
    customName: !empty(customName2) ? customName2 : ''
  }
}

@description('The name of the Azure resource')
output resourceName string = VirtualNetworkPeering1.outputs.resourceName

@description('The ID of the Azure resource')
output resourceID string = VirtualNetworkPeering1.outputs.resourceID

@description('The name of the Azure resource')
output resourceName2 string = VirtualNetworkPeering2.outputs.resourceName

@description('The ID of the Azure resource')
output resourceID2 string = VirtualNetworkPeering2.outputs.resourceID
