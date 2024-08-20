# Controleer of de Microsoft Teams module geïnstalleerd is en installeer deze zo nodig
function Install-ModuleIfNotInstalled {
    param (
        [string]$ModuleName
    )

    if (-not (Get-Module -ListAvailable -Name $ModuleName)) {
        Write-Host "Module $ModuleName is niet geïnstalleerd. Installeren..."
        Install-Module -Name $ModuleName -Force -AllowClobber
    }
    else {
        Write-Host "Module $ModuleName is al geïnstalleerd."
    }
}

# Installeer Microsoft Teams module als het nog niet geïnstalleerd is
Install-ModuleIfNotInstalled -ModuleName "MicrosoftTeams"

# Log in bij Microsoft Teams
Connect-MicrosoftTeams

Get-Team -DisplayName "RAZ" | Select-Object GroupId

# Team ID waar de kanalen moeten worden aangemaakt
$teamId = "75f60ff4-04ce-4851-a4be-6f40d1b5a207"

# Lijst van kanalen om aan te maken
$channels = @(
    "Onderzoeksprogramma",
    "Organisatie-bureau",
    "Overdracht",
    "Personeel",
    "Sluis"
)

# Maak elk kanaal aan als gedeeld kanaal
foreach ($channel in $channels) {
    try {
        New-TeamChannel -GroupId $teamId -DisplayName $channel -MembershipType Shared
        Write-Host "Kanaal '$channel' succesvol aangemaakt als gedeeld kanaal."
    }
    catch {
        Write-Host "Er is een fout opgetreden bij het aanmaken van kanaal '$channel': $_"
    }
}