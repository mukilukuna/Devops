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
$VMList = (Get-AutomationVariable -Name $RunId) -split ","
$VMS = @()
foreach ($VM in $VMList)
{
  $VMSplit = ($VM).Split('/')
  $VMs += @{
    subscriptionId = $VMSplit[2]
    resourceGroup  = $VMSplit[4]
    name           = $VMSplit[8]
  }
}
$jobIDs = New-Object System.Collections.Generic.List[System.Object]
foreach ($VM in $VMs)
{
  $newJob = Start-ThreadJob -ArgumentList $VM.resourceGroup, $VM.name, $VM.subscriptionId -ScriptBlock { param($resourcegroup, $vmname, $subscription) $context = Set-AzContext -Subscription $subscription; Stop-AzVM -ResourceGroupName $resourcegroup -Name $vmname -DefaultProfile $context -Force }
  $jobIDs.Add($newJob.Id)
}

$jobsList = $jobIDs.ToArray()
if ($jobsList)
{
  Write-Output "Waiting for Virtual Machines to finish stopping..."
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
Remove-AzAutomationVariable -AutomationAccountName $AutomationAccount -ResourceGroupName $ResourceGroup -Name $RunId