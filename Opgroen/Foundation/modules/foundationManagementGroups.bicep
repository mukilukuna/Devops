targetScope = 'managementGroup'

param managementGroupIdPrefix string
param managementGroupDisplaynamePrefix string = ''
param managementGroupDisplayNameSuffix string = ''
param managementGroupIdSuffix string = ''

var tenantRootConfig = loadJsonContent('../configs/tenantRootGroupConfig.json')
var customerMgConfig = loadJsonContent('../configs/customerMgConfig.json')
var customerMgChildConfig = loadJsonContent('../configs/customerMgChildConfig.json')
var platformMgChildConfig = loadJsonContent('../configs/platformMgChildConfig.json')
var platformLzChildConfig = loadJsonContent('../configs/customerMgLzChildConfig.json')

module customerMg '../../Templates/Features/ManagementGroup/template.bicep' = {
  scope: tenant()
  name: customerMgConfig.name
  params: {
    displayName: customerMgConfig.name
    managementGroupName: customerMgConfig.name
    parentResourceId: '/providers/Microsoft.Management/managementGroups/${tenant().tenantId}'
    managementGroupIdPrefix: managementGroupIdPrefix
    managementGroupDisplaynamePrefix: managementGroupDisplaynamePrefix
    managementGroupDisplayNameSuffix: managementGroupDisplayNameSuffix
    managementGroupIdSuffix: managementGroupIdSuffix
  }
}

module customerMgs '../../Templates/Features/ManagementGroup/template.bicep' = [for (mg, i) in customerMgChildConfig: {
  scope: tenant()
  name: 'mg-${mg.name}-${i + 1}'
  dependsOn: [
    customerMg
  ]
  params: {
    displayName: mg.name
    managementGroupName: mg.name
    parentResourceId: customerMg.outputs.resourceID
    managementGroupIdPrefix: managementGroupIdPrefix
    managementGroupDisplaynamePrefix: managementGroupDisplaynamePrefix
    managementGroupDisplayNameSuffix: managementGroupDisplayNameSuffix
    managementGroupIdSuffix: managementGroupIdSuffix
  }
}]

module platformMgs '../../Templates/Features/ManagementGroup/template.bicep' = [for (mg, i) in platformMgChildConfig: {
  dependsOn: [
    customerMgs
  ]
  scope: tenant()
  name: 'mg-${mg.name}-${i + 1}'
  params: {
    displayName: mg.name
    managementGroupName: mg.name
    parentResourceId: '/providers/Microsoft.Management/managementGroups/${managementGroupIdPrefix}Platform${managementGroupIdSuffix}'
    managementGroupIdPrefix: managementGroupIdPrefix
    managementGroupDisplaynamePrefix: managementGroupDisplaynamePrefix
    managementGroupDisplayNameSuffix: managementGroupDisplayNameSuffix
    managementGroupIdSuffix: managementGroupIdSuffix
  }
}]

module landingZoneManagementGroups '../../Templates/Features/ManagementGroup/template.bicep' = [for (mg, i) in platformLzChildConfig: {
  dependsOn: [
    platformMgs
  ]
  scope: tenant()
  name: 'landingzonemanagementGroups${i}'
  params: {
    displayName: mg.name
    managementGroupName: mg.name
    parentResourceId: '/providers/Microsoft.Management/managementGroups/${managementGroupIdPrefix}LandingZones${managementGroupIdSuffix}'
    managementGroupMembers: mg.members
    managementGroupIdPrefix: managementGroupIdPrefix
    managementGroupDisplaynamePrefix: managementGroupDisplaynamePrefix
    managementGroupDisplayNameSuffix: managementGroupDisplayNameSuffix
    managementGroupIdSuffix: managementGroupIdSuffix
  }
}]

module managementGroupSettings '../../Templates/Features/ManagementGroupSettings/template.bicep' = {
  scope: tenant()
  name: 'managementGroupSettings'
  dependsOn: [
    customerMg
    customerMgs
  ]
  params: {
    authForNewMG: tenantRootConfig.authForNewMG
    defaultMgId: empty(tenantRootConfig.defaultMgId) ? tenant().tenantId : 'mg-${tenantRootConfig.defaultMgId}'
  }
}

output customerMg_ResourceName string = customerMg.outputs.resourceName
output customerMg_ResourceId string = customerMg.outputs.resourceID
