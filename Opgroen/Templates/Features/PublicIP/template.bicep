@description('Required. The name of the application')
param applicationName string

@description('Required. The code of the application this resource will be used for')
param workloadName string

@description('Required. The region this resource will be deployed in')
@maxLength(4)
param regionName string

@description('Required. Index of the resource')
param index int

@description('Required. The code of the environment this resource will be used in')
@maxLength(1)
param environmentName string

@description('Optional. The name to use if not using the normal naming convention')
param customName string = ''

@description('Optional. Resource tags')
param tags object = {}

@description('Optional. Name of a public IP address SKU')
@allowed([
  'Standard'
  'Basic'
])
param publicIPSku string = 'Standard'

@description('Optional. IP address allocation method')
@allowed([
  'Static'
  'Dynamic'
])
param publicIPAllocationMethod string = 'Static'

@description('Optional. The domain name label. The concatenation of the domain name label and the regionalized DNS zone make up the fully qualified domain name associated with the public IP address. If a domain name label is specified, an A DNS record is created for the public IP in the Microsoft Azure DNS system')
param publicIPDomainNameLabel string = ''

@description('Optional. The idle timeout of the public IP address')
param publicIPIdleTimeoutInMinutes int = 10

@description('Optional. 	IP address version')
@allowed([
  'IPv4'
  'IPv6'
])
param publicIPAddressVersion string = 'IPv4'

@description('Optional. Location of the resource')
param location string = resourceGroup().location

@description('Optional. Array of Role Assignments to deploy')
param permissions array = []

@description('Optional. A list of availability zones denoting the IP allocated for the resource needs to come from')
param zones array = [
  '1'
  '2'
  '3'
]

@description('Optional. Diagnostic settings configuration')
param diagnosticSettings array = []

var nameVar = empty(customName) ? toLower('pip-${workloadName}-${applicationName}-${environmentName}-${regionName}-${padLeft(index, 2, '0')}') : customName

resource publicIPAddresses 'Microsoft.Network/publicIPAddresses@2023-05-01' = {
  name: nameVar
  location: location
  tags: tags
  zones: zones
  sku: {
    name: publicIPSku
  }
  properties: {
    publicIPAllocationMethod: publicIPSku == 'Standard' ? 'Static' : publicIPAllocationMethod
    publicIPAddressVersion: publicIPSku == 'Standard' ? 'IPv4' : publicIPAddressVersion
    dnsSettings: empty(publicIPDomainNameLabel) ? null : {
      domainNameLabel: toLower('${publicIPDomainNameLabel}-${uniqueString(resourceGroup().id)}')
    }
    idleTimeoutInMinutes: publicIPIdleTimeoutInMinutes
  }
}

resource diagSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = [for setting in diagnosticSettings: if (!empty(diagnosticSettings)) {
  name: setting.name
  scope: publicIPAddresses
  properties: {
    workspaceId: contains(setting, 'workspaceId') ? setting.workspaceId : null
    storageAccountId: contains(setting, 'diagnosticsStorageAccountId') ? setting.diagnosticsStorageAccountId : null
    logs: contains(setting, 'logs') ? setting.logs : null
    metrics: contains(setting, 'metrics') ? setting.metrics : null
  }
}]

resource roleAssignments 'Microsoft.Authorization/roleAssignments@2022-04-01' = [for item in permissions: {
  name: guid(resourceGroup().id, item.name, item.roleDefinitionId)
  scope: publicIPAddresses
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
output resourceName string = publicIPAddresses.name
@description('The resource-id of the Azure resource')
output resourceID string = publicIPAddresses.id
@description('The FQDN of the Azure Public IP')
output publicIPFqdn string = empty(publicIPDomainNameLabel) ? '' : publicIPAddresses.properties.dnsSettings.fqdn
