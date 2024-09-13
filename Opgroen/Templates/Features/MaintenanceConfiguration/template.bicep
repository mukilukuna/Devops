@description('Prefix to add to maintenanceConfiguration')
param maintenanceConfigurationPrefix string

@description('Default location')
param location string = 'westeurope'

@allowed([
  'IfRequired'
  'Always'
  'Never'
])
param rebootSetting string = 'IfRequired'

@description('https://learn.microsoft.com/en-us/azure/templates/microsoft.maintenance/maintenanceconfigurations?pivots=deployment-language-bicep#inputwindowsparameters')
param windowsParameters object

@description('https://learn.microsoft.com/en-us/azure/templates/microsoft.maintenance/maintenanceconfigurations?pivots=deployment-language-bicep#inputlinuxparameters')
param linuxParameters object

@description('''
maintenance Window configuration.

docs: https://learn.microsoft.com/en-us/azure/templates/microsoft.maintenance/maintenanceconfigurations?pivots=deployment-language-bicep#maintenancewindow

fields: startTime, duration, timezone, recurEvery
''')
param maintenanceWindow object

@allowed(['Any', 'All'])
@description('')
param filterOperator string = 'All'

@description('''
maintenanceConfiguration Subscriptions + locations to assign

docs: https://learn.microsoft.com/en-us/azure/templates/microsoft.maintenance/configurationassignments?pivots=deployment-language-bicep

Fields: id, locations
''')
param subscriptions array

param tags object = {
  inSpark_InfrastructureManagedBy: 'InSpark'
}

@description('tagName to match against')
param searchTagName string = 'InSpark_VirtualMachineUpdateGroup'

@description('tagValue to match against')
param searchTagValue string = ''

@secure()
param startWebhookUri string

@secure()
param stopWebhookUri string

param now string = utcNow('yyyy-MM-dd')

var maintenanceConfigurationName = length(split(maintenanceWindow.recurEvery, ' ')) > 1
  ? format(
      '{0}-{1}-{2}{3}',
      maintenanceConfigurationPrefix,
      replace(maintenanceWindow.startTime, ':', ''),
      split(maintenanceWindow.recurEvery, ' ')[1],
      split(maintenanceWindow.recurEvery, ' ')[2]
    )
  : format(
      '{0}-{1}-{2}',
      maintenanceConfigurationPrefix,
      replace(maintenanceWindow.startTime, ':', ''),
      maintenanceWindow.recurEvery
    )

resource maintenanceConfiguration 'Microsoft.Maintenance/maintenanceConfigurations@2023-04-01' = {
  name: maintenanceConfigurationName
  location: location
  tags: union(tags, { TagValue: empty(searchTagValue) ? maintenanceConfigurationName : searchTagValue })
  properties: {
    extensionProperties: {
      InGuestpatchMode: 'User'
    }
    maintenanceScope: 'InGuestPatch'
    maintenanceWindow: {
      startDateTime: '${now} ${maintenanceWindow.startTime}'
      duration: maintenanceWindow.duration
      timeZone: maintenanceWindow.timeZone
      recurEvery: maintenanceWindow.recurEvery
    }
    visibility: 'Custom'
    installPatches: {
      rebootSetting: rebootSetting
      windowsParameters: windowsParameters
      linuxParameters: linuxParameters
    }
  }
}

resource systemTopic 'Microsoft.EventGrid/systemTopics@2023-12-15-preview' = {
  name: '${maintenanceConfigurationName}-Topic'
  tags: tags
  location: location
  properties: {
    source: maintenanceConfiguration.id
    topicType: 'Microsoft.Maintenance.MaintenanceConfigurations'
  }
}

resource startEventSubscription 'Microsoft.EventGrid/systemTopics/eventsubscriptions@2023-12-15-preview' = {
  name: '${maintenanceConfigurationName}-startEventSubscription'
  parent: systemTopic
  properties: {
    eventDeliverySchema: 'EventGridSchema'
    filter: {
      includedEventTypes: ['Microsoft.Maintenance.PreMaintenanceEvent']
    }
    destination: {
      endpointType: 'WebHook'
      properties: {
        endpointUrl: startWebhookUri
        maxEventsPerBatch: 1
        preferredBatchSizeInKilobytes: 128
      }
    }
  }
}

resource stopEventSubscription 'Microsoft.EventGrid/systemTopics/eventsubscriptions@2023-12-15-preview' = {
  name: '${maintenanceConfigurationName}-stopEventSubscription'
  parent: systemTopic
  properties: {
    eventDeliverySchema: 'EventGridSchema'
    filter: {
      includedEventTypes: ['Microsoft.Maintenance.PostMaintenanceEvent']
    }
    destination: {
      endpointType: 'WebHook'
      properties: {
        endpointUrl: stopWebhookUri
        maxEventsPerBatch: 1
        preferredBatchSizeInKilobytes: 128
      }
    }
  }
}

module azureUpdateManagerAssignment '../MaintenanceConfigurationAssignment/template.bicep' = [
  for subscription in subscriptions: {
    name: '${maintenanceConfiguration.name}-Assignment'
    scope: az.subscription(subscription.id)
    params: {
      maintenanceConfigurationSubscriptionId: az.subscription().subscriptionId
      locations: subscription.locations
      maintenanceConfigurationName: maintenanceConfiguration.name
      searchTagName: empty(searchTagName) ? null : searchTagName
      searchTagValue: empty(searchTagValue) ? null : searchTagValue
      resourceGroupName: resourceGroup().name
      filterOperator: filterOperator
    }
  }
]

output tagvalue string = maintenanceConfiguration.name
output maintenanceConfigurationid string = maintenanceConfiguration.id
