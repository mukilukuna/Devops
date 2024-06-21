Connect-MsolService
$user = Get-MsolUser -UserPrincipalName "yasemin.kahramanoglu@hefgroep-peuterenco.nl"
	
$user.Licenses
	
$user.Licenses.ServiceStatus
#reseller-account:O365_BUSINESS_ESSENTIALS - BASIC
#reseller-account:M365_F1_COMM - F1
#reseller-account:SPE_F1 - Microsoft F3

Get-MsolAccountSku


$LO = New-MsolLicenseOptions -AccountSkuId "reseller-account:M365_F1_COMM" -DisabledPlans "SHAREPOINTDESKLESS", "MCOIMP", "EXCHANGE_S_DESKLESS"
Set-MsolUserLicense -UserPrincipalName "anja.mom@hefgroep-peuterenco.nl" -LicenseOptions $LO

#Import CSVMO

Get-Content "C:\My Documents\Accounts.txt" | foreach {Set-MsolUserLicense -UserPrincipalName $_ -LicenseOptions $LO}

Get-Content "C:\My Documents\Accounts.txt" | foreach {Set-MsolUserLicense -UserPrincipalName $_ -LicenseOptions $LO}

Set-MsolUserLicense -UserPrincipalName "anja.mom@hefgroep-peuterenco.nl" -AddLicenses "reseller-account:O365_BUSINESS_ESSENTIALS"

#F3 User
Set-MsolUserLicense -UserPrincipalName "yasemin.kahramanoglu@hefgroep-peuterenco.nl" –RemoveLicenses "reseller-account:M365_F1_COMM"
Set-MsolUserLicense -UserPrincipalName "yasemin.kahramanoglu@hefgroep-peuterenco.nl" -AddLicenses "reseller-account:SPE_F1"

Get-Content "C:\LIC\F3.txt" | foreach {Set-MsolUserLicense -UserPrincipalName $_ –RemoveLicenses "reseller-account:M365_F1_COMM"} 
Get-Content "C:\LIC\F3.txt" | foreach {Set-MsolUserLicense -UserPrincipalName $_ -AddLicenses "reseller-account:SPE_F1"} 

#F1
$LO = New-MsolLicenseOptions -AccountSkuId "reseller-account:M365_F1_COMM" -DisabledPlans "MCOIMP", "EXCHANGE_S_DESKLESS"
Set-MsolUserLicense -UserPrincipalName "marlies.slaa@hefgroep-peuterenco.nl" -LicenseOptions $LO
Set-MsolUserLicense -UserPrincipalName "marlies.slaa@hefgroep-peuterenco.nl" -AddLicenses "reseller-account:O365_BUSINESS_ESSENTIALS"

$LO = New-MsolLicenseOptions -AccountSkuId "reseller-account:M365_F1_COMM" -DisabledPlans "MCOIMP", "EXCHANGE_S_DESKLESS"
Get-Content "C:\LIC\F1.txt" | foreach {Set-MsolUserLicense -UserPrincipalName $_ -LicenseOptions $LO} 
Get-Content "C:\LIC\F1.txt" | foreach {Set-MsolUserLicense -UserPrincipalName $_ -AddLicenses "reseller-account:O365_BUSINESS_ESSENTIALS"} 

"C:\LIC\F3.txt"