@description('Required. The workload name of the resource.')
param workloadName string

@description('Required. The application name of the resource.')
param applicationName string

@description('Required. The environment letter of the resource.')
@maxLength(1)
param environmentName string

@description('Required. The region this resource will be deployed in.')
@maxLength(4)
param regionName string

@description('Required. The index of the resource.')
param index int

@description('Optional. Custom name of the resource.')
param customName string = ''

@description('Required. Name of the VWAN hub.')
param vwanHubName string

@description('Required. The next hop for internet traffic, this can either be the Azure Firewall resource id or a third party Microsoft.Solutions/applications resource id.')
param internetTrafficRoutingPolicyNextHopId string

@description('Required. The next hop for private traffic, this can either be the Azure Firewall resource id or a third party Microsoft.Solutions/applications resource id.')
param privateTrafficRoutingPolicyNextHopId string

var nameVar = empty(customName) ? toLower('vwanintent-${workloadName}-${applicationName}-${environmentName}-${regionName}-${padLeft(index, 2, '0')}') : customName

resource existingVwanHub 'Microsoft.Network/virtualHubs@2022-11-01' existing = {
  name: vwanHubName
}

resource routingIntentInternetTraffic 'Microsoft.Network/virtualHubs/routingIntent@2023-02-01' = {
  name: nameVar
  parent: existingVwanHub
  properties: {
    routingPolicies: [
      {
        name: 'Internet'
        destinations: [
          'Internet'
        ]
        nextHop: internetTrafficRoutingPolicyNextHopId
      }
      {
        name: 'PrivateTraffic'
        destinations: [
          'PrivateTraffic'
        ]
        nextHop: privateTrafficRoutingPolicyNextHopId
      }
    ]
  }
}
