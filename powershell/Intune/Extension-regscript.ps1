function CheckRegistryKeyExists($keyPath) {
    return (Test-Path -LiteralPath $keyPath)
}

function CheckRegistryValueEquals($keyPath, $valueName, $expectedValue) {
    $actualValue = Get-ItemPropertyValue -LiteralPath $keyPath -Name $valueName -ea SilentlyContinue
    return ($actualValue -eq $expectedValue)
}

# AddInLoadTimes Registry Checks
function CheckAddInLoadTimesRegistry {
    $addInLoadTimesKey = "HKCU:\Software\Microsoft\Office\16.0\Excel\AddInLoadTimes"
    
    if (-not (CheckRegistryKeyExists $addInLoadTimesKey)) {
        return $false
    }
    
    $expectedValue = ([byte[]](0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00)) -join ','
    
    $actualValue = Get-ItemPropertyValue -LiteralPath $addInLoadTimesKey -Name '\\\\nbgeuazusto.file.core.windows.net\\exsion\\Exsion\\Exsion11\\Exsion.xlam' -ea SilentlyContinue
    
    return ($actualValue -join ',' -eq $expectedValue)
}

# Trusted Locations Registry Checks
function CheckTrustedLocationsRegistry {
    $trustedLocationsKey = "HKCU:\Software\Microsoft\Office\16.0\Excel\Security\Trusted Locations"
    
    if (-not (CheckRegistryKeyExists $trustedLocationsKey)) {
        return $false
    }

    # Add checks for each trusted location here
    
    # Example:
    # if (-not (CheckRegistryValueEquals $trustedLocationsKey\Location0 'Path' 'C:\Program Files\Microsoft Office\root\Office16\XLSTART\')) {
    #     return $false
    # }

    # Add checks for 'AllowNetworkLocations' here

    return $true
}

# OptionsExsion Registry Checks
function CheckOptionsExsionRegistry {
    $optionsKey = "HKCU:\Software\Microsoft\Office\16.0\Excel\options"
    
    if (-not (CheckRegistryKeyExists $optionsKey)) {
        return $false
    }

    # Add checks for each option setting here
    
    return $true
}

# Check all conditions
$addInLoadTimesCheck = CheckAddInLoadTimesRegistry
$trustedLocationsCheck = CheckTrustedLocationsRegistry
$optionsExsionCheck = CheckOptionsExsionRegistry
$allowNetworkLocationsCheck = CheckRegistryValueEquals "HKCU:\Software\Microsoft\Office\16.0\Excel\Security\Trusted Locations" 'AllowNetworkLocations' 1
$location6Check = CheckRegistryValueEquals "HKCU:\Software\Microsoft\Office\16.0\Excel\Security\Trusted Locations\Location6" 'AllowSubfolders' 1 -and
                  CheckRegistryValueEquals "HKCU:\Software\Microsoft\Office\16.0\Excel\Security\Trusted Locations\Location6" 'Path' '\\nbgeuazusto.file.core.windows.net\exsion\'

# Final result
if ($addInLoadTimesCheck -and $trustedLocationsCheck -and $optionsExsionCheck -and $allowNetworkLocationsCheck -and $location6Check) {
    return $true
} else {
    return $false
}
