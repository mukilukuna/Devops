# Detection script for One Integrate Cara (Version-agnostic)
$appName = "One Integrate Cara"
$publisher = "Vodafone NL"


$registryPaths = @(
    "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*"
    "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*"
)

try {
    # Check both registry locations
    $installed = Get-ItemProperty $registryPaths -ErrorAction SilentlyContinue | Where-Object {
        $_.DisplayName -eq $appName -and
        $_.Publisher -eq $publisher
    }

    if ($installed) {
        Write-Host "$appName detected"
        exit 0
    }
    exit 1
}
catch {
    Write-Error "Detection error: $_"
    exit 1
}