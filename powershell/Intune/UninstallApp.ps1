# Lijst met applicaties om te verwijderen (aanpasbaar)
$AppsToRemove = @(
    @{ Name = "DYMO Connect"; Publisher = "DYMO*" }
    @{ Name = "DYMO Connect Web Service"; Publisher = "DYMO" }
)

# Registry locaties om te doorzoeken
$RegistryPaths = @(
    "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall",
    "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall"
)

# Loop door elke app in de lijst
foreach ($App in $AppsToRemove) {
    $AppName = $App.Name
    $AppPublisher = $App.Publisher
    $UninstallCommand = $null

    # Zoek in beide registry locaties
    foreach ($Path in $RegistryPaths) {
        $UninstallKey = Get-ChildItem -Path $Path | Get-ItemProperty | 
        Where-Object { $_.DisplayName -match $AppName -and $_.Publisher -match $AppPublisher }

        if ($UninstallKey) {
            # Zoek naar een stille uninstall-string
            if ($UninstallKey.QuietUninstallString) {
                $UninstallCommand = $UninstallKey.QuietUninstallString
            }
            elseif ($UninstallKey.UninstallString) {
                $UninstallCommand = $UninstallKey.UninstallString
            }

            # Voer de uninstall uit als er een opdracht is gevonden
            if ($UninstallCommand) {
                try {
                    # Split de uninstall-string als nodig
                    $UninstallArgs = $UninstallCommand -split '"'
                    $ExePath = $UninstallArgs[1]
                    $Arguments = if ($UninstallArgs.Count -gt 2) { $UninstallArgs[2] } else { "" }

                    # Voer de uninstall uit zonder pop-ups
                    Start-Process -FilePath $ExePath -ArgumentList $Arguments -NoNewWindow -Wait
                }
                catch {
                    # Fout wordt genegeerd zodat de rest van het script doorgaat
                }
            }
        }
    }
}
