param name string = 'rg-liteuezusto'
param location string = 'westeurope'
targetScope = 'subscription'

resource resourcegroup 'Microsoft.Resources/resourceGroups@2024-03-01' = {
  name: name
  location: location

}


