targetScope = 'resourceGroup'

@description('Optional. Time parameter to create unique deployment. Do not set in parameter file!')
param time string = replace(utcNow(), ':', '-')

@description('JSON configuration object for bicep deployments')
var subscriptionConfig = loadJsonContent('../../configs/subscriptionConfig.jsonc')

@description('Location of the resource group')
var location = subscriptionConfig.Governance.location

module asgNpmServers '../../../Templates/Features/ApplicationSecurityGroup/template.bicep' = {
  name: 'asgNpm-${time}'
  params: {
    workloadName: ''
    regionName: ''
    applicationSecurityGroups: [
      {
        customName: 'asg-infr-npm-p-weu-01'
      }
    ]
    location: location
  }
}

@description('ID of the resource')
output applicationSecurityGroupNpm_ResourceId string = asgNpmServers.outputs.resourceID[0]
@description('Name of the resource')
output applicationSecurityGroupNpm_ResourceName string = asgNpmServers.outputs.resourceName[0]
