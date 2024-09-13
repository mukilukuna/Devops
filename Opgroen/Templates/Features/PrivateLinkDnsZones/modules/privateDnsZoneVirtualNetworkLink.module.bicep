@description('Private DNS zone name(without a terminating dot).')
param privateDnsZoneName string

@description('Custom private link dns zone virtual network link name')
param customName string = ''

@description('Resource Id of the virtual network')
param virtualNetworkResourceId string

@description('Auto-registration of virtual machine records in the virtual network in the Private DNS zone Enabled or Disabled')
param registrationEnabled bool = false

@description('Location of the resource')
param location string = 'global'

@description('Tags which need to be added to the resource')
param tags object = {}

// split private dns zone name to create array
var splitPrivateDnsZone = split(replace(privateDnsZoneName, '.', '-'), '-')
// create prefix in case of privatelink dns zone to be used zonename
var privateLinkDnsZoneNamePrefix = format('{0}-{1}-{2}',splitPrivateDnsZone[0], splitPrivateDnsZone[1], splitPrivateDnsZone[2])
// create zonename to be used in virtual network link, privatelink zones have different prefix for identification
var zoneName = first(splitPrivateDnsZone) == 'privatelink' ?  privateLinkDnsZoneNamePrefix : first(splitPrivateDnsZone)
var vNetName = last(split(virtualNetworkResourceId,'/'))
// identifier for use in virtual network link, read for link and write for link with autoregistration enabled
var readWrite = registrationEnabled ? 'write' : 'read'
// virtual network link name based on parameter input
var virtualNetworkLinkName = empty(customName) ? toLower('${zoneName}-${vNetName}-${readWrite}-link') : toLower(customName)

// parent resource for private dns zone
resource existingPrivateDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' existing = {
  name: privateDnsZoneName
}

// child resource for private dns zone virtual networklink
resource privatednsvirtualnetworklink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  parent: existingPrivateDnsZone
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

output azurePrivateDnsZoneVirtualNetworkLinkName string = privatednsvirtualnetworklink.name
output azurePrivateDnsZoneVirtualNetworkLinkResourceId string = privatednsvirtualnetworklink.id
