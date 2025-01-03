# Zet de uitvoeringsbeleid tijdelijk op Bypass
try {
    Write-Output "Instellen van de uitvoeringsbeleid naar Bypass..."
    Set-ExecutionPolicy Bypass -Confirm:$false -Scope Process
}
catch {
    Write-Output "Fout bij het instellen van de uitvoeringsbeleid: $_"
    exit 1
}

# Installeer het PSWindowsUpdate-script
try {
    Write-Output "Installeren van PSWindowsUpdate..."
    Install-Script -Name PSWindowsUpdate -Force -Confirm:$false
}
catch {
    Write-Output "Fout bij het installeren van PSWindowsUpdate: $_"
    exit 1
}

# Zoek en installeer beschikbare Windows-updates
try {
    Write-Output "Zoeken en installeren van Windows-updates..."
    Get-WindowsUpdate -AcceptAll -ForceInstall -Install
}
catch {
    Write-Output "Fout bij het verwerken van Windows-updates: $_"
    exit 1
}

# (Optioneel) Updategeschiedenis ophalen en opslaan in een bestand
$UpdateHistoryPath = "C:\Temp\UpdateHistory.txt"
try {
    Write-Output "Updategeschiedenis ophalen..."
    # Installeren van de module indien nodig
    if (-not (Get-Module -Name PUDAdminCenterPrototype -ListAvailable)) {
        Install-Module -Name PUDAdminCenterPrototype -AllowClobber -Force -Confirm:$false
    }
    Import-Module PUDAdminCenterPrototype

    # Geschiedenis ophalen en opslaan
    Get-WuaHistory | Select-Object Result, Product, Date, Title | Out-File -FilePath $UpdateHistoryPath -Force
    Write-Output "Updategeschiedenis opgeslagen in: $UpdateHistoryPath"
}
catch {
    Write-Output "Fout bij het ophalen van updategeschiedenis: $_"
}

Write-Output "Script uitgevoerd met succes."
