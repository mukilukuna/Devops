# Script: Office365_Mailbox_Add_Alias.ps1
# Purpose: Office365 Mailbox Add Alias
Connect-ExchangeOnline
Set-Mailbox "iTunes en Playstore Accounts" -EmailAddresses @{add="SBR-TB002@peuterenco.nl"}