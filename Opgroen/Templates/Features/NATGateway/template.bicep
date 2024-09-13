@description('Required. The name of the workload this resource will be used for')
param workloadName string

@description('Required. The name of the application')
param applicationName string

@description('Required. The code of the environment this resource will be used in')
@maxLength(1)
param environmentName string

@description('Required. The region this resource will be deployed in')
@maxLength(4)
param regionName string

@description('Required. Index of the resource')
param index int

@description('Optional. The name to use if not using the normal naming convention')
param customName string = ''

@description('Optional. Resource tags')
param tags object = {}

@description('Optional. The SKU for this NAT Gateway')
@allowed([
  'Standard'
])
param sku string = 'Standard'

@description('Optional. Location of the resource')
param location string = resourceGroup().location

@description('Optional. Array of Role Assignments to deploy')
param permissions array = []

@description('Optional. Zone numbers e.g. 1,2,3')
param availabilityZones array = [
  '1'
  '2'
  '3'
]

@description('Required. For an internal load balancer, the resource group that contains the VNet to connect to')
param subnetID array

@description('Optional. The name to use if not using the normal naming convention (PIP)')
param customPipName string = ''

@description('Optional. For an external load balancer, the type of public IP address to use')
@allowed([
  'Dynamic'
  'Static'
])
param publicIPAddressAllocation string = 'Static'

@description('Optional. Diagnostic settings configuration')
param diagnosticSettings array = []

var natGatewayName_var = empty(customName) ? toLower('ngw-${workloadName}-${applicationName}-${environmentName}-${regionName}-${padLeft(index, 2, '0')}') : customName
var pipNameVar = empty(customPipName) ? toLower('pip-${workloadName}-${applicationName}-${environmentName}-${regionName}-${padLeft(index, 2, '0')}') : customPipName

module pipModule '../PublicIP/template.bicep' = {
  name: pipNameVar
  params: {
    location: location
    workloadName: workloadName
    applicationName: applicationName
    index: index
    environmentName: environmentName
    regionName: regionName
    customName: customPipName
    publicIPAllocationMethod: publicIPAddressAllocation
    publicIPSku: sku
    zones: availabilityZones
  }
}

resource natGateway 'Microsoft.Network/natGateways@2022-01-01' = {
  name: natGatewayName_var
  location: location
  tags: tags
  zones: availabilityZones
  sku: {
    name: sku
  }
  properties: {
    publicIpAddresses: [
      {
        id: pipModule.outputs.resourceID
      }
    ]
    subnets: [for id in subnetID: {
      id: id
    }]
  }
}

resource diagSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = [for diag in diagnosticSettings: if (!empty(diagnosticSettings)) {
  name: diag.name
  scope: natGateway
  properties: {
    workspaceId: contains(diag, 'workspaceId') ? diag.workspaceId : null
    storageAccountId: contains(diag, 'diagnosticsStorageAccountId') ? diag.diagnosticsStorageAccountId : null
    logs: contains(diag, 'logs') ? diag.logs : null
    metrics: contains(diag, 'metrics') ? diag.metrics : null
  }
}]

resource roleAssignments 'Microsoft.Authorization/roleAssignments@2022-01-01-preview' = [for item in permissions: {
  name: guid(resourceGroup().id, item.name, item.roleDefinitionId)
  scope: natGateway
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

@description('The name of the Azure resource')
output resourceName string = natGateway.name
@description('The resource-id of the Azure resource')
output resourceID string = natGateway.id
