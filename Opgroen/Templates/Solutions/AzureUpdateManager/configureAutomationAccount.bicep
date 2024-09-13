@description('The Azure region to deploy the resource')
param location string

@description('Name of the automationAccount')
param automationAccountName string

@description('Array of the automationAccount Packages')
param powershellgalleryPackages array

@description('Subscriptions to grant Desktop Virtualization Power On Off Contributor access to')
param subscriptions array

@description('Keyvault to store webhooks in | Fields: subscription, resourcegroup, name')
param keyVaultInfo object

@description('User assigned identity to use | Fields: subscription, resourcegroup, name')
param identityInfo object

param virtualNetworkResourceId string

param storageAccountName string

@description('Disable Role Assignments. Make sure you set them manually')
param enableRoleGrants bool = false

var virtualNetworkInfo = {
  subscription: split(virtualNetworkResourceId, '/')[2]
  resourcegroup: split(virtualNetworkResourceId, '/')[4]
  name: split(virtualNetworkResourceId, '/')[8]
}

resource userAssignedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' existing = {
  scope: resourceGroup(identityInfo.subscription, identityInfo.resourcegroup)
  name: identityInfo.name
}

resource automationAccount 'Microsoft.Automation/automationAccounts@2022-08-08' existing = {
  name: automationAccountName
}

resource storageAccount 'Microsoft.Storage/storageAccounts@2023-04-01' existing = {
  name: storageAccountName
}

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2023-11-01' existing = {
  scope: resourceGroup(virtualNetworkInfo.subscription, virtualNetworkInfo.resourcegroup)
  name: virtualNetworkInfo.name
}

resource deploymentScriptSubnet 'Microsoft.Network/virtualNetworks/subnets@2023-11-01' existing = {
  parent: virtualNetwork
  name: 'DeploymentScriptSubnet'
}

module automationAccountRoles '../../Features/RoleAssignmentSub/template.bicep' = [
  for subscription in subscriptions: if (enableRoleGrants) {
    name: guid('${automationAccount.name}-${subscription.id}-${subscription.role}')
    scope: az.subscription(subscription.id)
    params: {
      permissions: [
        {
          name: automationAccount.name
          principalId: userAssignedIdentity.properties.principalId
          roleDefinitionId: subscription.role
          description: '${subscription.role} role assignment'
          principalType: 'ServicePrincipal'
        }
      ]
    }
  }
]

var AARoles = [
  'f353d9bd-d4a6-484e-a77a-8050b599b867' // Automation Contributor
]

resource automationAccount_Grants 'Microsoft.Authorization/roleAssignments@2022-04-01' = [
  for role in AARoles: if (enableRoleGrants) {
    name: guid('${automationAccount.id}-${role}')
    scope: automationAccount
    properties: {
      principalId: userAssignedIdentity.properties.principalId
      roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', role)
      principalType: 'ServicePrincipal'
    }
  }
]

resource modules72 'Microsoft.Automation/automationAccounts/powerShell72Modules@2023-11-01' = [
  for item in powershellgalleryPackages: {
    parent: automationAccount
    name: item
    properties: {
      contentLink: {
        uri: 'https://www.powershellgallery.com/api/v2/package/${item}'
      }
    }
  }
]

resource modules 'Microsoft.Automation/automationAccounts/Modules@2022-08-08' = [
  for item in powershellgalleryPackages: {
    parent: automationAccount
    name: item
    properties: {
      contentLink: {
        uri: 'https://www.powershellgallery.com/api/v2/package/${item}'
      }
    }
  }
]

resource startScriptRunbook 'Microsoft.Automation/automationAccounts/runbooks@2022-08-08' = {
  dependsOn: [
    modules
    modules72
  ]
  name: '${automationAccount.name}-StartScript'
  location: location
  parent: automationAccount
  properties: {
    runbookType: 'PowerShell72'
  }
}

resource stopScriptRunbook 'Microsoft.Automation/automationAccounts/runbooks@2022-08-08' = {
  dependsOn: [
    modules
    modules72
  ]
  name: '${automationAccount.name}-StopScript'
  location: location
  parent: automationAccount
  properties: {
    runbookType: 'PowerShell72'
  }
}

// Deployment Script for webhook URI
var webhookScript = loadTextContent('deploymentScripts/Get-WebhookURI.ps1')

resource webhookURIs 'Microsoft.Resources/deploymentScripts@2023-08-01' = {
  name: 'WebhookURIs'
  location: location
  kind: 'AzurePowerShell'
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${userAssignedIdentity.id}': {}
    }
  }
  properties: {
    azPowerShellVersion: '7.2'
    cleanupPreference: 'Always'
    retentionInterval: 'PT1H'
    storageAccountSettings: {
      storageAccountName: storageAccountName
    }
    containerSettings: {
      subnetIds: [
        {
          id: deploymentScriptSubnet.id
        }
      ]
    }
    timeout: 'PT30M'
    scriptContent: webhookScript
    arguments: '-WebhookNames "${automationAccount.name}-StartScript-Webhook", "${automationAccount.name}-StopScript-Webhook" -SubscriptionId "${subscription().subscriptionId}" -ResourceGroupName "${resourceGroup().name}" -AutomationAccountName "${automationAccount.name}" -ClientId "${userAssignedIdentity.properties.clientId}"'
  }
}

module storeStartWebhookSecret '../../Features/KeyVaultSecret/template.bicep' = {
  name: 'Store-${automationAccount.name}-StartWebhook'
  scope: az.resourceGroup(keyVaultInfo.subscription, keyVaultInfo.resourcegroup)
  params: {
    keyVaultName: keyVaultInfo.name
    secretName: '${automationAccount.name}-StartWebhook'
    secretValue: webhookURIs.properties.outputs.webhook0
  }
}

module storeStopWebhookSecret '../../Features/KeyVaultSecret/template.bicep' = {
  name: 'Store-${automationAccount.name}-StopWebhook'
  scope: az.resourceGroup(keyVaultInfo.subscription, keyVaultInfo.resourcegroup)
  params: {
    keyVaultName: keyVaultInfo.name
    secretName: '${automationAccount.name}-StopWebhook'
    secretValue: webhookURIs.properties.outputs.webhook1
  }
}

var runbookScriptParam = loadTextContent('deploymentScripts/Set-Runbook.ps1.param')
var runbookScript = loadTextContent('deploymentScripts/Set-Runbook.ps1')

resource startScript 'Microsoft.Resources/deploymentScripts@2023-08-01' = {
  name: 'StartScriptRunbook'
  location: location
  kind: 'AzurePowerShell'
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${userAssignedIdentity.id}': {}
    }
  }
  properties: {
    azPowerShellVersion: '7.2'
    cleanupPreference: 'Always'
    retentionInterval: 'PT1H'
    storageAccountSettings: {
      storageAccountName: storageAccountName
    }
    containerSettings: {
      subnetIds: [
        {
          id: deploymentScriptSubnet.id
        }
      ]
    }
    timeout: 'PT30M'
    scriptContent: '${runbookScriptParam} \n @\'\n${loadTextContent('AA-Runbooks/AUM-StartScript.ps1.param')}\n$ApplicationId = \'${userAssignedIdentity.properties.clientId}\'\n${loadTextContent('AA-Runbooks/AUM-StartScript.ps1')}\n\'@ | Out-file AUM-StartScript.ps1 \n ${runbookScript}'
    arguments: '-SubscriptionId ${subscription().subscriptionId} -ResourceGroupName ${resourceGroup().name} -AutomationAccountName ${automationAccount.name} -runbookName ${startScriptRunbook.name} -RunbookPath AUM-StartScript.ps1'
  }
}

resource stopScript 'Microsoft.Resources/deploymentScripts@2023-08-01' = {
  name: 'StopScriptRunbook'
  location: location
  kind: 'AzurePowerShell'
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${userAssignedIdentity.id}': {}
    }
  }
  properties: {
    azPowerShellVersion: '7.2'
    cleanupPreference: 'Always'
    retentionInterval: 'PT1H'
    storageAccountSettings: {
      storageAccountName: storageAccountName
    }
    containerSettings: {
      subnetIds: [
        {
          id: deploymentScriptSubnet.id
        }
      ]
    }
    timeout: 'PT30M'
    scriptContent: '${runbookScriptParam} \n @\'\n${loadTextContent('AA-Runbooks/AUM-StopScript.ps1.param')}\n$ApplicationId = \'${userAssignedIdentity.properties.clientId}\'\n${loadTextContent('AA-Runbooks/AUM-StopScript.ps1')}\n\'@ | Out-file AUM-StopScript.ps1 \n ${runbookScript}'
    arguments: '-SubscriptionId ${subscription().subscriptionId} -ResourceGroupName ${resourceGroup().name} -AutomationAccountName ${automationAccount.name} -runbookName ${stopScriptRunbook.name} -RunbookPath AUM-StopScript.ps1'
  }
}

resource keyVault 'Microsoft.KeyVault/vaults@2023-07-01' existing = {
  name: keyVaultInfo.name
  scope: resourceGroup(keyVaultInfo.subscription, keyVaultInfo.resourcegroup)
}

// Create Webhooks with Webhook URI from deployment scripts
module startScriptWebhook '../../Features/AutomationAccountWebhook/template.bicep' = {
  name: 'Webhook-StartScript'
  dependsOn: [
    startScript
  ]
  params: {
    name: '${automationAccount.name}-StartScript-Webhook'
    automationAccountName: automationAccount.name
    runbookName: startScriptRunbook.name
    webhookUri: keyVault.getSecret(storeStartWebhookSecret.outputs.secretName)
  }
}

module stopScriptWebhook '../../Features/AutomationAccountWebhook/template.bicep' = {
  name: 'Webhook-StopScript'
  dependsOn: [
    stopScript
  ]
  params: {
    name: '${automationAccount.name}-StopScript-Webhook'
    automationAccountName: automationAccount.name
    runbookName: stopScriptRunbook.name
    webhookUri: keyVault.getSecret(storeStopWebhookSecret.outputs.secretName)
  }
}

output startWebhookUriSecretName string = storeStartWebhookSecret.outputs.secretName
output stopWebhookUriSecretName string = storeStopWebhookSecret.outputs.secretName
