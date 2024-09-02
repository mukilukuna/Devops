# InSpark Azure Policy Framework repository

The InSpark PolicyFramework repository contains the configuration for:

1. Storing and deploying Policy Definitions for the Foundation.
2. Storing and deploying Policy Sets (Initiatives) for the Foundation.
3. Storing and deploying Policy Assignments for the Foundation.
4. Pipelines to deploy to a single but also to multiple tenants if required.

## Folders

Defininitions: Contains all the policy definitions, assignments and initiatives.
Module: Contains PowerShell module provided by EPAC project.
Pipelines: Contains single-tenant and multi-tenant pipelines to be used for deployments.
Scripts: Contains scripts provided by the EPAC project. These scripts are used by the pipelines.

## Required values to update before starting the deployment

Starting with the .azure folder, you will need to update or review the following values per file. **Not all files in the variable file are shown below.**

### pipelines/variables.yaml

#### Resource Organization

| Variable Name          | Value                                                        | Description |
| ---------------------- | ------------------------------------------------------------ | ----------- |
| TenantId               | Tenant Id                                                    |             |
| hubSubscriptionId      | Subscription Id for the subscription                         |             |
| identitySubscriptionId | Subscription Id for the subscription                         |             |
| mubSubscriptionId      | Subscription Id for the subscription                         |             |
| location               | Location for the deployments metadata and policy definitions |             |

### pipelines/single-tenant-pipeline.yaml

| Variable Name                 | Value                                                                                              | Description |
| ----------------------------- | -------------------------------------------------------------------------------------------------- | ----------- |
| devServiceConnection          | Name of the Azure DevOps service connection used for canary Policy Framework                       |             |
| tenantPlanServiceConnection   | Name of the Azure DevOps service connection used for Production Policy Framework Reader            |             |
| tenantDeployServiceConnection | Name of the Azure DevOps service connection used for Production Policy Framework Contributor       |             |
| tenantRolesServiceConnection  | Name of the Azure DevOps service connection used for Production Policy Framework User Access Admin |             |

### pipelines/multi-tenant-pipeline.yaml

TODO

## Configuration

Configuration for the Policy Framework is done by the content of the Definitions, Definitions/Global-settings.jsonc and variables.yaml folder. If you run the deployment in a other branch then main or master the pipeline will trigger automatically but only deploy to the Canary Management Group structure, this may and should be used for validation purposes. Directly commiting to main will trigger a policy deployment to production (if any changes are made).

### Create pipeline from the single-tenant-pipeline.yaml file

Create a new pipeline in Azure DevOps uisng the piplines/single-tenant-pipeline.yaml file and run the pipeline. You can use the stages tab to run the different stages separately.
