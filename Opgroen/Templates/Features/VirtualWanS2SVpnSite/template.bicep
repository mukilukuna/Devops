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

@description('Optional. Tags to apply to the resource')
param tags object = {}

@description('Optional. Location of the resource')
param location string = resourceGroup().location

@description('Required. Resource ID of the Virtual Wan')
param virtualWanResourceId string

@description('Optional. Name of the device Vendor')
param deviceVendor string = ''

@description('Optional. Link speed.')
param linkSpeedInMbps int = 0

@description('Required. A list of address blocks reserved for this (virtual) network in CIDR notation')
param addressPrefixes array

@description('Required. List of all vpn site links')
param vpnSiteLinks array

@description('Optional. Object containing the Office 365 breakout configuration')
param o365Policy object = {
  optimize: false
  allow: false
  default: false
}

var nameVar = empty(customName) ? toLower('s2svpnsite-${workloadName}-${applicationName}-${environmentName}-${regionName}-${padLeft(index, 2, '0')}') : customName

resource s2sVpnSite 'Microsoft.Network/vpnSites@2021-12-01' = {
  name: nameVar
  location: location
  tags: tags
  properties: {
    addressSpace: {
      addressPrefixes: addressPrefixes
    }
    deviceProperties: {
      deviceVendor: deviceVendor
      linkSpeedInMbps: linkSpeedInMbps
    }
    virtualWan: {
      id: virtualWanResourceId
    }
    vpnSiteLinks: vpnSiteLinks
    o365Policy: {
      breakOutCategories: {
        allow: o365Policy.allow
        optimize: o365Policy.optimize
        default: o365Policy.default
      }
    }
  }
}

@description('ID of the resource')
output resourceID string = s2sVpnSite.id
@description('Name of the resource')
output resourceName string = s2sVpnSite.name
