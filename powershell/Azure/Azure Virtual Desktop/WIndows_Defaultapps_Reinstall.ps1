# Script: WIndows_Defaultapps_Reinstall.ps1
# Purpose: WIndows Defaultapps Reinstall
Get-ProvisionedAppXPackage -Online | Select DisplayName

Get-appxpackage Microsoft.MicrosoftOfficeHub

Get-AppxPackage -allusers | foreach { Add-AppxPackage -register "$($_.InstallLocation)\appxmanifest.xml" -DisableDevelopmentMode }
Get-AppxPackage Microsoft.MicrosoftOfficeHub | foreach { Add-AppxPackage -register "$($_.InstallLocation)\appxmanifest.xml" -DisableDevelopmentMode }