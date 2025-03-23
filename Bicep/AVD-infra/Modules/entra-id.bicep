param entraAppName string

resource entraApp 'Microsoft.Applications/applications@2021-03-01' = {
  name: entraAppName
  properties: {
    displayName: entraAppName
    signInAudience: 'AzureADMyOrg'
  }
}

// Assign AVD Contributor role to the app
resource roleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(entraApp.id, 'AVD Contributor')
  properties: {
    principalId: entraApp.properties.appId
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', '1d18fff3-a72a-46b5-b4a9-0b38a3cd7e63') // AVD Contributor
  }
}
