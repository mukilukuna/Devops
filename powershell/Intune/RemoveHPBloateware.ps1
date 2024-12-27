# Definieer lijsten met te verwijderen pakketten en programma's
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

$HPidentifier = "AD2F1837"

# Haal de te verwijderen pakketten en programma's op
$InstalledPackages = Get-AppxPackage -AllUsers | Where-Object { $_.Name -in $UninstallPackages -or $_.Name -match "^$HPidentifier" }
$ProvisionedPackages = Get-AppxProvisionedPackage -Online | Where-Object { $_.DisplayName -in $UninstallPackages -or $_.DisplayName -match "^$HPidentifier" }
$InstalledPrograms = Get-Package | Where-Object { $_.Name -in $UninstallPrograms }

# Verwijder Appx Provisioned Packages
foreach ($ProvPackage in $ProvisionedPackages) {
    Write-Host "Attempting to remove provisioned package: [$($ProvPackage.DisplayName)]..."
    try {
        Remove-AppxProvisionedPackage -PackageName $ProvPackage.PackageName -Online -ErrorAction Stop
        Write-Host "Successfully removed provisioned package: [$($ProvPackage.DisplayName)]"
    }
    catch {
        Write-Warning "Failed to remove provisioned package: [$($ProvPackage.DisplayName)]"
    }
}

# Verwijder Appx Packages
foreach ($AppxPackage in $InstalledPackages) {
    Write-Host "Attempting to remove Appx package: [$($AppxPackage.Name)]..."
    try {
        Remove-AppxPackage -Package $AppxPackage.PackageFullName -AllUsers -ErrorAction Stop
        Write-Host "Successfully removed Appx package: [$($AppxPackage.Name)]"
    }
    catch {
        Write-Warning "Failed to remove Appx package: [$($AppxPackage.Name)]"
    }
}

# Verwijder geïnstalleerde programma's
foreach ($Program in $InstalledPrograms) {
    Write-Host "Attempting to uninstall: [$($Program.Name)]..."
    try {
        $Program | Uninstall-Package -AllVersions -Force -ErrorAction Stop
        Write-Host "Successfully uninstalled: [$($Program.Name)]"
    }
    catch {
        Write-Warning "Failed to uninstall: [$($Program.Name)]"
    }
}

# Fallback poging 1 en 2 voor HP Wolf Security (indien nodig)
$FallbackMSI = @(
    "{0E2E04B0-9EDD-11EB-B38C-10604B96B11E}",
    "{4DA839F0-72CF-11EC-B247-3863BB3CB5A8}"
)

foreach ($MSI in $FallbackMSI) {
    Write-Host "Attempting MSI uninstall for HP Wolf Security: $MSI..."
    try {
        Start-Process "msiexec.exe" -ArgumentList "/x $MSI /qn /norestart" -Wait -ErrorAction Stop
        Write-Host "Successfully initiated MSI uninstall for $MSI"
    }
    catch {
        Write-Warning "Failed to uninstall HP Wolf Security using MSI: $MSI"
    }
}
