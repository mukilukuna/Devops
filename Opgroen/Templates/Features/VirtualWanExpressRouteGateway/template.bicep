@description('Required. The workload name of the resource.')
param workloadName string

@description('Required. The application name of the resource.')
param applicationName string

@description('Required. The environment letter of the resource.')
@maxLength(1)
param environmentName string

@description('Required. The index of the resource.')
param index int

@description('Required. The region this resource will be deployed in.')
@maxLength(4)
param regionName string

@description('Optional. Custom name of the resource.')
param customName string = ''

@description('Optional. Location of the resource.')
param location string = resourceGroup().location

@description('Optional. Array of Role Assignments to deploy')
param permissions array = []

@description('Required. Resource ID of the Virtual Wan Hub.')
param virtualWanHubResourceId string

@description('Optional. Scale unit for the gateway.')
param scaleUnits int = 1

@description('Optional. array containing express route connections.')
param expressRouteConnections array = []

@description('Optional. Tags to apply on the resource.')
param tags object = {}

@description('Optional. Diagnostic settings configuration.')
param diagnosticSettings array = []

var nameVar = empty(customName) ? toLower('egw-${workloadName}-${applicationName}-${environmentName}-${regionName}-${padLeft(index, 2, '0')}') : customName

resource expressRouteGw 'Microsoft.Network/expressRouteGateways@2023-05-01' = {
  name: nameVar
  location: location
  tags: tags
  properties: {
    virtualHub: {
      id: virtualWanHubResourceId
    }
    autoScaleConfiguration: {
      bounds: {
        min: scaleUnits
      }
    }
    expressRouteConnections: expressRouteConnections
  }
}

resource diagSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = [for setting in diagnosticSettings: if (!empty(diagnosticSettings)) {
  name: setting.name
  scope: expressRouteGw
  properties: {
    workspaceId: contains(setting, 'workspaceId') ? setting.workspaceId : null
    storageAccountId: contains(setting, 'diagnosticsStorageAccountId') ? setting.diagnosticsStorageAccountId : null
    logs: contains(setting, 'logs') ? setting.logs : null
    metrics: contains(setting, 'metrics') ? setting.metrics : null
  }
}]

resource roleAssignments 'Microsoft.Authorization/roleAssignments@2022-04-01' = [for item in permissions: {
  name: guid(resourceGroup().id, item.name, item.roleDefinitionId)
  scope: expressRouteGw
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

@description('The resource-id of the Azure resource')
output resourceID string = expressRouteGw.id
@description('The name of the Azure resource')
output resourceName string = expressRouteGw.name
