
if ($($Env:varMultiple -and $Env:preFix) -or $($Env:varMultiple -and [string]::IsNullOrWhitespace($Env:preFix))) {
    . "$($Env:SYSTEM_DEFAULTWORKINGDIRECTORY)/$Env:templateRepo/.Global/Scripts/Add-VariableGroup.ps1"

    $tempVar = $Env:varMultiple | ConvertFrom-Json
    $variable = @{}

    foreach ($e in $tempVar.PSObject.Properties) {
        $name = $e.Name
        $val = $e.Value.Value
        $variable.Add($Name, $Val)
    }

    Add-VariableGroup -variables $variable `
        -outPutPrefix $Env:preFix `
        -organization $env:organization `
        -project $env:project `
        -AZURE_DEVOPS_EXT_PAT $Env:AZURE_DEVOPS_EXT_PAT `
        -variableGroup $env:environment
}
elseif ($Env:varKey -and $Env:varValue) {
    $varcombined = $env:varKey + "=" + $env:varValue

    $varGroup = az pipelines variable-group list --org $env:organization --project $env:project | ConvertFrom-Json | Where-Object { $_.name -eq $env:environment }

    if (!$varGroup) {
        Write-Output "Creating variable group"
        az pipelines variable-group create --org $env:organization --project $env:project --name $env:environment --variables $varcombined --authorize
    }
    else {
        Write-Output "Updating variable group"
        $variables = az pipelines variable-group variable list --org $env:organization --project $env:project --group-id $varGroup.id | ConvertFrom-Json | Get-Member | Where-Object { $_.Name -eq $env:varKey }
        if (!$variables) {
            Write-Output "Create new variable"
            az pipelines variable-group variable create --org $env:organization --project $env:project --group-id $varGroup.id --name $env:varKey --value $env:varValue --secret $env:isSecret --output table
        }
        else {
            Write-Output "Update new variable"
            az pipelines variable-group variable update --org $env:organization --project $env:project --group-id $varGroup.id --name $env:varKey --value $env:varValue --secret $env:isSecret --output table
        }
    }
}
else {
    Write-Error "Not all variables are supplied. This is necessary for adding values to the library"
    exit 1
}


