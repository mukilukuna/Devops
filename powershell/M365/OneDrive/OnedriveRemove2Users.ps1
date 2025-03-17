#call on the function removal of secondary admin onedrive

Function Remove-OnedriveSecondaryAdmin($AdminURL, $SecondaryAdmin)
{

    #connect to Sharepoint online service.

    #Get all Onedrive URL's. of secondary admin that should not have permission.

    $OneDriveURLs = Get-SPOSite -IncludePersonalSite $true -Limit All -Filter "Url -like '-my.sharepoint.com/personal/'"

    foreach ($OneDriveURL in $OneDriveURLs)
    {

        #Remove Secondary administrator from users personal Onedrive Site, such as for example XXX-my.sharepoint.com/personal/.

        Set-SPOUser -Site $OneDriveURL.URL -LoginName $SecondaryAdmin -IsSiteCollectionAdmin $false -ErrorAction SilentlyContinue

        Write-Host "Removed $SecondaryAdmin admin from the site $($OneDriveURL.URL)" 

    }

}

#secondary admin is the user that we want to remove

#Adminurl = sharepoint site that we want to connect to.

Remove-OnedriveSecondaryAdmin -SecondaryAdmin "adm_evivandervelden@kinderdam.nl" -AdminURL "https://kinderdam-admin.sharepoint.com/"

#parameter secondarayadmin that is wanted to be removed, 

$SecondaryAdmin = "-SecondaryAdmin"
