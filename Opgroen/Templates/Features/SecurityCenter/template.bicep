targetScope = 'subscription'

@description('Required. Specifies the ASC pricing tier for VMs')
@allowed([
  'Free'
  'Standard'
])
param pricingTierVMs string

@description('Required. Specifies the ASC pricing tier for PaaS SQL')
@allowed([
  'Free'
  'Standard'
])
param pricingTierSqlServers string

@description('Required. Specifies the ASC pricing tier for App Services')
@allowed([
  'Free'
  'Standard'
])
param pricingTierAppServices string

@description('Required. Specifies the ASC pricing tier for Storage Accounts')
@allowed([
  'Free'
  'Standard'
])
param pricingTierStorageAccounts string

@description('Required. Specifies the ASC pricing tier for Azure VMs')
@allowed([
  'Free'
  'Standard'
])
param pricingTierSqlServerVirtualMachines string

@description('Required. Specifies the ASC pricing tier for Containers')
@allowed([
  'Free'
  'Standard'
])
param pricingTierContainers string

@description('Required. Specifies the ASC pricing tier for Key Vaults')
@allowed([
  'Free'
  'Standard'
])
param pricingTierKeyVaults string

@description('Required. Specifies the ASC pricing tier for OpenSource Relational Databases')
@allowed([
  'Free'
  'Standard'
])
param pricingTierOpenSourceRelationalDatabases string

@description('Required. Specifies the ASC pricing tier for Azure Resource Manager')
@allowed([
  'Free'
  'Standard'
])
param pricingTierARM string

@description('Required. Specifies the ASC pricing tier for DNS')
@allowed([
  'Free'
  'Standard'
])
param pricingTierDNS string

@description('Required. Specifies the ASC pricing tier for CloudPosture')
@allowed([
  'Free'
  'Standard'
])
param pricingTierCloudPosture string

var subInfo = subscription()

resource VirtualMachines 'Microsoft.Security/pricings@2018-06-01' = {
  name: 'VirtualMachines'
  properties: {
    pricingTier: pricingTierVMs
  }
}

resource SqlServers 'Microsoft.Security/pricings@2018-06-01' = {
  name: 'SqlServers'
  dependsOn: [
    VirtualMachines
  ]
  properties: {
    pricingTier: pricingTierSqlServers
  }
}

resource AppServices 'Microsoft.Security/pricings@2018-06-01' = {
  name: 'AppServices'
  dependsOn: [
    SqlServers
  ]
  properties: {
    pricingTier: pricingTierAppServices
  }
}

resource StorageAccounts 'Microsoft.Security/pricings@2018-06-01' = {
  name: 'StorageAccounts'
  dependsOn: [
    AppServices
  ]
  properties: {
    pricingTier: pricingTierStorageAccounts
  }
}

resource SqlServerVirtualMachines 'Microsoft.Security/pricings@2018-06-01' = {
  name: 'SqlServerVirtualMachines'
  dependsOn: [
    StorageAccounts
  ]
  properties: {
    pricingTier: pricingTierSqlServerVirtualMachines
  }
}

resource Containers 'Microsoft.Security/pricings@2018-06-01' = {
  name: 'Containers'
  dependsOn: [
    SqlServerVirtualMachines
  ]
  properties: {
    pricingTier: pricingTierContainers
  }
}

resource KeyVaults 'Microsoft.Security/pricings@2018-06-01' = {
  name: 'KeyVaults'
  dependsOn: [
    Containers
  ]
  properties: {
    pricingTier: pricingTierKeyVaults
  }
}

resource OpenSourceRelationalDatabases 'Microsoft.Security/pricings@2018-06-01' = {
  name: 'OpenSourceRelationalDatabases'
  dependsOn: [
    KeyVaults
  ]
  properties: {
    pricingTier: pricingTierOpenSourceRelationalDatabases
  }
}

resource ARM 'Microsoft.Security/pricings@2018-06-01' = {
  name: 'ARM'
  dependsOn: [
    OpenSourceRelationalDatabases
  ]
  properties: {
    pricingTier: pricingTierARM
  }
}

resource DNS 'Microsoft.Security/pricings@2018-06-01' = {
  name: 'DNS'
  dependsOn: [
    ARM
  ]
  properties: {
    pricingTier: pricingTierDNS
  }
}

resource CloudPosture 'Microsoft.Security/pricings@2018-06-01' = {
  name: 'CloudPosture'
  dependsOn: [
    DNS
  ]
  properties: {
    pricingTier: pricingTierCloudPosture
  }
}

@description('Target Subscription')
output resourceName string = subInfo.displayName

@description('Target Subscription-id')
output resourceId string = subInfo.subscriptionId

@description('ID of virtualMachine')
output VirtualMachinesID string = VirtualMachines.id

@description('ID of SqlServers')
output SqlServers string = SqlServers.id

@description('ID of AppServices')
output AppServices string = AppServices.id

@description('ID of StorageAccounts')
output StorageAccounts string = StorageAccounts.id

@description('ID of SqlServerVirtualMachines')
output SqlServerVirtualMachines string = SqlServerVirtualMachines.id

@description('ID of Containers')
output Containers string = Containers.id

@description('ID of KeyVaults')
output KeyVaults string = KeyVaults.id

@description('ID of OpenSourceRelationalDatabases')
output OpenSourceRelationalDatabases string = OpenSourceRelationalDatabases.id

@description('ID of ARM')
output ARM string = ARM.id

@description('ID of DNS')
output DNS string = DNS.id

@description('ID of CloudPosture')
output CloudPosture string = CloudPosture.id
