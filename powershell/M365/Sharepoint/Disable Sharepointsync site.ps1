# Controleer of de SharePoint Online Management Shell module geïnstalleerd is
if (-not (Get-Module -ListAvailable -Name "Microsoft.Online.SharePoint.PowerShell")) {
    Write-Host "Microsoft.Online.SharePoint.PowerShell is niet geïnstalleerd. Installatie wordt gestart..." -ForegroundColor Yellow
    try {
        Install-Module -Name "Microsoft.Online.SharePoint.PowerShell" -Scope AllUsers -Force -AllowClobber
        Write-Host "Module succesvol geïnstalleerd." -ForegroundColor Green
    }
    catch {
        Write-Error "Installatie is mislukt: $_"
        exit
    }
}
else {
    Write-Host "Microsoft.Online.SharePoint.PowerShell is al geïnstalleerd." -ForegroundColor Cyan
}

# Importeer de module
Import-Module Microsoft.Online.SharePoint.PowerShell -Force

# Verbind met SharePoint Online admin center
$cred = Get-Credential
Connect-SPOService -url "https://koersgroepbv-admin.sharepoint.com/" 
# Schakel de Sync-knop op teamsites uit
try {
    Set-SPOTenant -HideSyncButtonOnTeamSite $true
    Write-Host "Sync-knop op Team Sites is uitgeschakeld." -ForegroundColor Green
}
catch {
    Write-Error "Fout bij toepassen van instelling: $_"
}
