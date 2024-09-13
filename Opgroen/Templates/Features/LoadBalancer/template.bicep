@description('Required. The name of the application')
param applicationName string

@description('Required. The code of the environment this resource will be used in')
@maxLength(1)
param environmentName string

@description('Required. The name of the workload this resource will be used for')
param workloadName string

@description('Required. The region this resource will be deployed in')
@maxLength(4)
param regionName string

@description('Required. Index of the resource')
param index int

@description('Optional. Resource tags')
param tags object = {}

@description('Optional. The name to use if not using the normal naming convention (LB)')
param customName string = ''

@description('Optional. Name of a load balancer SKU')
@allowed([
  'Standard'
  'Basic'
  'Gateway'
])
param lbSku string = 'Standard'

@description('Optional. The name to use if not using the normal naming convention (PIP)')
param customPipName string = ''

@description('Optional. For an external load balancer, the type of public IP address to use')
@allowed([
  'Dynamic'
  'Static'
])
param publicIPAddressAllocation string = 'Static'

@description('Required. Indicates whether the load balancer is an external or internal load balancer')
param externalLoadBalancer bool

@description('Required. Array of objects describing the loadbalancing rules')
param loadBalancingRules array

@description('Required. For an internal load balancer, the resource group that contains the VNet to connect to')
param subnetID string

@description('Required. For an internal load balancer, the IP address type to use')
param privateIPType string

@description('Required. For an internal load balancer, the IP address to use on the given subnet')
param privateIPAddress string

@description('Required. The protocol of the end point. If \'Tcp\' is specified, a received ACK is required for the probe to be successful. If \'Http\' or \'Https\' is specified, a 200 OK response from the specifies URI is required for the probe to be successful')
@allowed([
  'Http'
  'Https'
  'Tcp'
])
param probeProtocol string

@description('Required. The port for communicating the probe. Possible values range from 1 to 65535, inclusive')
param probePort int

@description('Required. The interval, in seconds, for how frequently to probe the endpoint for health status. Typically, the interval is slightly less than half the allocated timeout period (in seconds) which allows two full probes before taking the instance out of rotation. The default value is 15, the minimum value is 5')
param probeInterval int

@description('Required. The number of probes where if no response, will result in stopping further traffic from being delivered to the endpoint. This values allows endpoints to be taken out of rotation faster or slower than the typical times used in Azure')
param probeLimit int

@description('Required. The path of the request')
param requestPath string = ''

@description('Optional. Location of the resource')
param location string = resourceGroup().location

@description('Optional. Array of Role Assignments to deploy')
param permissions array = []

@description('Optional. Zones of the public IP')
param zones array = [
  '1'
  '2'
  '3'
]

@description('Optional. Diagnostic settings configuration')
param diagnosticSettings array = []

var LBnameVar = empty(customName) ? toLower('${workloadName}-${applicationName}-${environmentName}-${regionName}-${padLeft(index, 2, '0')}') : customName
var pipNameVar = empty(customPipName) ? toLower('pip-${workloadName}-${applicationName}-${environmentName}-${regionName}-${padLeft(index, 2, '0')}') : customPipName
var resourceType = externalLoadBalancer ? 'lbe' : 'lbi'
var loadBalancerName = '${resourceType}-${LBnameVar}'
var loadBalancerFEIPName = empty(customName) ? toLower('fe-${loadBalancerName}') : customName
var loadBalancerBEPName = empty(customName) ? toLower('bep-${loadBalancerName}') : customName
var loadBalancerProbeName = empty(customName) ? toLower('probe-${loadBalancerName}') : customName

var externalFrontendIPConfig = {
  name: loadBalancerFEIPName
  properties: {
    publicIPAddress: {
      id: lbePIP.id
    }
  }
}
var internalFrontendIPConfig = {
  name: loadBalancerFEIPName
  properties: {
    subnet: {
      id: subnetID
    }
    privateIPAddress: privateIPAddress
    privateIPAllocationMethod: privateIPType
  }
}

module lbePIPModule '../PublicIP/template.bicep' = if (externalLoadBalancer) {
  name: pipNameVar
  params: {
    tags: tags
    zones: zones
    location: location
    workloadName: workloadName
    applicationName: applicationName
    index: index
    environmentName: environmentName
    regionName: regionName
    customName: customPipName
    publicIPAllocationMethod: publicIPAddressAllocation
    publicIPSku: lbSku == 'Standard' ? 'Standard' : 'Basic'
  }
}

resource lbePIP 'Microsoft.Network/publicIPAddresses@2022-01-01' existing = if (externalLoadBalancer) {
  name: lbePIPModule.name
}

resource loadBalancer 'Microsoft.Network/loadBalancers@2022-01-01' = {
  name: loadBalancerName
  location: location
  tags: tags
  sku: {
    name: lbSku
  }
  properties: {
    frontendIPConfigurations: [
      externalLoadBalancer ? externalFrontendIPConfig : internalFrontendIPConfig
    ]
    backendAddressPools: [
      {
        name: loadBalancerBEPName
      }
    ]
    loadBalancingRules: [for item in loadBalancingRules: {
      name: item.name
      properties: {
        frontendIPConfiguration: {
          id: resourceId('Microsoft.Network/loadBalancers/frontendIPConfigurations', loadBalancerName, loadBalancerFEIPName)
        }
        backendAddressPool: {
          id: resourceId('Microsoft.Network/loadBalancers/backendAddressPools', loadBalancerName, loadBalancerBEPName)
        }
        probe: {
          id: resourceId('Microsoft.Network/loadBalancers/probes', loadBalancerName, loadBalancerProbeName)
        }
        protocol: item.protocol
        frontendPort: item.frontendPort
        backendPort: item.backendPort
        idleTimeoutInMinutes: item.idleTimeout
      }
    }]
    probes: [
      {
        name: loadBalancerProbeName
        properties: {
          protocol: probeProtocol
          port: probePort
          intervalInSeconds: probeInterval
          numberOfProbes: probeLimit
          requestPath: probeProtocol == 'Tcp' ? null : requestPath
        }
      }
    ]
  }
}

resource diagSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = [for setting in diagnosticSettings: if (!empty(diagnosticSettings)) {
  name: setting.name
  scope: loadBalancer
  properties: {
    workspaceId: contains(setting, 'workspaceId') ? setting.workspaceId : null
    storageAccountId: contains(setting, 'diagnosticsStorageAccountId') ? setting.diagnosticsStorageAccountId : null
    logs: contains(setting, 'logs') ? setting.logs : null
    metrics: contains(setting, 'metrics') ? setting.metrics : null
  }
}]

resource roleAssignments 'Microsoft.Authorization/roleAssignments@2022-01-01-preview' = [for item in permissions: {
  name: guid(resourceGroup().id, item.name, item.roleDefinitionId)
  scope: loadBalancer
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
output resourceID string = loadBalancer.id
@description('The resource-id of the Azure resource')
output resourceName string = loadBalancer.name
@description('The name of the Azure Load Balancer Back-end Pool')
output backendPoolName string = loadBalancerBEPName
