@description('Required. Name of the backup policy')
param backupPolicyName string

@description('Required. The code of the environment this resource will be used in')
@maxLength(1)
param environmentName string

@description('Required. Name of the Recovery Services Vault')
param recoveryServicesVaultName string

@description('Required. Type of backup policy')
@allowed([
  'AzureIaasVM'
  'AzureSql'
  'AzureStorage'
  'AzureWorkload'
  'GenericProtectionPolicy'
  'MAB'
])
param backupManagementType string

@description('Optional. PolicyType')
@allowed([
  'Invalid'
  'V1'
  'V2'
])
param policyType string = 'V1'

@description('Required. Type of backup schedule')
@allowed([
  'LogSchedulePolicy'
  'LongTermSchedulePolicy'
  'SimpleSchedulePolicy'
  'SimpleSchedulePolicyV2'
])
param schedulePolicyType string

@description('Optional. Frequency of the schedule operation of this policy')
@allowed([
  'Daily'
  'Hourly'
  'Invalid'
  'Weekly'
])
param scheduleRunFrequency string = 'Daily'

@description('Optional. Backup Schedule will run on array of Days like, Monday, Tuesday etc. Applies in Weekly Backup Type only')
param scheduleRunDaysWeekly array = [
  'Sunday'
]

@description('Optional. Times in day when backup should be triggered. e.g. 01:00, 13:00. This will be used in LTR too for daily, weekly, monthly and yearly backup')
param scheduleRunTimes array = [
  '23:00:00z'
]

@description('Optional.Hourly schedule for enhanced backup policy')
param hourlySchedule object = {}

@description('Optional. Any Valid timezone, for example:UTC, Pacific Standard Time. Refer: https://msdn.microsoft.com/en-us/library/gg154758.aspx')
param timeZone string = 'W. Europe Standard Time'

@description('Optional. Instant RP retention policy range in days')
param instantRpRetentionRangeInDays int = 2

@description('Optional. Number of days you want to retain the daily backup')
param dailyRetentionDurationCount int = 30

@description('Optional. Enable Weekly Retention for Daily Scheduled Backups')
param enableDailyWeeklyRetentionBackup string = 'Disabled'

@description('Optional. Number of weeks you want to retain the backup')
param weeklyRetentionDurationCount int = 12

@description('Optional. Array of Days for Monthly Retention (Min One or Max all values from scheduleRunDaysWeekly, but not any other days which are not part of scheduleRunDaysWeekly)')
param daysOfTheWeekForWeeklyRetention array = [
  'Sunday'
]

@description('Optional. Enable Monthly Retention for Scheduled Backups')
param enableMonthlyRetentionBackup string = 'Disabled'

@description('Optional. Daily or Weekly Backup Type for Monthly Retention')
param monthlyRetentionScheduleFormatType string = 'Weekly'

@description('Optional. Array of Days of the Week for Monthly Retention (Min One or Max all values from scheduleRunDaysWeekly, but not any other days which are not part of scheduleRunDaysWeekly)')
param daysOfTheMonthForMonthlyRetention array = [
  {
    date: 1
    isLast: false
  }
]

@description('Optional. Array of Days for Monthly Retention (Min One or Max all values from scheduleRunDaysWeekly, but not any other days which are not part of scheduleRunDaysWeekly)')
param daysOfTheWeekForMonthlyRetention array = [
  'Sunday'
]

@description('Optional. Array of Weeks for Monthly Retention')
@allowed([
  'First'
  'Second'
  'Thrid'
  'Fourth'
  'Last'
])
param weeksOfTheMonthForMonthlyRetention array = [
  'First'
]

@description('Optional. Number of months you want to retain the backup')
param monthlyRetentionDurationCount int = 60

@description('Optional. Enable yearly retention')
param enableYearlyRetentionBackup string = 'Disabled'

@description('Optional. Daily or Weekly Backup Type')
@allowed([
  'Daily'
  'Invalid'
  'Weekly'
])
param yearlyRetentionScheduleFormatType string = 'Weekly'

@description('Optional. Array of Days for monthly retention for yearly backup(Min One or Max all values from scheduleRunDaysWeekly, but not any other days which are not part of scheduleRunDaysWeekly)')
param daysOfTheMonthForYearlyRetention array = [
  {
    date: 1
    isLast: false
  }
]

@description('Optional. List of months of year of yearly retention policy')
param monthsOfYear array = [
  'January'
]

@description('Optional. Array of Days for Yearly Retention (Min One or Max all values from scheduleRunDaysWeekly, but not any other days which are not part of scheduleRunDaysWeekly)')
param daysOfTheWeekForYearlyRetention array = [
  'Sunday'
]

@description('Optional. Array of Weeks for Yearly Retention - First, Second, Third, Fourth, Last')
param weeksOfTheMonthForYearlyRetention array = [
  'First'
]

@description('Optional. Number of years you want to retain the backup')
param yearlyRetentionDurationCount int = 7

@description('Optional. Enable or disable SQL Full + Diff backup (only possible with weekly schedule)')
param enableSqlFullAndDiffBackup string = 'Disabled'

@description('Optional. Enable or disable SQL Full + Diff + Log backup')
param enableSqlFullAndDiffAndLogBackup string = 'Disabled'

@description('Optional. Enable or disable SQL Full + Log backup')
param enableSqlFullAndLogBackup string = 'Enabled'

@description('Optional. Times in day when the SQL differential backup should be triggered. e.g. 01:00, 13:00')
param sqlDifferentialScheduleRunTimes array = [
  '23:00:00z'
]

@description('Optional. Enable or disable SQL compression during backup')
param sqlBackupCompression bool = false

@description('Optional. Array of Days of the Week for SQL differential backup (only possible with weekly schedule)')
@allowed([
  'Friday'
  'Monday'
  'Saturday'
  'Sunday'
  'Thursday'
  'Tuesday'
  'Wednesday'
])
param sqlDifferentialScheduleRunDaysWeekly array = [
  'Monday'
  'Tuesday'
  'Wednesday'
  'Thursday'
  'Friday'
  'Saturday'
]

@description('Optional. Number of day to keep the SQL differential backups')
param sqlDifferentialRetentionDurationCount int = 30

@description('Optional. Frequency in minutes for the log backup schedule')
param sqlScheduleFrequencyInMins int = 120

@description('Optional. Number of days to keep the SQL log backups')
param sqlLogRetentionDurationCount int = 14

@description('Optional. Location of the resource')
param location string = resourceGroup().location

var backupPolicyName_var = toLower('${backupPolicyName}-${environmentName}-${backupManagementType}')
var dailySchedule = {
  retentionTimes: scheduleRunTimes
  retentionDuration: {
    count: dailyRetentionDurationCount
    durationType: 'Days'
  }
}
var weeklySchedule = {
  daysOfTheWeek: scheduleRunFrequency == 'Weekly' ? scheduleRunDaysWeekly : daysOfTheWeekForWeeklyRetention
  retentionTimes: scheduleRunTimes
  retentionDuration: {
    count: weeklyRetentionDurationCount
    durationType: 'Weeks'
  }
}
var monthlyWeeklySchedule = {
  retentionScheduleFormatType: monthlyRetentionScheduleFormatType
  retentionScheduleDaily: null
  retentionScheduleWeekly: {
    daysOfTheWeek: daysOfTheWeekForMonthlyRetention
    weeksOfTheMonth: weeksOfTheMonthForMonthlyRetention
  }
  retentionTimes: scheduleRunTimes
  retentionDuration: {
    count: monthlyRetentionDurationCount
    durationType: 'Months'
  }
}
var monthlyDailySchedule = {
  retentionScheduleFormatType: monthlyRetentionScheduleFormatType
  retentionScheduleDaily: {
    daysOfTheMonth: daysOfTheMonthForMonthlyRetention
  }
  retentionScheduleWeekly: null
  retentionTimes: scheduleRunTimes
  retentionDuration: {
    count: monthlyRetentionDurationCount
    durationType: 'Months'
  }
}
var monthlySchedule = monthlyRetentionScheduleFormatType == 'Weekly' ? monthlyWeeklySchedule : (monthlyRetentionScheduleFormatType == 'Daily' ? monthlyDailySchedule : null)
var yearlyWeeklySchedule = {
  retentionScheduleFormatType: yearlyRetentionScheduleFormatType
  monthsOfYear: monthsOfYear
  retentionScheduleDaily: null
  retentionScheduleWeekly: {
    daysOfTheWeek: daysOfTheWeekForYearlyRetention
    weeksOfTheMonth: weeksOfTheMonthForYearlyRetention
  }
  retentionTimes: scheduleRunTimes
  retentionDuration: {
    count: yearlyRetentionDurationCount
    durationType: 'Years'
  }
}
var yearlyDailySchedule = {
  retentionScheduleFormatType: yearlyRetentionScheduleFormatType
  monthsOfYear: monthsOfYear
  retentionScheduleDaily: {
    daysOfTheMonth: daysOfTheMonthForYearlyRetention
  }
  retentionScheduleWeekly: null
  retentionTimes: scheduleRunTimes
  retentionDuration: {
    count: yearlyRetentionDurationCount
    durationType: 'Years'
  }
}
var yearlySchedule = yearlyRetentionScheduleFormatType == 'Weekly' ? yearlyWeeklySchedule : (yearlyRetentionScheduleFormatType == 'Daily' ? yearlyDailySchedule : null)
var subSqlFullOnlyProtectionPolicy = [
  {
    policyType: 'Full'
    schedulePolicy: {
      scheduleRunFrequency: scheduleRunFrequency
      scheduleRunDays: scheduleRunFrequency == 'Weekly' ? scheduleRunDaysWeekly : null
      scheduleRunTimes: scheduleRunTimes
      schedulePolicyType: schedulePolicyType
    }
    retentionPolicy: {
      dailySchedule: scheduleRunFrequency == 'Daily' ? dailySchedule : null
      weeklySchedule: scheduleRunFrequency == 'Weekly' ? weeklySchedule : (enableDailyWeeklyRetentionBackup == 'Enabled' ? weeklySchedule : null)
      monthlySchedule: enableMonthlyRetentionBackup == 'Enabled' ? monthlySchedule : null
      yearlySchedule: enableYearlyRetentionBackup == 'Enabled' ? yearlySchedule : null
      retentionPolicyType: 'LongTermRetentionPolicy'
    }
  }
]
var subSqlFullAndLogProtectionPolicy = [
  {
    policyType: 'Full'
    schedulePolicy: {
      scheduleRunFrequency: scheduleRunFrequency
      scheduleRunDays: scheduleRunFrequency == 'Weekly' ? scheduleRunDaysWeekly : null
      scheduleRunTimes: scheduleRunTimes
      schedulePolicyType: schedulePolicyType
    }
    retentionPolicy: {
      dailySchedule: scheduleRunFrequency == 'Daily' ? dailySchedule : null
      weeklySchedule: scheduleRunFrequency == 'Weekly' ? weeklySchedule : (enableDailyWeeklyRetentionBackup == 'Enabled' ? weeklySchedule : null)
      monthlySchedule: enableMonthlyRetentionBackup == 'Enabled' ? monthlySchedule : null
      yearlySchedule: enableYearlyRetentionBackup == 'Enabled' ? yearlySchedule : null
      retentionPolicyType: 'LongTermRetentionPolicy'
    }
  }
  {
    policyType: 'Log'
    schedulePolicy: {
      scheduleFrequencyInMins: sqlScheduleFrequencyInMins
      schedulePolicyType: 'LogSchedulePolicy'
    }
    retentionPolicy: {
      retentionDuration: {
        count: sqlLogRetentionDurationCount
        durationType: 'Days'
      }
      retentionPolicyType: 'SimpleRetentionPolicy'
    }
  }
]
var subSqlFullAndDifProtectionPolicy = [
  {
    policyType: 'Full'
    schedulePolicy: {
      scheduleRunFrequency: scheduleRunFrequency
      scheduleRunDays: scheduleRunFrequency == 'Weekly' ? scheduleRunDaysWeekly : null
      scheduleRunTimes: scheduleRunTimes
      schedulePolicyType: schedulePolicyType
    }
    retentionPolicy: {
      dailySchedule: scheduleRunFrequency == 'Daily' ? dailySchedule : null
      weeklySchedule: scheduleRunFrequency == 'Weekly' ? weeklySchedule : (enableDailyWeeklyRetentionBackup == 'Enabled' ? weeklySchedule : null)
      monthlySchedule: enableMonthlyRetentionBackup == 'Enabled' ? monthlySchedule : null
      yearlySchedule: enableYearlyRetentionBackup == 'Enabled' ? yearlySchedule : null
      retentionPolicyType: 'LongTermRetentionPolicy'
    }
  }
  {
    policyType: 'Differential'
    schedulePolicy: {
      scheduleRunFrequency: 'Weekly'
      scheduleRunDays: sqlDifferentialScheduleRunDaysWeekly
      scheduleRunTimes: sqlDifferentialScheduleRunTimes
      scheduleWeeklyFrequency: 0
      schedulePolicyType: 'SimpleSchedulePolicy'
    }
    retentionPolicy: {
      retentionDuration: {
        count: sqlDifferentialRetentionDurationCount
        durationType: 'Days'
      }
      retentionPolicyType: 'SimpleRetentionPolicy'
    }
  }
]
var subSqlFullAndDiffAndLogProtectionPolicy = [
  {
    policyType: 'Full'
    schedulePolicy: {
      scheduleRunFrequency: scheduleRunFrequency
      scheduleRunDays: scheduleRunFrequency == 'Weekly' ? scheduleRunDaysWeekly : null
      scheduleRunTimes: scheduleRunTimes
      schedulePolicyType: schedulePolicyType
    }
    retentionPolicy: {
      dailySchedule: scheduleRunFrequency == 'Daily' ? dailySchedule : null
      weeklySchedule: scheduleRunFrequency == 'Weekly' ? weeklySchedule : (enableDailyWeeklyRetentionBackup == 'Enabled' ? weeklySchedule : null)
      monthlySchedule: enableMonthlyRetentionBackup == 'Enabled' ? monthlySchedule : null
      yearlySchedule: enableYearlyRetentionBackup == 'Enabled' ? yearlySchedule : null
      retentionPolicyType: 'LongTermRetentionPolicy'
    }
  }
  {
    policyType: 'Differential'
    schedulePolicy: {
      scheduleRunFrequency: 'Weekly'
      scheduleRunDays: sqlDifferentialScheduleRunDaysWeekly
      scheduleRunTimes: sqlDifferentialScheduleRunTimes
      scheduleWeeklyFrequency: 0
      schedulePolicyType: 'SimpleSchedulePolicy'
    }
    retentionPolicy: {
      retentionDuration: {
        count: sqlDifferentialRetentionDurationCount
        durationType: 'Days'
      }
      retentionPolicyType: 'SimpleRetentionPolicy'
    }
  }
  {
    policyType: 'Log'
    schedulePolicy: {
      scheduleFrequencyInMins: sqlScheduleFrequencyInMins
      schedulePolicyType: 'LogSchedulePolicy'
    }
    retentionPolicy: {
      retentionDuration: {
        count: sqlLogRetentionDurationCount
        durationType: 'Days'
      }
      retentionPolicyType: 'SimpleRetentionPolicy'
    }
  }
]

resource backupPoliciesVm 'Microsoft.RecoveryServices/vaults/backupPolicies@2022-01-01' = if (backupManagementType == 'AzureIaasVM') {
  name: '${recoveryServicesVaultName}/${backupPolicyName_var}-vm'
  location: location
  properties: {
    backupManagementType: 'AzureIaasVM'
    instantRpRetentionRangeInDays: scheduleRunFrequency == 'Weekly' ? 5 : instantRpRetentionRangeInDays
    policyType: policyType
    schedulePolicy: {
      schedulePolicyType: schedulePolicyType
      scheduleRunFrequency: scheduleRunFrequency
      hourlySchedule: scheduleRunFrequency != 'Hourly' ? null : hourlySchedule
      dailySchedule: scheduleRunFrequency != 'Daily' ? null : {
        scheduleRunTimes: scheduleRunTimes
      }
      weeklySchedule: scheduleRunFrequency != 'Weekly' ? null : {
        scheduleRunTimes: scheduleRunDaysWeekly
      }
      scheduleRunDays: scheduleRunFrequency == 'Weekly' ? scheduleRunDaysWeekly : null
      scheduleRunTimes: scheduleRunFrequency != 'Hourly' ? scheduleRunTimes : null
    }
    retentionPolicy: {
      dailySchedule: scheduleRunFrequency == 'Daily' ? dailySchedule : null
      weeklySchedule: scheduleRunFrequency == 'Weekly' ? weeklySchedule : (enableDailyWeeklyRetentionBackup == 'Enabled' ? weeklySchedule : null)
      monthlySchedule: enableMonthlyRetentionBackup == 'Enabled' ? monthlySchedule : null
      yearlySchedule: enableYearlyRetentionBackup == 'Enabled' ? yearlySchedule : null
      retentionPolicyType: 'LongTermRetentionPolicy'
    }
    timeZone: timeZone
  }
}

resource backupPoliciesFile 'Microsoft.RecoveryServices/vaults/backupPolicies@2022-01-01' = if (backupManagementType == 'AzureStorage') {
  name: '${recoveryServicesVaultName}/${backupPolicyName_var}-file'
  location: location
  properties: {
    backupManagementType: 'AzureStorage'
    workLoadType: 'AzureFileShare'
    schedulePolicy: {
      scheduleRunFrequency: scheduleRunFrequency
      scheduleRunDays: null
      scheduleRunTimes: scheduleRunTimes
      schedulePolicyType: schedulePolicyType
    }
    retentionPolicy: {
      dailySchedule: scheduleRunFrequency == 'Daily' ? dailySchedule : null
      weeklySchedule: null
      monthlySchedule: null
      yearlySchedule: null
      retentionPolicyType: 'LongTermRetentionPolicy'
    }
    timeZone: timeZone
  }
}

resource backupPoliciesSqlvm 'Microsoft.RecoveryServices/vaults/backupPolicies@2022-01-01' = if (backupManagementType == 'AzureWorkload') {
  name: '${recoveryServicesVaultName}/${backupPolicyName_var}-sqlvm'
  location: location
  properties: {
    backupManagementType: 'AzureWorkload'
    workLoadType: 'SQLDataBase'
    settings: {
      timeZone: timeZone
      issqlcompression: sqlBackupCompression
      isCompression: sqlBackupCompression
    }
    subProtectionPolicy: enableSqlFullAndLogBackup == 'Enabled' ? subSqlFullAndLogProtectionPolicy : (enableSqlFullAndDiffBackup == 'Enabled' ? subSqlFullAndDifProtectionPolicy : (enableSqlFullAndDiffAndLogBackup == 'Enabled' ? subSqlFullAndDiffAndLogProtectionPolicy : subSqlFullOnlyProtectionPolicy))
  }
}

@description('ID of the resource')
output resourceID string = backupManagementType == 'AzureIaasVM' ? backupPoliciesVm.id : backupManagementType == 'AzureAzureStorage' ? backupPoliciesFile.id : backupManagementType == 'AzureWorkload' ? backupPoliciesSqlvm.id : ''

@description('Name of the resource')
output resourceName string = backupPolicyName_var
