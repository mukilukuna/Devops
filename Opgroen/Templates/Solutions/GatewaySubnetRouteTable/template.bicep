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

@description('Optional. Time parameter to create unique deployment. Do not set in parameter file!')
param time string = replace(utcNow(), ':', '-')

@description('Optional. Location of the resource')
param location string = resourceGroup().location

@description('Optional. Additional custom routes that need to be added to the route table')
param routes array = []

var virtualNetwork = loadJsonContent('Scripts/VirtualNetworkPeerings.json')

module GatewaySubnetRouteTable 'Modules/module.bicep' = {
  name: 'GatewaySubnetRouteTable-${time}'
  params: {
    nextHopIpAddress: nextHopIpAddress
    virtualNetworkPeerings: virtualNetwork
    location: location
    applicationName: applicationName
    workloadName: workloadName
    environmentName: environmentName
    index: index
    regionName: regionName
    customName: customName
    disableBgp: disableBgp
    tags: tags
    routes: routes
  }
}

@description('ID of the resource')
output resourceID string = GatewaySubnetRouteTable.outputs.resourceID

@description('Name of the resource')
output resourceName string = GatewaySubnetRouteTable.outputs.resourceName
