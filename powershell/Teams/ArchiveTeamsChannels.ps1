# Variables
$teamId = "f3ae0351-40f8-4e8c-aab1-33ab0dbce2f0"  # Your Team ID

# Connect to Microsoft Graph with the required permissions
Connect-MgGraph -Scopes "ChannelSettings.ReadWrite.All"

# Get all channels in the team
$channels = Get-TeamChannel -GroupId $teamId

# Loop through each channel and archive it
foreach ($channel in $channels) {
    $channelId = $channel.Id
    try {
        # Archive the channel
        Invoke-MgBetaArchiveTeamChannel -TeamId $teamId -ChannelId $channelId -ShouldSetSpoSiteReadOnlyForMembers
        Write-Host "Successfully archived channel: $($channel.DisplayName)"
    } catch {
        Write-Host "Failed to archive channel: $($channel.DisplayName) - $_"
    }
}

# Disconnect from Microsoft Graph
Disconnect-MgGraph
