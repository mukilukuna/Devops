@description('Required. The name of the application')
@maxLength(5)
param applicationName string

@description('Required. The code of the environment this resource will be used in')
@maxLength(1)
param environmentName string

@description('Required. The name of the workload this resource will be used for')
@maxLength(5)
param workloadName string

@description('Required. Region of the storage account')
@maxLength(4)
param regionName string

@description('Optional. The name to use if not using the normal naming convention')
param customName string = ''

@description('Optional. Enable encryption of Blob')
param encryptionBlob bool = true

@description('Optional. Enable encryption of Files')
param encryptionFile bool = true

@description('Optional. Set HTTPS traffic only')
param supportsHttpsTrafficOnly bool = true

@description('Optional. Set the access tier of the storage account')
@allowed([
  'Hot'
  'Cool'
])
param accessTier string = 'Hot'

@description('Optional. Specifies whether traffic is bypassed for Logging/Metrics/AzureServices. Possible values are any combination of Logging,Metrics,AzureServices (For example, "Logging, Metrics"), or None to bypass none of those traffics')
param bypass string = 'AzureServices'

@description('Optional. Specifies the default action of allow or deny when no other rules match')
@allowed([
  'Allow'
  'Deny'
])
param defaultAction string = 'Deny'

@description('Optional. Allow or disallow public network access to Storage Account.')
@allowed([
  'Enabled'
  'Disabled'
])
param publicNetworkAccess string = 'Disabled'

@description('Optional. Allow or disallow Blob public acces')
@allowed([
  false
  true
])
param allowBlobPublicAccess bool = false

@description('Optional. Minimal allowed TLS version')
@allowed([
  'TLS1_0'
  'TLS1_1'
  'TLS1_2'
])
param minimumTlsVersion string = 'TLS1_2'

@description('Optional. Sets the virtual network rules.')
param virtualNetworkRules array = []

@description('Optional. Sets the IP ACL rules')
param ipRules array = []

@description('Optional. Enables the delete retention policy')
param blobDeleteRetentionPolicy bool = true

@description('Optional. Indicates the number of days that the deleted item should be retained')
@minValue(1)
@maxValue(365)
param blobRetentionDays int = 30

@description('Optional. Enables the delete retention policy')
param shareDeleteRetentionPolicy bool = true

@description('Optional. Indicates the number of days that the deleted item should be retained')
@minValue(1)
@maxValue(365)
param shareRetentionDays int = 30

@description('Optional. Indicates the type of storage account')
@allowed([
  'BlobStorage'
  'BlockBlobStorage'
  'FileStorage'
  'Storage'
  'StorageV2'
])
param kind string = 'StorageV2'

@description('Optional. sku of the storage account')
@allowed([
  'Premium_LRS'
  'Premium_ZRS'
  'Standard_GRS'
  'Standard_GZRS'
  'Standard_LRS'
  'Standard_RAGRS'
  'Standard_RAGZRS'
  'Standard_ZRS'
])
param skuName string = 'Standard_GRS'

@description('Optional. Location of the resource')
param location string = resourceGroup().location

@description('Optional. Array of Role Assignments to deploy')
param permissions array = []

@description('Optional. Diagnostic settings configuration')
param diagnosticSettings array = []

@description('Optional. Resource tags')
param tags object = {}

var nameVar = toLower('st${workloadName}${applicationName}${environmentName}${regionName}${substring(uniqueString(resourceGroup().id), 7)}')

resource st 'Microsoft.Storage/storageAccounts@2021-06-01' = {
  name: empty(customName) ? nameVar : customName
  sku: {
    name: skuName
  }
  kind: kind
  location: location
  tags: tags
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    supportsHttpsTrafficOnly: supportsHttpsTrafficOnly
    publicNetworkAccess: publicNetworkAccess
    minimumTlsVersion: minimumTlsVersion
    allowBlobPublicAccess: allowBlobPublicAccess
    accessTier: kind == 'storageV2' ? accessTier : null
    networkAcls: {
      bypass: bypass
      defaultAction: defaultAction
      ipRules: ipRules
      virtualNetworkRules: virtualNetworkRules
    }
    encryption: {
      keySource: 'Microsoft.Storage'
      services: {
        blob: {
          enabled: encryptionBlob
        }
        file: {
          enabled: encryptionFile
        }
      }
    }
  }

  resource blobService 'blobServices@2021-06-01' = {
    name: 'default'
    properties: {
      deleteRetentionPolicy: {
        enabled: blobDeleteRetentionPolicy
        days: blobDeleteRetentionPolicy ? blobRetentionDays : null
      }
    }
  }

  resource symbolicname 'fileServices@2021-06-01' = {
    name: 'default'
    properties: {
      shareDeleteRetentionPolicy: {
        enabled: shareDeleteRetentionPolicy
        days: shareDeleteRetentionPolicy ? shareRetentionDays : null
      }
    }
  }
}

resource diagSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = [for setting in diagnosticSettings: if (!empty(diagnosticSettings)) {
  name: setting.name
  scope: st
  properties: {
    workspaceId: contains(setting, 'workspaceId') ? setting.workspaceId : null
    storageAccountId: contains(setting, 'diagnosticsStorageAccountId') ? setting.diagnosticsStorageAccountId : null
    logs: contains(setting, 'logs') ? setting.logs : null
    metrics: contains(setting, 'metrics') ? setting.metrics : null
  }
}]

resource roleAssignments 'Microsoft.Authorization/roleAssignments@2022-04-01' = [for item in permissions: {
  name: guid(resourceGroup().id, item.name, item.roleDefinitionId)
  scope: st
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
output resourceName string = st.name

@description('The resource-id of the Azure resource')
output resourceID string = st.id

@description('The URI of the Azure Blob storage primary endpoint')
output primaryEndpointsBlob string = st.properties.primaryEndpoints.blob
