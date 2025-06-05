# Script: REM_UninstallEset.ps1
# Purpose: REM UninstallEset
$productCode = (Get-WmiObject -Class Win32_Product | Where-Object { $_.Name -eq 'ESET Endpoint Security' -and $_.Vendor -eq 'ESET, spol. s r.o.' }).IdentifyingNumber

msiexec /x $productCode /qn PASSWORD="Syn3rgy3024#" REBOOT="ReallySuppress"