$requestbody = @{
    Uri         = 'https://management.azure.com/subscriptions/{0}/resourceGroups/{1}/providers/Microsoft.Automation/automationAccounts/{2}/runbooks/{3}/draft/content?api-version=2019-06-01' -f $SubscriptionId, $ResourceGroupName, $AutomationAccountName, $runbookName
    Method      = 'PUT'
    ContentType = 'text/powershell'
    Headers     = @{
        Authorization = "Bearer $AccessToken"
    }
}
$Response = Invoke-WebRequest -SkipHttpErrorCheck @requestbody -Body $(Get-Content -Path $RunbookPath | Out-String)

if ($Response.statuscode -notin @(200, 202)) {
    if ($($Response | ConvertFrom-Json).error.code -eq 'ResourceNotFound') {
        Write-Warning -Message $($Response | ConvertFrom-Json).error.message
        return 'ResourceNotFound'
    }
}

$requestbody = @{
    Uri         = 'https://management.azure.com/subscriptions/{0}/resourceGroups/{1}/providers/Microsoft.Automation/automationAccounts/{2}/runbooks/{3}/publish?api-version=2019-06-01' -f $SubscriptionId, $ResourceGroupName, $AutomationAccountName, $runbookName
    Method      = 'POST'
    ContentType = 'text/powershell'
    Headers     = @{
        Authorization = "Bearer $AccessToken"
    }
}
$Response = Invoke-WebRequest -SkipHttpErrorCheck @requestbody -Body $(Get-Content -Path $RunbookPath)

return $Response
