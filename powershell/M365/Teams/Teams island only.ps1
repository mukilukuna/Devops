##Change Teams Island mode to Teams Only##
##Teams Powershell module installeren##
Install-Module -Name MicrosoftTeams

#Verbinden naar Tenant#
Connect-MicrosoftTeams

##verander username@contoso.com met de echte gebruikersnaam##
Grant-CsTeamsUpgradePolicy -PolicyName UpgradeToTeams -Identity username@contoso.com

##voor alle gebruikers binnen een tennant
##Grant-CsTeamsUpgradePolicy -PolicyName UpgradeToTeams -Global##