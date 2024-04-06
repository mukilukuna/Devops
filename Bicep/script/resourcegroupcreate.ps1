# Check if the Az.Accounts module is installed
if (-Not (Get-Module -ListAvailable -Name Az.Accounts)) {
    # The Az.Accounts module is not installed, attempt to install it
    Write-Host "The Az.Accounts module is not installed. Attempting to install..."
    try {
        # Use the -Force and -AllowClobber parameters to install the latest version and override any conflicts without prompts
        Install-Module -Name Az.Accounts -Scope CurrentUser -Force -AllowClobber
        Write-Host "Az.Accounts module installed successfully."
    } catch {
        Write-Host "Failed to install the Az.Accounts module. Please install it manually and then rerun the script."
        exit
    }
} else {
    Write-Host "The Az.Accounts module is already installed."
}

# Ensure the user is connected to Azure
if (-Not (Get-AzContext)) {
    Write-Host "Please connect to your Azure account..."
    Connect-AzAccount
}
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
