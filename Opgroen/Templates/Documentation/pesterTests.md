# Pester Tests

## Feature tests

| Test                                                                                                                           | |
|--------------------------------------------------------------------------------------------------------------------------------|-|
| JSON template file (template.json) exists                                                                                      | |
| Template file (template.json) converts from JSON and has all expected properties                                               | |
| Parameter file (virtualNetwork.spoke1.json)  does contain all expected properties                                              | |
| Count of required parameters in template file (template.json) is equal or less than count of all parameters in parameters file | |
| All parameters in parameters file exist in template file                                                                       | |
| All required parameters in template file (template.json) existing in parameters file                                           | |

---

## Global tests

| General Feature folder tests                       | |
|---------------------------------------------------|-|
| Feature name should be Camel cased                | |
| Feature should contain a [template.json] file     | |
| Feature should contain a [Pipeline] folder         | |
| Feature should contain a [Tests] folder            | |
| Feature should contain a [Documentation] folder    | |

| Parameters file tests                                                  | |
|------------------------------------------------------------------------|-|
| *parameters.json files in the Parameters folder should not be empty    | |
| *parameters.json files in the Parameters folder should be valid JSON   | |

| Pipeline folder tests                                                      | |
|----------------------------------------------------------------------------|-|
| Pipeline folder should contain one or more *.yaml files (Pipeline files)   | |

| Tests folder tests                                           | |
|--------------------------------------------------------------|-|
| Tests folder should contain one or more *.tests.ps1 files    | |
| *.tests.ps1 files should not be empty                        | |

| Deployment template tests                                                                                                                        | |
|--------------------------------------------------------------------------------------------------------------------------------------------------|-|
| The template.json file should not be empty                                                                                                       | |
| The template.json file should be a valid JSON                                                                                                    | |
| Template schema version should be the latest                                                                                                     | |
| Template schema should use HTTPS reference                                                                                                       | |
| All apiVersion properties should be set to a static, hard-coded value                                                                            | |
| The template.json file should contain ALL supported elements                                                                                     | |
| Tagging should be implemented - if the resource type supports them                                                                               | |
| Delete lock should be implemented - if the resource type supports it                                                                             | |
| If delete lock is implemented, the template should have a lockForDeletion parameter with the default value of false                              | |
| If delete lock is implemented, it should have a deployment condition with the value of parameters('lockForDeletion')                             | |
| Diagnostic logs & metrics should be implemented - if the resource type supports them                                                             | |
| Resource level RBAC should be implemented - if the resource type supports it                                                                     | |
| Parameter, Output and variable names should be camel-cased (no dashes or underscores and must start with lower-case letter)                      | |
| The Location should be defined as a parameter, with the default value of 'resourceGroup().Location' or global for ResourceGroup deployment scope | |
| All resources that have a Location property should refer to the Location parameter 'parameters('Location')'                                      | |
| The template should not have empty lines                                                                                                         | |
| Standard outputs should be provided (e.g. resourceName, resourceID)                                                                              | |
| Parameters' description shoud start either by 'Optional.' or 'Required.' or 'Generated.'                                                         | |
| Output should have descriptions                                                                                                                  | |

---

## API tests

| General tests                                                      | |
|--------------------------------------------------------------------|-|
| Resource type [***] should use on of the recent API version(s)     | |