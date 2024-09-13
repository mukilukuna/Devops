targetScope = 'subscription'

@description('Required. Name of the Budget. It should be unique within a resource group')
param name string

@description('Optional. The total amount of cost or usage to track with the budget')
param amount int = 1000

@description('Optional. The time covered by a budget. Tracking of the amount will be reset based on the time grain')
@allowed([
  'Annually'
  'BillingAnnual'
  'BillingMonth'
  'BillingQuarter'
  'Monthly'
  'Quarterly'
])
param timeGrain string = 'Monthly'

@description('Required. The start date must be first of the month in YYYY-MM-DD format. Future start date should not be more than three months. Past start date should be selected within the timegrain preiod')
param startDate string = '${utcNow('yyyy/MM')}/01'

@description('Optional. The end date for the budget in YYYY-MM-DD format. If not provided, we default this to 10 years from the start date')
param endDate string = ''

@description('Optional. The operator field for treshhold comparison')
param operator string = 'GreaterThan'

@description('actualThreshhold')
param threshold int = 90

@description('forecast Threshhold')
param forecastThreshold int = 120

@description('The list of email addresses to send the budget notification to when the threshold is exceeded.')
param contactEmails array

@description('The list of Roles to send the budget notification to when the threshold is exceeded.')
param contactRoles array = []

@description('The list of Action Groups to send the budget notification to when the threshold is exceeded.')
param contactGroups array = []

resource budget 'Microsoft.Consumption/budgets@2021-10-01' = {
  name: name
  properties: {
    category: 'Cost'
    amount: amount
    timeGrain: timeGrain
    timePeriod: {
      startDate: startDate
      endDate: endDate
    }
    notifications: {
      actual_threshold: {
        enabled: true
        operator: operator
        threshold: threshold
        contactEmails: empty(contactEmails) ? [] : contactEmails
        contactRoles: empty(contactRoles) ? [] : contactRoles
        contactGroups: empty(contactGroups) ? [] : contactGroups
        thresholdType: 'Actual'
      }
      forecasted_threshold: {
        enabled: true
        operator: operator
        threshold: forecastThreshold
        contactEmails: empty(contactEmails) ? [] : contactEmails
        contactRoles: empty(contactRoles) ? [] : contactRoles
        contactGroups: empty(contactGroups) ? [] : contactGroups
        thresholdType: 'Forecasted'
      }
    }
  }
}
@description('The name of the budget')
output resourceName string = budget.name

@description('The resource-id of the budget')
output resourceID string = budget.id
