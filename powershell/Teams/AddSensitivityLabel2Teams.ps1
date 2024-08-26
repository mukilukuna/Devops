# Lijst van Teams en de gevoeligheidslabels die je wilt toepassen
$teams = @(
    @{TeamName = "RAZ"; LabelGuid = "6f5b5cbf-641f-4fe8-8454-e84d86455685" },
    @{TeamName = "Bedrijfsvoering"; LabelGuid = "6f5b5cbf-641f-4fe8-8454-e84d86455685" },
    @{TeamName = "Projecten"; LabelGuid = "6f5b5cbf-641f-4fe8-8454-e84d86455685" }
)

# Loop door de lijst van Teams en pas het gevoeligheidslabel toe
foreach ($team in $teams) {
    try {
        # Haal het Team ID op basis van de teamnaam
        $group = Get-Team -DisplayName $team.TeamName

        if ($group) {
            # Pas het gevoeligheidslabel toe met de GUID
            Set-UnifiedGroup -Identity $group.GroupId -SensitivityLabelId $team.LabelGuid
            Write-Host "Gevoeligheidslabel '$($team.LabelGuid)' succesvol toegepast op team '$($team.TeamName)'."
        }
        else {
            Write-Host "Team '$($team.TeamName)' niet gevonden."
        }
    }
    catch {
        Write-Host "Fout bij het toepassen van gevoeligheidslabel op team '$($team.TeamName)': $_"
    }
}
