param avdHostPoolName string
param location string

resource hostPool 'Microsoft.DesktopVirtualization/hostpools@2023-09-05' = {
  name: avdHostPoolName
  location: location
  properties: {
    hostPoolType: 'Pooled'
    loadBalancerType: 'BreadthFirst'
    preferredAppGroupType: 'Desktop'
  }
}

output hostPoolId string = hostPool.id
