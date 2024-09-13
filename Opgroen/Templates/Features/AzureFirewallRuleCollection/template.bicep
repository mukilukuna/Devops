@description('Required. Name of the rule collection group')
param ruleCollectionGroupName string

@description('Required. Name of the Azure Firewall Policy')
param azureFirewallPolicyResourceName string

@description('Required. Priority of the Firewall Policy Rule Collection resource')
param priority int

@description('Required. Array with firewall rulecollection configuration')
param ruleCollections array

@description('Optional. Array of Role Assignments to deploy')
param permissions array = []

resource azureFirewallPolicy 'Microsoft.Network/firewallPolicies@2021-05-01' existing = {
  name: azureFirewallPolicyResourceName
}

resource firewallPolicyRuleCollectionGroup 'Microsoft.Network/firewallPolicies/ruleCollectionGroups@2022-09-01' = {
  parent: azureFirewallPolicy
  name: ruleCollectionGroupName
  properties: {
    priority: priority
    ruleCollections: ruleCollections
  }
}

resource roleAssignments 'Microsoft.Authorization/roleAssignments@2022-04-01' = [for item in permissions: {
  name: guid(resourceGroup().id, item.name, item.roleDefinitionId)
  scope: firewallPolicyRuleCollectionGroup
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

@description('The resource-id of the Azure resource')
output resourceID string = firewallPolicyRuleCollectionGroup.id

@description('The name of the Azure resource')
output resourceName string = firewallPolicyRuleCollectionGroup.name
