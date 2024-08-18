// https://www.detechnischejongens.nl/actueel/how-to-create-a-personal-azure-virtual-desktop-scaling-plan-with-terraform-using-azapi

param location string = 'westeurope'
param avdHostPoolId string // Dit is de ID van je AVD hostpool
param principalId string // Principal ID van de Windows Virtual Desktop App

// Stap 2: Definieer een aangepaste rol voor het schaalplan
resource scalerRole 'Microsoft.Authorization/roleDefinitions@2022-04-01' = {
  name: guid(subscription().id, 'SP-ROLE-AVD-W11-DEV-Personal')
  properties: {
    roleName: 'SP-ROLE-AVD-W11-DEV-Personal'
    description: 'AVD AutoScale Role'
    assignableScopes: [
      resourceGroup().id
    ]
    permissions: [
      {
        actions: [
          'Microsoft.Insights/eventtypes/values/read'
          'Microsoft.Compute/virtualMachines/deallocate/action'
          'Microsoft.Compute/virtualMachines/restart/action'
          'Microsoft.Compute/virtualMachines/powerOff/action'
          'Microsoft.Compute/virtualMachines/start/action'
          'Microsoft.Compute/virtualMachines/read'
          'Microsoft.DesktopVirtualization/hostpools/read'
          'Microsoft.DesktopVirtualization/hostpools/write'
          'Microsoft.DesktopVirtualization/hostpools/sessionhosts/read'
          'Microsoft.DesktopVirtualization/hostpools/sessionhosts/write'
          'Microsoft.DesktopVirtualization/hostpools/sessionhosts/usersessions/delete'
          'Microsoft.DesktopVirtualization/hostpools/sessionhosts/usersessions/read'
          'Microsoft.DesktopVirtualization/hostpools/sessionhosts/usersessions/sendMessage/action'
        ]
        notActions: []
      }
    ]
  }
}

// Role assignment voor de Windows Virtual Desktop App
resource roleAssignment 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: guid(resourceGroup().id, 'WVDRole')
  properties: {
    roleDefinitionId: scalerRole.id
    principalId: principalId
    principalType: 'ServicePrincipal'
  }
  scope: resourceGroup()
}

// Stap 3: Definieer het schaalplan voor persoonlijke hosts
resource personalScalingPlan 'Microsoft.DesktopVirtualization/scalingPlans@2023-11-01-preview' = {
  name: 'VDSCALING-AVD-W11-DEV-Personal'
  location: location
  properties: {
    description: 'VDSCALING-AVD-W11-DEV-Personal'
    exclusionTag: 'ExcludeFromScaling'
    friendlyName: 'VDSCALING-AVD-W11-DEV-Personal'
    hostPoolType: 'Personal'
    hostPoolReferences: [
      {
        hostPoolArmPath: avdHostPoolId
        scalingPlanEnabled: true
      }
    ]
    timeZone: 'W. Europe Standard Time'
  }
}

// Stap 4: Definieer het schema voor het schaalplan
resource scalingPlanPersonalSchedule 'Microsoft.DesktopVirtualization/scalingPlans/personalSchedules@2023-11-01-preview' = {
  name: 'Alldays'
  parent: personalScalingPlan
  properties: {
    daysOfWeek: [
      'Monday'
      'Tuesday'
      'Wednesday'
      'Thursday'
      'Friday'
      'Saturday'
      'Sunday'
    ]
    offPeakActionOnDisconnect: 'Deallocate'
    offPeakActionOnLogoff: 'Deallocate'
    offPeakMinutesToWaitOnDisconnect: 120
    offPeakMinutesToWaitOnLogoff: 60
    offPeakStartTime: {
      hour: 22
      minute: 0
    }
    offPeakStartVMOnConnect: 'Enable'
    peakActionOnDisconnect: 'Deallocate'
    peakActionOnLogoff: 'Deallocate'
    peakMinutesToWaitOnDisconnect: 120
    peakMinutesToWaitOnLogoff: 60
    peakStartTime: {
      hour: 9
      minute: 0
    }
    peakStartVMOnConnect: 'Enable'
    rampDownActionOnDisconnect: 'Deallocate'
    rampDownActionOnLogoff: 'Deallocate'
    rampDownMinutesToWaitOnDisconnect: 120
    rampDownMinutesToWaitOnLogoff: 60
    rampDownStartTime: {
      hour: 19
      minute: 0
    }
    rampDownStartVMOnConnect: 'Enable'
    rampUpActionOnDisconnect: 'Deallocate'
    rampUpActionOnLogoff: 'Deallocate'
    rampUpAutoStartHosts: 'None'
    rampUpMinutesToWaitOnDisconnect: 120
    rampUpMinutesToWaitOnLogoff: 60
    rampUpStartTime: {
      hour: 6
      minute: 0
    }
    rampUpStartVMOnConnect: 'Enable'
  }
}
