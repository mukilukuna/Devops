using './template.bicep' /*TODO: Provide a path to a bicep template*/

param location = 'westeurope'

param networkInterfaceName = 'lukunavm582'

param enableAcceleratedNetworking = true

param networkSecurityGroupName = 'LukunaVM-nsg'

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

param subnetName = 'SnetLukunaBV'

param virtualNetworkId = '/subscriptions/c0b52ba4-df61-49cf-ab65-315eb1152086/resourceGroups/ResourceGroupBeroepsProduct/providers/Microsoft.Network/virtualNetworks/VnetLukunaBV'

param publicIpAddressName = 'LukunaVM-ip'

param publicIpAddressType = 'Static'

param publicIpAddressSku = 'Standard'

param pipDeleteOption = 'Delete'

param virtualMachineName = 'LukunaVM'

param virtualMachineComputerName = 'LukunaVM'

param virtualMachineRG = 'ResourceGroupBeroepsProduct'

param osDiskType = 'Premium_LRS'

param osDiskDeleteOption = 'Delete'

param virtualMachineSize = 'Standard_D2s_v3'

param nicDeleteOption = 'Delete'

param hibernationEnabled = false

param adminUsername = 'admini'

param adminPassword = 'Uxwt7X6E_92@ZE-'

param patchMode = 'AutomaticByPlatform'

param enableHotpatching = false

param rebootSetting = 'IfRequired'
