<#
Printer instellingen exporteren door middel van PrintBrm.exe 
Printer instellingen zoals ip adres, driver, poorten en instellingen worden opgeslagen in een .printerexport bestand
vervolgens exporteren met een andere script
Gemaakt door: Muki & ChatGPT
Datum: 2025-2-26
#>
$BackupPath = "C:\Temp\PrintersBackup.printerexport"

# Controleer of de directory bestaat
if (!(Test-Path "C:\Temp")) {
    New-Item -Path "C:\Temp" -ItemType Directory -Force
}

# Maak een back-up van alle printerinstellingen
Start-Process -FilePath "C:\Windows\System32\spool\tools\PrintBrm.exe" -ArgumentList "/B /F $BackupPath /O FORCE" -Wait -NoNewWindow

Write-Host "Printerinstellingen zijn opgeslagen in $BackupPath"
