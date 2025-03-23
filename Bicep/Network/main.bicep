targetScope = 'resourceGroup'
param KeyVaultName string
param enablePurgeProtection bool = true
@secure()
param patToken string = newGuid()

module myKeyVault 'br/public:avm/res/key-vault/vault:0.11.0' = {
  name: 'AVMKeyVault' // the name of the module's deployment
  params: {
    name: KeyVaultName
    enablePurgeProtection: enablePurgeProtection
    secrets: [
      {
        name: 'mySecret'
        value: patToken
      }
    ]
    roleAssignments: [
      {principalId: 'test'
      roleDefinitionIdOrName: 'Contributor'
      }
    ]
  }
}
