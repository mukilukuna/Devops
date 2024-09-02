targetScope = 'tenant'

@description('Optional. The name of the management group to be created')
param managementGroupName string

@description('Optional. The resource ID of the parent management group')
param managementGroupDisplaynamePrefix string = ''

@description('Optional. The resource ID of the parent management group')
param managementGroupDisplayNameSuffix string = ''

@description('Optional. The resource ID of the parent management group')
param managementGroupIdPrefix string = 'mg'

@description('Optional. The resource ID of the parent management group')
param managementGroupIdSuffix string = ''

@description('Optional. The display name of the management group to be created')
param displayName string = ''

@description('Optional. The resource ID of the parent management group')
param parentResourceId string = ''

@description('Optional. The name of the management group to be created')
param managementGroupMembers array = []

resource managementGroup 'Microsoft.Management/managementGroups@2021-04-01' = {
  name: empty(managementGroupIdPrefix) ? replace('${managementGroupName}', ' ', '') : replace('${managementGroupIdPrefix}${managementGroupName}${managementGroupIdSuffix}', ' ', '')
  properties: {
    displayName: !empty(managementGroupDisplaynamePrefix) ? '${managementGroupDisplaynamePrefix}${displayName}${managementGroupDisplayNameSuffix}' : '${displayName}${managementGroupDisplayNameSuffix}'
    details: {
      parent: {
        id: empty(parentResourceId) ? null : parentResourceId
      }
    }
  }
}

resource managementGroupDirectMembers 'Microsoft.Management/managementGroups@2021-04-01' = [for (mg, i) in managementGroupMembers: {
  name: empty(managementGroupIdPrefix) ? replace('${mg.name}', ' ', '') : replace('${managementGroupIdPrefix}${mg.name}${managementGroupIdSuffix}', ' ', '')
  properties: {
    displayName: !empty(managementGroupDisplaynamePrefix) ? '${managementGroupDisplaynamePrefix}${displayName}${managementGroupDisplayNameSuffix}' : '${displayName}${managementGroupDisplayNameSuffix}'
    details: {
      parent: {
        id: managementGroup.id
      }
    }
  }
}]

@description('The name of the Azure resource')
output resourceName string = managementGroup.name

@description('The resource-id of the Azure resource')
output resourceID string = managementGroup.id
