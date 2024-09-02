[CmdletBinding()]
param (
    [Parameter(Mandatory)]
    [String] $SubscriptionId,

    [Parameter(Mandatory)]
    [String] $ResourceGroupName,

    [Parameter(Mandatory)]
    [String] $AutomationAccountName,

    [Parameter(Mandatory)]
    [String] $ClientId,

    [Parameter(Mandatory)]
    [string[]] $WebhookNames
)

Connect-AzAccount -Identity -AccountId $ClientId -Subscription $SubscriptionId
$token = (Get-AzAccessToken).token
$DeploymentScriptOutputs = @{}

$generateWebhookUri = "https://management.azure.com/subscriptions/$subscriptionId/resourceGroups/$ResourceGroupName/providers/Microsoft.Automation/automationAccounts/$AutomationAccountName/webhooks/generateUri?api-version=2018-06-30"
$getWebhookUri = "https://management.azure.com/subscriptions/$subscriptionId/resourceGroups/$ResourceGroupName/providers/Microsoft.Automation/automationAccounts/$AutomationAccountName/webhooks?api-version=2018-06-30"
$i = 0

foreach ($webhook in $WebhookNames) {
    $webhookExisting = Invoke-RestMethod -Method Get -Uri $getWebhookUri -Headers @{Authorization = "Bearer $token" } -ErrorAction SilentlyContinue

    if ($webhookExisting.value.name -contains $webhook) {
        $DeploymentScriptOutputs["webhook$i"] = ''
    } else {
        $DeploymentScriptOutputs["webhook$i"] = Invoke-RestMethod -Method Post -Uri $generateWebhookUri -Headers @{Authorization = "Bearer $token" } -ErrorAction SilentlyContinue
    }

    $i++
}
