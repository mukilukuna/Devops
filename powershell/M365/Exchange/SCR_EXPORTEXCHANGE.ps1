# Script: SCR_EXPORTEXCHANGE.ps1
# Purpose: SCR EXPORTEXCHANGE
$Path = "C:\Users\muki.lukuna\IT Synergy\Stichting Mano - General\Professional services\Inventarisatie\export.csv"

Connect-ExchangeOnline
# Zorg ervoor dat het exportpad bestaat
if (-not (Test-Path -Path (Split-Path -Path $Path -Parent))) {
    New-Item -ItemType Directory -Path (Split-Path -Path $Path -Parent) -Force
}

# Overige code voor module checks en connecties...

$gebruikers = Get-Mailbox -ResultSize Unlimited

$results = foreach ($gebruiker in $gebruikers) {
    $mailboxStats = Get-MailboxStatistics -Identity $gebruiker.Identity
    $mailboxPermissions = Get-MailboxPermission -Identity $gebruiker.Identity | Where-Object { $_.IsInherited -eq $false -and $_.User -notlike "NT AUTHORITY\SELF" } | Select-Object User, @{Name='AccessRights';Expression={$_.AccessRights -join ', '}}

    $servicePlans = $null
    try {
        $servicePlans = Get-MsolUser -UserPrincipalName $gebruiker.UserPrincipalName -ErrorAction Stop | Select-Object -ExpandProperty Licenses | Select-Object -ExpandProperty ServiceStatus | Where-Object { $_.ProvisioningStatus -eq "Enabled" } | Select-Object -ExpandProperty ServicePlan
    } catch {
        $servicePlans = "Gebruiker niet gevonden in MSOnline"
    }

    [PSCustomObject]@{
        Gebruikersnaam       = $gebruiker.Name
        Email                = $gebruiker.PrimarySmtpAddress
        Aliassen             = ($gebruiker.EmailAddresses | Where-Object { $_.PrefixString -eq "smtp" } | ForEach-Object { $_.SmtpAddress }) -join '; '
        Forward              = if ($gebruiker.ForwardingSmtpAddress -ne $null) { $gebruiker.ForwardingSmtpAddress.ToString() } else { "Geen" }
        GrootteVanHetPostvak = $mailboxStats.TotalItemSize.Value.ToString()
        RechtenVanHetPostvak = ($mailboxPermissions | ForEach-Object { $_.User + ': ' + $_.AccessRights }) -join '; '
        MailboxType          = $gebruiker.RecipientTypeDetails
        ServicePlans         = if ($servicePlans -is [string]) { $servicePlans } else { ($servicePlans | ForEach-Object { $_.ServiceName }) -join '; ' }
    }
}

$results | Export-Csv -Path $Path -NoTypeInformation -Delimiter ';'


