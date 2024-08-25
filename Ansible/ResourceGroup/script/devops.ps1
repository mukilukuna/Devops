param(
    $location,
    $resourceGroupName,
    $owner,
    $costCenter,
    $application,
    $description,
    $repo
)

$tag = @{
    Owner       = $owner;
    CostCenter  = $costCenter;
    Application = $application;
    Description = $description;
    Repository  = $repo
}

try {
    Write-Host "Now creating the resource group"
    Write-Host "location: ${location}"
    Write-Host "resource group name: ${resourceGroupName}"

    # Debugging lines
    if (-not $resourceGroupName) {
        throw "Resource group name is null or empty!"
    }

    $deployment = New-AzResourceGroup -Name "${resourceGroupName}" -Location "${location}" -Tag ${tag}
    Write-Host $deployment
}
catch {
    $message = $_.Exception.Message
    $stackTraceText = $_.Exception.StackTrace
    Write-Host "The script failed with the following text"
    Write-Host $message
    Write-Host $stackTraceText
    throw "Script Halted"
}
