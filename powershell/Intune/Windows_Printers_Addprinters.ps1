# Script: Windows_Printers_Addprinters.ps1
# Purpose: Windows Printers Addprinters
$ErrorActionPreference = 'SilentlyContinue'

Add-printerport -Name "TCPPort:10.8.10.51" -PrinterHostAddress "10.8.10.51"
Add-printerport -Name "TCPPort:10.8.10.53" -PrinterHostAddress "10.8.10.53"
Add-printerport -Name "TCPPort:10.8.10.54" -PrinterHostAddress "10.8.10.54"
Add-printerport -Name "TCPPort:10.8.10.55" -PrinterHostAddress "10.8.10.55"
Add-printerport -Name "TCPPort:10.8.10.57" -PrinterHostAddress "10.8.10.57"

Add-PrinterDriver -Name "RICOH MP C3004 PCL 5c"
Add-PrinterDriver -Name "RICOH MP C3004ex PCL 5c"
Add-PrinterDriver -Name "Dell B2375dnf Mono MFP XPS"

Add-Printer -Name "1e - Directie" -PortName "TCPPort:10.8.10.51" -DriverName "RICOH MP C3004 PCL 5c"
Add-Printer -Name "BG - Kamer Frank" -PortName "TCPPort:10.8.10.53" -DriverName "RICOH MP C3004ex PCL 5c"
Add-Printer -Name "BG - P&O" -PortName "TCPPort:10.8.10.54" -DriverName "RICOH MP C3004 PCL 5c"
Add-Printer -Name "1e - Managers" -PortName "TCPPort:10.8.10.55" -DriverName "RICOH MP C3004ex PCL 5c"
Add-Printer -Name "BG - Dell ZW" -PortName "TCPPort:10.8.10.57" -DriverName "Dell B2375dnf Mono MFP XPS"


