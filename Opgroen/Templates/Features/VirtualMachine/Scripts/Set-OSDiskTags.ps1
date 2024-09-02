param(
    $ArmOutput,
    $ResourceGroupName
)

$JsonOutput = $ArmOutput | ConvertFrom-Json
$JsonOutput.osDiskTags.Value.PSObject.Properties | %{ $Tags=@{} } { $Tags.Add($_.Name, $_.Value) }

Get-AzResource -ResourceType Microsoft.Compute/disks -ResourceGroupName $ResourceGroupName -Name "$($JsonOutput.vmName.value)-md-os" | Set-AzResource -Tag $Tags -Force