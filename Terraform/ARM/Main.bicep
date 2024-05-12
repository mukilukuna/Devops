@description('Specifies the location for resources.')
param location string = 'westeurope'
param adminUsername string = 'adminiML'
param klantnaam string = 'LOI'

// virtual machine template
resource VMTemp 'Microsoft.Compute/virtualMachines@2022-03-01' = {
  name: klantnaam
  location: location
  properties: {
    storageProfile: {
      #disable-next-line BCP036
      osDisk: {
        osType: 'Windows'
        #disable-next-line BCP036
        diskSizeGB: '200GB'
        createOption: 'Attach'
      }
    }
    osProfile: {
      adminPassword: 'BitchesAintShn!t'
      #disable-next-line adminusername-should-not-be-literal
      adminUsername: adminUsername
    }
  }
}
