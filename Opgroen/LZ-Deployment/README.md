# Introduction

This repo contains the default template files to onboard and start the basic deployment of a new workload subscription.

## Getting Started

Before the onboarding of a new workload can begin a workload design needs to be available and approved by the Platform Architecture team.
The design should provide information for all the relevant critical design areas such as subscription, subscription name, IP plan, vNet design, RBAC roles and additional policy requirements.

![image](assests/PlatformSubscriptions.png)


For the onboarding please follow the guidelines below

1. Create Contributor and Reader Azure AD Group for workload
2. Add Groups to GEN-ZZ-SEC-P01-HUBBASTION-RE for Azure Bastion Access where needed
3. Create new subscription
4. Create new repository in DevOps
5. Copy the templates files from this repository to the target repository
6. Create Variable Group in DevOps Library
   - grant AzureFoundation Build Service Administrator permissions to update the variable group

The following files need to be updated before a deployment can start.

1. variable.yaml
   - outPutPrefix
   - subscriptionName
   - subscriptionId
   - azureResourceManagerConnection
   - variableGroup with item 4 name
   - group with item 4 name

## Goverance
2. roleAssignment.json (Map group to either internal or online custom role based on workload)
3. managementGroupMove.json
4. SubscriptionTag.json
Automation
5. automationAcccount.json
Backup
6. recoveryServicevault.json
Network
7. virtualNetwork.json
8. virtualNetworkPeering.json
Monitoring
9. storageAccount.diagnostics.json
Security
10. keyVault.json


remove the // and update the parameters with the correct values

Create an exception for the Security Policy to exempt the Key Vault that will host the BEK/KEK keys for Azure Disk Encryption from the policies to enforce activation/expiration dates on secrets and keys.

## Contribute

In case updates are required to the code to make sure manual input is kept at a minimum please create a branch and pull request to the repository with the suggested updates.
