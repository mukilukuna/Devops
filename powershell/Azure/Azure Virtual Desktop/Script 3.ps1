# Aanmaken van Active Directory beveiligingsgroepen en gebruikers toevoegen aan groepen
$ouPath = "OU=ToSync,DC=adatum,DC=com" # Definieer het pad voor de OU

# Groepen aanmaken
New-ADGroup -Name 'az140-wvd-pooled' -GroupScope Global -GroupCategory Security -Path $ouPath
New-ADGroup -Name 'az140-wvd-remote-app' -GroupScope Global -GroupCategory Security -Path $ouPath
New-ADGroup -Name 'az140-wvd-personal' -GroupScope Global -GroupCategory Security -Path $ouPath
New-ADGroup -Name 'az140-wvd-users' -GroupScope Global -GroupCategory Security -Path $ouPath
New-ADGroup -Name 'az140-wvd-admins' -GroupScope Global -GroupCategory Security -Path $ouPath

# Gebruikers toevoegen aan groepen
Add-AdGroupMember -Identity 'az140-wvd-pooled' -Members 'aduser1', 'aduser2', 'aduser3', 'aduser4'
Add-AdGroupMember -Identity 'az140-wvd-remote-app' -Members 'aduser1', 'aduser5', 'aduser6'
Add-AdGroupMember -Identity 'az140-wvd-personal' -Members 'aduser7', 'aduser8', 'aduser9'
Add-AdGroupMember -Identity 'az140-wvd-users' -Members 'aduser1', 'aduser2', 'aduser3', 'aduser4', 'aduser5', 'aduser6', 'aduser7', 'aduser8', 'aduser9'
Add-AdGroupMember -Identity 'az140-wvd-admins' -Members 'wvdadmin1'
