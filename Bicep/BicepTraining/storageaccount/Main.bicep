param location string = resourceGroup().location
param name string = 'liteuezusto'
param type string = 'Premium_LRS'
param fileShareName string = 'netlogon'
param fileShareName2 string = 'syslogon'
param fileShareQuota int = 100
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

resource netlogon 'Microsoft.Storage/storageAccounts/fileServices/shares@2023-01-01' = {
  name: '${name}/default/${fileShareName}'
  dependsOn: [
    StorageAccount
  ]
  properties: {
    enabledProtocols: enabledProtocols
    shareQuota: fileShareQuota
  }
}
resource syslogon 'Microsoft.Storage/storageAccounts/fileServices/shares@2023-01-01' = {
  name: '${name}/default/${fileShareName2}'
  dependsOn: [
    StorageAccount
  ]
  properties: {
    enabledProtocols: enabledProtocols
    shareQuota: fileShareQuota
  }
}
