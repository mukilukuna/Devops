@description('Required. The name of the workload this resource will be used for')
param workloadName string

@description('Required. The region this resource will be deployed in')
@maxLength(4)
param regionName string

@description('Optional. Location of the resource')
param location string = resourceGroup().location

@description('Required. The names of the application security groups')
param applicationSecurityGroups array

var applicationSecurityGroupName = [for item in applicationSecurityGroups: contains(item, 'customName') ? item.customName : toLower('asg-${workloadName}-${item.applicationName}-${item.environmentName}-${regionName}')]
var applicationSecurityGroupResourceId = [for (item, i) in applicationSecurityGroups: resourceId('Microsoft.Network/applicationSecurityGroups', applicationSecurityGroupName[i])]

resource AppSecGroup 'Microsoft.Network/applicationSecurityGroups@2021-12-01' = [for (item, i) in applicationSecurityGroups: {
  name: applicationSecurityGroupName[i]
  tags: contains(item, 'tags') ? item.tags : null
  location: location
}]

@description('The name of the Azure resource')
output resourceName array = applicationSecurityGroupName
@description('The resource-id of the Azure resource')
output resourceID array = applicationSecurityGroupResourceId
