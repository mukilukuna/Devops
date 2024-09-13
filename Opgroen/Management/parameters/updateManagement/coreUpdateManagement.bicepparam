using '../../modules/core/coreUpdateManagement.bicep'

param AAsubscriptions = [
  // This is done on Management Group level (FoundatioRoleAssignments.bicep)
  // {
  //   id: ''
  //   role: 'acdd72a7-3385-48ef-bd42-f606fba81ae7'
  //   roleName: 'Reader'
  // }
  // {
  //   id: ''
  //   role: '40c5ff49-9181-41f8-ae61-143b0e78555e'
  //   roleName: 'Desktop Virtualization Power On Off Contributor'
  // }
]

param subscriptions = [
  // Should be filled in by pipeline override
  // {
  //   id: ''
  //   locations: [
  //     'westeurope'
  //   ]
  // }
]

param AUMschedules = [
  {
    name: 'infr-weu-group0'
    location: 'westeurope'
    rebootSetting: 'IfRequired'
    maintenanceWindowSearchTagName: ''
    OverrideTagValue: ''
    maintenanceWindow: {
      startTime: '08:00'
      duration: '01:30'
      timeZone: 'W. Europe Standard Time'
      recurEvery: '1Day'
    }
    linuxParameters: {
      classificationsToInclude: null
      packageNameMasksToExclude: null
      packageNameMasksToInclude: null
    }
    windowsParameters: {
      classificationsToInclude: [
        'Definition'
      ]
      kbNumbersToExclude: null
      kbNumbersToInclude: null
    }
  }
  {
    name: 'infr-weu-group1'
    location: 'westeurope'
    rebootSetting: 'IfRequired'
    OverrideTagValue: 'infr-weu-group1-0600-ThirdSunday'
    maintenanceWindow: {
      startTime: '06:00'
      duration: '03:55'
      timeZone: 'W. Europe Standard Time'
      recurEvery: 'Month Third Sunday'
    }
    linuxParameters: {
      packageNameMasksToExclude: [
        '*diffutils.i686*'
      ]
      classificationsToInclude: [
        'Critical'
        'Security'
      ]
    }
    windowsParameters: {
      kbNumbersToExclude: [
        '5034439'
      ]
      classificationsToInclude: [
        'Critical'
        'Security'
      ]
    }
  }
  {
    name: 'infr-weu-group2'
    location: 'westeurope'
    rebootSetting: 'IfRequired'
    OverrideTagValue: 'infr-weu-group2-0600-FourthSunday'
    maintenanceWindow: {
      startTime: '06:00'
      duration: '03:55'
      timeZone: 'W. Europe Standard Time'
      recurEvery: 'Month Fourth Sunday'
    }
    linuxParameters: {
      packageNameMasksToExclude: [
        '*diffutils.i686*'
      ]
      classificationsToInclude: [
        'Critical'
        'Security'
      ]
    }
    windowsParameters: {
      kbNumbersToExclude: [
        '5034439'
      ]
      classificationsToInclude: [
        'Critical'
        'Security'
      ]
    }
  }
]
