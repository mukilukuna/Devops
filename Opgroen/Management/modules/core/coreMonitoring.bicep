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

module updateManagementUserAssignedIdentity '../../../Templates/Features/UserAssignedIdentity/template.bicep' = {
  name: 'deploy-aum-identity-${time}'
  params: {
    workloadName: namingConvention.workloadName
    applicationName: 'aum'
    environmentName: namingConvention.environmentName
    regionName: namingConvention.regionName
    index: 1
    location: location
    tags: tags
  }
}

module azureMonitoringAgentUserAssignedIdentity '../../../Templates/Features/UserAssignedIdentity/template.bicep' = {
  name: 'deploy-ama-identity-${time}'
  params: {
    workloadName: namingConvention.workloadName
    applicationName: 'ama'
    environmentName: namingConvention.environmentName
    regionName: namingConvention.regionName
    index: 1
    location: location
    tags: tags
  }
}

module automationAccount '../../../Templates/Features/AutomationAccount/template.bicep' = {
  name: 'automationAccount-${time}'
  params: {
    workloadName: namingConvention.workloadName
    applicationName: 'loganalytics'
    environmentName: namingConvention.environmentName
    regionName: namingConvention.regionName
    location: location
    tags: tags
    index: 1
    assignManagedIdentity: true
    userAssignedIdentities: {
      '${updateManagementUserAssignedIdentity.outputs.resourceID}': {}
    }
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

module logAnalytics '../../../Templates/Features/LogAnalytics/template.bicep' = {
  name: 'logAnalytics-${time}'
  params: {
    workloadName: namingConvention.workloadName
    applicationName: namingConvention.applicationName
    environmentName: namingConvention.environmentName
    regionName: namingConvention.regionName
    index: 1
    location: location
    tags: tags
    linkAutomationAccountResourceId: automationAccount.outputs.resourceID
    publicNetworkAccessForIngestion: 'Enabled'
    publicNetworkAccessForQuery: 'Enabled'
    retentionInDays: 30
    solutionTypes: [
      'AgentHealthAssessment'
      'AzureActivity'
      'KeyVaultAnalytics'
      'ChangeTracking'
      'DnsAnalytics'
      'NetworkMonitoring'
      'Security'
      'ServiceMap'
      'SQLVulnerabilityAssessment'
      'SQLAdvancedThreatProtection'
      'VMInsights'
    ]
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
    subnetId: '*<mgmtWeu-virtualNetwork_ResourceId>*/subnets/PrivateEndpointSubnet'
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

module loggingStorageAccount '../../../Templates/Features/StorageAccount/template.bicep' = {
  name: 'loggingStorageAccount-${time}'
  params: {
    workloadName: namingConvention.workloadName
    applicationName: 'log'
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

module loggingStorageAccount_PE '../../../Templates/Features/PrivateLink/template.bicep' = {
  name: 'loggingStorageAccount_PE-${time}'
  params: {
    subnetId: '*<mgmtWeu-virtualNetwork_ResourceId>*/subnets/PrivateEndpointSubnet'
    privateLinkServiceId: loggingStorageAccount.outputs.resourceID
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

module deploymentScriptStorageAccount '../../../Templates/Features/StorageAccount/template.bicep' = {
  name: 'deploymentScriptStorageAccount-${time}'
  params: {
    workloadName: namingConvention.workloadName
    applicationName: 'scrpt'
    environmentName: namingConvention.environmentName
    regionName: namingConvention.regionName
    location: location
    tags: tags
    skuName: 'Standard_LRS'
    accessTier: 'Hot'
    publicNetworkAccess: 'Enabled'
    defaultAction: 'Deny'
    bypass: 'Logging, Metrics, AzureServices'
    ipRules: []
    virtualNetworkRules: [
      {
        id: '*<mgmtWeu-virtualNetwork_ResourceId>*/subnets/DeploymentScriptSubnet'
        action: 'Allow'
      }
    ]
  }
}

resource storageFileDataPrivilegedContributor 'Microsoft.Authorization/roleDefinitions@2022-04-01' existing = {
  name: '69566ab7-960f-475b-8e7c-b3118f30c6bd' // Storage File Data Privileged Contributor
  scope: tenant()
}

resource roleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(
    storageFileDataPrivilegedContributor.id,
    resourceGroup().id,
    'id-${namingConvention.workloadName}-aum-${namingConvention.environmentName}-${namingConvention.regionName}-01'
  )
  properties: {
    principalId: updateManagementUserAssignedIdentity.outputs.userAssignedIdentityPrincipalId
    roleDefinitionId: storageFileDataPrivilegedContributor.id
    principalType: 'ServicePrincipal'
  }
}

module dcr '../../../Templates/Features/DataCollectionRule/template.bicep' = {
  name: 'default-DCR-${time}'
  params: {
    dcrName: toLower('dcr-${namingConvention.workloadName}-${namingConvention.applicationName}-${namingConvention.environmentName}-${namingConvention.regionName}-${padLeft(1, 2, '0')}')
    logAnalyticsWorkspaceResourceId: logAnalytics.outputs.resourceID
    location: location
  }
}

@description('ID of the resource')
output diagStorageAccount_ResourceId string = diagStorageAccount.outputs.resourceID
@description('Name of the resource')
output diagStorageAccount_ResourceName string = diagStorageAccount.outputs.resourceName

@description('ID of the resource')
output loggingStorageAccount_ResourceId string = loggingStorageAccount.outputs.resourceID
@description('Name of the resource')
output loggingStorageAccount_ResourceName string = loggingStorageAccount.outputs.resourceName

output deploymentScriptStorageAccount_ResourceId string = deploymentScriptStorageAccount.outputs.resourceID
output deploymentScriptStorageAccount_ResourceName string = deploymentScriptStorageAccount.outputs.resourceName
output updateManagementUserAssignedIdentity_ResourceId string = updateManagementUserAssignedIdentity.outputs.resourceID
output updateManagementUserAssignedIdentity_PrincipalId string = updateManagementUserAssignedIdentity.outputs.userAssignedIdentityPrincipalId
output updateManagementUserAssignedIdentity_ClientId string = updateManagementUserAssignedIdentity.outputs.userAssignedIdentityClientId
output updateManagementUserAssignedIdentity_ResourceName string = updateManagementUserAssignedIdentity.outputs.resourceName

output logAnalytics_ResourceName string = logAnalytics.outputs.resourceName
output logAnalytics_ResourceId string = logAnalytics.outputs.resourceID
output logAnalytics_WorkspaceId string = logAnalytics.outputs.workspaceId

output automationAccountLA_ResourceName string = automationAccount.outputs.resourceName
output automationAccountLA_ResourceId string = automationAccount.outputs.resourceID

output dataCollectionRule_ResourceName string = dcr.outputs.resourceName
output dataCollectionRule_ResourceId string = dcr.outputs.resourceId

output azureMonitoringAgentUserAssignedIdentity_ResourceId string = azureMonitoringAgentUserAssignedIdentity.outputs.resourceID
output azureMonitoringAgentUserAssignedIdentity_PrincipalId string = azureMonitoringAgentUserAssignedIdentity.outputs.userAssignedIdentityPrincipalId
output azureMonitoringAgentUserAssignedIdentity_ClientId string = azureMonitoringAgentUserAssignedIdentity.outputs.userAssignedIdentityClientId
output azureMonitoringAgentUserAssignedIdentity_ResourceName string = azureMonitoringAgentUserAssignedIdentity.outputs.resourceName
output azureMonitoringAgentUserAssignedIdentity_ResourceGroupName string = resourceGroup().name
output azureMonitoringAgentUserAssignedIdentity_SubscriptionId string = subscription().subscriptionId
