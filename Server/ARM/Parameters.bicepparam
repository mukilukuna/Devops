using './template.bicep' /*TODO: Provide a path to a bicep template*/

param location = 'westeurope'

param networkInterfaceName = 'loiazudc172'

param enableAcceleratedNetworking = true

param networkSecurityGroupName = 'LOIAZUDC-nsg'

param networkSecurityGroupRules = [
  {
    name: 'RDP'
    properties: {
      priority: 300
      protocol: 'TCP'
      access: 'Allow'
      direction: 'Inbound'
      sourceAddressPrefix: '*'
      sourcePortRange: '*'
      destinationAddressPrefix: '*'
      destinationPortRange: '3389'
    }
  }
]

param subnetName = 'default'

param virtualNetworkName = 'LOI-vnet'

param addressPrefixes = [ '10.0.0.0/16' ]

param subnets = [
  {
    name: 'default'
    properties: {
      addressPrefix: '10.0.0.0/24'
    }
  }
]

param publicIpAddressName = 'LOIAZUDC-ip'

param publicIpAddressType = 'Dynamic'

param publicIpAddressSku = 'Basic'

param pipDeleteOption = 'Delete'

param virtualMachineName = 'LOIAZUDC'

param virtualMachineComputerName = 'LOIAZUDC'

param virtualMachineRG = 'LOI'

param osDiskType = 'Premium_LRS'

param osDiskDeleteOption = 'Delete'

param virtualMachineSize = 'Standard_D4as_v5'

param nicDeleteOption = 'Delete'

param adminUsername = 'Admini'

param adminPassword = 'fIt4acrAt@ociphUzAdl'

param patchMode = 'Manual'

param enableHotpatching = false

param diagnosticsStorageAccountName = 'loiazustor'

param diagnosticsStorageAccountId = 'Microsoft.Storage/storageAccounts/loiazustor'

param diagnosticsStorageAccountType = 'Standard_LRS'

param diagnosticsStorageAccountKind = 'Storage'

param autoShutdownStatus = 'Enabled'

param autoShutdownTime = '16:00'

param autoShutdownTimeZone = 'W. Europe Standard Time'

param autoShutdownNotificationStatus = 'Disabled'

param autoShutdownNotificationLocale = 'nl'
