targetScope = 'resourceGroup'

param keyVaultName string

param secretName string

@secure()
param secretValue string

resource keyVault 'Microsoft.KeyVault/vaults@2023-07-01' existing = {
  name: keyVaultName
}

resource secret 'Microsoft.KeyVault/vaults/secrets@2023-07-01' = if (secretValue != '') {
  name: secretName
  parent: keyVault
  properties: {
    value: secretValue
  }
}

output secretName string = secretName
