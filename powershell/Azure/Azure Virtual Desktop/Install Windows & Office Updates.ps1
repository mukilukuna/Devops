# Script: Install Windows & Office Updates.ps1
# Purpose: Install Windows & Office Updates
if (Test-Path "C:\Program Files\Common Files\microsoft shared\ClickToRun\") {
    Set-Location "C:\Program Files\Common Files\microsoft shared\ClickToRun\"
    Start-Process OfficeC2RClient.exe -Wait -ArgumentList "/update user displaylevel=false forceappshutdown=false"
}
if ( -not (Get-InstalledModule pswindowsupdate -ErrorAction silentlycontinue)) {
    Install-PackageProvider -Name NuGet -Force | Out-Null
    Install-Module -Name PSWindowsUpdate -force | Out-Null
    Import-Module -Name PSWindowsUpdate -Force | Out-Null
    Get-WindowsUpdate -Download -AcceptAll
    Install-WindowsUpdate -acceptall -ignorereboot -install
}
if (Get-InstalledModule pswindowsupdate -ErrorAction silentlycontinue) {
    Import-Module -Name PSWindowsUpdate -Force | Out-Null
    Get-WindowsUpdate -Download -AcceptAll
    Install-WindowsUpdate -acceptall -ignorereboot -install
}
$ATPcheck = Get-ItemProperty "hklm:\SOFTWARE\Microsoft\Windows Advanced Threat Protection\" | Select-Object senseid
if ($ATPcheck) {
    try {
        Update-MpSignature
    }
    catch {
        Write-Host "Commando: 'Update-MpSignature' gefaald"
    }
    Start-Process "c:\program files\Windows Defender\MpCmdRun.exe" -ArgumentList '-SignatureUpdate' -Wait
}