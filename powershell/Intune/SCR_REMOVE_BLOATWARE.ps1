# ====================================================================
# Script: Remove-Bloatware-Appx.ps1
# Doel  : Verwijdert ongewenste ingebouwde Windows 10/11 apps (Appx) 
#         system-wide (voor alle gebruikers) en uit de provisioned apps.
# Auteur: (Naam/Auteur kan hier)
# Datum : (bijv. 2025-03-31)
# ====================================================================

# Lijst met exacte Appx pakketnamen die verwijderd moeten worden.
# Voeg hier de ongewenste Appx-package namen toe (Exacte naam, geen wildcards).
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process -Force
$PackagesToRemove = @(
    "Microsoft.Getstarted",
    "Microsoft.Xbox.TCUI",
    "Microsoft.XboxGameOverlay",
    "Microsoft.XboxIdentityProvider",
    "Microsoft.XboxSpeechToTextOverlay",
    "Microsoft.People",
    "Microsoft.XboxGamingOverlay",
    "Microsoft.MicrosoftSolitaireCollection",
    "Microsoft.MicrosoftOfficeHub",
    "Microsoft.GamingApp",
    "Microsoft.WindowsFeedbackHub",
    "Microsoft.549981C3F5F10",
    "Microsoft.GetHelp"
)

# Pad naar logbestand (Intune Management Extension Logs directory)
$LogPath = "$env:ProgramData\Microsoft\IntuneManagementExtension\Logs\RemoveAppx.log"

# Zorg dat de log-map bestaat
try {
    $logDir = Split-Path -Path $LogPath
    if (!(Test-Path -Path $logDir)) {
        New-Item -Path $logDir -ItemType Directory -Force | Out-Null
    }
}
catch {
    # Als het aanmaken van de log-directory mislukt, gaan we desondanks door.
    # (Het script zal dan mogelijk niet kunnen loggen naar bestand.)
}

# Hulpfunctie voor het schrijven van logregels met tijdstempel
function Write-Log {
    param(
        [string]$Message,
        [switch]$IsError    # Gebruik -IsError voor foutmelding
    )
    try {
        $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        $type = if ($IsError.IsPresent) { "ERROR" } else { "INFO" }
        $entry = "$timestamp [$type] $Message"
        Add-Content -Path $LogPath -Value $entry -Encoding UTF8
    }
    catch {
        Write-Host "$timestamp [ERROR] Kon niet naar log schrijven: $Message"
    }
}


# Start van het script (log startpunt)
Write-Log "=== Start Remove Bloatware Script ==="

# Loop door elk opgegeven pakket in de lijst
foreach ($pkgName in $PackagesToRemove) {
    Write-Log "Verwerken pakket '$pkgName'..."

    # 1. Verwijder geïnstalleerde Appx-package(s) voor alle gebruikers (indien aanwezig)
    $foundPackages = $null
    try {
        # Zoek alle geïnstalleerde packages (All Users) met exact deze naam
        $foundPackages = Get-AppxPackage -AllUsers | Where-Object { $_.Name -eq $pkgName }
    }
    catch {
        Write-Log "Kon geïnstalleerde packages voor $pkgName niet opvragen: $($_.Exception.Message)" -Error
        continue  # Ga door naar het volgende pakket in de lijst
    }

    if (!$foundPackages) {
        Write-Log "Geen geïnstalleerde Appx-package gevonden met naam $pkgName (overslaan)."
    }
    else {
        foreach ($appx in $foundPackages) {
            try {
                # Probeer de gevonden Appx-package te verwijderen voor alle gebruikers
                Remove-AppxPackage -Package $appx.PackageFullName -AllUsers -ErrorAction Stop
                Write-Log "Appx-package verwijderd: $pkgName (PackageFullName: $($appx.PackageFullName))."
            }
            catch {
                Write-Log "Fout bij verwijderen van $pkgName (PackageFullName: $($appx.PackageFullName)): $($_.Exception.Message)" -Error
            }
        }
    }

    # 2. Verwijder provisioned package uit het systeem (indien aanwezig)
    $provPackage = $null
    try {
        # Zoek de provisioned Windows-image packages (Online) met deze DisplayName
        $provPackage = Get-AppxProvisionedPackage -Online | Where-Object { $_.DisplayName -eq $pkgName }
    }
    catch {
        Write-Log "Kon provisioned packages voor $pkgName niet opvragen: $($_.Exception.Message)" -Error
        continue
    }

    if (!$provPackage) {
        Write-Log "Geen provisioned package gevonden met naam $pkgName (overslaan)."
    }
    else {
        foreach ($prov in $provPackage) {
            try {
                # Verwijder de provisioned package van het systeem
                Remove-AppxProvisionedPackage -Online -PackageName $prov.PackageName -ErrorAction Stop
                Write-Log "Provisioned package verwijderd: $pkgName (PackageName: $($prov.PackageName))."
            }
            catch {
                Write-Log "Fout bij verwijderen van provisioned $pkgName (PackageName: $($prov.PackageName)): $($_.Exception.Message)" -Error
            }
        }
    }
}

# Einde van het script (log eindpunt)
Write-Log "=== Einde Remove Bloatware Script ==="