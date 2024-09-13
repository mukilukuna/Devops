targetScope = 'subscription'

param environmentName string
param regionName string
param workloadName string

@description('Optional. time parameter to create unique deployment. Do not set in parameter file!')
param time string = replace(utcNow(), ':', '-')

param location string = deployment().location

var tags = loadJsonContent('../configs/tags.json', 'tags')
var managementConfig = loadJsonContent('../configs/managementPrerequisites.json')

module managementSecurityResourceGroup '../../../Templates/Features/ResourceGroup/template.bicep' = {
  scope: subscription(managementConfig.subscriptionId)
  name: 'security-rg-${time}'
  params: {
    applicationName: managementConfig.securityResourceGroupApplicationName
    environmentName: environmentName
    index: 1
    regionName: regionName
    workloadName: workloadName
    location: location
    tags: tags
  }
}

module managementMonitoringResourceGroup '../../../Templates/Features/ResourceGroup/template.bicep' = {
  scope: subscription(managementConfig.subscriptionId)
  name: 'monitoring-rg-${time}'
  params: {
    applicationName: managementConfig.monitoringResourceGroupApplicationName
    environmentName: environmentName
    index: 1
    regionName: regionName
    workloadName: workloadName
    location: location
    tags: tags
  }
}

module azureMonitoringAgentUserAssignedIdentity '../../../Templates/Features/UserAssignedIdentity/template.bicep' = {
  name: 'deploy-ama-identity-${time}'
  scope: resourceGroup(
    managementConfig.subscriptionId,
    'rg-${workloadName}-${managementConfig.monitoringResourceGroupApplicationName}-${environmentName}-${regionName}-01'
  )
  params: {
    workloadName: workloadName
    applicationName: 'ama'
    environmentName: environmentName
    regionName: regionName
    index: 1
    location: location
    tags: tags
  }
}

module updateManagementUserAssignedIdentity '../../../Templates/Features/UserAssignedIdentity/template.bicep' = {
  name: 'deploy-aum-identity-${time}'
  scope: resourceGroup(
    managementConfig.subscriptionId,
    'rg-${workloadName}-${managementConfig.monitoringResourceGroupApplicationName}-${environmentName}-${regionName}-01'
  )
  params: {
    workloadName: workloadName
    applicationName: 'aum'
    environmentName: environmentName
    regionName: regionName
    index: 1
    location: location
    tags: tags
  }
}

module automationAccount '../../../Templates/Features/AutomationAccount/template.bicep' = {
  dependsOn: [
    managementMonitoringResourceGroup
  ]
  scope: resourceGroup(
    managementConfig.subscriptionId,
    'rg-${workloadName}-${managementConfig.monitoringResourceGroupApplicationName}-${environmentName}-${regionName}-01'
  )
  name: 'deploy-automation-${time}'
  params: {
    index: 1
    workloadName: workloadName
    environmentName: environmentName
    regionName: regionName
    applicationName: managementConfig.automationAccount.applicationName
    location: location
    publicNetworkAccess: managementConfig.automationAccount.publicNetworkAccess
    userAssignedIdentities: {
      '${updateManagementUserAssignedIdentity.outputs.resourceID}': {}
    }
    tags: tags
  }
}

module law '../../../Templates/Features/LogAnalytics/template.bicep' = {
  dependsOn: [
    managementMonitoringResourceGroup
  ]
  scope: resourceGroup(
    managementConfig.subscriptionId,
    'rg-${workloadName}-${managementConfig.monitoringResourceGroupApplicationName}-${environmentName}-${regionName}-01'
  )
  name: 'deploy-law-${time}'
  params: {
    index: 1
    workloadName: workloadName
    environmentName: environmentName
    regionName: regionName
    solutionTypes: managementConfig.logAnalyticsWorkspace.solutionTypes
    applicationName: managementConfig.logAnalyticsWorkspace.applicationName
    location: location
    linkAutomationAccountResourceId: automationAccount.outputs.resourceID
    tags: tags
  }
}

module keyvault '../../../Templates/Features/KeyVault/template.bicep' = {
  dependsOn: [
    managementSecurityResourceGroup
  ]
  scope: resourceGroup(
    managementConfig.subscriptionId,
    'rg-${workloadName}-${managementConfig.securityResourceGroupApplicationName}-${environmentName}-${regionName}-01'
  )
  name: 'kev-deploy-${time}'
  params: {
    workloadName: workloadName
    environmentName: environmentName
    regionName: regionName
    applicationName: managementConfig.keyVault.applicationName
    defaultAction: managementConfig.keyVault.defaultAction
    publicNetworkAccess: managementConfig.keyVault.publicNetworkAccess
    accessPolicies: managementConfig.keyVault.accessPolicies
    ipRules: managementConfig.keyVault.ipRules
    bypass: managementConfig.keyVault.bypass
    enableVaultForDeployment: managementConfig.keyVault.enableVaultForDeployment
    enablePurgeProtection: managementConfig.keyVault.enablePurgeProtection
    enableSoftDelete: managementConfig.keyVault.enableSoftDelete
    enableVaultForDiskEncryption: managementConfig.keyVault.enableVaultForDiskEncryption
    enableVaultForTemplateDeployment: managementConfig.keyVault.enableVaultForTemplateDeployment
    virtualNetworkRules: managementConfig.keyVault.virtualNetworkRules
    skuName: managementConfig.keyVault.skuName
    location: location
    tags: tags
  }
}

module storageAccount '../../../Templates/Features/StorageAccount/template.bicep' = {
  dependsOn: [
    managementMonitoringResourceGroup
  ]
  scope: resourceGroup(
    managementConfig.subscriptionId,
    'rg-${workloadName}-${managementConfig.monitoringResourceGroupApplicationName}-${environmentName}-${regionName}-01'
  )
  name: 'sta-deploy-${time}'
  params: {
    applicationName: managementConfig.storageAccount.applicationName
    environmentName: environmentName
    regionName: regionName
    workloadName: workloadName
    accessTier: managementConfig.storageAccount.accessTier
    skuName: managementConfig.storageAccount.skuName
    location: location
    tags: tags
  }
}

module dcr '../../../Templates/Features/DataCollectionRule/template.bicep' = {
  name: 'default-DCR-${time}'
  scope: resourceGroup(
    managementConfig.subscriptionId,
    'rg-${workloadName}-${managementConfig.monitoringResourceGroupApplicationName}-${environmentName}-${regionName}-01'
  )
  params: {
    dcrName: toLower('dcr-${workloadName}-management-${environmentName}-${regionName}-${padLeft(1, 2, '0')}')
    logAnalyticsWorkspaceResourceId: law.outputs.resourceID
    location: location
  }
}

output logAnalytics_ResourceId string = law.outputs.resourceID
output logAnalytics_WorkspaceId string = law.outputs.workspaceId
output logAnalytics_ResourceName string = law.outputs.resourceName

output keyVault_ResourceId string = keyvault.outputs.resourceID
output keyvault_ResourceName string = keyvault.outputs.resourceName

output loggingStorageAccount_ResourceId string = storageAccount.outputs.resourceID
output loggingStorageAccount_ResourceName string = storageAccount.outputs.resourceName

output dataCollectionRule_ResourceName string = dcr.outputs.resourceName
output dataCollectionRule_ResourceId string = dcr.outputs.resourceId

output azureMonitoringAgentUserAssignedIdentity_ResourceId string = azureMonitoringAgentUserAssignedIdentity.outputs.resourceID
output azureMonitoringAgentUserAssignedIdentity_PrincipalId string = azureMonitoringAgentUserAssignedIdentity.outputs.userAssignedIdentityPrincipalId
output azureMonitoringAgentUserAssignedIdentity_ClientId string = azureMonitoringAgentUserAssignedIdentity.outputs.userAssignedIdentityClientId
output azureMonitoringAgentUserAssignedIdentity_ResourceName string = azureMonitoringAgentUserAssignedIdentity.outputs.resourceName
output azureMonitoringAgentUserAssignedIdentity_ResourceGroupName string = 'rg-${workloadName}-${managementConfig.monitoringResourceGroupApplicationName}-${environmentName}-${regionName}-01'
output azureMonitoringAgentUserAssignedIdentity_SubscriptionId string = subscription().subscriptionId

output updateManagementUserAssignedIdentity_ResourceId string = updateManagementUserAssignedIdentity.outputs.resourceID
output updateManagementUserAssignedIdentity_PrincipalId string = updateManagementUserAssignedIdentity.outputs.userAssignedIdentityPrincipalId
output updateManagementUserAssignedIdentity_ResourceName string = updateManagementUserAssignedIdentity.outputs.resourceName
