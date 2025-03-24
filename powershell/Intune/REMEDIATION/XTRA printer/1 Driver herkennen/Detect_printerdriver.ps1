# Naam van het printerstuurprogramma dat gecontroleerd moet worden
$printerDriverName = "KONICA MINOLTA C754SeriesPCL"

# Vraag de lijst met geïnstalleerde printers op
$printers = Get-PrinterDriver

# Controleer of het stuurprogramma geïnstalleerd is
$driverInstalled = $printers.Name -contains $printerDriverName

if ($driverInstalled) {
    
    Write-Host "Het printerstuurprogramma '$printerDriverName' is geïnstalleerd."
    
    exit 0
} else {
    
    Write-Host "Het printerstuurprogramma '$printerDriverName' is niet geïnstalleerd."
   
    exit 1
}