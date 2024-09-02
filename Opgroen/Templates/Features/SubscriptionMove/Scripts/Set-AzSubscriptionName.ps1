<#

.SYNOPSIS
Set Azure Subscription Name

.DESCRIPTION
Rename Azure Subscription

.EXAMPLE
    - task: AzureCLI@2
    displayName: 'Azure CLI  script: Set Azure Subscription Name'
    inputs:
    azureSubscription: ServicePrincipal
    scriptType: pscore
    scriptLocation: 'scriptPath'
    scriptPath: 'Templates\scripts\set-AzSubscriptionName.ps1'
    arguments:
        -SubscriptionName 'sub-gmn-identity-p-weu-01'
        -SubscriptionId 'd772b15c-0edc-4729-9109-0392265bfc76'

    Should be used from a Azure Devops Yaml Pipeline.
.NOTES
    Should be used from a Azure Devops Yaml Pipeline.

#>

[CmdletBinding()]
param (
    [Parameter(Mandatory = $true)] [string] $SubscriptionId,
    [Parameter(Mandatory = $true)] [string] $SubscriptionName
)
$ErrorActionPreference = "Stop"
[Console]::ResetColor()
$scriptName = $MyInvocation.MyCommand.Name

if ($PSVersionTable.PSVersion.Major -lt 7) {
    Write-Error " ## Unable to execute this script using a PowerShell version lower than 7"
    exit 1
}

# =============================================================================
## Get object id for group and the target group
az account set --subscription $SubscriptionId
$existingSubscriptionName = az account show --query name --output tsv

# =============================================================================
## Add created group to the Identity Access Monitoring Group

if ($existingSubscriptionName -eq $SubscriptionName) {
    Write-Host " -- $SubscriptionId already has $SubscriptionName"
    return
}
else {
    [Console]::ResetColor()
    Write-Host "-- Modify Subscription Name"
}

Write-Host "-----------------------------------------------"
Write-Host " -- Current Subscription Name is : ($existingSubscriptionName)"
Write-Host " -- SubscriptionId is : ($SubscriptionId)"
Write-Host " -- Subscription Name will be set to : ($SubscriptionName)"
Write-Host ""
Write-Host "-----------------------------------------------"

az config set extension.use_dynamic_install=yes_without_prompt
az account subscription rename --subscription-id $SubscriptionId --name $SubscriptionName

# =============================================================================

Write-Host "-----------------------------------------------"
Write-Host " -- Script finished ($scriptName)"
Write-Host ""
Write-Host "-----------------------------------------------"

