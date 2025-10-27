# Functie om te controleren of een module is geïnstalleerd
function Check-And-Install-Module {
    param (
        [string]$ModuleName
    )
    if (-not (Get-Module -ListAvailable -Name $ModuleName)) {
        Write-Host "Module $ModuleName is niet geïnstalleerd. Installeren..."
        Install-Module -Name $ModuleName -Force -Scope CurrentUser
    } else {
        Write-Host "Module $ModuleName is al geïnstalleerd."
    }
}

# Controleer en installeer de benodigde modules
Check-And-Install-Module -ModuleName "ExchangeOnlineManagement"

# Importeer de module
Import-Module ExchangeOnlineManagement

# Maak verbinding met Exchange Online
Connect-ExchangeOnline

# Ophalen van mailboxgegevens
$mailboxes = Get-Mailbox -ResultSize Unlimited
$mailboxDetails = foreach ($mailbox in $mailboxes) {
    $permissions = Get-MailboxPermission -Identity $mailbox.Identity
    $licenties = Get-MailboxStatistics -Identity $mailbox.Identity | Select-Object StorageLimitStatus

    # Aangepast object voor elk postvak
    [PSCustomObject]@{
        DisplayName  = $mailbox.DisplayName
        EmailAddress = $mailbox.PrimarySmtpAddress
        MailboxType  = $mailbox.RecipientTypeDetails
        License      = $licenties.StorageLimitStatus
        Permissions  = ($permissions | Where-Object { $_.User -notlike "NT AUTHORITY\SELF" }) | ForEach-Object { $_.User }
    }
}

# Resultaten naar CSV exporteren
$path = "C:\Users\MukiLukunaITSynergy\IT Synergy\Storax - Documents\inventarisatie\mailbox.CSV"
$mailboxDetails | Export-Csv -Path $path -NoTypeInformation -Encoding UTF8

# Verbinding met Exchange Online verbreken
Disconnect-ExchangeOnline -Confirm:$false

# Bevestiging van voltooide export
Write-Host "Export voltooid. De gegevens zijn opgeslagen in $path"
