# Script: Get-AADTenantID-and-TenantName-FromWindowsClient.ps1
# Purpose: Get AADTenantID and TenantName FromWindowsClient
<#
    .SYNOPSIS 
    AAD details from AAD join
    
    .DESCRIPTION
    Install:   PowerShell.exe -ExecutionPolicy Bypass -Command .\Get-AADTenantID-and-TenantName-FromWindowsClient.ps1
    
    .ENVIRONMENT
    PowerShell 5.0
    
    .AUTHOR
    Niklas Rast
#>

#Get AAD Tenant ID
$regPath = "HKLM:\SYSTEM\CurrentControlSet\Control\CloudDomainJoin\TenantInfo"
$TenantInfoPath = (Get-ChildItem -Path $regPath).Name
$parentPart = Split-Path $TenantInfoPath -Parent
$AADTenantID = Split-Path $TenantInfoPath -Leaf
$AADTenantID

#Get AAD Name
$AADName = (Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\CloudDomainJoin\TenantInfo\$AADTenantID" -Name DisplayName).DisplayName
$AADName