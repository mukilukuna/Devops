@description('Required. Private DNS zone name(without a terminating dot).')
param privateDnsZoneName string

@description('Optional. Custom private link dns zone virtual network link name')
param customName string = ''

@description('Required. Resource Id of the virtual network')
param virtualNetworkResourceId string

@description('Optional. Auto-registration of virtual machine records in the virtual network in the Private DNS zone Enabled or Disabled')
param registrationEnabled bool = false

@description('Optional. Location of the resource')
param location string = 'global'

@description('Optional. Tags which need to be added to the resource')
param tags object = {}

var splitPrivateDnsZone = split(replace(privateDnsZoneName, '.', '-'), '-')
var privateLinkDnsZoneNamePrefix = format('{0}-{1}-{2}', splitPrivateDnsZone[0], splitPrivateDnsZone[1], splitPrivateDnsZone[2])
var zoneName = first(splitPrivateDnsZone) == 'privatelink' ? privateLinkDnsZoneNamePrefix : first(splitPrivateDnsZone)
var vNetName = last(split(virtualNetworkResourceId, '/'))
var readWrite = registrationEnabled ? 'write' : 'read'
var virtualNetworkLinkName = empty(customName) ? toLower('${zoneName}-${vNetName}-${readWrite}-link') : toLower(customName)

resource existingPrivateDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' existing = {
  name: privateDnsZoneName

  resource privatednsvirtualnetworklink 'virtualNetworkLinks@2020-06-01' = {
    name: virtualNetworkLinkName
    tags: tags
    location: location
    properties: {
      registrationEnabled: registrationEnabled
      virtualNetwork: {
        id: virtualNetworkResourceId
      }
    }
  }
}

@description('The name of the Azure resource')
output resourceName string = existingPrivateDnsZone::privatednsvirtualnetworklink.name

@description('The resource-id of the Azure resource')
output resourceID string = existingPrivateDnsZone::privatednsvirtualnetworklink.id
