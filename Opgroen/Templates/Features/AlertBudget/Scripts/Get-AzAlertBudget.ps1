
[CmdletBinding()]
param (
    # Name of the budget
    [Parameter(Mandatory = $true)]
    [string]
    $Name,
    [Parameter(Mandatory = $false)]
    [string]
    # Name of the scope
    $Scope = 'Subscription',
    # Provide the name of the resource group if the scope is set to Resource Group
    [Parameter(Mandatory = $false)]
    [string]
    $ResourceGroupName = '',
    # Subscription Id, defaults to current context if not provided.
    [Parameter(Mandatory = $false)]
    [string]
    $SubscriptionId = (Get-AzContext).Subscription.Id
)

## Build the parameters for the API request
$RestApiParameters = @{
    Method               = "GET"
    Name                 = $Name
    SubscriptionId       = $SubscriptionId
    ResourceProviderName = "Microsoft.Consumption"
    ResourceType         = "Budgets"
    ApiVersion           = "2021-10-01"
}

# Add the Resource Group Name value if scope is set to ResourceGroup
switch ($Scope) {
    'Subscription' {}
    'ResourceGroup' {
        $RestApiParameters.Add('ResourceGroup', $ResourceGroupName)
    }
}

# Print output that is handy when debugging the script on your computer or Azure DevOps
if ($($env:build.buildid) -and $($env:system.debug)) {
    foreach ($value in $RestApiParameters.GetEnumerator() ) {
        Write-Host "$($value.Name) : $($value.Value)"
    }

} elseif (-not($env:build.buildid)) {
    foreach ($value in $RestApiParameters.GetEnumerator() ) {
        Write-Host "$($value.Name) : $($value.Value)"
    }
}

# Call the api with the parameters
$ApiResult = (Invoke-AzRestMethod @RestApiParameters).Content | ConvertFrom-Json

# Return the variable for further processing
if (-not($ApiResult.error)) {
    Write-Host "##[INFO] Setting existing budget startdate"
    Write-Host "##vso[task.setvariable variable=budgetStartDate;]$($ApiResult.properties.timePeriod.startDate)"
} else {
    $StartDate = (Get-Date -Format "MM/01/yyyy")
    Write-Host "##[INFO] Setting new budget startdate to $StartDate because budget does not exist"
    Write-Host "##vso[task.setvariable variable=budgetStartDate;]$StartDate"
}

