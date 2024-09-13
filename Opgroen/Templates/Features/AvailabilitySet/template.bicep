@description('Required. The application name of the resource.')
@maxLength(5)
param applicationName string

@description('Required. The workload name of the resource.')
@maxLength(3)
param workloadName string

@description('Required. The region this resource will be deployed in.')
@maxLength(4)
param regionName string

@description('Required. Role of the VM.')
@maxLength(2)
param roleName string

@description('Optional. The name to use if not using the normal naming convention.')
param customName string = ''

@description('Required. The environment letter of the resource.')
@maxLength(1)
param environmentName string

@description('Required. Index of the VM.')
param index int

@description('Optional. The number of fault domains to use for the availability set.')
param platformFaultDomainCount int = 3

@description('Optional. The number of update domains to use for the availability set.')
param platformUpdateDomainCount int = 3

@description('Optional. Location of the Action Group object(s)')
param location string = 'westeurope'

@description('Optional. Object containing the tags to apply to all resources')
param tags object = {}

var availabilitySetName = empty(customName) ? toLower('avail-${workloadName}-${applicationName}-${roleName}-${environmentName}-${regionName}-${padLeft(index, 2, '0')}') : customName

resource availabilitySet 'Microsoft.Compute/availabilitySets@2021-07-01' = {
  name: availabilitySetName
  location: location
  sku: {
    name: 'Aligned'
  }
  properties: {
    platformFaultDomainCount: platformFaultDomainCount
    platformUpdateDomainCount: platformUpdateDomainCount
  }
  tags: tags
}

@description('The name of the Azure resource')
output resourceName string = availabilitySet.name
@description('The resource-id of the Azure resource')
output resourceID string = availabilitySet.id
