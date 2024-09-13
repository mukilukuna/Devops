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

module automationAccount '../../../Templates/Features/AutomationAccount/template.bicep' = {
  name: 'automationAccount-${time}'
  params: {
    workloadName: namingConvention.workloadName
    applicationName: namingConvention.applicationName
    environmentName: namingConvention.environmentName
    regionName: namingConvention.regionName
    location: location
    tags: tags
    index: 1
    assignManagedIdentity: true
    publicNetworkAccess: true
    sku: 'Free'
  }
}

module automationAccountWebhook_PE '../../../Templates/Features/PrivateLink/template.bicep' = {
  name: 'automationAccountWebhook_PE-${time}'
  params: {
    subnetId: '*<mgmtWeu-virtualNetwork_ResourceId>*/subnets/PrivateEndpointSubnet'
    privateLinkServiceId: automationAccount.outputs.resourceID
    groupIds: [
      'Webhook'
    ]
    index: 1
    customName: ''
    requestMessage: ''
    tags: tags
    location: location
  }
}

module automationAccountDSCAndHybridWorker_PE '../../../Templates/Features/PrivateLink/template.bicep' = {
  name: 'automationAccountDSCAndHybridWorker_PE-${time}'
  params: {
    subnetId: '*<mgmtWeu-virtualNetwork_ResourceId>*/subnets/PrivateEndpointSubnet'
    privateLinkServiceId: automationAccount.outputs.resourceID
    groupIds: [
      'DSCAndHybridWorker'
    ]
    index: 2
    customName: ''
    requestMessage: ''
    tags: tags
    location: location
  }
}

@description('ID of the resource')
output automationAccount_ResourceId string = automationAccount.outputs.resourceID
@description('Name of the resource')
output automationAccount_ResourceName string = automationAccount.outputs.resourceName
