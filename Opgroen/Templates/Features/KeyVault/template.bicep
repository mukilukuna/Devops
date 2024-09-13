@description('Required. The name of the workload this resource will be used for')
@maxLength(5)
param workloadName string

@description('Required. The name of the application')
@maxLength(5)
param applicationName string

@description('Required. The code of the environment this resource will be used in')
@maxLength(1)
param environmentName string

@description('Required. Region of the resource')
@maxLength(4)
param regionName string

@description('Optional. The name to use if not using the normal naming convention')
param customName string = ''

@description('Optional. Resource tags')
param tags object = {}

@description('Optional. SKU name to specify whether the key vault is a standard vault or a premium vault')
@allowed([
  'standard'
  'premium'
])
param skuName string = 'standard'

@description('Optional. Property to specify whether Azure Virtual Machines are permitted to retrieve certificates stored as secrets from the key vault')
param enableVaultForDeployment bool = true

@description('Optional. Property to specify whether Azure Disk Encryption is permitted to retrieve secrets from the vault and unwrap keys')
param enableVaultForDiskEncryption bool = true

@description('Optional. Property to specify whether Azure Resource Manager is permitted to retrieve secrets from the key vault')
param enableVaultForTemplateDeployment bool = true

@description('Optional. Property to specify whether the \'soft delete\' functionality is enabled for this key vault. Once set to true, it cannot be reverted to false')
param enableSoftDelete bool = true

@description('Optional. Property specifying whether protection against purge is enabled for this vault. Setting this property to true activates protection against purge for this vault and its content - only the Key Vault service may initiate a hard, irrecoverable deletion. The setting is effective only if soft delete is also enabled. Enabling this functionality is irreversible - that is, the property does not accept false as its value')
param enablePurgeProtection bool = true

@description('Optional. Specifies the DevOps service principal to grant permissions on the KeyVault')
param azDevOpsServicePrincipal string = ''

@description('Optional. Specifies the Backup service principal to grant permissions on the KeyVault')
param azBackupServicePrincipal string = ''

@description('Optional. Parameter used by task group to pass the existing access policies')
param existingAccessPolicies object = {}

@description('Required. Array of objects that define the access policies within the KeyVault')
param accessPolicies array

@description('Optional. Property to specify whether the vault will accept traffic from public internet. If set to \'disabled\' all traffic except private endpoint traffic and that that originates from trusted services will be blocked. This will override the set firewall rules, meaning that even if the firewall rules are present we will not honor the rules')
param publicNetworkAccess string = 'disabled'

@description('Optional. Specifies whether traffic is bypassed for Logging/Metrics/AzureServices. Possible values are any combination of Logging,Metrics,AzureServices (For example, "Logging, Metrics"), or None to bypass none of those traffics')
param bypass string = 'AzureServices'

@description('Optional. Specifies the default action of allow or deny when no other rules match')
@allowed([
  'Allow'
  'Deny'
])
param defaultAction string = 'Allow'

@description('Optional. Sets the IP ACL rules')
param ipRules array = []

@description('Optional. Sets the virtual network rules.')
param virtualNetworkRules array = []

@description('Optional. Diagnostic settings for the KeyVault')
param diagnosticsSettings array = []

@description('Optional. Location of the resource')
param location string = resourceGroup().location

@description('Optional. Array of Role Assignments to deploy')
param permissions array = []

var nameVar = toLower('kv${workloadName}${applicationName}${environmentName}${regionName}')
var uniqueNameVar = '${nameVar}${substring(uniqueString(resourceGroup().id, nameVar), 7)}'
var devOpsAccessPolicy = [
  {
    objectId: azDevOpsServicePrincipal
    permissions: {
      keys: []
      secrets: [
        'List'
        'Get'
        'Set'
      ]
      certificates: []
    }
  }
]
var backupAccessPolicy = [
  {
    objectId: azBackupServicePrincipal
    permissions: {
      keys: [
        'List'
        'Get'
        'Backup'
      ]
      secrets: [
        'List'
        'Get'
        'Backup'
      ]
      certificates: []
    }
  }
]

#disable-next-line decompiler-cleanup
var accessPolicies_var = union(
  contains(existingAccessPolicies, 'list') ? existingAccessPolicies.list : [],
  accessPolicies,
  empty(azDevOpsServicePrincipal) ? [] : devOpsAccessPolicy,
  empty(azBackupServicePrincipal) ? [] : backupAccessPolicy
)

resource kv 'Microsoft.KeyVault/vaults@2022-07-01' = {
  name: empty(customName) ? uniqueNameVar : customName
  location: location
  tags: tags
  properties: {
    enabledForDeployment: enableVaultForDeployment
    enabledForDiskEncryption: enableVaultForDiskEncryption
    enabledForTemplateDeployment: enableVaultForTemplateDeployment
    enableSoftDelete: enableSoftDelete
    enablePurgeProtection: enablePurgeProtection == true ? enablePurgeProtection : null
    tenantId: subscription().tenantId
    publicNetworkAccess: publicNetworkAccess
    networkAcls: {
      bypass: bypass
      defaultAction: defaultAction
      ipRules: ipRules
      virtualNetworkRules: virtualNetworkRules
    }
    accessPolicies: [
      for item in accessPolicies_var: {
        tenantId: contains(item, 'tenantId') ? item.tenantId : subscription().tenantId
        objectId: item.objectId
        permissions: {
          keys: item.permissions.keys
          secrets: item.permissions.secrets
          certificates: item.permissions.certificates
        }
      }
    ]
    sku: {
      family: 'A'
      name: skuName
    }
  }
}

resource diagnosticSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = [
  for item in diagnosticsSettings: if (!empty(diagnosticsSettings)) {
    name: item.name
    scope: kv
    properties: {
      workspaceId: contains(item, 'workspaceId') && item.workspaceId != '' ? item.workspaceId : null
      storageAccountId: contains(item, 'diagnosticsStorageAccountId') && item.diagnosticsStorageAccountId != ''
        ? item.diagnosticsStorageAccountId
        : null
      logs: contains(item, 'logs') ? item.logs : null
      metrics: contains(item, 'metrics') ? item.metrics : null
    }
  }
]

resource roleAssignments 'Microsoft.Authorization/roleAssignments@2022-01-01-preview' = [
  for item in permissions: {
    name: guid(resourceGroup().id, item.name, item.roleDefinitionId)
    scope: kv
    properties: {
      principalId: item.principalId
      roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', item.roleDefinitionId)
      condition: contains(item, 'condition') && item.condition != '' ? item.condition : null
      conditionVersion: contains(item, 'conditionVersion') && item.conditionVersion != '' ? item.conditionVersion : null
      delegatedManagedIdentityResourceId: contains(item, 'delegatedManagedIdentityResourceId') && item.delegatedManagedIdentityResourceId != ''
        ? item.delegatedManagedIdentityResourceId
        : null
      description: item.description
      principalType: item.principalType
    }
  }
]

@description('The name of the Azure resource')
output resourceName string = kv.name
@description('The resource-id of the Azure resource')
output resourceID string = kv.id
