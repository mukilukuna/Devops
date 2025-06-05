# Script: SCR_APP_Uninstall.ps1
# Purpose: SCR APP Uninstall
<#
.SYNOPSIS
    PowerShell-script voor Intune om opgegeven applicaties te verwijderen.
.DESCRIPTION
    Dit script verwijdert een opgegeven lijst van applicaties (gebaseerd op DisplayName en Publisher) van een Windows-systeem.
    Het script doorzoekt zowel de 64-bit als 32-bit uninstall-registerlocaties voor elk opgegeven programma.
    Voor elke gevonden toepassing probeert het script een stille deïnstallatie uit te voeren:
      - Indien een QuietUninstallString is gespecificeerd in de registry, wordt deze gebruikt.
      - Als alleen een UninstallString beschikbaar is en de installer is MSI-gebaseerd (msiexec), dan worden de switches "/qn /norestart" toegevoegd voor stille modus.
      - Als het een niet-MSI installer is, wordt het uninstall-commando ongewijzigd uitgevoerd (mogelijk niet stil als de fabrikant geen stille optie voorziet).
    Alle acties en resultaten worden gelogd naar %ProgramData%\Microsoft\IntuneManagementExtension\Logs\UninstallApps.log met tijdstempels.
    Als een uninstall faalt of een foutcode retourneert, wordt dit gelogd en een foutstatus bijgehouden.
    Na het verwerken van alle applicaties geeft het script Exit 1 als er een of meer fouten waren, anders Exit 0.
#>

# Lijst van te verwijderen applicaties (Name en Publisher moeten exact overeenkomen met de weergegeven naam en uitgever in het systeem)
$appsToRemove = @(
    @{ Name = "Advanced Installer 22.5"; Publisher = "Caphyon" },
    @{ Name = "Autodesk Identity Manager"; Publisher = "Autodesk" },
    @{ Name = "Autodesk CER"; Publisher = "Autodesk Inc." }
    # Voeg hier zo nodig extra applicaties toe...
)

# Pad naar logbestand (wordt aangemaakt als het niet bestaat)
$logPath = Join-Path -Path $env:ProgramData -ChildPath "Microsoft\IntuneManagementExtension\Logs\UninstallApps.log"

# Zorg dat de logdirectory bestaat
if (-not (Test-Path -Path (Split-Path $logPath))) {
    New-Item -Path (Split-Path $logPath) -ItemType Directory -Force | Out-Null
}

# Logging-functie voor het toevoegen van tijdgestempelde berichten aan het logbestand
function Write-Log {
    param (
        [string]$Message,
        [string]$Level = "INFO"
    )
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $entry = "$timestamp [$Level] $Message"
    # Schrijf naar logbestand (UTF8 encoding)
    $entry | Out-File -FilePath $logPath -Append -Encoding utf8
    # Schrijf ook naar standaardoutput (voor directe feedback bij interactief draaien)
    Write-Output $entry
}

Write-Log "=== Intune Uninstall Script gestart ==="

# Variabele om fouten bij te houden
$uninstallError = $false

# Te controleren registry-paden voor geïnstalleerde software (64-bit en 32-bit)
$registryPaths = @(
    "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall",
    "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall"
)

foreach ($app in $appsToRemove) {
    $appName = $app.Name
    $appPublisher = $app.Publisher
    Write-Log "Zoeken naar '$($appName)' van uitgever '$($appPublisher)' in de registry..."

    # Zoek alle overeenkomstige uninstall-sleutels in beide registry-paden
    $foundEntries = @()
    foreach ($regPath in $registryPaths) {
        try {
            $entries = Get-ItemProperty -Path "$regPath\*" -ErrorAction SilentlyContinue |
            Where-Object { $_.DisplayName -eq $appName -and $_.Publisher -eq $appPublisher }
            if ($entries) {
                $foundEntries += $entries
            }
        }
        catch {
            Write-Log "Kon registry-pad $regPath niet uitlezen: $($_.Exception.Message)" "ERROR"
        }
    }

    if (-not $foundEntries -or $foundEntries.Count -eq 0) {
        Write-Log "Applicatie '$appName' (uitgever '$appPublisher') niet gevonden. Overslaan." "WARN"
        continue
    }

    foreach ($entry in $foundEntries) {
        $displayName = $entry.DisplayName
        $uninstallString = $entry.UninstallString
        $quietUninstallString = $entry.QuietUninstallString

        if ([string]::IsNullOrEmpty($uninstallString) -and [string]::IsNullOrEmpty($quietUninstallString)) {
            Write-Log "Geen uninstall-commando gevonden voor '$displayName'. Overslaan." "ERROR"
            $uninstallError = $true
            continue
        }

        # Bepaal het juiste uninstall-commando
        $commandToRun = $null
        if ($quietUninstallString) {
            Write-Log "QuietUninstallString gevonden voor '$displayName'. Gebruik stille deïnstallatie."
            $commandToRun = $quietUninstallString
        }
        elseif ($uninstallString) {
            Write-Log "Geen QuietUninstallString voor '$displayName'. Gebruik UninstallString."
            $commandToRun = $uninstallString
            # Controleer of het uninstall-commando een MSI betreft (msiexec)
            if ($commandToRun -match '(?i)msiexec') {
                # MSI-gebaseerde installer gedetecteerd
                if ($commandToRun -match '{[0-9A-Fa-f-]{36}}') {
                    $productCode = $matches[0]
                    Write-Log "MSI-productcode $productCode gedetecteerd voor '$displayName'. Voeg stille parameters toe."
                    # Gebruik msiexec met stille opties voor deze productcode
                    $commandToRun = "msiexec.exe /x $productCode /qn /norestart"
                }
                else {
                    Write-Log "MSI-commando gedetecteerd voor '$displayName', geen productcode kunnen bepalen. Voeg /qn toe."
                    if ($commandToRun -notmatch '/qn') {
                        $commandToRun += " /qn /norestart"
                    }
                }
            }
            else {
                Write-Log "Uninstall-commando voor '$displayName' is geen MSI. Voer ongewijzigd uit."
            }
        }

        # Als er geen uitvoerbaar commando bepaald kon worden (zeer onwaarschijnlijk), sla over
        if ([string]::IsNullOrEmpty($commandToRun)) {
            Write-Log "Geen uitvoerbaar uninstall-commando voor '$displayName'. Overslaan." "ERROR"
            $uninstallError = $true
            continue
        }

        # Splits het commando in exe-pad en argumenten voor Start-Process
        $exePath = $null
        $arguments = $null
        if ($commandToRun.StartsWith('"')) {
            # Het uitvoerbaar bestand staat tussen aanhalingstekens
            $closingQuoteIndex = $commandToRun.IndexOf('"', 1)
            if ($closingQuoteIndex -gt 0) {
                $exePath = $commandToRun.Substring(1, $closingQuoteIndex - 1)
                $arguments = $commandToRun.Substring($closingQuoteIndex + 1).TrimStart()
            }
            else {
                # Onwaarschijnlijk geval: geen sluitende quote gevonden
                $exePath = $commandToRun
            }
        }
        else {
            # Geen aanhalingstekens aan het begin, splits op de eerste spatie
            $parts = $commandToRun -split ' ', 2
            $exePath = $parts[0]
            if ($parts.Count -gt 1) {
                $arguments = $parts[1]
            }
        }

        if ($arguments) {
            Write-Log "Start uninstall: $exePath $arguments"
        }
        else {
            Write-Log "Start uninstall: $exePath"
        }

        # Voer het uninstall-commando uit en wacht tot het proces eindigt
        try {
            $proc = Start-Process -FilePath $exePath -ArgumentList $arguments -Wait -PassThru
            $exitCode = $proc.ExitCode
            if ($exitCode -ne 0) {
                Write-Log "Uninstall voor '$displayName' voltooid met exitcode $exitCode." "ERROR"
                $uninstallError = $true
            }
            else {
                Write-Log "Uninstall voor '$displayName' succesvol afgerond (exitcode 0)."
            }
        }
        catch {
            Write-Log "Fout tijdens uitvoeren van uninstall voor '$displayName': $($_.Exception.Message)" "ERROR"
            $uninstallError = $true
        }
    }
}

if ($uninstallError) {
    Write-Log "Eén of meer uninstall-acties zijn afgerond met fouten."
    Exit 1
}
else {
    Write-Log "Alle opgegeven applicaties zijn succesvol verwijderd."
    Exit 0
}
