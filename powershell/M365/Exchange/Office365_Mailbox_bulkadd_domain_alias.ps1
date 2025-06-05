# Script: Office365_Mailbox_bulkadd_domain_alias.ps1
# Purpose: Office365 Mailbox bulkadd domain alias
Connect-ExchangeOnline

$users = Get-Mailbox -ResultSize Unlimited | Where-Object{$_.PrimarySMTPAddress -match "stichting-joz.nl"}#
 
foreach($user in $users){
    $newUpn = $user.UserPrincipalName.Replace(‘stichting-joz.nl’,’sbrdam.nl’)
    Write-Host "Adding Alias" $newUpn
    Set-Mailbox $user.PrimarySmtpAddress -EmailAddresses @{add="$newUpn"}
}

$users = Get-Mailbox -ResultSize Unlimited | Where-Object{$_.PrimarySMTPAddress -match "peuterenco.nl"}
 
foreach($user in $users){
    $newUpn = $user.UserPrincipalName.Replace(‘peuterenco.nl’,’sbrdam.nl’)
    Write-Host "Adding Alias" $newUpn
    Set-Mailbox $user.PrimarySmtpAddress -EmailAddresses @{add="$newUpn"}
}

$users = Get-Mailbox -ResultSize Unlimited | Where-Object{$_.PrimarySMTPAddress -match "smwr-rijnmond.nl"}
 
foreach($user in $users){
    $newUpn = $user.UserPrincipalName.Replace(‘smwr-rijnmond.nl’,’sbrdam.nl’)
    Write-Host "Adding Alias" $newUpn
    Set-Mailbox $user.PrimarySmtpAddress -EmailAddresses @{add="$newUpn"}
}

$users = Get-Mailbox -ResultSize Unlimited | Where-Object{$_.PrimarySMTPAddress -match "hefgroep.nl"}
 
foreach($user in $users){
    $newUpn = $user.UserPrincipalName.Replace(‘hefgroep.nl’,’sbrdam.nl’)
    Write-Host "Adding Alias" $newUpn
    Set-Mailbox $user.PrimarySmtpAddress -EmailAddresses @{add="$newUpn"}
}