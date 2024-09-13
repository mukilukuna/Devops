@description('Required. The workload name of the resource.')
param workloadName string

@description('Required. The application name of the resource.')
param applicationName string

@description('Required. The environment letter of the resource.')
@maxLength(1)
param environmentName string

@description('Required. The region this resource will be deployed in.')
@maxLength(4)
param regionName string

@description('Required. The index of the resource.')
param index int

@description('Optional. Custom name of the resource.')
param customName string = ''

@description('Optional. Location of the resource')
param location string = resourceGroup().location

@description('Optional. Array of Role Assignments to deploy')
param permissions array = []

@description('Optional. The type of the VirtualWAN')
@allowed([
  'Basic'
  'Standard'
])
param type string = 'Standard'

@description('Optional. Vpn encryption to be disabled or not.')
param disableVpnEncryption bool = false

@description('Optional. True if branch to branch traffic is allowed.')
param allowBranchToBranchTraffic bool = true

@description('Optional. True if Vnet to Vnet traffic is allowed.')
param allowVnetToVnetTraffic bool = true

@description('Optional. Resource Tags')
param tags object = {}

var nameVar = empty(customName) ? toLower('vwan-${workloadName}-${applicationName}-${environmentName}-${regionName}-${padLeft(index, 2, '0')}') : customName

resource vWan 'Microsoft.Network/virtualWans@2023-05-01' = {
  name: nameVar
  location: location
  tags: tags
  properties: {
    type: type
    disableVpnEncryption: disableVpnEncryption
    allowBranchToBranchTraffic: allowBranchToBranchTraffic
    allowVnetToVnetTraffic: allowVnetToVnetTraffic
  }
}

resource roleAssignments 'Microsoft.Authorization/roleAssignments@2022-04-01' = [for item in permissions: {
  name: guid(resourceGroup().id, item.name, item.roleDefinitionId)
  scope: vWan
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

@description('ID of the resource')
output resourceID string = vWan.id
@description('Name of the resource')
output resourceName string = vWan.name
