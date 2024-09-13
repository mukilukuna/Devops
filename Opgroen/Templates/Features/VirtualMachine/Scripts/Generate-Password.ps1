param(
    $parameterFile
)

$parameters = Get-Content $parameterFile | ConvertFrom-Json

$keyVaultResourceId = $parameters.parameters.adminPasswordKeyVault.value
if (!$keyVaultResourceId) { exit }

$applicationName = $parameters.parameters.applicationName.value
$regionName = $parameters.parameters.regionName.value
$roleName = $parameters.parameters.roleName.value
$dtapName = $parameters.parameters.dtapName.value
$serialNumber = $parameters.parameters.serialNumber.value
$osType = $parameters.parameters.image.value.osType

$password = ([char[]](Get-Random -Input $(48..57 + 65..90 + 97..122 + 33..33 + 35..35 + 63..64) -Count 16)) -join ""
$secret = ConvertTo-SecureString -String $password -AsPlainText -Force

if ($osType -eq "linux") { $osLetter = 'l' } else { $osLetter = 'w' }

$vmName = (($applicationName + "-" + $regionName + $osLetter + $roleName + $dtapName).ToLower() + $serialNumber.toString().PadLeft(2, '0'))
$secretName = $vmName + '-password'

$keyVault = Get-AzResource -ResourceId $keyVaultResourceId

if (!(Get-AzKeyVaultSecret -VaultName $keyVault.Name -Name $secretName)) {
    Set-AzKeyVaultSecret -VaultName $keyVault.Name -Name $secretname -SecretValue $secret -ContentType 'password';
} else {
    Write-Warning "Keyvaultsecrect $secretName already exists."
}
