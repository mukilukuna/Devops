@description('Required. The application name of the resource.')
param applicationName string

@description('Required. The workload name of the resource.')
param workloadName string

@description('Required. The environment letter of the resource.')
@maxLength(1)
param environmentName string

@description('Required. The Index of the resource.')
param index int

@description('Required. The region this resource will be deployed in.')
@maxLength(4)
param regionName string

@description('Optional. The custom name of the resource.')
param customName string = ''

@description('Optional. The custom name of the pip')
param customVgwPipName string = ''

@description('Optional. The custom name of the active-active pip')
param customVgwPipActiveActiveName string = ''

@description('Optional. Configuration object for P2S clients.')
param vpnClientConfiguration object = {}

@description('Optional. The SKU of the of the resource')
@allowed([
  'Basic'
  'ErGw1AZ'
  'ErGw2AZ'
  'ErGw3AZ'
  'HighPerformance'
  'Standard'
  'UltraPerformance'
  'VpnGw1'
  'VpnGw1AZ'
  'VpnGw2'
  'VpnGw2AZ'
  'VpnGw3'
  'VpnGw3AZ'
  'VpnGw4'
  'VpnGw4AZ'
  'VpnGw5'
  'VpnGw5AZ'
])
param gatewaySku string = 'VpnGw1AZ'

@description('Optional. The generation for this VirtualNetworkGateway.')
@allowed([
  'Generation1'
  'Generation2'
  'None'
])
param vpnGatewayGeneration string = 'Generation1'

@description('Optional. ActiveActive flag.')
param activeActive bool = true

@description('Optional. Whether BGP is enabled for this virtual network gateway or not.')
param enableBgp bool = false

@description('Optional. The type of this virtual network gateway.')
@allowed([
  'PolicyBased'
  'RouteBased'
])
param vpnType string = 'RouteBased'

@description('Whether private IP needs to be enabled on this gateway for connections or not.')
param enablePrivateIpAddress bool

@description('Optional. The BGP speakers ASN.')
param asn int = 65515

@description('Optional. The weight added to routes learned from this BGP speaker.')
param peerWeight int = 0

@description('Optional. The list of custom BGP peering addresses which belong to Primary IP configuration.')
param customBgpIpAddresses array = []

@description('Optional. For ActiveActive mode the list of custom BGP peering addresses which belong to Secondary IP configuration.')
param customBgpIpAddressesActiveActive array = []

@description('Optional. The resource ID of the virtual network.')
param vNetId string = ''

@description('Optional. Tags to apply to the resource.')
param tags object = {}

@description('Optional. Location of the resource.')
param location string = resourceGroup().location

@description('Optional. Array of Role Assignments to deploy')
param permissions array = []

@description('Optional. PIP Zone redudancy.')
param pipZones array = [
  '1'
  '2'
  '3'
]

var namevar = (empty(customName) ? toLower('vgw-${workloadName}-${applicationName}-${environmentName}-${regionName}-${padLeft(index, 2, '0')}') : customName)

var ipConfigurations = [
  {
    properties: {
      privateIPAllocationMethod: 'Dynamic'
      subnet: {
        id: '${vNetId}/subnets/GatewaySubnet'
      }
      publicIPAddress: {
        id: vpnGatewayPIP.outputs.resourceID
      }
    }
    name: 'vnetGatewayConfig'
  }
]

var ipConfigurationsActiveActive = [
  {
    properties: {
      privateIPAllocationMethod: 'Dynamic'
      subnet: {
        id: '${vNetId}/subnets/GatewaySubnet'
      }
      publicIPAddress: {
        id: vpnGatewayPIP.outputs.resourceID
      }
    }
    name: 'vnetGatewayConfig'
  }
  {
    properties: {
      privateIPAllocationMethod: 'Dynamic'
      subnet: {
        id: '${vNetId}/subnets/GatewaySubnet'
      }
      publicIPAddress: {
        id: vpnGatewayPIPActiveActive.outputs.resourceID
      }
    }
    name: 'vnetGatewayConfigActiveActive'
  }
]

var bgpSettings = {
  asn: asn
  peerWeight: peerWeight
  bgpPeeringAddresses: [
    {
      ipconfigurationId: '${resourceId('Microsoft.Network/VirtualNetworkGateways', namevar)}/ipConfigurations/vnetGatewayConfig'
      customBgpIpAddresses: customBgpIpAddresses
    }
  ]
}

var bgpSettingsActiveActive = {
  asn: asn
  peerWeight: peerWeight
  bgpPeeringAddresses: [
    {
      ipconfigurationId: '${resourceId('Microsoft.Network/VirtualNetworkGateways', namevar)}/ipConfigurations/vnetGatewayConfig'
      customBgpIpAddresses: customBgpIpAddresses
    }
    {
      ipconfigurationId: '${resourceId('Microsoft.Network/VirtualNetworkGateways', namevar)}/ipConfigurations/vnetGatewayConfigActiveActive'
      customBgpIpAddresses: customBgpIpAddressesActiveActive
    }
  ]
}

module vpnGatewayPIP '../PublicIP/template.bicep' = {
  name: '${namevar}-pip'
  params: {
    workloadName: 'vgw-${workloadName}'
    applicationName: applicationName
    environmentName: environmentName
    regionName: regionName
    index: index
    zones: pipZones
    customName: customVgwPipName
    publicIPAllocationMethod: (startsWith(toLower(gatewaySku), 'vpngw') ? 'Static' : 'Dynamic')
    publicIPDomainNameLabel: namevar
    publicIPSku: (startsWith(toLower(gatewaySku), 'vpngw') ? 'Standard' : 'Basic')
    location: location
  }
}

module vpnGatewayPIPActiveActive '../PublicIP/template.bicep' = if (activeActive) {
  name: '${namevar}-pipActiveActive'
  params: {
    workloadName: 'vgw-${workloadName}'
    applicationName: applicationName
    environmentName: environmentName
    regionName: regionName
    index: index + 1
    zones: pipZones
    customName: customVgwPipActiveActiveName
    publicIPAllocationMethod: (startsWith(toLower(gatewaySku), 'vpngw') ? 'Static' : 'Dynamic')
    publicIPDomainNameLabel: '${namevar}-aa'
    publicIPSku: (startsWith(toLower(gatewaySku), 'vpngw') ? 'Standard' : 'Basic')
    location: location
  }
}

resource vpnGateways 'Microsoft.Network/virtualNetworkGateways@2023-05-01' = {
  name: namevar
  location: location
  tags: tags
  properties: {
    ipConfigurations: activeActive ? ipConfigurationsActiveActive : ipConfigurations
    sku: {
      name: gatewaySku
      tier: gatewaySku
    }
    gatewayType: 'Vpn'
    vpnClientConfiguration: vpnClientConfiguration
    vpnGatewayGeneration: vpnGatewayGeneration
    vpnType: vpnType
    enableBgp: enableBgp
    activeActive: activeActive
    enablePrivateIpAddress: enablePrivateIpAddress
    bgpSettings: (startsWith(toLower(gatewaySku), 'vpngw') ? activeActive ? bgpSettingsActiveActive : bgpSettings : json('null'))
  }
}

resource roleAssignments 'Microsoft.Authorization/roleAssignments@2022-04-01' = [for item in permissions: {
  name: guid(resourceGroup().id, item.name, item.roleDefinitionId)
  scope: vpnGateways
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
output resourceName string = vpnGateways.name
@description('The resource-id of the Azure resource')
output resourceID string = vpnGateways.id
@description('The publicIP of the Azure VNET GW')
output gateWayPIP string = vpnGatewayPIP.outputs.resourceID
@description('The publicIP of the Azure VNET GW')
output gateWayPIPActiveActive string = activeActive ? vpnGatewayPIPActiveActive.outputs.resourceID : ''
