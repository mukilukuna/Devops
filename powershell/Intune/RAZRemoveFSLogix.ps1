# Functie om een registersleutel en bijbehorende waarden te verwijderen
function Remove-RegistryKey {
    param (
        [string]$regPath
    )
    if (Test-Path $regPath) {
        try {
            Remove-Item -Path $regPath -Recurse -Force
            Write-Host "Verwijderd: $regPath"
        }
        catch {
            Write-Host "FOUT bij verwijderen van $regPath - $($_.Exception.Message)"
        }
    }
    else {
        Write-Host "Sleutel niet gevonden: $regPath"
    }
}

# FSLogix registersleutels in HKLM
$fslogixKeysHKLM = @(
    "HKLM:\SOFTWARE\FSLogix",
    "HKLM:\SOFTWARE\Policies\FSLogix"
)

# Verwijder FSLogix keys in HKLM
foreach ($key in $fslogixKeysHKLM) {
    Remove-RegistryKey -regPath $key
}

Write-Host "FSLogix registeropschoning voltooid."

# Activeer lokaal account its_local
net user its_local /active:yes