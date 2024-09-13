targetScope = 'subscription'

@description('Required. Array of Role Assignments to deploy')
param permissions array = []

resource roleAssignments 'Microsoft.Authorization/roleAssignments@2022-04-01' = [for item in permissions: {
  name: guid(subscription().id, item.name, item.roleDefinitionId)
  properties: {
    principalId: item.principalId
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', item.roleDefinitionId)
    condition: contains(item, 'condition') && item.condition != '' ? item.condition : null
    conditionVersion: contains(item, 'conditionVersion') && item.conditionVersion != '' ? item.conditionVersion : null
    delegatedManagedIdentityResourceId: contains(item, 'delegatedManagedIdentityResourceId') && item.delegatedManagedIdentityResourceId != '' ? item.delegatedManagedIdentityResourceId : null
    description: item.description
    principalType: item.principalType
  }
}]

@description('The name of the Azure resource')
output resourceName string = !empty(permissions) ? roleAssignments[0].name : ''
@description('The resource ID of the Azure resource')
output resourceID string = !empty(permissions) ? roleAssignments[0].id : ''
