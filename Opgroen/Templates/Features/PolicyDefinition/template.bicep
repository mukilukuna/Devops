targetScope = 'managementGroup'

@description('Required. The resource name')
param name string

@description('Required. The display name of the policy definition')
param displayName string

@description('Optional. The policy definition description')
param desc string = ''

@description('Required. Object describing the policy rule')
param policyRule object

@description('Optional. The parameter definitions for parameters used in the policy. The keys are the parameter names')
param policyParameters object = {}

@description('Optional. Metadata of the policy objects')
param policyMetadata object = {}

@description('Optional. The policy definition mode')
param mode string = 'All'

resource policyDefinitions 'Microsoft.Authorization/policyDefinitions@2021-06-01' = {
  name: name
  properties: {
    policyType: 'Custom'
    displayName: displayName
    description: desc
    mode: mode
    parameters: policyParameters
    policyRule: policyRule
    metadata: policyMetadata
  }
}

@description('The name of the Azure resource')
output resourceName string = policyDefinitions.name
@description('The resource-id of the Azure resource')
output resourceID string = policyDefinitions.id
