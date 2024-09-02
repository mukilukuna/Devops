targetScope = 'subscription'

@description('Required. The resourceID of the Log Analytics Workspace')
param logAnalyticsResourceID string

@description('Optional. Whether Autoprovisioning is turned on for Microsoft Defender for Cloud')
@allowed([
  'On'
  'Off'
])
param azureSecurityCenterAutoprovisioning string = 'On'

@description('Optional. Whether to send security alerts notifications to the security contact')
@allowed([
  'On'
  'Off'
])
param alertNotifications string = 'On'

@description('Optional. Defines the minimal alert severity which will be sent as email notifications')
@allowed([
  'High'
  'Low'
  'Medium'
])
param minimalSeverity string = 'Low'

@description('Optional. Defines whether to send email notifications from AMicrosoft Defender for Cloud to persons with specific RBAC roles on the subscription')
@allowed([
  'On'
  'Off'
])
param notificationsByRole string = 'Off'

@description('Optional. Defines which RBAC roles will get email notifications from Microsoft Defender for Cloud. List of allowed RBAC roles:')
param notificationsRoles array = [ 'Owner', 'Contributor' ]

@description('Optional. The email of this security contact')
param email string = ''

@description('Optional. The phone number of this security contact')
param phone string = ''

var subInfo = subscription()

resource autoProvisioning 'Microsoft.Security/autoProvisioningSettings@2017-08-01-preview' = {
  name: 'default'
  properties: {
    autoProvision: azureSecurityCenterAutoprovisioning
  }
}

resource securityContact 'Microsoft.Security/securityContacts@2020-01-01-preview' = {
  name: 'default'
  properties: {
    alertNotifications: {
      state: alertNotifications
      minimalSeverity: minimalSeverity
    }
    notificationsByRole: {
      roles: notificationsRoles
      state: notificationsByRole
    }
    emails: email
    phone: phone
  }
}

resource workSpaceSettings 'Microsoft.Security/workspaceSettings@2017-08-01-preview' = {
  name: 'default'
  properties: {
    workspaceId: logAnalyticsResourceID
    scope: subscription().id
  }
}

@description('Target Subscription')
output resourceName string = subInfo.displayName

@description('Target Subscription-id')
output resourceId string = subInfo.subscriptionId
