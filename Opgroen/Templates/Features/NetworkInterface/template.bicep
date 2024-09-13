@description('Required. Name of the VM')
param vmName string

@description('Required. Index of the network interface')
param index int

@description('Optional. Resource tags')
param tags object = {}

@description('Required. ID of the Vnet')
param vNetId string

@description('Required. Name of the subnet')
param subnetName string

@description('Required. Number of IP`s')
param numberOfIPs int

@description('Optional. Private IP address of the IP configuration')
param privateIP string = ''

@description('Optional. IP address allocation method')
@allowed([
  'Dynamic'
  'Static'
])
param privateIPAllocationMethod string = 'Dynamic'

@description('Optional. Enable or disable network acceleration')
param acceleratedNetworking bool = false

@description('Optional. List of DNS servers IP addresses')
param dnsServers array = []

@description('Optional. ID of the public IP')
param publicIpId string = ''

@description('Optional. Name of the load balancer')
param loadBalancerName string = ''

@description('Optional. Name of the load balancer pool')
param loadBalancerPoolName string = ''

@description('Optional. ID of the Application gateway pool')
param applicationGatewayBackendPoolId string = ''

@description('Optional. Application security groups in which the IP configuration is included')
param applicationSecurityGroups array = []

@description('Optional. Location of the network interface')
param location string = resourceGroup().location

@description('Optional. Array of Role Assignments to deploy')
param permissions array = []

@description('Optional. Diagnostic settings configuration')
param diagnosticSettings array = []

resource networkInt 'Microsoft.Network/networkInterfaces@2021-12-01' = {
  name: 'nic-${padLeft(index, 2, '0')}-${vmName}'
  location: location
  tags: tags
  properties: {
    enableAcceleratedNetworking: acceleratedNetworking ? acceleratedNetworking : false
    dnsSettings: {
      dnsServers: !empty(dnsServers) ? dnsServers : []
    }
    ipConfigurations: [for (item2, ipIndex) in range(0, numberOfIPs): {
      name: 'ipconfig${ipIndex + 1}'
      properties: {
        privateIPAllocationMethod: privateIPAllocationMethod
        privateIPAddress: !empty(privateIP) ? privateIP : ''
        primary: ipIndex == 0 ? true : false
        subnet: {
          id: '${vNetId}/subnets/${subnetName}'
        }
        publicIPAddress: !empty(publicIpId) && ipIndex == 0 ? {
          id: publicIpId
        } : null
        loadBalancerBackendAddressPools: !empty(loadBalancerName) && !empty(loadBalancerPoolName) ? [
          {
            id: resourceId('Microsoft.Network/loadBalancers/backendAddressPools', loadBalancerName, loadBalancerPoolName)
          }
        ] : null
        applicationGatewayBackendAddressPools: !empty(applicationGatewayBackendPoolId) ? [
          {
            id: applicationGatewayBackendPoolId
          }
        ] : null
        applicationSecurityGroups: !empty(applicationSecurityGroups) ? applicationSecurityGroups : null
      }
    }]
  }
}

resource diagSettings 'Microsoft.Insights/diagnosticSettings@2021-12-01' = [for diag in diagnosticSettings: if (!empty(diagnosticSettings)) {
  name: diag.name
  scope: networkInt
  properties: {
    workspaceId: contains(diag, 'workspaceId') ? diag.workspaceId : null
    storageAccountId: contains(diag, 'diagnosticsStorageAccountId') ? diag.diagnosticsStorageAccountId : null
    logs: contains(diag, 'logs') ? diag.logs : null
    metrics: contains(diag, 'metrics') ? diag.metrics : null
  }
}]

resource roleAssignments 'Microsoft.Authorization/roleAssignments@2022-01-01-preview' = [for item in permissions: {
  name: guid(resourceGroup().id, item.name, item.roleDefinitionId)
  scope: networkInt
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

@description('The ID of the Azure resource')
output resourceID string = networkInt.id

@description('The name of the Azure resource')
output resourceName string = networkInt.name
