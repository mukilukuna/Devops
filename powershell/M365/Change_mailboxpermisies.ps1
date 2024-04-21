# Vereiste modules
$requiredModules = @("ExchangeOnlineManagement")

# Controleer en installeer de vereiste modules
foreach ($module in $requiredModules) {
    if (-not (Get-Module -ListAvailable -Name $module)) {
        Write-Host "Module $module is niet geïnstalleerd. Bezig met installeren..."
        Install-Module -Name $module -Force -AllowClobber
    }
    else {
        Write-Host "Module $module is al geïnstalleerd."
    }
}

# Verbinding maken met Exchange Online
Connect-ExchangeOnline

# Voer mailboxauditlogscripts uit
Search-MailboxAuditLog -Mailboxes "Summit Travel" -har

cd C:\Users\muki.lukuna.ITSYNERGY.001\Downloads\

.\AuditDeletedEmails.ps1 -Mailbox info@summittravel.nl -Subject "questions ID"
.\AuditDeletedEmails.ps1 -Mailbox info@summittravel.nl -StartDate 11/22/22 -EndDate 11/29/22

# Uitvoeren van verdere commando's zoals nodig
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
