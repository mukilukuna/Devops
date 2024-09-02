@description('Required. The name of the application')
param applicationName string

@description('Required. The code of the environment this resource will be used in')
@maxLength(1)
param environmentName string

@description('Required. The name of the workload this resource will be used for')
param workloadName string

@description('Required. Region of the resource')
@maxLength(4)
param regionName string

@description('Required. Index of the resource')
param index int

@description('Optional. The name to use if not using the normal naming convention')
param customName string = ''

@description('Optional. Resource tags')
param tags object = {}

@description('Optional. Sku of the firewall policy')
@allowed([
  'Basic'
  'Standard'
  'Premium'
])
param sku string = 'Standard'

@description('Optional. ResourceId of the parent firewall policy')
param basePolicyResourceId string = ''

@description('Optional. The operation mode for Threat Intel')
@allowed([
  'Alert'
  'Deny'
  'Off'
])
param threatIntelMode string = 'Alert'

@description('Optional. DNS Configuration settings, DNS servers, DNS Proxy')
param dnsSettings object = {}

@description('Optional. IP address whitelist for threat intel')
param threatIntelWhitelistIpAddresses array = []

@description('Optional. FQDN address whitelist for threat intel')
param threatIntelWhitelistFqdns array = []

@description('Optional. Intrusion detection state')
param intrusionDetectionMode string = 'Alert'

@description('Optional. List of specific signatures states')
param intrusionDetectionSignatureOverrides array = []

@description('Optional. List of rules for traffic to bypass')
param intrusionDetectionBypassTrafficSettings array = []

@description('Optional. Name of the CA certificate')
param transportSecurityCAName string = ''

@description('Optional. Secret Id of (base-64 encoded unencrypted pfx) \'Secret\' or \'Certificate\' object stored in KeyVault')
#disable-next-line secure-secrets-in-params // Doesn't contain a secret
param transportSecurityKeyVaultSecretId string = ''

@description('Optional. Name of the User Assigned Identity')
param userAssignedIdentityName string = ''

@description('Optional. A flag to indicate if the insights are enabled on the policy.')
@allowed([
  true
  false
])
param policyAnalyticsEnabled bool = false

@description('Optional. The default workspace Id for Firewall Policy Insights.')
param policyAnalyticsdefaultWorkspaceId string = ''

@description('Optional. List of workspaces for Firewall Policy Insights.')
param policyAnalyticsWorkspaces array = []

@description('Optional. Number of days the insights should be enabled on the policy.')
param policyAnalyticsRetentionDays int = 0

@description('Optional. Location of the resource')
param location string = resourceGroup().location

@description('Optional. Array of Role Assignments to deploy')
param permissions array = []

var nameVar = empty(customName) ? toLower('afwp-${workloadName}-${applicationName}-${environmentName}-${regionName}-${padLeft(index, 2, '0')}') : customName
var intrusionDetection = {
  mode: intrusionDetectionMode
  configuration: {
    signatureOverrides: intrusionDetectionSignatureOverrides
    bypassTrafficSettings: intrusionDetectionBypassTrafficSettings
  }
}
var transportSecurity = {
  certificateAuthority: {
    keyVaultSecretId: transportSecurityKeyVaultSecretId
    name: transportSecurityCAName
  }
}
var identity = {
  type: 'UserAssigned'
  userAssignedIdentities: {
    '${resourceId('Microsoft.ManagedIdentity/userAssignedIdentities/', userAssignedIdentityName)}': {}
  }
}

var insights = {
  isEnabled: policyAnalyticsEnabled
  logAnalyticsResources: {
    defaultWorkspaceId: {
      id: policyAnalyticsdefaultWorkspaceId
    }
    workspaces: policyAnalyticsWorkspaces
  }
  retentionDays: policyAnalyticsRetentionDays
}

resource firewallPolicy 'Microsoft.Network/firewallPolicies@2023-05-01' = {
  name: nameVar
  location: location
  tags: tags
  identity: sku == 'Standard' ? null : empty(userAssignedIdentityName) ? null : identity
  properties: {
    sku: {
      tier: sku
    }
    threatIntelMode: threatIntelMode
    threatIntelWhitelist: {
      fqdns: threatIntelWhitelistFqdns
      ipAddresses: threatIntelWhitelistIpAddresses
    }
    basePolicy: empty(basePolicyResourceId) ? null : {
      id: basePolicyResourceId
    }
    insights: policyAnalyticsEnabled == true ? insights : null
    dnsSettings: dnsSettings
    intrusionDetection: sku == 'Standard' ? null : empty(intrusionDetectionMode) ? null : intrusionDetection
    transportSecurity: sku == 'Standard' ? null : empty(transportSecurityKeyVaultSecretId) ? null : transportSecurity
  }
}

resource roleAssignments 'Microsoft.Authorization/roleAssignments@2022-04-01' = [for item in permissions: {
  name: guid(resourceGroup().id, item.name, item.roleDefinitionId)
  scope: firewallPolicy
  properties: {
    principalId: item.principalId
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', item.roleDefinitionId)
    condition: contains(item, 'condition') && item.condition != '' ? item.condition : null
    conditionVersion: contains(item, 'conditionVersion') && item.conditionVersion != '' ? item.conditionVersion : null
    delegatedManagedIdentityResourceId: contains(item, 'delegatedManagedIdentityResourceId') && item.delegatedManagedIdentityResourceId != '' ? item.delegatedManagedIdentityResourceId : null
    description: item.description
    principalType: item.principalType
  }
}]

@description('The name of the Azure resource')
output resourceName string = firewallPolicy.name
@description('The resource-id of the Azure resource')
output resourceID string = firewallPolicy.id
