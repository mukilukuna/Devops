targetScope = 'resourceGroup'

@description('Required. The name of the Azure Policy assignment')
@maxLength(24)
param name string

@description('Required. The name of the scope')
param displayName string

@description('Optional. This message will be part of response in case of policy violation')
param assigmentDescription string = ''

@description('Optional. The policy`s excluded scopes')
param notScopes array = []

@description('Optional. The policy assignment enforcement mode')
@allowed([
  'Default'
  'DoNotEnforce'
])
param policyAssignmentMode string = 'Default'

@description('Required. The ID of the policy definition or policy set definition being assigned')
param policyDefinitionId string

@description('Optional. The parameter values for the policy rule. The keys are the parameter names')
param policyParameters object = {}

@description('Optional. Object containing the metadata for the Azure Policy Assignment')
param metadata object = {
  assignedBy: 'DevOps Pipeline'
}

@description('Optional. Enables deployment of a Managed Identity')
param deployManagedIdentity bool = false

@description('Optional. Location of the managed identity')
param location string = resourceGroup().location

var RGInfo = resourceGroup()

resource policyAssignments 'Microsoft.Authorization/policyAssignments@2021-06-01' = {
  name: name
  location: location
  properties: {
    displayName: '${RGInfo.name} - ${displayName}'
    description: assigmentDescription
    policyDefinitionId: policyDefinitionId
    parameters: policyParameters
    notScopes: notScopes
    enforcementMode: policyAssignmentMode
    metadata: metadata
  }
  identity: deployManagedIdentity ? {
    type: 'SystemAssigned'
  } : {
    type: 'None'
  }
}

@description('ID of the resource')
output resourceID string = policyAssignments.id

@description('Name of the resource')
output resourceName string = policyAssignments.name

@description('Managed identity of the resource')
output managedIdentity string = deployManagedIdentity ? (reference(policyAssignments.id, '2020-09-01', 'Full').identity.principalId) : ''
