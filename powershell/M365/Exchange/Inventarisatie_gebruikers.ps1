# Installeer de Microsoft Graph PowerShell SDK als deze nog niet is geïnstalleerd
if (-not (Get-Module -Name Microsoft.Graph -ListAvailable)) {
    Install-Module -Name Microsoft.Graph -Scope CurrentUser -Force
}

# Importeer de Microsoft Graph module
Import-Module Microsoft.Graph

# Definieer het pad voor het CSV-bestand
$path = "C:\Users\MukiLukunaITSynergy\IT Synergy\Storax - Documents\inventarisatie\M365GebruikersInfo.csv"

# Verbinding maken met Microsoft Graph
Connect-MgGraph -Scopes "User.Read.All"

# Haal alle gebruikers op
$gebruikers = Get-MgUser -All

# Array om de gebruikersgegevens op te slaan
$gebruikersgegevens = @()

# Loop door elke gebruiker en haal de gewenste informatie op
foreach ($gebruiker in $gebruikers) {
    $displayName = $gebruiker.DisplayName
    $email = $gebruiker.UserPrincipalName
    $isSharedMailbox = $false
    $isSyncedFromAD = $false

    # Controleer of het postvak een gedeelde mailbox is
    if ($gebruiker.MailboxSettings -and $gebruiker.MailboxSettings.DelegateMeetingMessageDeliveryOptions) {
        $isSharedMailbox = $true
    }

    # Controleer of het account wordt gesynchroniseerd via Active Directory
    if ($gebruiker.OnPremisesSyncEnabled) {
        $isSyncedFromAD = $true
    }

    # Maak een object met de gebruikersgegevens
    $gebruikerInfo = [PSCustomObject]@{
        DisplayName      = $displayName
        Email            = $email
        IsSharedMailbox  = $isSharedMailbox
        IsSyncedFromAD   = $isSyncedFromAD
    }

    # Voeg het object toe aan de array
    $gebruikersgegevens += $gebruikerInfo
}

# Exporteer de gegevens naar een CSV-bestand
$gebruikersgegevens | Export-Csv -Path $path -NoTypeInformation

Write-Host "Gebruikersinformatie is opgeslagen in M365GebruikersInfo.csv"
