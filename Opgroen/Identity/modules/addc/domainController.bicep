targetScope = 'resourceGroup'

@description('Optional. Time parameter to create unique deployment. Do not set in parameter file!')
param time string = replace(utcNow(), ':', '-')

@description('JSON configuration object for bicep deployments')
var subscriptionConfig = loadJsonContent('../../configs/subscriptionConfig.jsonc')
var namingConvention = subscriptionConfig.namingConvention
var tags = subscriptionConfig.Governance.tags

@description('Location of the resource group')
var location = subscriptionConfig.Governance.location

var resourceTagsADDC01 = {
  InSpark_VirtualMachineUpdateGroup: 'infr-weu-group1-0600-ThirdSunday'
  InSpark_VirtualMachineRole: 'DC'
}

var resourceTagsADDC02 = {
  InSpark_VirtualMachineUpdateGroup: 'infr-weu-group2-0600-FourthSunday'
  InSpark_VirtualMachineRole: 'DC'
}

module resourceGroupConnectivityLock '../../../Templates/Features/ResourceGroupLock/template.bicep' = {
  name: 'resourceGroupConnectivityLock-${time}'
  params: {
    level: 'CanNotDelete'
  }
}

resource keyVault 'Microsoft.KeyVault/vaults@2019-09-01' existing = {
  name: '*<idenWeu-keyvault_ResourceName>*'
  scope: resourceGroup('*<idenWeu-securityRG_ResourceName>*')
}

module availabilitySet '../../../Templates/Features/AvailabilitySet/template.bicep' = {
  name: 'avset-${time}'
  params: {
    workloadName: 'inf'
    applicationName: 'ad'
    environmentName: namingConvention.environmentName
    regionName: namingConvention.regionName
    roleName: 'dc'
    index: 1
    location: location
    tags: tags
  }
}

module virtualMachineADDC01 '../../../Templates/Features/VirtualMachine/template.bicep' = {
  name: 'ADDC01-${time}'
  params: {
    workloadName: 'inf'
    applicationName: 'ad'
    environmentName: namingConvention.environmentName
    regionName: namingConvention.regionName
    roleName: 'dc'
    location: location
    index: 1
    virtualMachineSize: 'Standard_D2ds_v5'
    vNetId: '*<idenWeu-virtualNetwork_ResourceId>*'
    deployAvailabilitySet: false
    existingAvailabilitySet: true
    existingAvailabilitySetId: availabilitySet.outputs.resourceID
    bootDiagnostics: true
    networkWatcher: true
    dependencyAgent: true
    backupVaultResourceId: '*<idenWeu-recoveryServicesVault_ResourceId>*'
    backupPolicyName: '*<idenWeu-defaultBackupPolicyVMEnhanced_ResourceName>*'
    logAnalyticsWorkspaceId: ''
    osDiskStorageType: 'Premium_LRS'
    encryptionAtHost: true
    securityType: 'TrustedLaunch'
    vTpmEnabled: true
    secureBootEnabled: true
    bootIntegrityMonitoringEnabled: true
    networkConfig: [
      {
        subnetName: 'IdentitySubnet'
        numberOfIPs: 1
        privateIPType: 'Static'
        //        dnsServers: [       Add on-prem DNS server to allow for domain join and promotion. Update list based on customer config.
        //          '172.20.4.200'
        //          '172.20.4.201'
        //        ]
        applicationSecurityGroups: [
          {
            id: '*<idenWeu-applicationSecurityGroupAddc_ResourceId>*'
          }
        ]
      }
    ]
    dataDisks: [
      {
        storageType: 'Premium_LRS'
        createOption: 'Empty'
        diskSizeGB: 16
        caching: 'None'
        writeAccelerator: false
        networkAccessPolicy: 'AllowAll'
        publicNetworkAccess: 'Enabled'
      }
    ]
    image: {
      publisher: 'MicrosoftWindowsServer'
      offer: 'WindowsServer'
      sku: '2022-datacenter-g2'
      version: 'latest'
      licenseType: 'None'
      osType: 'Windows'
    }
    adminUsername: keyVault.getSecret('vmadmin')
    adminPassword: keyVault.getSecret('vmpassword')
    tags: union(tags, resourceTagsADDC01)
  }
}

module virtualMachineADDC02 '../../../Templates/Features/VirtualMachine/template.bicep' = {
  name: 'ADDC02-${time}'
  params: {
    workloadName: 'inf'
    applicationName: 'ad'
    environmentName: namingConvention.environmentName
    regionName: namingConvention.regionName
    roleName: 'dc'
    location: location
    index: 2
    virtualMachineSize: 'Standard_D2ds_v5'
    vNetId: '*<idenWeu-virtualNetwork_ResourceId>*'
    deployAvailabilitySet: false
    existingAvailabilitySet: true
    existingAvailabilitySetId: availabilitySet.outputs.resourceID
    bootDiagnostics: true
    networkWatcher: true
    dependencyAgent: true
    backupVaultResourceId: '*<idenWeu-recoveryServicesVault_ResourceId>*'
    backupPolicyName: '*<idenWeu-defaultBackupPolicyVMEnhanced_ResourceName>*'
    logAnalyticsWorkspaceId: ''
    osDiskStorageType: 'Premium_LRS'
    encryptionAtHost: true
    securityType: 'TrustedLaunch'
    vTpmEnabled: true
    secureBootEnabled: true
    bootIntegrityMonitoringEnabled: true
    networkConfig: [
      {
        subnetName: 'IdentitySubnet'
        numberOfIPs: 1
        privateIPType: 'Static'
        //        dnsServers: [       Add on-prem DNS server to allow for domain join and promotion. Update list based on customer config.
        //          '172.20.4.200'
        //          '172.20.4.201'
        //        ]
        applicationSecurityGroups: [
          {
            id: '*<idenWeu-applicationSecurityGroupAddc_ResourceId>*'
          }
        ]
      }
    ]
    dataDisks: [
      {
        storageType: 'Premium_LRS'
        createOption: 'Empty'
        diskSizeGB: 16
        caching: 'None'
        writeAccelerator: false
        networkAccessPolicy: 'AllowAll'
        publicNetworkAccess: 'Enabled'
      }
    ]
    image: {
      publisher: 'MicrosoftWindowsServer'
      offer: 'WindowsServer'
      sku: '2022-datacenter-g2'
      version: 'latest'
      licenseType: 'None'
      osType: 'Windows'
    }
    adminUsername: keyVault.getSecret('vmadmin')
    adminPassword: keyVault.getSecret('vmpassword')
    tags: union(tags, resourceTagsADDC02)
  }
}

@description('ID of the resource')
output virtualMachineADDC01_ResourceId string = virtualMachineADDC01.outputs.resourceID
@description('Name of the resource')
output virtualMachineADDC01_ResourceName string = virtualMachineADDC01.outputs.resourceName
@description('PrivateIP of the resource')
output virtualMachineAddc01_PrivateIp string = virtualMachineADDC01.outputs.privateIP

@description('ID of the resource')
output virtualMachineADDC02_ResourceId string = virtualMachineADDC02.outputs.resourceID
@description('Name of the resource')
output virtualMachineADDC02_ResourceName string = virtualMachineADDC02.outputs.resourceName
@description('PrivateIP of the resource')
output virtualMachineAddc02_PrivateIp string = virtualMachineADDC02.outputs.privateIP
