@description('Optional. Time parameter to create unique deployment. Do not set in parameter file!')
param time string = replace(utcNow(), ':', '-')

var rulecollections = loadJsonContent('../../configs/firewallRules/sub-cfp-workload-p-weu-01.json')

module subCfpWorkloadPWeu01RuleCollections '../../../Templates/Features/AzureFirewallRuleCollection/template.bicep' = {
  name: 'subCfpWorkloadPWeu01RuleCollections-${time}'
  params: {
    azureFirewallPolicyResourceName: rulecollections.azureFirewallPolicyResourceName
    priority: rulecollections.priority
    ruleCollectionGroupName: rulecollections.ruleCollectionGroupName
    ruleCollections: rulecollections.ruleCollections
  }
}
