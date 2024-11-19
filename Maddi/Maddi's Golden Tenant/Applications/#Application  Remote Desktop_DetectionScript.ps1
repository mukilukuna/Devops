If (([string](Get-ChildItem Registry::HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall | Where-Object {$_.GetValue('DisplayName') -eq 'Remote Desktop'})) -and (Get-WmiObject -Class Win32_Product | Where-Object {$_.Name -eq 'Remote Desktop' -and $_.Vendor -eq 'Microsoft Corporation'})) {
    Write-Host "Microsoft Remote Desktop client is installed"
    exit 0
} else {
    Write-Host "Microsoft Remote Desktop client isn't installed"
    exit 1
}