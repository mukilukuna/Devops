@description('Required. Name of the resource.')
param vWanHubName string

@description('Required. Name of the route table.')
param routeTableName string

@description('Required. Routing configuration for the Route Table.')
param routes array

@description('Optional. List of labels that will be associated with the route table.')
param labels array = []

resource vWanHub 'Microsoft.Network/virtualHubs@2021-05-01' existing = {
  name: vWanHubName

  resource vWanHubName_routeTableName 'hubRouteTables@2021-05-01' = {
    name: routeTableName
    properties: {
      routes: routes
      labels: labels
    }
  }
}

@description('The resource-id of the Azure resource')
output resourceID string = vWanHub::vWanHubName_routeTableName.id
@description('The name of the Azure resource')
output resourceName string = vWanHub::vWanHubName_routeTableName.name
