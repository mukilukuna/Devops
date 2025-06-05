# Script: Migrate_FSlogix2New_share.ps1
# Purpose: Migrate FSlogix2New share
<# Zorg ervoor dat de volgende is ingesteld:
1. Azure PowerShell-module is geïnstalleerd.
2. voldoende ruimte in de doelbestandsshare.
3. AzCopy is geïnstalleerd op uw systeem.

Gemaakt door: Muki lukuna samen met chatGPT
#>
Connect-AzAccount -UseDeviceAuthentication
#Vervang <StorageAccountName> en <ResourceGroupName> door de naam van uw opslagaccount en resourcegroep om de context te verkrijgen:
$storageAccount = Get-AzStorageAccount -ResourceGroupName "DST-EUAZU-RSG" -Name "dsteuazustodata"
$ctx = $storageAccount.Context

#Vervang <FileShareName> door de naam van uw bronbestandsshare en stel de gewenste vervaltijd en machtigingen in:
$expiry = (Get-Date).AddDays(1)  # Stel de vervaldatum in op 1 dag vanaf nu
$permissions = "rl"  # Lezen en lijstmachtigingen
$sourceSasToken = New-AzStorageShareSASToken -Context $ctx -Name "fslogix" -ExpiryTime $expiry -Permission $permissions

#Herhaal het proces voor het doelopslagaccount en de bestandsshare:
$destinationStorageAccount = Get-AzStorageAccount -ResourceGroupName "DST-EUAZU-RSG" -Name "dsteuazusto"
$destinationCtx = $destinationStorageAccount.Context
$destinationSasToken = New-AzStorageShareSASToken -Context $destinationCtx -Name "fslogix11" -ExpiryTime $expiry -Permission "rwdl"  # Lezen, schrijven, verwijderen en lijstmachtigingen

#Combineer de opslagaccount-URI's met de gegenereerde SAS-tokens:
$sourceUri = $ctx.FileEndPoint + "fslogix" + "?" + $sourceSasToken
$destinationUri = $destinationCtx.FileEndPoint + "fslogix11" + "?" + $destinationSasToken

#Met de gegenereerde SAS-tokens kunt u AzCopy gebruiken om de FSLogix-profielen te migreren. Zorg ervoor dat AzCopy is geïnstalleerd op uw systeem. Gebruik de volgende opdracht in de opdrachtprompt of PowerShell:
azcopy copy $sourceUri $destinationUri --recursive --overwrite=ifSourceNewer --preserve-smb-permissions=true --preserve-smb-info=true