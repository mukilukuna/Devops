# Functie om te controleren of een module is geïnstalleerd, en zo niet, deze te installeren
function Install-ModuleIfNotInstalled {
    param (
        [string]$ModuleName
    )

    if (-not (Get-Module -ListAvailable -Name $ModuleName)) {
        Write-Host "Module $ModuleName is niet geïnstalleerd. Installeren..."
        Install-Module -Name $ModuleName -Force -AllowClobber
    } else {
        Write-Host "Module $ModuleName is al geïnstalleerd."
    }
}

# Controleer en installeer de Microsoft Teams module
Install-ModuleIfNotInstalled -ModuleName "MicrosoftTeams"

# Log in bij Microsoft Teams
Connect-MicrosoftTeams

# Haal alle teams op en hun bijbehorende ID's
$teams = Get-Team

Write-Host "Hier is een lijst van jouw Teams en hun bijbehorende ID's:"
$teams | Format-Table DisplayName, GroupId

# Selecteer het Team-ID dat je wilt gebruiken
$teamId = Read-Host "Voer het GroupId in van het team waarvan je de kanalen wilt verwijderen"

# Bevestiging vragen voor het verwijderen van kanalen
$confirmation = Read-Host "Weet je zeker dat je alle kanalen in het team $teamId wilt verwijderen? (ja/nee)"
if ($confirmation -eq "ja") {
    # Haal alle kanalen op binnen het geselecteerde team
    $channels = Get-TeamChannel -GroupId $teamId

    # Verwijder elk kanaal
    foreach ($channel in $channels) {
        Remove-TeamChannel -GroupId $teamId -DisplayName $channel.DisplayName
        Write-Host "Kanaal $($channel.DisplayName) verwijderd."
    }

    Write-Host "Alle kanalen zijn verwijderd."
} else {
    Write-Host "Verwijderingsproces geannuleerd."
}