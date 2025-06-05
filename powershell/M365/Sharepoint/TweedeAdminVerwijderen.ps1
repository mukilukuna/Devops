# Script: TweedeAdminVerwijderen.ps1
# Purpose: TweedeAdminVerwijderen
<# 
Script om een secundaire beheerder te verwijderen uit alle OneDrive for Business-sites van een organisatie.

Zorg ervoor dat de volgende punten zijn ingesteld voordat u dit script uitvoert:
1. SharePoint Online Management Shell is geïnstalleerd.
2. U heeft de juiste machtigingen (SharePoint Online-beheerder of Global Administrator).
3. U bent ingelogd in de SharePoint Online-service.

Gemaakt door: Muki Lukuna samen met ChatGPT
#>

Function Remove-OnedriveSecondaryAdmin {
    param (
        [string]$AdminURL, # URL van het SharePoint Online-beheercentrum
        [string]$SecondaryAdmin     # Het e-mailadres van de secundaire beheerder die u wilt verwijderen
    )

    # Controleer of de gebruiker al is ingelogd
    if (!(Get-SPOService | Out-Null)) {
        Write-Host "U bent momenteel niet ingelogd bij SharePoint Online. Aanmelden wordt nu uitgevoerd..."
        Connect-SPOService -Url $AdminURL
    }

    # Haal alle OneDrive URL's op van gebruikers
    Write-Host "Bezig met ophalen van alle OneDrive URL's..."
    $OneDriveURLs = Get-SPOSite -IncludePersonalSite $true -Limit All -Filter "Url -like '-my.sharepoint.com/personal/'"

    foreach ($OneDriveURL in $OneDriveURLs) {
        try {
            # Verwijder de secundaire beheerder van de OneDrive-site
            Set-SPOUser -Site $OneDriveURL.URL -LoginName $SecondaryAdmin -IsSiteCollectionAdmin $false -ErrorAction Stop
            Write-Host "Secundaire beheerder $SecondaryAdmin succesvol verwijderd van site $($OneDriveURL.URL)"
        }
        catch {
            Write-Warning "Er is een fout opgetreden bij het verwijderen van $SecondaryAdmin van site $($OneDriveURL.URL): $_"
        }
    }

    # Vraag om af te melden na voltooiing
    $logoutResponse = Read-Host "Wilt u afmelden van SharePoint Online? Typ 'ja' om af te melden of druk op Enter om ingelogd te blijven"
    if ($logoutResponse -eq "ja") {
        Disconnect-SPOService
        Write-Host "Succesvol afgemeld van SharePoint Online."
    }
    else {
        Write-Host "U blijft ingelogd bij SharePoint Online."
    }
}

# Uitvoeren van de functie
Remove-OnedriveSecondaryAdmin -AdminURL "https://kinderdam-admin.sharepoint.com/" -SecondaryAdmin "its_admin@kinderdam.nl"
