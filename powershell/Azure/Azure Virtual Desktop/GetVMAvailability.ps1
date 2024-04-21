# Vereiste modules
$requiredModules = @("Az.Compute")

# Installeer de Azure PowerShell module indien niet geïnstalleerd
foreach ($module in $requiredModules) {
    if (-not (Get-Module -ListAvailable -Name $module)) {
        Write-Host "Module $module is niet geïnstalleerd. Bezig met installeren..."
        Install-Module -Name $module -Force -AllowClobber
    }
    else {
        Write-Host "Module $module is al geïnstalleerd."
    }
}

# Importeer de module
Import-Module Az.Compute

Get-AzComputeResourceSku | Where-Object { $_.Locations -contains "westeurope" -and $_.ResourceType -eq "virtualMachines" }