Param(
    [Parameter(Mandatory = $true)][String] $subscriptionId,
    [Parameter(Mandatory = $true)][String] $resourceGroup,
    [Parameter(Mandatory = $true)][String] $automationAccountName,
    [Parameter(Mandatory = $true)][String] $scheduleSearchPath
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

Write-Host "Starting Create-JobsSchedules.ps1 for $subscriptionId - $resourceGroup - $automationAccountName"
Write-Host "  Looking for schedule definition file."
try {
    if (Test-Path -Path $scheduleSearchPath\Schedules.json) {
        Write-Host "  Found schedule definition file, processing."
        $Schedules = Get-Content -Path $scheduleSearchPath\Schedules.json | ConvertFrom-Json
        Write-Host "  Found $($Schedules.Count) schedule specifications."
        foreach ($Schedule in $Schedules) {
            $StartTime = (Get-Date).Date.AddMinutes((New-TimeSpan -End $Schedule.StartTime -Start (Get-Date $Schedule.StartTime).Date).TotalMinutes)
            if ($StartTime -le (Get-Date).AddMinutes(15)) { $StartTime = $StartTime.AddDays(1) }
            $ExistingSchedule = Get-AzureRmAutomationSchedule -ResourceGroupName $resourceGroup -AutomationAccountName $automationAccountName -Name $Schedule.name -ErrorAction SilentlyContinue
            if (!$ExistingSchedule -or `
                    ((New-TimeSpan -Start (Get-Date $ExistingSchedule.StartTime.DateTime).Date -End (Get-Date $ExistingSchedule.StartTime.DateTime)) -ne ((New-TimeSpan -Start (Get-Date $Schedule.StartTime).Date -End (Get-Date $Schedule.StartTime)))) -or `
                    ($ExistingSchedule.Frequency -ne $Schedule.Frequency) -or `
                    ($ExistingSchedule.Interval -ne $Schedule.Interval) -or `
                    ($ExistingSchedule.TimeZone -ne $Schedule.TimeZone)) {
                if ($ExistingSchedule) {
                    Write-Host "  Found existing schedule with different specifications, removing."
                    Get-AzureRmAutomationScheduledRunbook -ResourceGroupName $resourceGroup -AutomationAccountName $automationAccountName -ScheduleName $Schedule.name | Unregister-AzureRmAutomationScheduledRunbook -Force
                    Remove-AzureRmAutomationSchedule -ResourceGroupName $resourceGroup -AutomationAccountName $automationAccountName -Name $Schedule.name
                }
                Write-Host "  Creating new schedule $($Schedule.name)."
                if ($Schedule.Frequency -eq "Hour") {
                    New-AzureRmAutomationSchedule -ResourceGroupName $resourceGroup -AutomationAccountName $automationAccountName -Name $Schedule.name -StartTime $StartTime -ExpiryTime $Schedule.ExpiryTime -HourInterval $Schedule.Interval -TimeZone $Schedule.TimeZone
                } elseif ($Schedule.Frequency -eq "Week") {
                    New-AzureRmAutomationSchedule -ResourceGroupName $resourceGroup -AutomationAccountName $automationAccountName -Name $Schedule.name -StartTime $StartTime -ExpiryTime $Schedule.ExpiryTime -DayInterval $Schedule.Interval -TimeZone $Schedule.TimeZone
                } elseif ($Schedule.Frequency -eq "Week") {
                    New-AzureRmAutomationSchedule -ResourceGroupName $resourceGroup -AutomationAccountName $automationAccountName -Name $Schedule.name -StartTime $StartTime -ExpiryTime $Schedule.ExpiryTime -WeekInterval $Schedule.Interval -TimeZone $Schedule.TimeZone
                } elseif ($Schedule.Frequency -eq "Month") {
                    New-AzureRmAutomationSchedule -ResourceGroupName $resourceGroup -AutomationAccountName $automationAccountName -Name $Schedule.name -StartTime $StartTime -ExpiryTime $Schedule.ExpiryTime -MonthInterval $Schedule.Interval -TimeZone $Schedule.TimeZone
                }
            } else {
                Write-Host "  An existing schedule with the same specifications exists, skipping."
            }
        }
    } else {
        Write-Host "  No schedule definition file found."
    }
} catch {
    Write-Host $_.Exception
}

Write-Host "  Looking for job definition file."
try {
    if (Test-Path -Path $scheduleSearchPath\Jobs.json) {
        Write-Host "  Found job definition file, processing."
        $Jobs = Get-Content -Path $scheduleSearchPath\Jobs.json | ConvertFrom-Json
        Write-Host "  Found $($Schedules.Count) job specifications."
        foreach ($Job in $Jobs) {
            $ExistingJob = Get-AzureRmAutomationScheduledRunbook -ResourceGroupName $resourceGroup -AutomationAccountName $automationAccountName -ScheduleName $Job.schedule -RunbookName $Job.runbook -ErrorAction SilentlyContinue
            if (!$ExistingJob -or ($ExistingJob.Parameters -ne $Job.Parameters)) {
                if ($ExistingJob) {
                    Write-Host "  Found existing job with different parameters, removing."
                    Unregister-AzureRmAutomationScheduledRunbook -ResourceGroupName $resourceGroup -AutomationAccountName $automationAccountName -ScheduleName $Job.schedule -RunbookName $Job.runbook -Force
                }
                Write-Host "  Creating new job for runbook $($Job.runbook) and schedule $($Job.schedule)."
                $parameters = @{}
                foreach ($property in $Job.parameters.PSObject.Properties) { $parameters[$property.Name] = $property.Value }
                Register-AzureRmAutomationScheduledRunbook -ResourceGroupName $resourceGroup -AutomationAccountName $automationAccountName -ScheduleName $Job.schedule -RunbookName $Job.runbook -Parameters $parameters
            }
        }
    } else {
        Write-Host "  No job definition file found."
    }
} catch {
    Write-Host $_.Exception
}

Write-Host "Completed Create-JobsSchedules.ps1."
