# Controleer of het registerbestaat bestaat. Zo niet, voeg het toe.
$registryPath = "HKCU:\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32"
if (-not (Test-Path $registryPath)) {
    New-Item -Path $registryPath -Force
    Write-Host "Register toegevoegd."
}
else {
    Write-Host "Register bestaat al."
}
