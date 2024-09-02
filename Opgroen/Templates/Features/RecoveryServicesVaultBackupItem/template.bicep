@description('Required. Name of the recovery services vault')
param backupVaultName string

@description('Required. Name of the backup policy')
param backupPolicyName string

@description('Required. ID of the VM')
param vmId string

@description('Required. Name of the VM')
param vmName string

@description('Required. ResourceGroup of the VM')
param resourceGroup string

resource recoveryServicesVault 'Microsoft.RecoveryServices/vaults@2021-08-01' existing = {
  name: backupVaultName
}

var protectionContainer = 'Azure/iaasvmcontainer;iaasvmcontainerv2;${resourceGroup};${vmName}'
var protectedItem = 'vm;iaasvmcontainerv2;${resourceGroup};${vmName}'

resource backup 'Microsoft.RecoveryServices/vaults/backupFabrics/protectionContainers/protectedItems@2021-08-01' = {
  name: '${backupVaultName}/${protectionContainer}/${protectedItem}'
  properties: {
    protectedItemType: 'Microsoft.Compute/virtualMachines'
    policyId: resourceId('Microsoft.RecoveryServices/vaults/backupPolicies', backupVaultName, backupPolicyName)
    sourceResourceId: vmId
  }
}

@description('The ID of the Azure resource')
output resourceID string = backup.id

@description('The name of the Azure resource')
output resourceName string = backup.name
