# Functie om taal- en regio-instellingen te controleren en aan te passen
function Set-DesiredLanguageAndRegion {
    # Controleer de huidige taal- en regio-instellingen
    $currentLanguage = (Get-WinSystemLocale).Name
    $currentRegion = (Get-WinHomeLocation).Name

    # Als taal niet ingesteld is op Nederlands (Nederland) of regio niet ingesteld op Nederland
    if ($currentLanguage -ne "nl-NL" -or $currentRegion -ne "Netherlands") {
        Write-Host "Taal- en/of regio-instellingen worden aangepast..."
        # Installeer taalpakket en stel regio-instellingen in
        Install-Language nl-NL
        Set-TimeZone -Id "W. Europe Standard Time"
        Set-WinHomeLocation -GeoId 0xb0
        Set-Culture -CultureInfo nl-NL
        Copy-UserInternationalSettingsToSystem -WelcomeScreen $True -NewUser $True
        Write-Host "Taal- en regio-instellingen zijn bijgewerkt."
    }
    else {
        Write-Host "Taal- en regio-instellingen zijn al correct ingesteld."
    }
}

# Roep de functie aan om taal- en regio-instellingen te controleren en aan te passen
Set-DesiredLanguageAndRegion

# Functie om Execution Policy te controleren en aan te passen
function Set-DesiredExecutionPolicy {
    param (
        [string]$PolicyScope,
        [string]$DesiredPolicy
    )

    # Speciale behandeling voor MachinePolicy en UserPolicy, die niet via script gewijzigd kunnen worden als ze ingesteld zijn via Group Policy.
    if ($PolicyScope -eq "MachinePolicy" -or $PolicyScope -eq "UserPolicy") {
        Write-Host "Waarschuwing: $PolicyScope kan alleen via Group Policy gewijzigd worden en zal niet door dit script worden aangepast."
        return
    }

    $currentPolicy = Get-ExecutionPolicy -Scope $PolicyScope
    if ($currentPolicy -ne $DesiredPolicy) {
        Set-ExecutionPolicy -ExecutionPolicy $DesiredPolicy -Scope $PolicyScope -Force
    }
}

# Stel de Execution Policies in volgens de gewenste waarden voor alle scopes, met uitzondering van MachinePolicy en UserPolicy
$desiredPolicies = @{
    "CurrentUser"  = "RemoteSigned";
    "LocalMachine" = "RemoteSigned";
    "Process"      = "Undefined"
}

foreach ($policyScope in $desiredPolicies.Keys) {
    Set-DesiredExecutionPolicy -PolicyScope $policyScope -DesiredPolicy $desiredPolicies[$policyScope]
}

# Vraag gebruiker of systeemchecks uitgevoerd moeten worden.
$runChecks = Read-Host "Systeemchecks uitvoeren (sfc, DISM, chkdsk)? (Ja/Nee)"

if ($runChecks.ToLower() -eq "ja") {
    # Start systeemcomponent opschoning.
    DISM.exe /Online /Cleanup-Image /StartComponentCleanup
    DISM.exe /Online /Cleanup-Image /SPSuperseded

    Write-Host "Controleer het CBS.log bestand voor sfc details en het Event Viewer voor chkdsk en DISM logs."
}
else {
    Write-Host "Systeemchecks overgeslagen."
}

# Vraag gebruiker of updates uitgevoerd moeten worden.
$runUpdates = Read-Host "Windows updates uitvoeren? (Ja/Nee)"

if ($runUpdates.ToLower() -eq "ja") {
    # Controleer en installeer PSWindowsUpdate module indien nodig.
    if (-not (Get-Module -ListAvailable -Name PSWindowsUpdate)) {
        Install-Module -Name PSWindowsUpdate -Force
    }

    # Windows updates uitvoeren.
    Get-WindowsUpdate -Install -AcceptAll

    # Upgrade alle geïnstalleerde pakketten.
    winget upgrade --all --include-unknown --silent
}
else {
    Write-Host "Updates overgeslagen."
}
