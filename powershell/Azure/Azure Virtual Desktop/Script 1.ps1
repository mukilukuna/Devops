# Admin registervermelding instellen en Explorer proces stoppen
$adminRegEntry = 'HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A7-37EF-4b3f-8CFC-4F3A74704073}'
Set-ItemProperty -Path $adminRegEntry -Name 'IsInstalled' -Value 0
Stop-Process -Name Explorer -Force

# Aanmaken van Active Directory organisatorische eenheden
New-ADOrganizationalUnit -Name 'ToSync' -Path 'DC=adatum,DC=com' -ProtectedFromAccidentalDeletion $false

New-ADOrganizationalUnit -Name 'WVDClients' -Path 'DC=adatum,DC=com' -ProtectedFromAccidentalDeletion $false

New-ADOrganizationalUnit -Name 'WVDInfra' –Path 'DC=adatum,DC=com' -ProtectedFromAccidentalDeletion $false
