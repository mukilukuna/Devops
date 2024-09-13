<#
.SYNOPSIS
  This script builds BRCTemplates features and solutions based on BRCModules.
.DESCRIPTION
  The script finds the latest tags for all features and solutions in BRCModules and uses these for the module reference in the template.bicep files in BRCTemplates.
  All parameters, output and their descriptions are also copied from BRCModules and the template.bicep files in BRCTemplates are built by using this information.
  Based on the scope of the feature/solution, the corresponding tasks.yaml file is copied and the feature.tests.ps1 file is copied aswell.
.EXAMPLE

.INPUTS

.OUTPUTS
  A folder for each feature and solution in BRCTemplates containing template.bicep, Pipeline/tasks.yaml, and Tests/feature.tests.ps1
.NOTES
#>

$TeamProject = 'BusinessReadyCloud'
$CollectionUri = 'https://dev.azure.com/weareinspark'
$RepositoryID = 'e56d0d44-3474-4359-b094-8ceab571d92c'
$tags = @()
# Run the command below if you're not logged into the IURCSC tenant yet
# Connect-AzAccount -tenantid '6a56fe50-e9d9-477f-9831-e42147c8f9d4'
$AzureDevOpsPAT = Get-AzKeyVaultSecret -VaultName 'sha-kv-01' -Name 'Templates' -AsPlainText
$AzureDevOpsAuthenticationHeader = @{Authorization = 'Basic ' + [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(":$($AzureDevOpsPAT)")) }

# Find existing tags of the repo
$params = @{
  uri     = "$CollectionUri/$TeamProject/_apis/git/repositories/$RepositoryID/refs?filter=tags/&api-version=6.0"
  Method  = 'GET'
  Headers = $AzureDevOpsAuthenticationHeader
}

$response = Invoke-RestMethod @params

$response.value | Where-Object { $_.name -match "refs/tags" } | ForEach-Object {
  $objectId = $_.objectId
  $params = @{
    uri     = "$CollectionUri/$TeamProject/_apis/git/repositories/$RepositoryID/annotatedtags/$objectId" + "?api-version=6.0-preview.1"
    Method  = 'GET'
    Headers = $AzureDevOpsAuthenticationHeader
  }

  $tags += Invoke-RestMethod @params
}

# Sort the tags
$sortTags = { [regex]::Replace($_, '\d+', { $args[0].Value.PadLeft(20) }) }
$tags = @($tags.name) | Sort-Object $sortTags

$tagNames = @()
for ($i = 0; $i -le ($tags.Length - 2); $i += 1) {

  if ([regex]::Replace($tags[$i], '-v\d+.\d+.\d+', '') -ne [regex]::Replace($tags[$i + 1], '-v\d+.\d+.\d+', '')) {
    $tagNames += $tags[$i]
  }
}

# Collect all feature and solution names
$BRCTemplates = Split-Path -Parent -Path (Split-Path -Parent -Path $PSScriptRoot)
$modulesFeaturesPath = Join-Path -ChildPath 'Features' -Path (Join-Path -ChildPath 'BRCModules' -Path (
    Split-Path -Parent -Path (Split-Path -Parent -Path (Split-Path -Parent -Path $PSScriptRoot))))
$modulesSolutionsPath = Join-Path -ChildPath 'Solutions' -Path (Join-Path -ChildPath 'BRCModules' -Path (
    Split-Path -Parent -Path (Split-Path -Parent -Path (Split-Path -Parent -Path $PSScriptRoot))))

$features = (Get-ChildItem -path $modulesFeaturesPath).name
$solutions = (Get-ChildItem -path $modulesSolutionsPath).name
$features += $solutions

# Collect script and tasks.yaml content
$testScript = Get-Content -path $BRCTemplates\.Global\Scripts\feature.tests.ps1
$taskYamlRg = Get-Content -path $BRCTemplates\.Global\Pipelines\Templates\tasksRG.yaml
$taskYamlSub = Get-Content -path $BRCTemplates\.Global\Pipelines\Templates\tasksSub.yaml
$taskYamlMg = Get-Content -path $BRCTemplates\.Global\Pipelines\Templates\tasksMG.yaml
$taskYamlTenant = Get-Content -path $BRCTemplates\.Global\Pipelines\Templates\tasksTenant.yaml

# Matches everything up to 'var <word> =', 'resource <word> '', or 'module <word> ''. -> https://regex101.com/r/yKeOzO/2
$paramRegex = "[\s\S]+?(?=(var \w+ =|resource \w+ '|module \w+ '))"
# Matches the word after the string 'param '. -> https://regex101.com/r/MzBdRD/1
$paramNamesRegex = "(?<=\bparam )(\w+)"

foreach ($feature in $features) {
  $tagFound = $false
  # Find matching tag based on feature
  foreach ($tagName in $tagNames) {
    if ($tagName.Split('-')[0] -eq $feature) {
      $tagVersion = $tagName.split('-')[1]
      $tagFound = $true
      break
    }
  }

  if (-Not $tagFound) {
    continue
  }

  if ($solutions -contains $feature) {
    $workloadType = 'Solutions'
    $path = $modulesSolutionsPath
  }
  else {
    $workloadType = 'Features'
    $path = $modulesFeaturesPath
  }

  if ((Get-ChildItem -path $path/$feature).name -contains 'unique') {
    continue
  }

  # Check if template.bicep and pipelines are present in BRCModules, if so, create new template and pipeline files in BRCTemplates
  if ((Test-Path -path $path\$feature\template.bicep) -and (Test-Path -path $path\$feature\Pipelines)) {
    New-Item -path $BRCTemplates\$workloadType\$feature\template.bicep,
    $BRCTemplates\$workloadType\$feature\Pipeline\tasks.yaml -force
    # Create script file and set the content of the script file if it doesn't exist yet
    if (-Not (Test-Path $BRCTemplates\$workloadType\$feature\Tests)) {
      New-Item -path $BRCTemplates\$workloadType\$feature\Tests -ItemType "directory"
    }
    if (-Not (Test-Path $BRCTemplates\$workloadType\$feature\Tests\feature.tests.ps1)) {
      New-Item -path $BRCTemplates\$workloadType\$feature\Tests\feature.tests.ps1 -ItemType "file"
      Set-Content -path $BRCTemplates\$workloadType\$feature\Tests\feature.tests.ps1 -value $testScript
    }
    $tasks = (Get-ChildItem -Path (Join-Path 'Pipelines\Templates' -Path (Split-Path -Parent -Path $PSScriptRoot))).name
    $tasks = $tasks.replace('tasks', '').replace('.yaml', '')

    if ($tasks -contains $feature) {
      Get-Content -path $BRCTemplates\.Global\Pipelines\Templates\tasks$feature.yaml | Set-Content -path $BRCTemplates\$workloadType\$feature\Pipeline\tasks.yaml
    }
    # Create Tenant level tasks.yaml
    elseif (Select-String -path $path\$feature\template.bicep -pattern "targetScope = 'tenant'") {
      $taskYamlTenant.Replace("<workloadName>", $feature).Replace("<workloadType>", $workloadType) | Set-Content -path $BRCTemplates\$workloadType\$feature\Pipeline\tasks.yaml
    }
    # Create Management Group level tasks.yaml
    elseif (Select-String -path $path\$feature\template.bicep -pattern "targetScope = 'managementGroup'") {
      $taskYamlMg.Replace("<workloadName>", $feature).Replace("<workloadType>", $workloadType) | Set-Content -path $BRCTemplates\$workloadType\$feature\Pipeline\tasks.yaml
    }
    # Create Subscription level tasks.yaml
    elseif (Select-String -path $path\$feature\template.bicep -pattern "targetScope = 'subscription'") {
      $taskYamlSub.Replace("<workloadName>", $feature).Replace("<workloadType>", $workloadType) | Set-Content -path $BRCTemplates\$workloadType\$feature\Pipeline\tasks.yaml
    }
    # Create Resource Group level tasks.yaml
    else {
      $taskYamlRg.Replace("<workloadName>", $feature).Replace("<workloadType>", $workloadType) | Set-Content -path $BRCTemplates\$workloadType\$feature\Pipeline\tasks.yaml
    }

    if ((get-content -path $path\$feature\template.bicep -raw) -match $paramRegex) {

      $template = ""
      # Add parameters with descriptions to template and remove commented lines. -> https://regex101.com/r/ke63aV/1
      $template += $matches[0] -replace '(?m)^\/\/.*$'
      # Remove time parameter and its description if present. -> https://regex101.com/r/DRtSwf/1
      $template = $template -replace '(?(@description)(((.*(\n|\r|\r\n)){1})param time string = .*)|param time string = .*)'
      # If there are more than 3 line breaks after each other, replace with only 3. -> https://regex101.com/r/CSwoOa/1
      $template = $template -replace '(\r?\n){3,}', "`n`n`n"
      # Find all parameter names
      $parameters = ($template | Select-String -pattern $paramNamesRegex -AllMatches | ForEach-Object Matches).value
      $params = ""
      $featureToLower = $feature.ToLower()
      # Build the module parameters of the template
      foreach ($parameter in $parameters) {
        if ($parameter -ne 'time') {
          $params += @"

    $parameter`: $parameter
"@
        }
      }
      # Build the module reference part of the template
      $module = @"
@description('Optional. Time parameter to create unique deployment. Do not set in parameter file!')
param time string = replace(utcNow(), ':', '-')

module $feature 'br/Bicep$workloadType`:$featureToLower`:$tagVersion' = {
  name: '$feature-`${time}'
  params: {$params
  }
}


"@
      $template += $module
      # Looks for the word 'output', followed by 2 words and '=' , and matches the word after 'output'. -> https://regex101.com/r/Z5VzCB/1
      $outputNamesRegex = "(?<=\boutput )(\w+)(?= \w+ =)"
      $outputNames = ((get-content -path $path\$feature\template.bicep -raw) | Select-String -pattern $outputNamesRegex -AllMatches | ForEach-Object Matches).value

      # Looks for lines that start with the word 'output', followed by 2 words, '=', and anything after that. Matches this line, and the line before that if '@description' is found. -> https://regex101.com/r/GQvZOQ/2
      $outputRegex = "(?(@description)(((.*(\n|\r|\r\n)){1})output \w+ \w+ = .*)|output \w+ \w+ = .*)"
      $output = (((get-content -path $path\$feature\template.bicep -raw) | Select-String -pattern $outputRegex -AllMatches | ForEach-Object Matches).value) -replace "(?<= = )('\`${|[\[\]{}'])"

      # Looks for ' = ' and matches the rest of the line after. -> https://regex101.com/r/Jfu7hR/1
      $outputValueRegex = "(?<= = ).*"
      $outputValue = ((($output | Select-String -pattern $outputValueRegex -AllMatches) | ForEach-Object Matches).value) -replace "(?<= = )('\`${|[\[\]{}'])"

      $i = 0
      foreach ($match in $outputValue) {
        $outputName = $outputnames[$i]
        $match = [Regex]::Escape($match)
        $output = $output -replace "\b$match(\b|$)", "$feature.outputs.$outputName`n`r"
        $i += 1
      }

      $template += $output
      # Remove whitespace in front of '@description'
      $template = $template -replace '\s(?=@description)'
      # Set content of the template.bicep file
      Set-Content -path $BRCTemplates\$workloadType\$feature\template.bicep -value $template
    }
  }
}


