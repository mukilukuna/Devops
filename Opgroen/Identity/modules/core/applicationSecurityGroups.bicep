targetScope = 'resourceGroup'

@description('Optional. Time parameter to create unique deployment. Do not set in parameter file!')
param time string = replace(utcNow(), ':', '-')

@description('JSON configuration object for bicep deployments')
var subscriptionConfig = loadJsonContent('../../configs/subscriptionConfig.jsonc')

@description('Location of the resource group')
var location = subscriptionConfig.Governance.location

module asgAddcServers '../../../Templates/Features/ApplicationSecurityGroup/template.bicep' = {
  name: 'asgAddc-${time}'
  params: {
    workloadName: ''
    regionName: ''
    applicationSecurityGroups: [
      {
        customName: 'asg-infr-addc-p-weu-01'
      }
    ]
    location: location
  }
}

@description('ID of the resource')
output applicationSecurityGroupADDC_ResourceId string = asgAddcServers.outputs.resourceID[0]
@description('Name of the resource')
output appplicationSecurityGroupADDC_ResourceName string = asgAddcServers.outputs.resourceName[0]
