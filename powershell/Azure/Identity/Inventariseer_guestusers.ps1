# Stap 1: Installeer de Microsoft Graph PowerShell-module als je deze nog niet hebt
Install-Module Microsoft.Graph -Scope CurrentUser

# Stap 2: Maak verbinding met Microsoft Graph met de benodigde machtigingen
Connect-MgGraph -Scopes "User.Read.All", "AuditLog.Read.All", "Directory.Read.All"

# Stap 3: Definieer de periode (3 maanden geleden)
$DateThreshold = (Get-Date).AddMonths(-3)

# Stap 4: Haal alle gastgebruikers op
$guestUsers = Get-MgUser -All -Filter "userType eq 'Guest'" -Property "DisplayName", "UserPrincipalName", "UserType", "SignInActivity"

# Stap 5: Filter gebruikers die langer dan 3 maanden niet hebben ingelogd
$inactiveGuestUsers = $guestUsers | Where-Object {
    if ($_.SignInActivity.LastSignInDateTime) {
        [DateTime]$_.SignInActivity.LastSignInDateTime -lt $DateThreshold
    }
    else {
        # Als er geen aanmeldingsgegevens zijn, beschouw de gebruiker als nooit aangemeld
        $true
    }
}

# Stap 6: Selecteer de gewenste eigenschappen
$inactiveGuestUsers | Select-Object DisplayName, UserPrincipalName, @{Name = "LastSignInDateTime"; Expression = { $_.SignInActivity.LastSignInDateTime } }

# Stap 7: Exporteer de lijst naar een CSV-bestand (optioneel)
$inactiveGuestUsers | Select-Object DisplayName, UserPrincipalName, @{Name = "LastSignInDateTime"; Expression = { $_.SignInActivity.LastSignInDateTime } } | Export-Csv -Path "C:\temp\InactieveGastGebruikers.csv" -NoTypeInformation -Encoding UTF8
