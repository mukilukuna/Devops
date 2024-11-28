# Lijst van Teams en de gevoeligheidslabels die je wilt toepassen
$teams = @(
    @{TeamName = ""; LabelGuid = "" },
    @{TeamName = ""; LabelGuid = "" },
    @{TeamName = ""; LabelGuid = "" }
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
