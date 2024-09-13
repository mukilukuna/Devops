<#
.SYNOPSIS
    This script creates snippets for the InSpark YAML structure and all features and solutions.
.DESCRIPTION
    The script looks for all features and solutions and loops through them to create a snippet for each.
    Based on the scope of the feature/solution, a snippet will be built.
    The InSpark YAML structure is hardcoded in the $mainSnippets variable.
.EXAMPLE

.INPUTS

.OUTPUTS
    The script outputs a snippets file to the .vscode folder, named yaml.code-snippets. It contains all the snippets for the InSpark YAML structure, features and solutions.
.NOTES
#>

# Collect all feature and solution names
$featuresPath = Join-Path -ChildPath 'Features' -Path (Split-Path -Parent -Path (Split-Path -Parent -Path $PSScriptRoot))
$solutionsPath = Join-Path -ChildPath 'Solutions' -Path (Split-Path -Parent -Path (Split-Path -Parent -Path $PSScriptRoot))
$features = (Get-ChildItem -path $featuresPath).name
$solutions = (Get-ChildItem -path $solutionsPath).name
$features += $solutions
$features = $features | Sort-Object

Write-Verbose "Features path is $featuresPath"
Write-Verbose "Solutions path is $solutionsPath"

# Create YAML structure snippets
$snippets = ""
$mainSnippets = @"
{
  "MainYaml": {
    "prefix": "InSpark-MainYaml",
    "body": [
      "trigger: none",
      "",
      "pool:",
      "  vmImage: 'ubuntu-latest'",
      "",
      "resources:",
      "  repositories:",
      "    - repository: templates",
      "      type: git",
      "      name: BRCTemplates",
      "",
      "variables:",
      "  - template: ./variables.yaml # Global Variables",
      "",
      "stages:",
      "  - template: stages/<stageName>.yaml",
      "    parameters:",
      "      azureResourceManagerConnection: `$(azureResourceManagerConnection)",
      "      subscriptionId: `$(subscriptionId)",
      "      variableGroup: `$(variableGroup)",
      "      variableFile: /variables.yaml",
      "",
      "  "
    ],
    "description": "Main Yaml Template",
    "scope": "yaml, azure-pipelines"
  },
  "StageReference": {
    "prefix": "InSpark-NewStageReference",
    "body": [
      "- template: stages/<stageName>.yaml",
      "  parameters:",
      "    azureResourceManagerConnection: `$(azureResourceManagerConnection)",
      "    subscriptionId: `$(subscriptionId)",
      "    variableGroup: `$(variableGroup)",
      "    variableFile: /variables.yaml",
      "",
      "  "
    ],
    "description": "Stage Reference Template",
    "scope": "yaml, azure-pipelines"
  },
  "Stage": {
    "prefix": "InSpark-NewStage",
    "body": [
      "parameters:",
      "  - name: azureResourceManagerConnection",
      "    type: string",
      "  - name: location",
      "    type: string",
      "    default: 'westeurope'",
      "  - name: subscriptionId # Replace with or add managementGroupId if needed",
      "    type: string",
      "  - name: variableGroup",
      "    type: string",
      "  - name: variableFile",
      "    type: string",
      "  - name: AZURE_DEVOPS_EXT_PAT",
      "    type: string",
      "    default: `$(System.AccessToken)",
      "  - name: organization",
      "    type: string",
      "    default: `$(System.TeamFoundationCollectionUri)",
      "  - name: project",
      "    type: string",
      "    default: `$(System.TeamProject)",
      "",
      "stages:",
      "  - stage: <stageName>",
      "    displayName: <displayName>",
      "    variables:",
      "    - template: `${{ parameters.variableFile }}",
      "",
      "    jobs:",
      "      - job: <jobName>",
      "        displayName: <displayName>",
      "        dependsOn: # Optional dependencies",
      "        steps:",
      "          "
    ],
    "description": "Stage Template",
    "scope": "yaml, azure-pipelines"
  },
  "Job": {
    "prefix": "InSpark-NewJob",
    "body": [
      "- job: <jobName>",
      "  displayName: <displayName>",
      "  dependsOn: # Optional dependencies",
      "  steps:",
      "    "
    ],
    "description": "Job Template",
    "scope": "yaml, azure-pipelines"
  },
  "AddIdVariableToVariableGroup": {
    "prefix": "InSpark-AddIdVariableToVariableGroup",
    "body": [
      "- `${{ if eq(variables['Build.SourceBranch'], 'refs/heads/main') }}:",
      "  - template: /.Global/Pipelines/addVariableToVariableGroup.yaml@Templates",
      "    parameters:",
      "      AZURE_DEVOPS_EXT_PAT: `${{ parameters.AZURE_DEVOPS_EXT_PAT }}",
      "      organization: `${{ parameters.organization }}",
      "      project: `${{ parameters.project }}",
      "      varKey: `$(outputPrefix)-<resource>Id",
      "      varValue: `$(resourceId)",
      "      isSecret: false",
      "      environment: `${{ parameters.variableGroup }}",
      "      templateRepo: `${{ variables.templateRepo }}",
      "",
      ""
    ],
    "description": "Add Resource Id Variable To Variable Group",
    "scope": "yaml, azure-pipelines"
  },
  "AddNameVariableToVariableGroup": {
    "prefix": "InSpark-AddNameVariableToVariableGroup",
    "body": [
      "- `${{ if eq(variables['Build.SourceBranch'], 'refs/heads/main') }}:",
      "  - template: /.Global/Pipelines/addVariableToVariableGroup.yaml@Templates",
      "    parameters:",
      "      AZURE_DEVOPS_EXT_PAT: `${{ parameters.AZURE_DEVOPS_EXT_PAT }}",
      "      organization: `${{ parameters.organization }}",
      "      project: `${{ parameters.project }}",
      "      varKey: `$(outputPrefix)-<resource>Name",
      "      varValue: `$(resourceName)",
      "      isSecret: false",
      "      environment: `${{ parameters.variableGroup }}",
      "      templateRepo: `${{ variables.templateRepo }}",
      "",
      ""
    ],
    "description": "Add Resource Name Variable To Variable Group",
    "scope": "yaml, azure-pipelines"
  },
"@

$snippets += $mainSnippets

# Loop through all features and solutions and create snippets for each
foreach ($feature in $features) {
  # Check if current item is a feature or solution and set workloadType accordingly
  if ($solutions -contains $feature) {
    $workloadTypeDescription = "Solution"
    $workloadType = "Solutions"
    $path = $solutionsPath
  }
  else {
    $workloadTypeDescription = "Feature"
    $workloadType = "Features"
    $path = $featuresPath
  }

  if (-Not (Test-Path -path $path\$feature\template.bicep)) {
    continue
  }

  # Create general part of the snippet
  $newsnippet = @"

  "$feature": {
    "prefix": "InSpark-$feature",
    "body": [
      "- template: /$workloadType/$feature/Pipeline/tasks.yaml@templates",
      "  parameters:",
      "    azureResourceManagerConnection: `${{ parameters.azureResourceManagerConnection }}",
      "    templateRepo: `${{ variables.templateRepo }}",
      "    templateProject: `${{ variables.templateProject }}",
      "    version: `${{ variables.version }}",
"@
  # Create Tenant level snippet
  if (Select-String -path $path\$feature\template.bicep -pattern "targetScope = 'tenant'") {
    $newsnippet += @"

      "    csmParametersFile: /parameters/`$(tenantName)/$feature.json",
"@
  }
  # Create Management Group level snippet
  elseif (Select-String -path $path\$feature\template.bicep -pattern "targetScope = 'managementGroup'") {
    $newsnippet += @"

      "    csmParametersFile: /parameters/`$(managementGroupName)/$feature.json",
      "    managementGroupId: `${{ parameters.managementGroupId }}",
      "    location: `${{ parameters.location }}",
"@
  }
  # Create Subscription level snippet
  elseif (Select-String -path $path\$feature\template.bicep -pattern "targetScope = 'subscription'") {
    $newsnippet += @"

      "    csmParametersFile: /parameters/`$(subscriptionName)/$feature.json",
      "    subscriptionId: `${{ parameters.subscriptionId }}",
      "    location: `${{ parameters.location }}",
"@
  }
  # Create Resource Group level snippet
  else {
    $newsnippet += @"

      "    csmParametersFile: /parameters/`$(resourceGroupName)/$feature.json",
      "    subscriptionId: `${{ parameters.subscriptionId }}",
      "    resourceGroupName: `$(resourceGroupName)",
      "    location: `${{ parameters.location }}",
"@
  }
  # If the feature is 'SubscriptionMove', add specific part for this feature
  if ($feature -eq 'SubscriptionMove') {
    $newsnippet += @"

      "    # Optional. Set both if you want to set the subscription name. subscriptionId: `${{ parameters.subscriptionId }}",
      "    # Optional. Set both if you want to set the subscription name. subscriptionName: `$(subscriptionName)",
"@
  }
  # Create general part of the snippet
  $newsnippet += @"

      "",
      ""
    ],
    "description": "$workloadTypeDescription`: $feature",
    "scope": "yaml, azure-pipelines"
"@
  # Check to see if the current item is the last feature to correctly finish the file
  if ($feature -ne $features[-1]) {
    $newsnippet += @"

  },
"@
  }
  else {
    $newsnippet += @"

  }
}
"@

  }
  # Add the new snippet to the list of snippets
  $snippets += $newsnippet
}
# Set the content of the snippets file
Set-Content -path (Join-Path -ChildPath '.vscode\yaml.code-snippets' -Path (Split-Path -Parent -Path (Split-Path -Parent -Path $PSScriptRoot))) -value $snippets
Write-Output 'Snippets created'
