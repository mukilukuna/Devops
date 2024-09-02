targetScope = 'managementGroup'

@description('Required. The resource name')
param initiativeName string

@description('Optional. The parameter definitions for parameters used in the policy. The keys are the parameter names')
param initiativeParameters object = {}

@description('Required. Array of policy definition IDs')
param policyDefinitionId array

@description('Required. The display name of the policy set definition')
param displayName string

@description('Optional. The policy definition description')
param desc string = ''

@description('Optional. Metadata of the Azure Policy Initiative')
param metadata object = {}

@description('Optional. contains the PolicyDefinitions')
param defaultPolicyDefinitions array = []

@description('Optional. contains the PolicyDefinitions')
param policyDefinitionGroups array = []

resource policySetDefinitions 'Microsoft.Authorization/policySetDefinitions@2021-06-01' = {
  name: initiativeName
  properties: {
    policyType: 'Custom'
    displayName: displayName
    description: desc
    metadata: metadata
    parameters: initiativeParameters
    policyDefinitionGroups: policyDefinitionGroups
    policyDefinitions: union(defaultPolicyDefinitions, policyDefinitionId)
  }
}

@description('The name of the Azure resource')
output resourceName string = policySetDefinitions.name
@description('The resource-id of the Azure resource')
output resourceID string = policySetDefinitions.id
