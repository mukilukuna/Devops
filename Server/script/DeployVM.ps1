# Toon PowerShell versie en locatie
Write-Host "PowerShell Version: $($PSVersionTable.PSVersion)"
Write-Host "PowerShell Path: $((Get-Command -Name PowerShell).Source)"

# Variabelen
$resourceGroupName = "ResourceGroupBeroepsProduct"
$location = "West Europe"
$vnetName = "VnetLukunaBV"
$subnetName = "SnetLukunaBV"
$nsgName = "NSGLukunaBV"
$vmSize = "Standard_DS1_v2"
$vmName = "BeroepsPruductLukunaBV" # Voeg de naam van je VM toe
$publicIpName = "MijnPublicIPLukunaBV" # Voeg de naam van je Public IP toe

# Credential opbouwen
$username = $env:vmUsername
$password = ConvertTo-SecureString $env:vmPassword -AsPlainText -Force
$credential = New-Object System.Management.Automation.PSCredential($username, $password)

try {

    #Netwerk
    $vnet = New-AzVirtualNetwork -ResourceGroupName $resourceGroupName -Location $location -Name $vnetName -AddressPrefix "10.0.0.0/16"
    $subnetConfig = Add-AzVirtualNetworkSubnetConfig -Name $subnetName -VirtualNetwork $vnet -AddressPrefix "10.0.0.0/24"
    $vnet | Set-AzVirtualNetwork

    #NSG
    $nsg = New-AzNetworkSecurityGroup -ResourceGroupName $resourceGroupName -Location $location -Name $nsgName
    $ruleConfig = New-AzNetworkSecurityRuleConfig -Name "AllowRDP" -Protocol Tcp -Direction Inbound -Priority 100 -SourceAddressPrefix "*" -SourcePortRange "*" -DestinationAddressPrefix "*" -DestinationPortRange 3389 -Access Allow
    $nsg | Add-AzNetworkSecurityRuleConfig -NetworkSecurityRule $ruleConfig | Set-AzNetworkSecurityGroup

    #PIP
    $publicIp = New-AzPublicIpAddress -ResourceGroupName $resourceGroupName -Location $location -AllocationMethod Static -Name $publicIpName

    # Virtual Machine
    $subnet = Get-AzVirtualNetworkSubnetConfig -Name $subnetName -VirtualNetwork $vnet
    $ipConfig = New-AzNetworkInterfaceIpConfig -Name "ipconfig1" -SubnetId $subnet.Id -PublicIpAddressId $publicIp.Id
    $nic = New-AzNetworkInterface -ResourceGroupName $resourceGroupName -Location $location -Name "$vmName-nic" -IpConfiguration $ipConfig
    New-AzVm -ResourceGroupName $resourceGroupName -Location $location -Name $vmName -NetworkInterfaceId $nic.Id -Image "Win2022Datacenter" -Size $vmSize -Credential $credential
}
catch {
    Write-Host "Er is een fout opgetreden: $_"
}
