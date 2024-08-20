$teamId = "f3ae0351-40f8-4e8c-aab1-33ab0dbce2f0" # Your Team ID
$channelId = "19:XBrqb2EAisvtHIshoxeQV4YekNR96GIM6A_RBEFSavI1@thread.tacv2" # The Channel ID you want to archive


Invoke-MgBetaArchiveTeamChannel -TeamId $teamId -ChannelId $channelId -ShouldSetSpoSiteReadOnlyForMembers $true  
