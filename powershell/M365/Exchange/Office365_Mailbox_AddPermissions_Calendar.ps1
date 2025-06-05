# Script: Office365_Mailbox_AddPermissions_Calendar.ps1
# Purpose: Office365 Mailbox AddPermissions Calendar
$LiveCred = Get-Credential
$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://ps.outlook.com/powershell/ -Credential $LiveCred -Authentication Basic –AllowRedirection
Import-PSSession $Session
Get-MailboxFolderPermission mukaddes.kilayikli@SMWR-Rijnmond.nl:\agenda 

#DONE
Add-MailboxFolderPermission -Identity ricardo.danning@stichting-joz.nl:\agenda -user linda.alders@kinderdam-hefgroep.nl -AccessRights Editor
Add-MailboxFolderPermission -Identity nadia.barquioua@stichting-joz.nl:\agenda -user linda.alders@kinderdam-hefgroep.nl -AccessRights Editor
Add-MailboxFolderPermission -Identity guilherme.dagraca@stichting-joz.nl:\agenda -user linda.alders@kinderdam-hefgroep.nl -AccessRights Editor
Add-MailboxFolderPermission -Identity fabian.keerveld@stichting-joz.nl:\agenda -user linda.alders@kinderdam-hefgroep.nl -AccessRights Editor
Add-MailboxFolderPermission -Identity habtom.ghebresellasie@stichting-joz.nl:\agenda -user linda.alders@kinderdam-hefgroep.nl -AccessRights Editor
Add-MailboxFolderPermission -Identity fouad.albouayadi@stichting-joz.nl:\agenda -user linda.alders@kinderdam-hefgroep.nl -AccessRights Editor
Add-MailboxFolderPermission -Identity jurre.bardoel@stichting-joz.nl:\agenda -user linda.alders@kinderdam-hefgroep.nl -AccessRights Editor

#Remove-MailboxFolderPermission -Identity mukaddes.kilayikli@SMWR-Rijnmond.nl:\agenda -user inez.brouwer@kinderdam-hefgroep.nl

Add-MailboxFolderPermission -Identity mukaddes.kilayikli@SMWR-Rijnmond.nl:\agenda -user inez.brouwer@kinderdam-hefgroep.nl -AccessRights Editor
Add-MailboxFolderPermission -Identity nadia.barquioua@stichting-joz.nl:\agenda -user inez.brouwer@kinderdam-hefgroep.nl -AccessRights Editor
#Add-MailboxFolderPermission -Identity therese.denboer@hefgroep.nl:\agenda -user inez.brouwer@kindemukgroep.nl -AccessRights Editor
#Add-MailboxFolderPermission -Identity elisa.vansplunder@hefgroep.nl:\agenda -user inez.brouwer@kinderdam-hefgroep.nl -AccessRights Editor
#Add-MailboxFolderPermission -Identity linda.alders@hefgroep.nl:\agenda -user inez.brouwer@kinderdam-hefgroep.nl -AccessRights Editor
Add-MailboxFolderPermission -Identity ana.cudina@SMWR-Rijnmond.nl:\agenda -user inez.brouwer@kinderdam-hefgroep.nl -AccessRights Editor

Add-MailboxFolderPermission -Identity ayse.kolay@SMWR-Rijnmond.nl:\agenda -user inez.brouwer@kinderdam-hefgroep.nl -AccessRights Editor
Add-MailboxFolderPermission -Identity birgul.atas@smwr-rijnmond.nl:\agenda -user inez.brouwer@kinderdam-hefgroep.nl -AccessRights Editor
Add-MailboxFolderPermission -Identity charline.hoogerwerf@SMWR-Rijnmond.nl:\agenda -user inez.brouwer@kinderdam-hefgroep.nl -AccessRights Editor
#Add-MailboxFolderPermission -Identity charlotte.dekker@hefgroep.nl:\agenda -user inez.brouwer@kinderdam-hefgroep.nl -AccessRights Editor
Add-MailboxFolderPermission -Identity cindy.breidel@SMWR-Rijnmond.nl:\agenda -user inez.brouwer@kinderdam-hefgroep.nl -AccessRights Editor
Add-MailboxFolderPermission -Identity corine.kleppe@smwr-rijnmond.nl:\agenda -user inez.brouwer@kinderdam-hefgroep.nl -AccessRights Editor

Add-MailboxFolderPermission -Identity debby.vanroijen@SMWR-Rijnmond.nl:\agenda -user inez.brouwer@kinderdam-hefgroep.nl -AccessRights Editor
Add-MailboxFolderPermission -Identity emily.stam@SMWR-Rijnmond.nl:\agenda -user inez.brouwer@kinderdam-hefgroep.nl -AccessRights Editor
Add-MailboxFolderPermission -Identity ena.delic@SMWR-Rijnmond.nl:\agenda -user inez.brouwer@kinderdam-hefgroep.nl -AccessRights Editor
Add-MailboxFolderPermission -Identity fatma.sener@SMWR-Rijnmond.nl:\agenda -user inez.brouwer@kinderdam-hefgroep.nl -AccessRights Editor
Add-MailboxFolderPermission -Identity hajar.bourakba@SMWR-Rijnmond.nl:\agenda -user inez.brouwer@kinderdam-hefgroep.nl -AccessRights Editor
Add-MailboxFolderPermission -Identity hasnae.hamdi@SMWR-Rijnmond.nl:\agenda -user inez.brouwer@kinderdam-hefgroep.nl -AccessRights Editor

Add-MailboxFolderPermission -Identity jenny.balgobind@smwr-rijnmond.nl:\agenda -user inez.brouwer@kinderdam-hefgroep.nl -AccessRights Editor
#Add-MailboxFolderPermission -Identity kim.vansolinge@SMWR-Rijnmond.nl:\agenda -user inez.brouwer@kinderdam-hefgroep.nl -AccessRights Editor
Add-MailboxFolderPermission -Identity leila.sakkali@SMWR-Rijnmond.nl:\agenda -user inez.brouwer@kinderdam-hefgroep.nl -AccessRights Editor
Add-MailboxFolderPermission -Identity mariska.broekhoff@SMWR-Rijnmond.nl:\agenda -user inez.brouwer@kinderdam-hefgroep.nl -AccessRights Editor
Add-MailboxFolderPermission -Identity miriam.meier@SMWR-Rijnmond.nl:\agenda -user inez.brouwer@kinderdam-hefgroep.nl -AccessRights Editor
Add-MailboxFolderPermission -Identity nadia.benhaddou@smwr-rijnmond.nl:\agenda -user inez.brouwer@kinderdam-hefgroep.nl -AccessRights Editor
Add-MailboxFolderPermission -Identity natascha.waalring@SMWR-Rijnmond.nl:\agenda -user inez.brouwer@kinderdam-hefgroep.nl -AccessRights Editor
Add-MailboxFolderPermission -Identity nelleke.torn@smwr-rijnmond.nl:\agenda -user inez.brouwer@kinderdam-hefgroep.nl -AccessRights Editor

Add-MailboxFolderPermission -Identity susan.koole@SMWR-Rijnmond.nl:\agenda -user inez.brouwer@kinderdam-hefgroep.nl -AccessRights Editor
Add-MailboxFolderPermission -Identity susanna.ricci@smwr-rijnmond.nl:\agenda -user inez.brouwer@kinderdam-hefgroep.nl -AccessRights Editor
Add-MailboxFolderPermission -Identity susanne.blokzijl@smwr-rijnmond.nl:\agenda -user inez.brouwer@kinderdam-hefgroep.nl -AccessRights Editor
Add-MailboxFolderPermission -Identity suzanne.tol@SMWR-Rijnmond.nl:\agenda -user inez.brouwer@kinderdam-hefgroep.nl -AccessRights Editor
#Add-MailboxFolderPermission -Identity arjan.verwoerd@hefgroep.nl:\agenda -user inez.brouwer@kinderdam-hefgroep.nl -AccessRights Editor
#Add-MailboxFolderPermission -Identity rene.segers@peuterenco.nl:\agenda -user inez.brouwer@kinderdam-hefgroep.nl -AccessRights Editor

Add-MailboxFolderPermission -Identity elisa.vansplunder@hefgroep.nl:\agenda -user inez.brouwer@kinderdam-hefgroep.nl -AccessRights Editor

