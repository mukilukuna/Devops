# Script: Office365_Mailbox_bulkalias_remover_final.ps1
# Purpose: Office365 Mailbox bulkalias remover final
$Domain = "sbrdam.nl"
$RemoveSMTPDomain = "smtp:*@$Domain"
 
 
$AllMailboxes = Get-Mailbox | Where-Object {$_.EmailAddresses -clike $RemoveSMTPDomain}
 
 
ForEach ($Mailbox in $AllMailboxes)
{
 
       
   $AllEmailAddress  = $Mailbox.EmailAddresses -cnotlike $RemoveSMTPDomain
   $RemovedEmailAddress = $Mailbox.EmailAddresses -clike $RemoveDomainsmtp
   $MailboxID = $Mailbox.PrimarySmtpAddress 
   $MailboxID | Set-Mailbox -EmailAddresses $AllEmailAddress #-whatif
 
   Write-Host "The follwoing E-mail address where removed $RemovedEmailAddress from $MailboxID Mailbox "
   
 
} 