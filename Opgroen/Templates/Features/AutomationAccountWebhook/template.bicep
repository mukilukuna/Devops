@description('Name of the automationAccount')
param automationAccountName string

param runbookName string

param name string

@secure()
param webhookUri string

param timeNow string = utcNow()

resource automationAccount 'Microsoft.Automation/automationAccounts@2022-08-08' existing = {
  name: automationAccountName
}

// Create Webhooks with Webhook URI from deployment scripts
resource webhook 'Microsoft.Automation/automationAccounts/webhooks@2015-10-31' = {
  name: name
  parent: automationAccount
  properties: {
    isEnabled: true
    expiryTime: dateTimeAdd(timeNow, 'P10Y')
    runbook: {
      name: runbookName
    }
    uri: webhookUri
  }
}
