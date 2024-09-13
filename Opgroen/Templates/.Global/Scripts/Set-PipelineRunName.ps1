<#
.SYNOPSIS
    This script calculates the new version of the workload and renames the pipeline run.
.DESCRIPTION
    The script looks for the latest tag of the specific workload and increments it as needed based on the type of update.
    Based on the last merge commit ID, the script finds the matching PR where the description tells the script what kind of update it is.
    It looks for this PR within the last 10 completed PRs, if this PR can't be found, the script exits.
    If a 'workload-v1.0.0' tag doesn't exist yet, the script will create this tag.
.EXAMPLE
    If the last version of the workload is 'workload-v1.0.0', the new version will be 'workload-v1.0.1' for a fix, 'workload-v1.1.0' for a feature, and 'workload-v2.0.0' for a big feature.
.INPUTS

.OUTPUTS
    The script uses the new version to rename the pipeline run.
.NOTES
#>

$TeamProject = $env:TeamProject
$CollectionUri = $env:CollectionUri
$RepositoryID = $env:RepositoryID
$objectId = $env:objectId
$AzureDevOpsPAT = $env:SYSTEM_ACCESSTOKEN
$AzureDevOpsAuthenticationHeader = @{Authorization = 'Basic ' + [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(":$($AzureDevOpsPAT)")) }
$tags = @()

# Install VSTeam to find last 10 active PRs
Install-Module -Name VSTeam -Scope CurrentUser -Force
Set-VSTeamAccount -Account "weareinspark" -PersonalAccessToken $AzureDevOpsPAT

$pullRequestIDs = Get-VSTeamPullRequest -RepositoryId $RepositoryID -Status "Active" -Top 10
$pullRequestIDs = $pullRequestIDs.pullRequestId

# Find existing tags of the workload
$params = @{
  uri     = "$CollectionUri/$TeamProject/_apis/git/repositories/$RepositoryID/refs?filter=tags/&api-version=6.0"
  Method  = 'GET'
  Headers = $AzureDevOpsAuthenticationHeader
}

$response = Invoke-RestMethod @params

$response.value | Where-Object { $_.name -match "refs/tags/v" } | ForEach-Object {
  $objectId = $_.objectId
  $params = @{
    uri     = "$CollectionUri/$TeamProject/_apis/git/repositories/$RepositoryID/annotatedtags/$objectId" + "?api-version=6.0-preview.1"
    Method  = 'GET'
    Headers = $AzureDevOpsAuthenticationHeader
  }

  $tags += Invoke-RestMethod @params
}

# If 'workload-v1.0.0' doesn't exist, rename pipeline run to 'workload-v1.0.0' and exit the script
if ($tags.name -notcontains 'v1.0.0') {
  Write-output 'v1.0.0 not found'
  $newVersion = 'v1.0.0'

  Write-output 'New version is: '$newVersion
  Write-Host   "##vso[build.updatebuildnumber]$newVersion"
  exit
}

# Sort the tags
else {
  $ToNatural = { [regex]::Replace($_, '\d+', { $args[0].Value.PadLeft(20) }) }
  $tagNames = @($tags.name) | Sort-Object $ToNatural
  Write-Output 'Tags found are '$tagNames
}

# Find correct PR within the last 10 active PRs based on last merge commit ID
foreach ($id in $pullRequestIDs) {
  $params = @{
    uri     = "$CollectionUri/$TeamProject/_apis/git/repositories/$RepositoryID/pullrequests/$id" + "?api-version=6.0"
    Method  = 'GET'
    Headers = $AzureDevOpsAuthenticationHeader
  }

  $pullRequest = Invoke-RestMethod @params
  $objectId = $env:objectId
  if ($pullRequest.lastMergeCommit.commitId -match $objectId) {
    Write-output 'Matching PR found based on last merge commitId'
    $foundCommit = $true
    break
  }
  Write-Output 'Pull Request ' $pullRequest.pullRequestId ' doesn`t match last merge commitId'
}

if (-not $foundCommit) {
  Write-Output 'No pull request was found matching the last merge commitId'
  exit
}

# currentVersion is the latest tag, use regex to increment this number based on the type of update to get the newVersion
$currentVersion = $tagNames | Select-object -last 1

$currentVersion -match "v(?<Major>\d{1,3}).(?<Minor>\d{1,3}).(?<Patch>\d{1,3})" > $null
Write-output 'Current version is: '$currentVersion

[int]$currentPatch = [int]$matches['Patch']
[int]$currentMinor = [int]$matches['Minor']
[int]$currentMajor = [int]$matches['Major']

if ($pullRequest.description -match '\[x\] Fix') {
  $currentPatch = $currentPatch + 1
  Write-Output 'This update adds a fix'
}
elseif ($pullRequest.description -match '\[x\] Feature') {
  $currentMinor = $currentMinor + 1
  Write-Output 'This update adds a feature'
}
elseif ($pullRequest.description -match '\[x\] Big feature') {
  $currentMajor = $currentMajor + 1
  Write-Output 'This update adds a big feature'
}
else {
  Write-Error 'Declare if this PR adds a fix, feature, or big feature and re-queue this validation'
}

$newVersion = 'v' + $currentMajor + '.' + $currentMinor + '.' + $currentPatch
if ($currentVersion -ne $newVersion) {
  Write-output 'New version is: '$newVersion
}

# Rename pipeline run
Write-Host   "##vso[build.updatebuildnumber]$newVersion"
