@description('Optional. Time parameter to create unique deployment. Do not set in parameter file!')
param time string = replace(utcNow(), ':', '-')

var rulecollections = loadJsonContent('../../configs/firewallRules/sub-ccs-workload-p-weu-01.json')

module subCcsWorkloadPWeu01RuleCollections '../../../Templates/Features/AzureFirewallRuleCollection/template.bicep' = {
  name: 'subCcsWorkloadPWeu01RuleCollections-${time}'
  params: {
    azureFirewallPolicyResourceName: rulecollections.azureFirewallPolicyResourceName
    priority: rulecollections.priority
    ruleCollectionGroupName: rulecollections.ruleCollectionGroupName
    ruleCollections: rulecollections.ruleCollections
  }
}
