# Script: REM_UninstallEsetEMP.ps1
# Purpose: REM UninstallEsetEMP
$productCode = (Get-WmiObject -Class Win32_Product | Where-Object {$_.Name -eq 'ESET Endpoint Antivirus' -and $_.Vendor -eq 'ESET, spol. s r.o.'}).IdentifyingNumber

msiexec /x $productCode /qn PASSWORD="10#r00sk@rlijn.antivirus" REBOOT="ReallySuppress"