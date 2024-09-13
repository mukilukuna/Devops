targetScope = 'resourceGroup'

@description('Optional. Time parameter to create unique deployment. Do not set in parameter file!')
param time string = replace(utcNow(), ':', '-')

@description('JSON configuration object for bicep deployments')
var subscriptionConfig = loadJsonContent('../../configs/subscriptionConfig.jsonc')
var tags = subscriptionConfig.Governance.tags

var azureFirewallWorkbookConfig = loadJsonContent('../../configs/workbooks/azureFirewallWorkbook.json')
var workbookDefenderActiveAlertsWorkbookConfig = loadJsonContent('../../configs/workbooks/workbookDefenderActiveAlerts.json')
var workbookDefenderComplianceOverTimeWorkbookConfig = loadJsonContent('../../configs/workbooks/workbookDefenderComplianceOverTime.json')
var workbookDefenderCoverageWorkbookConfig = loadJsonContent('../../configs/workbooks/workbookDefenderCoverage.json')

@description('Location of the resource group')
var location = subscriptionConfig.Governance.location

module resourceGroupConnectivityLock '../../../Templates/Features/ResourceGroupLock/template.bicep' = {
  name: 'resourceGroupConnectivityLock-${time}'
  params: {
    level: 'CanNotDelete'
  }
}

module azureMonitorWorkbook '../../../Templates/Features/AzureMonitorWorkbook/template.bicep' = {
  name: 'azureMonitorWorkbook-${time}'
  params: {
    customName: 'wb-infr-firewall-p-weu-01'
    galleries: azureFirewallWorkbookConfig.galleries
    templateData: azureFirewallWorkbookConfig.templateData
    location: location
    tags: tags
  }
}

module workbookDefenderActiveAlertsWorkbook '../../../Templates/Features/AzureMonitorWorkbook/template.bicep' = {
  name: 'workbookDefenderActiveAlertsWorkbook-${time}'
  params: {
    customName: 'wb-infr-activealerts-p-weu-01'
    galleries: workbookDefenderActiveAlertsWorkbookConfig.galleries
    templateData: workbookDefenderActiveAlertsWorkbookConfig.templateData
    location: location
    tags: tags
  }
}

module workbookDefenderComplianceOverTimeWorkbook '../../../Templates/Features/AzureMonitorWorkbook/template.bicep' = {
  name: 'workbookDefenderComplianceOverTimeWorkbook-${time}'
  params: {
    customName: 'wb-infr-complianceovertime-p-weu-01'
    galleries: workbookDefenderComplianceOverTimeWorkbookConfig.galleries
    templateData: workbookDefenderComplianceOverTimeWorkbookConfig.templateData
    location: location
    tags: tags
  }
}

module workbookDefenderCoverageWorkbook '../../../Templates/Features/AzureMonitorWorkbook/template.bicep' = {
  name: 'workbookDefenderCoverageWorkbook-${time}'
  params: {
    customName: 'wb-infr-defendercoverage-p-weu-01'
    galleries: workbookDefenderCoverageWorkbookConfig.galleries
    templateData: workbookDefenderCoverageWorkbookConfig.templateData
    location: location
    tags: tags
  }
}

@description('ID of the resource')
output azureMonitorWorkbook_ResourceId string = azureMonitorWorkbook.outputs.resourceID
@description('Name of the resource')
output azureMonitorWorkbook_ResourceName string = azureMonitorWorkbook.outputs.resourceName
