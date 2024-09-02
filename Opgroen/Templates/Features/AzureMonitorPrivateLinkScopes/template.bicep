@description('Required. The name of the application')
param applicationName string
@description('Required. The code of the environment this resource will be used in')
@maxLength(1)
param environmentName string
@description('Required. The name of the workload this resource will be used for')
param workloadName string
@description('Required. Region of the resource')
@maxLength(4)
param regionName string
@description('Optional. The name to use if not using the normal naming convention')
param customName string = ''
@description('Optional. Resource tags')
param tags object = {}
@description('Optional. Azure region')
param location string = 'global'
@description('Optional. Monitor resource to be linked')
param linkedResourceId array
@description('Required. Ingestion access mode')
@allowed([
  'Open'
  'PrivateOnly'
])
param ingestionAccessMode string = 'Open'
@description('Required. Query access mode')
@allowed([
  'Open'
  'PrivateOnly'
])
param queryAccessMode string = 'Open'
@description('Optional. Exclusions of access mode settings')
param exclusions array = []
@description('Optional. Time parameter to create unique deployment. Do not set in parameter file!')
param time string = replace(utcNow(), ':', '-')

module AzureMonitorPrivateLinkScopes 'br/BicepFeatures:azuremonitorprivatelinkscopes:v1.0.0' = {
  name: 'AzureMonitorPrivateLinkScopes-${time}'
  params: {
    applicationName: applicationName
    environmentName: environmentName
    workloadName: workloadName
    regionName: regionName
    customName: customName
    tags: tags
    location: location
    linkedResourceId: linkedResourceId
    ingestionAccessMode: ingestionAccessMode
    queryAccessMode: queryAccessMode
    exclusions: exclusions
  }
}
@description('The name of the Azure resource')
output resourceID string = AzureMonitorPrivateLinkScopes.outputs.resourceID
@description('The resource-id of the Azure resource')
output resourceName string = AzureMonitorPrivateLinkScopes.outputs.resourceName

