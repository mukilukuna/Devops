# Script: Ltmoncheck.ps1
# Purpose: Ltmoncheck
$ServiceName = 'LTSvcMon'

try {
    $Service = Get-Service -Name $ServiceName -ErrorAction Stop

    if ($Service.Status -eq 'Running') {
        Write-Output "$ServiceName is running"
    }
    else {
        Write-Output "$ServiceName is not running. Current status: $($Service.Status)"
    }
}
catch {
    Write-Output "Service '$ServiceName' not found or an error occurred: $_"
}
