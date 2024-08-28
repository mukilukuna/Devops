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
    # Output parameter values for debugging
    Write-Host "Starting resource group creation process"
    Write-Host "Parameters received:"
    Write-Host "Location: $location"
    Write-Host "Resource Group Name: $resourceGroupName"
    Write-Host "Owner: $owner"
    Write-Host "Cost Center: $costCenter"
    Write-Host "Application: $application"
    Write-Host "Description: $description"
    Write-Host "Repository: $repo"

    # Check if resource group name is provided
    if (-not $resourceGroupName) {
        throw "Resource group name is null or empty!"
    }

    Write-Host "Now creating the resource group"
    $deployment = New-AzResourceGroup -Name $resourceGroupName -Location $location -Tag $tag
    Write-Host "Resource group created successfully"
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
