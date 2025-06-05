# Script: Remove APPX.ps1
# Purpose: Remove APPX
$wingetappxes = (Get-ChildItem 'C:\Program Files\WindowsApps' | Where-Object { $_.name -like "*microsoft.winget.source*" }).name
$LangPackappxes = (Get-ChildItem 'C:\Program Files\WindowsApps' | Where-Object { $_.name -like "*Microsoft.LanguageExperiencePack*" }).name
$HPPrintControlAppxes = (Get-ChildItem 'C:\Program Files\WindowsApps' | Where-Object { $_.name -like "*HPPrinterControl*" }).name
foreach ($wingetappx in $wingetappxes) {
    remove-appxpackage -allusers $wingetappx
}
foreach ($LangPackappx in $LangPackappxes) {
    remove-appxpackage -allusers $LangPackappx
}
foreach ($HPPrintControlAppx in $HPPrintControlAppxes) {
    remove-appxpackage -allusers $HPPrintControlAppx
}