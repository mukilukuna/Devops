# Script: Office365_Tenant_DisableAzureADsync.ps1
# Purpose: Office365 Tenant DisableAzureADsync
Install-module MSOnline
Connect-MsolService
(Get-MsolCompanyInformation).DirectorySynchronizationEnabled
Set-MsolDirSyncEnabled -EnableDirSync $false
(Get-MsolCompanyInformation).DirectorySynchronizationEnabled