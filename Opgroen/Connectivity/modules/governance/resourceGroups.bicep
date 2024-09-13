targetScope = 'subscription'

@description('Optional. Time parameter to create unique deployment. Do not set in parameter file!')
param time string = replace(utcNow(), ':', '-')

var subscriptionConfig = loadJsonContent('../../configs/subscriptionConfig.jsonc')
var namingConvention = subscriptionConfig.namingConvention
var tags = subscriptionConfig.Governance.tags
var location = subscriptionConfig.Governance.location

module ResourceGroupConnectivity '../../../Templates/Features/ResourceGroup/template.bicep' = {
  name: 'ResourceGroup-Connectivity-${time}'
  params: {
    workloadName: namingConvention.workloadName
    applicationName: 'connectivity'
    environmentName: namingConvention.environmentName
    regionName: namingConvention.regionName
    index: 1
    location: location
    tags: tags
  }
}

module ResourceGroupDfcDataExportRG '../../../Templates/Features/ResourceGroup/template.bicep' = {
  name: 'ResourceGroup-DfcDataExportRG-${time}'
  params: {
    workloadName: ''
    applicationName: ''
    environmentName: ''
    regionName: ''
    customName: 'DfcDataExportRG'
    index: 1
    location: location
    tags: tags
  }
}

output ConnectivityRG_ResourceId string = ResourceGroupConnectivity.outputs.resourceID
output ConnectivityRG_ResourceName string = ResourceGroupConnectivity.outputs.resourceName

output DfcDataExportRG_ResourceId string = ResourceGroupDfcDataExportRG.outputs.resourceID
output DfcDataExportRG_ResourceName string = ResourceGroupDfcDataExportRG.outputs.resourceName
