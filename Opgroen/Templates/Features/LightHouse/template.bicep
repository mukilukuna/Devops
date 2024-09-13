targetScope = 'subscription'

@description('Required. Specify a name for your offer')
param mspOfferName string

@description('Required. The description of the registration definition')
param mspOfferDescription string

@description('Required. The identifier of the managedBy tenant')
param managedByTenantId string

@description('Optional. The collection of authorization objects describing the access Azure Active Directory principals in the managedBy tenant will receive on the delegated resource in the managed tenant')
param authorizations array = []

@description('Optional. The collection of eligible authorization objects describing the just-in-time access Azure Active Directory principals in the managedBy tenant will receive on the delegated resource in the managed tenant')
param eligibleAuthorizations array = []

var mspRegistrationName_var = guid(mspOfferName)
var mspAssignmentName_var = guid(mspOfferName)

resource mspRegistrationName 'Microsoft.ManagedServices/registrationDefinitions@2022-01-01-preview' = {
  name: mspRegistrationName_var
  properties: {
    registrationDefinitionName: mspOfferName
    description: mspOfferDescription
    managedByTenantId: managedByTenantId
    authorizations: authorizations
    eligibleAuthorizations: eligibleAuthorizations
  }
}

resource mspAssignmentName 'Microsoft.ManagedServices/registrationAssignments@2022-01-01-preview' = {
  name: mspAssignmentName_var
  properties: {
    registrationDefinitionId: mspRegistrationName.id
  }
}

@description('MSP offer name')
output mspOfferName string = 'Managed by ${mspOfferName}'

@description('Authorizations')
output authorizations array = authorizations

@description('Azure Lighthouse')
output resourceName string = 'Azure Lighthouse'

@description('Azure Lighthouse')
output resourceID string = 'Azure Lighthouse'
