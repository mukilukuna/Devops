# Prerequisites: 
# - backup vault
# - backup policy for AFS
# - storage account with file share
# Microsoft docs: https://docs.microsoft.com/en-us/azure/backup/backup-azure-afs-automation

$vaultName = "<Name of the Backup Vault>"
$vaultRG = "<Resource group of the Backup Vault>"
$policyName = "<Name of the backup policy>"
$storageAccountName = "<Name of storage account>"
$fileShareName = "<Name of the file share>"

# Set the recovery vault context
$vault = Get-AzRecoveryServicesVault -Name $vaultName -ResourceGroupName $vaultRG
Set-AzRecoveryServicesVaultContext -Vault $vault

# Enable backup of the file share
$afsPol = Get-AzRecoveryServicesBackupProtectionPolicy -Name $policyName
Enable-AzRecoveryServicesBackupProtection -StorageAccountName $storageAccountName -Name $fileShareName -Policy $afsPol