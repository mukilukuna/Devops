targetScope = 'resourceGroup'

@description('Optional. Time parameter to create unique deployment. Do not set in parameter file!')
param time string = replace(utcNow(), ':', '-')

@description('JSON configuration object for bicep deployments')
var subscriptionConfig = loadJsonContent('../../configs/subscriptionConfig.jsonc')
var tags = subscriptionConfig.Governance.tags

@description('Location of the resource group')
var location = 'global'

module privateDnsZones '../../../Templates/Features/PrivateLinkDnsZones/template.bicep' = {
  name: 'privatelinkdnszone-${time}'
  params: {
    virtualNetworkResourceId: '*<idenWeu-virtualNetwork_ResourceId>*'
    azureRegionCodes: [
      'we'
    ]
    azureRegionNames: [
      'westeurope'
    ]
    deployAzureMonitorZones: false
    customPrivateLinkDnsZones: []
    location: location
    tags: tags
  }
}

//module privateDnsZonesHub '../../../Templates/Features/PrivateLinkDnsZones/template.bicep' = {
//  name: 'privateDnsZonesHub-${time}'
//  params: {
//    virtualNetworkResourceId: '*<connWeu-virtualNetwork_ResourceId>*'
//    azureRegionCodes: [
//      'we'
//    ]
//    azureRegionNames: [
//      'westeurope'
//    ]
//    deployAzureMonitorZones: false
//    customPrivateLinkDnsZones: []
//    location: location
//    tags: tags
//  }
//}
