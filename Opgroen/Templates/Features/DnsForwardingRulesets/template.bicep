@description('Required. The name of the application')
param applicationName string

@description('Required. The code of the environment this resource will be used in')
@maxLength(1)
param environmentName string

@description('Required. The name of the workload this resource will be used for')
param workloadName string

@description('Required. region of the resource')
@maxLength(4)
param regionName string

@description('Required. Index of the resource')
param index int

@description('Optional. The name to use if not using the normal naming convention')
param customName string = ''

@description('Optional. Location of the resource')
param location string = resourceGroup().location

@description('Optional. Resource tags')
param tags object = {}

@description('Required. Virtual Network ResourceId')
param vNetId string

@description('Required. Array with forwardrules containing, name, targetDnsservers with port and rule state of the domain')
param forwardingRules array

@description('Required. ResourceId of the outbound endpoint')
param outboundEndpointResourceId string

var dnsForwardingRulesets_namevar = empty(customName) ? toLower('pdnsfr-${workloadName}-${applicationName}-${environmentName}-${regionName}-${padLeft(index, 2, '0')}') : customName
var virtualNetworkName = last(split(vNetId, '/'))
var virtualNetworkLinkName = '${virtualNetworkName}-link'

resource dnsForwardingRulesets 'Microsoft.Network/dnsForwardingRulesets@2020-04-01-preview' = {
  name: dnsForwardingRulesets_namevar
  location: location
  tags: tags
  properties: {
    dnsResolverOutboundEndpoints: [
      {
        id: outboundEndpointResourceId
      }
    ]
  }
}

resource dnsForwardingRulesetsVirtualNetworkLinks 'Microsoft.Network/dnsForwardingRulesets/virtualNetworkLinks@2020-04-01-preview' = {
  parent: dnsForwardingRulesets
  name: virtualNetworkLinkName
  properties: {
    virtualNetwork: {
      id: vNetId
    }
  }

}

resource dnsForwardingRulesetsForwardingRules 'Microsoft.Network/dnsForwardingRulesets/forwardingRules@2020-04-01-preview' = [for forwardingRules in forwardingRules: {
  parent: dnsForwardingRulesets
  name: forwardingRules.ruleName
  properties: {
    domainName: forwardingRules.domainName
    targetDnsServers: forwardingRules.targetDnsServers
    forwardingRuleState: forwardingRules.forwardingRuleState
  }
}]

@description('The name of the Azure resource')
output resourceName string = dnsForwardingRulesets.name

@description('The resource-id of the Azure resource')
output resourceID string = dnsForwardingRulesets.id
