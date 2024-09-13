@description('Required. The workload this resource will be used for')
param workloadName string

@description('Required. The name of the application')
param applicationName string

@description('Required. The code of the environment this resource will be used in')
param environmentName string

@description('Required. The region this resource will be deployed in')
param regionName string

@description('Required. Index of the resource')
param index int

@description('Optional. Custom name for the resource')
param localGatewayCustomName string = ''

@description('Optional. Object containing the tags to apply to all resources')
param tags object = {}

@description('Required. Name of the virtual network gateway')
param virtualNetworkGatewayName string

@description('Required. IP address of local network gateway')
param localGatewayIpAddress string

@description('Optional. A list of address blocks reserved for this virtual network in CIDR notation')
param localGatewayaddressPrefixes array = []

@description('Optional. Local network gateway`s BGP speaker settings')
param localGatewayBGPSettings object = {}

@description('Optional. Custom name for the resource')
param connectionCustomName string = ''

@allowed([
  'ExpressRoute'
  'IPsec'
  'VPNClient'
  'Vnet2Vnet'
])
@description('Optional. Gateway connection type')
param connectionType string = 'IPsec'

@description('Optional. The routing weight')
param connectionRoutingWeight int = 0

@secure()
@description('Required. The IPSec shared key')
param sharedKey string

@description('Optional. Enable policy-based traffic selectors')
param usePolicyBasedTrafficSelectors bool = false

@allowed([
  'AES128'
  'AES192'
  'AES256'
  'DES'
  'DES3'
  'GCMAES128'
  'GCMAES256'
])
@description('Optional. The IKE encryption algorithm (IKE phase 2)')
param ikeEncryption string = 'AES256'

@allowed([
  'GCMAES128'
  'GCMAES256'
  'MD5'
  'SHA1'
  'SHA256'
  'SHA384'
])
@description('Optional. The IKE integrity algorithm (IKE phase 2)')
param ikeIntegrity string = 'SHA256'

@allowed([
  'DHGroup1'
  'DHGroup2'
  'DHGroup14'
  'DHGroup24'
  'DHGroup2048'
  'ECP256'
  'ECP384'
  'None'
])
@description('Optional. The DH Group used in IKE Phase 1 for initial SA')
param dhGroup string = 'DHGroup24'

@allowed([
  'ECP256'
  'ECP384'
  'None'
  'PFS1'
  'PFS14'
  'PFS2'
  'PFS2048'
  'PFS24'
  'PFSMM'
])
@description('Optional. The Pfs Group used in IKE Phase 2 for new child SA')
param pfsGroup string = 'PFS24'

@description('Optional. The IPSec Security Association (also called Quick Mode or Phase 2 SA) lifetime in seconds for a site to site VPN tunnel')
param saLifeTimeSeconds int = 27000

@description('Optional. The IPSec Security Association (also called Quick Mode or Phase 2 SA) payload size in KB for a site to site VPN tunnel')
param saDataSizeKilobytes int = 102400000

@allowed([
  'AES128'
  'AES192'
  'AES256'
  'DES'
  'DES3'
  'GCMAES128'
  'GCMAES192'
  'GCMAES256'
  'None'
])
@description('Optional. The IPSec encryption algorithm (IKE phase 1)')
param ipsecEncryption string = 'AES256'

@allowed([
  'GCMAES128'
  'GCMAES192'
  'GCMAES256'
  'MD5'
  'SHA1'
  'SHA256'
])
@description('Optional. The IPSec integrity algorithm (IKE phase 1)')
param ipsecIntegrity string = 'SHA256'

@description('Optional. Location of the resource')
param location string = resourceGroup().location

@description('Optional. Array of Role Assignments to deploy')
param permissions array = []

@description('Optional. Diagnostic settings to deploy')
param diagnosticSettings array = []

resource vgw 'Microsoft.Network/virtualNetworkGateways@2021-12-01' existing = {
  name: virtualNetworkGatewayName
}

resource lgw 'Microsoft.Network/localNetworkGateways@2021-12-01' = {
  name: empty(localGatewayCustomName) ? toLower('lgw-${workloadName}-${applicationName}-${environmentName}-${regionName}-${padLeft(index, 2, '0')}') : localGatewayCustomName
  location: location
  tags: tags
  properties: {
    localNetworkAddressSpace: {
      addressPrefixes: localGatewayaddressPrefixes
    }
    gatewayIpAddress: localGatewayIpAddress
    bgpSettings: empty(localGatewayBGPSettings) ? null : localGatewayBGPSettings
  }
}

resource connection 'Microsoft.Network/connections@2021-12-01' = {
  name: empty(connectionCustomName) ? 'vcn-${vgw.name}-to-${lgw.name}' : connectionCustomName
  location: location
  tags: tags
  properties: {
    virtualNetworkGateway1: {
      id: vgw.id
      properties: {}
    }
    localNetworkGateway2: {
      id: lgw.id
      properties: {}
    }
    connectionType: connectionType
    sharedKey: sharedKey
    routingWeight: connectionRoutingWeight
    usePolicyBasedTrafficSelectors: usePolicyBasedTrafficSelectors
    ipsecPolicies: [
      {
        saLifeTimeSeconds: saLifeTimeSeconds
        saDataSizeKilobytes: saDataSizeKilobytes
        ikeEncryption: ikeEncryption
        ikeIntegrity: ikeIntegrity
        ipsecEncryption: ipsecEncryption
        ipsecIntegrity: ipsecIntegrity
        dhGroup: dhGroup
        pfsGroup: pfsGroup
      }
    ]
  }
}

resource diagSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = [for setting in diagnosticSettings: if (!empty(diagnosticSettings)) {
  name: setting.name
  scope: connection
  properties: {
    workspaceId: contains(setting, 'workspaceId') ? setting.workspaceId : null
    storageAccountId: contains(setting, 'diagnosticsStorageAccountId') ? setting.diagnosticsStorageAccountId : null
    logs: contains(setting, 'logs') ? setting.logs : null
    metrics: contains(setting, 'metrics') ? setting.metrics : null
  }
}]

resource roleAssignments 'Microsoft.Authorization/roleAssignments@2022-01-01-preview' = [for item in permissions: {
  name: guid(resourceGroup().id, item.name, item.roleDefinitionId)
  scope: connection
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

@description('Name of the resource')
output resourceName string = connection.name

@description('ID of the resource')
output resourceID string = connection.id

@description('Local network name')
output localNetworkGatewayName string = lgw.name
