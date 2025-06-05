# Script: APPX fix.ps1
# Purpose: APPX fix
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$wingetpath = 'C:\Program Files\WindowsApps\Microsoft.DesktopAppInstaller_*_x64__8wekyb3d8bbwe\'
$wingetdir = Get-ChildItem -Path $wingetpath -Recurse -Include "winget.exe" | Sort-Object -Property lastwritetime | Select-Object -ExcludeProperty lastwritetime -Last 1
Set-Location ($wingetdir).directory    

$commands = @(
    # paint
    ".\winget install 9PCFS5B6T72H --silent --accept-source-agreements --accept-package-agreements --verbose",
    # Notepad
    ".\winget install 9MSMLRH6LZF3 --silent --accept-source-agreements --accept-package-agreements --verbose",
    # Calculator
    ".\winget install 9WZDNCRFHVN5 --silent --accept-source-agreements --accept-package-agreements --verbose",
    # Photos
    ".\winget install 9WZDNCRFJBH4 --silent --accept-source-agreements --accept-package-agreements --verbose",
    # snipping tool
    ".\winget install 9MZ95KL8MR0L --silent --accept-source-agreements --accept-package-agreements --verbose"
)
    
# Loop through each command and execute it
foreach ($command in $commands) {
    Invoke-Expression $command
}
