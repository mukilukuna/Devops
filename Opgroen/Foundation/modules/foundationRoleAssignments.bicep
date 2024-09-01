targetScope = 'managementGroup'

@description('Optional. time parameter to create unique deployment. Do not set in parameter file!')
param time string = replace(utcNow(), ':', '-')

var tenantRootGroupConfig = loadJsonContent('../configs/tenantRootGroupConfig.json')
var customerMgConfig = loadJsonContent('../configs/customerMgConfig.json')
var managementGroupsCombined = union(
  loadJsonContent('../configs/customerMgChildConfig.json'),
  loadJsonContent('../configs/platformMgChildConfig.json'),
  loadJsonContent('../configs/customerMgLzChildConfig.json')
)

module RoleAssignmentTenantRootGroup '../../Templates/Features//RoleAssignmentTenant/template.bicep' = {
  scope: tenant()
  name: 'RoleAssignment-TenantRootGroup-${time}'
  params: {
    permissions: tenantRootGroupConfig.permissions
  }
}

module RoleAssignmentPFCanarycustomerMg '../../Templates/Features/RoleAssignmentMG/template.bicep' = {
  scope: managementGroup('*<canary-managementGroup-customerMg_ResourceName>*')
  name: 'RoleAssignment-pf-*<canary-managementGroup-customerMg_ResourceName>*-${time}'
  params: {
    permissions: [
      {
        name: 'PF-OTA-Owner'
        principalId: '*<PF-OTA-Owner>*'
        roleDefinitionId: '8e3af657-a8ff-443c-a75c-2fe8c4bcb635'
        description: 'PF-OTA-Owner-Group Owner role assignment'
        principalType: 'ServicePrincipal'
      }
    ]
  }
}

module RoleAssignmentcustomerMg '../../Templates/Features/RoleAssignmentMG/template.bicep' = {
  scope: managementGroup('mg-${customerMgConfig.name}')
  name: 'RoleAssignment-mg-${customerMgConfig.name}-${time}'
  params: {
    permissions: customerMgConfig.permissions
  }
}

module RoleAssignmentManagementGroups '../../Templates/Features/RoleAssignmentMG/template.bicep' = [for (mg, i) in managementGroupsCombined: if (contains(mg, 'permissions')) {
  scope: managementGroup('mg-${mg.name}')
  name: 'RoleAssignment-${time}-${i + 1}'
  params: {
    permissions: contains(mg, 'permissions') ? mg.permissions : []
  }
}]
