targetScope = 'resourceGroup'

@description('Optional. Time parameter to create unique deployment. Do not set in parameter file!')
param time string = replace(utcNow(), ':', '-')

@description('JSON configuration object for bicep deployments')
var subscriptionConfig = loadJsonContent('../../configs/subscriptionConfig.jsonc')
var namingConvention = subscriptionConfig.namingConvention
var tags = subscriptionConfig.Governance.tags

var keyVaultAccessPolicies = loadJsonContent('../../configs/keyVaultAccessPolicies/coreKeyVault.json')

@description('Location of the resource group')
var location = subscriptionConfig.Governance.location

module resourceGroupConnectivityLock '../../../Templates/Features/ResourceGroupLock/template.bicep' = {
  name: 'resourceGroupConnectivityLock-${time}'
  params: {
    level: 'CanNotDelete'
  }
}

module keyVault '../../../Templates/Features/KeyVault/template.bicep' = {
  name: 'KeyVault-${time}'
  params: {
    workloadName: namingConvention.workloadName
    applicationName: 'mgmt'
    environmentName: namingConvention.environmentName
    regionName: namingConvention.regionName
    location: location
    publicNetworkAccess: 'Enabled'
    defaultAction: 'Deny'
    virtualNetworkRules: []
    bypass: 'AzureServices'
    ipRules: []
    enablePurgeProtection: true
    enableSoftDelete: true
    enableVaultForDeployment: true
    enableVaultForDiskEncryption: true
    enableVaultForTemplateDeployment: true
    accessPolicies: keyVaultAccessPolicies.accessPolicies
  }
}

module keyvault_PE '../../../Templates/Features/PrivateLink/template.bicep' = {
  name: 'keyvault_PE-${time}'
  params: {
    subnetId: '*<mgmtWeu-virtualNetwork_ResourceId>*/subnets/PrivateEndpointSubnet'
    privateLinkServiceId: keyVault.outputs.resourceID
    groupIds: [
      'vault'
    ]
    index: 1
    customName: ''
    requestMessage: ''
    tags: tags
    location: location
  }
}

@description('ID of the resource')
output keyvault_ResourceId string = keyVault.outputs.resourceID
@description('Name of the resource')
output keyvault_ResourceName string = keyVault.outputs.resourceName
