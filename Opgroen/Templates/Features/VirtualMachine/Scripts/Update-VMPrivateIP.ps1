[cmdletbinding()]
param (
  [Parameter(Mandatory)]
  [ValidateNotNullOrEmpty()]
  [string[]] $VMName,

  [Parameter(Mandatory)]
  [ValidateNotNullOrEmpty()]
  [string] $ResourceGroupName
)

foreach ($v in $VMName) {
  # Get the VM
  $vm = Get-AzureRmVM -ResourceGroupName $ResourceGroupName -Name $v -ErrorAction SilentlyContinue
  if ($null -eq $vm) {
    Write-Warning -Message "Could not find VM with name: $v in $ResourceGroupName"
    continue
  }

  # Get the ipConfigs
  $ipConfigs = Get-AzureRmResource -ResourceId $vm.NetworkProfile.NetworkInterfaces[0].Id |
    Get-AzureRmNetworkInterface | Get-AzureRmNetworkInterfaceIpConfig

  # Find details about network
  $vnetId = ($ipConfigs[0].Subnet.Id -split '/' | Select-Object -SkipLast 2) -join '/'
  $subnetName = $ipConfigs[0].Subnet.Id -split '/' | Select-Object -Last 1
  $vnet = Get-AzureRmResource -ResourceId $vnetId | Get-AzureRmVirtualNetwork
  $cidr = ($vnet.Subnets.Where{$_.Name -eq $subnetName}.AddressPrefix -split '/')[-1]

  # If no DNS servers are configured, set pre-defined as documented at https://docs.microsoft.com/en-us/azure/virtual-network/virtual-network-multiple-ip-addresses-powershell#os-config
  if ($null -eq $vnet.DhcpOptions.DnsServers) {
    $dnsServers = '168.63.129.16'
  } else {
    $dnsServers = $vnet.DhcpOptions.DnsServers -join ':'
  }

  $runArgs = @{
    ResourceGroupName = $vm.ResourceGroupName
    VMName = $vm.Name
    Parameter = @{
      IpAddress = @($ipConfigs.Where{$_.Primary}.PrivateIpAddress; $ipConfigs.Where{-not $_.Primary}.PrivateIpAddress) -join ':'
      PrefixLength = $cidr
      DnsServer = $dnsServers
    }
  }

  if ($vm.StorageProfile.OsDisk.OsType -eq 'Windows') {
    [void] $runArgs.Add('CommandId', 'RunPowerShellScript')
    [void] $runArgs.Add('ScriptPath', "$PSScriptRoot\updateNic.ps1")
  } else {
    [void] $runArgs.Add('CommandId', 'RunShellScript')
    [void] $runArgs.Add('ScriptPath', "$PSScriptRoot\updateNic.sh")
  }

  $result = Invoke-AzureRmVMRunCommand @runArgs

  [pscustomobject]@{
    VM = $v
    Status = $result.Status
    Result = $result
  }
}
