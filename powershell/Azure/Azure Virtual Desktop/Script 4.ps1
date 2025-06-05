# Script: Script 4.ps1
# Purpose: Script 4
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Install-Module -Name PowerShellGet -Force -SkipPublisherCheck

Install-Module -Name Az -AllowClobber -SkipPublisherCheck

Connect-AzAccount

Install-Module -Name AzureAD -Force
Import-Module -Name AzureAD

$tenantId = (Get-AzContext).Tenant.Id
Connect-AzureAD -TenantId $tenantId

$aadDomainName = ((Get-AzureAdTenantDetail).VerifiedDomains)[0].Name

$domainUsers = Get-ADUser -Filter { UserPrincipalName -like '*adatum.com' } -Properties userPrincipalName -ResultSetSize $null
$domainUsers | foreach { $newUpn = $_.UserPrincipalName.Replace('adatum.com', $aadDomainName); $_ | Set-ADUser -UserPrincipalName $newUpn }

$domainAdminUser = Get-ADUser -Filter { sAMAccountName -eq 'Student' } -Properties userPrincipalName
$domainAdminUser | Set-ADUser -UserPrincipalName 'student@adatum.com'