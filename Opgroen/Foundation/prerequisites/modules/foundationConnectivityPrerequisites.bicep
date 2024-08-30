targetScope = 'subscription'

param environmentName string
param regionName string
param workloadName string

@description('Optional. time parameter to create unique deployment. Do not set in parameter file!')
param time string = replace(utcNow(), ':', '-')

param location string = deployment().location

var tags = loadJsonContent('../configs/tags.json', 'tags')
var connectivityConfig = loadJsonContent('../configs/connectivityPrerequisites.json')

module connectivityResourceGroup '../../../Templates/Features/ResourceGroup/template.bicep' = {
  scope: subscription(connectivityConfig.subscriptionId)
  name: 'security-rg-${time}'
  params: {
    applicationName: connectivityConfig.connectivityResourceGroupApplicationName
    environmentName: environmentName
    index: 1
    regionName: regionName
    workloadName: workloadName
    location: location
    tags: tags
  }
}

module userAssignedPeeringIdentity '../../../Templates/Features/UserAssignedIdentity/template.bicep' = {
  dependsOn: [
    connectivityResourceGroup
  ]
  scope: resourceGroup(connectivityConfig.subscriptionId, 'rg-${workloadName}-${connectivityConfig.connectivityResourceGroupApplicationName}-${environmentName}-${regionName}-01')
  name: 'deploy-connectivity-${time}'
  params: {
    index: 1
    workloadName: workloadName
    environmentName: environmentName
    regionName: regionName
    applicationName: connectivityConfig.peeringIdentity.applicationName
    location: location
    tags: tags
  }
}

output peeringUserAssignedIdentity_ResourceId string = userAssignedPeeringIdentity.outputs.resourceID
output peeringUserAssignedIdentity_ResoureName string = userAssignedPeeringIdentity.outputs.resourceName
output peeringUserAssignedIdentity_PrincipalId string = userAssignedPeeringIdentity.outputs.userAssignedIdentityPrincipalId
