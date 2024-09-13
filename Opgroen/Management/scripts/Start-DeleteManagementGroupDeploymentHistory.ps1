[CmdletBinding()]
param (
    [Parameter(Mandatory = $true)] [ValidateNotNullOrEmpty()] [string] $ManagementGroupId,
    [Parameter(Mandatory = $false)] [int] $NumberOfDaysToKeep = 90,
    [Parameter(Mandatory = $false)] [string] $LowerLimit = "400",
    [Parameter(Mandatory = $false)] [string] $UpperLimit = "800"
)

$threshold = (Get-Date).ToUniversalTime().AddDays(-$NumberOfDaysToKeep)

#Remove the number of deployments for the specified Management Group based on the last $NumberOfDaysToKeep Days
Try {
    $deploymentsBasedOnDays = Get-AzManagementGroupDeployment -ManagementGroupId $ManagementGroupId -ErrorAction Stop | Where-Object { $_.Timestamp.Date -lt $threshold }
} catch {
    if ($_.exception.message -like "*NotFound*") {
        Write-Warning "No deployments found. No need to continue."
    } else {
        Write-Error $_
    }
}

[int]$deploymentsBasedOnDaysCount = $deploymentsBasedOnDays.Count
Write-Host "Found $deploymentsBasedOnDaysCount deployments based on last $NumberOfDaysToKeep days for $ManagementGroupId Management Group." -ForegroundColor Yellow

if ($deploymentsBasedOnDaysCount -gt $LowerLimit) {
    foreach ($deploymentsBasedOnDays in $deploymentsBasedOnDays) {
        Write-Output "[$(Get-Date)] Deleting Management Group deployment '$($deploymentsBasedOnDays.DeploymentName)' - $($deploymentsBasedOnDays.Timestamp) ..."
        Remove-AzManagementGroupDeployment -ManagementGroupId $ManagementGroupId -Name $deploymentsBasedOnDays.DeploymentName
        Write-Output "[$(Get-Date)] Deleted Management Group deployment '$($deploymentsBasedOnDays.DeploymentName)' - $($deploymentsBasedOnDays.Timestamp)"
    }
} Else {
    Write-Host "Number of deployments for last $NumberOfDaysToKeep days is $deploymentsBasedOnDaysCount less than $LowerLimit."
    Write-Host "No cleanup required for $ManagementGroupId Management Group deployments of the last $NumberOfDaysToKeep."
}

#Remove the number of deployments for the specified Management Group based on lower and upper limit.
Try {
    $deployments = Get-AzManagementGroupDeployment -ManagementGroupId $ManagementGroupId -ErrorAction Stop
} catch {
    if ($_.exception.message -like "*NotFound*") {
        Write-Warning "No deployments found. No need to continue."
    } else {
        Write-Error $_
    }
}

[int]$deploymentsCount = $deployments.Count
Write-Host "Found $deploymentsCount deployments $ManagementGroupId Management Group." -ForegroundColor Yellow

If ($deploymentsCount -ge $LowerLimit -and $deploymentsCount -le $UpperLimit) {
    Write-Host "Removing deployments except for the most recent $LowerLimit." -ForegroundColor Yellow
    $deployments | Select-Object -Skip $LowerLimit | Remove-AzManagementGroupDeployment
} Else {
    Write-Host "Number of deployments is with the range of $LowerLimit-$UpperLimit."
    Write-Host "No cleanup required for $ManagementGroupId Management Group deployments."
}