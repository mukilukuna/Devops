@description('Optional. Custom name of the resource.')
param customName string = ''

@description('Required. Resource ID of the virtual network.')
param virtualNetworkResourceId string

@description('Required. Resource ID of the Virtual Wan Hub.')
param vWANHubId string

@description('Optional. Allow transit from Hub to remote virtual network.')
param allowHubToRemoteVnetTransit bool = true

@description('Optional. Allow use of Hub virtual network gateway.')
param allowRemoteVnetToUseHubVnetGateways bool = true

@description('Optional. ResourceId of the Virtual Wan.')
param enableInternetSecurity bool = false

@description('Optional. VWAN Hub Route Table associated with this connection.')
param associatedRouteTable string = ''

@description('Optional. The list of RouteTables to advertise the routes to.')
param propagatedRouteTables object = {}

@description('Optional. List of static routes that control routing from VirtualHub into a virtual network connection.')
param staticRoutes array = []

var vWANHubResourceInfo = {
  subscription: split(vWANHubId, '/')[1]
  resourceGroup: split(vWANHubId, '/')[3]
  resourceName: last(split(vWANHubId, '/'))
}
var virtualNetworkName = last(split(virtualNetworkResourceId, '/'))
var nameVar = empty(customName) ? toLower('peer-${vWANHubResourceInfo.resourceName}-to-${virtualNetworkName}') : customName

resource vWanHub 'Microsoft.Network/virtualHubs@2021-05-01' existing = {
  name: vWANHubResourceInfo.resourceName

  resource defaultRouteTableRes 'hubRouteTables' existing = {
    name: 'defaultRouteTable'
  }

  resource noneRouteTableRes 'hubRouteTables' existing = {
    name: 'noneRouteTable'
  }
}

resource vNetConnection 'Microsoft.Network/virtualHubs/hubVirtualNetworkConnections@2021-05-01' = {
  name: nameVar
  parent: vWanHub
  properties: {
    remoteVirtualNetwork: {
      id: virtualNetworkResourceId
    }
    allowHubToRemoteVnetTransit: allowHubToRemoteVnetTransit
    allowRemoteVnetToUseHubVnetGateways: allowRemoteVnetToUseHubVnetGateways
    enableInternetSecurity: enableInternetSecurity
    routingConfiguration: {
      associatedRouteTable: {
        id: !empty(associatedRouteTable) ? associatedRouteTable : vWanHub::defaultRouteTableRes.id
      }
      propagatedRouteTables: {
        ids: contains(propagatedRouteTables, 'ids') && !empty(propagatedRouteTables.ids) ? propagatedRouteTables.ids : [
          {
            id: vWanHub::noneRouteTableRes.id
          }
        ]
        labels: contains(propagatedRouteTables, 'labels') && !empty(propagatedRouteTables.labels) ? propagatedRouteTables.labels : []
      }
      vnetRoutes: {
        staticRoutes: staticRoutes
      }
    }
  }
}

@description('The name of the Azure resource')
output resourceName string = vNetConnection.name
@description('The resource-id of the Azure resource')
output resourceID string = vNetConnection.id
