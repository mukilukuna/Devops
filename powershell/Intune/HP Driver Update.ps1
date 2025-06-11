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

Write-Log "Starting HP Image Assistant install script..."

# Instellingen
$HPIAPath = "C:\Program Files\HPImageAssistant\HPImageAssistant.exe"
$ReportFolder = "C:\HPIAReport"
$SoftpaqFolder = "C:\HPIASoftpaqs"

# Mappen aanmaken indien nodig
foreach ($folder in @($ReportFolder, $SoftpaqFolder)) {
    if (-not (Test-Path -Path $folder)) {
        try {
            New-Item -ItemType Directory -Path $folder -Force | Out-Null
            Write-Log "Created folder: $folder"
        } catch {
            Write-Log "Failed to create folder: $folder - $($_.Exception.Message)" "ERROR"
        }
    }
}

# Commandline parameters
$arguments = "/Operation:Analyze /Category:All /Selection:All /Action:Install /Silent /ReportFolder:`"$ReportFolder`" /SoftpaqDownloadFolder:`"$SoftpaqFolder`""

# Start HPIA
if (Test-Path -Path $HPIAPath) {
    try {
        Write-Log "Launching HPIA with arguments: $arguments"
        $process = Start-Process -FilePath $HPIAPath -ArgumentList $arguments -Wait -PassThru -WindowStyle Hidden
        Write-Log "HPIA exited with code: $($process.ExitCode)"
    } catch {
        Write-Log "Error running HPIA: $($_.Exception.Message)" "ERROR"
    }
} else {
    Write-Log "HPIA executable not found at $HPIAPath" "ERROR"
}

Write-Log "HP Image Assistant install script finished."
