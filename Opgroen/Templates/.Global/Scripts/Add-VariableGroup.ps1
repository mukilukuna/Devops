function Add-VariableGroup {
    param
    (
        [Parameter(Mandatory = $false)]
        [hashtable] $variables = $null,

        [Parameter(Mandatory = $false)]
        [string] $variableGroup = $variableGroup,

        [Parameter(Mandatory = $false)]
        [string] $organization = $env:System_TeamFoundationCollectionUri,

        [Parameter(Mandatory = $false)]
        [string] $project = $env:System_TeamProject,

        [Parameter(Mandatory = $false)]
        [string] $varKey = "",

        [Parameter(Mandatory = $false)]
        [string] $varValue = "",

        [Parameter(Mandatory = $false)]
        [bool] $isSecret = $false,

        [Parameter(Mandatory = $false)]
        [string] $outPutPrefix = "",

        [Parameter(Mandatory = $false)]
        [string] $AZURE_DEVOPS_EXT_PAT
    )

    $Groups = $null
    $varGroup = $null

    $env:AZURE_DEVOPS_EXT_PAT = $AZURE_DEVOPS_EXT_PAT

    if ($varkey) {
        # Original script if varKey and varValue are supplied
        $varcombined = $varKey + "=" + $varValue

        $Groups = az pipelines variable-group list --org $organization --project $project | ConvertFrom-Json
        $varGroup = $Groups | Where-Object { $_.name -eq $variableGroup }

        if (!$varGroup) {
            Write-Output "Creating variable group"
            az pipelines variable-group create --org $organization --project $project --name $environment --variables $varcombined --authorize
        }
        else {
            Write-Output "Updating variable group"
            $variables = az pipelines variable-group variable list --org $organization --project $project --group-id $varGroup.id | ConvertFrom-Json | Get-Member | Where-Object { $_.Name -eq $varKey }
            if (!$variables) {
                Write-Output "Create new variable"
                az pipelines variable-group variable create --org $organization --project $project --group-id $varGroup.id --name $varKey --value $varValue --secret $isSecret --output table
            }
            else {
                Write-Output "Update new variable"
                az pipelines variable-group variable update --org $organization --project $project --group-id $varGroup.id --name $varKey --value $varValue --secret $isSecret --output table
            }
        }
    }
    else {
        #New script inserting all variables that are supplied
        $Key = $(@($variables.Keys)[0])
        $Value = $variables.$Key
        $varcombined = [string]::IsNullOrWhitespace($outPutPrefix) ? "$Key=$Value" : "$outPutPrefix-$Key=$Value"

        $Groups = az pipelines variable-group list --org $organization --project $project | ConvertFrom-Json
        $varGroup = $Groups | Where-Object { $_.name -eq $variableGroup }

        if (!$varGroup) {
            Write-Output "Creating variable group"
            $varGroup = az pipelines variable-group create --org $organization --project $project --name $variableGroup --variables $varcombined --authorize | ConvertFrom-Json
        }

        $variableList = az pipelines variable-group variable list --org $organization --project $project --group-id $varGroup.id | ConvertFrom-Json

        foreach ($var in $variables.GetEnumerator()) {
            $Key = [string]::IsNullOrWhitespace($outPutPrefix) ? "$($var.Name)" : "$outPutPrefix-$($var.Name)"
            $Value = $var.Value.Value
            if (!$Value) {
                $Value = $variables."$($var.Name)"
            }

            if (![string]::IsNullOrWhiteSpace($Value)) {
                Write-Output "Updating variable group"
                $variableItem = $variableList | Get-Member | Where-Object { $_.Name -eq $Key }
                if (!$variableItem) {
                    Write-Output "Create new variable '$Key'"
                    az pipelines variable-group variable create --org $organization --project $project --group-id $varGroup.id --name $Key --value $Value --secret $isSecret --output table
                }
                else {
                    Write-Output "Update variable '$Key'"
                    az pipelines variable-group variable update --org $organization --project $project --group-id $varGroup.id --name $Key --value $Value --secret $isSecret --output table
                }
            }
            else {
                Write-Host "Value for '$Key' is Empty, not updating group"
            }
        }
    }
}
