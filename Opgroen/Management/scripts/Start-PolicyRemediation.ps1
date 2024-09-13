param(
    [Parameter(Mandatory = $false)] [string] $Type,
    [Parameter(Mandatory = $false)] [string] $Id,
    [Parameter(Mandatory = $false)] [bool] $StartPolicyComplianceScan,
    [Parameter(Mandatory = $false)] [bool] $runAsJob
)

# .Import PowerShell Modules
Import-Module -Name Az.Accounts -Force
Import-Module -Name Az.Resources -Force
Import-Module -Name Az.PolicyInsights -Force

switch ($Type) {
    subscription {
        Set-AzContext -SubscriptionId $Id
        if ( $StartPolicyComplianceScan ) {
            Write-Output "Starting Subscription Policy Compliance Scan, this may take 15 minutes"
            Start-AzPolicyComplianceScan
        }
        $nonCompliantPolicies = Get-AzPolicyState -SubscriptionId $Id | Where-Object { $_.ComplianceState -eq "NonCompliant" -and ($_.PolicyDefinitionAction -eq "modify" -or $_.PolicyDefinitionAction -eq "deployIfNotExists" -or $_.PolicyDefinitionAciont -eq "append") -and $_.PolicyAssignmentScope -like "*subscriptions*" }
        foreach ($policy in $nonCompliantPolicies) {
            Write-Output "Start remediation: $($policy.PolicyDefinitionName)"
            if ($policy.PolicyDefinitionReferenceId) {
                Write-Output "SubscriptionInitiative"
                if ( $runAsJob ) {
                    $job = Start-AzPolicyRemediation -Name "rem-$($policy.PolicyDefinitionName)" -PolicyAssignmentId $policy.PolicyAssignmentId -PolicyDefinitionReferenceId $policy.PolicyDefinitionReferenceId -AsJob
                    $job | Wait-Job
                    $remediation = $job | Receive-Job
                }
                else {
                    Start-AzPolicyRemediation -Name "rem-$($policy.PolicyDefinitionName)" -PolicyAssignmentId $policy.PolicyAssignmentId -PolicyDefinitionReferenceId $policy.PolicyDefinitionReferenceId
                }
                Write-Host $remediation
            }
            else {
                Write-Output "SubscriptionPolicy"
                if ( $runAsJob ) {
                    $job = Start-AzPolicyRemediation -Name "rem-$($policy.PolicyDefinitionName)" -PolicyAssignmentId $policy.PolicyAssignmentId -AsJob
                    $job | Wait-Job
                    $remediation = $job | Receive-Job
                }
                else {
                    Start-AzPolicyRemediation -Name "rem-$($policy.PolicyDefinitionName)" -PolicyAssignmentId $policy.PolicyAssignmentId
                }
                Write-Host $remediation
            }
        }
    }
    managementgroup {
        $nonCompliantPolicies = Get-AzPolicyState -ManagementGroupName $Id | Where-Object { $_.ComplianceState -eq "NonCompliant" -and ($_.PolicyDefinitionAction -eq "modify" -or $_.PolicyDefinitionAction -eq "deployIfNotExists" -or $_.PolicyDefinitionAciont -eq "append") -and $_.PolicyAssignmentScope -like "*$Id" }
        if ( $StartPolicyComplianceScan ) {
            Write-Output "Starting Management Group Policy Compliance Scan, this may take 15 minutes"
            Start-AzPolicyComplianceScan
        }
        foreach ($policy in $nonCompliantPolicies) {
            Write-Output "Start Management Group remediation: $($policy.PolicyDefinitionName)"
            if ($policy.PolicyDefinitionReferenceId) {
                Write-Output "ManagementGroupInitiative"
                if ( $runAsJob ) {
                    $job = Start-AzPolicyRemediation -ManagementGroupName $Id -Name "rem-$($policy.PolicyDefinitionName)" -PolicyAssignmentId $policy.PolicyAssignmentId -PolicyDefinitionReferenceId $policy.PolicyDefinitionReferenceId -AsJob
                    $job | Wait-Job
                    $remediation = $job | Receive-Job
                }
                else {
                    Start-AzPolicyRemediation -ManagementGroupName $Id -Name "rem-$($policy.PolicyDefinitionName)" -PolicyAssignmentId $policy.PolicyAssignmentId -PolicyDefinitionReferenceId $policy.PolicyDefinitionReferenceId
                }
                Write-Host $remediation
            }
            else {
                Write-Output "ManagementGroupPolicy"
                if ($runAsJob ) {
                    $job = Start-AzPolicyRemediation -ManagementGroupName $Id -Name "rem-$($policy.PolicyDefinitionName)" -PolicyAssignmentId $policy.PolicyAssignmentId -AsJob
                    $job | Wait-Job
                    $remediation = $job | Receive-Job
                }
                else {
                    Start-AzPolicyRemediation -ManagementGroupName $Id -Name "rem-$($policy.PolicyDefinitionName)" -PolicyAssignmentId $policy.PolicyAssignmentId
                }
                Write-Host $remediation
            }
        }
    }
    resourcegroup {
        $nonCompliantPolicies = Get-AzPolicyState -ResourceGroupName $Id | Where-Object { $_.ComplianceState -eq "NonCompliant" -and ($_.PolicyDefinitionAction -eq "modify" -or $_.PolicyDefinitionAction -eq "deployIfNotExists" -or $_.PolicyDefinitionAciont -eq "append") -and $_.PolicyAssignmentScope -like "*$Id*" }
        Set-AzContext -SubscriptionId $Id
        if ( $StartPolicyComplianceScan ) {
            Write-Output "Starting Resource Group Policy Compliance Scan, this may take 15 minutes"
            Start-AzPolicyComplianceScan -ResourceGroupName $Id
        }
        foreach ($policy in $nonCompliantPolicies) {
            Write-Output "Start remediation: $($policy.PolicyDefinitionName)"
            if ($policy.PolicyDefinitionReferenceId) {
                Write-Output "ResourceGroupInitiative"
                if ($runAsJob ) {
                    $job = Start-AzPolicyRemediation -Name "rem-$($policy.PolicyDefinitionName)" -PolicyAssignmentId $policy.PolicyAssignmentId -PolicyDefinitionReferenceId $policy.PolicyDefinitionReferenceId -AsJob
                    $job | Wait-Job
                    $remediation = $job | Receive-Job
                }
                else {
                    Start-AzPolicyRemediation -Name "rem-$($policy.PolicyDefinitionName)" -PolicyAssignmentId $policy.PolicyAssignmentId -PolicyDefinitionReferenceId $policy.PolicyDefinitionReferenceId
                }
                Write-Host $remediation
            }
            else {
                Write-Output "ResourceGroupPolicy"
                if ( $runAsJob ) {
                    $job = Start-AzPolicyRemediation -Name "rem-$($policy.PolicyDefinitionName)" -PolicyAssignmentId $policy.PolicyAssignmentId -AsJob
                    $job | Wait-Job
                    $remediation = $job | Receive-Job
                }
                else {
                    Start-AzPolicyRemediation -Name "rem-$($policy.PolicyDefinitionName)" -PolicyAssignmentId $policy.PolicyAssignmentId
                }
                Write-Host $remediation
            }
        }
    }
}