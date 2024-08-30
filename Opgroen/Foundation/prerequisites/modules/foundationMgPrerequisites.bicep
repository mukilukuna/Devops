targetScope = 'managementGroup'

param managementGroupIdPrefix string
param customerMgName string

module customerMg '../../../Templates/Features/ManagementGroup/template.bicep' = {
  scope: tenant()
  name: customerMgName
  params: {
    displayName: customerMgName
    managementGroupName: customerMgName
    parentResourceId: '/providers/Microsoft.Management/managementGroups/${tenant().tenantId}'
    managementGroupIdPrefix: managementGroupIdPrefix
  }
}

output customerMg_ResourceName string = customerMg.outputs.resourceName
output customerMg_ResourceId string = customerMg.outputs.resourceID
