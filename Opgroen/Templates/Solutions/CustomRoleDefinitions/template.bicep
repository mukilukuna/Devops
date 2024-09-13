targetScope = 'managementGroup'

////////////////////////////////
// Azure Bastion Reader Role //
///////////////////////////////

module azureBastion '../../Features/RoleDefinition/template.bicep' = {
  name: 'azureBastionReaderRole'
  params: {
    roles: [
      {
        name: 'AzureBastion-Reader-Role'
        description: 'CUSTOM - Azure Bastion Reader Role'
        permissions: [
          {
            actions: [
              'Microsoft.Network/bastionHosts/read'
              'Microsoft.Network/virtualNetworks/BastionHosts/action'
              'Microsoft.Network/virtualNetworks/BastionHosts/action'
            ]
            notActions: []
            DataActions: []
            NotDataActions: []
          }
        ]
      }
    ]
  }
}

///////////////////////////////////////////////////////////
// Azure Firewall Rule Collection Group Contributor Role //
///////////////////////////////////////////////////////////

module azureFirewallRuleCollectionGroupContributorRole '../../Features/RoleDefinition/template.bicep' = {
  name: 'azureFirewallRuleCollectionGroupContributorRole'
  params: {
    roles: [
      {
        name: 'AzureFirewallRuleCollectionGroup-Contributor-Role'
        description: 'CUSTOM - Azure Firewall Policy Rule Collection Group Contributor Role'
        permissions: [
          {
            actions: [
              'Microsoft.Network/firewallPolicies/ruleCollectionGroups/read'
              'Microsoft.Network/firewallPolicies/ruleCollectionGroups/write'
              'Microsoft.Network/firewallPolicies/ruleCollectionGroups/delete'
              'Microsoft.Network/firewallPolicies/read'
              'Microsoft.Resources/subscriptions/resourceGroups/read'
              'Microsoft.Resources/deployments/validate/action'
              'Microsoft.Resources/deployments/read'
              'Microsoft.Resources/deployments/write'
              'Microsoft.Resources/deployments/operationStatuses/read'
            ]
            notActions: []
            DataActions: []
            NotDataActions: []
          }
        ]
      }
    ]
  }
}

////////////////////////////////
// Azure Bastion Reader Role //
///////////////////////////////

module azureLockAdministrator '../../Features/RoleDefinition/template.bicep' = {
  name: 'azureLockAdministrator'
  params: {
    roles: [
      {
        name: 'AzureLock-Administrator-Role'
        description: 'CUSTOM - Azure Lock Administrator Role'
        permissions: [
          {
            actions: [
              'Microsoft.Authorization/locks/*'
            ]
            notActions: []
            DataActions: []
            NotDataActions: []
          }
        ]
      }
    ]
  }
}

////////////////////////////////////////
// Corporate Contributor Role //
///////////////////////////////////////

module CorporateContributor '../../Features/RoleDefinition/template.bicep' = {
  name: 'CorporateContributor'
  params: {
    roles: [
      {
        name: 'Corporate-Contributor-Role'
        description: 'CUSTOM - Corporate Contributor Role'
        permissions: [
          {
            actions: [
              '*'
            ]
            notActions: [
              'Microsoft.Authorization/*/Delete'
              'Microsoft.Authorization/*/Write'
              'Microsoft.Authorization/elevateAccess/Action'
              'Microsoft.Blueprint/blueprintAssignments/write'
              'Microsoft.Blueprint/blueprintAssignments/delete'
              'Microsoft.Compute/galleries/share/action'
              'Microsoft.ClassicNetwork/*'
              'Microsoft.Network/applicationGatewayAvailableRequestHeaders/*'
              'Microsoft.Network/applicationGatewayAvailableResponseHeaders/*'
              'Microsoft.Network/applicationGatewayAvailableServerVariables/*'
              'Microsoft.Network/applicationGatewayAvailableSslOptions/*'
              'Microsoft.Network/applicationGatewayAvailableWafRuleSets/*'
              'Microsoft.Network/applicationGateways/*'
              'Microsoft.Network/ApplicationGatewayWebApplicationFirewallPolicies/*'
              'Microsoft.Network/azurefirewalls/*'
              'Microsoft.Network/bastionHosts/*'
              'Microsoft.Network/bgpServiceCommunities/*'
              'Microsoft.Network/connections/*'
              'Microsoft.Network/customIpPrefixes/*'
              'Microsoft.Network/expressRouteCircuits/*'
              'Microsoft.Network/expressRouteCrossConnections/*'
              'Microsoft.Network/expressRouteGateways/*'
              'Microsoft.Network/expressRoutePorts/*'
              'Microsoft.Network/expressRoutePortsLocations/*'
              'Microsoft.Network/expressRouteServiceProviders/*'
              'Microsoft.Network/firewallPolicies/*'
              'Microsoft.Network/frontDoors/*'
              'Microsoft.Network/frontDoorWebApplicationFirewallManagedRuleSets/*'
              'Microsoft.Network/frontDoorWebApplicationFirewallPolicies/*'
              'Microsoft.Network/localnetworkgateways/*'
              'Microsoft.Network/masterCustomIpPrefixes/*'
              'Microsoft.Network/natGateways/*'
              'Microsoft.Network/networkVirtualAppliances/*'
              'Microsoft.Network/p2sVpnGateways/*'
              'Microsoft.Network/privateLinkServices/*'
              'Microsoft.Network/publicIPAddresses/*'
              'Microsoft.Network/publicIPPrefixes/*'
              'Microsoft.Network/routeFilters/*'
              'Microsoft.Network/virtualHubs/*'
              'Microsoft.Network/virtualnetworkgateways/*'
              'Microsoft.Network/virtualWans/*'
              'Microsoft.Network/vpnGateways/*'
              'Microsoft.Network/vpnServerConfigurations/*'
              'Microsoft.Network/vpnsites/*'
              'Microsoft.Network/routeTables/write'
              'Microsoft.Network/routeTables/delete'
              'Microsoft.Network/routeTables/routes/write'
              'Microsoft.Network/routeTables/routes/delete'
              'Microsoft.Network/virtualNetworks/write'
              'Microsoft.Network/virtualNetworks/delete'
              'Microsoft.Network/virtualNetworks/peer/action'
              'Microsoft.Network/virtualNetworks/remoteVirtualNetworkPeeringProxies/write'
              'Microsoft.Network/virtualNetworks/remoteVirtualNetworkPeeringProxies/delete'
              'Microsoft.Network/virtualNetworks/virtualNetworkPeerings/write'
              'Microsoft.Network/virtualNetworks/virtualNetworkPeerings/delete'
              'Microsoft.Network/virtualRouters/write'
              'Microsoft.Network/virtualRouters/delete'
            ]
            DataActions: []
            NotDataActions: []
          }
        ]
      }
    ]
  }
}

///////////////////////////////////////
// Online Workload Contributor Role //
//////////////////////////////////////

module onlineConnectedContributor '../../Features/RoleDefinition/template.bicep' = {
  name: 'onlineConnectedContributor'
  params: {
    roles: [
      {
        name: 'OnlineConnected-Contributor-Role'
        description: 'CUSTOM - Online-Connected Contributor Role'
        permissions: [
          {
            actions: [
              '*'
            ]
            notActions: [
              'Microsoft.Authorization/*/write'
              'Microsoft.Authorization/*/Delete'
              'Microsoft.Authorization/elevateAccess/Action'
              'Microsoft.Network/virtualNetworks/write'
              'Microsoft.Network/virtualNetworks/delete'
              'Microsoft.Network/vpnGateways/*'
              'Microsoft.Network/azurefirewalls/*'
              'Microsoft.Network/firewallPolicies/*'
              'Microsoft.Network/expressRouteCircuits/*'
              'Microsoft.Network/routeFilters/*'
              'Microsoft.Network/virtualRouters/write'
              'Microsoft.Network/virtualRouters/delete'
              'Microsoft.Network/virtualHubs/*'
              'Microsoft.Network/virtualnetworkgateways/*'
              'Microsoft.Network/virtualWans/*'
              'Microsoft.Network/routeTables/write'
              'Microsoft.Network/routeTables/delete'
              'Microsoft.Network/routeTables/routes/write'
              'Microsoft.Network/routeTables/routes/delete'
              'Microsoft.Network/virtualNetworks/virtualNetworkPeerings/write'
              'Microsoft.Network/virtualNetworks/virtualNetworkPeerings/delete'
              'Microsoft.Network/vpnSites/*'
            ]
            DataActions: []
            NotDataActions: []
          }
        ]
      }
    ]
  }
}

//////////////////////////////////////////
// Access Management Administrator Role //
//////////////////////////////////////////

module accessManagementAdministrator '../../Features/RoleDefinition/template.bicep' = {
  name: 'accessManagementAdministrator'
  params: {
    roles: [
      {
        name: 'AccessManagement-Administrator-Role'
        description: 'CUSTOM - Access Management Administrator Role'
        permissions: [
          {
            actions: [
              'Microsoft.Authorization/roleAssignments/read'
              'Microsoft.Authorization/roleAssignments/write'
              'Microsoft.Authorization/roleAssignments/delete'
              'Microsoft.Authorization/roleAssignmentScheduleRequests/cancel/action'
              'Microsoft.Authorization/roleAssignmentScheduleRequests/write'
              'Microsoft.Authorization/roleAssignmentScheduleRequests/read'
              'Microsoft.Authorization/roleAssignmentScheduleInstances/read'
              'Microsoft.Authorization/roleAssignmentSchedules/read'
            ]
            notActions: []
            DataActions: []
            NotDataActions: []
          }
        ]
      }
    ]
  }
}

///////////////////////////////////////////////
// Virtual Network Peering Contributor Role //
//////////////////////////////////////////////

module virtualNetworkPeeringContributorRole '../../Features/RoleDefinition/template.bicep' = {
  name: 'virtualNetworkPeeringContributorRole'
  params: {
    roles: [
      {
        name: 'VirtualNetworkPeering-Contributor-Role'
        description: 'CUSTOM - Virtual Network Peering Contributor Role'
        permissions: [
          {
            actions: [
              'Microsoft.Network/virtualNetworks/virtualNetworkPeerings/read'
              'Microsoft.Network/virtualNetworks/virtualNetworkPeerings/write'
              'Microsoft.Network/virtualNetworks/virtualNetworkPeerings/delete'
              'Microsoft.Network/virtualNetworks/peer/action'
              'Microsoft.Resources/subscriptions/resourceGroups/read'
              'Microsoft.Resources/deployments/validate/action'
              'Microsoft.Resources/deployments/read'
              'Microsoft.Resources/deployments/write'
              'Microsoft.Resources/deployments/operationStatuses/read'
            ]
            notActions: []
            DataActions: []
            NotDataActions: []
          }
        ]
      }
    ]
  }
}

///////////////////////////////////////////////
// Policy Reader Role                       //
//////////////////////////////////////////////

module policyReaderRole '../../Features/RoleDefinition/template.bicep' = {
  name: 'policyReaderRole'
  params: {
    roles: [
      {
        name: 'Policy-Reader-Role'
        description: 'CUSTOM - Policy Reader Role'
        permissions: [
          {
            actions: [
              '*/read'
              'Microsoft.Authorization/policySetDefinitions/read'
              'Microsoft.Authorization/policyAssignments/read'
              'Microsoft.Authorization/policyDefinitions/read'
              'Microsoft.Authorization/policyExemptions/read'
              'Microsoft.PolicyInsights/*'
              'Microsoft.Management/register/action'
              'Microsoft.Support/*'
            ]
            notActions: []
            DataActions: []
            NotDataActions: []
          }
        ]
      }
    ]
  }
}

///////////////////////////////////////////////
// AzureRoles Reader Role                       //
//////////////////////////////////////////////

module azureRolesReaderRole '../../Features/RoleDefinition/template.bicep' = {
  name: 'azureRolesReaderRole'
  params: {
    roles: [
      {
        name: 'AzureRoles-Reader-Role'
        description: 'CUSTOM - Azure Roles Reader Role'
        permissions: [
          {
            actions: [
              'Microsoft.Authorization/roleDefinitions/read'
            ]
            notActions: []
            DataActions: []
            NotDataActions: []
          }
        ]
      }
    ]
  }
}

///////////////////////////////////////////
// Log Analytics Diagnostics Contributor //
///////////////////////////////////////////

module logAnalyticsDiagContributor '../../Features/RoleDefinition/template.bicep' = {
  name: 'logAnalyticsDiagContributor'
  params: {
    roles: [
      {
        name: 'LogAnalyticsDiag-Contribtutor-Role'
        description: 'CUSTOM - Log Analytics Diagnostics Contributor'
        permissions: [
          {
            actions: [
              'Microsoft.OperationalInsights/workspaces/read'
              'Microsoft.OperationalInsights/workspaces/sharedKeys/action'
              'Microsoft.OperationalInsights/workspaces/listKeys/action'
            ]
            notActions: []
            DataActions: []
            NotDataActions: []
          }
        ]
      }
    ]
  }
}

output virtualNetworkPeeringContributorRoleDefinitionId string = virtualNetworkPeeringContributorRole.outputs.resourceID[0]
output accessManagementAdministratorRoleDefinitionId string = accessManagementAdministrator.outputs.resourceID[0]
output onlineConnectedContributorRoleDefinitionId string = onlineConnectedContributor.outputs.resourceID[0]
output corporateContributorRoleDefintionId string = CorporateContributor.outputs.resourceID[0]
output azureLockAdministratorRoleDefinitionId string = azureLockAdministrator.outputs.resourceID[0]
output azureFirewallRuleCollectionGroupContributorRoleDefinitionId string = azureFirewallRuleCollectionGroupContributorRole.outputs.resourceID[0]
output azureBastionReaderRoleRoleDefinitionId string = azureBastion.outputs.resourceID[0]
output policyReaderRoleRoleDefinitionId string = policyReaderRole.outputs.resourceID[0]
output azureRolesReaderRoleRoleDefinitionId string = azureRolesReaderRole.outputs.resourceID[0]
output logAnalyticsDiagContributorRoleRoleDefinitionId string = logAnalyticsDiagContributor.outputs.resourceID[0]
