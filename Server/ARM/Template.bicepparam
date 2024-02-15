using './template.bicep'

param location = ''
param networkInterfaceName = ''
param enableAcceleratedNetworking = false
param networkSecurityGroupName = ''
param networkSecurityGroupRules = []
param subnetName = ''
param virtualNetworkName = ''
param addressPrefixes = []
param subnets = []
param publicIpAddressName = ''
param publicIpAddressType = ''
param publicIpAddressSku = ''
param pipDeleteOption = ''
param virtualMachineName = ''
param virtualMachineComputerName = ''
param virtualMachineRG = ''
param osDiskType = ''
param osDiskDeleteOption = ''
param virtualMachineSize = ''
param nicDeleteOption = ''
param adminUsername = ''
param adminPassword = ''
param patchMode = ''
param enableHotpatching = false
param diagnosticsStorageAccountName = ''
param diagnosticsStorageAccountId = ''
param diagnosticsStorageAccountType = ''
param diagnosticsStorageAccountKind = ''
param autoShutdownStatus = ''
param autoShutdownTime = ''
param autoShutdownTimeZone = ''
param autoShutdownNotificationStatus = ''
param autoShutdownNotificationLocale = ''

