param location string = resourceGroup().location
@minLength(3)
@maxLength(24)
param name string = 'liteuezusto'
@allowed([
  'Standard_LRS'
  'Standard_GRS'
  'Standard_RAGRS'
  'Standard_ZRS'
  'Premium_LRS'
])
param type string = 'Standard_LRS'
param fileShareName string = 'netlogon'
@allowed([100, 1024, 5120])
@maxValue(5120)
@minValue(100)
param fileShareQuota int = 100
@allowed(['premium', 'standard', 'hot'])
param accesstier string = 'premium'
@allowed(['nfs', 'smb'])
param enabledProtocols string = 'nfs'
resource StorageAccount 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: name
  location: location
  kind: 'StorageV2'
  sku: {
    name: type
  }
  properties: {
    supportsHttpsTrafficOnly: true
  }
}

resource fileshare 'Microsoft.Storage/storageAccounts/fileServices/shares@2023-01-01' = {
  name: '${name}/default/${fileShareName}'
  dependsOn: [
    StorageAccount
  ]
  properties: {
    accessTier: accesstier
    enabledProtocols: enabledProtocols

    shareQuota: fileShareQuota
  }
}
