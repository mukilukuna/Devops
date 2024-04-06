param prefix string = 'CIR'
param location string = 'westeurope'

resource exampleVnet 'Microsoft.Network/virtualNetworks@2020-06-01' = {
  name: '${prefix}euazuvnet'
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.0.0.0/16'
      ]
    }
    subnets: [
      {
        name: '${prefix}euazusubnet'
        properties: {
          addressPrefix: '10.0.1.0/24'
        }
      }
    ]
  }
}

resource exampleNsg 'Microsoft.Network/networkSecurityGroups@2020-06-01' = {
  name: '${prefix}euazuNSG'
  location: location
  properties: {}
}

resource exampleHostPool 'Microsoft.DesktopVirtualization/hostPools@2021-09-03-preview' = {
  name: '${prefix}euazuhp'
  location: location
  properties: {
    hostPoolType: 'Pooled'
    loadBalancerType: 'BreadthFirst'
    preferredAppGroupType: 'RemoteApp'
  }
}

resource exampleApplicationGroup 'Microsoft.DesktopVirtualization/applicationGroups@2021-09-03-preview' = {
  name: '${prefix}euazuvd'
  location: location
  properties: {
    applicationGroupType: 'RemoteApp'
    hostPoolArmPath: exampleHostPool.id
  }
}
