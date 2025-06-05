# Script: Office365_Users_CreationDate.ps1
# Purpose: Office365 Users CreationDate
Connect-AzureAD 

$Report = @()
$AAD_users = Get-AzureADUser -All:$true
foreach ($AAD_User in $AAD_users) {
$objReport = [PSCustomObject]@{
User     = $AAD_User.UserPrincipalName
CreationDate  = (Get-AzureADUserExtension -ObjectId $AAD_User.ObjectId).Get_Item("createdDateTime")
}
$Report += $objReport
}
$Report

$Report| Export-CSV "C:\TEMP\aad_users.csv"