# Benodigde modules installeren en importeren
try {
    Install-Module -Name Az.Accounts -Force -AllowClobber
    Import-Module -Name Az.Accounts -Force
    Install-Module -Name Microsoft.Graph -Force -AllowClobber
    Import-Module -Name Microsoft.Graph -Force
}
catch {
    Write-Output "Fout bij het installeren/importeren van modules: $_"
    exit 1
}

# Aanmelden bij Azure AD
try {
    Connect-MgGraph -Scopes "Group.ReadWrite.All", "Directory.ReadWrite.All"
    Write-Output "Succesvol aangemeld bij Microsoft Graph."
}
catch {
    Write-Output "Fout bij aanmelden bij Microsoft Graph: $_"
    exit 1
}

# Functie voor het toevoegen van dynamische groepen
Function Add-DynGrp {
    [CmdletBinding()]
    Param (
        [string]$GroupName,
        [string]$GroupMailName,
        [string]$GroupQuery
    )
    Process {
        try {
            Write-Output "Aanmaken van dynamische groep: $GroupName"
            
            # Nieuwe groep aanmaken
            $Group = New-MgGroup -DisplayName $GroupName `
                -MailEnabled $false `
                -SecurityEnabled $true `
                -MailNickname $GroupMailName `
                -GroupTypes @("DynamicMembership") `
                -MembershipRule $GroupQuery `
                -MembershipRuleProcessingState "On"
            
            Write-Output "Groep '$GroupName' succesvol aangemaakt met ID: $($Group.Id)"
        }
        catch {
            Write-Output "Fout bij het aanmaken van groep '$GroupName': $_"
        }
    }
}

# Dynamische groepen aanmaken
Add-DynGrp -GroupName "Group - Devices - Windows" `
    -GroupMailName "SEC_INTUNE_DEVICES_WINDOWS" `
    -GroupQuery '(device.deviceOSType -in ["Windows","Windows 10 Pro","Windows 10 Enterprise"]) -and (device.deviceOSVersion -startsWith "10.0") -and (device.managementType -eq "MDM")'

Add-DynGrp -GroupName "Group - Devices - HP" `
    -GroupMailName "SEC_INTUNE_DEVICES_HP" `
    -GroupQuery '(device.deviceManufacturer -eq "HP")'
