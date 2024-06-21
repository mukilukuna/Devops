$packageName = "XelionWindowsDesktop"

# Check if the appx package is installed
$package = Get-AppxPackage | Where-Object { $_.Name -eq $packageName }

if ($package) {
    Write-Host "The $packageName appx package is installed."
    exit 1
}