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
$vmName = "BeroepsPruductLukunaBV"
$publicIpName = "MijnPublicIPLukunaBV"

# Credential opbouwen
$username = $env:vmUsername
$password = ConvertTo-SecureString $env:vmPassword -AsPlainText -Force
$credential = New-Object System.Management.Automation.PSCredential($username, $password)
Write-Host "Username: $env:vmUsername"
Write-Host "Password: $($env:vmPassword -replace '.', '*')"

try {
    # Netwerk
    $vnet = New-AzVirtualNetwork -ResourceGroupName $resourceGroupName -Location $location -Name $vnetName -AddressPrefix "10.0.0.0/16"
    $subnetConfig = Add-AzVirtualNetworkSubnetConfig -Name $subnetName -VirtualNetwork $vnet -AddressPrefix "10.0.0.0/24"
    $vnet | Set-AzVirtualNetwork

    # NSG
    $nsg = New-AzNetworkSecurityGroup -ResourceGroupName $resourceGroupName -Location $location -Name $nsgName

    # PIP
    $publicIp = New-AzPublicIpAddress -ResourceGroupName $resourceGroupName -Location $location -AllocationMethod Static -Name $publicIpName

    # Haal het volledige subnet-ID op
    $vnet = Get-AzVirtualNetwork -ResourceGroupName $resourceGroupName -Name $vnetName
    $subnet = $vnet.Subnets | Where-Object { $_.Name -eq $subnetName }
    Write-Host "Subnet ID: $($subnet.Id)"

    # Virtual Machine
    $ipConfig = New-AzNetworkInterfaceIpConfig -Name "ipconfig1" -SubnetId $subnet.Id -PublicIpAddressId $publicIp.Id
    $nic = New-AzNetworkInterface -ResourceGroupName $resourceGroupName -Location $location -Name "$vmName-nic" -IpConfiguration $ipConfig
    $vmConfig = New-AzVMConfig -VMName $vmName -VMSize $vmSize
    $vmConfig = Set-AzVMOperatingSystem -VM $vmConfig -Windows -ComputerName $vmName -Credential $credential
    $vmConfig = Set-AzVMSourceImage -VM $vmConfig -PublisherName "MicrosoftWindowsServer" -Offer "WindowsServer" -Skus "2019-Datacenter" -Version "latest"
    $vmConfig = Add-AzVMNetworkInterface -VM $vmConfig -Id $nic.Id

    New-AzVm -ResourceGroupName $resourceGroupName -Location $location -VM $vmConfig
}
catch {
    Write-Host "Er is een fout opgetreden: $_"
    if ($_ -match "Cannot bind argument to parameter 'String'") {
        Write-Host "Controleer de waarden van vmUsername en vmPassword in de omgevingsvariabelen."
    }
}
