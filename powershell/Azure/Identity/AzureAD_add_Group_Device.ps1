# Script: AzureAD_add_Group_Device.ps1
# Purpose: AzureAD add Group Device
<#
.Synopsis
   Add Computers to Azure AD Group
.DESCRIPTION
   Add Computers to Azure AD Group. Jimmy White Feb 2021 www.deviousweb.com
.EXAMPLE
  Create a txt file with the netbios names of devices you want to add. The script invokes a file picker to allow you to choose the file.
.INPUTS
   Inputs to this cmdlet (if any) None
.OUTPUTS
   Output from this cmdlet (if any) Console
.NOTES
   General notes
.COMPONENT
   AzureAD
#>
###################################################################################
#                       Adjust these variables accordingly...                     #
###################################################################################
$azgroup = "AASG-KDAM-MDM-DEVICES-WINDOWS"
###################################################################################
#lets check to see if we have the Azure AD module installed...
if (Get-Module -ListAvailable -Name Azuread) {
    Write-Host "AzureAD Module exists, loading"
    Import-Module Azuread 
} 
else {
    #no module, does user hae admin rights?
    Write-Host "AzureAD Module does not exist please install`r`n with install-module azuread" -ForegroundColor Red
    
    if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(`
                [Security.Principal.WindowsBuiltInRole] "Administrator")) {
        Write-Host "Insufficient permissions to install module. Please run as an administrator and try again." -ForegroundColor DarkYellow
        return(0)
    }
    else {
        Write-Host "Attempting to install Azure AD module" -ForegroundColor Cyan
        Install-Module AzureAD -Confirm:$False -Force
    }
    
}
# OK, lets pick the file..
$FileBrowser = New-Object System.Windows.Forms.OpenFileDialog -Property @{ 
    InitialDirectory = [Environment]::GetFolderPath('Desktop') 
    Filter           = 'Documents (*.txt)|*.txt|TextFile (*.txt)|*.txt'
}
$null = $FileBrowser.ShowDialog()
$machines = get-content $FileBrowser.FileName
#ok, if we got here, we must have the Azure AD module installed, lets connect...
Connect-AzureAD
write-host "Getting Object ID of group.." -ForegroundColor Green
$objid = (get-azureadgroup -Filter "DisplayName eq '$azgroup'" ).objectid
write-host "Getting group members (We dont want duplicates!).." -ForegroundColor Cyan
$members = Get-AzureADGroupMember -ObjectId $objid -all $true | select displayname
foreach ($machine in $machines) {
    $refid = Get-AzureADDevice -Filter "DisplayName eq '$machine'"
    $result = ""
    $result = ($members -match $machine)
    if ($result -eq "") {
        try {
            Write-host "Adding " $refid.displayname -ForegroundColor Cyan
            Add-AzureADGroupMember -ObjectId $objid -RefObjectId $refid.objectid
        }
        catch {
            write-host "An error occured for " $refid.displayname  -ForegroundColor Red
        }
    }
    else {
        write-host $machine " is already a member" -ForegroundColor Green
    }
}