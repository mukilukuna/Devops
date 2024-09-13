targetScope = 'managementGroup'

@description('Required. Provide the ID of the management group that you want to move the subscription to')
param managementGroupId string

@description('Required. Provide the ID of the existing subscription to move')
param subscriptionId array

var name = [for item in subscriptionId: item]
var id = [for item in subscriptionId: resourceId('Microsoft.Management/managementGroups/subscriptions', managementGroupId, item)]

resource subToMG 'Microsoft.Management/managementGroups/subscriptions@2021-04-01' = [for item in subscriptionId: {
  scope: tenant()
  name: '${managementGroupId}/${item}'
}]

@description('Name of all the resources.')
output resourceName array = name

@description('ID of all the resources.')
output resourceID array = id
