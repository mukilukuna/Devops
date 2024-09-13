targetScope = 'subscription'

param environmentName string
param regionName string
param workloadName string

@description('Optional. time parameter to create unique deployment. Do not set in parameter file!')
param time string = replace(utcNow(), ':', '-')

param location string = deployment().location

var tags = loadJsonContent('../configs/tags.json', 'tags')
var identityConfig = loadJsonContent('../configs/identityPrerequisites.json')

module identityPrivateLinkZonesResourceGroup '../../../Templates/Features/ResourceGroup/template.bicep' = {
  scope: subscription(identityConfig.subscriptionId)
  name: 'privatelinkzones-rg-${time}'
  params: {
    applicationName: identityConfig.privatelinkzonesResourceGroupApplicationName
    environmentName: environmentName
    index: 1
    regionName: regionName
    workloadName: workloadName
    location: location
    tags: tags
  }
}

output privateLinkZonesRg_ResourceId string = identityPrivateLinkZonesResourceGroup.outputs.resourceID
output privateLinkZonesRg_ResourceName string = identityPrivateLinkZonesResourceGroup.outputs.resourceName
