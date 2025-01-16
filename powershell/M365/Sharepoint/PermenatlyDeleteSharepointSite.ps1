# Controleer en installeer benodigde modules
$modules = @("Microsoft.Online.SharePoint.PowerShell", "MSOnline")

foreach ($module in $modules) {
    if (-not (Get-Module -ListAvailable -Name $module)) {
        Write-Host "Module $module is not installed. Installing..."
        Install-Module -Name $module -Force -AllowClobber -Scope AllUsers
    }
    else {
        Write-Host "Module $module is already installed."
    }
}

# Importeer modules
Import-Module Microsoft.Online.SharePoint.PowerShell
Import-Module MSOnline

# Log in bij SharePoint Online
Write-Host "Logging in to SharePoint Online..."
$adminUrl = "https://<tenant>-admin.sharepoint.com"
Connect-SPOService -Url $adminUrl

# Verwijderde sites opvragen
Write-Host "Retrieving deleted sites..."
$deletedSites = Get-SPODeletedSite

if ($deletedSites) {
    Write-Host "Found deleted sites. Proceeding to permanently delete them..."
    foreach ($site in $deletedSites) {
        Write-Host "Permanently deleting site: $($site.Url)"
        Remove-SPODeletedSite -Identity $site.Url -Confirm:$false
    }
    Write-Host "All deleted sites have been permanently removed."
}
else {
    Write-Host "No deleted sites found."
}

# Afmelden bij SharePoint Online
Disconnect-SPOService

Write-Host "Script completed."