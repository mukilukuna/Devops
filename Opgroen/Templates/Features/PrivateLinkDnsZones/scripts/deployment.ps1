$subscriptionId = ""
$resoucegroup = ""

# Create the install folder
$installPath = "$env:USERPROFILE\.bicep"
$installDir = New-Item -ItemType Directory -Path $installPath -Force
$installDir.Attributes += 'Hidden'
# Fetch the latest Bicep CLI binary
(New-Object Net.WebClient).DownloadFile("https://github.com/Azure/bicep/releases/latest/download/bicep-win-x64.exe", "$installPath\bicep.exe")
# Add bicep to your PATH
$currentPath = (Get-Item -path "HKCU:\Environment" ).GetValue('Path', '', 'DoNotExpandEnvironmentNames')
if (-not $currentPath.Contains("%USERPROFILE%\.bicep")) { setx PATH ($currentPath + ";%USERPROFILE%\.bicep") }
if (-not $env:path.Contains($installPath)) { $env:path += ";$installPath" }
# Verify you can now access the 'bicep' command.
bicep --help
# Done!

select-azsubscription -subscriptionId  $subscriptionId

new-azresourcegroupdeployment -resourcegroupname $resoucegroup -name DNSZones -templatefile "$(System.DefaultWorkingDirectory)/_BRCCustomer/vdlgroep/7fc07cde-acd7-4896-b2b1-f1dd192542be/Private DNS Zone/templates/privateLinkZones.template.bicep" -templateparameterfile "$(System.DefaultWorkingDirectory)/_BRCCustomer/vdlgroep/7fc07cde-acd7-4896-b2b1-f1dd192542be/Private DNS Zone/parameters/privatelinkDnsZone.parameters.json"