<# 
    Dit is een tweeledig script: 
    1. Zorg eerst dat HP Image Assistant (HPIA) is geïnstalleerd op het systeem.
    2. Dit script wordt uitgerold als tweede Intune-app (afhankelijk van de HPIA-installatie).

    Detectie: Bestaan van de map C:\HPIAReport, zodat het script slechts eenmaal wordt uitgevoerd.
#>

# Pad naar logbestand (Intune Management Extension logging)
$logPath = Join-Path -Path $env:ProgramData -ChildPath "Microsoft\IntuneManagementExtension\Logs\InstallApps.log"

# Zorg dat de logdirectory bestaat
if (-not (Test-Path -Path (Split-Path $logPath))) {
    New-Item -Path (Split-Path $logPath) -ItemType Directory -Force | Out-Null
}

# Loggingfunctie
function Write-Log {
    param (
        [string]$Message,
        [string]$Level = "INFO"
    )
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $entry = "$timestamp [$Level] $Message"
    $entry | Out-File -FilePath $logPath -Append -Encoding utf8
    Write-Output $entry
}

Write-Log "Start van HP Image Assistant installatiescript..."

# Instellingen
$HPIAPath      = "C:\hpia\HPImageAssistant.exe"
$ReportFolder  = "C:\HPIAReport"
$SoftpaqFolder = "C:\HPIASoftpaqs"

# Mappen aanmaken indien ze nog niet bestaan
foreach ($folder in @($ReportFolder, $SoftpaqFolder)) {
    if (-not (Test-Path -Path $folder)) {
        try {
            New-Item -ItemType Directory -Path $folder -Force | Out-Null
            Write-Log "Map aangemaakt: $folder"
        } catch {
            Write-Log "Kan map niet aanmaken: $folder - $($_.Exception.Message)" "ERROR"
        }
    }
}

# Command-line parameters voor HPIA
$arguments = "/Operation:Analyze /Category:All /Selection:All /Action:Install /Silent /ReportFolder:`"$ReportFolder`" /SoftpaqDownloadFolder:`"$SoftpaqFolder`""

# Start HPIA als deze aanwezig is
if (Test-Path -Path $HPIAPath) {
    try {
        Write-Log "Start HPIA met parameters: $arguments"
        $process = Start-Process -FilePath $HPIAPath -ArgumentList $arguments -Wait -PassThru -WindowStyle Hidden
        Write-Log "HPIA is afgesloten met exitcode: $($process.ExitCode)"
    } catch {
        Write-Log "Fout bij het uitvoeren van HPIA: $($_.Exception.Message)" "ERROR"
    }
} else {
    Write-Log "HPIA niet gevonden op: $HPIAPath" "ERROR"
}

Write-Log "HP Image Assistant installatiescript afgerond."
