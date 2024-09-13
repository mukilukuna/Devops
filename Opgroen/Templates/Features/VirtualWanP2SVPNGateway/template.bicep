@description('Required. The workload name of the resource.')
param workloadName string

@description('Required. The application name of the resource.')
param applicationName string

@description('Required. The environment letter of the resource.')
@maxLength(1)
param environmentName string

@description('Required. The index of the resource.')
param index int

@description('Required. The region this resource will be deployed in.')
@maxLength(4)
param regionName string

@description('Optional. Custom name of the resource.')
param customName string = ''

@description('Optional. Tags to apply to the resource.')
param tags object = {}

@description('Optional. Location of the resource.')
param location string = resourceGroup().location

@description('Optional. Array of Role Assignments to deploy')
param permissions array = []

@description('Required. Resource ID of the Virtual Wan Hub.')
param vWANHubId string

@description('Optional. Custom DNS Servers for P2S VPN.')
param customDnsServers array = []

@description('Optional. Enable Routing Preference property for the Public IP Interface of the P2SVpnGateway.')
param isRoutingPreferenceInternet bool = false

@description('Optional. Flag indicating whether the enable internet security flag is turned on for the P2S Connections or not.')
param enableInternetSecurity bool = false

@description('Optional. VWAN Hub Route Table associated with this connection.')
param associatedRouteTable string = ''

@description('Optional. The list of RouteTables to advertise the routes to.')
param propagatedRouteTables object = {}

@description('Optional. List of static routes that control routing from VirtualHub into a virtual network connection.')
param staticRoutes array = []

@description('Optional. The scale unit for this P2S VPN Gateway.')
param vpnGatewayScaleUnit int = 1

@description('Optional. Resource ID of the P2S Config')
param p2sServerconfigurationRID string

@description('Optional. Name for the P2S Configuration')
param customConfigurationName string = ''

@description('Required.  Array of IP address ranges that can be used by P2S VPN clients.')
param vpnClientAddressPool array

@description('Optional. Diagnostic settings configuration.')
param diagnosticSettings array = []

var nameVar = empty(customName) ? toLower('vgw-p2s-${workloadName}-${applicationName}${environmentName}-${regionName}-${padLeft(index, 2, '0')}') : customName
var vWANHubResourceInfo = {
  subscription: split(vWANHubId, '/')[1]
  resourceGroup: split(vWANHubId, '/')[3]
  resourceName: last(split(vWANHubId, '/'))
}
var p2sServerconfigurationInfo = {
  subscription: split(p2sServerconfigurationRID, '/')[1]
  resourceGroup: split(p2sServerconfigurationRID, '/')[3]
  resourceName: last(split(p2sServerconfigurationRID, '/'))
}
var p2sConfigurationName = (empty(customConfigurationName) ? toLower('${nameVar}-cfg') : customConfigurationName)

resource vWanHub 'Microsoft.Network/virtualHubs@2021-05-01' existing = {
  name: vWANHubResourceInfo.resourceName

  resource defaultRouteTableRes 'hubRouteTables' existing = {
    name: 'defaultRouteTable'
  }

  resource noneRouteTableRes 'hubRouteTables' existing = {
    name: 'noneRouteTable'
  }
}
resource p2sVPNConfig 'Microsoft.Network/vpnServerConfigurations@2021-05-01' existing = {
  name: p2sServerconfigurationInfo.resourceName
}

resource p2svpng 'Microsoft.Network/p2svpnGateways@2021-12-01' = {
  name: nameVar
  location: location
  tags: tags
  properties: {
    customDnsServers: customDnsServers
    isRoutingPreferenceInternet: isRoutingPreferenceInternet
    virtualHub: {
      id: vWanHub.id
    }
    vpnGatewayScaleUnit: vpnGatewayScaleUnit
    vpnServerConfiguration: {
      id: p2sVPNConfig.id
    }
    p2SConnectionConfigurations: [
      {
        name: p2sConfigurationName
        properties: {
          enableInternetSecurity: enableInternetSecurity
          routingConfiguration: {
            associatedRouteTable: {
              id: !empty(associatedRouteTable) ? associatedRouteTable : vWanHub::defaultRouteTableRes.id
            }
            propagatedRouteTables: {
              ids: [
                contains(propagatedRouteTables, 'ids') && !empty(propagatedRouteTables.ids) ? propagatedRouteTables.ids : {
                  id: vWanHub::noneRouteTableRes.id
                }
              ]
              labels: [
                contains(propagatedRouteTables, 'labels') && !empty(propagatedRouteTables.labels) ? propagatedRouteTables.labels : 'None'
              ]
            }
            vnetRoutes: {
              staticRoutes: staticRoutes
            }
          }
          vpnClientAddressPool: {
            addressPrefixes: vpnClientAddressPool
          }
        }
      }
    ]
  }
}

resource diagSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = [for setting in diagnosticSettings: if (!empty(diagnosticSettings)) {
  name: empty(diagnosticSettings) ? 'outOfBoundsError' : setting.name
  scope: p2svpng
  properties: {
    workspaceId: contains(setting, 'workspaceId') ? setting.workspaceId : null
    storageAccountId: contains(setting, 'diagnosticsStorageAccountId') ? setting.diagnosticsStorageAccountId : null
    logs: contains(setting, 'logs') ? setting.logs : null
    metrics: contains(setting, 'metrics') ? setting.metrics : null
  }
}]

resource roleAssignments 'Microsoft.Authorization/roleAssignments@2022-01-01-preview' = [for item in permissions: {
  name: guid(resourceGroup().id, item.name, item.roleDefinitionId)
  scope: p2svpng
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

@description('The resource-ID of the Azure resource')
output resourceID string = p2svpng.id
@description('The name of the Azure resource')
output resourceName string = p2svpng.name
