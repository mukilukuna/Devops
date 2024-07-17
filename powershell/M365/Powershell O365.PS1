Install the 64-bit version of the Microsoft Online Services Sign-in Assistant
https://go.microsoft.com/fwlink/p/?LinkId=286152

Install Framework 5.1
https://www.microsoft.com/download/details.aspx?id=54616

##Run Powershell as Administrator
Check Powershell version
(Get-Host).Version
$PSVersionTable.PSVersion
Install-Module -Name AzureAD
Install-Module MSOnline
Set-ExecutionPolicy RemoteSigned
$UserCredential = Get-Credential
$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $UserCredential -Authentication Basic -AllowRedirection
Import-PSSession $Session -DisableNameChecking

#Einde sessie:
- Remove-PSSession $Session

##Deze heb je nodig Hugo je moet het even uncommenten
#get-mailbox recruitment@koers.com | Set-Mailbox -MessageCopyForSendOnBehalfEnabled $true
#get-mailbox recruitment@koers.com | Set-Mailbox -MessageCopyForSentAsEnabled $true


##na het inloggen voor deze comando uit om te zien welke sharedmailboxen een gebruiker rechten tot heeft, vervang .... met gebruikersnaam

##Get-Mailbox -RecipientTypeDetails UserMailbox,SharedMailbox -ResultSize Unlimited | Get-MailboxPermission -User levers@w-e.nl
##versturen als
##Get-Mailbox | Get-RecipientPermission -Trustee levers@w-e.nl
## versturen namens
##Get-Mailbox | ? {$_.GrantSendOnBehalfTo -match "levers@w-e.nl"}

