@description('Required. Array of Azure Firewall IP Groups')
param ipGroups array

@description('Optional. Resource tags')
param tags object = {}

@description('Optional. Location for the IP groups')
param location string = resourceGroup().location

@description('Optional. Array of Role Assignments to deploy')
param permissions array = []

var ipGroupsName = [for item in ipGroups: toLower('ig-${item.type}-${item.name}-${padLeft(item.index, 2, '0')}')]
var ipGroupsId = [for item in ipGroups: resourceId('Microsoft.Network/ipGroups', toLower(concat(item.name)))]

resource ipGroup 'Microsoft.Network/ipGroups@2021-12-01' = [for (item, i) in ipGroups: {
  name: ipGroupsName[i]
  location: location
  tags: tags
  properties: {
    ipAddresses: item.ipAddresses
  }
}]

resource roleAssignments 'Microsoft.Authorization/roleAssignments@2022-01-01-preview' = [for item in permissions: {
  name: guid(resourceGroup().id, item.name, item.roleDefinitionId)
  scope: ipGroup[item]
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

@description('Name of the resource')
output resourceName array = ipGroupsName

@description('ID of the resource')
output resourceID array = ipGroupsId
