# Script: DET_EsetInstalledEMP.ps1
# Purpose: DET EsetInstalledEMP
If (([string](Get-ChildItem Registry::HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall | Where-Object {$_.GetValue('DisplayName') -eq 'ESET Endpoint Antivirus'})) -and (Get-WmiObject -Class Win32_Product | Where-Object {$_.Name -eq 'ESET Endpoint Security' -and $_.vendor -eq 'ESET, spol. s r.o.'})) {
    Write-Host "ESET is installed"
    exit 1
} else {
    Write-Host "ESET isn't installed"
    exit 0
}