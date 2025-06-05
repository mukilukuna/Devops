# Script: Detect_Dropbox.ps1
# Purpose: Detect Dropbox
$registryPath = "HKLM:\SOFTWARE\WOW6432Node\Dropbox\Client"

# Check if the registry key exists
if (Test-Path $registryPath)
{
    Write-Host "The registry key exists."
    exit 1
}
else
{
    Write-Host "The registry key does not exist."
    exit 0
}