Param(
    $location,
    $resourcegroupname,
    $owner,
    $costcenter,
    $application,
    $description,
    $repo
)

$tag = @{
    Owner       = $owner
    Costcenter  = $costcenter
    Application = $application
    Description = $description
    Repository  = $repo
}

try {
    Write-Host "Now creating the resource group"
    Write-Host "Location: ${location}"
    Write-Host "Resource group name: ${resourcegroupname}"
    $deployment = New-AzResourceGroup -Name $resourcegroupname -Location $location -Tag $tag
    Write-Host $deployment
}
Catch {
    $message = $_.Exception.Message
    $StackTraceText = $_.Exception.StackTrace
    Write-Host "The script failed due to the following error:"
    Write-Host $message
    Write-Host $StackTraceText
    throw "Script halted"
}
