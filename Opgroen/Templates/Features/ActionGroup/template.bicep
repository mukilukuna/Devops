@description('Required. Array of Action Group object(s)')
param actionGroups array

@description('Optional. Location of the Action Group object(s)')
param location string = 'global'

@description('Optional. Object containing the tags to apply to all resources')
param tags object = {}

var actionGroupNames = [for item in actionGroups: contains(item, 'customName') ? item.customName : toLower('ag-${item.appName}-${item.destination}-${item.environment}-${item.action}')]
var actionGroupResourceIds = [for (item, i) in actionGroups: resourceId('Microsoft.Insights/actionGroups', actionGroupNames[i])]

resource actionGroup 'Microsoft.Insights/actionGroups@2021-09-01' = [for (item, i) in actionGroups: {
  name: actionGroupNames[i]
  location: location
  tags: tags
  properties: {
    enabled: contains(item, 'actionGroupEnabled') ? item.actionGroupEnabled : true
    groupShortName: item.groupShortName
    emailReceivers: contains(item, 'emailReceivers') ? item.emailReceivers : null
    smsReceivers: contains(item, 'smsReceivers') ? item.smsReceivers : null
    webhookReceivers: contains(item, 'webhookReceivers') ? item.webhookReceivers : null
    itsmReceivers: contains(item, 'itsmReceivers') ? item.itsmReceivers : null
    azureAppPushReceivers: contains(item, 'azureAppPushReceivers') ? item.azureAppPushReceivers : null
    automationRunbookReceivers: contains(item, 'automationRunbookReceivers') ? item.automationRunbookReceivers : null
    voiceReceivers: contains(item, 'voiceReceivers') ? item.voiceReceivers : null
    logicAppReceivers: contains(item, 'logicAppReceivers') ? item.logicAppReceivers : null
    azureFunctionReceivers: contains(item, 'azureFunctionReceivers') ? item.azureFunctionReceivers : null
    armRoleReceivers: contains(item, 'armRoleReceivers') ? item.armRoleReceivers : null
    eventHubReceivers: contains(item, 'eventHubReceivers') ? item.eventHubReceivers : null
  }
}]

@description('The name of the Azure resource')
output resourceName array = actionGroupNames
@description('The resource-id of the Azure resource')
output resourceID array = actionGroupResourceIds
