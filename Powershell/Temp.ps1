
$letters = Read-Host "Choose some letters"

if (($letters.ToCharArray() | Select-Object -Unique).Count -gt 4) {
    Write-Host "Too many letters"
}
else {
    $combinations = @()

    foreach ($first in $letters) {
        foreach ($second in $letters) {
            if ($second -ne $first) {
                foreach ($third in $letters) {
                    if ($third -ne $first -and $third -ne $second) {
                        foreach ($fourth in $letters) {
                            if ($fourth -ne $first -and $fourth -ne $second -and $fourth -ne $third) {
                                $combinations += "$first$second$third$fourth"
                            }
                        }
                    }
                }
            }
        }
    }

    foreach ($combination in $combinations) {
        Write-Host $combination
    }
}
