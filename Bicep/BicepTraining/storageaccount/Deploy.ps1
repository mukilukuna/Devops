$location = "westeurope"
$name = "rg-liteuezusto"
$templatefile = "C:\Users\mukil\OneDrive\Documenten\Vs Code\Devops\Devops\Bicep\bicep training\StorageAccount\main.bicep"

$context = Get-AzContext

if (-not $context -or -not $context.Account) {
    Connect-AzAccount
}

New-AzResourceGroup -Name $name -Location $location

New-AzResourceGroupDeployment -ResourceGroupName $name -TemplateFile $templatefile
