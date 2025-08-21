    # =====================================================================
    # Robocopy Script - Mirror Source to Destination with Logging
    # =====================================================================
    # Configuratie
    $Source      = "<Bron Locatie>"
    $Destination = "<Doel Locatie>"
    $LogPath     = "C:\Temp\Robocopy_Test_Mirror.log"

    # Maak logmap aan indien deze niet bestaat
    $LogDir = Split-Path $LogPath
    if (!(Test-Path $LogDir)) {
        New-Item -Path $LogDir -ItemType Directory -Force | Out-Null
    }

    # Robocopy parameters
    $RoboParams = @(
        $Source
        $Destination
        "/MT:20"        # Multi-threading met 20 threads
        "/R:2"          # 2 retries bij mislukking
        "/W:1"          # 1 seconde wachttijd tussen retries
        "/B"            # Backup mode (om beveiligingsfouten te voorkomen)
        "/MIR"          # Mirror: doel exact gelijk aan bron maken
        "/IT"           # Neem gewijzigde timestamps mee
        "/COPY:DATSO"   # Data, Attributes, Timestamps, Security (NTFS), Owner info
        "/DCOPY:DAT"    # Directory data + attributen + timestamps kopiëren
        "/NP"           # Geen voortgang in procenten tonen
        "/NFL"          # Geen bestandsnamen loggen (log blijft korter)
        "/NDL"          # Geen mapnamen loggen
        "/LOG+:$LogPath" # Append logging naar bestand
        "/TEE"          # Toon output ook in console
    )

    # Uitvoeren van Robocopy
    Write-Host "=== Robocopy gestart: $(Get-Date) ===" -ForegroundColor Cyan
    robocopy @RoboParams
    Write-Host "=== Robocopy afgerond: $(Get-Date) ===" -ForegroundColor Green
    Write-Host "Logbestand: $LogPath"
