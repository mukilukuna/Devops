# Script: SCR_UPD_UPDATEWITHOUTREBOOT.ps1
# Purpose: SCR UPD UPDATEWITHOUTREBOOT
Set-ExecutionPolicy Bypass -Confirm:$false
Install-Script -name pswindowsupdate -force -Confirm:$false
Get-WindowsUpdate -AcceptAll -ForceInstall -Install
# # Update geschiedenis ophalen
# Install-Module -Name PUDAdminCenterPrototype -allowclobber
# Import-Module PUDAdminCenterPrototype
# Get-WuaHistory | select-object Result, Product, Date, title | out-file -filepath c:\temp\Updatehystory.txt