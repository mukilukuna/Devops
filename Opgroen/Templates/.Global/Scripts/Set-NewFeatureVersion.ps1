<#
.SYNOPSIS
    This script calculates the new version of the repo and sets it as a tag.
.DESCRIPTION
    The script looks for the latest tag of the repo and increments it as needed based on the type of update.
    Based on the last merge commit ID, the script finds the matching PR where the description tells the script what kind of update it is.
    It looks for this PR within the last 10 completed PRs, if this PR can't be found, the script exits.
    If a 'v1.0.0' tag doesn't exist yet, the script will create this tag.
.EXAMPLE
    If the last version of the repo is 'v1.0.0', the new version will be 'v1.0.1' for a fix, 'v1.1.0' for a feature, and 'v2.0.0' for a big feature.
.INPUTS

.OUTPUTS
    The script outputs a tag to Repos -> Tags and uses the new version to rename the pipeline run.
    The script outputs a variable containing the new version number (e.g. 'v1.0.0').
.NOTES
#>

$TeamProject = $env:TeamProject
$CollectionUri = $env:CollectionUri
$RepositoryID = $env:RepositoryID
$objectId = $env:objectId
$AzureDevOpsPAT = $env:SYSTEM_ACCESSTOKEN
$AzureDevOpsAuthenticationHeader = @{Authorization = 'Basic ' + [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(":$($AzureDevOpsPAT)")) }
$tags = @()

# Find existing tags of the repo
$params = @{
  uri     = "$CollectionUri/$TeamProject/_apis/git/repositories/$RepositoryID/refs?filter=tags/&api-version=6.0"
  Method  = 'GET'
  Headers = $AzureDevOpsAuthenticationHeader
}

$response = Invoke-RestMethod @params

$response.value | Where-Object { $_.name -match "refs/tags" } | ForEach-Object {
  $params = @{
    uri     = "$CollectionUri/$TeamProject/_apis/git/repositories/$RepositoryID/annotatedtags/$($_.objectId)" + "?api-version=6.0-preview.1"
    Method  = 'GET'
    Headers = $AzureDevOpsAuthenticationHeader
  }

  $tags += Invoke-RestMethod @params
}

# If 'v1.0.0' doesn't exist, create it and exit the script
if ($tags.name -notcontains 'v1.0.0') {
  Write-output 'v1.0.0 not found'
  $newVersion = 'v1.0.0'
  Write-output 'New version is: '$newVersion
  $body = @{
    name         = $newVersion
    taggedObject = @{
      objectId = $objectId
    }
    message      = 'Release 1.0.0'
  }

  $params = @{
    uri         = "$CollectionUri/$TeamProject/_apis/git/repositories/$RepositoryID/annotatedtags?api-version=7.1-preview.1"
    Method      = 'Post'
    body        = $body | ConvertTo-Json
    Headers     = $AzureDevOpsAuthenticationHeader
    ContentType = 'application/json'
  }
  Invoke-RestMethod @params
  Write-Output "##vso[task.setvariable variable=newVersion;]$newVersion"
  exit
}

# Sort the tags
else {
  $ToNatural = { [regex]::Replace($_, '\d+', { $args[0].Value.PadLeft(20) }) }
  $tagNames = @($tags.name) | Sort-Object $ToNatural
  Write-Output 'Tags found are '$tagNames
}

# Find correct PR within the last 10 completed PRs based on last merge commit ID
$params = @{
  uri     = "$CollectionUri/$TeamProject/_apis/git/repositories/$RepositoryID/pullrequests?searchCriteria.status=completed&" + '$top=10&api-version=6.0'
  Method  = 'GET'
  Headers = $AzureDevOpsAuthenticationHeader
}

$pullRequests = Invoke-RestMethod @params

foreach ($pullRequest in $pullRequests.value) {
  if ($pullRequest.lastMergeCommit.commitId -match $objectId) {
    Write-Output 'Matching PR found based on commitId'
    $foundCommit = $true
    break
  }
  Write-Output 'Pull Request ' $pullRequest.pullRequestId ' doesn`t match commitId'
}

if (-not $foundCommit) {
  Write-Output 'No pull request was found matching the commitId'
  exit
}

# currentVersion is the latest tag, use regex to increment this number based on the type of update to get the newVersion
$currentVersion = $tagNames | Select-Object -Last 1

$currentVersion -match "v(?<Major>\d{1,3}).(?<Minor>\d{1,3}).(?<Patch>\d{1,3})" > $null
Write-Output 'Current version is: '$currentVersion

[int]$currentPatch = [int]$matches['Patch']
[int]$currentMinor = [int]$matches['Minor']
[int]$currentMajor = [int]$matches['Major']

if ($pullRequest.description -match '\[x\] Fix') {
  $currentPatch = $currentPatch + 1
  Write-Output 'This update adds a fix'
}
elseif ($pullRequest.description -match '\[x\] Feature') {
  $currentMinor = $currentMinor + 1
  $currentPatch = 0
  Write-Output 'This update adds a feature'
}
elseif ($pullRequest.description -match '\[x\] Big feature') {
  $currentMajor = $currentMajor + 1
  $currentMinor = 0
  $currentPatch = 0
  Write-Output 'This update adds a big feature'
}
else {
  Write-Error 'No version increased'
}

$newVersion = 'v' + $currentMajor + '.' + $currentMinor + '.' + $currentPatch
if ($currentVersion -ne $newVersion) {
  Write-Output 'New version is: '$newVersion
}

# Create the newVersion tag
$body = @{
  name         = $newVersion
  taggedObject = @{
    objectId = $objectId
  }
  message      = 'Release ' + $currentMajor + '.' + $currentMinor + '.' + $currentPatch
}

$params = @{
  uri         = "$CollectionUri/$TeamProject/_apis/git/repositories/$RepositoryID/annotatedtags?api-version=7.1-preview.1"
  Method      = 'Post'
  body        = $body | ConvertTo-Json
  Headers     = $AzureDevOpsAuthenticationHeader
  ContentType = 'application/json'
}
Invoke-RestMethod @params
# Set Output Variables
Write-Output "##vso[task.setvariable variable=newVersion;]$newVersion"
Write-Host   "##vso[build.updatebuildnumber]$newVersion"