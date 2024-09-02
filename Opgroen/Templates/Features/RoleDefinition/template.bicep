targetScope = 'managementGroup'

@description('Required. Array of Custom Roles to be created')
param roles array

var id = [for item in roles: resourceId('Microsoft.Authorization/roleDefinitions', guid(managementGroup().id, item.name))]
var name = [for item in roles: guid(managementGroup().id, item.name)]

resource roleDefinitions 'Microsoft.Authorization/roleDefinitions@2018-01-01-preview' = [for item in roles: {
  name: guid(managementGroup().id, item.name)
  properties: {
    roleName: 'custom-${item.name}'
    description: item.description
    type: 'CustomRole'
    assignableScopes: contains(item, 'assignableScopes') && !empty(item.assignableScopes) ? item.assignableScopes : [
      '/providers/Microsoft.Management/managementGroups/${managementGroup().name}'
    ]
    permissions: item.permissions
  }
}]

@description('Name of all the resources')
output resourceName array = name

@description('ID of all the resources')
output resourceID array = id
