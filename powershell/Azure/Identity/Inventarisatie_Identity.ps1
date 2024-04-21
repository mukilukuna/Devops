# Benodigde modules installeren en importeren
Install-Module Az.Accounts -Force -AllowClobber
Import-Module Az.Accounts -Force
Install-Module AzureAD -Force -AllowClobber
Import-Module AzureAD -Force
Install-Module -Name AzureADPreview -AllowClobber -Force
Import-Module AzureADPreview -Force

# Aanmelden bij Azure AD
Connect-AzureAD

# Functie voor het toevoegen van dynamische groepen
Function Add-DynGrp {
    [cmdletbinding()]
    Param (
        [string]$IntuneGroupName, 
        [string]$IntuneGroupMailName, 
        [string]$IntuneGroupQuery
    )
    Process {
        $IntuneDevices = New-AzureADMSGroup -Description "$($IntuneGroupName)" `
            -DisplayName "$($IntuneGroupName)" -MailEnabled $false -SecurityEnabled $true `
            -MailNickname "$($IntuneGroupMailName)" -GroupTypes "DynamicMembership" `
            -MembershipRule "$($IntuneGroupQuery)" -MembershipRuleProcessingState "on"
        Set-AzureADMSGroup -Id $IntuneDevices.Id -MembershipRuleProcessingState "on"
    }
}

# Dynamische groepen aanmaken
Add-DynGrp -IntuneGroupName "Group - Devices - Windows" -IntuneGroupMailName "SEC_INTUNE_DEVICES_*WINDOWS" `
-IntuneGroupQuery '(device.DeviceOSType -in ["Windows","Windows 10 Pro","Windows 10 Enterprise"]) -and (device.deviceOSVersion -startsWith "10.0") -and (device.managementType -eq "MDM")'

Add-DynGrp -IntuneGroupName "SEC_INTUNE_DEVICES_*HP" -IntuneGroupMailName "SEC_INTUNE_DEVICES_*HP" `
-IntuneGroupQuery '(Device.deviceManufacturer -eq "HP")'
