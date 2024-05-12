param location string = 'westeurope'
param name string = 'cir'

// Create a FileStorage Account for premium file shares
resource storageAccount 'Microsoft.Storage/storageAccounts@2021-02-01' = {
  name: '${name}euazusto'
  location: location
  kind: 'FileStorage' // Specifically for premium file shares
  sku: {
    name: 'Premium_LRS' // Premium performance tier
  }
}


// Define the default file service for the storage account
resource fileService 'Microsoft.Storage/storageAccounts/fileServices@2023-01-01' = {
  name: 'default'
  parent: storageAccount
}

// Define file share 'APPS'
resource appsFileShare 'Microsoft.Storage/storageAccounts/fileServices/shares@2023-01-01' = {
  name: 'APPS'
  parent: fileService
  properties: {
    shareQuota: 100 // Example quota in GiB
    metadata: {
      description: 'File share for applications'
    }
  }
}

// Define file share 'SYSLOGON'
resource sysLogonFileShare 'Microsoft.Storage/storageAccounts/fileServices/shares@2023-01-01' = {
  name: 'SYSLOGON'
  parent: fileService
  properties: {
    shareQuota: 50 // Example quota in GiB
    metadata: {
      description: 'File share for system logon scripts'
    }
  }
}

// Define file share 'SCRIPTS'
resource scriptsFileShare 'Microsoft.Storage/storageAccounts/fileServices/shares@2023-01-01' = {
  name: 'SCRIPTS'
  parent: fileService
  properties: {
    shareQuota: 20 // Example quota in GiB
    metadata: {
      description: 'File share for miscellaneous scripts'
    }
  }
}
