@description('Required. The name of the application')
param applicationName string

@description('Required. The code of the environment this resource will be used in')
@maxLength(1)
param environmentName string

@description('Required. The name of the workload this resource will be used for')
param workloadName string

@description('Required. Region of the resource')
@maxLength(4)
param regionName string

@description('Required. Index of the resource')
param index int

@description('Optional. The name to use if not using the normal naming convention')
param customName string = ''

@description('Optional. Resource Tags')
param tags object = {}

@description('Optional. Location of the Application Gateway')
param location string = resourceGroup().location

@description('Optional. Array of Role Assignments to deploy')
param permissions array = []

@allowed([
  'Enabled'
  'Disabled'
])
@description('Optional. Describes if the policy is in enabled or disabled state')
param enabledState string = 'Enabled'

@description('Optional. The mode of the policy')
@allowed([
  'Prevention'
  'Detection'
])
param mode string = 'Prevention'

@description('Optional. Whether to allow WAF to check request Body')
param requestBodyCheck bool = true

@description('Optional. Maximum file upload size in Mb for WAF')
param fileUploadLimitInMb int = 100

@description('Optional. Maximum request body size in Kb for WAF')
param maxRequestBodySizeInKb int = 128

@description('Optional. List of custom rules')
param customRules array = []

@description('Optional. List of managed rules')
param managedRules array = []

var nameVar = toLower('agwfp-${workloadName}-${applicationName}-${environmentName}-${regionName}-${padLeft(index, 2, '0')}')

resource applicationGatewayWafPolicy 'Microsoft.Network/applicationGatewayWebApplicationFirewallPolicies@2021-12-01' = {
  name: empty(customName) ? nameVar : customName
  tags: tags
  location: location
  properties: {
    policySettings: {
      state: enabledState
      mode: mode
      requestBodyCheck: requestBodyCheck
      fileUploadLimitInMb: fileUploadLimitInMb
      maxRequestBodySizeInKb: maxRequestBodySizeInKb
    }
    customRules: customRules
    managedRules: {
      managedRuleSets: managedRules
    }
  }
}

resource roleAssignments 'Microsoft.Authorization/roleAssignments@2022-01-01-preview' = [for item in permissions: {
  name: guid(resourceGroup().id, item.name, item.roleDefinitionId)
  scope: applicationGatewayWafPolicy
  properties: {
    principalId: item.principalId
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', item.roleDefinitionId)
    condition: contains(item, 'condition') && item.condition != '' ? item.condition : null
    conditionVersion: contains(item, 'conditionVersion') && item.conditionVersion != '' ? item.conditionVersion : null
    delegatedManagedIdentityResourceId: contains(item, 'delegatedManagedIdentityResourceId') && item.delegatedManagedIdentityResourceId != '' ? item.delegatedManagedIdentityResourceId : null
    description: item.description
    principalType: item.principalType
  }
}]

@description('The name of the Azure resource')
output resourceName string = applicationGatewayWafPolicy.name
@description('The resource-id of the Azure resource')
output resourceID string = applicationGatewayWafPolicy.id
