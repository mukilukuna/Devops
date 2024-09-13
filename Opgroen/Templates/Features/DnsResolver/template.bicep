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

@description('Required. Name of the inbound endpoints')
param inboundEndpointsName string

@description('Required. Name of the outbound endpoints')
param outboundEndpointName string

@description('Required. Name of the subnet for the inbound endpoints')
param inboundEndpointSubnetName string

@description('Required. Name of the subnet for the outbound endpoints')
param outboundEndpointSubnetName string

var dnsResolver_namevar = empty(customName) ? toLower('pdnsr-${workloadName}-${applicationName}-${environmentName}-${regionName}-${padLeft(index, 2, '0')}') : customName
var inboundEndpointsSubnetResourceId = '${vNetId}/subnets/${inboundEndpointSubnetName}'
var outboundEndpointsSubnetResourceId = '${vNetId}/subnets/${outboundEndpointSubnetName}'

resource dnsResolver 'Microsoft.Network/dnsResolvers@2020-04-01-preview' = {
  name: dnsResolver_namevar
  location: location
  tags: tags
  properties: {
    virtualNetwork: {
      id: vNetId
    }
  }
}

resource inboundEndpoints 'Microsoft.Network/dnsResolvers/inboundEndpoints@2020-04-01-preview' = {
  parent: dnsResolver
  name: inboundEndpointsName
  location: location
  properties: {
    ipConfigurations: [
      {
        subnet: {
          #disable-next-line use-resource-id-functions
          id: inboundEndpointsSubnetResourceId
        }
      }
    ]
  }
}

resource outboundEndpoints 'Microsoft.Network/dnsResolvers/outboundEndpoints@2020-04-01-preview' = {
  parent: dnsResolver
  name: outboundEndpointName
  location: location
  properties: {
    subnet: {
      #disable-next-line use-resource-id-functions
      id: outboundEndpointsSubnetResourceId
    }
  }
}

@description('The name of the Azure resource')
output resourceName string = dnsResolver.name

@description('The resourceId of the Azure resource')
output resourceID string = dnsResolver.id

@description('The resourceId of the Azure resource')
output outboundEndpointsID string = outboundEndpoints.id
