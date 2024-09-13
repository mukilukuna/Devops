@description('Required. The name of the workload this resource will be used for')
param workloadName string

@description('Required. The name of the application')
param applicationName string

@description('Required. The code of the environment this resource will be used in')
@maxLength(1)
param environmentName string

@description('Required. Region of the resource')
@maxLength(4)
param regionName string

@description('Required. Index of the resource')
param index int

@description('Optional. The name to use if not using the normal naming convention')
param customName string = ''

@description('Optional. Resource Tags')
param tags object = {}

@description('Optional. Describes if the policy is in enabled or disabled state')
@allowed([
  'Enabled'
  'Disabled'
])
param enabledState string = 'Enabled'

@description('Optional. Describes if it is in detection mode or prevention mode at policy level')
@allowed([
  'Prevention'
  'Detection'
])
param mode string = 'Prevention'

@description('Optional. If action type is redirect, this field represents redirect URL for the client')
param redirectUrl string = ''

@description('Optional. If the action type is block, customer can override the response status code')
param customBlockResponseStatusCode int = 0

@description('Optional. If the action type is block, customer can override the response body. The body must be specified in base64 encoding')
param customBlockResponseBody string = ''

@description('Optional. List of custom rules')
param customRules array = []

@description('Optional. List of managed rules')
param managedRules array = []

@description('Optional. Array of Role Assignments to deploy')
param permissions array = []

var nameVar = toLower('fdfp${workloadName}${applicationName}${environmentName}${regionName}${padLeft(index, 2, '0')}')

resource frontdoorWafPolicy 'Microsoft.Network/FrontDoorWebApplicationFirewallPolicies@2020-11-01' = {
  name: empty(customName) ? nameVar : customName
  tags: tags
  location: 'Global'
  properties: {
    policySettings: {
      enabledState: enabledState
      mode: mode
      redirectUrl: empty(redirectUrl) ? null : redirectUrl
      customBlockResponseStatusCode: customBlockResponseStatusCode == 0 ? null : customBlockResponseStatusCode
      customBlockResponseBody: empty(customBlockResponseBody) ? null : customBlockResponseBody
    }
    customRules: {
      rules: customRules
    }
    managedRules: {
      managedRuleSets: managedRules
    }
  }
}

resource roleAssignments 'Microsoft.Authorization/roleAssignments@2022-01-01-preview' = [for item in permissions: {
  name: guid(resourceGroup().id, item.name, item.roleDefinitionId)
  scope: frontdoorWafPolicy
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
output resourceName string = frontdoorWafPolicy.name
@description('The resource-id of the Azure resource')
output resourceID string = frontdoorWafPolicy.id
