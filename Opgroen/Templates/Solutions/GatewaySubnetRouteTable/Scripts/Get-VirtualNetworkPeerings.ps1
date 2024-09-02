[CmdletBinding()]
param (
    [Parameter(Mandatory = $false)] [string] $Subscriptionid
)

Set-AzContext -SubscriptionId $Subscriptionid
$vnetName = $env:vnetName
$location = $PSScriptRoot + '/VirtualNetworkPeerings.json'
$peering = (Get-AzVirtualNetwork -Name $vnetName).VirtualNetworkPeerings

If ($peering) {
    Write-Host "Peering Information: $($peering | Out-String)"
    $peering | ConvertTo-Json -Depth 99 -AsArray | Out-File $location
} else {
    Write-Host "No peerings found."
}