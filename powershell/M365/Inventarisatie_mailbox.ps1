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
        Permissions  = ($permissions | Select-Object User, AccessRights, IsInherited -ExpandProperty User).UserPrincipalName
    }
}

# Resultaten naar CSV exporteren
$path = "C:\Users\muki.lukuna\IT Synergy\Stichting Mano - General\Professional services\Inverntarisatie\mailboxDetails.csv"
$mailboxDetails | Export-Csv -Path $path -NoTypeInformation -Encoding UTF8

# Verbinding met Exchange Online verbreken
Disconnect-ExchangeOnline -Confirm:$false

# Bevestiging van voltooide export
Write-Host "Export voltooid. De gegevens zijn opgeslagen in $path"
