targetScope = 'managementGroup'
@description('Required. Provide a name for the subscription. This name will also be the display name of the subscription')
param subscriptionName string
@description('Required. The code of the environment this resource will be used in')
@maxLength(1)
param environmentName string
@description('Required. Index of the resource')
param index int
@description('Optional. The name to use if not using the normal naming convention')
param customName string = ''
@description('Required. Provide the customer ID to use for subscription creation')
param customerID string
@description('Required. Provide the billing account ID to use for subscription creation')
param billingAccountId string
@description('Optional. Provide the workload type')
@allowed([
  'Production'
  'DevTest'
])
param workload string = 'Production'
@description('Optional. Time parameter to create unique deployment. Do not set in parameter file!')
param time string = replace(utcNow(), ':', '-')

module Subscription 'br/BicepFeatures:subscription:v1.0.0' = {
  name: 'Subscription-${time}'
  params: {
    subscriptionName: subscriptionName
    environmentName: environmentName
    index: index
    customName: customName
    customerID: customerID
    billingAccountId: billingAccountId
    workload: workload
  }
}
@description('Name of the resource')
output resourceName string = Subscription.outputs.resourceName
@description('Name of the resource')
output resourceID string = Subscription.outputs.resourceID

