Param(
    [Parameter(Mandatory = $true)][String] $subscriptionId,
    [Parameter(Mandatory = $true)][String] $resourceGroup,
    [Parameter(Mandatory = $true)][String] $automationAccountName,
    [Parameter(Mandatory = $false)][String] $runbookSearchPath = "PSScriptRoot\..\..\..\..\$subscriptionId\$resourceGroup\$automationAccountName"
)

Write-host "Import modules"
try {
    Import-Module AzureRM.Profile
    Import-Module AzureRM.Resources
} catch {
    Write-Host $_.Exception
}

Write-Host "Select subscription"
try {
    $subscription = Get-AzureRmSubscription -SubscriptionId $subscriptionId
    $tenantId = ($subscription | Select-Object TenantId -First 1).TenantId
    Write-Host "$subscription -  $tenantId"
    Select-AzureRmSubscription -TenantId $tenantId -Subscription $subscription
} catch {
    Write-Host $_.Exception
}

Write-Host "Starting Copy-Runbook.ps1 for $subscriptionId - $resourceGroup - $automationAccountName"
try {
    Write-Host "Getting runbooks from $automationAccountName"
    $runbookList = Get-AzureRmAutomationRunbook -ResourceGroupName $ResourceGroup -AutomationAccountName $automationAccountName
    foreach ($runbook in $runbookList) {
        if ((Test-Path "$runbookSearchPath\$($runbook.Name).ps1") -and ($runbook.RunbookType -eq "PowerShell")) {
            Write-Host "  Found matching script $($runbook.Name).ps1 in search folder, importing."
            Import-AzureRmAutomationRunbook -Path "$runbookSearchPath\$($runbook.Name).ps1" -Name $runbook.Name -ResourceGroupName $ResourceGroup -AutomationAccountName $automationAccountName -Type PowerShell -Force
            Write-Host "  Script imported, publishing."
            $runbook | Publish-AzureRmAutomationRunbook
        } elseif ((Test-Path "$PSScriptRoot\..\Runbooks\$($runbook.Name).ps1") -and ($runbook.RunbookType -eq "PowerShell")) {
            Write-Host "  Found matching script $($runbook.Name).ps1 in general folder, importing."
            Import-AzureRmAutomationRunbook -Path "$PSScriptRoot\..\Runbooks\$($runbook.Name).ps1" -Name $runbook.Name -ResourceGroupName $ResourceGroup -AutomationAccountName $automationAccountName -Type PowerShell -Force
            Write-Host "  Script imported, publishing."
            $runbook | Publish-AzureRmAutomationRunbook
        } else {
            Write-Host "  No matching script found for $($runbook.Name), skipping."
        }
    }
    Write-Host "Completed Copy-Runbooks.ps1."
} catch {
    Write-Host $_.Exception
}