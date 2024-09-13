targetScope = 'subscription'

@description('Required. The name of the workload this resource will be used for')
param workloadName string

@description('Required. The name of the application')
param applicationName string

@description('Required. The code of the environment this resource will be used in')
param environmentName string

@description('Required. The region this resource will be deployed in')
param regionName string

@description('Required. Index of the resource')
param index int

@description('Optional. The name to use if not using the normal naming convention')
param customName string = ''

@description('Optional. Resource tags')
param tags object = {}

@description('Optional. The name of the region where the resource group will be deployed.')
param location string = 'West Europe'

var resourceGroupname = empty(customName) ? toLower('rg-${workloadName}-${applicationName}-${environmentName}-${regionName}-${padLeft(index, 2, '0')}') : customName

resource resourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: resourceGroupname
  location: location
  tags: tags
}

@description('Name of the resourcegroup')
output resourceName string = resourceGroup.name
@description('ID of the resourcegroup')
output resourceID string = resourceGroup.id
