# Naam van de printerdriver die gecontroleerd moet worden
$printerDriverName = "KONICA MINOLTA C754SeriesPCL"

# Haal de lijst van geïnstalleerde printerdrivers op
$printerDrivers = Get-PrinterDriver

# Controleer of de specifieke printerdriver bestaat
$driverExists = $printerDrivers.Name -contains $printerDriverName

# Geef de juiste exit code gebaseerd op de aanwezigheid van de driver
if ($driverExists) {
    Write-Output "De printerdriver '$printerDriverName' bestaat."
    exit 0
} else {
    Write-Output "De printerdriver '$printerDriverName' bestaat niet."
    exit 1
}
