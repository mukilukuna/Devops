targetScope = 'resourceGroup'

@description('Required. The name of the Azure Policy assignment')
@maxLength(24)
param name string

@description('Optional. The description of the policy exemption')
param exemptionDescription string = ''

@description('Required. The policy exemption category')
@allowed([
  'Mitigated'
  'Waiver'
])
param exemptionCategory string

@description('Optional. The expiration date and time (in UTC ISO 8601 format yyyy-MM-ddTHH:mm:ssZ) of the policy exemption')
param expiresOn string = ''

@description('Optional. Object containing the metadata for the Azure Policy Assignment')
param metadata object = {}

@description('Optional. The ID of the policy assignment that is being exempted')
param policyAssignmentId string = ''

@description('Optional. The policy definition reference ID list when the associated policy assignment is an assignment of a policy set definition')
param policyDefinitionReferenceIds array = []

resource policyExemptions 'Microsoft.Authorization/policyExemptions@2020-07-01-preview' = {
  name: '${resourceGroup().name}-${exemptionCategory}-${name}'
  properties: {
    description: exemptionDescription
    displayName: '${resourceGroup().name} - ${exemptionCategory} - ${name}'
    exemptionCategory: exemptionCategory
    expiresOn: expiresOn
    metadata: metadata
    policyAssignmentId: policyAssignmentId
    policyDefinitionReferenceIds: policyDefinitionReferenceIds
  }
}

@description('The name of the Azure resource')
output resourceName string = policyExemptions.name
@description('The resource-id of the Azure resource')
output resourceID string = policyExemptions.id
