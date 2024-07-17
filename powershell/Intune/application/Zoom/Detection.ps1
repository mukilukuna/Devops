#Vul de winget id hier in
$PackageName = "XP99J3KP4XZ4VV"

$InstalledApps = winget list --id  $PackageName

if ($InstalledApps) {
    Write-Host "$($PackageName) is installed"
    exit 1
}