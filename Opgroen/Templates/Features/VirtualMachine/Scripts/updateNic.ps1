param (
    [string] $IpAddress,

    [string] $PrefixLength,

    [string] $DnsServer
)
# Primary IP should always be the first in the list
$IpAddresses = $IpAddress -split ':'

# Get the network adapter that currently has the active primary IP
$ipconfig = Get-NetIPConfiguration | Where-Object -FilterScript {$_.ipv4Address.ipaddress -contains $IpAddresses[0]}

# Check if the IP is already set manually, if not, replace
$primaryIpExists = Get-NetIPAddress -IPAddress $IpAddresses[0] -InterfaceIndex $ipconfig.InterfaceIndex -ErrorAction SilentlyContinue
if ($primaryIpExists.PrefixOrigin -ne 'Manual') {
    Remove-NetIPAddress -InterfaceIndex $ipconfig.InterfaceIndex -IPAddress $ipconfig.IPv4Address[0].IPAddress -Confirm:$false
    $null = New-NetIPAddress -IPAddress $IpAddresses[0] -InterfaceIndex $ipconfig.InterfaceIndex -DefaultGateway $ipconfig.IPv4DefaultGateway[0].NextHop -PrefixLength $PrefixLength
}

# Add additional IP Addresses
$IpAddresses | Select-Object -Skip 1 | ForEach-Object -Process {
    $ipExists = Get-NetIPAddress -IPAddress $_ -InterfaceIndex $ipconfig.InterfaceIndex -ErrorAction SilentlyContinue
    if ($null -eq $ipExists) {
        $null = New-NetIPAddress -IPAddress $_ -InterfaceIndex $ipconfig.InterfaceIndex -PrefixLength $PrefixLength -SkipAsSource $true
    }
}

# Configure DNS Servers
Set-DnsClientServerAddress -InterfaceIndex $ipconfig.InterfaceIndex -ServerAddresses ($DnsServer -split ':')
