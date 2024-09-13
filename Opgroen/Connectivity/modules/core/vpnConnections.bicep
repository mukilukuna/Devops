targetScope = 'resourceGroup'

@description('Optional. Time parameter to create unique deployment. Do not set in parameter file!')
param time string = replace(utcNow(), ':', '-')

@description('JSON configuration object for bicep deployments')
var subscriptionConfig = loadJsonContent('../../configs/subscriptionConfig.jsonc')

@description('Location of the resource group')
var location = subscriptionConfig.Governance.location

module VPNConnection '../../../Templates/Features/VPNConnection/template.bicep' = {
  name: 'VPNConnection-${time}'
  dependsOn: []
  params: {
    workloadName: subscriptionConfig.namingConvention.workloadName
    applicationName: 'customervpn'
    environmentName: subscriptionConfig.namingConvention.environmentName
    regionName: subscriptionConfig.namingConvention.regionName
    index: 1
    location: location
    virtualNetworkGatewayName: '*<connWeu-virtualNetworkGateway_ResourceName>*'
    localGatewayIpAddress: '10.10.10.10'
    sharedKey: '*<VPN-PSK>*'
    ikeEncryption: 'AES256'
    ikeIntegrity: 'SHA256'
    ipsecEncryption: 'AES256'
    ipsecIntegrity: 'SHA256'
    localGatewayBGPSettings: {}
    localGatewayaddressPrefixes: [
      '172.21.0.0/16'
    ]
    connectionType: 'IPsec'
    usePolicyBasedTrafficSelectors: false
    dhGroup: 'ECP384'
    pfsGroup: 'ECP384'
    saLifeTimeSeconds: 3600
    saDataSizeKilobytes: 102400000
    tags: subscriptionConfig.Governance.tags
  }
}
