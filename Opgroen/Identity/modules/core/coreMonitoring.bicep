targetScope = 'resourceGroup'

@description('Optional. Time parameter to create unique deployment. Do not set in parameter file!')
param time string = replace(utcNow(), ':', '-')

@description('JSON configuration object for bicep deployments')
var subscriptionConfig = loadJsonContent('../../configs/subscriptionConfig.jsonc')
var namingConvention = subscriptionConfig.namingConvention
var tags = subscriptionConfig.Governance.tags

@description('Location of the resource group')
var location = subscriptionConfig.Governance.location

module resourceGroupConnectivityLock '../../../Templates/Features/ResourceGroupLock/template.bicep' = {
  name: 'resourceGroupConnectivityLock-${time}'
  params: {
    level: 'CanNotDelete'
  }
}

module diagStorageAccount '../../../Templates/Features/StorageAccount/template.bicep' = {
  name: 'diagStorageAccount-${time}'
  params: {
    workloadName: namingConvention.workloadName
    applicationName: 'diag'
    environmentName: namingConvention.environmentName
    regionName: namingConvention.regionName
    location: location
    tags: tags
    skuName: 'Standard_GRS'
    accessTier: 'Hot'
    publicNetworkAccess: 'Disabled'
    defaultAction: 'Deny'
    bypass: 'Logging, Metrics, AzureServices'
    ipRules: []
    virtualNetworkRules: []
  }
}

module diagStorageAccount_PE '../../../Templates/Features/PrivateLink/template.bicep' = {
  name: 'diagStorageAccount_PE-${time}'
  params: {
    subnetId: '*<idenWeu-virtualNetwork_ResourceId>*/subnets/PrivateEndpointSubnet'
    privateLinkServiceId: diagStorageAccount.outputs.resourceID
    groupIds: [
      'Blob'
    ]
    index: 1
    customName: ''
    requestMessage: ''
    tags: tags
    location: location
  }
}

@description('ID of the resource')
output diagStorageAccount_ResourceId string = diagStorageAccount.outputs.resourceID
@description('Name of the resource')
output diagStorageAccount_ResourceName string = diagStorageAccount.outputs.resourceName
