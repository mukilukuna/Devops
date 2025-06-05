# Script: DET_BENEDEN_IP.ps1
# Purpose: DET BENEDEN IP
$printerName = "PRT_KYOCERA_BENEDEN"
$specificPort = "10.0.10.246"


$printers = Get-WmiObject -Query "Select * From Win32_Printer"


$printerFound = $false

foreach ($printer in $printers) {
    if ($printer.Name -eq $printerName) {
        $printerFound = $true
        if ($printer.PortName -eq "TCPPort:$specificPort") {
            Write-Host "Printer $printerName is verbonden met IP-poort $specificPort"
            exit 0
        } else {
            Write-Host "Printer $printerName is niet verbonden met IP-poort $specificPort"
            exit 1
        }
    }
}

if (-not $printerFound) {
    Write-Host "Printer $printerName niet gevonden."
    exit 0
}