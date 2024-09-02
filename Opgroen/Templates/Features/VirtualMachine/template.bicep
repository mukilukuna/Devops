@description('Required. The application name of the resource.')
@maxLength(5)
param applicationName string

@description('Required. The workload name of the resource.')
@maxLength(3)
param workloadName string

@description('Required. The region this resource will be deployed in.')
@maxLength(4)
param regionName string

@description('Required. Role of the VM.')
@maxLength(2)
param roleName string

@description('Required. The environment letter of the resource.')
@maxLength(1)
param environmentName string

@description('Required. Index of the VM.')
param index int

@description('Optional. The name to use if not using the normal naming convention.')
param customName string = ''

@description('Required. Virtual network ID.')
param vNetId string

@description('Required. The network config.')
param networkConfig array

@description('Optional. Disks to add to the VM.')
param dataDisks array = []

@description('Optional. Enable the deployment of an availability set.')
param deployAvailabilitySet bool = false

@description('Optional. Name of the availability set.')
param customAvailabilitySetName string = ''

@description('Optional. Join the VM to an existing availability set, requires the use of customAvailabilitySetName')
param existingAvailabilitySet bool = false

@description('Optional. Used in conjuction with existingAvailabilitySet set to true. ID of the availability set.')
param existingAvailabilitySetId string = ''

@description('Optional. Amount of zones to deploy in.')
param maxZones int = 3

@description('Optional. Deploy an managed identity.')
param enableManagedIdentity bool = true

@description('Optional. Azure MarketPlace Offer.')
param azureMarketPlaceOffer object = {}

@description('Required. Size of the virtual machine.')
param virtualMachineSize string

@description('Required. Which image to deploy.')
param image object

param noInfrastructureRedundancy bool = false

@description('Optional. OS disk type.')
@allowed([
  'Premium_LRS'
  'Premium_ZRS'
  'StandardSSD_LRS'
  'StandardSSD_ZRS'
  'Standard_LRS'
  'UltraSSD_LRS'
])
param osDiskStorageType string = 'Premium_LRS'

@description('Optional. OS disk caching')
@allowed([
  'None'
  'ReadOnly'
  'ReadWrite'
])
param osDiskCaching string = 'ReadWrite'

@description('Required. Username')
@secure()
param adminUsername string

@description('Required. Password')
@secure()
param adminPassword string

@description('Optional. customData')
param customData string = ''

@description('Optional. Enable boot diagnostics')
param bootDiagnostics bool = true

@description('Optional. Enable network watcher extension')
param networkWatcher bool = false

@description('Optional. Enable dependency agent extension')
param dependencyAgent bool = true

@description('Optional. Resource ID of the back-up vault')
param backupVaultResourceId string = ''

@description('Optional. Name of the back-up vault policy')
param backupPolicyName string = ''

@description('Optional. ID of the encryption key vault')
param encryptionKeyVaultResourceId string = ''

@description('Optional. Sequence ID of the encryption')
param encryptionSequenceId string = newGuid()

@description('Optional. volumes to encrypt')
@allowed([
  'All'
  'OS'
  'Data'
])
param encryptionVolume string = 'All'

@description('Optional. Enable key encryption key')
param enableKeyEncryptionKey bool = false

@description('Optional. URL of the key encryption key')
param KeyEncryptionKeyUrl string = ''

@description('Optional. Tags to add to all resources')
param tags object = {}

@description('Optional. Log analytics workspace ID')
param logAnalyticsWorkspaceId string = ''

@description('Optional. Enable encryptionAtHost')
param encryptionAtHost bool = false

@description('Optional. Enable securityType')
@allowed([
  'None'
  'TrustedLaunch'
  'ConfidentialVM'
])
param securityType string = 'None'

@description('Optional. Enable secureBootEnabled')
param secureBootEnabled bool = false

@description('Optional. Enable vTpmEnabled')
param vTpmEnabled bool = false

@description('Optional. Enable Boot Integrity Monitoring')
param bootIntegrityMonitoringEnabled bool = false

@description('Optional. Object describing the domain to join')
param domainJoin object = {}

@description('Optional. The name of the domain join account')
param domainJoinUsername string = ''

@description('Optional. The name of the domain join account password')
@secure()
param domainJoinPassword string = ''

@description('Optional. Location of the resources')
param timeZone string = 'W. Europe Standard Time'

@description('Optional. Location of the resources')
param location string = resourceGroup().location

@description('Optional. Array of Role Assignments to deploy')
param permissions array = []

var availabilitySetId = existingAvailabilitySet
  ? existingAvailabilitySetId
  : deployAvailabilitySet ? availabilitySet.id : null
var availabilitySetName = empty(customAvailabilitySetName)
  ? toLower('avail-${workloadName}-${applicationName}-${environmentName}-${regionName}-${padLeft(index, 2, '0')}')
  : customAvailabilitySetName
var vmName = empty(customName)
  ? toLower('vm${workloadName}${applicationName}${roleName}${environmentName}${padLeft(index, 2, '0')}')
  : customName
var backupVaultResourceIdVar = empty(backupVaultResourceId) ? resourceGroup().id : backupVaultResourceId

var securityProfile = {
  encryptionAtHost: encryptionAtHost
  securityType: securityType
  uefiSettings: {
    secureBootEnabled: secureBootEnabled
    vTpmEnabled: vTpmEnabled
  }
}
var securityProfileEncryptionAtHostOnly = {
  encryptionAtHost: encryptionAtHost
}

var imageReference = {
  publisher: image.publisher
  offer: image.offer
  sku: image.sku
  version: image.version
}
var dataDiskConfig = [
  for (item, index) in dataDisks: {
    lun: index + 1
    name: 'disk-${padLeft(index + 1, 2, '0')}-${vmName}'
    createOption: 'Attach'
    caching: item.caching ?? null
    writeAcceleratorEnabled: item.writeAccelerator ?? null
    managedDisk: {
      id: resourceId('Microsoft.Compute/disks', 'disk-${padLeft(index + 1, 2, '0')}-${vmName}')
    }
  }
]

resource availabilitySet 'Microsoft.Compute/availabilitySets@2021-07-01' =
  if (deployAvailabilitySet) {
    name: availabilitySetName
    location: location
    sku: {
      name: 'Aligned'
    }
    properties: {
      platformFaultDomainCount: 3
      platformUpdateDomainCount: 3
    }
    tags: tags
  }

resource publicIPAddresses 'Microsoft.Network/publicIPAddresses@2023-05-01' = [
  for (item, i) in networkConfig: if (contains(item, 'publicIP') && item.publicIP) {
    name: 'pip-${padLeft(i + 1, 2, '0')}-${vmName}'
    location: location
    sku: {
      name: contains(item, 'publicIPSku') && item.publicIPSku ? item.publicIPSku : null
    }
    properties: {
      publicIPAllocationMethod: contains(item, 'publicIPType') && item.publicIPType ? item.publicIPType : null
    }
    tags: tags
  }
]

resource networkInterfaces 'Microsoft.Network/networkInterfaces@2023-05-01' = [
  for (item, i) in networkConfig: {
    name: 'nic-${padLeft(i + 1, 2, '0')}-${vmName}'
    location: location
    properties: {
      enableAcceleratedNetworking: contains(item, 'acceleratedNetworking') && item.acceleratedNetworking != ''
        ? item.acceleratedNetworking
        : false
      dnsSettings: {
        dnsServers: contains(item, 'dnsServers') && item.dnsServers != '' ? item.dnsServers : []
      }
      ipConfigurations: [
        for (item2, ipIndex) in range(0, item.numberOfIPs): {
          name: 'ipconfig${ipIndex + 1}'
          properties: {
            privateIPAllocationMethod: 'Dynamic'
            primary: ipIndex == 0 ? true : false
            subnet: {
              #disable-next-line use-resource-id-functions
              id: '${vNetId}/subnets/${item.subnetName}'
            }
            publicIPAddress: contains(item, 'publicIP') && item.publicIP && ipIndex == 0
              ? {
                  id: publicIPAddresses[ipIndex].id
                }
              : null
            loadBalancerBackendAddressPools: contains(item, 'loadBalancerName') && item.loadBalancerName != ''
              ? [
                  {
                    id: resourceId(
                      'Microsoft.Network/loadBalancers/backendAddressPools',
                      item.loadBalancerName,
                      item.loadBalancerPoolName
                    )
                  }
                ]
              : null
            applicationGatewayBackendAddressPools: contains(item, 'applicationGatewayBackendPoolId') && item.applicationGatewayBackendPoolId != ''
              ? [
                  {
                    id: item.applicationGatewayBackendPoolId
                  }
                ]
              : null
            applicationSecurityGroups: contains(item, 'applicationSecurityGroups') && !empty(item.applicationSecurityGroups)
              ? item.applicationSecurityGroups
              : null
          }
        }
      ]
    }
    tags: tags
  }
]

module staticIPs '../NetworkInterface/template.bicep' = [
  for (item, i) in networkConfig: if (item.privateIPType == 'Static') {
    name: 'nic-${padLeft(i + 1, 2, '0')}-${vmName}-static'
    params: {
      tags: tags
      vmName: vmName
      vNetId: vNetId
      subnetName: item.subnetName
      privateIP: networkInterfaces[i].properties.ipConfigurations[i].properties.privateIPAddress
      privateIPAllocationMethod: 'Static'
      index: i + 1
      location: location
      numberOfIPs: item.numberOfIPs
      loadBalancerName: contains(item, 'loadBalancerName') && !empty(item.loadBalancerName) ? item.loadBalancerName : ''
      loadBalancerPoolName: contains(item, 'loadBalancerPoolName') && !empty(item.loadBalancerPoolName)
        ? item.loadBalancerPoolName
        : ''
      applicationSecurityGroups: contains(item, 'applicationSecurityGroups') && !empty(item.applicationSecurityGroups)
        ? item.applicationSecurityGroups
        : []
      applicationGatewayBackendPoolId: contains(item, 'applicationGatewayBackendPoolId') && !empty(item.applicationGatewayBackendPoolId)
        ? item.applicationGatewayBackendPoolId
        : ''
      dnsServers: contains(item, 'dnsServers') && item.dnsServers != '' ? item.dnsServers : []
    }
  }
]

resource disks 'Microsoft.Compute/disks@2021-12-01' = [
  for (item, i) in dataDisks: {
    name: 'disk-${padLeft(i + 1, 2, '0')}-${vmName}'
    location: location
    sku: {
      name: item.storageType
    }
    #disable-next-line BCP036
    zones: noInfrastructureRedundancy || deployAvailabilitySet || existingAvailabilitySet
      ? null
      : [
          (index - 1) % maxZones + 1
        ]
    properties: {
      creationData: {
        createOption: item.createOption
      }
      diskSizeGB: item.diskSizeGB
      networkAccessPolicy: contains(item, 'networkAccessPolicy') && !empty(item.networkAccessPolicy)
        ? item.networkAccessPolicy
        : 'DenyAll'
      publicNetworkAccess: contains(item, 'publicNetworkAccess') && !empty(item.publicNetworkAccess)
        ? item.publicNetworkAccess
        : 'Disabled'
    }
    tags: tags
  }
]

resource virtualMachine 'Microsoft.Compute/virtualMachines@2021-07-01' = {
  dependsOn: [
    staticIPs
    disks
    networkInterfaces
    publicIPAddresses
  ]
  name: vmName
  location: location
  #disable-next-line BCP036
  zones: noInfrastructureRedundancy || deployAvailabilitySet || existingAvailabilitySet
    ? null
    : [
        (index - 1) % maxZones + 1
      ]
  identity: enableManagedIdentity
    ? {
        type: 'SystemAssigned'
      }
    : {
        type: 'None'
      }
  plan: !empty(azureMarketPlaceOffer) ? azureMarketPlaceOffer : null
  properties: {
    licenseType: image.licenseType
    hardwareProfile: {
      vmSize: virtualMachineSize
    }
    availabilitySet: deployAvailabilitySet || existingAvailabilitySet
      ? {
          id: availabilitySetId
        }
      : null
    osProfile: {
      computerName: vmName
      adminUsername: adminUsername
      adminPassword: adminPassword
      windowsConfiguration: toLower(image.osType) == 'windows'
        ? {
            timeZone: timeZone
            provisionVMAgent: true
            enableAutomaticUpdates: true
          }
        : null
      linuxConfiguration: toLower(image.osType) == 'linux'
        ? {
            disablePasswordAuthentication: false
          }
        : null
      customData: !empty(customData) ? base64(customData) : null
    }
    storageProfile: {
      osDisk: {
        createOption: 'FromImage'
        name: 'osdisk-${vmName}'
        managedDisk: {
          storageAccountType: osDiskStorageType
        }
        caching: osDiskCaching
      }
      imageReference: contains(image, 'referenceId') && !empty(image.referenceId)
        ? {
            id: image.referenceId
          }
        : imageReference
      dataDisks: dataDiskConfig
    }
    networkProfile: {
      networkInterfaces: [
        for (item, i) in networkConfig: {
          id: resourceId('Microsoft.Network/networkInterfaces', 'nic-${padLeft(i + 1, 2, '0')}-${vmName}')
          properties: {
            primary: i == 0 ? true : false
          }
        }
      ]
    }
    securityProfile: securityType == 'None' && !encryptionAtHost
      ? null
      : securityType == 'None' && encryptionAtHost ? securityProfileEncryptionAtHostOnly : securityProfile
    diagnosticsProfile: {
      bootDiagnostics: {
        enabled: bootDiagnostics
      }
    }
  }
  tags: tags
}

resource logAnalyticsExtension 'Microsoft.Compute/virtualMachines/extensions@2021-07-01' =
  if (!empty(logAnalyticsWorkspaceId)) {
    parent: virtualMachine
    name: 'LogAnalytics'
    location: location
    tags: tags
    properties: {
      publisher: 'Microsoft.EnterpriseCloud.Monitoring'
      type: toLower(image.osType) == 'windows' ? 'MicrosoftMonitoringAgent' : 'OmsAgentForLinux'
      typeHandlerVersion: toLower(image.osType) == 'windows' ? '1.0' : '1.7'
      autoUpgradeMinorVersion: true
      settings: {
        workspaceId: !empty(logAnalyticsWorkspaceId)
          ? reference(logAnalyticsWorkspaceId, '2015-11-01-preview').customerId
          : null
      }
      protectedSettings: {
        workspaceKey: !empty(logAnalyticsWorkspaceId)
          ? listKeys(logAnalyticsWorkspaceId, '2015-11-01-preview').primarySharedKey
          : null
      }
    }
  }

resource dependencyAgentExtension 'Microsoft.Compute/virtualMachines/extensions@2021-07-01' =
  if (!empty(logAnalyticsWorkspaceId) && (dependencyAgent)) {
    dependsOn: [
      logAnalyticsExtension
    ]
    parent: virtualMachine
    name: 'DAExtension'
    location: location
    tags: tags
    properties: {
      publisher: 'Microsoft.Azure.Monitoring.DependencyAgent'
      type: toLower(image.osType) == 'windows' ? 'DependencyAgentWindows' : 'DependencyAgentLinux'
      typeHandlerVersion: toLower(image.osType) == 'windows' ? '9.5' : '9.5'
      autoUpgradeMinorVersion: true
    }
  }

resource encryptionKeyVault 'Microsoft.KeyVault/vaults@2021-06-01-preview' existing =
  if (!empty(encryptionKeyVaultResourceId)) {
    scope: resourceGroup(split(encryptionKeyVaultResourceId, '/')[2], split(encryptionKeyVaultResourceId, '/')[4])
    name: last(split(encryptionKeyVaultResourceId, '/'))
  }
resource encryptionExtension 'Microsoft.Compute/virtualMachines/extensions@2021-07-01' =
  if (!empty(encryptionKeyVaultResourceId)) {
    dependsOn: [
      logAnalyticsExtension
    ]
    parent: virtualMachine
    name: 'DiskEncryption'
    location: location
    tags: tags
    properties: {
      publisher: 'Microsoft.Azure.Security'
      type: toLower(image.osType) == 'windows' ? 'AzureDiskEncryption' : 'AzureDiskEncryptionForLinux'
      typeHandlerVersion: toLower(image.osType) == 'windows' ? '2.2' : '1.1'
      autoUpgradeMinorVersion: true
      forceUpdateTag: encryptionSequenceId
      settings: {
        EncryptionOperation: 'EnableEncryption'
        KeyVaultURL: !empty(encryptionKeyVaultResourceId) ? encryptionKeyVault.properties.vaultUri : null
        KeyVaultResourceId: !empty(encryptionKeyVaultResourceId) ? encryptionKeyVaultResourceId : null
        KeyEncryptionAlgorithm: 'RSA-OAEP'
        VolumeType: encryptionVolume
        KeyEncryptionKeyURL: enableKeyEncryptionKey ? KeyEncryptionKeyUrl : ''
        KekVaultResourceId: enableKeyEncryptionKey ? encryptionKeyVaultResourceId : ''
      }
    }
  }

resource networkWatcherExtension 'Microsoft.Compute/virtualMachines/extensions@2021-07-01' =
  if (!empty(logAnalyticsWorkspaceId) && (networkWatcher)) {
    dependsOn: [
      logAnalyticsExtension
      dependencyAgentExtension
      encryptionExtension
    ]
    parent: virtualMachine
    name: 'NetworkWatcher'
    location: location
    tags: tags
    properties: {
      publisher: 'Microsoft.Azure.NetworkWatcher'
      type: 'NetworkWatcherAgentWindows'
      typeHandlerVersion: '1.4'
      autoUpgradeMinorVersion: true
    }
  }

resource domainJoinExtension 'Microsoft.Compute/virtualMachines/extensions@2021-07-01' =
  if ((toLower(image.osType) == 'windows') && !empty(domainJoin)) {
    dependsOn: [
      logAnalyticsExtension
      dependencyAgentExtension
      encryptionExtension
      networkWatcherExtension
    ]
    parent: virtualMachine
    name: 'DomainJoin'
    location: location
    tags: tags
    properties: {
      publisher: 'Microsoft.Compute'
      type: 'JsonADDomainExtension'
      typeHandlerVersion: '1.3'
      autoUpgradeMinorVersion: true
      settings: {
        Name: domainJoin.name
        OUPath: domainJoin.ouPath
        User: domainJoinUsername
        Restart: true
        Options: 3
      }
      protectedSettings: {
        Password: domainJoinPassword
      }
    }
  }

resource guestAttestationWindows 'Microsoft.Compute/virtualMachines/extensions@2023-09-01' =
  if (bootIntegrityMonitoringEnabled) {
    name: 'GuestAttestation'
    parent: virtualMachine
    dependsOn: [
      logAnalyticsExtension
      dependencyAgentExtension
      encryptionExtension
      networkWatcherExtension
      domainJoinExtension
    ]
    location: location
    properties: {
      publisher: toLower(image.osType) == 'windows'
        ? 'Microsoft.Azure.Security.WindowsAttestation'
        : 'Microsoft.Azure.Security.LinuxAttestation'
      type: 'GuestAttestation'
      typeHandlerVersion: '1.0'
      autoUpgradeMinorVersion: true
      enableAutomaticUpgrade: true
      settings: {
        AttestationConfig: {
          MaaSettings: {
            maaEndpoint: ''
            maaTenantName: 'GuestAttestation'
          }
          AscSettings: {
            ascReportingEndpoint: ''
            ascReportingFrequency: ''
          }
          useCustomToken: 'false'
          disableAlerts: 'false'
        }
      }
    }
  }

module backup '../RecoveryServicesVaultBackupItem/template.bicep' =
  if (!empty(backupVaultResourceId) && !empty(backupPolicyName)) {
    name: '${virtualMachine.name}-backup'
    scope: resourceGroup(split(backupVaultResourceIdVar, '/')[2], split(backupVaultResourceIdVar, '/')[4])
    dependsOn: [
      logAnalyticsExtension
      encryptionExtension
    ]
    params: {
      backupVaultName: empty(backupVaultResourceId) ? '' : last(split(backupVaultResourceId, '/'))
      backupPolicyName: backupPolicyName
      vmId: virtualMachine.id
      vmName: virtualMachine.name
      resourceGroup: resourceGroup().name
    }
  }

resource roleAssignments 'Microsoft.Authorization/roleAssignments@2022-04-01' = [
  for item in permissions: {
    name: guid(resourceGroup().id, item.name, item.roleDefinitionId)
    scope: virtualMachine
    properties: {
      principalId: item.principalId
      roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', item.roleDefinitionId)
      condition: contains(item, 'condition') && item.condition != '' ? item.condition : null
      conditionVersion: contains(item, 'conditionVersion') && item.conditionVersion != '' ? item.conditionVersion : null
      delegatedManagedIdentityResourceId: contains(item, 'delegatedManagedIdentityResourceId') && item.delegatedManagedIdentityResourceId != ''
        ? item.delegatedManagedIdentityResourceId
        : null
      description: item.description
      principalType: item.principalType
    }
  }
]

@description('ID of the virtual machine')
output resourceID string = virtualMachine.id

@description('Name of the virtual machine')
output resourceName string = virtualMachine.name

@description('Private IP of the virtual machine')
output privateIP string = networkInterfaces[0].properties.ipConfigurations[0].properties.privateIPAddress

@description('ID of the managed identity')
output objectId string = enableManagedIdentity ? virtualMachine.identity.principalId : ''
