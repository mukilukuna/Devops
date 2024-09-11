

# Define source and destination paths
$sourcePath = "C:\Users\MukiLukunaITSynergy\OneDrive - IT Synergy\Documenten\PowerShell\Modules"
$destinationPath = "$env:ProgramFiles\WindowsPowerShell\Modules"

# Check if the source directory exists
if (-not (Test-Path -Path $sourcePath)) {
    Write-Host "Source path '$sourcePath' does not exist. Please check the path or ensure modules are installed."
    exit
}

# Check if the destination directory exists, create if it doesn't
if (-not (Test-Path -Path $destinationPath)) {
    New-Item -ItemType Directory -Path $destinationPath
}

# Initialize arrays to track module statuses
$correctModules = @()
$movedModules = @()

# Get all installed modules in the user's Modules folder
$modules = Get-ChildItem -Path $sourcePath

# Copy each module to the destination folder
foreach ($module in $modules) {
    $sourceModulePath = Join-Path -Path $sourcePath -ChildPath $module.Name
    $destinationModulePath = Join-Path -Path $destinationPath -ChildPath $module.Name

    # Check if the module already exists in the destination
    if (Test-Path -Path $destinationModulePath) {
        Write-Host "Module $($module.Name) already exists in All Users location. Skipping..."
        $correctModules += $module.Name
    }
    else {
        Write-Host "Copying $($module.Name) to All Users location..."
        Copy-Item -Path $sourceModulePath -Destination $destinationModulePath -Recurse -Force
        $movedModules += $module.Name
    }
}

# Summary of actions
Write-Host "-------------------------------------------------"
Write-Host "Modules already in the correct location:"
if ($correctModules.Count -gt 0) {
    $correctModules | ForEach-Object { Write-Host "- $_" }
}
else {
    Write-Host "None"
}

Write-Host "-------------------------------------------------"
Write-Host "Modules that were moved:"
if ($movedModules.Count -gt 0) {
    $movedModules | ForEach-Object { Write-Host "- $_" }
}
else {
    Write-Host "None"
}

Write-Host "-------------------------------------------------"
Write-Host "Module transfer completed."
