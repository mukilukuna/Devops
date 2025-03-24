# Remediatiescript
$filePath = "$env:PUBLIC\Desktop\paint.net.lnk"

if (Test-Path -Path $filePath) {
    # Verwijder het bestand
    Remove-Item -Path $filePath -Force
}
