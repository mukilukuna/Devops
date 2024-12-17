$uptime = get-vm | Select-Object uptime

if ($uptime -gt 1.00:00:00) {
    Stop-VM
}