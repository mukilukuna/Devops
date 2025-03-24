# Paden om te controleren en eventueel te verwijderen
$publicDesktopPath = "$env:PUBLIC\Desktop"
$remoteAppPath = "C:\Program Files\REMOTEAPP"

# Bestanden om te verwijderen van de publieke desktop
$files = @("Kantoor-Belgie.rdp", "Kantoor-Nederland.rdp")

# Controleer en verwijder elk RDP-bestand indien aanwezig
foreach ($file in $files) {
    $filePath = Join-Path -Path $publicDesktopPath -ChildPath $file
    if (Test-Path -Path $filePath) {
        # Verwijder het RDP-bestand
        Remove-Item -Path $filePath -Force
        Write-Host "Bestand verwijderd: $filePath"
    }
}

# Controleer en verwijder de REMOTEAPP-map indien aanwezig
if (Test-Path -Path $remoteAppPath) {
    Remove-Item -Path $remoteAppPath -Recurse -Force
    Write-Host "Map en inhoud verwijderd: $remoteAppPath"
}

Write-Host "Remediatie voltooid."
