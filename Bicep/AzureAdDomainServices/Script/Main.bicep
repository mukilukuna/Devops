param Location string = resourceGroup().location
param subid string = subscription().subscriptionId
param DomainName string = 'lukunait.com'
param sku string = 'standard'
resource azureADS 'Microsoft.AAD/domainServices@2022-12-01' = {
  name: DomainName
  location: Location
  properties: {
    domainName: DomainName
    sku: sku
  }
}

resource OrganizationalUnit 'Microsoft.Aad/domainServices/ouContainer@2022-12-01' = {
  name: 'Azure Virtual Desktop'
  parent: azureADS
  accountName: 'string'
  password: 'string'
  spn: 'string'
}
