param(
    $FilePath,
    $BicepTemplate,
    $OutFile
)

try {
    Write-Host "compileren van bicep naar arm____________________"
    Write-Host "FilePath: ${FilePath}"
    Write-Host "BicepTemplate: ${BicepTemplate}"
    Write-Host "OutFile: ${OutFile}"
    Write-Host "_________________________________________________"
    az bicep upgrade
    az bicep build --file "${FilePath}/${BicepTemplate}" --outfile "${FilePath}/${OutFile}"
    $Files = get-cjilditem -path "${FilePath}"
    Write-Host "toon de bestanden in de map"
    Write-Host "${files}"
}
catch {
    $message = $_.Exception.Message
    $StackTrace = $exception.ScriptStackTrace
    Write-host = $message
    write-host = $StackTrace
    throw "script halted"
}