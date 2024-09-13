# InSpark Connectivity

The InSpark Connectivity repository contains the configuration for:

1. Deploy governance settings for the Connectivity Subscription.
   1. Enable Microsoft Defender For Cloud.
   2. Deploy a Cost Budget Alert.
   3. Move the subscription to the required Management Group.
   4. Configure Subscription Tags.
   5. Configure Subscription Activity Logs.
2. Deploy the Network resource group containing the following components:
   1. Virtual Network or Virtual WAN Hub (with Routing Intent).
   2. Network Security Groups
   3. Route Table with User Defined Routes
   4. Azure Firewall.
   5. VPN gateway with Local Network Gateway, Site-to-Site (S2S) VPN and Point-to-Site (P2S) VPN.
   6. Express Route Circruit, Gateway and Peering.
   7. Azure Firewall Policies for Platform (Foundation) and Landing Zones.
   8. Resource Group Locks

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

| Variable Name         | Value         | Description |
| --------------------- | ------------- | ----------- |
| addressSpacePrefix    | 172.27.0      |             |
| mgtAddressSpacePrefix | 172.27.3      |             |
| AzureIPSpace          | 172.27.0.0/16 |             |

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

Create a new pipeline in Azure DevOps uisng the .azure/main.yaml file and run the pipeline. You can use the stages tab to run the different stages separately.
