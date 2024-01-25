# Creates an Azure resource group with tags
#
# This function creates a new Azure resource group with the provided name,
# location, and tags. It takes in parameters for the resource group name,
# location, owner, cost center, application name, description, and repository.
#
# It assigns the tag values to a hashtable, then passes that hashtable to the
# New-AzResourceGroup command to create the resource group with tags.
#
# It wraps the resource group creation in a try/catch block to handle any errors.
# If an error occurs, it will output debug information and throw a custom error.

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
    Owner       = $owner;
    Costcenter  = $costcenter;
    Application = $application;
    Description = $description;
    Repository  = $Repository
}

try {
    write-host "now creating the resource group"
    write-host "location : ${location}"
    write-host "resource group name : ${recoursegroupname}"
    $deployment = New-AzResourceGroup -Name "${recoursegroupname}" -Location "${location}" -tag ${tag}
    write-host $deployment
}
Catch {
    $message = $_.Exception.Message
    $StackTracetext = $_.Exception.StackTrace
    Write-Host "The script is gefaald door de volgende"
    Write-Host $message
    Write-host $StackTracetext
    throw "script halted"
}