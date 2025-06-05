# Script: SCR_Printers_Import.ps1
# Purpose: SCR Printers Import
<# een back-up van alle printerinstellingen importeren met behulp van PrintBrm.exe
Printerinstellingen zoals ip adres, driver, poorten en instellingen worden opgeslagen in een .printerexport bestand
vervolgens importeren met een andere script
Gemaakt door: Muki & ChatGPT
Datum: 2025-2-26
#>

# Definieer het pad naar de logmap en logbestand
$logDir = "$env:windir\Temp"
$logFile = "$logDir\printer_import.log"

# Controleer of de logmap bestaat; zo niet, maak deze aan
if (-not (Test-Path -Path $logDir)) {
    New-Item -Path $logDir -ItemType Directory | Out-Null
}

# Functie om logs te schrijven
function Write-Log {
    param (
        [string]$Message
    )
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "$timestamp - $Message" | Out-File -Append -FilePath $logFile
}

Write-Log "==== Start Printer Installatie ===="

# Definieer pad naar printer backup bestand
$BackupPath = "$PSScriptRoot\PrintersBackup.printerexport"

# Controleer of het backup bestand aanwezig is
if (-not (Test-Path -Path $BackupPath)) {
    Write-Log "FOUT: Printer backup bestand niet gevonden. Installatie gestopt."
    Exit 1
}

Write-Log "Printer backup bestand gevonden. Start import..."

# Importeer printerinstellingen
try {
    Start-Process -FilePath "$env:windir\System32\spool\tools\PrintBrm.exe" -ArgumentList "/R /F $BackupPath /O FORCE" -Wait -NoNewWindow
    Write-Log "Printer instellingen succesvol geïmporteerd."
} catch {
    Write-Log "FOUT: Kon printer instellingen niet importeren. $_"
    Exit 1
}

Write-Log "==== Printer Installatie Voltooid ===="
