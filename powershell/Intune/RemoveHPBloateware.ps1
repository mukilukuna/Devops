<#
.SYNOPSIS
Verwijdert vooraf geïnstalleerde HP-apps, Appx-packages en extra software die vaak meegeleverd wordt met zakelijke HP-devices.

.DESCRIPTION
- Verwijdert een lijst van Appx-packages (voor alle gebruikers)
- Verwijdert klassieke programma's met Get-Package of via WMI (fallback)
- Verwijdert specifieke HP MSI's als laatste fallback
- Logt alle stappen naar een Intune-logbestand op de client

.GEBRUIK
- Te gebruiken als Intune Win32-applicatie
- Controleer of de te verwijderen pakketten overeenkomen met wat op jouw image staat
- Uitvoeren met beheerdersrechten

.AUTEUR
Aangepast door Muki Lukuna
#>

# Stel de uitvoeringspolicy in op 'Bypass' om het uitvoeren van scripts toe te staan
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process -Force

# Pad naar het logbestand
$LogPath = "$env:ProgramData\Microsoft\IntuneManagementExtension\Logs\RemoveAppx.log"

# Zorg ervoor dat de logmap bestaat
$logDir = Split-Path -Path $LogPath
if (!(Test-Path -Path $logDir)) {
    New-Item -Path $logDir -ItemType Directory -Force | Out-Null
}

# Functie om berichten naar het logbestand te schrijven
function Write-Log {
    param (
        [string]$Message
    )
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logMessage = "$timestamp - $Message"
    Add-Content -Path $LogPath -Value $logMessage
    Write-Output $logMessage
}

# Lijsten met te verwijderen pakketten en programma's
$UninstallPackages = @(
    "AD2F1837.HPJumpStarts",
    "AD2F1837.HPPCHardwareDiagnosticsWindows",
    "AD2F1837.HPPowerManager",
    "AD2F1837.HPPrivacySettings",
    "AD2F1837.HPSupportAssistant",
    "AD2F1837.HPSureShieldAI",
    "AD2F1837.HPSystemInformation",
    "AD2F1837.HPQuickDrop",
    "AD2F1837.HPWorkWell",
    "AD2F1837.myHP",
    "AD2F1837.HPDesktopSupportUtilities",
    "AD2F1837.HPQuickTouch",
    "AD2F1837.HPEasyClean"
)

$UninstallPrograms = @(
    "HP Client Security Manager",
    "HP Connection Optimizer",
    "HP Documentation",
    "HP MAC Address Manager",
    "HP Notifications",
    "HP Security Update Service",
    "HP System Default Settings",
    "HP Sure Click",
    "HP Sure Click Security Browser",
    "HP Sure Run",
    "HP Sure Recover",
    "HP Sure Sense",
    "HP Sure Sense Installer",
    "HP Wolf Security",
    "HP Wolf Security Application Support for Sure Sense",
    "HP Wolf Security Application Support for Windows"
)

# Verwijder Appx Provisioned Packages
foreach ($Package in $UninstallPackages) {
    Write-Log "Proberen te verwijderen: $Package"
    try {
        Get-AppxPackage -AllUsers -Name $Package | Remove-AppxPackage -AllUsers -ErrorAction Stop
        Write-Log "Succesvol verwijderd: $Package"
    }
    catch {
        Write-Log "Fout bij verwijderen van $Package $_"
    }
}

# Verwijder geïnstalleerde programma's via Get-Package
foreach ($Program in $UninstallPrograms) {
    Write-Log "Proberen te verwijderen: $Program"
    try {
        $pkg = Get-Package -Name $Program -ErrorAction Stop
        if ($pkg) {
            $pkg | Uninstall-Package -Force -ErrorAction Stop
            Write-Log "Succesvol verwijderd: $Program"
        }
    }
    catch {
        Write-Log "Fout bij verwijderen van $Program via Get-Package: $_"
        Write-Log "Fallback: Proberen te verwijderen via CIM: $Program"
        try {
            $app = Get-CimInstance -ClassName Win32_Product -Filter "Name = '$Program'" -ErrorAction Stop
            if ($app) {
                Invoke-CimMethod -InputObject $app -MethodName Uninstall -ErrorAction Stop
                Write-Log "Succesvol verwijderd via CIM: $Program"
            }
        }
        catch {
            Write-Log "Fout bij verwijderen van $Program via CIM: $_"
        }
    }
}

# Fallback pogingen voor specifieke MSI's van HP Wolf Security
$FallbackMSI = @(
    "{0E2E04B0-9EDD-11EB-B38C-10604B96B11E}",
    "{4DA839F0-72CF-11EC-B247-3863BB3CB5A8}"
)

foreach ($MSI in $FallbackMSI) {
    Write-Log "Proberen te verwijderen via MSI: $MSI"
    try {
        Start-Process "msiexec.exe" -ArgumentList "/x $MSI /qn /norestart" -Wait -ErrorAction Stop
        Write-Log "Succesvol verwijderd via MSI: $MSI"
    }
    catch {
        Write-Log "Fout bij verwijderen via MSI $MSI $_"
    }
}
