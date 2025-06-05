targetScope = 'resourceGroup'

param location string = resourceGroup().location
param keyVaultName string = 'avd-kv'
param enablePurgeProtection bool = true

@secure()
param patToken string
param vnetName string = 'avd-vnet'
param avdHostPoolName string = 'avd-hostpool'
param scalingPlanName string = 'avd-scaling'
param entraAppName string = 'avd-app'
param vmAdminUsername string = 'avdadmin'

@secure()
param vmAdminPassword string

module network './Modules/network.bicep' = {
  name: 'network'
  params: {
    location: location
    vnetName: vnetName
  }
}

module hostPool './Modules/hostpool.bicep' = {
  name: 'hostPool'
  params: {
    avdHostPoolName: avdHostPoolName
    location: location
  }
}

module scaling './Modules/scaling.bicep' = {
  name: 'scaling'
  params: {
    scalingPlanName: scalingPlanName
    hostPoolName: avdHostPoolName
    location: location
  }
}

module kv 'br/public:avm/res/key-vault/vault:0.11.0' = {
  name: 'keyvault'
  params: {
    name: keyVaultName
    enablePurgeProtection: enablePurgeProtection
    location: location
    secrets: [
      {
        name: 'patToken'
        value: patToken
      }
    ]
  }
}

module entra './Modules/entra-id.bicep' = {
  name: 'entra'
  params: {
    entraAppName: entraAppName
  }
}

module policy './Modules/policies.bicep' = {
  name: 'policies'
  scope: subscription()
}

module session './Modules/sessionhosts.bicep' = {
  name: 'sessionhosts'
  params: {
    vmAdminUsername: vmAdminUsername
    vmAdminPassword: vmAdminPassword
    subnetId: network.outputs.subnetId
    hostPoolName: avdHostPoolName
    location: location
  }
}

output networkId string = network.outputs.vnetId
output hostPoolId string = hostPool.outputs.hostPoolId
output scalingPlanId string = scaling.outputs.scalingPlanId
output keyVaultId string = kv.outputs.resourceId
output entraAppId string = entra.outputs.appId
output sessionHostVmId string = session.outputs.vmId
