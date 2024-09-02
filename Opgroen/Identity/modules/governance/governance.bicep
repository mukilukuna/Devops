targetScope = 'subscription'

@description('Optional. Time parameter to create unique deployment. Do not set in parameter file!')
param time string = replace(utcNow(), ':', '-')

var subscriptionConfig = loadJsonContent('../../configs/subscriptionConfig.jsonc')
var goveranceSettings = subscriptionConfig.Governance
var foundationLogAnalyticsResourceId = subscriptionConfig.Foundation.foundationLogAnalyticsResourceId
var subscriptionDiagnosticsConfig = loadJsonContent('../../configs/subscriptionDiagnostics.json')
var tags = subscriptionConfig.Governance.tags

module subscriptionTag '../../../Templates/Features/SubscriptionTag/template.bicep' = {
  name: 'SubscriptionTag-${time}'
  params: {
    tags: tags
  }
}

module subscriptionDiagnostics '../../../Templates/Features/SubscriptionDiagnostics/template.bicep' = {
  name: 'SubscriptionDiagnostics-${time}'
  params: {
    logAnalyticsResourceId: subscriptionDiagnosticsConfig.logAnalyticsResourceId
    logs: subscriptionDiagnosticsConfig.logs
  }
}

module securityCenter '../../../Templates/Features/SecurityCenter/template.bicep' = if (goveranceSettings.enableDefenderForCloud) {
  name: 'DefenderForCloud-${time}'
  params: {
    pricingTierVMs: 'Standard'
    pricingTierSqlServers: 'Standard'
    pricingTierAppServices: 'Standard'
    pricingTierStorageAccounts: 'Standard'
    pricingTierSqlServerVirtualMachines: 'Standard'
    pricingTierContainers: 'Standard'
    pricingTierKeyVaults: 'Standard'
    pricingTierOpenSourceRelationalDatabases: 'Standard'
    pricingTierARM: 'Standard'
    pricingTierDNS: 'Standard'
    pricingTierCloudPosture: 'Free'
  }
}

module defenderForCloudSettings '../../../Templates/Features/DefenderForCloudSettings/template.bicep' = if (goveranceSettings.enableDefenderForCloud) {
  name: 'DefenderForCloudSettings-${time}'
  dependsOn: [
    securityCenter
  ]
  params: {
    logAnalyticsResourceID: foundationLogAnalyticsResourceId
    azureSecurityCenterAutoprovisioning: 'Off'
    email: goveranceSettings.securityEmail
  }
}

module roleAssignmentSub '../../../Templates/Features/RoleAssignmentSub/template.bicep' = {
  scope: subscription(subscriptionConfig.Governance.subscriptionId)
  name: 'RoleAssignmentSub-${time}'
  params: {
    permissions: subscriptionConfig.permissions
  }
}
