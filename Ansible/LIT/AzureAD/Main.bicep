@description('The display name of the security group')
param group1Name string = 'Security Group 1'

@description('The display name of the second security group')
param group2Name string = 'Security Group 2'

@description('The display name of the third security group')
param group3Name string = 'Security Group 3'

resource securityGroup1 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: guid(group1Name)
  properties: {

    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', '{roleDefinitionId}')
    principalId: '{principalId}'
    principalType: 'Group'
  }
}

resource securityGroup2 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: guid(group2Name)
  properties: {

    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', '{roleDefinitionId}')
    principalId: '{principalId}'
    principalType: 'Group'
  }
}

resource securityGroup3 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: guid(group3Name)
  properties: {

    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', '{roleDefinitionId}')
    principalId: '{principalId}'
    principalType: 'Group'
  }
}

output securityGroupIds object = {
  securityGroup1Id: securityGroup1.id
  securityGroup2Id: securityGroup2.id
  securityGroup3Id: securityGroup3.id
}
