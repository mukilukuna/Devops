# InSpark Foundation

The InSpark Foundation repository is the first repository in the Foundation platform deployment process. It is used to set-up the environment and lay-out of the platform.

The InSpark foundation repository contains the configuration for:

1. Deploy the pre-requisites for the platform.
2. Deploy the Management Groups for the platform.
3. Deploy the Custom Role Definitions for the platform
4. Deploy the Role Assignments for the platform on Tenant and Business (mg-Customer) Management Group level.

## Pre-requisites to create before starting the configuration of the parameters and variables

**Note: This is usually created during the technical onboarding. The technical onboarding should be done before continuing with this document**

### Azure Active Directory Role Access

For optimal deployment we require the `Directory Readers` and `Application Administrator` roles (via PIM). If this is not possible most of the work below has to be done by someone with access to those roles (or a role with more permissions). These roles are _temporary_ and can be removed after the project is finished.

### Foundation Service Principal

- Service Principal that will be used for Tenant Root Group deployments.
  - Suggested name: `sp-devops-foundation-tenantroot-co`
  - Save the `Application Id`, `Object Id`, `Tenant ID` and `Client Secret` in a secure (temporary) location.

- Permissions to set permissions for the aforementioned Service Principal on the Tenant Root Group ('/') **Note: This cannot be done using the Azure portal!**
  - Use the [latest Azure PowerShell module](https://learn.microsoft.com/en-us/powershell/azure/install-azure-powershell?view=azps-10.4.1) and sign in to Azure PowerShell using `Connect-AzAccount -TenantId <TenantId>`
  - Elevate privileges as a Global Admin ([MS Learn](https://learn.microsoft.com/en-us/azure/role-based-access-control/elevate-access-global-admin#elevate-access-for-a-global-administrator))
  - Grant the Service Principal the Owner role on the Tenant Root Group ('/')
    Run Command:

    ```powershell
    $SPNObjectId = "<Object Id of the Service Principal>"
    New-AzRoleAssignment -ObjectId $SPNObjectId -RoleDefinitionName "User Access Administrator" -Scope "/"
    New-AzRoleAssignment -ObjectId $SPNObjectId -RoleDefinitionName "Log Analytics Contributor" -Scope "/"
    New-AzRoleAssignment -ObjectId $SPNObjectId -RoleDefinitionName "Management Group Contributor" -Scope "/"
    New-AzRoleAssignment -ObjectId $SPNObjectId -RoleDefinitionName "Hierarchy Settings Administrator" -Scope "/"
    ```

- Configure Microsoft Graph Api Delegated Permissions (With Consent from Global Admin user)
  - `Directory.Read.All`
  - `Group.Read.All`
  - `ServicePrincipalEndpoint.Read.All`
  - `User.Read.All`

- Create the service connection in the DevOps project with the name `Tenant Root Group` and scope set to the `TenantId` of the tenant.

### PolicyFramework Service Principals

#### OTA (Canary) Policy Framework Environment

- Service Principal that will be used for `Canary` Policy Framework deployments.
  - Suggested name: `sp-devops-pf-ota-owner`
  - Save the `Application Id`, `Object Id`, `Tenant ID` and `Client Secret` in a secure (temporary) location.

- Configure Microsoft Graph Api Delegated Permissions (With Consent from Global Admin user)
  - Microsoft Graph Delegated: `Directory.Read.All`
  - Extra permissions for potential future Automation tasks could include: `ApplicationReadWrite.OwnedBy`, `Group.Create`

- Create the service connection in the DevOps project with the name `PolicyFramework-OTA-Owner` and scope set to the `TenantId` of the tenant.

#### Production Policy Framework Environment

##### Reader Principal

- Suggested name: `sp-devops-pf-prd-reader`
  - Save the `Application Id`, `Object Id`, `Tenant ID` and `Client Secret` in a secure (temporary) location.

- Configure Microsoft Graph Api Delegated Permissions (With Consent from Global Admin user)
  - Microsoft Graph Delegated: `Directory.Read.All`
  - Extra permissions for potential future Automation tasks could include: `ApplicationReadWrite.OwnedBy`, `Group.Create`

- Create the service connection in the DevOps project with the name `PolicyFramework-PRD-Reader` and scope set to the `mg-corporateMgName` of the platform.

##### Contributor Principal

- Suggested name: `sp-devops-pf-prd-contributor`
  - Save the `Application Id`, `Object Id`, `Tenant ID` and `Client Secret` in a secure (temporary) location.

- No graph permissions required!

- Create the service connection in the DevOps project with the name `PolicyFramework-PRD-Contributor` and scope set to the `mg-corporateMgName` of the platform.

##### User Access Administrator Principal

- Suggested name: `sp-devops-pf-prd-useraccessadministrator`
  - Save the `Application Id`, `Object Id`, `Tenant ID` and `Client Secret` in a secure (temporary) location.

- No graph permissions required!

- Create the service connection in the DevOps project with the name `PolicyFramework-PRD-UAA` and scope set to the `mg-corporateMgName` of the platform.

##### Reader Principal

- Suggested name: `sp-devops-pf-prd-reader`
  - Save the `Application Id`, `Object Id`, `Tenant ID` and `Client Secret` in a secure (temporary) location.

- Configure Microsoft Graph Api Delegated Permissions (With Consent from Global Admin user)
  - Microsoft Graph Delegated: `Directory.Read.All`
  - Extra permissions for potential future Automation tasks could include: `ApplicationReadWrite.OwnedBy`, `Group.Create`

- Create the service connection in the DevOps project with the name `PolicyFramework-PRD-Reader` and scope set to the `mg-corporateMgName` of the platform.

### Foundation Security Groups

In order to set permissions we need to create Security Groups in AAD. Starting with the following for the Platform (Foundation) team:

- CustomerAbbreviation could be: 'cia'
- corporateMgName could be: 'cia'

For the tenant root group:

- sg-`customerAbbreviation`-aad-mg-tenant-owners
- sg-`customerAbbreviation`-aad-mg-tenant-contributors
- sg-`customerAbbreviation`-aad-mg-tenant-readers
- sg-`customerAbbreviation`-aad-mg-tenant-useraccessadministrators
- sg-`customerAbbreviation`-aad-mg-tenant-securityadmins
- sg-`customerAbbreviation`-aad-mg-tenant-secrutiyreaders

For assignment on the mg-`corporateMgName` level:

- sg-`customerAbbreviation`-aad-`mg-corporateMgName`-owners
- sg-`customerAbbreviation`-aad-`mg-corporateMgName`-contributors
- sg-`customerAbbreviation`-aad-`mg-corporateMgName`-readers
- sg-`customerAbbreviation`-aad-`mg-corporateMgName`-useraccessadministrators
- sg-`customerAbbreviation`-aad-`mg-corporateMgName`-securityadmins
- sg-`customerAbbreviation`-aad-`mg-corporateMgName`-securityreaders

Note: Make sure to have access to the security group object ids before continuing.

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

| Variable Name             | Value                                             | Description         |
| ------------------------- | ------------------------------------------------- | ------------------- |
| TenantId                  | Tenant Id to deploy to                            |                     |
| HubSubscriptionId         | Subscription Id for the Connectivity Subscription |                     |
| hubSubscriptionName       | Name for the Connectivity Subscription            | Can be left default |
| identitySubscriptionId    | Subscription Id for the Identity Subscription     |                     |
| identitySubscriptionName  | Name for the Identity Subscription                | Can be left default |
| managementSubscriptionId  | ubscription Id for the Management Subscription    |                     |
| managementSubscriptionId  | Name for the Management Subscription              | Can be left default |
| location                  | Location for the deployments metadata             |                     |
| TenantRootManagementGroup | TenantRootGroup                                   |                     |
| CorporateManagementGroup   | `mg-corporateMgName`                              |                     |

#### Identity Configuration

| Variable Name                     | Value                                                                 | Description                                            |
| --------------------------------- | --------------------------------------------------------------------- | ------------------------------------------------------ |
| TenantRootGroupIdentity           | Object Id of the deployment (tenant root group) service principal     | C1                                                     |
| BackupManagementServiceIdentity   | Object Id of the Backup Management Service AAD Enterprise application | Only exists upon creation of a Recovery Services Vault |
| TenantRoot-ADGroup-Owner          | Object Id of the corresponding security group                         |                                                        |
| TenantRoot-ADGroup-Contributor    | Object Id of the corresponding security group                         |                                                        |
| TenantRoot-ADGroup-Reader         | Object Id of the corresponding security group                         |                                                        |
| TenantRoot-ADGroup-UAC            | Object Id of the corresponding security group                         |                                                        |
| TenantRoot-ADGroup-SecurityAdmin  | Object Id of the corresponding security group                         |                                                        |
| TenantRoot-ADGroup-SecurityReader | Object Id of the corresponding security group                         |                                                        |
| CustomerMG-ADGroup-Owner          | Object Id of the corresponding security group                         |                                                        |
| CustomerMG-ADGroup-Contributor    | Object Id of the corresponding security group                         |                                                        |
| CustomerMG-ADGroup-Reader         | Object Id of the corresponding security group                         |                                                        |
| CustomerMG-ADGroup-UAC            | Object Id of the corresponding security group                         |                                                        |
| CustomerMG-ADGroup-SecurityAdmin  | Object Id of the corresponding security group                         |                                                        |
| CustomerMG-ADGroup-SecurityReader | Object Id of the corresponding security group                         |                                                        |

#### PolicyFramework

| Variable Name            | Value                                            | Description |
| ------------------------ | ------------------------------------------------ | ----------- |
| PF-OTA-Owner             | Object Id of the corresponding service principal |             |
| PF-PrdPlan-PolicyReader  | Object Id of the corresponding service principal |             |
| PF-Prd-PolicyContributor | Object Id of the corresponding service principal |             |
| PF-PrdRoles-UAA          | Object Id of the corresponding service principal |             |

#### Networking

| Variable Name         | Value                                         | Description                                                                                         |
| --------------------- | --------------------------------------------- | --------------------------------------------------------------------------------------------------- |
| hubAddressSpacePrefix | Address space of the Connectivity hub network | i.e. 10.120.0.0/23                                                                                  |
| hubmodel              | customerManaged or microsoftManaged           | customerManaged (Hub-Spoke) or microsoftManaged (VWAN) to determine correct internal IP of firewall |

### .azure/main.yaml

Update `CIA` to the correct value:

```yaml
resources:
  repositories:
    - repository: Templates
      type: git
      name: CIA/Templates
```

### prerequisites/.azure/prerequisites.yaml

Update `CIA` to the correct value:

```yaml
resources:
  repositories:
    - repository: Templates
      type: git
      name: CIA/Templates
```

## Configuration

Deployment is done via YAML pipelines which reference Bicep files (or tasks that take a bicep file as input). The bicep modules are located in the modules folder. The modules folder stores modules that reference modules from the Templates repository. For the Foundation, as it is fairly static and requires a minimal amount of changes we use the configs folder to store the configuration files. We load these files in Bicep using the loadJsonContent() function. Inside these .json files we have values that are different per foundation deployment, those are provided from the variables.yaml in the .azure folder. Values that are surrounded by *<>* will be replaced by the values from the variables.yaml file. Usually it should be sufficient to update the variable.yaml file, but sometimes the configs need to be adjusted as well.

## Deployment

### Create pipeline from the prerequisites.yaml file

Create a new pipeline in Azure DevOps using the prerequisites/.azure/prerequisites.yaml file and run the pipeline.

Note: This pipeline must be removed after the foundation has been deployed to prevent any confusion in the future.

This will:

- Create the business MG
- Move the platform (Connectivity, Identity and Management) subscriptions to the business MG
  - Rationale: If the subscriptions are not moved, we will not be able to manage or view them from the Azure Portal with our user accounts as we are not supposed to have rights on the Tenant Root Group.
- Deploy Custom Role Definitions on the business MG
  - Rationale: We assign custom role definitions during the next phase of the foundation deployment, in order for us to do this, they need to exist beforehand.
- Deploy a Log Analytics workspace in the management subscription
  - Rationale: The resource id needs to be known before deploying the PolicyFramework. This allows us to know the id.
- Deploy a Resource group in the identity subscription for the future Private DNS Zones
  - Rationale: We need to know the resource id of the resource group before deploying the PolicyFramework.
- Deploy a Resource group in the connectivity subscription for the network resources
  - Additionally deploy a Managed Identity which will be used for future spoke deployments
    - Rationale: We need to know the resource id of the Managed Identity before deploying the PolicyFramework.

### Create pipeline from the main.yaml file

Create a new pipeline in Azure DevOps using the .azure/main.yaml file and run the pipeline.

This will:

- Deploy the Management Groups
- Deploy the Custom Role Definitions
- Deploy the Role Assignments for the platform
