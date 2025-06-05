# Script: ArchiveTeamsChannel.ps1
# Purpose: ArchiveTeamsChannel
$teamId = "" # Your Team ID
$channelId = "" # The Channel ID you want to archive


Invoke-MgBetaArchiveTeamChannel -TeamId $teamId -ChannelId $channelId -ShouldSetSpoSiteReadOnlyForMembers $true  
