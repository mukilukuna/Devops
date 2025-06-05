# Aanmaken van gebruikers in de specifieke OU en een gebruiker toevoegen aan 'Domain Admins'
$ouName = 'ToSync'
$ouPath = "OU=$ouName,DC=adatum,DC=com"
$adUserNamePrefix = 'aduser'
$adUPNSuffix = 'adatum.com'
$userCount = 1..9

# Gebruikersreeks aanmaken
foreach ($counter in $userCount) {
   New-AdUser -Name "${adUserNamePrefix}${counter}" -Path $ouPath -Enabled $True `
      -ChangePasswordAtLogon $false -UserPrincipalName "${adUserNamePrefix}${counter}@${adUPNSuffix}" `
      -AccountPassword (ConvertTo-SecureString 'YourPasswordHere' -AsPlainText -Force) -PassThru
}

# Admin gebruiker aanmaken
$adUserNamePrefix = 'wvdadmin1'
New-AdUser -Name $adUserNamePrefix -Path $ouPath -Enabled $True `
   -ChangePasswordAtLogon $false -UserPrincipalName "${adUserNamePrefix}@${adUPNSuffix}" `
   -AccountPassword (ConvertTo-SecureString '6l3oswU_i4AphlspAdl2' -AsPlainText -Force) -PassThru

# Admin gebruiker toevoegen aan 'Domain Admins'
Get-ADGroup -Identity 'Domain Admins' | Add-AdGroupMember -Members $adUserNamePrefix
