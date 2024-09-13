@description('Required. The workload name of the resource')
param workloadName string

@description('Required. The application name of the resource')
param applicationName string

@description('Required. The environment name of the resource')
@maxLength(1)
param environmentName string

@description('Required. The index of the resource')
param index int

@description('Required. The region this resource will be deployed in')
@maxLength(4)
param regionName string

@description('Optional. Custom name of resource')
param customName string = ''

@description('Optional. Location of the resource')
param location string = resourceGroup().location

@description('Optional. Array of Role Assignments to deploy')
param permissions array = []

@description('Required. Resource ID of the Virtual Wan')
param virtualWanResourceId string

@description('Required. Address prefix for this VirtualHub')
param addressPrefix string

param tags object = {}

var nameVar = empty(customName) ? toLower('vhub-${workloadName}-${applicationName}-${regionName}-${environmentName}-${padLeft(index, 2, '0')}') : customName

resource vWanHub 'Microsoft.Network/virtualHubs@2021-05-01' = {
  name: nameVar
  location: location
  tags: tags
  properties: {
    addressPrefix: addressPrefix
    virtualWan: {
      id: virtualWanResourceId
    }
  }
}

resource roleAssignments 'Microsoft.Authorization/roleAssignments@2022-04-01' = [for item in permissions: {
  name: guid(resourceGroup().id, item.name, item.roleDefinitionId)
  scope: vWanHub
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

@description('The resource-ID of the Azure resource')
output resourceID string = vWanHub.id
@description('The name of the Azure resource')
output resourceName string = vWanHub.name
