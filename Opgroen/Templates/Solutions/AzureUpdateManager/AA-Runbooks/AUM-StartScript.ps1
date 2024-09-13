# Functions #
function Invoke-AzResourceGraphRestQuery
{
  param(
    [parameter(Mandatory = $false)]
    [String] $Uri = 'https://management.azure.com/providers/Microsoft.ResourceGraph/resources?api-version=2021-03-01',
    [parameter(Mandatory = $true)]
    [String] $Query,
    [parameter(Mandatory = $true)]
    [String] $Authorization
  )
  $Data = @()
  $RecordCount = 0
  $RequestBody = @{
    Uri    = $Uri
    Method = 'POST'
    Header = @{
      Accept         = 'application/json'
      'Content-Type' = 'application/json'
      Authorization  = $('Bearer {0}' -f $Authorization)
    }
  }
  $Body = @{
    query = $Query
  } | ConvertTo-Json -Compress
  $Response = (Invoke-WebRequest -UseBasicParsing @RequestBody -Body $Body).Content | ConvertFrom-Json
  $RecordCount = $Response.totalRecords
  $Data = $Response.data

  if ($RecordCount -gt 1000)
  {
    $RecordCount = $RecordCount - 1000
    $End = $false
    $Stop = $false
    do
    {
      $Body = @{
        query   = $Query
        options = @{'$skipToken' = $Response.'$skipToken' }
      } | ConvertTo-Json -Compress
      $Response = (Invoke-WebRequest -UseBasicParsing @RequestBody -Body $Body).Content | ConvertFrom-Json
      $RecordCount = $RecordCount - $Response.count
      $Data += $Response.data
      if ($End) { $Stop = $true }
      if ($RecordCount -lt 1000) { $End = $true }
    }
    until ($Stop)
  }

  return $Data
}
# Functions #

Connect-AzAccount -Identity -ApplicationId $ApplicationId
$Authorization = (Get-AzAccessToken).Token

$notificationPayload = ConvertFrom-Json -InputObject $WebhookData.RequestBody
$maintenanceRunId = $notificationPayload[0].data.CorrelationId
$resourceSubscriptionIds = $notificationPayload[0].data.ResourceSubscriptionIds
$RunId = ($maintenanceRunId).Split('/')
$RunId = $RunId[$RunId.Count - 1]

#https://github.com/azureautomation/runbooks/blob/master/Utility/ARM/Find-WhoAmI
# In order to prevent asking for an Automation Account name and the resource group of that AA,
# search through all the automation accounts in the subscription
# to find the one with a job which matches our job ID
$AutomationResource = Get-AzResource -ResourceType Microsoft.Automation/AutomationAccounts

foreach ($Automation in $AutomationResource)
{
  $Job = Get-AzAutomationJob -ResourceGroupName $Automation.ResourceGroupName -AutomationAccountName $Automation.Name -Id $PSPrivateMetadata.JobId.Guid -ErrorAction SilentlyContinue
  if (!([string]::IsNullOrEmpty($Job)))
  {
    $ResourceGroup = $Job.ResourceGroupName
    $AutomationAccount = $Job.AutomationAccountName
    break;
  }
}
New-AzAutomationVariable -ResourceGroupName $ResourceGroup -AutomationAccountName $AutomationAccount -Name $RunId -Value "" -Encrypted $false

if ($resourceSubscriptionIds.Count -eq 0)
{
  Write-Error "No subscriptions Supplied"
  break
}

$argQuery = @"
maintenanceresources
| where type =~ 'microsoft.maintenance/applyupdates' and properties.correlationId =~ '$($maintenanceRunId)' and id has '/providers/microsoft.compute/virtualmachines/'
| project id, resourceId = tostring(properties.resourceId)
"@

Write-Output "maintenanceresources Query: `r"
Write-Output $argQuery
$VirtualMachines = Invoke-AzResourceGraphRestQuery -Authorization $Authorization -Query $argQuery
if ($VirtualMachines.Count -eq 0)
{
  Write-Output "No Virtual Machines were found."
  break
}

## Get PowerState Query
$Query = @"
resources
| where type == 'microsoft.compute/virtualmachines' and id in~ ({0})
| extend
powerstate = split(todynamic(properties).extended.instanceView.powerState.code,'/')[1]
| project name, id, resourceGroup, subscriptionId, powerstate
"@

foreach ($VM in $VirtualMachines.resourceId) { $VMs += -join ("'{0}'," -f $VM) }
$VMs = $VMs.Substring(0, $VMs.Length - 1)

Write-Output "powerstate Query: `r"
Write-Output $($Query -f $VMS)

$VMsPowerState = Invoke-AzResourceGraphRestQuery -Authorization $Authorization -Query $($Query -f $VMS)
$jobIDs = New-Object System.Collections.Generic.List[System.Object]
$VMList = @()
foreach ($VM in $VMsPowerState)
{
  if ($VM.powerstate -in @("stopped", "stopping", "deallocated", "deallocating"))
  {
    $newJob = Start-ThreadJob -ArgumentList $VM.resourceGroup, $VM.name, $VM.subscriptionId -ScriptBlock { param($resourcegroup, $vmname, $subscription) $context = Set-AzContext -Subscription $subscription; Start-AzVM -ResourceGroupName $resourcegroup -Name $vmname -DefaultProfile $context -Force }
    Write-Output $("Starting Virtual Machine: {0} | JobId: {1}" -f $VM.name, $newJob.Id)
    $jobIDs.Add($newJob.Id)
    $VMList += $VM.id
  }
  else
  {
    Write-Output $("Virtual Machine: {0} Already Started" -f $VM.name)
  }
}

$jobsList = $jobIDs.ToArray()
if ($jobsList)
{
  Write-Output "Waiting for Virtual Machines to finish starting..."
  Wait-Job -Id $jobsList
}

foreach ($id in $jobsList)
{
  $job = Get-Job -Id $id
  if ($job.Error)
  {
    Write-Output $job.Error
  }
}
$VMListCSV = $VMList -join ","
Set-AutomationVariable -Name $RunId -Value $VMListCSV