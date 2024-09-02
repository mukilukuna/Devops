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

@description('Optional. Storage type for the recovery service vault')
@allowed([
  'GeoRedundant'
  'Invalid'
  'LocallyRedundant'
  'ReadAccessGeoZoneRedundant'
  'ZoneRedundant'
])
param storageType string = 'GeoRedundant'

@description('Optional. Opt in details of cross region restore feature')
param crossRegionRestoreFlag bool = true

@description('Optional. Location of the resource')
param replicationAlertEmail array = []

@description('Optional. Resource tags')
param tags object = {}

@description('Optional. The SKU for the recovery vault')
@allowed([
  'Standard'
  'RS0'
])
param skuName string = 'Standard'

@description('Optional. Specify if a Managed Identity should be assigned')
param assignManagedIdentity bool = false

@description('Optional. Deny or allow public network access of the resource')
@allowed([
  'Enabled'
  'Disabled'
])
param publicNetworkAccess string = 'Enabled'

@description('Optional. Location of the resource')
param location string = resourceGroup().location

@description('Optional. Array of Role Assignments to deploy')
param permissions array = []

@description('Optional. Diagnostic settings configuration')
param diagnosticSettings array = []

var nameVar = toLower('rsv-${workloadName}-${applicationName}-${environmentName}-${regionName}-${padLeft(index, 2, '0')}')

resource vaultName 'Microsoft.RecoveryServices/vaults@2023-01-01' = {
  name: empty(customName) ? nameVar : customName
  location: location
  identity: assignManagedIdentity ? {
    type: 'SystemAssigned'
  } : {
    type: 'None'
  }
  tags: tags
  sku: {
    name: skuName
  }
  properties: {
    publicNetworkAccess: publicNetworkAccess
  }

  resource backupstorageconfig 'backupstorageconfig' = {
    name: 'vaultstorageconfig'
    location: location
    tags: tags
    properties: {
      crossRegionRestoreFlag: crossRegionRestoreFlag
      storageModelType: storageType
      storageType: storageType
    }
  }

  resource testRecoveryServices 'replicationAlertSettings' = if (!empty(replicationAlertEmail)) {
    name: 'replicationAlert'
    properties: {
      sendToOwners: 'Senders'
      customEmailAddresses: replicationAlertEmail
    }
  }
}

resource diagSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = [for setting in diagnosticSettings: if (!empty(diagnosticSettings)) {
  name: setting.name
  scope: vaultName
  properties: {
    workspaceId: contains(setting, 'workspaceId') ? setting.workspaceId : null
    storageAccountId: contains(setting, 'diagnosticsStorageAccountId') ? setting.diagnosticsStorageAccountId : null
    logs: contains(setting, 'logs') ? setting.logs : null
    metrics: contains(setting, 'metrics') ? setting.metrics : null
  }
}]

resource roleAssignments 'Microsoft.Authorization/roleAssignments@2022-01-01-preview' = [for item in permissions: {
  name: guid(resourceGroup().id, item.name, item.roleDefinitionId)
  scope: vaultName
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
output resourceName string = vaultName.name

@description('The resource-id of the Azure resource')
output resourceID string = vaultName.id

@description('The PrincipalId of the Managed Identity of the Azure resource')
output resourceIdentity string = assignManagedIdentity ? vaultName.identity.principalId : ''
