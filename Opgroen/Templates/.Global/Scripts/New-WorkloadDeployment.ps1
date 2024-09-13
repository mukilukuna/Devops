function New-ModuleDeployment {

    [CmdletBinding(SupportsShouldProcess, DefaultParameterSetName = 'None')]
    param (
        [Parameter(Mandatory)]
        [string] $workloadName,

        [Parameter(Mandatory)]
        [string] $basePath,

        [Parameter(Mandatory)]
        [string] $workloadType,

        [Parameter(Mandatory = $false)]
        [string] $parameterFilePath,

        [Parameter(Mandatory)]
        [string] $location,

        [Parameter(Mandatory, ParameterSetName = 'ByRg')]
        [string] $resourceGroupName,

        [Parameter(Mandatory, ParameterSetName = 'BySub')]
        [Parameter(Mandatory, ParameterSetName = 'ByRg')]
        [string] $subscriptionId,

        [Parameter(Mandatory, ParameterSetName = 'ByMg')]
        [string] $managementGroupId,

        [Parameter(Mandatory = $false)]
        [bool] $whatIfDeployment = $false,

        [Parameter(Mandatory = $false)]
        [bool] $removeDeployment,

        [Parameter(Mandatory = $false)]
        [string] $outPutPrefix = "",

        [Parameter(Mandatory = $false)]
        [string] $AZURE_DEVOPS_EXT_PAT
    )

    begin {
        Write-Debug ("{0} entered" -f $MyInvocation.MyCommand)
    }

    process {
        $templateFilePath = "$basePath/$workloadType/$workloadName/template.json"
        #$parameterFilePath = Join-Path $parametersBasePath $parameterFilePath
        Write-Verbose "Got path: $templateFilePath"
        if ($parameterFilePath) {
            $DeploymentInputs = @{
                Name                  = "$workloadName-$(-join (Get-Date -Format yyyyMMddTHHMMssffffZ)[0..63])"
                TemplateFile          = $templateFilePath
                TemplateParameterFile = $parameterFilePath
                Verbose               = $true
                ErrorAction           = 'Stop'
            }
        } else {
            $DeploymentInputs = @{
                Name         = "$workloadName-$(-join (Get-Date -Format yyyyMMddTHHMMssffffZ)[0..63])"
                TemplateFile = $templateFilePath
                Verbose      = $true
                ErrorAction  = 'Stop'
            }
        }
        if ($removeDeployment) {
            # Fetch tags of parameter file if any (- required for the remove process. Tags may need to be compliant with potential customer requirements)
            $parameterFileTags = (ConvertFrom-Json (Get-Content -Raw -Path $parameterFilePath) -AsHashtable).parameters.tags.value
            if (-not $parameterFileTags) {
                $parameterFileTags = @{}
            }
            $parameterFileTags['RemoveModule'] = $workloadName
        }
        #######################
        ## INVOKE DEPLOYMENT ##
        #######################
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
                        New-AzResourceGroup -Name $resourceGroupName -Location $location -Confirm:$false
                    }
                }
                if ($removeDeployment) {
                    Write-Verbose "Because the subsequent removal is enabled after the Module $workloadName has been deployed, the following tags (RemoveModule: $workloadName) are now set on the resource."
                    Write-Verbose "This is necessary so that the later running Removal Stage can remove the corresponding Module from the Resource Group again."
                    # Overwrites parameter file tags parameter
                    $DeploymentInputs += @{
                        Tags = $parameterFileTags
                    }
                }
                if ($PSCmdlet.ShouldProcess("Resource group level deployment", "Create")) {
                    Select-AzSubscription $subscriptionId

                    # Deploy template and get the output
                    if ($whatIfDeployment -eq $false) {
                        $outputs = New-AzResourceGroupDeployment @DeploymentInputs -ResourceGroupName $resourceGroupName
                        if ($outPutPrefix -and $outputs) {

                            Add-VariableGroup -variables $outputs.Outputs -outPutPrefix $outPutPrefix -organization $Env:SYSTEM_TEAMFOUNDATIONSERVERURI -project $Env:SYSTEM_TEAMPROJECT -AZURE_DEVOPS_EXT_PAT $AZURE_DEVOPS_EXT_PAT
                        }
                        Write-Output "OUTPUT:"
                        foreach ($key in $outputs.Outputs.keys) {
                            $value = $outputs.Outputs[$key].value
                            Write-Output $key
                            Write-Output $value
                            Write-Output "##vso[task.setvariable variable=$key;isOutput=true]$value"
                            Write-Output "##vso[task.setvariable variable=$key;isOutput=false]$value"
                            Write-Output ""
                        }
                    } else {
                        New-AzResourceGroupDeployment -WhatIf @DeploymentInputs -ResourceGroupName $resourceGroupName
                    }
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
                if ($removeDeployment) {
                    Write-Verbose "Because the subsequent removal is enabled after the Module $workloadName has been deployed, the following tags (RemoveModule: $workloadName) are now set on the resource."
                    Write-Verbose "This is necessary so that the later running Removal Stage can remove the corresponding Module from the Resource Group again."
                    # Overwrites parameter file tags parameter
                    $DeploymentInputs += @{
                        Tags = $parameterFileTags
                    }
                }
                if ($PSCmdlet.ShouldProcess("Subscription level deployment", "Create")) {
                    if ($whatIfDeployment -eq $false) {
                        $outputs = New-AzSubscriptionDeployment @DeploymentInputs -Location $location
                        if ($outPutPrefix -and $outputs) {

                            Add-VariableGroup -variables $outputs.Outputs -outPutPrefix $outPutPrefix -organization $Env:SYSTEM_TEAMFOUNDATIONSERVERURI -project $Env:SYSTEM_TEAMPROJECT -AZURE_DEVOPS_EXT_PAT $AZURE_DEVOPS_EXT_PAT
                        }
                        Write-Output "OUTPUT:"
                        foreach ($key in $outputs.Outputs.keys) {
                            $value = $outputs.Outputs[$key].value
                            Write-Output $key
                            Write-Output $value
                            Write-Output "##vso[task.setvariable variable=$key;isOutput=true]$value"
                            Write-Output "##vso[task.setvariable variable=$key;isOutput=false]$value"
                            Write-Output ""
                        }
                    } else {
                        New-AzSubscriptionDeployment -WhatIf @DeploymentInputs -Location $location
                    }
                }
                break
            }
            '\/managementGroupDeploymentTemplate.json#$' {
                if ($PSCmdlet.ShouldProcess("Management group level deployment", "Create")) {
                    if ($whatIfDeployment -eq $false) {
                        $outputs = New-AzManagementGroupDeployment @DeploymentInputs -Location $location -ManagementGroupId $managementGroupId
                        if ($outPutPrefix -and $outputs) {

                            Add-VariableGroup -variables $outputs.Outputs -outPutPrefix $outPutPrefix -organization $Env:SYSTEM_TEAMFOUNDATIONSERVERURI -project $Env:SYSTEM_TEAMPROJECT -AZURE_DEVOPS_EXT_PAT $AZURE_DEVOPS_EXT_PAT
                        }
                        Write-Output "OUTPUT:"
                        foreach ($key in $outputs.Outputs.keys) {
                            $value = $outputs.Outputs[$key].value
                            Write-Output $key
                            Write-Output $value
                            Write-Output "##vso[task.setvariable variable=$key;isOutput=true]$value"
                            Write-Output "##vso[task.setvariable variable=$key;isOutput=false]$value"
                            Write-Output ""
                        }
                    } else {
                        New-AzManagementGroupDeployment -WhatIf @DeploymentInputs -Location $location -ManagementGroupId $managementGroupId
                    }
                }
                break
            }
            '\/tenantDeploymentTemplate.json#$' {
                if ($PSCmdlet.ShouldProcess("Tenant level deployment", "Create")) {
                    if ($whatIfDeployment -eq $false) {
                        $outputs = New-AzTenantDeployment @DeploymentInputs -Location $location
                        if ($outPutPrefix -and $outputs) {

                            Add-VariableGroup -variables $outputs.Outputs -outPutPrefix $outPutPrefix -organization $Env:SYSTEM_TEAMFOUNDATIONSERVERURI -project $Env:SYSTEM_TEAMPROJECT -AZURE_DEVOPS_EXT_PAT $AZURE_DEVOPS_EXT_PAT
                        }
                        Write-Output "OUTPUT:"
                        foreach ($key in $outputs.Outputs.keys) {
                            $value = $outputs.Outputs[$key].value
                            Write-Output $key
                            Write-Output $value
                            Write-Output "##vso[task.setvariable variable=$key;isOutput=true]$value"
                            Write-Output "##vso[task.setvariable variable=$key;isOutput=false]$value"
                            Write-Output ""
                        }
                    } else {
                        New-AzTenantDeployment -WhatIf @DeploymentInputs -Location $location
                    }
                }
                break
            }
            default {
                throw "[$deploymentSchema] is a non-supported ARM template schema"
            }
        }
    }

    end {
        Write-Debug ("{0} exited" -f $MyInvocation.MyCommand)
    }
}