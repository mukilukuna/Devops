param scalingPlanName string
param hostPoolName string
param location string

resource hostPool 'Microsoft.DesktopVirtualization/hostpools@2023-09-05' existing = {
  name: hostPoolName
}

resource scalingPlan 'Microsoft.DesktopVirtualization/scalingplans@2023-09-05' = {
  name: scalingPlanName
  location: location
  properties: {
    timeZone: 'W. Europe Standard Time'
    hostPoolReferences: [
      {
        hostPoolArmPath: hostPool.id
        scalingPlanEnabled: true
      }
    ]
    schedules: [
      {
        name: 'Weekdays'
        daysOfWeek: ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday']
        rampUpStartTime: {
          hour: 6
          minute: 0
        }
        peakStartTime: {
          hour: 8
          minute: 0
        }
        rampDownStartTime: {
          hour: 18
          minute: 0
        }
        offPeakStartTime: {
          hour: 20
          minute: 0
        }
      }
    ]
  }
}

output scalingPlanId string = scalingPlan.id
