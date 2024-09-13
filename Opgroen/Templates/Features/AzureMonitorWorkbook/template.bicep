@description('Required. The name to use if not using the normal naming convention. In this case there is no naming convention')
param customName string

@description('Optional. Resource tags')
param tags object = {}

@description('Required. Workbook galleries supported by the template')
param galleries array

@description('Required. Object describing the actual workbook')
param templateData object

@description('Optional. Location of the resource')
param location string = resourceGroup().location

resource WorkbookTemplates 'Microsoft.Insights/WorkbookTemplates@2020-11-20' = {
  name: customName
  location: location
  tags: tags
  properties: {
    galleries: galleries
    templateData: templateData
  }
}

@description('The name of the Azure resource')
output resourceID string = WorkbookTemplates.id
@description('The resource-id of the Azure resource')
output resourceName string = WorkbookTemplates.name
