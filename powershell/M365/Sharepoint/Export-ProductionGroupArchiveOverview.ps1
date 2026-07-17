<#
.SYNOPSIS
Maakt een CSV-overzicht van bestanden in de SharePoint-map Production Group.

.DESCRIPTION
Leest uitsluitend bestanden uit de opgegeven SharePoint-map en de onderliggende
mappen. Alleen bestanden die uiterlijk op 31 december 2024 zijn gewijzigd,
worden opgenomen in het CSV-bestand.

Het script downloadt, verplaatst, verwijdert en wijzigt geen SharePoint-bestanden.
#>

[CmdletBinding()]
param(
    [Parameter()]
    [ValidateNotNullOrEmpty()]
    [string]$SiteUrl = "https://koersgroepbv.sharepoint.com/sites/TeamRotterdam",

    [Parameter()]
    [ValidateNotNullOrEmpty()]
    [string]$ClientId = "82d6daea-eb3c-4453-a344-f8e3a98dbe46",

    [Parameter()]
    [ValidateNotNullOrEmpty()]
    [string]$TenantId = "2c154eae-2ba8-4ab0-acc1-f9ecf4cf682e",

    [Parameter()]
    [ValidateNotNullOrEmpty()]
    [string]$StartFolderSiteRelativeUrl = "Shared Documents/Production Group",

    [Parameter()]
    [datetime]$CutoffDateTime = [datetime]"2025-01-01",

    [Parameter()]
    [ValidateNotNullOrEmpty()]
    [string]$OutputCsv = (Join-Path $env:TEMP ("TeamRotterdam-ProductionGroup-ArchiefOverzicht-{0}.csv" -f (Get-Date -Format "yyyyMMdd-HHmmss")))
)

$ErrorActionPreference = "Stop"

function Get-FileValue {
    param(
        [Parameter(Mandatory)]
        $Item,

        [Parameter(Mandatory)]
        [string]$PropertyName
    )

    if ($null -ne $Item.File -and $null -ne $Item.File.PSObject.Properties[$PropertyName]) {
        return $Item.File.$PropertyName
    }

    if ($null -ne $Item.PSObject.Properties[$PropertyName]) {
        return $Item.$PropertyName
    }

    return $null
}

if (-not (Get-Module -ListAvailable -Name PnP.PowerShell)) {
    throw "PnP.PowerShell is niet gevonden. Installeer met: Install-Module PnP.PowerShell -Scope CurrentUser -AllowClobber -Force"
}

$outputFolder = Split-Path -Path $OutputCsv -Parent
if ([string]::IsNullOrWhiteSpace($outputFolder)) {
    $outputFolder = (Get-Location).Path
}

if (-not (Test-Path -LiteralPath $outputFolder)) {
    New-Item -Path $outputFolder -ItemType Directory -Force | Out-Null
}

Import-Module PnP.PowerShell -Force

$siteUri = [System.Uri]$SiteUrl
$tenantRootUrl = "$($siteUri.Scheme)://$($siteUri.Host)"
$sitePath = $siteUri.AbsolutePath.TrimEnd("/")
$startFolderServerRelativeUrl = "$sitePath/$($StartFolderSiteRelativeUrl.TrimStart('/'))"

Write-Host "Verbinden met SharePoint-site:" -ForegroundColor Cyan
Write-Host $SiteUrl -ForegroundColor Cyan

Connect-PnPOnline `
    -Url $SiteUrl `
    -Interactive `
    -ClientId $ClientId `
    -Tenant $TenantId

Write-Host ""
Write-Host "Bestanden ophalen uit $StartFolderSiteRelativeUrl en onderliggende mappen..." -ForegroundColor Cyan

$allFiles = @(Get-PnPFolderItem `
    -FolderSiteRelativeUrl $StartFolderSiteRelativeUrl `
    -ItemType File `
    -Recursive)

Write-Host "Aantal bestanden gevonden voor datumfilter: $($allFiles.Count)" -ForegroundColor Green
Write-Host "Filteren op gewijzigd vóór $($CutoffDateTime.ToString('dd-MM-yyyy'))..." -ForegroundColor Cyan

$rows = foreach ($file in $allFiles) {
    $serverRelativeUrl = Get-FileValue -Item $file -PropertyName "ServerRelativeUrl"
    $fileName = Get-FileValue -Item $file -PropertyName "Name"
    $modifiedRaw = Get-FileValue -Item $file -PropertyName "TimeLastModified"
    $createdRaw = Get-FileValue -Item $file -PropertyName "TimeCreated"
    $sizeBytes = Get-FileValue -Item $file -PropertyName "Length"

    if ([string]::IsNullOrWhiteSpace($serverRelativeUrl)) {
        continue
    }

    try {
        $modifiedDate = [datetime]$modifiedRaw
    }
    catch {
        Write-Warning "Bestand overgeslagen omdat de wijzigingsdatum niet kan worden gelezen: $serverRelativeUrl"
        continue
    }

    if ($modifiedDate -ge $CutoffDateTime) {
        continue
    }

    $extension = [System.IO.Path]::GetExtension($fileName).TrimStart(".")
    $folderUrl = Split-Path -Path $serverRelativeUrl -Parent

    [pscustomobject]@{
        SiteUrl            = $SiteUrl
        BronMap            = $startFolderServerRelativeUrl
        Bestandsnaam       = $fileName
        Extensie           = $extension
        MapUrl             = "$tenantRootUrl$folderUrl"
        ServerRelatiefPad  = $serverRelativeUrl
        VolledigeUrl       = "$tenantRootUrl$serverRelativeUrl"
        GewijzigdOp        = $modifiedDate
        AangemaaktOp       = $createdRaw
        GrootteBytes       = $sizeBytes
        GrootteMB          = if ($sizeBytes) { [math]::Round(([double]$sizeBytes / 1MB), 2) } else { 0 }
        MigratieBestemming = ""
        MigratieOpmerking  = ""
    }
}

$rows = @($rows)
Write-Host "Aantal bestanden na datumfilter: $($rows.Count)" -ForegroundColor Green
Write-Host "CSV exporteren..." -ForegroundColor Cyan

$rows |
    Sort-Object MapUrl, Bestandsnaam |
    Export-Csv `
        -Path $OutputCsv `
        -NoTypeInformation `
        -Encoding utf8BOM `
        -Delimiter ";"

Write-Host ""
Write-Host "Klaar." -ForegroundColor Green
Write-Host "Aantal bestanden in CSV: $($rows.Count)" -ForegroundColor Green
Write-Host "CSV-bestand: $OutputCsv" -ForegroundColor Green
