# Checks if 7-Zip is installed and if the version is 23.01 or lower.
# Looks in the registry at a specific path for the 7-Zip uninstall key.
# Checks if the key exists, then checks the display name to verify it is 7-Zip.
# Gets the version number and compares it to 23.01.
# Writes output indicating if 7-Zip was found and the version.
# Exits with code 1 if version <= 23.01, else exits with code 0.
# Checks if 7-Zip version 23.01 or lower is installed by querying the registry.
# Exits with code 1 if found, 0 otherwise.
# Sleutelpad in de registry
$registryPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{23170F69-40C1-2702-2201-000001000000}"

# Controleren of de sleutel bestaat
if (Test-Path $registryPath) {
    # Sleutel bestaat, controleer nu de waarde
    $value = Get-ItemPropertyValue -Path $registryPath -Name "DisplayName" -ErrorAction SilentlyContinue

    if ($value -and $value -like "*7-zip*") {
        # Haal de versie op en controleer deze
        $version = Get-ItemPropertyValue -Path $registryPath -Name "DisplayVersion" -ErrorAction SilentlyContinue
        if ($version -and ([version]$version -le [version]"23.01")) {
            Write-Output "7-zip gevonden met versie 23.01 of lager."
            exit 1
        }
        else {
            Write-Output "7-zip gevonden, maar met een hogere versie dan 23.01."
            exit 0
        }
    }
    else {
        Write-Output "7-zip niet gevonden in de opgegeven registry sleutel."
        exit 0
    }
}
else {
    # Sleutel bestaat niet
    Write-Output "De opgegeven registry sleutel bestaat niet."
    exit 0
}
