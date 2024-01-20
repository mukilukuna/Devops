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
    $Repository = $Repository
}

try {
    write-host "now creating the recourse group"
    write-host "location : ${location}"
    write-host "resource group name : ${resourcegroupname}"
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