# Script: Install OneDrive.ps1
# Purpose: Install OneDrive
$URILatestOneDrive = "https://go.microsoft.com/fwlink/?linkid=860984"
$LatestOneDriveTempDest = "c:\temp\OneDriveSetup.exe"
if (-not(Test-Path -path "c:\temp")) {
    New-Item -ItemType Directory "c:\temp"
}
Invoke-WebRequest -Uri $URILatestOneDrive -OutFile $LatestOneDriveTempDest
Start-Process -Wait -FilePath $LatestOneDriveTempDest -ArgumentList "/allusers /silent"