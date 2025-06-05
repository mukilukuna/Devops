# Script: AzureAD_Group_AddUsers.ps1
# Purpose: AzureAD Group AddUsers
connect-azuread

$csv = Get-Content c:\temp\ism_xx.csv
foreach ($line1 in $csv) {
    $Users1 = Get-AzureADUser -ObjectId $line1
    $Users1 | ForEach { Add-AzureADGroupMember -ObjectId 16d6f671-63b6-4eb6-b53c-4309bf0b92e1 -RefObjectId $Users1.ObjectID }
}