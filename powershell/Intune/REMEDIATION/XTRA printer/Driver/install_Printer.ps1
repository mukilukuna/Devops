# Naam van de printerdriver die toegevoegd moet worden
$printerDriverName = "KONICA MINOLTA C754SeriesPCL"

try {
    # Voeg de printerdriver toe
    Add-PrinterDriver -Name $printerDriverName
    Write-Host "Printerdriver '$printerDriverName' is succesvol toegevoegd."
}
catch {
    Write-Error "Er is een fout opgetreden bij het toevoegen van de printerdriver: $_"
    exit 1
}
