param(
    [parameter(Mandatory=$true)][string]$AzureSubscriptionName,
    [parameter(mandatory=$false)][bool]$simulate = $false
)

$VERSION = "1.0.0"

# Define function to check current time against specified range
function CheckScheduleEntry ([string]$TimeRange)
{	
	# Initialize variables
	$rangeStart, $rangeEnd, $parsedDay = $null
	$currentTime = (Get-Date).ToUniversalTime()
    $midnight = $currentTime.AddDays(1).Date	        

	try
	{
	    # Parse as range if contains '->'
	    if($TimeRange -like "*->*")
	    {
	        $timeRangeComponents = $TimeRange -split "->" | ForEach-Object {$_.Trim()}
	        if($timeRangeComponents.Count -eq 2)
	        {
	            $rangeStart = Get-Date $timeRangeComponents[0]
	            $rangeEnd = Get-Date $timeRangeComponents[1]
	
	            # Check for crossing midnight
	            if($rangeStart -gt $rangeEnd)
	            {
                    # If current time is between the start of range and midnight tonight, interpret start time as earlier today and end time as tomorrow
                    if($currentTime -ge $rangeStart -and $currentTime -lt $midnight)
                    {
                        $rangeEnd = $rangeEnd.AddDays(1)
                    }
                    # Otherwise interpret start time as yesterday and end time as today   
                    else
                    {
                        $rangeStart = $rangeStart.AddDays(-1)
                    }
	            }
	        }
	        else
	        {
	            Write-Output "`tWARNING: Invalid time range format. Expects valid .Net DateTime-formatted start time and end time separated by '->'" 
	        }
	    }
	    # Otherwise attempt to parse as a full day entry, e.g. 'Monday' or 'December 25' 
	    else
	    {
	        # If specified as day of week, check if today
	        if([System.DayOfWeek].GetEnumValues() -contains $TimeRange)
	        {
	            if($TimeRange -eq (Get-Date).DayOfWeek)
	            {
	                $parsedDay = Get-Date "00:00"
	            }
	            else
	            {
	                # Skip detected day of week that isn't today
	            }
	        }
	        # Otherwise attempt to parse as a date, e.g. 'December 25'
	        else
	        {
	            $parsedDay = Get-Date $TimeRange
	        }
	    
	        if($parsedDay -ne $null)
	        {
	            $rangeStart = $parsedDay # Defaults to midnight
	            $rangeEnd = $parsedDay.AddHours(23).AddMinutes(59).AddSeconds(59) # End of the same day
	        }
	    }
	}
	catch
	{
	    # Record any errors and return false by default
	    Write-Output "`tWARNING: Exception encountered while parsing time range. Details: $($_.Exception.Message). Check the syntax of entry, e.g. '<StartTime> -> <EndTime>', or days/dates like 'Sunday' and 'December 25'"   
	    return $false
	}
	
	# Check if current time falls within range
	if($currentTime -ge $rangeStart -and $currentTime -le $rangeEnd)
	{
	    return $true
	}
	else
	{
	    return $false
	}
	
} # End function CheckScheduleEntry


# Function to handle database sizing
function AssertDatabaseSizing($db, $newSize, $simulate) {
    Write-Output $db.DatabaseName
    Write-Output $newSize
    Write-Output $simulate
    try {
        if ($db.CurrentServiceObjectiveName -ne $newSize) {
            if ($simulate) {
                Write-Ouput "Running in simulate mode, not actually resizing database. According to the schedule the database size should be changed to [$newSize]."
            } else {
                Write-Output "Running in live mode. Resizing database to [$newSize]."
                $db | Set-AzureRmSqlDatabase -RequestedServiceObjectiveName $newSize
            }
        } else {
            Write-Output "Database is running at the correct size."
        }
    } catch {
        Write-Output $_.Exception
        throw $_.Exception
    }
}

# Main runbook content
try
{
    $currentTime = (Get-Date).ToUniversalTime()
    Write-Output "Runbook started. Version: $VERSION"
    if($simulate)
    {
        Write-Output "*** Running in simulate mode. No resize actions will be taken. ***"
    }
    else
    {
        Write-Output "*** Running in LIVE mode. Schedules will be enforced. ***"
    }
    Write-Output "Current UTC/GMT time [$($currentTime.ToString("dddd, yyyy MMM dd HH:mm:ss"))] will be checked against schedules"
	
    # Retrieve subscription name from variable asset if not specified
    if($AzureSubscriptionName -eq "Use *Default Azure Subscription* Variable Value")
    {
        $AzureSubscriptionName = Get-AutomationVariable -Name "Default Azure Subscription"
        if($AzureSubscriptionName.length -gt 0)
        {
            Write-Output "Specified subscription name/ID: [$AzureSubscriptionName]"
        }
        else
        {
            throw "No subscription name was specified, and no variable asset with name 'Default Azure Subscription' was found. Either specify an Azure subscription name or define the default using a variable setting"
        }
    }

    # Connecting to Azure using RunAs account
    $connectionName = "AzureRunAsConnection"
    try {
        Write-Output "Connecting to Azure using RunAs account"
        $servicePrincipalConnection = Get-AutomationConnection -Name $connectionName
        Add-AzureRmAccount -ServicePrincipal -TenantId $servicePrincipalConnection.TenantId -ApplicationId $servicePrincipalConnection.ApplicationId -CertificateThumbprint $servicePrincipalConnection.CertificateThumbprint | Out-Null
        Write-Output "Connected"
    } catch {
        if (!$servicePrincipalConnection) {
            Write-Output "Connection $connectionName not found"
        } 
        throw $_.Exception
    }
    

    # Validate subscription
    $subscriptions = @(Get-AzureRmSubscription | Where-Object {$_.SubscriptionName -eq $AzureSubscriptionName -or $_.SubscriptionId -eq $AzureSubscriptionName})
    if($subscriptions.Count -eq 1)
    {
        # Set working subscription
        $targetSubscription = $subscriptions | Select-Object -First 1
        $targetSubscription | Select-AzureRmSubscription | Out-Null
        Write-Output "Working against subscription: $($targetSubscription.SubscriptionName) ($($targetSubscription.SubscriptionId))"
    }
    else
    {
        if($subscription.Count -eq 0)
        {
            throw "No accessible subscription found with name or ID [$AzureSubscriptionName]. Check the runbook parameters and ensure user is a co-administrator on the target subscription."
        }
        elseif($subscriptions.Count -gt 1)
        {
            throw "More than one accessible subscription found with name or ID [$AzureSubscriptionName]. Please ensure your subscription names are unique, or specify the ID instead"
        }
    }

    # Get a list of all SQL Servers in subscription
    Write-Output "Getting list of SQL Servers"
    $sqlServerList = Get-AzureRmSqlServer | Sort-Object Name
    Write-Output "Found [$($sqlServerList.Count)] SQL Servers"

    # For each SQL Database, determine
    #  - Is it tagged for resizing
    #  - Is the current time within the tagged schedule 
    # Then size to the correct sizing based on the assigned schedule
    foreach($sqlServer in $sqlServerList)
    {
        $schedule = $null

        $dbList = Get-AzureRmSqlDatabase -ServerName $sqlServer.ServerName -ResourceGroupName $sqlServer.ResourceGroupName
        foreach($db in $dbList) {
            # Check for tag
            if($db.Tags.Keys -contains "AutoResizeSchedule" -and $db.Tags.Keys -contains "AutoResizeSizes")
            {
                # Database has a tag.
                $schedule = $db.Tags.AutoResizeSchedule
                $sizes = $db.Tags.AutoResizeSizes -split "," | ForEach-Object {$_.Trim()}
                Write-Output "[$($db.DatabaseName)]: Found resizing schedule tag with value: $schedule"
                Write-Output "Database sizing: $sizes"
            }
            else
            {
                # No tag. Skip this database.
                Write-Output "[$($db.DatabaseName)]: Not tagged for resizing. Skipping this database."
                continue
            }

            # Check that tag value was succesfully obtained
            if($schedule -eq $null -or $sizes.length -ne 2)
            {
                Write-Output "[$($vm.DatabaseName)]: Failed to get tagged schedule or sizes. Skipping this database."
                continue
            }

            # Parse the ranges in the Tag value. Expects a string of comma-separated time ranges, or a single time range
            $timeRangeList = @($schedule -split "," | ForEach-Object {$_.Trim()})
            
            # Check each range against the current time to see if any schedule is matched
            $scheduleMatched = $false
            $matchedSchedule = $null
            foreach($entry in $timeRangeList)
            {
                if((CheckScheduleEntry -TimeRange $entry) -eq $true)
                {
                    $scheduleMatched = $true
                    $matchedSchedule = $entry
                    break
                }
            }

            # Enforce desired state for group resources based on result. 
            if($scheduleMatched)
            {
                # Schedule is matched. Resize the DB if it at default size. 
                Write-Output "[$($db.DatabaseName)]: Current time [$currentTime] falls within the scheduled size reduction range [$matchedSchedule]."
                if ($db.CurrentServiceObjectiveName -ne $sizes[1]) {
                    Write-Output "Resizing database to [$($sizes[1])]"
                    AssertDatabaseSizing $db $sizes[1] $simulate
                } else {
                    Write-Output "Database is at the desired size."
                }
            }
            else
            {
                # Schedule not matched. Resize the DB if it is at reduced size.
                Write-Output "[$($db.DatabaseName)]: Current time falls outside of all scheduled size reduction ranges."
                if ($db.CurrentServiceObjectiveName -ne $sizes[0]) {
                    Write-Output "Resizing database to [$($sizes[1])]"
                } else {
                    Write-Output "Database is at the desired size."
                }
                AssertDatabaseSizing $db $sizes[0] $simulate
            }
        }
    }

    Write-Output "Finished processing database schedules"
}
catch
{
    $errorMessage = $_.Exception.Message
    throw "Unexpected exception: $errorMessage"
}
finally
{
    Write-Output "Runbook finished (Duration: $(("{0:hh\:mm\:ss}" -f ((Get-Date).ToUniversalTime() - $currentTime))))"
}
