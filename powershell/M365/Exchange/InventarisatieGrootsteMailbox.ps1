# Controleer of de ExchangeOnlineManagement-module is geïnstalleerd
if (-not (Get-Module -ListAvailable -Name ExchangeOnlineManagement)) {
    # Installeer de module als deze niet aanwezig is
    Install-Module -Name ExchangeOnlineManagement -Force -AllowClobber
}

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
        Permissions  = ($permissions | Where-Object { $_.User -ne $null } | Select-Object -ExpandProperty User) -join ', '
    }
}

# Resultaten naar CSV exporteren
$path = "C:\Users\MukiLukunaITSynergy\IT Synergy\Storax - Documents\inventarisatie\mailboxDetails.csv"
$mailboxDetails | Export-Csv -Path $path -NoTypeInformation -Encoding UTF8

# Verbinding met Exchange Online verbreken
Disconnect-ExchangeOnline -Confirm:$false

# Bevestiging van voltooide export
Write-Host "Export voltooid. De gegevens zijn opgeslagen in $path"
