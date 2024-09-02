@description('Required. The name of the workload this resource will be used for')
param workloadName string

@description('Required. The name of the application')
param applicationName string

@description('Required. The code of the environment this resource will be used in')
@maxLength(1)
param environmentName string

@description('Required. The region this resource will be deployed in')
@maxLength(4)
param regionName string

@description('Required. Index of the resource')
param index int

@description('Optional. The name to use if not using the normal naming convention')
param customName string = ''

@description('Optional. Resource tags')
param tags object = {}

@description('Optional. Subnet resource ID(s), required if using Private networktype')
param subnetResourceId array = []

@description('Optional. The image registry credentials by which the container group is created from')
param imageRegistryCredentials array = []

@description('Optional. The operating system type required by the containers in the container group')
@allowed([
  'Linux'
  'Windows'
])
param osType string = 'Linux'

@description('Optional. The restart policy for a container (Always, OnFailure, Never)')
@allowed([
  'Always'
  'OnFailure'
  'Never'
])
param restartPolicy string = 'Always'

@description('Optional. Public will create a public IP address for your container instance. Private (Linux Only) will allow you to choose a new or existing virtual network for your container instance. None will not create either a public IP or virtual network.')
@allowed([
  'Public'
  'Private'
  'None'
])
param networkType string = 'None'

@description('Optional. Specify if a Managed Identity should be assigned')
param assignManagedIdentity bool = false

@description('Required. The containers within the container group')
param containers array

@description('Required. DNS configuration for the container group, required if using Public or Private networktype')
param dnsConfig object = {}

@description('Optional. The container group SKU')
@allowed([
  'Standard'
  'Dedicated'
])
param sku string = 'Standard'

@description('Optional. Object describing the encryption key')
param encryptionProperties object = {}

@description('Optional. Object describing the IP configuration of the container group, required if using Public or Private networktype')
param ipAddress object = {}

@description('Required. The list of volumes that can be mounted by containers in this container group')
param volumes array = []

@description('Optional. The init containers for a container group')
param initContainers array = []

@description('Optional. Location of the resource')
param location string = resourceGroup().location

@description('Optional. Diagnostic settings configuration')
param diagnosticSettings array = []

@description('Optional. Array of Role Assignments to deploy')
param permissions array = []

var aciName_var = empty(customName) ? toLower('ci-${workloadName}-${applicationName}-${environmentName}-${regionName}-${padLeft(index, 2, '0')}') : customName

resource aci 'Microsoft.ContainerInstance/containerGroups@2021-10-01' = {
  name: aciName_var
  location: location
  tags: tags
  identity: assignManagedIdentity ? {
    type: 'SystemAssigned'
  } : null

  properties: contains(networkType, 'None') ? {
    containers: containers
    imageRegistryCredentials: imageRegistryCredentials
    restartPolicy: restartPolicy
    osType: osType
    sku: sku
    initContainers: initContainers
    volumes: volumes
  } : {
    containers: containers
    imageRegistryCredentials: imageRegistryCredentials
    restartPolicy: restartPolicy
    ipAddress: ipAddress
    osType: osType
    volumes: volumes
    subnetIds: subnetResourceId
    dnsConfig: empty(subnetResourceId) ? null : dnsConfig
    sku: sku
    encryptionProperties: empty(encryptionProperties) ? null : encryptionProperties
    initContainers: initContainers
  }
}

resource diagSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = [for diag in diagnosticSettings: if (!empty(diagnosticSettings)) {
  name: diag.name
  scope: aci
  properties: {
    workspaceId: contains(diag, 'workspaceId') ? diag.workspaceId : null
    storageAccountId: contains(diag, 'diagnosticsStorageAccountId') ? diag.diagnosticsStorageAccountId : null
    logs: contains(diag, 'logs') ? diag.logs : null
    metrics: contains(diag, 'metrics') ? diag.metrics : null
  }
}]

resource roleAssignments 'Microsoft.Authorization/roleAssignments@2022-01-01-preview' = [for item in permissions: {
  name: guid(resourceGroup().id, item.name, item.roleDefinitionId)
  scope: aci
  properties: {
    principalId: item.principalId
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', item.roleDefinitionId)
    condition: contains(item, 'condition') && item.condition != '' ? item.condition : null
    conditionVersion: contains(item, 'conditionVersion') && item.conditionVersion != '' ? item.conditionVersion : null
    delegatedManagedIdentityResourceId: contains(item, 'delegatedManagedIdentityResourceId') && item.delegatedManagedIdentityResourceId != '' ? item.delegatedManagedIdentityResourceId : null
    description: item.description
    principalType: item.principalType
  }
}]

@description('The name of the Azure resource')
output resourceName string = aci.name
@description('The resource-id of the Azure resource')
output resourceID string = aci.id
