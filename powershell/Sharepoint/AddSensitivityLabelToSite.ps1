# Install and connect to SharePoint Online Management Shell if not already done
Install-Module -Name Microsoft.Online.SharePoint.PowerShell -Force -AllowClobber
Connect-SPOService -Url https://rekenkameramsterdam-admin.sharepoint.com


$label = Get-Label -Identity "Sensitive Information" | Select-Object Name, GUID
$labelGuid = $label.GUID

# Define the URLs of the SharePoint sites
$sites = @(
    "https://rekenkameramsterdam.sharepoint.com/sites/RAZ",
    "https://rekenkameramsterdam.sharepoint.com/sites/Projecten",
    "https://rekenkameramsterdam.sharepoint.com/sites/Bedrijfsvoering"
)

# Loop through each site and apply the sensitivity label
foreach ($siteUrl in $sites) {
    Set-SPOSite -Identity $siteUrl -SensitivityLabel $labelGuid
    Write-Host "Applied sensitivity label to $siteUrl"
}
