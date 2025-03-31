<# 
.Introductie
Dit PowerShell-script verwijdert opgegeven applicaties op een stille manier via Intune. 
Het script leest de uninstall-instructies uit het Windows register (zowel 64-bit als 32-bit hive) 
en voert deze uit. Logging gebeurt naar %ProgramData%\Microsoft\IntuneManagementExtension\Logs. 
#>

# **Configuratie: te verwijderen applicaties**
# Vul de array $AppsToRemove met één of meerdere applicaties (Name en Publisher moeten matchen 
# met de waarden in het register). Gebruik eventueel wildcards (*) in de naam of publisher.
$AppsToRemove = @(
    @{ Name = "Splashtop for RMM"; Publisher = "Splashtop Inc." },
    @{ Name = "MSP Remote Support by Splashtop"; Publisher = "Splashtop Inc." },
    @{ Name = "Advanced Installer 22.5"; Publisher = "Caphyon" },
    @{ Name = "7-Zip 23.01 (x64 edition)"; Publisher = "Igor Pavlov" },
    @{ Name = "7-Zip 24.09 (x64 edition)"; Publisher = "Igor Pavlov" },
    @{ Name = "Autodesk DWG TrueView 2026 - English"; Publisher = "Autodesk, Inc." },
    @{ Name = "Autodesk CER"; Publisher = "Autodesk, Inc." },
    @{ Name = "Autodesk Identity Manager"; Publisher = "Autodesk, Inc." },
    @{ Name = "Master Packager"; Publisher = "Master Packager" }
    # Voeg hier extra applicaties toe indien nodig, bijvoorbeeld:
    # @{ Name = "Nog een applicatie*"; Publisher = "Naam van uitgever*" }
)

# **Logging-instellingen**
$LogDir = Join-Path $env:ProgramData "Microsoft\IntuneManagementExtension\Logs"
$LogFile = Join-Path $LogDir "UninstallApps.log"

# Zorg dat de log-directory bestaat
try {
    if (-not (Test-Path $LogDir)) {
        New-Item -Path $LogDir -ItemType Directory -Force | Out-Null
    }
    # Logstart met tijdstempel
    "==== Uninstall script gestart op $(Get-Date -Format "yyyy-MM-dd HH:mm:ss") ====" | Out-File -FilePath $LogFile -Append -Encoding utf8
}
catch {
    # Als het niet lukt om naar log te schrijven, gaan we toch verder (fouten worden onderdrukt om script niet te laten stoppen)
}

# Hulpfunctie voor het wegschrijven van logregels met tijdstempel
function Write-Log($Message) {
    $timestamp = (Get-Date -Format "yyyy-MM-dd HH:mm:ss")
    $entry = "$timestamp - $Message"
    try {
        Add-Content -Path $LogFile -Value $entry -Encoding utf8
    }
    catch {
        # Als loggen faalt, negeer dit (script moet door kunnen gaan)
    }
}

# **Functie: Ophalen van geïnstalleerde programma's uit het register (zowel 64-bit als 32-bit)**
function Get-InstalledApps {
    [OutputType([PSCustomObject[]])]
    param ()
    $results = @()

    # Lees 64-bit Uninstall registry key (alleen als OS 64-bit is)
    try {
        $regHive64 = [Microsoft.Win32.RegistryKey]::OpenBaseKey([Microsoft.Win32.RegistryHive]::LocalMachine, [Microsoft.Win32.RegistryView]::Registry64)
        $uninstallKey64 = $regHive64.OpenSubKey("SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Uninstall")
        if ($uninstallKey64) {
            foreach ($subKeyName in $uninstallKey64.GetSubKeyNames()) {
                $subKey = $uninstallKey64.OpenSubKey($subKeyName)
                if ($subKey) {
                    $name = $subKey.GetValue("DisplayName")
                    $publisher = $subKey.GetValue("Publisher")
                    $uninst = $subKey.GetValue("UninstallString")
                    $quiet = $subKey.GetValue("QuietUninstallString")
                    # Neem alleen op als DisplayName en Publisher aanwezig zijn (om systeemcomponenten e.d. over te slaan)
                    if ($name -and $publisher) {
                        $results += [PSCustomObject]@{
                            DisplayName          = $name
                            Publisher            = $publisher
                            UninstallString      = $uninst
                            QuietUninstallString = $quiet
                        }
                    }
                }
            }
        }
    }
    catch {
        Write-Log "Fout bij lezen van 64-bit registry hive: $($_.Exception.Message)"
    }

    # Lees 32-bit Uninstall registry key
    try {
        $regHive32 = [Microsoft.Win32.RegistryKey]::OpenBaseKey([Microsoft.Win32.RegistryHive]::LocalMachine, [Microsoft.Win32.RegistryView]::Registry32)
        $uninstallKey32 = $regHive32.OpenSubKey("SOFTWARE\\Wow6432Node\\Microsoft\\Windows\\CurrentVersion\\Uninstall")
        if ($uninstallKey32) {
            foreach ($subKeyName in $uninstallKey32.GetSubKeyNames()) {
                $subKey = $uninstallKey32.OpenSubKey($subKeyName)
                if ($subKey) {
                    $name = $subKey.GetValue("DisplayName")
                    $publisher = $subKey.GetValue("Publisher")
                    $uninst = $subKey.GetValue("UninstallString")
                    $quiet = $subKey.GetValue("QuietUninstallString")
                    if ($name -and $publisher) {
                        $results += [PSCustomObject]@{
                            DisplayName          = $name
                            Publisher            = $publisher
                            UninstallString      = $uninst
                            QuietUninstallString = $quiet
                        }
                    }
                }
            }
        }
    }
    catch {
        Write-Log "Fout bij lezen van 32-bit registry hive: $($_.Exception.Message)"
    }

    return $results
}

# Haal alle geïnstalleerde programma's op als lijst van objecten
$InstalledApps = Get-InstalledApps

# Variabele om bij te houden of er fouten zijn opgetreden
$uninstallError = $false

# **Verwijderingsproces per opgegeven applicatie**
foreach ($app in $AppsToRemove) {
    $appNameFilter = $app.Name
    $appPubFilter = $app.Publisher
    Write-Log "Zoeken naar applicatie: Name='$appNameFilter' Publisher='$appPubFilter'"

    # Zoek naar overeenkomende geïnstalleerde applicaties (case-insensitive match, wildcards toegestaan)
    $matches = $InstalledApps | Where-Object { 
        $_.DisplayName -like $appNameFilter -and $_.Publisher -like $appPubFilter 
    }

    if (!$matches -or $matches.Count -eq 0) {
        Write-Log "Geen installatie gevonden voor '$($app.Name)' van uitgever '$($app.Publisher)'. (Mogelijk al verwijderd)"
        continue  # Ga door naar de volgende opgegeven app
    }

    foreach ($entry in $matches) {
        Write-Log "Applicatie gevonden: $($entry.DisplayName) (Publisher: $($entry.Publisher)). Voorbereiden op verwijdering..."

        # Bepaal de juiste uninstall opdracht (quiet indien beschikbaar)
        $uninstallCmd = $entry.QuietUninstallString
        if ([string]::IsNullOrEmpty($uninstallCmd)) {
            $uninstallCmd = $entry.UninstallString
            Write-Log "QuietUninstallString niet gevonden voor $($entry.DisplayName). Gebruik UninstallString."
        }
        else {
            Write-Log "QuietUninstallString gevonden voor $($entry.DisplayName). Gebruik stille uninstall."
        }

        if ([string]::IsNullOrEmpty($uninstallCmd)) {
            Write-Log "Geen uninstall commando beschikbaar voor $($entry.DisplayName). Wordt overgeslagen."
            continue
        }

        # Voer het uninstall commando uit via cmd.exe /c (dit om eventuele spaties/quotes correct te behandelen in PowerShell)
        Write-Log "Voer uninstall uit: $uninstallCmd"
        try {
            # Start het proces en wacht tot het klaar is
            $combinedCmd = '/c ' + $uninstallCmd
            $process = Start-Process -FilePath "cmd.exe" -ArgumentList $combinedCmd -WindowStyle Hidden -Wait -PassThru
            $exitCode = $process.ExitCode

            if ($exitCode -eq 0) {
                Write-Log "Verwijdering van $($entry.DisplayName) voltooid (exitcode 0)."
            }
            elseif ($exitCode -eq 3010) {
                Write-Log "Verwijdering van $($entry.DisplayName) voltooid – herstart vereist (exitcode 3010)."
            }
            elseif ($exitCode -eq 1605 -or $exitCode -eq 1614) {
                Write-Log "Applicatie $($entry.DisplayName) was niet geïnstalleerd of al verwijderd (MSI exitcode $exitCode)."
            }
            else {
                Write-Log "Uninstall commando voor $($entry.DisplayName) gaf exitcode $exitCode (mogelijk fout)."
                $uninstallError = $true
            }
        }
        catch {
            Write-Log "Fout tijdens uitvoeren van uninstall voor $($entry.DisplayName): $($_.Exception.Message)"
            $uninstallError = $true
        }
    }
}

Write-Log "Uninstall script geëindigd."
# Als er ergens een fout is opgetreden, retourneer een exitcode ongelijk aan 0 (zodat Intune dit kan signaleren)
if ($uninstallError) {
    Exit 1
}
