# Script: DET_WUPGRADE.ps1
# Purpose: DET WUPGRADE
Try {
	
    Write-Host "Resolving winget Path"
	
    ## Help System to find winget.exe
    $JBNWinGetResolve = Resolve-Path "C:\Program Files\WindowsApps\Microsoft.DesktopAppInstaller_*_x64__8wekyb3d8bbwe\winget.exe"
    $JBNWinGetPathExe = $JBNWinGetResolve[-1].Path
    $JBNWinGetPath = Split-Path -Path $JBNWinGetPathExe -Parent
    set-location $JBNWinGetPath

    Write-Host "Path: $JBNWinGetPath"
	
    Write-Host "Starting winget: .\winget.exe upgrade --accept-source-agreements"
    $updatecheck = .\winget.exe upgrade --accept-source-agreements
    Write-Host "winget upgrade --accept-source-agreements finished"
	
    $updatecheckmatches = $updatecheck | Select-String '(.+) upgrades available' -AllMatches 	
    if ($updatecheckmatches -ne $null) {
        $nof_matches = [int]$updatecheckmatches.matches.groups[1].value
	
        if ($nof_matches -ge 3) {
            $outputstring = "Not Ok, " + $nof_matches + " updates pending"
            Write-Warning -Message $outputstring	
            exit 1
        }
        else {
            Write-Host "Semi Ok, " + $nof_matches + " updates pending"
            exit 0
        }
    }

    $updatecheckmatches2 = $updatecheck | Select-String 'No installed package found matching input criteria' -AllMatches 	
    if ($updatecheckmatches2 -ne $null) {
        Write-Host "Ok, no updates pending"
        exit 0
    }

    Write-Warning "Not Ok, regex fail"
    exit 1

} 
catch {
    $errMsg = "Exception: " + $_.Exception.Message + " At: " + $_.ScriptStackTrace
    $strippederrMsag = $errMsg -replace '\r\n', ','
    Write-Warning $strippederrMsag
    #Write-Warning "Exception"
    exit 1
}

Write-Warning "Not Ok, outside try catch.. should not be here"
exit 1
