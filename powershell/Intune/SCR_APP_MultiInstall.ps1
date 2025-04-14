# Zet foutafhandeling zodat niet-terminerende fouten ook worden opgevangen in try/catch
$ErrorActionPreference = 'Stop'

# Pad naar logbestand (wordt aangemaakt als het niet bestaat)
$logPath = Join-Path -Path $env:ProgramData -ChildPath "Microsoft\IntuneManagementExtension\Logs\MultiInstallApps.log"

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

Write-Log "Starting Intune multi-install script..."

# Functie om een applicatie stil te installeren
function Install-Application {
    param (
        [string]$filePath
    )

    if (Test-Path -Path $filePath) {
        Write-Log "Bezig met installeren: $filePath"
        try {
            $process = Start-Process -FilePath $filePath -ArgumentList "/s", "/v`"REBOOT=ReallySuppress /qn /l*v `"$logPath`"`"" -Wait -PassThru -ErrorAction Stop
            if ($process.ExitCode -ne 0) {
                throw "Installer exited with code $($process.ExitCode)"
            }
            Write-Log "Installatie voltooid: $filePath"
            return $true
        }
        catch {
            Write-Log "FOUT bij installatie van $filePath - $($_.Exception.Message)"
            return $false
        }
    }
    else {
        Write-Log "Bestand niet gevonden: $filePath"
        return $false
    }
}



catch {}

# Lijst van applicaties en bijbehorende registersleutels
$applications = @(
    @{ Path = "$PSScriptRoot\CR Integration\SAP Business One Crystal Report Integration Package.exe" },
    @{ Path = "$PSScriptRoot\Crystal Server Integration\BOERuntime_x64.exe" },
    @{ Path = "$PSScriptRoot\Client.x64\setup.exe" }
)

$anyError = $false

# Installeer applicaties indien de voorwaarden correct zijn
foreach ($app in $applications) {
    if (-not ($app.ContainsKey('InstallCondition') -and !$(& $app.InstallCondition))) {
        Write-Log "Installatie wordt gestart voor: $($app.Path)"
        if (-not (Install-Application -filePath $app.Path)) {
            $anyError = $true
        }
    }
    else {
        Write-Log "Applicatie wordt overgeslagen: $($app.Path) omdat de installatievoorwaarde niet is voldaan."
    }
}

if ($anyError) {
    Write-Log "Een of meer installaties zijn mislukt. Script eindigt met exitcode 1."
    exit 1
}
else {
    Write-Log "Alle installaties succesvol afgerond. Script eindigt met exitcode 0."
    exit 0
}