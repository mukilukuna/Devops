@description('Required. The name of the application ')
param applicationName string

@description('Required. The code of the environment this resource will be used in')
@maxLength(1)
param environmentName string

@description('Required. The name of the workload this resource will be used for')
param workloadName string

@description('Required. Region of the resource')
@maxLength(4)
param regionName string

@description('Required. Index of the resource')
param index int

@description('Optional. The name to use if not using the normal naming convention')
param customName string = ''

@description('Optional. Resource tags')
param tags object = {}

@description('Optional. Name of an Azure Firewall SKU. - AZFW_VNet or AZFW_Hub')
@allowed([
  'AZFW_VNet'
  'AZFW_Hub'
])
param firewallSkuName string = 'AZFW_VNet'

@description('Optional. Tier of an Azure Firewall')
@allowed([
  'Basic'
  'Standard'
  'Premium'
])
param firewallSkuTier string = 'Standard'

@description('Optional. ResourceId of the firewall policy')
param firewallPolicyResourceId string = ''

@description('Optional. Number of Public Ip Address to deploy')
param numberOfPublicIPAddresses int = 1

@description('Required. Virtual Network Resource ID')
param virtualNetworkId string

@description('Optional. Zone numbers e.g. 1,2,3')
param availabilityZones array = [
  '1'
  '2'
  '3'
]

@description('Optional. Microsoft Insights diagnosticSettings configuration')
param diagnosticsSettings array = []

@description('Optional. Location of the resource')
param location string = resourceGroup().location

@description('Optional. Array of Role Assignments to deploy')
param permissions array = []

var firewallName = empty(customName) ? toLower('afw-${workloadName}-${applicationName}-${environmentName}-${regionName}-${padLeft(index, 2, '0')}') : customName

resource existing_vnet 'Microsoft.Network/virtualNetworks@2022-09-01' existing = {
  name: split(virtualNetworkId, '/')[8]
}

resource existing_fw_subnet 'Microsoft.Network/virtualNetworks/subnets@2022-09-01' existing = {
  parent: existing_vnet
  name: 'AzureFirewallSubnet'
}

module pip '../PublicIP/template.bicep' = [for i in range(0, numberOfPublicIPAddresses): {
  name: 'pip-${padLeft((range(0, numberOfPublicIPAddresses)[i] + 1), 2, '0')}-${firewallName}'
  params: {
    location: location
    workloadName: workloadName
    applicationName: applicationName
    environmentName: environmentName
    regionName: regionName
    index: range(0, numberOfPublicIPAddresses)[i] + index
    customName: 'pip-${padLeft((range(0, numberOfPublicIPAddresses)[i] + 1), 2, '0')}-${firewallName}'
    zones: length(availabilityZones) == 0 ? [] : availabilityZones
    publicIPAddressVersion: 'IPv4'
    publicIPAllocationMethod: 'Static'
    publicIPDomainNameLabel: 'pip-${padLeft((range(0, numberOfPublicIPAddresses)[i] + 1), 2, '0')}-${firewallName}'
    publicIPIdleTimeoutInMinutes: 5
    publicIPSku: 'Standard'
  }
}]

resource fw 'Microsoft.Network/azureFirewalls@2022-09-01' = {
  name: firewallName
  location: location
  zones: empty(availabilityZones) ? [] : availabilityZones
  tags: tags
  properties: {
    ipConfigurations: [for (item, i) in range(0, numberOfPublicIPAddresses): {
      name: 'publicIpConfiguration-${i}-${pip[i].outputs.resourceName}'
      properties: {
        subnet: i == 0 ? {
          id: existing_fw_subnet.id
        } : null
        publicIPAddress: {
          id: pip[i].outputs.resourceID
        }
      }
    }]
    firewallPolicy: empty(firewallPolicyResourceId) ? null : {
      id: firewallPolicyResourceId
    }
    sku: {
      name: firewallSkuName
      tier: firewallSkuTier
    }
  }
  dependsOn: [
    pip
  ]
}

resource diagSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = [for diag in diagnosticsSettings: if (!empty(diagnosticsSettings)) {
  scope: fw
  name: diag.name
  properties: {
    workspaceId: contains(diag, 'workspaceId') ? diag.workspaceId : null
    storageAccountId: contains(diag, 'diagnosticStorageAccountId') ? diag.diagnosticsStorageAccountId : null
    serviceBusRuleId: contains(diag, 'serviceBusRuleId') ? diag.serviceBusRuleId : null
    eventHubName: contains(diag, 'eventHubName') ? diag.eventHubName : null
    eventHubAuthorizationRuleId: contains(diag, 'eventHubAuthorizationRuleId') ? diag.eventHubAuthorizationRuleId : null
    logs: contains(diag, 'logs') ? diag.logs : null
    metrics: contains(diag, 'metrics') ? diag.metrics : null
  }
}]

resource roleAssignments 'Microsoft.Authorization/roleAssignments@2022-04-01' = [for item in permissions: {
  name: guid(resourceGroup().id, item.name, item.roleDefinitionId)
  scope: fw
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
output resourceName string = fw.name
@description('The resource-id of the Azure resource')
output resourceID string = fw.id
@description('The names of the public IPs of the Azure Firewall')
output publicIPName array = [for (item, i) in range(0, numberOfPublicIPAddresses): pip[i].outputs.resourceName]
@description('The resource ids of the public IPs of the Azure Firewall')
output publicIPResourceID array = [for (item, i) in range(0, numberOfPublicIPAddresses): pip[i].outputs.resourceID]
@description('The private IP of the Azure Firewall')
output privateIPFirewall string = fw.properties.ipConfigurations[0].properties.privateIPAddress
