Connect-MsolService
Get-MsolUser –UserPrincipalName srv_hef.facturen@hefgroep.nl| Set-MsolUser –PasswordNeverExpires $True
 get-msoluser –UserPrincipalName srv_hef.facturen@hefgroep.nl | ft displayname, passwordneverexpires