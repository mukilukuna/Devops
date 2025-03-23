param scalingPlanName string
param hostPoolName string
param location string

resource scalingPlan 'Microsoft.DesktopVirtualization/scalingplans@2023-09-05' = {
  name: scalingPlanName
  location: location
  properties: {
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
        rampUpStartTime: '06:00'
        peakStartTime: '08:00'
        rampDownStartTime: '18:00'
        offPeakStartTime: '20:00'
      }
    ]
  }
}
