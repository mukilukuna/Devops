#JVM delete all ADgroups from disabled OU#
$OU = "OU=2021,OU=Disabled,OU=Users,OU=HD Medi bv,DC=hdmedi,DC=eu"
$Users = Get-ADUser -SearchBase $OU -Filter *

Get-ADGroup -Filter * |
Remove-ADGroupMember -Members $users -Confirm:$False