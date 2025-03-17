# Installeer de PnP PowerShell-module indien nodig
if (-not (Get-Module -Name PnP.PowerShell -ListAvailable)) {
    Install-Module -Name PnP.PowerShell -Force -AllowClobber
}

$AdminUrl = "https://kinderdam-admin.sharepoint.com/"  # Vervang met de SharePoint Admin-URL
$SiteUrl = "https://kinderdam.sharepoint.com/sites/OrganizationalAssets"  # De site waar je bibliotheken wilt aanmaken

Connect-PnPOnline -Url $SiteUrl -UseWebLogin

$libraryURL = @(
    "https://kinderdam.sharepoint.com/sites/OrganizationalAssets/Hefgroep",
    "https://kinderdam.sharepoint.com/sites/OrganizationalAssets/Grootrotterdam",
    "https://kinderdam.sharepoint.com/sites/OrganizationalAssets/Peuter&co",
    "https://kinderdam.sharepoint.com/sites/OrganizationalAssets/JOZ",
    "https://kinderdam.sharepoint.com/sites/OrganizationalAssets/SMWR",
    "https://kinderdam.sharepoint.com/sites/OrganizationalAssets/Kinderdam")
$cdnType = "Private"
$orgAssetType = "OfficeTemplateLibrary"

foreach ($library in $libraryURL) {
    try {
        Add-PnPOrgAssetsLibrary -LibraryUrl $library -OrgAssetType $orgAssetType -CdnType Private
    }
    catch {
        Write-Host "Error: $_"
    }
}
