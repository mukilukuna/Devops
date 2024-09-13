targetScope = 'subscription'

@description('Optional. Time parameter to create unique deployment. Do not set in parameter file!')
param time string = replace(utcNow(), ':', '-')

var subscriptionConfig = loadJsonContent('../../configs/subscriptionConfig.jsonc')
var namingConvention = subscriptionConfig.namingConvention
var tags = subscriptionConfig.Governance.tags
var location = subscriptionConfig.Governance.location

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

module resourceGroupAutomation '../../../Templates/Features/ResourceGroup/template.bicep' = {
  name: 'resourceGroupAutomation-${time}'
  params: {
    workloadName: namingConvention.workloadName
    applicationName: 'automation'
    environmentName: namingConvention.environmentName
    regionName: namingConvention.regionName
    index: 1
    location: location
    tags: tags
  }
}

module resourceGroupWorkbooks '../../../Templates/Features/ResourceGroup/template.bicep' = {
  name: 'resourceGroupWorkbooks-${time}'
  params: {
    workloadName: namingConvention.workloadName
    applicationName: 'workbooks'
    environmentName: namingConvention.environmentName
    regionName: namingConvention.regionName
    index: 1
    location: location
    tags: tags
  }
}

module resourceGroupNpm '../../../Templates/Features/ResourceGroup/template.bicep' = {
  name: 'resourceGroupNpm-${time}'
  params: {
    workloadName: namingConvention.workloadName
    applicationName: 'npm'
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

output BackupRG_ResourceId string = resourceGroupBackup.outputs.resourceID
output BackupRG_ResourceName string = resourceGroupBackup.outputs.resourceName

output AutomationRG_ResourceId string = resourceGroupAutomation.outputs.resourceID
output AutomationRG_ResourceName string = resourceGroupAutomation.outputs.resourceName

output WorkbooksRG_ResourceId string = resourceGroupWorkbooks.outputs.resourceID
output WorkbooksRG_ResourceName string = resourceGroupWorkbooks.outputs.resourceName

output NpmRG_ResourceId string = resourceGroupNpm.outputs.resourceID
output NpmRG_ResourceName string = resourceGroupNpm.outputs.resourceName
