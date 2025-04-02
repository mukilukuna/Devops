targetScope = 'resourceGroup'
param KeyVaultName string = 'AVMKeyVault' // the name of the Key Vault
param location string = resourceGroup().location // the location of the Key Vault
param enablePurgeProtection bool = true
@secure()
param patToken string = newGuid()

module myKeyVault 'br/public:avm/res/key-vault/vault:0.11.0' = {
  name: 'AVMKeyVault' // the name of the module's deployment
  params: {
    name: KeyVaultName
    enablePurgeProtection: enablePurgeProtection
    location: location
    secrets: [
      {
        name: 'mySecret'
        value: patToken
      }
    ]
    roleAssignments: [
      {principalId: 'da0a184d-e7dd-4d42-b011-a06f05fa395d'
      roleDefinitionIdOrName: 'owner'
      }
    ]
  }
}
