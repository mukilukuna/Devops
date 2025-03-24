# Paden om te controleren
$publicDesktopPath = "$env:PUBLIC\Desktop"
$remoteAppPath = "C:\Program Files\REMOTEAPP"

# Bestanden om te zoeken op de publieke desktop
$files = @("Kantoor-Belgie.rdp", "Kantoor-Nederland.rdp")

# Controleer of een van de RDP-bestanden bestaat
$found = $false
foreach ($file in $files) {
    $filePath = Join-Path -Path $publicDesktopPath -ChildPath $file
    if (Test-Path -Path $filePath) {
        $found = $true
        break
    }
}

# Controleer of de REMOTEAPP-map bestaat
if (Test-Path -Path $remoteAppPath) {
    $found = $true
}

# Bepaal de exit code op basis van de aanwezigheid van de bestanden en map
if ($found) {
    # Een van de bestanden of de REMOTEAPP-map bestaat, geef exit code 1
    exit 1
} else {
    # Geen van de bestanden en de REMOTEAPP-map bestaat niet, geef exit code 0
    exit 0
}
