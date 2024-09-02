@description('Virtual Network resource id of the central DNS Virtual Network')
param virtualNetworkResourceId string

@description('Array to only deploy specified azure private dns zones, regional zones also not be deployed and needs to be added to this list')
param customPrivateLinkDnsZones array = []

@description('Array with azure region codes (e.g. we, ne, wus2) for regional private dns zones')
param azureRegionCodes array = [
  'we'
]

@description('Array with azure region names (e.g. westeurope, northeurope) for regional private dns zones')
param azureRegionNames array = [
  'westeurope'
]

param location string = 'global'

param deployAzureMonitorZones bool = false

param tags object = {}

//Array with Azure Monitor private link DNS Zones.
var azureMonitorDnsZones = [
  'privatelink.monitor.azure.com'
  'privatelink.oms.opinsights.azure.com'
  'privatelink.ods.opinsights.azure.com'
  'privatelink.agentsvc.azure-automation.net'
]

// Array with all the default Microsoft private link DNS zones.
var defaultPrivateDnsZones = [
  'privatelink.azure-automation.net'
  'privatelink${environment().suffixes.sqlServerHostname}'
  'privatelink.sql.azuresynapse.net'
  'privatelink.blob.${environment().suffixes.storage}'
  'privatelink.table.${environment().suffixes.storage}'
  'privatelink.queue.${environment().suffixes.storage}'
  'privatelink.file.${environment().suffixes.storage}'
  'privatelink.dfs.${environment().suffixes.storage}'
  'privatelink.web.${environment().suffixes.storage}'
  'privatelink.documents.azure.com'
  'privatelink.mongo.cosmos.azure.com'
  'privatelink.cassandra.cosmos.azure.com'
  'privatelink.gremlin.cosmos.azure.com'
  'privatelink.table.cosmos.azure.com'
  'privatelink.postgres.database.azure.com'
  'privatelink.mysql.database.azure.com'
  'privatelink.mariadb.database.azure.com'
  'privatelink.vaultcore.azure.net'
  'privatelink.search.windows.net'
  'privatelink.azurecr.io'
  'privatelink.azconfig.io'
  'privatelink.servicebus.windows.net'
  'privatelink.azure-devices.net'
  'privatelink.eventgrid.azure.net'
  'privatelink.azurewebsites.net'
  'privatelink.api.azureml.ms'
  'privatelink.notebooks.azure.net'
  'privatelink.service.signalr.net'
  'privatelink.cognitiveservices.azure.com'
  'privatelink.afs.azure.net'
  'privatelink.datafactory.azure.net'
  'privatelink.adf.azure.com'
  'privatelink.redis.cache.windows.net'
  'privatelink.dev.azuresynapse.net'
  'privatelink.azuredatabricks.net'
  'privatelink.azuresynapse.net'
  'privatelink.managedhsm.azure.net'
  'privatelink.siterecovery.windowsazure.com'
  'privatelink.azure-devices-provisioning.net'
  'privatelink.openai.azure.com'
  'privatelink.redisenterprise.cache.azure.net'
  'privatelink.purview.azure.com'
  'privatelink.purviewstudio.azure.com'
  'privatelink.digitaltwins.azure.net'
  'privatelink.azurehdinsight.net'
  'privatelink.his.arc.azure.com'
  'privatelink.dp.kubernetesconfiguration.azure.com'
  'privatelink.media.azure.net'
  'privatelink.azurestaticapps.net'
  'privatelink.prod.migration.windowsazure.com'
  'privatelink.azure-api.net'
  'privatelink.analysis.windows.net'
  'privatelink.pbidedicated.windows.net'
  'privatelink.tip1.powerquery.microsoft.com'
  'privatelink.directline.botframework.com'
  'privatelink.token.botframework.com'
  'privatelink.workspace.azurehealthcareapis.com'
  'privatelink.fhir.azurehealthcareapis.com'
  'privatelink.dicom.azurehealthcareapis.com'
  'privatelink-global.wvd.microsoft.com'
  'privatelink.wvd.microsoft.com'
]

// regional private link zones, as not all private link types are global
var regionalBackupPrivateLinkDnsZones = 'privatelink.{region}.backup.windowsazure.com'
var regionalAksPrivateLinkDnsZones = 'privatelink.{region}.azmk8s.io'
var regionalStorageSyncServicesPrivateLinkDnsZones = '{region}.privatelink.afs.azure.net'
var regionalBatchAccountPrivateLinkDnsZones = '{region}.privatelink.batch.azure.com'
var regionalBatchNodePrivateLinkDnsZones = '{region}.service.privatelink.batch.azure.com'
var regionalACRPrivateLinkDnsZones = '{region}.privatelink.azurecr.io'
// create privateDnsZones array for deployment. Array will be default micrsoft zones or custom specified private link array
var privateDnsZones = empty(customPrivateLinkDnsZones) ? defaultPrivateDnsZones : customPrivateLinkDnsZones

// parent resource private link zone creation. Loop based on privateDnsZones array
module privateLinkZone './modules/privateDnsZone.module.bicep' = [for privateDnsZone in privateDnsZones: {
  name: privateDnsZone
  params: {
    customName: privateDnsZone
    location: location
    tags: tags
  }
}]

// child resource private dns zone virtual network link to create link to central DNS vnet
module privateLinkZoneNetworkLink './modules/privateDnsZoneVirtualNetworkLink.module.bicep' = [for privateDnsZone in privateDnsZones: {
  name: 'vnetlink-${privateDnsZone}'
  params: {
    privateDnsZoneName: privateDnsZone
    registrationEnabled: false
    virtualNetworkResourceId: virtualNetworkResourceId
    location: location
    tags: tags
  }
  dependsOn: [
    privateLinkZone
  ]
}]

// parent resource Azure Monitor private link zone creation. Loop based on privateDnsZones array
module azureMonitorPrivateLinkZone './modules/privateDnsZone.module.bicep' = [for azureMonitorprivateDnsZone in azureMonitorDnsZones: if (deployAzureMonitorZones) {
  name: azureMonitorprivateDnsZone
  params: {
    customName: azureMonitorprivateDnsZone
    location: location
    tags: tags
  }
}]

// child resource Azure Monitor private dns zone virtual network link to create link to central DNS vnet
module azureMonitorPrivateLinkZoneNetworkLink './modules/privateDnsZoneVirtualNetworkLink.module.bicep' = [for azureMonitorprivateDnsZone in azureMonitorDnsZones: if (deployAzureMonitorZones) {
  name: 'vnetlink-${azureMonitorprivateDnsZone}'
  params: {
    privateDnsZoneName: azureMonitorprivateDnsZone
    registrationEnabled: false
    virtualNetworkResourceId: virtualNetworkResourceId
    location: location
    tags: tags
  }
  dependsOn: [
    privateLinkZone
  ]
}]

// parent resource private link zone creation for regional backup private link dns zone. Loop based on azureRgion array
module backupPrivateLinkZone './modules/privateDnsZone.module.bicep' = [for azureRegionCode in azureRegionCodes: if (empty(customPrivateLinkDnsZones)) {
  name: replace(regionalBackupPrivateLinkDnsZones, '{region}', azureRegionCode)
  params: {
    customName: replace(regionalBackupPrivateLinkDnsZones, '{region}', azureRegionCode)
    location: location
    tags: tags
  }
}]

// child resource backup private dns zone virtual network link to create link to central DNS vnet
module backupPrivateLinkZoneNetworkLink './modules/privateDnsZoneVirtualNetworkLink.module.bicep' = [for azureRegionCode in azureRegionCodes: if (empty(customPrivateLinkDnsZones)) {
  name: 'vnetlink-${replace(regionalBackupPrivateLinkDnsZones, '{region}', azureRegionCode)}'
  params: {
    privateDnsZoneName: replace(regionalBackupPrivateLinkDnsZones, '{region}', azureRegionCode)
    registrationEnabled: false
    virtualNetworkResourceId: virtualNetworkResourceId
    location: location
    tags: tags
  }
  dependsOn: [
    backupPrivateLinkZone
  ]
}]

// parent resource private link zone creation for regional aks private link dns zone. Loop based on azureRgion array
module AksPrivateLinkZone './modules/privateDnsZone.module.bicep' = [for azureRegionName in azureRegionNames: if (empty(customPrivateLinkDnsZones)) {
  name: replace(regionalAksPrivateLinkDnsZones, '{region}', azureRegionName)
  params: {
    customName: replace(regionalAksPrivateLinkDnsZones, '{region}', azureRegionName)
    location: location
    tags: tags
  }
}]

// child resource aks private dns zone virtual network link to create link to central DNS vnet
module aksPrivateLinkZoneNetworkLink './modules/privateDnsZoneVirtualNetworkLink.module.bicep' = [for azureRegionName in azureRegionNames: if (empty(customPrivateLinkDnsZones)) {
  name: 'vnetlink-${replace(regionalAksPrivateLinkDnsZones, '{region}', azureRegionName)}'
  params: {
    privateDnsZoneName: replace(regionalAksPrivateLinkDnsZones, '{region}', azureRegionName)
    registrationEnabled: false
    virtualNetworkResourceId: virtualNetworkResourceId
    location: location
    tags: tags
  }
  dependsOn: [
    AksPrivateLinkZone
  ]
}]

// parent resource private link zone creation for regional storageSyncServices private link dns zone. Loop based on azureRgion array
module storageSyncServicesprivateLinkZone './modules/privateDnsZone.module.bicep' = [for azureRegionName in azureRegionNames: if (empty(customPrivateLinkDnsZones)) {
  name: replace(regionalStorageSyncServicesPrivateLinkDnsZones, '{region}', azureRegionName)
  params: {
    customName: replace(regionalStorageSyncServicesPrivateLinkDnsZones, '{region}', azureRegionName)
    location: location
    tags: tags
  }
}]

// child resource storageSyncServices private dns zone virtual network link to create link to central DNS vnet
module storageSyncServicesPrivateLinkZoneNetworkLink './modules/privateDnsZoneVirtualNetworkLink.module.bicep' = [for azureRegionName in azureRegionNames: if (empty(customPrivateLinkDnsZones)) {
  name: 'vnetlink-${replace(regionalStorageSyncServicesPrivateLinkDnsZones, '{region}', azureRegionName)}'
  params: {
    privateDnsZoneName: replace(regionalStorageSyncServicesPrivateLinkDnsZones, '{region}', azureRegionName)
    registrationEnabled: false
    virtualNetworkResourceId: virtualNetworkResourceId
    location: location
    tags: tags
  }
  dependsOn: [
    storageSyncServicesprivateLinkZone
  ]
}]

// parent resource private link zone creation for regional batchAccount private link dns zone. Loop based on azureRgion array
module batchAccountprivateLinkZone './modules/privateDnsZone.module.bicep' = [for azureRegionName in azureRegionNames: if (empty(customPrivateLinkDnsZones)) {
  name: replace(regionalBatchAccountPrivateLinkDnsZones, '{region}', azureRegionName)
  params: {
    customName: replace(regionalBatchAccountPrivateLinkDnsZones, '{region}', azureRegionName)
    location: location
    tags: tags
  }
}]

// child resource batchAccount private dns zone virtual network link to create link to central DNS vnet
module batchAccountPrivateLinkZoneNetworkLink './modules/privateDnsZoneVirtualNetworkLink.module.bicep' = [for azureRegionName in azureRegionNames: if (empty(customPrivateLinkDnsZones)) {
  name: 'vnetlink-${replace(regionalBatchAccountPrivateLinkDnsZones, '{region}', azureRegionName)}'
  params: {
    privateDnsZoneName: replace(regionalBatchAccountPrivateLinkDnsZones, '{region}', azureRegionName)
    registrationEnabled: false
    virtualNetworkResourceId: virtualNetworkResourceId
    location: location
    tags: tags
  }
  dependsOn: [
    batchAccountprivateLinkZone
  ]
}]

// parent resource private link zone creation for regional batchNode private link dns zone. Loop based on azureRgion array
module batchNodeprivateLinkZone './modules/privateDnsZone.module.bicep' = [for azureRegionName in azureRegionNames: if (empty(customPrivateLinkDnsZones)) {
  name: replace(regionalBatchNodePrivateLinkDnsZones, '{region}', azureRegionName)
  params: {
    customName: replace(regionalBatchNodePrivateLinkDnsZones, '{region}', azureRegionName)
    location: location
    tags: tags
  }
}]

// child resource batchNode private dns zone virtual network link to create link to central DNS vnet
module batchNodePrivateLinkZoneNetworkLink './modules/privateDnsZoneVirtualNetworkLink.module.bicep' = [for azureRegionName in azureRegionNames: if (empty(customPrivateLinkDnsZones)) {
  name: 'vnetlink-${replace(regionalBatchNodePrivateLinkDnsZones, '{region}', azureRegionName)}'
  params: {
    privateDnsZoneName: replace(regionalBatchNodePrivateLinkDnsZones, '{region}', azureRegionName)
    registrationEnabled: false
    virtualNetworkResourceId: virtualNetworkResourceId
    location: location
    tags: tags
  }
  dependsOn: [
    batchNodeprivateLinkZone
  ]
}]

// parent resource private link zone creation for regional ACR private link dns zone. Loop based on azureRgion array
module acrPrivateLinkZone './modules/privateDnsZone.module.bicep' = [for azureRegionName in azureRegionNames: if (empty(customPrivateLinkDnsZones)) {
  name: replace(regionalACRPrivateLinkDnsZones, '{region}', azureRegionName)
  params: {
    customName: replace(regionalACRPrivateLinkDnsZones, '{region}', azureRegionName)
    location: location
    tags: tags
  }
}]

// child resource ACR private dns zone virtual network link to create link to central DNS vnet
module acrPrivateLinkZoneNetworkLink './modules/privateDnsZoneVirtualNetworkLink.module.bicep' = [for azureRegionName in azureRegionNames: if (empty(customPrivateLinkDnsZones)) {
  name: 'vnetlink-${replace(regionalACRPrivateLinkDnsZones, '{region}', azureRegionName)}'
  params: {
    privateDnsZoneName: replace(regionalACRPrivateLinkDnsZones, '{region}', azureRegionName)
    registrationEnabled: false
    virtualNetworkResourceId: virtualNetworkResourceId
    location: location
    tags: tags
  }
  dependsOn: [
    acrPrivateLinkZone
  ]
}]
