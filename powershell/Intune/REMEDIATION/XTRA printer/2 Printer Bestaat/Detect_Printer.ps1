# Definieer een lijst met te controleren registersleutels
$registryPaths = @()

# Verwachte printerdriver naam
$expectedDriverName = "KONICA MINOLTA C754SeriesPCL"

# Ga ervan uit dat alle drivers correct zijn tot het tegendeel bewezen is
$allDriversCorrect = $true

# Loop door de printerregisterpaden van XTR-PR000 tot XTR-PR999
for ($i = 0; $i -le 999; $i++) {
    $printerPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Print\Printers\XTR-PR" + "{0:D3}" -f $i
    if (Test-Path $printerPath) {
        Write-Output "Registry path gevonden: $printerPath"
        try {
            # Probeer de waarde 'Printer Driver' op te halen
            $driverName = Get-ItemPropertyValue -Path $printerPath -Name "Printer Driver" -ErrorAction Stop
            if ($driverName -ne $expectedDriverName) {
                Write-Output "Onjuiste printer driver gevonden: $driverName voor pad: $printerPath"
                $allDriversCorrect = $false
            }
        } catch {
            Write-Output "Kan de 'Printer Driver' waarde niet ophalen voor pad: $printerPath"
            $allDriversCorrect = $false
        }
    }
}

# Controleer of alle drivers correct zijn en exit met de overeenkomstige code
if ($allDriversCorrect) {
    exit 0
} else {
    exit 1
}
