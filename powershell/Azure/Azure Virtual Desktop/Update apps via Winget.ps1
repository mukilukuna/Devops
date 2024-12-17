#Stappen die uitgevoerd moeten worden:
#1) Zorg eerst dat het "Winget_Installer_MasterImage.ps1" is uitgevoerd, zodat Winget er op staat.
$wingetpath = 'C:\Program Files\WindowsApps\Microsoft.DesktopAppInstaller_*_x64__8wekyb3d8bbwe\'
$wingetdir = Get-ChildItem -Path $wingetpath -Recurse -Include "winget.exe" | Sort-Object -Property lastwritetime | Select-Object -ExcludeProperty lastwritetime -Last 1
Set-Location ($wingetdir).directory
Start-Process ".\winget.exe" -ArgumentList "source remove msstore"
Start-Process -Wait ".\winget.exe" -ArgumentList "upgrade --all --accept-source-agreements --accept-package-agreements --silent"