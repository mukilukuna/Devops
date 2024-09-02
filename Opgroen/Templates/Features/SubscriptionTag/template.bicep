targetScope = 'subscription'

@description('Required. Resource tags')
param tags object

resource tag 'Microsoft.Resources/tags@2021-04-01' = {
  name: 'default'
  properties: {
    tags: tags
  }
}

@description('ID of the resource')
output resourceID string = tag.id

@description('ID of the resource')
output resourceName string = tag.id
