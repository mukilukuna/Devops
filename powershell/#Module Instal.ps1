#MODULE INSTAL
Install-Module ExchangeOnlineManagement
Import-Module ExchangeOnlineManagement

#VERBINDEN MET EXCHANGE ONLINE
Connect-ExchangeOnline -UserPrincipalName #<ADMIN E-MAIL ACCOUNT INVOEREN>

# TOP 10 GROOTSTE MAILBOXEN TONEN
Get-Mailbox -ResultSize Unlimited | Get-MailboxStatistics | Sort-Object TotalItemSize -Descending | Select-Object DisplayName, TotalItemSize -First 10

#TOP 10 GROOTSTE MAILBOXEN EXPORTEREN NAAR EEN CSV IN C:\TEMP
Get-Mailbox -ResultSize Unlimited | Get-MailboxStatistics | Sort-Object TotalItemSize -Descending | Select-Object DisplayName, TotalItemSize -First 100 | Export-CSV C:\TEMP\top100mailboxes.csv

