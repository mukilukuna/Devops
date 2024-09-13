@description('Required. Resource ID of the local virtual network')
param localVirtualNetworkID string

@description('Required. Resource ID of the remote virtual network')
param remoteVirtualNetworkID string

@description('Required. Allow access from remote network to local network')
param allowVirtualNetworkAccess bool

@description('Required. Allow access from forwarded traffic')
param allowForwardedTraffic bool

@description('Required. Allow the remote network to use the gateway on this network')
param allowGatewayTransit bool

@description('Required. Use the gateway from the remote network')
param useRemoteGateways bool

@description('Optional. Custom name of the resource')
param customName string = ''

var name = toLower('peer-${last(split(localVirtualNetworkID, '/'))}-to-${last(split(remoteVirtualNetworkID, '/'))}')

resource vnet 'Microsoft.Network/virtualNetworks@2021-05-01' existing = {
  name: last(split(localVirtualNetworkID, '/'))

  resource peering 'virtualNetworkPeerings@2020-05-01' = {
    name: empty(customName) ? name : customName
    properties: {
      allowVirtualNetworkAccess: allowVirtualNetworkAccess
      allowForwardedTraffic: allowForwardedTraffic
      allowGatewayTransit: allowGatewayTransit
      useRemoteGateways: useRemoteGateways
      remoteVirtualNetwork: {
        id: remoteVirtualNetworkID
      }
    }
  }
}

@description('The name of the Azure resource')
output resourceName string = vnet::peering.name
@description('The resource ID of the Azure resource')
output resourceID string = vnet::peering.id
