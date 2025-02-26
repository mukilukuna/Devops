# Definieer het pad naar de logmap en logbestand
$logDir = "C:\Temp"
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
    Start-Process -FilePath "C:\Windows\System32\spool\tools\PrintBrm.exe" -ArgumentList "/R /F $BackupPath /O FORCE" -Wait -NoNewWindow
    Write-Log "Printer instellingen succesvol geïmporteerd."
} catch {
    Write-Log "FOUT: Kon printer instellingen niet importeren. $_"
    Exit 1
}

Write-Log "==== Printer Installatie Voltooid ===="
