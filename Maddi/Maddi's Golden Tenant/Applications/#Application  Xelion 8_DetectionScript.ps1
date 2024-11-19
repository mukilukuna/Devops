$packageName = "*XelionWindows*"
$package = Get-AppxPackage -Name $packageName

if ($package) {
    Write-Host "Found it!"
}
