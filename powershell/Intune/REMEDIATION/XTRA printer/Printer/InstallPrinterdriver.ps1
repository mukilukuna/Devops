# Definieer een lijst met te controleren printer namen
$printerNames = @(
    "XTR-PR009",
    "XTR-PR007",
    "XTR-PR004",
    "XTR-PR003",
    "XTR-PR002"
)

# Naam van de printerdriver die bijgewerkt moet worden
$printerDriverName = "KONICA MINOLTA C754SeriesPCL"

# Loop door de lijst en controleer of de printer bestaat in het register
foreach ($printerName in $printerNames) {
    $path = "HKLM:\SYSTEM\CurrentControlSet\Control\Print\Printers\$printerName"
    if (Test-Path $path) {
        Write-Host "Printer $printerName bestaat. De driver wordt nu bijgewerkt."
        
        # Voer het commando uit om de printerdriver bij te werken
        $command = "rundll32 printui.dll,PrintUIEntry /Xs /n `"$printerName`" DriverName `"$printerDriverName`""
        Invoke-Expression $command
        
        exit 0 # Stop het script succesvol na de eerste update
    }
}

# Als geen van de printers bestaat, toon dan een bericht en exit met 1
Write-Host "Geen van de printers bestaat."
exit 1

