param(
    $resourceGroup,
    $parameterFile
)

$parameters = Get-Content $parameterFile | ConvertFrom-Json

$applicationName = $parameters.parameters.applicationName.value
$regionName = $parameters.parameters.regionName.value
$dtapName = $parameters.parameters.dtapName.value

$vaultName = ($applicationName + "-" + $regionName + "-" + $dtapName + "-*")
$keyVault = Get-AzKeyVault -ResourceGroupName $resourceGroup -VaultName $vaultName
if (!$keyVault) {
    exit
}
$keyVaultAccessPolicies = (Get-AzKeyVault -ResourceGroupName $resourceGroup -VaultName $keyVault.VaultName).accessPolicies

$armAccessPolicies = @()

if ($keyVaultAccessPolicies) {
    foreach ($keyVaultAccessPolicy in $keyVaultAccessPolicies) {
        $armAccessPolicy = [PSCustomObject]@{
            tenantId                = $keyVaultAccessPolicy.TenantId
            objectId                = $keyVaultAccessPolicy.ObjectId
            keysPermissions         = $keyVaultAccessPolicy.PermissionsToKeys
            secretsPermissions      = $keyVaultAccessPolicy.PermissionsToSecrets
            certificatesPermissions = $keyVaultAccessPolicy.PermissionsToCertificates
        }

        $armAccessPolicies += $armAccessPolicy
    }
}

$armAccessPoliciesParameter = [PSCustomObject]@{
    list = $armAccessPolicies
}

$armAccessPoliciesParameter = $armAccessPoliciesParameter | ConvertTo-Json -Depth 5 -Compress

Write-Host ("##vso[task.setvariable variable=existingAccessPolicies;]$armAccessPoliciesParameter")