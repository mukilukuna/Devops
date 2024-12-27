# Haal de uptime van alle virtuele machines op
$VMs = Get-VM | Select-Object Name, Uptime

foreach ($VM in $VMs) {
    # Controleer of de uptime beschikbaar is
    if ($VM.Uptime -eq $null) {
        Write-Output "Kan de uptime niet bepalen voor VM: $($VM.Name)"
        continue
    }

    # Controleer of uptime langer is dan 1 dag
    $Threshold = [timespan]"1.00:00:00" # 1 dag
    if ($VM.Uptime -gt $Threshold) {
        Write-Output "VM '$($VM.Name)' heeft een uptime langer dan 1 dag. Stopt de VM..."
        try {
            Stop-VM -Name $VM.Name -Force
            Write-Output "VM '$($VM.Name)' succesvol gestopt."
        }
        catch {
            Write-Output "Fout bij het stoppen van VM '$($VM.Name)': $_"
        }
    }
    else {
        Write-Output "VM '$($VM.Name)' heeft een uptime van $($VM.Uptime). Geen actie nodig."
    }
}
