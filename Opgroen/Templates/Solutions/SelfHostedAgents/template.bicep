@description('Required. The name of the application')
param applicationName string
@description('Required. The code of the environment this resource will be used in')
@maxLength(1)
param environmentName string
@description('Required. Workload name of the resource')
param workloadName string
@description('Required. Region of the resource')
@maxLength(4)
param regionName string
@description('Required. The index of the resource')
param index int
@description('Optional. The name to use if not using the normal naming convention')
param customName string = ''
@description('Optional. Resource tags')
param tags object = {}
@description('Required. The containers within the container group')
param containers int
@description('Required. The image for the containers')
param image string
@description('Optional. The amount of CPU(s) to assign to the container(s)')
param cpuCount int = 1
@description('Optional. The amount of memory to assign to the container(s)')
param memoryInGb string = '3.5'
@description('Required. DNS configuration for the container group')
param dnsConfig object
@description('Required. Deploy managed identity')
param assignManagedIdentity bool = false
@description('Required. DevOps PAT for the project to deploy the agent pools')
@secure()
param devOpsPAT string
@description('Required. The pool in which the agent(s) should join')
param agentPool string
@description('Required. Name of the organization (https://dev.azure.com/<organizationName>)')
param organizationName string
@description('Required. Name of the subnet for the ACI')
param subnetName string
@description('Optional. The restart policy for a container (Always, OnFailure, Never)')
@allowed([
  'Always'
  'OnFailure'
  'Never'
])
param restartPolicy string = 'Always'
@description('Required. The resource ID of the virtual network')
param vnetResourceId string
@description('Optional. Location of the resource')
param location string = resourceGroup().location
@description('Optional. Diagnostic settings configuration')
param diagnosticSettings array = []
@description('Optional. Time parameter to create unique deployment. Do not set in parameter file!')
param time string = replace(utcNow(), ':', '-')

module SelfHostedAgents 'br/BicepSolutions:selfhostedagents:v2.0.1' = {
  name: 'SelfHostedAgents-${time}'
  params: {
    applicationName: applicationName
    environmentName: environmentName
    workloadName: workloadName
    regionName: regionName
    index: index
    customName: customName
    tags: tags
    containers: containers
    image: image
    cpuCount: cpuCount
    memoryInGb: memoryInGb
    dnsConfig: dnsConfig
    assignManagedIdentity: assignManagedIdentity
    devOpsPAT: devOpsPAT
    agentPool: agentPool
    organizationName: organizationName
    subnetName: subnetName
    restartPolicy: restartPolicy
    vnetResourceId: vnetResourceId
    location: location
    diagnosticSettings: diagnosticSettings
  }
}
@description('The resource-ID of the Azure resource')
output resourceID string = SelfHostedAgents.outputs.resourceID
@description('The name of the Azure resource')
output resourceName string = SelfHostedAgents.outputs.resourceName

