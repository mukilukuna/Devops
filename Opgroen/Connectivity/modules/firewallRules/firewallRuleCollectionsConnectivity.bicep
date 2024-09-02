@description('Optional. Time parameter to create unique deployment. Do not set in parameter file!')
param time string = replace(utcNow(), ':', '-')

var rulecollections = loadJsonContent('../../configs/firewallRules/platformConnectivity.json')

module connectivityRuleCollections '../../../Templates/Features/AzureFirewallRuleCollection/template.bicep' = {
  name: 'connectivityRuleCollections-${time}'
  params: {
    azureFirewallPolicyResourceName: rulecollections.azureFirewallPolicyResourceName
    priority: rulecollections.priority
    ruleCollectionGroupName: rulecollections.ruleCollectionGroupName
    ruleCollections: rulecollections.ruleCollections
  }
}
