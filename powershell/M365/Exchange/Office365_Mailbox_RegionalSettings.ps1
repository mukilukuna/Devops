# Script: Office365_Mailbox_RegionalSettings.ps1
# Purpose: Office365 Mailbox RegionalSettings
Connect-ExchangeOnline
Get-MailboxRegionalConfiguration facturen@hefgroep.nl
Set-MailboxRegionalConfiguration -Identity facturen@hefgroep.nl -Language nl-NL -DateFormat “d-M-yyyy” -timezone “W. Europe Standard Time” -timeformat “HH:mm” -LocalizeDefaultFolderName:$true
Set-MailboxRegionalConfiguration -Identity itunes@peuterenco.nl -Language nl-NL -DateFormat “d-M-yyyy” -timezone “W. Europe Standard Time” -timeformat “HH:mm” -LocalizeDefaultFolderName:$true


#Get-MailboxRegionalConfiguration <user> | fl
#Checking the settings for alle users :
#Get-Mailbox | Get-MailboxRegionalConfiguration
#Change the settings to Dutch :
#Set-MailboxRegionalConfiguration -Identity <user> -Language nl-NL -DateFormat “d-M-yyyy” -timezone “W. Europe Standard Time” -timeformat “HH:mm” -LocalizeDefaultFolderName:$true
#Change the settings to English :
#Set-MailboxRegionalConfiguration -Identity <user> -Language en-US -DateFormat “M/d/yyyy” -timezone “W. Europe Standard Time” -timeformat “HH:mm” -LocalizeDefaultFolderName:$true
#Change the settings, for all users in the Office 365 portal to Dutch :
#Get-mailbox -ResultSize unlimited | Set-MailboxRegionalConfiguration -Language nl-NL -DateFormat “d-M-yyyy” -timezone “W. Europe Standard Time” -timeformat “HH:mm” -LocalizeDefaultFolderName:$true