targetScope = 'resourceGroup'

@description('Optional. Time parameter to create unique deployment. Do not set in parameter file!')
param time string = replace(utcNow(), ':', '-')

@description('JSON configuration object for bicep deployments')
var subscriptionConfig = loadJsonContent('../../configs/subscriptionConfig.jsonc')
var namingConvention = subscriptionConfig.namingConvention
var tags = subscriptionConfig.Governance.tags

@description('Location of the resource group')
var location = subscriptionConfig.Governance.location

module resourceGroupConnectivityLock '../../../Templates/Features/ResourceGroupLock/template.bicep' = {
  name: 'resourceGroupConnectivityLock-${time}'
  params: {
    level: 'CanNotDelete'
  }
}

module recoveryServicesVault '../../../Templates/Features/RecoveryServicesVault/template.bicep' = {
  name: 'RecoveryServicesVault-${time}'
  params: {
    workloadName: namingConvention.workloadName
    applicationName: namingConvention.applicationName
    environmentName: namingConvention.environmentName
    regionName: namingConvention.regionName
    index: 1
    location: location
    tags: tags
    crossRegionRestoreFlag: true
    publicNetworkAccess: 'Disabled'
    skuName: 'Standard'
    storageType: 'GeoRedundant'
    assignManagedIdentity: true
  }
}

module recoveryServicesVaultRoleAssignment '../../../Templates/Features/RoleAssignmentRG/template.bicep' = {
  name: 'recoveryServicesVaultRoleAssignment-${time}'
  params: {
    permissions: [
      {
        name: recoveryServicesVault.outputs.resourceName
        principalId: recoveryServicesVault.outputs.resourceIdentity
        roleDefinitionId: 'b24988ac-6180-42a0-ab88-20f7382dd24c'
        description: 'Recovery Vault Managed Identity Contributor role assignment'
        principalType: 'ServicePrincipal'
      }
    ]
  }
}

module recoveryServicesVaultRoleAssignmentNetwork '../../../Templates/Features/RoleAssignmentRG/template.bicep' = {
  name: 'recoveryServicesVaultRoleAssignmentNetwork-${time}'
  scope: resourceGroup('*<mgmtWeu-connectivityRG_ResourceName>*')
  params: {
    permissions: [
      {
        name: recoveryServicesVault.outputs.resourceName
        principalId: recoveryServicesVault.outputs.resourceIdentity
        roleDefinitionId: 'b24988ac-6180-42a0-ab88-20f7382dd24c'
        description: 'Recovery Vault Managed Identity Contributor role assignment'
        principalType: 'ServicePrincipal'
      }
    ]
  }
}

module recoveryServicesVault_PE '../../../Templates/Features/PrivateLink/template.bicep' = {
  name: 'recoveryServicesVault_PE-${time}'
  params: {
    subnetId: '*<mgmtWeu-virtualNetwork_ResourceId>*/subnets/PrivateEndpointSubnet'
    privateLinkServiceId: recoveryServicesVault.outputs.resourceID
    groupIds: [
      'AzureBackup'
    ]
    index: 1
    customName: ''
    requestMessage: ''
    tags: tags
    location: location
  }
}


module defaultBackupPolicyVM '../../../Templates/Features/RecoveryServicesVaultBackupPolicy/template.bicep' = {
  name: 'defaultBackupPolicyVirtualMachinesPrd-${time}'
  params: {
    backupPolicyName: 'infr-vm-backup-policy'
    recoveryServicesVaultName: recoveryServicesVault.outputs.resourceName
    environmentName: namingConvention.environmentName
    backupManagementType: 'AzureIaasVM'
    timeZone: 'W. Europe Standard Time'
    scheduleRunTimes: [
      '23:00:00z'
    ]
    schedulePolicyType: 'SimpleSchedulePolicy'
    scheduleRunFrequency: 'Daily'
    scheduleRunDaysWeekly: []
    instantRpRetentionRangeInDays: 2
    dailyRetentionDurationCount: 7
    enableDailyWeeklyRetentionBackup: 'Enabled'
    daysOfTheWeekForWeeklyRetention: [
      'Sunday'
    ]
    weeklyRetentionDurationCount: 5
    enableMonthlyRetentionBackup: 'Enabled'
    monthlyRetentionScheduleFormatType: 'Daily'
    daysOfTheMonthForMonthlyRetention: [
      {
        date: 1
        isLast: false
      }
    ]
    weeksOfTheMonthForMonthlyRetention: []
    daysOfTheWeekForMonthlyRetention: []
    monthlyRetentionDurationCount: 12
    enableYearlyRetentionBackup: 'Enabled'
    yearlyRetentionScheduleFormatType: 'Daily'
    daysOfTheMonthForYearlyRetention: [
      {
        date: 1
        isLast: false
      }
    ]
    monthsOfYear: [
      'January'
    ]
    daysOfTheWeekForYearlyRetention: []
    weeksOfTheMonthForYearlyRetention: []
    yearlyRetentionDurationCount: 2
    location: location
  }
}


module defaultBackupPolicyVMEnhanced '../../../Templates/Features/RecoveryServicesVaultBackupPolicy/template.bicep' = {
  name: 'defaultBackupPolicyVMEnhanced-${time}'
  params: {
    backupPolicyName: 'infr-vm-backup-policy-enhanced'
    recoveryServicesVaultName: recoveryServicesVault.outputs.resourceName
    environmentName: namingConvention.environmentName
    backupManagementType: 'AzureIaasVM'
    timeZone: 'W. Europe Standard Time'
    scheduleRunTimes: [
      '23:00:00z'
    ]
    schedulePolicyType: 'SimpleSchedulePolicyV2'
    policyType: 'V2'
    scheduleRunFrequency: 'Daily'
    scheduleRunDaysWeekly: []
    instantRpRetentionRangeInDays: 2
    dailyRetentionDurationCount: 7
    enableDailyWeeklyRetentionBackup: 'Enabled'
    daysOfTheWeekForWeeklyRetention: [
      'Sunday'
    ]
    weeklyRetentionDurationCount: 5
    enableMonthlyRetentionBackup: 'Enabled'
    monthlyRetentionScheduleFormatType: 'Daily'
    daysOfTheMonthForMonthlyRetention: [
      {
        date: 1
        isLast: false
      }
    ]
    weeksOfTheMonthForMonthlyRetention: []
    daysOfTheWeekForMonthlyRetention: []
    monthlyRetentionDurationCount: 12
    enableYearlyRetentionBackup: 'Enabled'
    yearlyRetentionScheduleFormatType: 'Daily'
    daysOfTheMonthForYearlyRetention: [
      {
        date: 1
        isLast: false
      }
    ]
    monthsOfYear: [
      'January'
    ]
    daysOfTheWeekForYearlyRetention: []
    weeksOfTheMonthForYearlyRetention: []
    yearlyRetentionDurationCount: 2
    location: location
  }
}

module defaultSQLBackupPolicyVM '../../../Templates/Features/RecoveryServicesVaultBackupPolicy/template.bicep' = {
  name: 'defaultSQLBackupPolicyVirtualMachinesPrd-${time}'
  params: {
    backupPolicyName: 'infr-sql-backup-policy'
    recoveryServicesVaultName: recoveryServicesVault.outputs.resourceName
    environmentName: namingConvention.environmentName
    backupManagementType: 'AzureWorkload'
    timeZone: 'W. Europe Standard Time'
    schedulePolicyType: 'SimpleSchedulePolicy'
    instantRpRetentionRangeInDays: 2
    scheduleRunFrequency: 'Weekly'
    scheduleRunDaysWeekly: [
      'Sunday'
    ]
    dailyRetentionDurationCount: 30
    enableDailyWeeklyRetentionBackup: 'Enabled'
    weeklyRetentionDurationCount: 5
    daysOfTheWeekForWeeklyRetention: [
      'Sunday'
    ]
    enableMonthlyRetentionBackup: 'Enabled'
    monthlyRetentionScheduleFormatType: 'Weekly'
    daysOfTheMonthForMonthlyRetention: []
    daysOfTheWeekForMonthlyRetention: [
      'Sunday'
    ]
    weeksOfTheMonthForMonthlyRetention: [
      'First'
    ]
    monthlyRetentionDurationCount: 12
    enableYearlyRetentionBackup: 'Enabled'
    yearlyRetentionScheduleFormatType: 'Weekly'
    daysOfTheMonthForYearlyRetention: []
    daysOfTheWeekForYearlyRetention: [
      'Sunday'
    ]
    weeksOfTheMonthForYearlyRetention: [
      'First'
    ]
    monthsOfYear: [
      'January'
    ]
    yearlyRetentionDurationCount: 2
    enableSqlFullAndDiffAndLogBackup: 'Enabled'
    enableSqlFullAndDiffBackup:  'Disabled'
    enableSqlFullAndLogBackup: 'Disabled'
    sqlDifferentialScheduleRunTimes: [
      '23:00:00z'
    ]
    sqlDifferentialScheduleRunDaysWeekly: [
      'Monday'
      'Tuesday'
      'Wednesday'
      'Thursday'
      'Friday'
      'Saturday'
    ]
    sqlDifferentialRetentionDurationCount: 30
    sqlBackupCompression: false
    sqlScheduleFrequencyInMins: 15
    sqlLogRetentionDurationCount: 30
    location: location
  }
}


@description('ID of the resource')
output recoveryServicesVault_ResourceId string = recoveryServicesVault.outputs.resourceID
@description('Name of the resource')
output recoveryServicesVault_ResourceName string = recoveryServicesVault.outputs.resourceName

output defaultBackupPolicyVM_ResourceName string = '${defaultBackupPolicyVM.outputs.resourceName}-vm'
output defaultBackupPolicyVMEnhanced_ResourceName string = '${defaultBackupPolicyVMEnhanced.outputs.resourceName}-vm'
output defaultSQLBackupPolicyVM_ResourceName string = '${defaultSQLBackupPolicyVM.outputs.resourceName}-sqlvm'
