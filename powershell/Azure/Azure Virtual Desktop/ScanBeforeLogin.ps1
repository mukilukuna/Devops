# PowerShell script to allow Windows updates to install before the initial user sign-in

# Define the registry path
$registryPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Orchestrator"

# Define the value name and data
$valueName = "ScanBeforeInitialLogonAllowed"
$valueData = 1

# Check if the registry key exists, if not, create it
if (-not (Test-Path $registryPath)) {
    New-Item -Path $registryPath -Force
}

# Set the registry value
Set-ItemProperty -Path $registryPath -Name $valueName -Value $valueData -Force

# Confirm the value has been set
$confirmation = Get-ItemProperty -Path $registryPath -Name $valueName
Write-Output "Registry value set: $($confirmation.$valueName)"
