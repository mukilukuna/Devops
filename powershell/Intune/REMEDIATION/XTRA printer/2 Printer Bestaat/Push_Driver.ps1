# Definieer een lijst met te controleren registersleutels voor printers
$printerKeys = @()

# Verwachte printerdriver naam
$expectedDriverName = "KONICA MINOLTA C754SeriesPCL"

# Ga ervan uit dat alle drivers correct zijn tot het tegendeel bewezen is
$allDriversCorrect = $true

# Loop door de printerregisterpaden van XTR-PR000 tot XTR-PR999
for ($i = 0; $i -le 999; $i++) {
    $printerPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Print\Printers\XTR-PR" + "{0:D3}" -f $i
    if (Test-Path $printerPath) {
        $printerKeys += $printerPath  # Voeg het gevonden registerpad toe aan de lijst
    }
}

# Loop door elk van de printer sleutels in de lijst
foreach ($key in $printerKeys) {
    # Voer hier de gewenste acties uit voor elke gevonden printer
    # Bijvoorbeeld, als je de driver wilt bijwerken:
    try {
        $printerName = $key -split "\\" | Select-Object -Last 1
        $command = "rundll32 printui.dll,PrintUIEntry /Xs /n `"$printerName`" DriverName `"KONICA MINOLTA C754SeriesPCL`""
        Invoke-Expression $command
        Write-Host "Driver bijgewerkt voor printer: $printerName"
    } catch {
        Write-Host "Fout bijwerken van driver voor printer: $printerName"
        $allDriversCorrect = $false
    }
}
