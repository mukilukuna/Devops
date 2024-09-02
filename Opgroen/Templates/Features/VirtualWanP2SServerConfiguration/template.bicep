@description('Required. The workload name of the resource.')
param workloadName string

@description('Required. The application name of the resource.')
param applicationName string

@description('Required. The environment letter of the resource.')
@maxLength(1)
param environmentName string

@description('Required. The index of the resource.')
param index int

@description('Required. The region this resource will be deployed in.')
@maxLength(4)
param regionName string

@description('Optional. Custom name of the resource.')
param customName string = ''

@description('Optional. Tags to apply to the resource.')
param tags object = {}

@description('Optional. Location of the resource.')
param location string = resourceGroup().location

@description('Optional. VPN protocols for the VpnServerConfiguration.')
@allowed([
  'IkeV2'
  'OpenVPN'
])
param vpnProtocols array = [
  'IkeV2'
  'OpenVPN'
]

@description('Optional. VPN authentication types for the VpnServerConfiguration.')
@allowed([
  'AAD'
  'Certificate'
  'Radius'
])
param vpnAuthenticationTypes array = [
  'AAD'
]

@description('Required. IPSec Policies Configuration for the VPN.')
param vpnClient object

@description('Optional. AAD Based authentication P2S VPN setup.')
param aadAuthenticationParameters object = {}

@description('Optional. Certificate Based authentication P2S VPN setup.')
param certificateAuthenticationParameters object = {}

@description('Optional. Radius Based authentication P2S VPN setup.')
param radiusAuthenticationParameters object = {}

@description('Optional. Reference to the KeyVault Entry with the Radius secret.')
@secure()
param radiusServerSecret string = ''

var nameVar = empty(customName) ? toLower('p2scfg-${workloadName}-${applicationName}${environmentName}-${regionName}-${padLeft(index, 2, '0')}') : customName

resource p2sServerconfigurationName 'Microsoft.Network/vpnServerConfigurations@2021-12-01' = {
  name: nameVar
  tags: tags
  location: location
  properties: {
    vpnProtocols: vpnProtocols
    vpnAuthenticationTypes: vpnAuthenticationTypes
    vpnClientIpsecPolicies: vpnClient.IpsecPolicies

    aadAuthenticationParameters: {
      aadTenant: contains(aadAuthenticationParameters, 'aadTenant') && !empty(aadAuthenticationParameters.aadTenant) ? aadAuthenticationParameters.aadTenant : null
      aadIssuer: contains(aadAuthenticationParameters, 'aadIssuer') && !empty(aadAuthenticationParameters.aadIssuer) ? aadAuthenticationParameters.aadIssuer : null
      aadAudience: empty(aadAuthenticationParameters) ? null : '41b23e61-6c1e-4545-b367-cd054e0ed4b4'
    }
    vpnClientRootCertificates: contains(certificateAuthenticationParameters, 'vpnClientRootCertificates') && !empty(certificateAuthenticationParameters.vpnClientRootCertificates) ? certificateAuthenticationParameters.vpnClientRootCertificates : null
    vpnClientRevokedCertificates: contains(certificateAuthenticationParameters, 'vpnClientRevokedCertificates') && !empty(certificateAuthenticationParameters.vpnClientRevokedCertificates) ? certificateAuthenticationParameters.vpnClientRevokedCertificates : null

    radiusClientRootCertificates: contains(radiusAuthenticationParameters, 'radiusClientRootCertificates') && !empty(radiusAuthenticationParameters.radiusClientRootCertificates) ? radiusAuthenticationParameters.radiusClientRootCertificates : null
    radiusServerAddress: contains(radiusAuthenticationParameters, 'radiusServerAddress') && !empty(radiusAuthenticationParameters.radiusServerAddress) ? radiusAuthenticationParameters.radiusServerAddress : null
    radiusServerRootCertificates: contains(radiusAuthenticationParameters, 'radiusServerRootCertificates') && !empty(radiusAuthenticationParameters.radiusServerRootCertificates) ? radiusAuthenticationParameters.radiusServerRootCertificates : null
    radiusServers: contains(radiusAuthenticationParameters, 'radiusServers') && !empty(radiusAuthenticationParameters.radiusServers) ? radiusAuthenticationParameters.radiusServers : null
    radiusServerSecret: empty(radiusAuthenticationParameters) ? null : radiusServerSecret
  }
}

@description('The resource-ID of the Azure resource')
output resourceID string = p2sServerconfigurationName.id
@description('The name of the Azure resource')
output resourceName string = p2sServerconfigurationName.name
