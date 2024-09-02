<#
.SYNOPSIS
    This script builds the release notes for a specific workload.
.DESCRIPTION
    The script looks for all the tags of a workload and finds the matching PRs based on the commit IDs
    Then the script grabs the release notes, backlog items and contributors from these PRs and combines them into a markdown file
    If a 'workload-v1.0.0' tag doesn't exist yet, the script will exit.
.EXAMPLE

.INPUTS

.OUTPUTS
    The script outputs a markdown file with version number, release notes, backlog items and contributors
.NOTES
#>

$TeamProject = $env:TeamProject
$CollectionUri = $env:CollectionUri
$RepositoryID = $env:RepositoryID
$AzureDevOpsPAT = $env:SYSTEM_ACCESSTOKEN
$outputFile = $env:outputFile
$AzureDevOpsAuthenticationHeader = @{Authorization = 'Basic ' + [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(":$($AzureDevOpsPAT)")) }
$tags = @()

# Install MarkdownPS for wiki layout
Install-Module -Name MarkdownPS -Scope CurrentUser -Force

$markdown = ""

# Find existing tags of the workload
$params = @{
  uri     = "$CollectionUri/$TeamProject/_apis/git/repositories/$RepositoryID/refs?filter=tags/&api-version=6.0"
  Method  = 'GET'
  Headers = $AzureDevOpsAuthenticationHeader
}

$response = Invoke-RestMethod @params

$response.value | Where-Object { $_.name -match "refs/tags/" } | ForEach-Object {
  $objectId = $_.objectId
  $params = @{
    uri     = "$CollectionUri/$TeamProject/_apis/git/repositories/$RepositoryID/annotatedtags/$objectId" + "?api-version=6.0-preview.1"
    Method  = 'GET'
    Headers = $AzureDevOpsAuthenticationHeader
  }

  $tags += Invoke-RestMethod @params
}

# If 'workload-v1.0.0' doesn't exist, exit the script
if ($tags.name -notcontains 'v1.0.0') {
  Write-output "v1.0.0 not found"
  exit
}

# Sort the tags
$ToNatural = { [regex]::Replace($_, '\d+', { $args[0].Value.PadLeft(20) }) }
$tagNames = @($tags.name) | Sort-Object $ToNatural
Write-Output 'Tags found are '$tagNames

# Find PRs that match the commitID of the tags
$params = @{
  uri     = "$CollectionUri/$TeamProject/_apis/git/repositories/$RepositoryID/pullrequests?searchCriteria.status=completed&" + '$top=99999&api-version=6.0'
  Method  = 'GET'
  Headers = $AzureDevOpsAuthenticationHeader
}

$pullRequests = Invoke-RestMethod @params

foreach ($pullRequest in $pullRequests.value) {
  foreach ($tag in $tags) {
    if ($tag.taggedObject.objectId -contains $pullRequest.lastMergeCommit.commitId) {
      Write-output 'Matching PR found based on tag commitId'
      $foundCommit = $true

      # Add version of the workload
      if ($tag.name -eq $tagNames[-1]) {
        $markdown += New-MDHeader "$($tag.name) - Latest"
      }
      else {
        $markdown += New-MDHeader $tag.name
      }

      # Add pull request link of the update
      $mcasCollectionUri = $CollectionUri.replace('.com', '.com.mcas.ms')
      $pullRequestURL = "$mcasCollectionUri/$TeamProject/_git/$RepositoryID/pullrequest/$($pullRequest.pullRequestId)"

      $markdown += "`n"
      $markdown += (New-MDLink -Text "#$($pullRequest.pullRequestId)" -Link $pullRequestURL)
      $markdown += "`n"

      # Add pull request description, or 'Initial Release' when $tag is v1.0.0
      if ($tag.name -eq "v1.0.0") {
        $markdown += New-MDHeader 'Initial Release' -Level 2
        $markdown += "`n"
      }
      else {
        $markdown += New-MDHeader 'Highlights' -Level 2
        $markdown += "`n"
        $markdown += $pullRequest.description.split('Release Notes')[1] + "`n"
      }

      $params = @{
        uri     = "$CollectionUri/$TeamProject/_apis/git/repositories/$RepositoryID/pullrequests/$($pullRequest.pullRequestId)/workitems?api-version=6.0"
        Method  = 'GET'
        Headers = $AzureDevOpsAuthenticationHeader
      }

      $workitems = Invoke-RestMethod @params

      # Add work item links that are attached to the pull request
      if ($workitems.count -ne 0) {
        $markdown += "`n"
        $markdown += New-MDHeader 'Backlog items' -Level 2
        $markdown += "`n"
        foreach ($workitem in $workitems.value.id) {
          $markdown += "#" + $workitem + "`n" + "`n"
        }
      }

      # Add contributors (Releaser + reviewers)
      $markdown += New-MDHeader 'Contributors' -Level 3
      $markdown += "`n"
      $markdown += New-MDImage -Source $pullRequest.createdBy.imageUrl -Title $pullRequest.createdBy.displayName

      $contributors = @()
      $contributors += $pullRequest.createdBy.displayName
      $contributorNames = ''
      $contributorNames += $contributors


      if (-not [string]::IsNullOrEmpty($pullRequest.reviewers.id)) {
        foreach ($reviewer in $pullRequest.reviewers) {
          if ($reviewer.displayName -ne $pullRequest.createdBy.displayName -and $reviewer.displayName -NotMatch '[\[\]\\]') {
            $markdown += ' '
            $markdown += New-MDImage -Source $reviewer.imageUrl -Title $reviewer.displayName
            $contributors += $reviewer.displayName
          }
        }

        foreach ($contributor in $contributors) {
          if ($contributor -eq $contributors[0]) {
            continue
          }
          elseif ($contributor -ne $contributors[-1]) {
            $contributorNames += ', ' + $contributor
          }
          elseif ($contributor -eq $contributors[-1]) {
            $contributorNames += ' and ' + $contributor
          }
        }
      }

      $markdown += "`n" + "`n"
      $markdown += New-MDHeader $contributorNames -Level 6
      $markdown += "`n" + "`n" + '---' + "`n"

      # Quit the loop if v1.0.0 is found, as it's the last tag
      if ($tag.name -eq "v1.0.0") {
        "Tag v1.0.0 found"
        break
      }
    }
  }
}

if (-not $foundCommit) {
  Write-Output 'No pull request was found matching the tag commitId'
  exit
}

# If tag v1.0.0 was created manually, there is no matching PR
if ($markdown -NotMatch '# v1.0.0') {
  $markdown += New-MDHeader 'v1.0.0'
  $markdown += "`n"
  $markdown += New-MDHeader 'Initial Release' -Level 2
  $markdown += "`n"
}
# Output the release notes to md file
$markdown | Out-File $outputFile

