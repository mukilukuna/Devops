# Script: SCR_APP_DetectApp.ps1
# Purpose: SCR APP DetectApp
<#
.SYNOPSIS
    PowerShell Detection Script voor Intune - controleert of een specifieke applicatie is geïnstalleerd.

.DESCRIPTION
    Dit detection script controleert of een applicatie met een specifieke naam én uitgever (Publisher)
    aanwezig is in de registry op een Windows-device. Dit werkt versie-onafhankelijk.

    Er wordt gezocht in beide registry-locaties:
    - HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall
    - HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall

    Indien de applicatie is gevonden, eindigt het script met exitcode 0.
    Indien niet gevonden, of bij een fout, eindigt het script met exitcode 1.
    Dit gedrag is standaard voor gebruik als Detection Rule in Intune.

    De applicatiegegevens (naam en publisher) kunnen eenvoudig worden aangepast of uitgebreid met meerdere controles.
#>

# Applicatiegegevens voor detectie
$appName = "One Integrate Cara"
$publisher = "Vodafone NL"

# Registry-paden voor 64-bit en 32-bit uninstall entries
$registryPaths = @(
    "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*",
    "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*"
)

try {
    # Doorzoek alle opgegeven registry-paden
    $installed = Get-ItemProperty $registryPaths -ErrorAction SilentlyContinue | Where-Object {
        $_.DisplayName -eq $appName -and $_.Publisher -eq $publisher
    }

    if ($installed) {
        Write-Host "$appName is gedetecteerd."
        exit 0  # Applicatie gevonden, dus detection is geslaagd
    }

    exit 1  # Niet gevonden
}
catch {
    Write-Error "Fout bij het uitvoeren van de detection: $_"
    exit 1
}
