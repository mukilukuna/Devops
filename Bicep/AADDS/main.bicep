module domainServices 'br/public:avm/res/aad/domain-service:0.3.2' = {
  name: 'domainServices'
  params: {
    domainName: 'Lukunait.com'
     ]
    diagnosticSettings: [
      {
        eventHubAuthorizationRuleResourceId: '<eventHubAuthorizationRuleResourceId>'
        eventHubName: '<eventHubName>'
        logCategoriesAndGroups: [
          {
            categoryGroup: 'allLogs'
          }
        ]
        metricCategories: [
          {
            category: 'AllMetrics'
          }
        ]
        name: 'customSetting'
        storageAccountResourceId: '<storageAccountResourceId>'
        workspaceResourceId: '<workspaceResourceId>'
      }
    ]
    externalAccess: 'Enabled'
    ldaps: 'Enabled'
    location: '<location>'
    lock: {
      kind: 'None'
      name: 'myCustomLockName'
    }
    name: 'aaddswaf001'
    pfxCertificate: '<pfxCertificate>'
    pfxCertificatePassword: '<pfxCertificatePassword>'
    replicaSets: [
      {
        location: 'NorthEurope'
        subnetId: '<subnetId>'
      }
    ]
    sku: 'Standard'
    tags: {
      Environment: 'Non-Prod'
      'hidden-title': 'This is visible in the resource name'
      Role: 'DeploymentValidation'
    }
  }
}
