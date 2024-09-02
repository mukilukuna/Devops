targetScope = 'tenant'

@description('Optional. Default Management group for new subscriptions.')
param defaultMgId string = ''

@description('Optional. Indicates whether RBAC access is required upon group creation under the root Management Group. Default value is true')
param authForNewMG bool = true

resource managementGroupSettings 'Microsoft.Management/managementGroups/settings@2021-04-01' = {
  name: '${tenant().tenantId}/default'
  properties: {
    requireAuthorizationForGroupCreation: authForNewMG
    defaultManagementGroup: empty(defaultMgId) ? null : tenantResourceId('Microsoft.Management/managementGroups', defaultMgId)
  }
}

@description('The resource-id of the Azure resource')
output resourceID string = managementGroupSettings.properties.defaultManagementGroup
