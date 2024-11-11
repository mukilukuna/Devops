# Controleer of de Azure PowerShell-module geïnstalleerd is en installeer zo nodig
if (!(Get-Module -ListAvailable -Name Az)) {
    Write-Host "Azure PowerShell module not found. Installing..."
    Install-Module -Name Az -AllowClobber -Scope CurrentUser -Force
}
else {
    Write-Host "Azure PowerShell module is already installed."
}

# Importeer de Az module
Import-Module Az

# Aanmelden bij de Azure-tenant met Device Code Authentication
Write-Host "Logging in to Azure. Follow the instructions to authenticate."
$account = Connect-AzAccount -UseDeviceAuthentication

# Lijst subscriptions
Write-Host "Available Subscriptions:"
$subscriptions = Get-AzSubscription | ForEach-Object { $_.SubscriptionId + " - " + $_.Name }
$subscriptions | ForEach-Object { Write-Host $_ }

# Vraag de gebruiker om een subscription-ID
$subscriptionId = Read-Host -Prompt "Enter the Subscription ID you want to use"
if (-not [string]::IsNullOrWhiteSpace($subscriptionId)) {
    Set-AzContext -SubscriptionId $subscriptionId
}
else {
    Write-Host "No Subscription ID provided. Exiting script."
    exit
}

# Lijst resourcegroepen in de geselecteerde subscription
Write-Host "Available Resource Groups in subscription ${subscriptionId}:"
$resourceGroups = Get-AzResourceGroup | ForEach-Object { $_.ResourceGroupName }
$resourceGroups | ForEach-Object { Write-Host $_ }

# Vraag de gebruiker om de naam van de resourcegroep
$resourceGroupName = Read-Host -Prompt "Enter the Resource Group name where resources will be created"
if (-not [string]::IsNullOrWhiteSpace($resourceGroupName)) {
    Write-Host "Resource group selected: $resourceGroupName"
}
else {
    Write-Host "No Resource Group name provided. Exiting script."
    exit
}

# Variabelen definiëren met gebruikersinput
$Customer = Read-Host -Prompt "Enter the customer name"  # Vraagt om de klantnaam
$Octet = Read-Host -Prompt "Enter the second octet for the VNet IP address (1-255, e.g., 200 for 10.200.0.0/16)"  # Vraagt om het tweede octet
if ($Octet -lt 1 -or $Octet -gt 255) {
    Write-Host "Invalid second octet. Please provide a value between 1 and 255."
    exit
}
$location = "westeurope"  # Locatie is altijd West Europe

# Definieer VNet en subnet-adresbereiken
$vnetAddress = "10.$Octet.0.0/16"
$prodSubnetAddress = "10.$Octet.10.0/24"
$avdSubnetAddress = "10.$Octet.20.0/24"

# VNet naam en Subnet namen definiëren
$vnetName = "$Customer-EUAZU-VNET"
$prodSubnetName = "$Customer-EUAZU-SUBNET-10.$Octet.10.0-PROD"
$avdSubnetName = "$Customer-EUAZU-SUBNET-10.$Octet.20.0-AVD"

# NAT Gateway en Public IP voor NAT Gateway
$natGatewayName = "$Customer-EUAZU-NAT-AVD"
$natPublicIPName = "$Customer-EUAZU-NAT-PIP-AVD"

# VNet aanmaken
$vnet = New-AzVirtualNetwork -ResourceGroupName $resourceGroupName -Location $location `
    -Name $vnetName -AddressPrefix $vnetAddress

# Productie Subnet toevoegen
Add-AzVirtualNetworkSubnetConfig -Name $prodSubnetName -AddressPrefix $prodSubnetAddress `
    -VirtualNetwork $vnet

# AVD Subnet toevoegen
Add-AzVirtualNetworkSubnetConfig -Name $avdSubnetName -AddressPrefix $avdSubnetAddress `
    -VirtualNetwork $vnet

# Wijzigingen in VNet toepassen
$vnet | Set-AzVirtualNetwork

# Public IP voor NAT Gateway aanmaken
$natPublicIP = New-AzPublicIpAddress -ResourceGroupName $resourceGroupName -Location $location `
    -Name $natPublicIPName -Sku Standard -AllocationMethod Static

# NAT Gateway aanmaken en koppelen aan Public IP
$natGateway = New-AzNatGateway -ResourceGroupName $resourceGroupName -Location $location `
    -Name $natGatewayName -PublicIpAddress @($natPublicIP) -Sku Standard

# NAT Gateway koppelen aan AVD Subnet
$avdSubnetConfig = $vnet | Get-AzVirtualNetworkSubnetConfig -Name $avdSubnetName
$avdSubnetConfig.NatGateway = $natGateway

# Wijzigingen in VNet toepassen (inclusief NAT Gateway koppeling aan AVD subnet)
$vnet | Set-AzVirtualNetwork

Write-Host "Virtueel netwerk $vnetName en bijbehorende resources zijn succesvol aangemaakt."
