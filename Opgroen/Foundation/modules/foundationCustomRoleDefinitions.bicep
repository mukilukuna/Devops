targetScope = 'managementGroup'

var customerMgConfig = loadJsonContent('../configs/customerMgConfig.json')

@description('Optional. time parameter to create unique deployment. Do not set in parameter file!')
param time string = replace(utcNow(), ':', '-')

module customerMgRoleDefinitions '../../Templates/Solutions/CustomRoleDefinitions/template.bicep' = {
  scope: managementGroup('mg-${customerMgConfig.name}')
  name: 'CustomRoleDefinitions-${time}'
}

output azureRolesReaderRole_RoleDefinitionId string = last(split(customerMgRoleDefinitions.outputs.azureRolesReaderRoleRoleDefinitionId, '/'))
output policyReaderRole_RoleDefinitionId string = last(split(customerMgRoleDefinitions.outputs.policyReaderRoleRoleDefinitionId, '/'))
output virtualNetworkPeeringContributor_RoleDefinitionId string = last(split(customerMgRoleDefinitions.outputs.virtualNetworkPeeringContributorRoleDefinitionId, '/'))
output accessManagementAdministrator_RoleDefinitionId string = last(split(customerMgRoleDefinitions.outputs.accessManagementAdministratorRoleDefinitionId, '/'))
output onlineConnectedContributor_RoleDefinitionId string = last(split(customerMgRoleDefinitions.outputs.onlineConnectedContributorRoleDefinitionId, '/'))
output corporateContributor_RoleDefintionId string = last(split(customerMgRoleDefinitions.outputs.corporateContributorRoleDefintionId, '/'))
output azureLockAdministrator_RoleDefinitionId string = last(split(customerMgRoleDefinitions.outputs.azureLockAdministratorRoleDefinitionId, '/'))
output azureFirewallRuleCollectionGroupContributor_RoleDefinitionId string = last(split(customerMgRoleDefinitions.outputs.azureFirewallRuleCollectionGroupContributorRoleDefinitionId, '/'))
output azureBastionReaderRole_RoleDefinitionId string = last(split(customerMgRoleDefinitions.outputs.azureBastionReaderRoleRoleDefinitionId, '/'))
output logAnalyticsDiagContributor_RoleDefinitionId string = last(split(customerMgRoleDefinitions.outputs.logAnalyticsDiagContributorRoleRoleDefinitionId, '/'))
