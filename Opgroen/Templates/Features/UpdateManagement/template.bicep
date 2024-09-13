@description('Required. The name of the automation account resource the update configuration should be deployed to.')
param automationAccountName string

@description('Required. Array of Objects with updateConfigurationobjects.')
param updateSchedules array

@description('Optional. References the time when deploying.')
param currentTime string = utcNow('u')

resource automationAccount 'Microsoft.Automation/automationAccounts@2021-06-22' existing = {
  name: automationAccountName
}

resource softwareUpdateConfigurations 'Microsoft.Automation/automationAccounts/softwareUpdateConfigurations@2019-06-01' = [for item in updateSchedules: {
  name: item.name
  parent: automationAccount
  properties: {
    updateConfiguration: {
      operatingSystem: item.updateConfiguration.operatingSystem
      windows: contains(item.updateConfiguration, 'Windows') ? item.updateConfiguration.windows : null
      linux: contains(item.updateConfiguration, 'Linux') ? item.updateConfiguration.linux : null
      duration: item.updateConfiguration.duration
      targets: {
        azureQueries: item.updateConfiguration.targets.azureQueries
      }
    }
    scheduleInfo: {
      startTime: contains(item.scheduleInfo, 'startTime') ? item.scheduleInfo.startTime : dateTimeAdd(currentTime, 'PT3H')
      expiryTime: contains(item.scheduleInfo, 'expiryTime') ? item.scheduleInfo.expiryTime : '9999-12-31T23:59:59.9999999+00:00'
      isEnabled: contains(item.scheduleInfo, 'isEnabled') ? item.scheduleInfo.isEnabled : null
      frequency: item.scheduleInfo.frequency
      timeZone: item.scheduleInfo.timeZone
      interval: item.scheduleInfo.interval
      advancedSchedule: contains(item.scheduleInfo, 'advancedSchedule') ? item.scheduleInfo.advancedSchedule : null
    }
    tasks: {
      preTask: {
        parameters: contains(item.scheduleInfo.tasks, 'preTask') ? item.scheduleInfo.tasks.preTask.parameters : null
        source: contains(item.scheduleInfo.tasks, 'preTask') ? item.scheduleInfo.tasks.preTask.source : null
      }
      postTask: {
        parameters: contains(item.scheduleInfo.tasks, 'postTask') ? item.scheduleInfo.tasks.postTask.parameters : null
        source: contains(item.scheduleInfo.tasks, 'postTask') ? item.scheduleInfo.tasks.postTask.source : null
      }
    }
  }
}]

@description('Update schedule name')
output resourceName array = [for item in updateSchedules: item.name]

@description('Update schedule ID')
output resourceID array = [for (item, i) in updateSchedules: resourceId('Microsoft.Automation/automationAccounts/softwareUpdateConfigurations', automationAccountName, item.name)]
