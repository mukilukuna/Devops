Connect-MgGraph
# Datum voor de bestandsnaam
$datum = Get-Date -Format "yyyyMMdd"

# Haal alle gebruikers op met de benodigde eigenschappen
$users = Get-MgUser -All -Property DisplayName, UserPrincipalName, JobTitle, AssignedLicenses, OnPremisesSyncEnabled, UserType, SignInActivity

# Maak een array om de resultaten op te slaan
$result = @()

foreach ($user in $users) {
    # Bepaal het type gebruiker
    switch ($user.UserType) {
        "Member" {
            if ($user.MailNickname -like "*shared*") {
                $userType = "Shared"
            } else {
                $userType = "User"
            }
        }
        "Guest" { $userType = "Guest" }
        default { $userType = "External" }
    }

    # Controleer of de gebruiker een licentie heeft
    $hasLicense = if ($user.AssignedLicenses.Count -gt 0) { "Ja" } else { "Nee" }

    # Controleer of de gebruiker gesynchroniseerd is met Active Directory
    $adSynced = if ($user.OnPremisesSyncEnabled -eq $true) { "Ja" } else { "Nee" }

    # Haal de laatste aanmeldingsdatum op
    $lastSignIn = if ($user.SignInActivity.LastSignInDateTime) { $user.SignInActivity.LastSignInDateTime } else { "Nooit aangemeld" }

    # Voeg de gegevens toe aan de resultaten
    $result += [PSCustomObject]@{
        Naam                   = $user.DisplayName
        Email                  = $user.UserPrincipalName
        Type                   = $userType
        Functie                = $user.JobTitle
        Licentie               = $hasLicense
        ActiveDirectorySynced  = $adSynced
        LaatsteAanmelding      = $lastSignIn
        GastExternGebruiker    = $user.UserType
    }
}

# Exporteer de resultaten naar een CSV-bestand
$result | Export-Csv -Path "C:\temp\AzureAD_Gebruikers_$datum.csv" -NoTypeInformation -Encoding UTF8
