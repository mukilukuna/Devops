param owner string
param costCenter string
param application string
param desc string
param repo string

param tags object = {
  owner: owner
  costCenter: costCenter
  application: application
  description: desc
  repository: repo
}

param appShort string
param domainShort string
param enviroment string
param version string

@description('locatie van de loganalytics resource')
param location string = resourceGroup().location

@description('naam van de loganalytics Workspace')
param loganalyticsWSName string = 'lg-${domainShort}-${appShort}-${enviroment}-${version}'

@description('RetentionInDays')
param RetentionInDays int = 30

@description('Log analytics SKU')
param sku string = 'PerGB2018'

@description('publicNetworkAccessforIngestion')
param publicNetworkAccessforIngestion string = 'Enabled'

@description('publicNetworkAccessforQuery')
param publicNetworkAccessforQuery string = 'Enabled'
