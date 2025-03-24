# Detectiescript
$filePath = "$env:PUBLIC\Desktop\paint.net.lnk"

if (Test-Path -Path $filePath) {
    # Bestand bestaat, geef exit code 1
    exit 1
} else {
    # Bestand bestaat niet, geef exit code 0
    exit 0
}

