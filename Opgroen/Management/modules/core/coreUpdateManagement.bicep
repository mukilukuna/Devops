@description('''
Roles to assign to automationaccount

roles: https://learn.microsoft.com/en-us/azure/role-based-access-control/built-in-roles

Fields: id, role
''')
param AAsubscriptions array

@description('''
maintenanceConfiguration Subscriptions + locations to assign

docs: https://learn.microsoft.com/en-us/azure/templates/microsoft.maintenance/configurationassignments?pivots=deployment-language-bicep

Fields: id, locations
''')
param subscriptions array

@description('''
maintenanceConfiguration Schedules to create. (name will be set as tagvalue)
OverrideTagValue can be used to set custom tag values.

docs: https://learn.microsoft.com/en-us/azure/templates/microsoft.maintenance/maintenanceconfigurations?pivots=deployment-language-bicep

fields: name, location, rebootSetting, maintenanceWindow, linuxParameters, windowsParameters, OverrideTagValue
''')
param AUMschedules array

@description('TagName to use for ')
param maintenanceWindowSearchTagName string = 'InSpark_VirtualMachineUpdateGroup'

@description('what region to deploy the resources')
param location string = resourceGroup().location

@description('What keyVault to use for webhook storage')
param keyVaultResourceId string?

@description('Name of the Automation Account')
param automationAccountName string = 'aa-test'

@description('Name of the Automation Account')
param userAssignedIdentityName string = 'id-test'

@description('ResourceId of the Virtual Network to use for the deployment script')
param virtualNetworkResourceId string = 'id-test'

@description('Name of the Automation Account for the deployment script')
param storageAccountName string = 'id-test'

resource userAssignedIdentityExisting 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-07-31-preview' existing = {
  name: userAssignedIdentityName
}

resource automationAccountExisting 'Microsoft.Automation/automationAccounts@2022-08-08' existing = {
  name: automationAccountName
}

var keyVaultInfo = {
  subscription: split(keyVaultResourceId, '/')[2]
  resourcegroup: split(keyVaultResourceId, '/')[4]
  name: split(keyVaultResourceId, '/')[8]
}

var identityInfo = {
  subscription: split(userAssignedIdentityExisting.id, '/')[2]
  resourcegroup: split(userAssignedIdentityExisting.id, '/')[4]
  name: split(userAssignedIdentityExisting.id, '/')[8]
}

module automationAccount '../../../Templates/Solutions/AzureUpdateManager/configureAutomationAccount.bicep' = {
  name: 'Deployment-${automationAccountExisting.name}'
  params: {
    automationAccountName: automationAccountExisting.name
    location: location
    powershellgalleryPackages: ['ThreadJob']
    subscriptions: AAsubscriptions
    keyVaultInfo: keyVaultInfo
    identityInfo: identityInfo
    virtualNetworkResourceId: virtualNetworkResourceId
    storageAccountName: storageAccountName
    enableRoleGrants: true
  }
}

resource keyVault 'Microsoft.KeyVault/vaults@2023-07-01' existing = {
  name: keyVaultInfo.name
  scope: resourceGroup(keyVaultInfo.subscription, keyVaultInfo.resourcegroup)
}

module azureUpdateManager '../../../Templates/Features/MaintenanceConfiguration/template.bicep' = [
  for AUMschedule in AUMschedules: {
    name: 'Deployment-${AUMschedule.name}'
    params: {
      location: AUMschedule.location
      maintenanceConfigurationPrefix: AUMschedule.name
      maintenanceWindow: AUMschedule.maintenanceWindow
      rebootSetting: AUMschedule.rebootSetting
      linuxParameters: AUMschedule.linuxParameters
      windowsParameters: AUMschedule.windowsParameters
      subscriptions: subscriptions
      searchTagName: contains(AUMschedule, 'maintenanceWindowSearchTagName')
        ? AUMschedule.maintenanceWindowSearchTagName
        : maintenanceWindowSearchTagName
      searchTagValue: contains(AUMschedule, 'OverrideTagValue') ? AUMschedule.OverrideTagValue : null
      startWebhookUri: keyVault.getSecret(automationAccount.outputs.startWebhookUriSecretName)
      stopWebhookUri: keyVault.getSecret(automationAccount.outputs.stopWebhookUriSecretName)
    }
    dependsOn: [userAssignedIdentityExisting]
  }
]
