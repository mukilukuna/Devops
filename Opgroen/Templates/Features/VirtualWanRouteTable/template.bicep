@description('Required. Name of the Virtual WAN Hub.')
param vWanHubName string

@description('Required. Name of the route table.')
param routeTableName string

@description('Required. Routing configuration for the Route Table.')
param routes array

@description('Required. List of labels that will be associated with the route table.')
param attachedConnections array

resource vWanHub 'Microsoft.Network/virtualHubs@2021-12-01' existing = {
  name: vWanHubName

  resource vWanHub_routeTable 'routeTables@2021-12-01' = {
    name: routeTableName
    properties: {
      routes: routes
      attachedConnections: attachedConnections
    }
  }
}

@description('The name of the Azure resource')
output resourceName string = vWanHub::vWanHub_routeTable.name
@description('The resource-id of the Azure resource')
output resourceID string = vWanHub::vWanHub_routeTable.id
