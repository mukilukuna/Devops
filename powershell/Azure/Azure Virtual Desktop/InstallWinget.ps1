# Script: InstallWinget.ps1
# Purpose: InstallWinget
$URILatestWinget = "https://github.com/microsoft/winget-cli/releases/download/v1.4.10173/Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle"
$URILatestWebview2 = "https://go.microsoft.com/fwlink/p/?LinkId=2124703"
$LatestWingetTempDest = "c:\temp\Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle"
$LatestWebview2TempDest = "c:\temp\MicrosoftEdgeWebview2Setup.exe"
if (-not(Test-Path -path "c:\temp")) {
    New-Item -ItemType Directory "c:\temp"
}
Invoke-WebRequest -Uri $URILatestWinget -OutFile $LatestWingetTempDest
Invoke-WebRequest -Uri $URILatestWebview2 -OutFile $LatestWebview2TempDest
Start-Process -Wait -FilePath $LatestWebview2TempDest
Add-AppxPackage -Path $LatestWingetTempDest