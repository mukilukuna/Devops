Connect-ExchangeOnline
Search-MailboxAuditLog
Search-MailboxAuditLog -Mailboxes "Summit Travel" -har

cd C:\Users\muki.lukuna.ITSYNERGY.001\Downloads\


.\AuditDeletedEmails.ps1 -Mailbox info@summittravel.nl -Subject "questions ID"
.\AuditDeletedEmails.ps1 -Mailbox info@summittravel.nl -StartDate 11/22/22 -EndDate 11/29/22


Get-MailboxFolderPermission -Identity Hoven@w-e.nl:\agenda

Get-MailboxCalendarConfiguration

Get-RecipientPermission "Bas van den Hoven"

Get-OrganizationRelationship

Get-PublicFolderClientPermission -Identity Public "Folders"

Get-ManagementRole -Cmdlet Get-PublicFolderClientPermission

get-publicfolder

Get-Mailbox | ForEach-Object { Get-MailboxFolderPermission $_”:\agenda” } | Where { $_.User -like “bas” } | Select Identity, User, AccessRights
Get-Mailbox | ForEach-Object { Get-MailboxFolderPermission $_":\calendar" } | Where { $_.User -like “*Mueller*” } | Select Identity, User, AccessRights

Get-MailboxFolderPermission Verweij@w-e.nl:\agenda


Get-Mailbox | Get-MailboxPermission -User Verweij@w-e.nl