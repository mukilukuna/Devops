<# Hiermee kun je geopende file handles op een Azure Files share ophalen #>


# Zorg dat foutmeldingen niet het script stoppen
$ErrorActionPreference = "Stop"

# Benodigde modules
$requiredModules = @("Az.Accounts", "Az.Storage")

foreach ($module in $requiredModules) {
    if (-not (Get-Module -ListAvailable -Name $module)) {
        Write-Host "Module $module wordt geïnstalleerd..."
        Install-Module -Name $module -Force -Scope AllUsers
    }
}

# Connect met Azure
Write-Host "Log in met device code..."
Connect-AzAccount -UseDeviceAuthentication

# Selecteer subscription
$subscription = Get-AzSubscription | Out-GridView -Title "Selecteer een subscription" -PassThru
Set-AzContext -SubscriptionId $subscription.Id

# Selecteer storage account
$storageAccount = Get-AzStorageAccount | Out-GridView -Title "Selecteer het storage account" -PassThru

# Maak de context aan
$ctx = $storageAccount.Context

# Geef de naam van de Azure Files share op
$shareName = Read-Host "Voer de naam in van de Azure File Share (bijv. fslogix)"

# Haal geopende handles op
Write-Host "Ophalen geopende file handles op share '$shareName'..."
Get-AzStorageFileHandle -Context $ctx -ShareName $shareName | Format-Table Path, OpenTime, SessionId
