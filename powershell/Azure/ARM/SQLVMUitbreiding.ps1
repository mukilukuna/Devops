# Instellen van variabelen voor de omgeving
$resourceGroup = "<ResourceGroupNaam>"    # Azure Resource Group van de VM
$vmName = "<VM-Naam>"             # Naam van de Azure VM
$location = "<Azure-regio>"         # Regio, bv. "westeurope"
$newDiskName = "ExtraDisk1"            # Naam voor de nieuwe managed disk
$newDiskSizeGB = 128                     # Grootte van de nieuwe disk in GB
$storagePoolName = "SQLVMStoragePool1"     # Naam van de bestaande storage pool
$virtualDiskName = "SQLVMVirtualDisk1"     # Naam van de virtuele schijf in de pool
$driveLetter = "F"                     # Schijfletter van het volume dat u wilt uitbreiden

# Zorg dat u bent aangemeld bij Azure (indien nog niet gedaan)
# Connect-AzAccount  # <--- Meld u interactief aan, of gebruik een service principal context

# **Stap 1: Controleer vrije ruimte in de storage pool**
Write-Host "Controleert vrije ruimte in storage pool $storagePoolName ..."
$freeSpaceCheckScript = @"
\$pool = Get-StoragePool -FriendlyName '$storagePoolName'
[float]((\$pool.Size - \$pool.AllocatedSize) / 1GB)
"@  # bovenstaande PowerShell berekent vrije ruimte (GB) als float
$checkResult = Invoke-AzVMRunCommand -ResourceGroupName $resourceGroup -Name $vmName `
    -CommandId 'RunPowerShellScript' -ScriptString $freeSpaceCheckScript
if ($checkResult.Status -ne "Succeeded") {
    Write-Error "Kon vrije ruimte in de pool niet controleren. Fout: $($checkResult.Value[0].Message)"
    return
}
# Haal de vrije ruimte (GB) uit de output
$freeSpaceGB = [math]::Round([double]$checkResult.Value[0].Message, 2)
Write-Host "Vrije ruimte in $storagePoolName: $freeSpaceGB GB"

# **Stap 2: Indien nodig, voeg extra disk toe**
if ($freeSpaceGB -le 0) {
    Write-Host "Geen vrije ruimte beschikbaar. Voegt een nieuwe managed disk toe aan de VM..."
    # Maak een nieuwe lege managed disk resource
    $diskConfig = New-AzDiskConfig -SkuName "Premium_LRS" -Location $location -CreateOption Empty -DiskSizeGB $newDiskSizeGB
    $newDisk = New-AzDisk -ResourceGroupName $resourceGroup -DiskName $newDiskName -Disk $diskConfig
    # Koppel de nieuwe disk aan de VM (op de eerstvolgende vrije LUN)
    $vm = Get-AzVM -ResourceGroupName $resourceGroup -Name $vmName
    # Bepaal LUN: pak hoogste bestaande LUN en +1, of gebruik 0 als er nog geen data disks zijn
    $existingLUNs = $vm.StorageProfile.DataDisks | ForEach-Object { $_.Lun }
    $lun = if ($existingLUNs) { ($existingLUNs | Measure-Object -Maximum).Maximum + 1 } else { 0 }
    $vm = Add-AzVMDataDisk -VM $vm -Name $newDisk.Name -ManagedDiskId $newDisk.Id -Lun $lun -CreateOption Attach
    $update = Update-AzVM -ResourceGroupName $resourceGroup -VM $vm
    if ($update.Status -ne "Succeeded") {
        Write-Error "FOUT: De nieuwe disk kon niet aan de VM worden toegevoegd."
        return
    }
    else {
        Write-Host "Nieuwe Azure managed disk ($newDiskName, $newDiskSizeGB GB) is toegevoegd aan VM $vmName (LUN $lun)."
    }
}
else {
    Write-Host "Vrije ruimte is beschikbaar; er wordt geen extra disk toegevoegd."
}

# **Stap 3-5: Breid storage pool, virtuele disk en volume uit binnen de VM**
Write-Host "Uitbreiden van storage pool, virtuele disk en volume binnen de VM..."
# Stel een PowerShell-script samen dat *binnen* de VM zal draaien voor de resterende stappen
$inVMExpandScript = @"
# Breng eventueel nieuwe schijf online als deze offline is
Get-Disk | Where-Object PartitionStyle -eq 'Raw' | Set-Disk -IsOffline \$False -IsReadOnly \$False

# Voeg nieuwe fysieke disks toe aan de storage pool
\$pool = Get-StoragePool -FriendlyName '$storagePoolName'
\$canPoolDisks = Get-PhysicalDisk | Where-Object { \$_.CanPool -eq \$true }
if (\$canPoolDisks) {
    Add-PhysicalDisk -StoragePoolFriendlyName '$storagePoolName' -PhysicalDisks \$canPoolDisks
    Write-Host 'Nieuwe fysieke disk(s) toegevoegd aan storage pool.'
} else {
    Write-Host 'Geen nieuwe fysieke disks om toe te voegen aan de pool (mogelijk al uitgevoerd).'
}

# Bereken vrije ruimte en nieuwe grootte voor de virtuele schijf
\$pool = Get-StoragePool -FriendlyName '$storagePoolName'    # update pool info na toevoegen disk
\$virtualDisk = Get-VirtualDisk -FriendlyName '$virtualDiskName'
\$freeSpaceBytes = \$pool.Size - \$pool.AllocatedSize
if (\$freeSpaceBytes -le 0) {
    Write-Host 'Geen vrije ruimte om de virtuele schijf uit te breiden (mogelijke fout).'
    exit 1
}
\$newSizeBytes = \$virtualDisk.Size + \$freeSpaceBytes

# Vergroot de virtuele schijf
Resize-VirtualDisk -FriendlyName '$virtualDiskName' -Size \$newSizeBytes
Write-Host "Virtuele disk is vergroot tot \$([math]::Round(\$newSizeBytes/1GB,2)) GB."

# Breid de partitie en het bestandssysteem op schijf $driveLetter uit tot de maximale grootte
\$partition = Get-Partition -DriveLetter '$driveLetter'
if (-not \$partition) {
    Write-Host "Partitie met schijfletter $driveLetter niet gevonden. Controleer de drive letter."
    exit 1
}
\$maxSize = (Get-PartitionSupportedSize -Partition \$partition).SizeMax
Resize-Partition -Partition \$partition -Size \$maxSize
Write-Host "Partitie $driveLetter is uitgebreid tot maximale grootte."
"@

# Voer het samengestelde script uit op de Azure VM
$runResult = Invoke-AzVMRunCommand -ResourceGroupName $resourceGroup -Name $vmName -CommandId 'RunPowerShellScript' -ScriptString $inVMExpandScript
if ($runResult.Status -ne "Succeeded") {
    Write-Error "Er trad een fout op tijdens het uitbreiden binnen de VM: $($runResult.Value[0].Message)"
    return
}

Write-Host ""
Write-Host "=== Uitbreiding voltooid! Valideer de nieuwe grootte van de storage pool, virtuele disk en volume. ==="
