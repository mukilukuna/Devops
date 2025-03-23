resource vmTagPolicy 'Microsoft.Authorization/policyDefinitions@2023-04-01' = {
  name: 'enforce-vm-tags'
  properties: {
    policyType: 'Custom'
    parameters: {
      tagName: {
        type: 'String'
        defaultValue: 'CostCenter'
      }
    }
    policyRule: {
      if: {
        allOf: [
          {
            field: 'type'
            equals: 'Microsoft.Compute/virtualMachines'
          },
          {
            field: 'tags[parameters(''tagName'')]'
            exists: false
          }
        ]
      }
      then: {
        effect: 'deny'
      }
    }
  }
}
