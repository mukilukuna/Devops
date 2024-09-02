# InSpark Management

The InSpark Management repository contains the configuration for:

1. Deploy governance settings for the Management Subscription.
   1. Enable Microsoft Defender For Cloud.
   2. Deploy a Cost Budget Alert.
   3. Move the subscription to the required Management Group.
   4. Configure Subscription Tags.
   5. Configure Subscription Activity Logs.
2. Deploy the Network resource group containing the following components:
   1. Virtual Network.
   2. Network Security Groups.
   3. Route Table with User Defined Routes.
   4. If required subnets for Azure Bastion, Domain Controllers, DNS Servers (or Resolver(s)).
3. Deploy a log analytics resource group for:
   1. Log Analytics workspace with required solutions.
4. Deploy a NPM resource group with:
   1. Two Virtual Machines which can be used for configuring Network Watcher Connection Monitors.
   2. Configuration for Connection Monitors.
5. Deploying Azure Automation Accounts for Update Management and one for Azure Automation (script) purposes.
   1. Configuration for Update Management
6. Deploying a resource group with workbooks
   1. Workbooks for Azure Firewall
   2. Reliability Insights
   3. Microsoft Defender for Cloud

Additionally, the repository has a operations folder, which contains some operational scripts. These scripts can be run on a schedule to handle certain tasks. Currently this is limited to:

- Azure Policy Remediation.
- Clean up orphaned Role Based Access Control assignments.
- Clean up deployment history on management groups.

## Required values to update before starting the deployment

Starting with the .azure folder, you will need to update or review the following values per file. **Not all files in the variable file are shown below.**

### .azure/variables.yaml

#### Pipelines and templates

| Variable Name                  | Value                                                               | Description |
| ------------------------------ | ------------------------------------------------------------------- | ----------- |
| azureResourceManagerConnection | Name of the service connection in Azure DevOps                      |             |
| templateProject                | Name of the project which contains the InSpark Templates repository |             |
| version                        | Version (tag) to use on the Templates repository                    |             |
| azureResourceManagerConnection | Name of the service connection in Azure DevOps                      |             |

#### Resource Organization

| Variable Name     | Value                                 | Description         |
| ----------------- | ------------------------------------- | ------------------- |
| subscriptionId    | Subscription Id for the subscription  |                     |
| subscriptionName  | Name for the subscription             | Can be left default |
| managementGroupId | Id of the management group            |                     |
| location          | Location for the deployments metadata |                     |

#### Governance

| Variable Name | Value                                 | Description |
| ------------- | ------------------------------------- | ----------- |
| securityEmail | E-mailaddress of the security contact |             |
| budgetEmail   | E-mailaddress of the cost owner       |             |
| budget        | Budget in euros to set alert          |             |

#### Tags

**Note, the below is a default and can be different for each environment.**

| Variable Name   | Value | Description |
| --------------- | ----- | ----------- |
| CostCenter      |       |             |
| Owner           |       |             |
| WorkloadName    |       |             |
| ApplicationName |       |             |
| ManagedBy       |       |             |

#### Naming convention

**Note, the below is a default and can be different for each environment.**

| Variable Name   | Value        | Description |
| --------------- | ------------ | ----------- |
| workloadName    | infr         |             |
| applicationName | connectivity |             |
| environmentName | p            |             |
| regionName      | weu          |             |

#### Networking

| Variable Name                | Value                         | Description                                                            |
| ---------------------------- | ----------------------------- | ---------------------------------------------------------------------- |
| addressSpacePrefix           | 172.27.2                      |                                                                        |
| hubAddressSpacePrefix        | 172.27.3                      |                                                                        |
| hubSubscriptionId            | 0000-0000-000-0000            | Id of the Connectivity Subscription                                    |
| hubConnectivityResourceGroup | rg-infr-connectivity-p-weu-01 | Resource Group Name of the network RG in the Connectivity Subscription |
| AzureIPSpace                 | 172.27.0.0/16                 |                                                                        |

### Output

| Variable Name | Value                     | Description |
| ------------- | ------------------------- | ----------- |
| outputPrefix  | connWeu                   |             |
| variableGroup | Platform-Connectivity-Weu |             |

## Configuration

Deployment is done via YAML pipelines which reference Bicep files (or tasks that take a bicep file as input). The bicep modules are located in the modules folder. The modules folder stores modules that reference modules from the Templates repository. For the Foundation, as it is fairly static and requires a minimal amount of changes we use the configs folder to store the configuration files. We load these files in Bicep using the loadJsonContent() function. Inside these .json files we have values that are different per foundation deployment, those are provided from the variables.yaml in the .azure folder. Values that are surrounded by *<>* will be replaced by the values from the variables.yaml file. Usually it should be sufficient to update the variable.yaml file, but sometimes the configs need to be adjusted as well.

### .azure/main.yaml

Update `CIA` to the correct value:

```yaml
resources:
  repositories:
    - repository: Templates
      type: git
      name: CIA/Templates
```

## Deployment

### Create pipeline from the main.yaml file

Create a new pipeline in Azure DevOps using the .azure/main.yaml file and run the pipeline. You can use the stages tab to run the different stages separately.

## Operational pipelines

In the .azure folder we have pipelines available to deliver operational tasks. These pipelines are not automatically created, after creation the pipelines can be run on a schedule.

- policyAutoRemediation.yaml: This pipeline runs periodically to remediate policies that are not compliant.
- cleanUpOrphanedRBACAssignments.yaml: This pipeline runs periodically to clean up orphaned RBAC assignments.
- cleanUpDeploymentHistory.yaml: This pipeline runs periodically to clean up deployment history on management group customer MG.
