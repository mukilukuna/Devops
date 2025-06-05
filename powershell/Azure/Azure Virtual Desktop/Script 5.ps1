# Script: Script 5.ps1
# Purpose: Script 5
$userName = 'aadsyncuser'
$passwordProfile = New-Object -TypeName Microsoft.Open.AzureAD.Model.PasswordProfile
$passwordProfile.Password = '6l3oswU_i4AphlspAdl2'
$passwordProfile.ForceChangePasswordNextLogin = $false
New-AzureADUser -AccountEnabled $true -DisplayName $userName -PasswordProfile $passwordProfile -MailNickName $userName -UserPrincipalName "$userName@$aadDomainName"


(Get-AzureADUser -Filter "MailNickName eq '$userName'").UserPrincipalName


$aadUser = Get-AzureADUser -ObjectId "$userName@$aadDomainName"
$aadRole = Get-AzureADDirectoryRole | Where-Object { $_.displayName -eq 'Global administrator' } 
Add-AzureADDirectoryRoleMember -ObjectId $aadRole.ObjectId -RefObjectId $aadUser.ObjectId