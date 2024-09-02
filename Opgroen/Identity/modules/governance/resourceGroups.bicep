targetScope = 'subscription'

@description('Optional. Time parameter to create unique deployment. Do not set in parameter file!')
param time string = replace(utcNow(), ':', '-')

var subscriptionConfig = loadJsonContent('../../configs/subscriptionConfig.jsonc')
var namingConvention = subscriptionConfig.namingConvention
var tags = subscriptionConfig.Governance.tags
var location = subscriptionConfig.Governance.location
var addc = subscriptionConfig.ADDC

module resourceGroupConnectivity '../../../Templates/Features/ResourceGroup/template.bicep' = {
  name: 'resourceGroupConnectivity-${time}'
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

module resourceGroupMonitoring '../../../Templates/Features/ResourceGroup/template.bicep' = {
  name: 'resourceGroupMonitoring-${time}'
  params: {
    workloadName: namingConvention.workloadName
    applicationName: 'monitoring'
    environmentName: namingConvention.environmentName
    regionName: namingConvention.regionName
    index: 1
    location: location
    tags: tags
  }
}

module resourceGroupSecurity '../../../Templates/Features/ResourceGroup/template.bicep' = {
  name: 'resourceGroupSecurity-${time}'
  params: {
    workloadName: namingConvention.workloadName
    applicationName: 'security'
    environmentName: namingConvention.environmentName
    regionName: namingConvention.regionName
    index: 1
    location: location
    tags: tags
  }
}

module resourceGroupBackup '../../../Templates/Features/ResourceGroup/template.bicep' = {
  name: 'resourceGroupBackup-${time}'
  params: {
    workloadName: namingConvention.workloadName
    applicationName: 'backup'
    environmentName: namingConvention.environmentName
    regionName: namingConvention.regionName
    index: 1
    location: location
    tags: tags
  }
}

module resourceGroupPrivateLinkZones '../../../Templates/Features/ResourceGroup/template.bicep' = {
  name: 'resourceGroupPrivateLinkZones-${time}'
  params: {
    workloadName: namingConvention.workloadName
    applicationName: 'privatelinkzones'
    environmentName: namingConvention.environmentName
    regionName: namingConvention.regionName
    index: 1
    location: location
    tags: tags
  }
}

module resourceGroupADDC '../../../Templates/Features/ResourceGroup/template.bicep' = if (addc.deployADDC == 'yes') {
  name: 'resourceGroupADDC-${time}'
  params: {
    workloadName: namingConvention.workloadName
    applicationName: 'addc'
    environmentName: namingConvention.environmentName
    regionName: namingConvention.regionName
    index: 1
    location: location
    tags: tags
  }
}

output ConnectivityRG_ResourceId string = resourceGroupConnectivity.outputs.resourceID
output ConnectivityRG_ResourceName string = resourceGroupConnectivity.outputs.resourceName

output DfcDataExportRG_ResourceId string = ResourceGroupDfcDataExportRG.outputs.resourceID
output DfcDataExportRG_ResourceName string = ResourceGroupDfcDataExportRG.outputs.resourceName

output MonitoringRG_ResourceId string = resourceGroupMonitoring.outputs.resourceID
output MonitoringRG_ResourceName string = resourceGroupMonitoring.outputs.resourceName

output SecurityRG_ResourceId string = resourceGroupSecurity.outputs.resourceID
output SecurityRG_ResourceName string = resourceGroupSecurity.outputs.resourceName

output PrivateLinkZonesRG_ResourceId string = resourceGroupPrivateLinkZones.outputs.resourceID
output PrivateLinkZonesRG_ResourceName string = resourceGroupPrivateLinkZones.outputs.resourceName

output BackupRG_ResourceId string = resourceGroupBackup.outputs.resourceID
output BackupRG_ResourceName string = resourceGroupBackup.outputs.resourceName

output ADDCRG_ResourceId string = addc.deployADDC == 'yes' ? resourceGroupADDC.outputs.resourceID : ''
output ADDCRG_ResourceName string = addc.deployADDC == 'yes' ? resourceGroupADDC.outputs.resourceName : ' '
