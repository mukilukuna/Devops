@description('Required. The name of the WebApp.')
param webAppName string

@description('Required. The name of the WebApp Deployment slot.')
param webAppSlotName string

@description('Optional. Object containing the tags to apply to all resources.')
param tags object = {}

@description('Required. The ID of the app service plan to use.')
param appServicePlanId string

@description('Optional. False to stop sending session affinity cookies, which route client requests in the same session to the same instance.')
param useClientSessionAffinityCookies bool = false

@description('Optional. true to enable client certificate authentication (TLS mutual authentication); otherwise, false.')
param useClientAuthenticationCertificate bool = false

@description('Optional. configures a web site to accept only HTTPS requests. Issues redirect for HTTP requests.')
param webAppHttpsOnly bool = true

@description('Optional. Set to amount of instances the webApp should be configured to scale.')
param numberOfWorkers int = 1

@description('Optional. WebApp Application Settings.')
param appSettings array = []

@description('Optional. Enter the connection string(s).')
param connectionString array = []

@description('Optional. Use 32 Bit workerprocess if true, if false use 64-bit worker process.')
param use32BitWorkerProcess bool = false

@description('Optional. Enable Web Socket support for ASP.NET/NodeJS.')
param webSocketsEnabled bool = false

@description('Optional. WebApp Always On or Off, keep the app loaded even when there\'s no traffic. It\'s required for continuous WebJobs or for WebJobs that are triggered using a CRON expression.')
param alwaysOn bool = true

@description('Optional. Managed service identity')
param enableManagedIdentity bool = true

@description('Optional. This property specifies whether the request-processing pipeline mode is Integrated or Classic..')
@allowed([
  'Integrated'
  'Classic'
])
param managedPipelineMode string = 'Integrated'

@description('Optional. Site Load balancing mode.')
@allowed([
  'WeightedRoundRobin'
  'LeastRequests'
  'LeastResponseTime'
  'WeightedTotalTraffic'
  'RequestHash'
])
param loadBalancingMode string = 'WeightedRoundRobin'

@description('Optional. The IP restrictions of the WebApp.')
param webAppIPRestrictions array = []

@description('Optional. The IP restrictions of the WebApp.')
param webAppScmIpRestrictions array = []

@description('Optional. WebApp SCM site uses same rules as WebApp itself.')
param webAppScmIpRestrictionsUseMainRestrictions bool = false

@description('Required. Http2.0Enabled: configures a web site to allow clients to connect over http2.0.')
param enableHTTP2 bool = true

@description('Optional. Health check path')
param healthCheckPath string = ''

@description('Optional. MinTlsVersion: configures the minimum version of TLS required for SSL requests.')
@allowed([
  '1.2'
  '1.1'
  '1.0'
])
param minTlsVersion string = '1.2'

@description('Optional. State of FTP / FTPS service.')
@allowed([
  'FtpsOnly'
  'Disabled'
  'AllAllowed'
])
param ftpsState string = 'FtpsOnly'

@description('Optional. .NET Framework version.')
param netFrameworkVersion string = 'v6.0'

@description('Optional. Version of PHP.')
param phpVersion string = '7.4'

@description('Optional. Version of Python.')
param pythonVersion string = ''

@description('Optional. Version of Node.js.')
param nodeVersion string = ''

@description('Optional. Linux App Framework and version.')
param linuxFxVersion string = ''

@description('Optional. Xenon App Framework and version.')
param windowsFxVersion string = ''

@description('Optional. Java version.')
param javaVersion string = ''

@description('Optional. Java container.')
param javaContainer string = ''

@description('Optional. Java container version.')
param javaContainerVersion string = ''

@description('Optional. Resource ID of the virtual network integration subnet.')
param subNetId string = ''

@description('Optional. Deploys the site extensions for AI.')
param deploySiteExtension bool = false

@description('Optional. Array of certificate objects.')
param webAppCertificates array = []

@description('Optional. Array of Hostname objects, containing the names and hostnames Azure App Managed Certificates must be requested for.')
param freeCertificates array = []

@description('Optional. Array of hostnamebinding objects, containing the hostnames and the certificatenames to bind.')
param hostNames array = []

@description('Optional. Diagnostic settings configuration.')
param diagnosticSettings array = []

@description('Optional. Location of the resource.')
param location string = resourceGroup().location

@description('Optional. Array of Role Assignments to deploy')
param permissions array = []

resource webApp 'Microsoft.Web/sites@2021-02-01' existing = {
  name: webAppName
}

resource webAppSlot 'Microsoft.Web/sites/slots@2021-02-01' = {
  name: webAppSlotName
  parent: webApp
  location: location
  identity: enableManagedIdentity ? {
    type: 'SystemAssigned'
  } : null
  tags: tags
  properties: {
    enabled: true
    serverFarmId: appServicePlanId
    clientAffinityEnabled: useClientSessionAffinityCookies
    clientCertEnabled: useClientAuthenticationCertificate
    httpsOnly: webAppHttpsOnly
    siteConfig: {
      numberOfWorkers: numberOfWorkers
      appSettings: appSettings
      connectionStrings: connectionString
      use32BitWorkerProcess: use32BitWorkerProcess
      webSocketsEnabled: webSocketsEnabled
      alwaysOn: alwaysOn
      managedPipelineMode: managedPipelineMode
      loadBalancing: loadBalancingMode
      ipSecurityRestrictions: webAppIPRestrictions
      scmIpSecurityRestrictions: webAppScmIpRestrictions
      scmIpSecurityRestrictionsUseMain: webAppScmIpRestrictionsUseMainRestrictions
      http20Enabled: enableHTTP2
      minTlsVersion: minTlsVersion
      ftpsState: ftpsState
      healthCheckPath: healthCheckPath
      netFrameworkVersion: empty(netFrameworkVersion) ? null : netFrameworkVersion
      phpVersion: empty(phpVersion) ? null : phpVersion
      pythonVersion: empty(pythonVersion) ? null : pythonVersion
      nodeVersion: empty(nodeVersion) ? null : nodeVersion
      linuxFxVersion: empty(linuxFxVersion) ? null : linuxFxVersion
      windowsFxVersion: empty(windowsFxVersion) ? null : windowsFxVersion
      javaVersion: empty(javaVersion) ? null : javaVersion
      javaContainer: empty(javaContainer) ? null : javaContainer
      javaContainerVersion: empty(javaContainerVersion) ? null : javaContainerVersion
    }
  }

  resource webAppSlot_virtualNetwork 'networkconfig@2021-02-01' = if (!empty(subNetId)) {
    name: 'virtualNetwork'
    properties: {
      subnetResourceId: empty(subNetId) ? null : subNetId
      swiftSupported: true
    }
  }

  resource webAppSlot_siteExtension 'siteExtensions@2021-02-01' = if (deploySiteExtension) {
    name: 'Microsoft.ApplicationInsights.AzureWebSites'
  }
}

resource webAppSlot_certificates 'Microsoft.Web/certificates@2021-02-01' = [for cert in webAppCertificates: if (length(webAppCertificates) != 0) {
  name: empty(webAppCertificates) ? 'empty' : cert.name
  location: location
  tags: tags
  properties: {
    keyVaultId: contains(cert, 'keyVaultId') ? cert.keyVaultId : null
    keyVaultSecretName: contains(cert, 'keyVaultSecretName') ? cert.keyVaultSecretName : null
    password: contains(cert, 'password') ? cert.password : null
    hostNames: contains(cert, 'hostNames') ? cert.hostNames : null
    serverFarmId: appServicePlanId
  }
}]

resource webAppSlot_freeCertificates 'Microsoft.Web/certificates@2021-02-01' = [for cert in freeCertificates: if (length(freeCertificates) != 0) {
  name: empty(freeCertificates) ? 'empty1' : cert.name
  tags: tags
  location: location
  properties: {
    serverFarmId: appServicePlanId
    hostNames: cert.hostNames
    canonicalName: cert.canonicalName
  }
}]

resource webAppSlot_hostnameBinding 'Microsoft.Web/sites/slots/hostnameBindings@2021-02-01' = [for hostname in hostNames: if (length(hostNames) != 0) {
  name: hostname.hostName
  parent: webAppSlot
  properties: {
    sslState: 'SniEnabled'
    thumbprint: length(hostNames) != 0 ? reference(resourceId('Microsoft.Web/certificates', hostname.name), '2019-08-01').Thumbprint : null
  }
}]

resource diagSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = [for diag in diagnosticSettings: if (!empty(diagnosticSettings)) {
  name: diag.name
  scope: webAppSlot
  properties: {
    workspaceId: contains(diag, 'workspaceId') ? diag.workspaceId : null
    storageAccountId: contains(diag, 'diagnosticsStorageAccountId') ? diag.diagnosticsStorageAccountId : null
    logs: contains(diag, 'logs') ? diag.logs : null
    metrics: contains(diag, 'metrics') ? diag.metrics : null
  }
}]

resource roleAssignments 'Microsoft.Authorization/roleAssignments@2022-01-01-preview' = [for item in permissions: {
  name: guid(resourceGroup().id, item.name, item.roleDefinitionId)
  scope: webAppSlot
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
output resourceName string = webAppSlot.name
@description('The resource-id of the Azure resource')
output resourceID string = webAppSlot.id
