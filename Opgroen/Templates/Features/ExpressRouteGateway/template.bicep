@description('Required. The name of the application')
param applicationName string

@description('Required. The name of the workload this resource will be used for')
param workloadName string

@description('Required. The code of the environment this resource will be used in')
@maxLength(1)
param environmentName string

@description('Required. Index of the resource')
param index int

@description('Required. Region this resource will be deployed in')
@maxLength(4)
param regionName string

@description('Optional. The name to use if not using the normal naming convention (EGW)')
param customName string = ''

@description('Optional. The name to use if not using the normal naming convention (PIP)')
param customEgwPipName string = ''

@description('Optional. The SKU of the of the resource')
@allowed([
  'Standard'
  'HighPerformance'
  'UltraPerformance'
  'ErGw1AZ'
  'ErGw2AZ'
  'ErGw3AZ'
])
param gatewaySku string = 'ErGw1AZ'

@description('Required. The resource ID of the virtual network.')
param vNetId string

@description('Optional. PIP Zone redudancy.')
param pipZones array = [
  '1'
  '2'
  '3'
]

@description('Optional. Resource tags')
param tags object = {}

@description('Optional. Location of the resource')
param location string = resourceGroup().location

@description('Optional. Array of Role Assignments to deploy')
param permissions array = []

var namevar = (empty(customName) ? toLower('egw-${workloadName}-${applicationName}-${environmentName}-${regionName}-${padLeft(index, 2, '0')}') : customName)

module expressGatewayPIP '../PublicIP/template.bicep' = {
  name: '${namevar}-pip'
  params: {
    zones: pipZones
    location: location
    workloadName: 'egw-${workloadName}'
    applicationName: applicationName
    environmentName: environmentName
    regionName: regionName
    index: index
    customName: customEgwPipName
    publicIPAllocationMethod: startsWith(toLower(gatewaySku), 'ergw') ? 'Static' : 'Dynamic'
    publicIPDomainNameLabel: namevar
    publicIPSku: startsWith(toLower(gatewaySku), 'ergw') ? 'Standard' : 'Basic'
  }
}

resource expressGatewayName 'Microsoft.Network/virtualNetworkGateways@2023-05-01' = {
  name: namevar
  location: location
  tags: tags
  properties: {
    ipConfigurations: [
      {
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            #disable-next-line use-resource-id-functions
            id: '${vNetId}/subnets/GatewaySubnet'
          }
          publicIPAddress: {
            id: expressGatewayPIP.outputs.resourceID
          }
        }
        name: 'vnetGatewayConfig'
      }
    ]
    sku: {
      name: gatewaySku
      tier: gatewaySku
    }
    gatewayType: 'ExpressRoute'
  }
}

resource roleAssignments 'Microsoft.Authorization/roleAssignments@2022-04-01' = [for item in permissions: {
  name: guid(resourceGroup().id, item.name, item.roleDefinitionId)
  scope: expressGatewayName
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
output resourceName string = expressGatewayName.name
@description('The resource-id of the Azure resource')
output resourceID string = expressGatewayName.id
@description('The resource-id of the Azure VNET GW')
output gateWayPIP string = expressGatewayPIP.outputs.resourceID
