# Definieer een lijst met te controleren registersleutels
$registryPaths = @(
    "HKLM:\SYSTEM\CurrentControlSet\Control\Print\Printers\XTR-PR009",
    "HKLM:\SYSTEM\CurrentControlSet\Control\Print\Printers\XTR-PR007",
    "HKLM:\SYSTEM\CurrentControlSet\Control\Print\Printers\XTR-PR004",
    "HKLM:\SYSTEM\CurrentControlSet\Control\Print\Printers\XTR-PR003",
    "HKLM:\SYSTEM\CurrentControlSet\Control\Print\Printers\XTR-PR002"
)

# Controleer of de registersleutels bestaan
foreach ($path in $registryPaths) {
    if (Test-Path $path) {
        Write-Host "Register bestaat: $path"
        exit 1
    }
}

# Als geen van de sleutels bestaat
Write-Host "Geen van de registersleutels bestaat."
exit 0
