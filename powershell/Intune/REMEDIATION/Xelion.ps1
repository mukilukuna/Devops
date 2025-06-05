# Script: Xelion.ps1
# Purpose: Xelion
    # Definieer de naam van het pakket
$packageName = "XelionWindowsDesktop"

# Controleer of het appx-pakket is geïnstalleerd
$package = Get-AppxPackage -Name $packageName -ErrorAction SilentlyContinue

if ($package) {
    exit 1
}
else {
    exit 0
}