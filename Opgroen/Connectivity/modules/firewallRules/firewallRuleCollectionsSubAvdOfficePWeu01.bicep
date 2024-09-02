@description('Optional. Time parameter to create unique deployment. Do not set in parameter file!')
param time string = replace(utcNow(), ':', '-')

var rulecollections = loadJsonContent('../../configs/firewallRules/sub-avd-office-p-weu-01.json')

module subAvdOfficePWeu01RuleCollections '../../../Templates/Features/AzureFirewallRuleCollection/template.bicep' = {
  name: 'subAvdOfficePWeu01RuleCollections-${time}'
  params: {
    azureFirewallPolicyResourceName: rulecollections.azureFirewallPolicyResourceName
    priority: rulecollections.priority
    ruleCollectionGroupName: rulecollections.ruleCollectionGroupName
    ruleCollections: rulecollections.ruleCollections
  }
}
