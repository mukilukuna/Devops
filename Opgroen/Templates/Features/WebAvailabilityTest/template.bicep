@description('Required. ID of the action group resource')
param actionGroupId string

@description('Required. ID of the application insights resource to link to')
param appInsightsId string

@description('Required. Tests and alerts that will be created')
param tests object

@description('Optional. Location of the resource')
param location string = resourceGroup().location

@description('Optional. Tags of the resource')
param tags object = {}

var tagVar = {
  'hidden-link:${appInsightsId}': 'Resource'
}

resource webAppTest 'Microsoft.Insights/webtests@2018-05-01-preview' = {
  name: tests.name
  location: location
  tags: union(tags, tagVar)
  properties: {
    Name: tests.name
    Description: tests.description
    Enabled: tests.enabled
    Frequency: tests.frequency
    Timeout: tests.timeout
    Kind: tests.kind
    RetryEnabled: tests.retryEnabled
    Locations: tests.locations
    Configuration: {
      WebTest: '<WebTest Name="${tests.name}"   Enabled="True" CssProjectStructure="" CssIteration="" Timeout="${tests.timeout}" WorkItemIds="" xmlns="http://microsoft.com/schemas/VisualStudio/TeamTest/2010" Description="" CredentialUserName="" CredentialPassword="" PreAuthenticate="True" Proxy="default" StopOnError="False" RecordedResultFile="" ResultsLocale=""> <Items> <Request Method="GET" Version="1.1" Url="${tests.url}" ThinkTime="0" Timeout="${tests.timeout}" ParseDependentRequests="${tests.parseDependentRequests}" FollowRedirects="True" RecordResult="True" Cache="False" ResponseTimeGoal="0" Encoding="utf-8" ExpectedHttpStatusCode="200" ExpectedResponseUrl="" ReportingName="" IgnoreHttpStatusCode="False" /> </Items> <ValidationRules> <ValidationRule  Classname="Microsoft.VisualStudio.TestTools.WebTesting.Rules.ValidationRuleFindText, Microsoft.VisualStudio.QualityTools.WebTestFramework, Version=10.0.0.0, Culture=neutral, PublicKeyToken=b03f5f7f11d50a3a" DisplayName="Find Text" Description="Verifies the existence of the specified text in the response." Level="High" ExecutionOrder="BeforeDependents">  <RuleParameters> <RuleParameter Name="FindText" Value="${tests.bodyContent}" />  <RuleParameter Name="IgnoreCase" Value="False" />  <RuleParameter Name="UseRegularExpression" Value="False" />  <RuleParameter Name="PassIfTextFound" Value="True" />  </RuleParameters> </ValidationRule>  </ValidationRules>  </WebTest>'
    }
    SyntheticMonitorId: tests.name
  }
}

resource metricAlerts 'Microsoft.Insights/metricAlerts@2018-03-01' = {
  name: tests.name
  location: 'global'
  tags: {
    'hidden-link:${appInsightsId}': 'Resource'
    'hidden-link:${resourceId('Microsoft.Insights/webtests', tests.name)}': 'Resource'
  }
  properties: {
    description: tests.alertDescription
    severity: tests.alertSeverity
    enabled: tests.alertEnabled
    scopes: [
      resourceId('Microsoft.Insights/webtests', tests.name)
      appInsightsId
    ]
    evaluationFrequency: tests.alertEvaluationFrequency
    windowSize: tests.alertPeriod
    criteria: {
      'odata.type': 'Microsoft.Azure.Monitor.WebtestLocationAvailabilityCriteria'
      webTestId: resourceId('Microsoft.Insights/webtests', tests.name)
      componentId: appInsightsId
      failedLocationCount: tests.alertLocationTreshhold
    }
    actions: [
      {
        actionGroupId: actionGroupId
      }
    ]
  }
  dependsOn: [
    webAppTest
  ]
}

@description('Name of the resource')
output resourceName string = webAppTest.name
@description('ID of the resource')
output resourceID string = webAppTest.id
