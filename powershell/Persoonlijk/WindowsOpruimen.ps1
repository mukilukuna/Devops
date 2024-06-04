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

if ($runChecks -eq "Ja") {
    # Start systeemcomponent opschoning.
    Write-Host "Systeemcomponent opschonen..."
    DISM.exe /Online /Cleanup-Image /StartComponentCleanup /ResetBase /scanhealth /restorehealth
    
    # Systeembestanden controleren en herstellen.
    Write-Host "Systeembestanden controleren en herstellen..."
    sfc /scannow

    # Schijfcontrole.
    Write-Host "Schijfcontrole..."
    chkdsk C: /scan

    Write-Host "Controleer het CBS.log bestand voor sfc details en het Event Viewer voor chkdsk en DISM logs."
}
else {
    Write-Host "Systeemchecks overgeslagen."
}

# Vraag gebruiker of updates uitgevoerd moeten worden.
$runUpdates = Read-Host "Windows updates uitvoeren? (Ja/Nee)"

if ($runUpdates -eq "Ja") {
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

# Vraag gebruiker of tijdelijke bestanden opgeruimd moeten worden.
$runTempCleanup = Read-Host "Tijdelijke bestanden opruimen (Temp, Prefetch)? (Ja/Nee)"

if ($runTempCleanup -eq "Ja") {
    # Verwijder tijdelijke bestanden.
    Write-Host "Tijdelijke bestanden worden verwijderd..."
    Remove-Item -Path "C:\Windows\Temp\*" -Force -Recurse
    Remove-Item -Path "C:\Users\$env:USERNAME\AppData\Local\Temp\*" -Force -Recurse
    Remove-Item -Path "C:\Windows\Prefetch\*" -Force -Recurse

    # Gebruik Disk Cleanup voor aanvullende opschoning.
    Write-Host "Disk Cleanup wordt uitgevoerd..."
    Start-Process -FilePath "cleanmgr.exe" -ArgumentList "/sagerun:1" -Wait

    Write-Host "Tijdelijke bestanden zijn verwijderd."
}
else {
    Write-Host "Opruimen van tijdelijke bestanden overgeslagen."
}

# Vraag gebruiker of Windows Update Cleanup uitgevoerd moet worden.
$runWUCleanup = Read-Host "Windows Update Cleanup uitvoeren? (Ja/Nee)"

if ($runWUCleanup -eq "Ja") {
    # Opruimen van Windows Update-bestanden.
    Write-Host "Windows Update-bestanden worden opgeruimd..."
    Dism.exe /Online /Cleanup-Image /StartComponentCleanup /ResetBase
    Dism.exe /Online /Cleanup-Image /SPSuperseded

    Write-Host "Windows Update-bestanden zijn opgeruimd."
}
else {
    Write-Host "Windows Update Cleanup overgeslagen."
}

Write-Host "Alle taken zijn voltooid."
