@description('Required. The name of the application')
param applicationName string

@description('Required. The code of the environment this resource will be used in')
@maxLength(1)
param environmentName string

@description('Required. The name of the workload this resource will be used for')
param workloadName string

@description('Required. Region of the resource')
@maxLength(4)
param regionName string

@description('Required. Index of the resource')
param index int

@description('Optional. The name to use if not using the normal naming convention')
param customName string = ''

@description('Optional. Resource tags')
param tags object = {}

@description('Required. Version of Kubernetes specified when creating the managed cluster')
param kubernetesVersion string

@description('Required. SKU Tier of AKS Cluster')
@allowed([
  'Free'
  'Standard'
  'Premium'
])
param skuTier string = 'Standard'

@description('Required. DNS prefix specified when creating the managed cluster, cannot be updated once the managed cluster has been created')
param dnsPrefix string

@description('Required. Properties of the agent pools')
param agentPools array

@description('Optional. Profile for Linux VMs in the container service cluster')
param linuxProfile object = {}

@description('Optional. Profile for Windows VMs in the container service cluster')
param windowsProfile object = {}

@description('Required. The resource Id of the log analytics workspace that will monitor the cluster')
param logAnalyticsWorkspaceId string

@description('Optional. Whether or not to enable the AKS Policy add-on')
param enableAKSPolicy bool = true

@description('Optional. Whether or not to enable the AKS Cost Analysis add-on')
param enableAKSCostAnalysis bool = true

@description('Optional. Name of the resource group containing agent pool nodes')
param nodeResourceGroup string = '${resourceGroup().name}-nodes'

@description('Optional. Whether to enable Kubernetes Role-Based Access Control')
param enableRBAC bool = true

@description('Optional. Whether to enable Kubernetes pod security policy')
param enablePodSecurityPolicy bool = false

@description('Required. Profile of network configuration')
param networkProfile object

@description('Optional. Profile of Azure Active Directory configuration')
param aadProfile object = {
  managed: true
  enableAzureRbac: true
}

@description('Optional. AutoUpgradeProfile')
@allowed([
  'stable'
  'node-image'
  'patch'
  'none'
  'rapid'
])
param upgradeChannel string = 'stable'

@description('Optional. Parameters to be applied to the cluster-autoscaler when enabled')
param autoScalerProfile object = {}

@description('Optional. Profile of managed cluster add-ons')
param addonProfiles object = {
  azureKeyvaultSecretsProvider: {
    enabled: true
    config: {
      enableSecretRotation: 'true'
    }
  }
}

@description('Optional. Access profile for managed cluster API server')
param apiServerAccessProfile object = {}

@description('Optional. ResourceId of the disk encryption set to use for enabling encryption at rest')
param diskEncryptionSetId string = ''

@description('Optional. The resource Id of the container registry this cluster should use. Default is `/////` to prevent a bug in the template')
param containerRegistryId string = '/////'

@description('Optional. Location of the resource')
param location string = resourceGroup().location

@description('Optional. The humber of days to keep the diagnostic logging')
param diagnosticsRetentionPeriod int = 14

@description('Optional. Array of Role Assignments to deploy')
param permissions array = []

var nameVar = empty(customName) ? toLower('aks-${workloadName}-${applicationName}-${environmentName}-${regionName}-${padLeft(index, 2, '0')}') : customName
var agentPoolIdentity = toLower('aks-${workloadName}-${applicationName}-${environmentName}-${regionName}-${padLeft(index, 2, '0')}-agentpool')
var metricsProfile = {
  costAnalysis: {
    enabled: enableAKSCostAnalysis
  }
}
var mandatoryAddOnProfile = {
  kubeDashboard: {
    enabled: false
  }
  omsagent: {
    enabled: true
    config: {
      logAnalyticsWorkspaceResourceID: logAnalyticsWorkspaceId
    }
  }
  azurepolicy: {
    enabled: enableAKSPolicy
    config: {
      version: 'v2'
    }
  }
}
var addOnProfiles_var = union(mandatoryAddOnProfile, addonProfiles)

resource aks 'Microsoft.ContainerService/managedClusters@2024-03-02-preview' = {
  name: nameVar
  location: location
  tags: tags
  properties: {
    kubernetesVersion: kubernetesVersion
    dnsPrefix: dnsPrefix
    agentPoolProfiles: agentPools
    linuxProfile: empty(linuxProfile) ? null : linuxProfile
    windowsProfile: empty(windowsProfile) ? null : windowsProfile
    addonProfiles: addOnProfiles_var
    nodeResourceGroup: nodeResourceGroup
    enableRBAC: enableRBAC
    enablePodSecurityPolicy: enablePodSecurityPolicy
    networkProfile: networkProfile
    metricsProfile: metricsProfile
    aadProfile: empty(aadProfile) ? null : aadProfile
    autoScalerProfile: autoScalerProfile
    apiServerAccessProfile: apiServerAccessProfile
    diskEncryptionSetID: empty(diskEncryptionSetId) ? null : diskEncryptionSetId
    autoUpgradeProfile: {
      upgradeChannel: upgradeChannel
    }
  }
  identity: {
    type: 'SystemAssigned'
  }
  sku: {
    name: 'Base'
    tier: skuTier
  }
}

resource roleAssignments 'Microsoft.Authorization/roleAssignments@2022-01-01-preview' = [for item in permissions: {
  name: guid(resourceGroup().id, item.name, item.roleDefinitionId)
  scope: aks
  properties: {
    principalId: item.principalId
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', item.roleDefinitionId)
    condition: contains(item, 'condition') && item.condition != '' ? item.condition : null
    conditionVersion: contains(item, 'conditionVersion') && item.conditionVersion != '' ? item.conditionVersion : null
    delegatedManagedIdentityResourceId: contains(item, 'delegatedManagedIdentityResourceId') && item.delegatedManagedIdentityResourceId != '' ? item.delegatedManagedIdentityResourceId : null
    description: item.description
    principalType: item.principalType
  }
}]

resource diagSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: 'AKSDiagnostics'
  scope: aks
  properties: {
    workspaceId: logAnalyticsWorkspaceId
    logs: [
      {
        category: 'kube-apiserver'
        enabled: true
        retentionPolicy: {
          days: diagnosticsRetentionPeriod
          enabled: true
        }
      }
      {
        category: 'kube-audit'
        enabled: true
        retentionPolicy: {
          days: diagnosticsRetentionPeriod
          enabled: true
        }
      }
      {
        category: 'kube-controller-manager'
        enabled: true
        retentionPolicy: {
          days: diagnosticsRetentionPeriod
          enabled: true
        }
      }
      {
        category: 'kube-scheduler'
        enabled: true
        retentionPolicy: {
          days: diagnosticsRetentionPeriod
          enabled: true
        }
      }
      {
        category: 'cluster-autoscaler'
        enabled: true
        retentionPolicy: {
          days: diagnosticsRetentionPeriod
          enabled: true
        }
      }
    ]
    metrics: [
      {
        category: 'AllMetrics'
        enabled: true
        retentionPolicy: {
          days: diagnosticsRetentionPeriod
          enabled: true
        }
      }
    ]
  }
}

resource monitor_roleAssignments 'Microsoft.Authorization/roleAssignments@2020-10-01-preview' = {
  name: '${guid(resourceGroup().id, nameVar, 'Monitoring Metrics Publisher')}'
  scope: aks
  properties: {
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', '3913510d-42f4-4e42-8a64-420c390055eb')
    principalId: aks.properties.addonProfiles.omsagent.identity.objectId
  }
}

module vnet_roleAssignment '../RoleAssignmentRG/template.bicep' = [for (item, i) in agentPools: {
  name: '${nameVar}-vnet-subnet-rbac${(i + 1)}'
  scope: resourceGroup(split(item.vnetSubnetId, '/')[4])
  params: {
    permissions: [
      {
        name: agentPools[i].vnetSubnetId
        principalId: aks.identity.principalId
        principalType: 'ServicePrincipal'
        roleDefinitionId: '4d97b98b-1d4f-4787-a291-c67834d212e7'
        description: 'Needed for AKS Cluster'
      }
    ]
  }
}]

module acr_roleAssignment '../RoleAssignmentRG/template.bicep' = if (contains(containerRegistryId, 'subscriptions')) {
  name: '${nameVar}-acr-rbac'
  scope: resourceGroup(split(containerRegistryId, '/')[2], split(containerRegistryId, '/')[4])
  params: {
    permissions: [
      {
        name: '${nameVar}-acr-rbac'
        principalId: aks.properties.identityProfile.kubeletidentity.objectId
        principalType: 'ServicePrincipal'
        roleDefinitionId: '7f951dda-4ed3-4680-a7ca-43fe172d538d'
        description: 'Needed for AKS Cluster'
      }
    ]
  }
}

module agentPoolIdentity_vmc_rbac '../RoleAssignmentRG/template.bicep' = {
  name: '${agentPoolIdentity}-vmc-rbac'
  scope: resourceGroup(nodeResourceGroup)
  params: {
    permissions: [
      {
        name: agentPoolIdentity
        principalId: aks.properties.identityProfile.kubeletidentity.objectId
        principalType: 'ServicePrincipal'
        roleDefinitionId: '9980e02c-c2be-4d73-94e8-173b1dc7cf3c'
        description: 'Needed for AKS Cluster'
      }
    ]
  }
}

module agentPoolIdentity_mio_rbac '../RoleAssignmentRG/template.bicep' = {
  name: '${agentPoolIdentity}-mio-rbac'
  scope: resourceGroup(nodeResourceGroup)
  params: {
    permissions: [
      {
        name: agentPoolIdentity
        principalId: aks.properties.identityProfile.kubeletidentity.objectId
        principalType: 'ServicePrincipal'
        roleDefinitionId: 'f1a07417-d97a-45cb-824c-7a7467783830'
        description: 'Needed for AKS Cluster'
      }
    ]
  }
}

@description('Name of the resource')
output resourceName string = aks.name

@description('ID of the resource')
output resourceID string = aks.id
