# Script: SCR_Printers_Export.ps1
# Purpose: SCR Printers Export
<#
Printer instellingen exporteren door middel van PrintBrm.exe 
Printer instellingen zoals ip adres, driver, poorten en instellingen worden opgeslagen in een .printerexport bestand
vervolgens importeren met een andere script
Gemaakt door: Muki & ChatGPT
Datum: 2025-2-26
#>
$BackupPath = "$env:windir\Temp\PrintersBackup.printerexport"

# Maak een back-up van alle printerinstellingen
Start-Process -FilePath "C:\Windows\System32\spool\tools\PrintBrm.exe" -ArgumentList "/B /F $BackupPath /O FORCE" -Wait -NoNewWindow

Write-Host "Printerinstellingen zijn opgeslagen in $BackupPath"
