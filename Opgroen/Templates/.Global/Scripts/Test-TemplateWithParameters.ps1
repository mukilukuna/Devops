function Test-TemplateWithParameterFile {
    
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory)]
        [string] $basePath,

        [Parameter(Mandatory)]
        [string] $workloadType,

        [Parameter(Mandatory)]
        [string] $workloadName,

        [Parameter(Mandatory)]
        [string] $parameterFilePath,

        [Parameter(Mandatory)]
        [string] $location,

        [Parameter()]
        [string] $templateFileName = 'template',

        [Parameter()]
        [string] $resourceGroupName,

        [Parameter()]
        [string] $subscriptionId,

        [Parameter()]
        [string] $managementGroupId
    )
        
    begin {
        Write-Debug ("{0} entered" -f $MyInvocation.MyCommand)
    }
        
    process {
        $templateFilePath = "$basePath/$workloadType/$workloadName/$templateFileName.json"
        $DeploymentInputs = @{
            TemplateFile          = $templateFilePath
            TemplateParameterFile = $parameterFilePath
            Verbose               = $true
            OutVariable           = 'ValidationErrors'
        }
        $ValidationErrors = $null
        
        #####################
        ## TEST DEPLOYMENT ##
        #####################
        $deploymentSchema = (ConvertFrom-Json (Get-Content -Raw -Path $templateFilePath)).'$schema'
        switch -regex ($deploymentSchema) {
            '\/deploymentTemplate.json#$' {
                if ($subscriptionId) {
                    $Context = Get-AzContext -ListAvailable | Where-Object Subscription -Match $subscriptionId
                    if ($Context) {
                        $Context | Set-AzContext
                    } else {
                        Write-Verbose "Subscription not found in context array, set correct context"
                        try{
                            $subscription = Get-AzSubscription | Where-Object Id -Match $subscriptionId
                            $Context = Set-AzContext -SubscriptionObject $subscription
                        } catch {
                            throw "Unable to set correct subscription contect for $subscriptionId"
                        }
                    }
                }
                if (-not (Get-AzResourceGroup -Name $resourceGroupName -ErrorAction 'SilentlyContinue')) {
                    if ($PSCmdlet.ShouldProcess("Resource group [$resourceGroupName] in location [$location]", "Create")) {
                        New-AzResourceGroup -Name $resourceGroupName -Location $location
                    }
                }
                if ($PSCmdlet.ShouldProcess("Resource group level deployment", "Test")) {
                    Test-AzResourceGroupDeployment @DeploymentInputs -ResourceGroupName $resourceGroupName
                }
                break
            }
            '\/subscriptionDeploymentTemplate.json#$' {
                if ($subscriptionId) {
                    $Context = Get-AzContext -ListAvailable | Where-Object Subscription -Match $subscriptionId
                    if ($Context) {
                        $Context | Set-AzContext
                    } else {
                        Write-Verbose "Subscription not found in context array, set correct context"
                        try{
                            $subscription = Get-AzSubscription | Where-Object Id -Match $subscriptionId
                            $Context = Set-AzContext -SubscriptionObject $subscription
                        } catch {
                            throw "Unable to set correct subscription contect for $subscriptionId"
                        }
                    }
                }
                if ($PSCmdlet.ShouldProcess("Subscription level deployment", "Test")) {
                    Test-AzSubscriptionDeployment @DeploymentInputs -Location $Location
                }
                break
            }
            '\/managementGroupDeploymentTemplate.json#$' {
                if ($PSCmdlet.ShouldProcess("Management group level deployment", "Test")) {
                    Test-AzManagementGroupDeployment @DeploymentInputs -Location $Location -ManagementGroupId $ManagementGroupId
                }
                break
            }
            '\/tenantDeploymentTemplate.json#$' {
                Write-Verbose 'Handling tenant level validation'
                if ($PSCmdlet.ShouldProcess("Tenant level deployment", "Test")) {
                    Test-AzTenantDeployment @DeploymentInputs -Location $location
                }
                break
            }
            default {
                throw "[$deploymentSchema] is a non-supported ARM template schema"
            }
        }
        if ($ValidationErrors) {
            Write-Error "Template is not valid."
        }
    }
        
    end {
        Write-Debug ("{0} exited" -f $MyInvocation.MyCommand) 
    }
}