param location string = resourceGroup().location

@minLength(3)
@maxLength(24)
param name string = 'liteuezusto'

@allowed([
  'Premium_LRS'
])
param type string = 'Premium_LRS'

param fileShareName string = 'netlogon'

@allowed([100, 1024, 5120])
@maxValue(5120)
@minValue(100)
param fileShareQuota int = 100

@allowed(['NFS'])
param enabledProtocols string = 'NFS'

resource StorageAccount 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: name
  location: location
  kind: 'FileStorage'
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
    enabledProtocols: enabledProtocols
    shareQuota: fileShareQuota
  }
}
