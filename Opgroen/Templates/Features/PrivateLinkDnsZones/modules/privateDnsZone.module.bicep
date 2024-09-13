@description('Prefix name of the DNS zone for CCC Private DNS zones (without a terminating dot).')
param zoneNamePrefix string = ''

@description('Prefix name of the DNS zone for CCC Private DNS zones (without a terminating dot).')
param zoneNamePostfix string = ''

@description('Location of the resource')
param location string = 'global'

@description('The environment where the storage account is deployed')
@allowed([
  's'
  'd'
  't'
  'a'
  'p'
])
param dtapName string = 'p'

@description('Is used to create Microsoft private link endpoint DNS zones and custom name zones. Parameter needs to contain the entire dns zone name e.g. privatelink.azurewebsites.net')
param customName string = ''

@description('Tags which need to be added to the resource')
param tags object = {}

// variable to generate dtap prefix to non-production zones to identify dta zones. Production zones will not have a dtap prefix added
var dtapPrefix = dtapName == 'p' ? '' : '-${dtapName}'

// variable to generate privateZoneName based on parameters.
var privateZoneName = empty(customName) ? toLower('${zoneNamePrefix}${dtapPrefix}.${zoneNamePostfix}') : customName

// private dns zone resource
resource privatednszone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: privateZoneName
  location: location
  tags: tags
  properties: {}
}

output azurePrivateDnsZoneName string = privatednszone.name
output azurePrivateDnsZoneResourceId string = privatednszone.id
