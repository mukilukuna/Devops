@description('Required. Resource ID of the subnet this resource should be created in')
param subnetId string

@description('Required. Service ID')
param privateLinkServiceId string

@description('Required. Groups ID\'s')
param requestMessage string = ''

@description('Optional. Request message')
param groupIds array = []

@description('Required. Index of the resource')
param index int

@description('Required. Custom name of the resource')
param customName string = ''

@description('Optional. Location of the resource')
param location string = resourceGroup().location

@description('Optional. Array of Role Assignments to deploy')
param permissions array = []

@description('Optional. Resource tags')
param tags object = {}

@description('Optional. Diagnostic settings configuration')
param diagnosticSettings array = []

// TODO naming convention
resource privateEndpoint 'Microsoft.Network/privateEndpoints@2021-12-01' = {
  name: empty(customName) ? 'pe-${last(split(privateLinkServiceId, '/'))}-${padLeft(index, 2, '0')}' : customName
  location: location
  tags: tags
  properties: {
    subnet: {
      id: subnetId
    }
    privateLinkServiceConnections: empty(requestMessage) ? [
      {
        name: empty(customName) ? 'pe-${last(split(privateLinkServiceId, '/'))}-${padLeft(index, 2, '0')}' : customName
        properties: {
          privateLinkServiceId: privateLinkServiceId
          groupIds: groupIds
          requestMessage: requestMessage
        }
      }
    ] : null
    manualPrivateLinkServiceConnections: !empty(requestMessage) ? [
      {
        name: empty(customName) ? 'pe-${last(split(privateLinkServiceId, '/'))}-${padLeft(index, 2, '0')}' : customName
        properties: {
          privateLinkServiceId: privateLinkServiceId
          groupIds: groupIds
          requestMessage: requestMessage
        }
      }
    ] : null
  }
}

resource diagSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = [for setting in diagnosticSettings: if (!empty(diagnosticSettings)) {
  name: setting.name
  scope: privateEndpoint
  properties: {
    workspaceId: contains(setting, 'workspaceId') ? setting.workspaceId : null
    storageAccountId: contains(setting, 'diagnosticsStorageAccountId') ? setting.diagnosticsStorageAccountId : null
    logs: contains(setting, 'logs') ? setting.logs : null
    metrics: contains(setting, 'metrics') ? setting.metrics : null
  }
}]

resource roleAssignments 'Microsoft.Authorization/roleAssignments@2022-01-01-preview' = [for item in permissions: {
  name: guid(resourceGroup().id, item.name, item.roleDefinitionId)
  scope: privateEndpoint
  properties: {
    principalId: item.principalId
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', item.roleDefinitionId)
    condition: contains(item, 'condition') && item.condition != '' ? item.condition : null
    conditionVersion: contains(item, 'conditionVersion') && item.conditionVersion != '' ? item.conditionVersion : null
    delegatedManagedIdentityResourceId: contains(item, 'delegatedManagedIdentityResourceId') && item.delegatedManagedIdentityResourceId != '' ? item.delegatedManagedIdentityResourceId : null
    description: item.description
    principalType: item.principalType
  }
}]

@description('The name of the Azure resource')
output resourceName string = privateEndpoint.name
@description('The resource-id of the Azure resource')
output resourceID string = privateEndpoint.id
