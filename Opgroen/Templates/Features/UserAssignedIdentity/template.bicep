@description('Required. The application name of the resource')
param applicationName string

@description('Required. The environment letter of the resource')
@maxLength(1)
param environmentName string

@description('Required. The workload name of the resource')
param workloadName string

@description('Required. The region of the resource')
@maxLength(4)
param regionName string

@description('Required. The index of the resource')
param index int

@description('Optional. Custom name of the resource')
param customName string = ''

@description('Optional. Tags to apply to the resource')
param tags object = {}

@description('Optional. Location of the resource')
param location string = resourceGroup().location

var userAssignedIdentityNamevar = empty(customName) ? toLower('id-${workloadName}-${applicationName}-${environmentName}-${regionName}-${padLeft(index, 2, '0')}') : customName

resource userAssignedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' = {
  name: userAssignedIdentityNamevar
  location: location
  tags: tags
}

@description('The name of the Azure resource')
output resourceName string = userAssignedIdentity.name
@description('The resource-id of the Azure resource')
output resourceID string = userAssignedIdentity.id
@description('The clientID of the Azure User Assigned Managed Identity')
output userAssignedIdentityClientId string = userAssignedIdentity.properties.clientId
@description('The principal id of the Azure User Assigned Managed Identity')
output userAssignedIdentityPrincipalId string = userAssignedIdentity.properties.principalId
