targetScope = 'subscription'

@description('Resource location')
param locations array

@allowed(['Any', 'All'])
@description('Filter Operator')
param filterOperator string = 'All'

@description('tagName to match against')
param searchTagName string = 'InSpark_VirtualMachineUpdateGroup'

@description('tagValue to match against')
param searchTagValue string = ''

@description('maintenanceConfiguration resourcegroupname')
param resourceGroupName string

@description('Maintenance Configuration Name')
param maintenanceConfigurationName string

@description('Maintenance Configuration Name')
param maintenanceConfigurationSubscriptionId string

param subscriptionId string = subscription().id

resource maintenanceConfiguration 'Microsoft.Maintenance/maintenanceConfigurations@2023-04-01' existing = {
  scope: resourceGroup(maintenanceConfigurationSubscriptionId, resourceGroupName)
  name: maintenanceConfigurationName
}

resource maintenanceConfigurationAssignment 'Microsoft.Maintenance/configurationAssignments@2023-04-01' = {
  name: '${maintenanceConfiguration.name}-${guid(maintenanceConfiguration.name, string(locations), subscriptionId)}'
  properties: {
    filter: {
      locations: locations
      osTypes: ['Windows', 'Linux']
      resourceTypes: ['Microsoft.Compute/virtualMachines']
      resourceGroups: []
      tagSettings: {
        filterOperator: filterOperator
        tags: !empty(searchTagValue) && !empty(searchTagValue)
          ? {
              '${searchTagName}': empty(searchTagValue) ? [maintenanceConfiguration.name] : [searchTagValue]
            }
          : null
      }
    }
    maintenanceConfigurationId: maintenanceConfiguration.id
    resourceId: subscriptionId
  }
}
