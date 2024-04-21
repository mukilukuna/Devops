# Installeer en importeer de MSOnline module als deze nog niet is geïnstalleerd en geïmporteerd
if (-not (Get-Module -Name MSOnline)) {
    Install-Module -Name MSOnline -Force -AllowClobber
}
Import-Module MSOnline

# Verbinding maken met de Microsoft 365-tenant
Connect-MsolService

# Haal alle gebruikers op in de Microsoft 365-tenant
$gebruikers = Get-MsolUser -All

# Array om de gebruikersgegevens op te slaan
$gebruikersgegevens = @()

# Loop door elke gebruiker en haal de gewenste informatie op
foreach ($gebruiker in $gebruikers) {
    $displayName = $gebruiker.DisplayName
    $email = $gebruiker.UserPrincipalName
    $isSharedMailbox = $false
    $isSyncedFromAD = $false

    # Controleer of het postvak een gedeelde mailbox is
    if ($gebruiker.IsLicensed -eq $false) {
        $isSharedMailbox = $true
    }

    # Controleer of het account wordt gesynchroniseerd via Active Directory
    if ($gebruiker.DirSyncEnabled) {
        $isSyncedFromAD = $true
    }

    # Maak een hashtable met de gebruikersgegevens
    $gebruikerInfo = @{
        "DisplayName" = $displayName
        "E-mail" = $email
        "IsSharedMailbox" = $isSharedMailbox
        "IsSyncedFromAD" = $isSyncedFromAD
    }

    # Voeg de hashtable toe aan de array
    $gebruikersgegevens += New-Object PSObject -Property $gebruikerInfo
}

# Exporteer de gegevens naar een CSV-bestand
$gebruikersgegevens | Export-Csv -Path "C:\Users\muki.lukuna\IT Synergy\Stichting Mano - Professional services\Inverntarisatie\M365GebruikersInfo.csv" -NoTypeInformation

Write-Host "Gebruikersinformatie is opgeslagen in M365GebruikersInfo.csv"
