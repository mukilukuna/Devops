Connect-AzAccount

# Variable to hold the customer code
$customerCode = "CIR" # Replace <customercode> with the actual customer code

# Azure location where the resource groups will be created
$location = "westeurope"

# Names of the resource groups to be created
$resourceGroupNames = @("${customerCode}euazunet", "${customerCode}euazuhost", "${customerCode}euazustor")

# Loop through each name and create the resource group
foreach ($name in $resourceGroupNames) {
    # Check if the Resource Group already exists
    $resourceGroupExists = Get-AzResourceGroup -Name $name -ErrorAction SilentlyContinue
    if (-Not $resourceGroupExists) {
        # Create the Resource Group since it does not exist
        New-AzResourceGroup -Name $name -Location $location
        Write-Host "Resource Group '$name' created in $location."
    } else {
        Write-Host "Resource Group '$name' already exists."
    }
}
