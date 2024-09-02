targetScope = 'resourceGroup'

@description('Optional. Time parameter to create unique deployment. Do not set in parameter file!')
param time string = replace(utcNow(), ':', '-')

@description('JSON configuration object for bicep deployments')
var subscriptionConfig = loadJsonContent('../../configs/subscriptionConfig.jsonc')
var namingConvention = subscriptionConfig.namingConvention
var tags = subscriptionConfig.Governance.tags

@description('Location of the resource group')
var location = subscriptionConfig.Governance.location

var resourceTagsNPM01 = {
  InSpark_VirtualMachineUpdateGroup: 'infr-weu-group1-0600-ThirdSunday'
  InSpark_VirtualMachineRole: 'NPM'
}

var resourceTagsNPM02 = {
  InSpark_VirtualMachineUpdateGroup: 'infr-weu-group2-0600-FourthSunday'
  InSpark_VirtualMachineRole: 'NPM'
}

module resourceGroupConnectivityLock '../../../Templates/Features/ResourceGroupLock/template.bicep' = {
  name: 'resourceGroupConnectivityLock-${time}'
  params: {
    level: 'CanNotDelete'
  }
}

resource keyVault 'Microsoft.KeyVault/vaults@2019-09-01' existing = {
  name: '*<mgmtWeu-keyvault_ResourceName>*'
  scope: resourceGroup('*<mgmtWeu-securityRG_ResourceName>*')
}

module availabilitySet '../../../Templates/Features/AvailabilitySet/template.bicep' = {
  name: 'avset-${time}'
  params: {
    workloadName: 'inf'
    applicationName: 'mon'
    environmentName: namingConvention.environmentName
    regionName: namingConvention.regionName
    roleName: 'np'
    index: 1
    location: location
    tags: tags
  }
}

module virtualMachineNpm01 '../../../Templates/Features/VirtualMachine/template.bicep' = {
  name: 'Npm01-${time}'
  params: {
    workloadName: 'inf'
    applicationName: 'mon'
    environmentName: namingConvention.environmentName
    regionName: namingConvention.regionName
    roleName: 'np'
    location: location
    index: 1
    virtualMachineSize: 'Standard_B2s'
    vNetId: '*<mgmtWeu-virtualNetwork_ResourceId>*'
    deployAvailabilitySet: false
    existingAvailabilitySet: true
    existingAvailabilitySetId: availabilitySet.outputs.resourceID
    bootDiagnostics: true
    networkWatcher: true
    dependencyAgent: true
    backupVaultResourceId: '*<mgmtWeu-recoveryServicesVault_ResourceId>*'
    backupPolicyName: '*<mgmtWeu-defaultBackupPolicyVMEnhanced_ResourceName>*'
    logAnalyticsWorkspaceId: ''
    osDiskStorageType: 'Premium_LRS'
    encryptionAtHost: true
    securityType: 'TrustedLaunch'
    vTpmEnabled: true
    secureBootEnabled: true
    bootIntegrityMonitoringEnabled: true
    networkConfig: [
      {
        subnetName: 'NpmSubnet'
        numberOfIPs: 1
        privateIPType: 'Static'
        applicationSecurityGroups: [
          {
            id: '*<mgmtWeu-applicationSecurityGroupNpm_ResourceId>*'
          }
        ]
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
    tags: union(tags, resourceTagsNPM01)
  }
}

module virtualMachineNpm02 '../../../Templates/Features/VirtualMachine/template.bicep' = {
  name: 'Npm02-${time}'
  params: {
    workloadName: 'inf'
    applicationName: 'mon'
    environmentName: namingConvention.environmentName
    regionName: namingConvention.regionName
    roleName: 'np'
    location: location
    index: 2
    virtualMachineSize: 'Standard_B2s'
    vNetId: '*<mgmtWeu-virtualNetwork_ResourceId>*'
    deployAvailabilitySet: false
    existingAvailabilitySet: true
    existingAvailabilitySetId: availabilitySet.outputs.resourceID
    bootDiagnostics: true
    networkWatcher: true
    dependencyAgent: true
    backupVaultResourceId: '*<mgmtWeu-recoveryServicesVault_ResourceId>*'
    backupPolicyName: '*<mgmtWeu-defaultBackupPolicyVMEnhanced_ResourceName>*'
    logAnalyticsWorkspaceId: ''
    osDiskStorageType: 'Premium_LRS'
    encryptionAtHost: true
    securityType: 'TrustedLaunch'
    vTpmEnabled: true
    secureBootEnabled: true
    bootIntegrityMonitoringEnabled: true
    networkConfig: [
      {
        subnetName: 'NpmSubnet'
        numberOfIPs: 1
        privateIPType: 'Static'
        applicationSecurityGroups: [
          {
            id: '*<mgmtWeu-applicationSecurityGroupNpm_ResourceId>*'
          }
        ]
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
    tags: union(tags, resourceTagsNPM02)
  }
}

@description('ID of the resource')
output virtualMachineNpm01_ResourceId string = virtualMachineNpm01.outputs.resourceID
@description('Name of the resource')
output virtualMachineNpm01_ResourceName string = virtualMachineNpm01.outputs.resourceName
@description('Name of the resource')
output virtualMachineNpm01_PrivateIp string = virtualMachineNpm01.outputs.privateIP

@description('ID of the resource')
output virtualMachineNpm02_ResourceId string = virtualMachineNpm02.outputs.resourceID
@description('Name of the resource')
output virtualMachineNpm02_ResourceName string = virtualMachineNpm02.outputs.resourceName
@description('Name of the resource')
output virtualMachineNpm02_PrivateIp string = virtualMachineNpm02.outputs.privateIP
