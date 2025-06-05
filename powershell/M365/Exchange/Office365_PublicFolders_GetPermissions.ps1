# Script: Office365_PublicFolders_GetPermissions.ps1
# Purpose: Office365 PublicFolders GetPermissions
Connect-ExchangeOnline
#SMTP Adresses
Get-MailPublicFolder | ft Alias, PrimarySmtpAddress

#Permissions
$Result=@()
$allFolders = Get-PublicFolder -Recurse -ResultSize Unlimited
$totalfolders = $allFolders.Count
$i = 1 
$allFolders | ForEach-Object {
$folder = $_
Write-Progress -activity "Processing $folder" -status "$i out of $totalfolders completed"
$folderPerms = Get-PublicFolderClientPermission -Identity $folder.Identity
$folderPerms | ForEach-Object {
$Result += New-Object PSObject -property @{ 
Folder = $folder.Identity
User = $_.User
Permissions = $_.AccessRights
}}
$i++
}
$Result | Select Folder, User, Permissions |
Export-CSV "C:\temp\1PublicFolderPermissions.CSV" -NoTypeInformation -Encoding UTF8