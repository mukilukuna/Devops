# Script: SelfHosted_COT.ps1
# Purpose: SelfHosted COT
BEGIN {
    $Hostname = hostname
    [System.String]$WindowsVersion = (Get-ItemProperty "HKLM:\Software\Microsoft\Windows NT\CurrentVersion\").ReleaseId

    [Version]$COTVersion = "3.3.0.1" 
    # Create Key
    $KeyPath = 'HKLM:\SOFTWARE\COT'
    If (-Not(Test-Path $KeyPath)) {
        New-Item -Path $KeyPath | Out-Null
    }

    # Add COT Version Key
    $Version = "Version"
    $VersionValue = $COTVersion
    If (Get-ItemProperty $KeyPath -Name Version -ErrorAction SilentlyContinue) {
        Set-ItemProperty -Path $KeyPath -Name $Version -Value $VersionValue
    }
    Else {
        New-ItemProperty -Path $KeyPath -Name $Version -Value $VersionValue | Out-Null
    }

    # Add COT Last Run
    $LastRun = "LastRunTime"
    $LastRunValue = Get-Date
    If (Get-ItemProperty $KeyPath -Name LastRunTime -ErrorAction SilentlyContinue) {
        Set-ItemProperty -Path $KeyPath -Name $LastRun -Value $LastRunValue
    }
    Else {
        New-ItemProperty -Path $KeyPath -Name $LastRun -Value $LastRunValue | Out-Null
    }
    
    $EventSources = @('COT', 'WindowsMediaPlayer', 'AppxPackages', 'ScheduledTasks', 'DefaultUserSettings', 'Autologgers', 'Services', 'NetworkOptimizations', 'Miscellaneous', 'AdvancedOptimizations', 'DiskCleanup')
    If (-not([System.Diagnostics.EventLog]::SourceExists("Citrix Virtual Desktop Optimization"))) {
        # All COT main function Event ID's [1-9]
        New-EventLog -Source $EventSources -LogName 'Citrix Virtual Desktop Optimization'
        Limit-EventLog -OverflowAction OverWriteAsNeeded -MaximumSize 64KB -LogName 'Citrix Virtual Desktop Optimization'
        Write-EventLog -LogName 'Citrix Virtual Desktop Optimization' -Source 'COT' -EntryType Information -EventId 2 -Message "Log Created"
    }
    Else {
        New-EventLog -Source $EventSources -LogName 'Citrix Virtual Desktop Optimization' -ErrorAction SilentlyContinue
    }
    Write-EventLog -LogName 'Citrix Virtual Desktop Optimization' -Source 'COT' -EntryType Information -EventId 2 -Message "Starting COT by user '$env:USERNAME', for COT build '$WindowsVersion'" 

    $StartTime = Get-Date
    $CurrentLocation = Get-Location
    $WorkingLocation = (Join-Path $PSScriptRoot $WindowsVersion)

    try {
        Push-Location (Join-Path $PSScriptRoot $WindowsVersion)-ErrorAction Stop
    }
    catch {
        $Message = "Invalid Path $WorkingLocation - Exiting Script!"
        Write-EventLog -Message $Message -Source 'COT' -EventID 101 -EntryType Error -LogName 'Citrix Virtual Desktop Optimization'
        Write-Warning $Message
        Return
    }
}
PROCESS {
    #region Disable Services
    #Disable services that are not required for VDI\RDS virtual machines
    $ServicesToDisable = New-Object System.Collections.ArrayList
    [void]$ServicesToDisable.Add(@{Name = 'AJRouter'; Description = 'Routes AllJoyn messages for the local AllJoyn clients.'; Value = 'Disabled' });
    [void]$ServicesToDisable.Add(@{Name = 'ALG'; Description = 'Provides support for 3rd party protocol plug-ins for Internet Connection Sharing.'; Value = 'Disabled' });
    [void]$ServicesToDisable.Add(@{Name = 'BthAvctpSvc'; Description = 'This is Audio Video Control Transport Protocol service'; Value = 'Disabled' });
    [void]$ServicesToDisable.Add(@{Name = 'BDESVC'; Description = 'BDESVC hosts the BitLocker Drive Encryption service. BitLocker Drive Encryption provides secure startup for the operating system, as well as full volume encryption for OS, fixed or removable volumes. This service allows BitLocker to prompt users for various actions related to their volumes when mounted, and unlocks volumes automatically without user interaction. Additionally, it stores recovery information to Active Directory, if available, and, if necessary, ensures the most recent recovery certificates are used.'; Value = 'Disabled' });
    [void]$ServicesToDisable.Add(@{Name = 'wbengine'; Description = 'The WBENGINE service is used by Windows Backup to perform backup and recovery operations.'; Value = 'Disabled' });
    [void]$ServicesToDisable.Add(@{Name = 'BTAGService'; Description = 'Service supporting the audio gateway role of the Bluetooth Handsfree Profile.'; Value = 'Disabled' });
    [void]$ServicesToDisable.Add(@{Name = 'bthserv'; Description = 'The Bluetooth service supports discovery and association of remote Bluetooth devices.'; Value = 'Disabled' });
    [void]$ServicesToDisable.Add(@{Name = 'PeerDistSvc'; Description = 'This service caches network content from peers on the local subnet.'; Value = 'Disabled' });
    [void]$ServicesToDisable.Add(@{Name = 'PimIndexMaintenanceSvc'; Description = 'Indexes contact data for fast contact searching. If you stop or disable this service, contacts might be missing from your search results.'; Value = 'Disabled' });
    [void]$ServicesToDisable.Add(@{Name = 'WdiServiceHost'; Description = 'The Diagnostic Service Host is used by the Diagnostic Policy Service to host diagnostics that need to run in a Local Service context.'; Value = 'Disabled' });
    [void]$ServicesToDisable.Add(@{Name = 'TrkWks'; Description = 'Maintains links between NTFS files within a computer or across computers in a network domain.'; Value = 'Disabled' });
    [void]$ServicesToDisable.Add(@{Name = 'EFS'; Description = 'Provides the core file encryption technology used to store encrypted files on NTFS file system volumes.'; Value = 'Disabled' });
    [void]$ServicesToDisable.Add(@{Name = 'Fax'; Description = 'Enables you to send and receive faxes, utilizing fax resources available on this computer or on the network.'; Value = 'Disabled' });
    [void]$ServicesToDisable.Add(@{Name = 'fdPHost'; Description = 'The FDPHOST service hosts the Function Discovery (FD) network discovery providers. These FD providers supply network discovery services for the Simple Services Discovery Protocol (SSDP) and Web Services Discovery (WS-D) protocol. Stopping or disabling the FDPHOST service will disable network discovery for these protocols when using FD. When this service is unavailable, network services using FD and relying on these discovery protocols will be unable to find network devices or resources.'; Value = 'Disabled' });
    [void]$ServicesToDisable.Add(@{Name = 'FDResPub'; Description = 'Publishes this computer and resources attached to this computer so they can be discovered over the network.'; Value = 'Disabled' });
    [void]$ServicesToDisable.Add(@{Name = 'SharedAccess'; Description = 'Provides network address translation, addressing, name resolution and/or intrusion prevention services for a home or small office network.'; Value = 'Disabled' });
    [void]$ServicesToDisable.Add(@{Name = 'CscService'; Description = 'The Offline Files service performs maintenance activities on the Offline Files cache, responds to user logon and logoff events, implements the internals of the public API, and dispatches interesting events to those interested in Offline Files activities and changes in cache state.'; Value = 'Disabled' });
    [void]$ServicesToDisable.Add(@{Name = 'CSC'; Description = 'The Offline Files service performs maintenance activities on the Offline Files cache, responds to user logon and logoff events, implements the internals of the public API, and dispatches interesting events to those interested in Offline Files activities and changes in cache state.'; Value = 'Disabled' });
    [void]$ServicesToDisable.Add(@{Name = 'WpcMonSvc'; Description = 'Enforces parental controls for child accounts in Windows. If this service is stopped or disabled, parental controls may not be enforced.'; Value = 'Disabled' });
    [void]$ServicesToDisable.Add(@{Name = 'RetailDemo'; Description = 'The Retail Demo service controls device activity while the device is in retail demo mode.'; Value = 'Disabled' });  
    [void]$ServicesToDisable.Add(@{Name = 'SensrSvc'; Description = 'Monitors various sensors in order to expose data and adapt to system and user state.'; Value = 'Disabled' });
    [void]$ServicesToDisable.Add(@{Name = 'SSDPSRV'; Description = 'Discovers networked devices and services that use the SSDP discovery protocol, such as UPnP devices. Also announces SSDP devices and services running on the local computer.'; Value = 'Disabled' });
    [void]$ServicesToDisable.Add(@{Name = 'upnphost'; Description = 'Allows UPnP devices to be hosted on this computer.'; Value = 'Disabled' });
    [void]$ServicesToDisable.Add(@{Name = 'VacSvc'; Description = 'Hosts spatial analysis for Mixed Reality audio simulation.'; Value = 'Disabled' });
    [void]$ServicesToDisable.Add(@{Name = 'wcncsvc'; Description = 'WCNCSVC hosts the Windows Connect Now Configuration which is Microsofts Implementation of Wi-Fi Protected Setup (WPS) protocol. This is used to configure Wireless LAN settings for an Access Point (AP) or a Wi-Fi Device. The service is started programmatically as needed.'; Value = 'Disabled' });
    [void]$ServicesToDisable.Add(@{Name = 'WMPNetworkSvc'; Description = 'Shares Windows Media Player libraries to other networked players and media devices using Universal Plug and Play.'; Value = 'Disabled' });
    [void]$ServicesToDisable.Add(@{Name = 'WlanSvc'; Description = 'The WLANSVC service provides the logic required to configure, discover, connect to, and disconnect from a wireless local area network (WLAN) as defined by IEEE 802.11 standards. It also contains the logic to turn your computer into a software access point so that other devices or computers can connect to your computer wirelessly using a WLAN adapter that can support this.'; Value = 'Disabled' });
    [void]$ServicesToDisable.Add(@{Name = 'WwanSvc'; Description = 'This service manages mobile broadband (GSM and CDMA) data card/embedded module adapters and connections by auto-configuring the networks. It is strongly recommended that this service be kept running for best user experience of mobile broadband devices.'; Value = 'Disabled' });

    Write-EventLog -EventId 69 -Message "Disable Services" -LogName 'Citrix Virtual Desktop Optimization' -Source 'Services' -EntryType Information
    Write-Host "[Citrix Optimize] Disable Services" -ForegroundColor Cyan

    If ($ServicesToDisable.count -gt 0) {
        Write-EventLog -EventId 69 -Message "Processing Services Configuration File" -LogName 'Citrix Virtual Desktop Optimization' -Source 'Services' -EntryType Information
        Write-Verbose "Processing Services Configuration File"
        Foreach ($Item in $ServicesToDisable) {
            #Write-EventLog -EventId 69 -Message "Attempting to Stop Service $($Item.Name) - $($Item.Description)" -LogName 'Citrix Virtual Desktop Optimization' -Source 'Services' -EntryType Information
            #Write-Verbose "Attempting to Stop Service $($Item.Name) - $($Item.Description)"
            #try{
            #    Stop-Service $Item.Name -Force -ErrorAction SilentlyContinue
            #}catch{
            #    Write-EventLog -EventId 169 -Message "Failed to disable Service: $($Item.Name) `n $($_.Exception.Message)" -LogName 'Citrix Virtual Desktop Optimization' -Source 'Services' -EntryType Error
            #    Write-Warning "Failed to disable Service: $($Item.Name) `n $($_.Exception.Message)"
            #}
            Write-EventLog -EventId 69 -Message "Attempting to disable Service $($Item.Name) - $($Item.Description)" -LogName 'Citrix Virtual Desktop Optimization' -Source 'Services' -EntryType Information
            Write-Verbose "Attempting to disable Service $($Item.Name) - $($Item.Description)"
            try {
                Set-Service $Item.Name -StartupType Disabled -ErrorAction SilentlyContinue  
            }
            catch {
                Write-EventLog -EventId 169 -Message "Failed to disable Service: $($Item.Name) `n $($_.Exception.Message)" -LogName 'Citrix Virtual Desktop Optimization' -Source 'Services' -EntryType Error
                Write-Warning "Failed to disable Service: $($Item.Name) `n $($_.Exception.Message)"
            }
        }
    }
    Else {
        Write-EventLog -EventId 69 -Message "No Services found to disable" -LogName 'Citrix Virtual Desktop Optimization' -Source 'Services' -EntryType Warnnig
        Write-Verbose "No Services found to disable"
    }
    #endregion

    #region Disable Scheduled Tasks
    $SchTasksList = New-Object System.Collections.ArrayList
    [void]$SchTasksList.Add(@{Name = 'BfeOnServiceStartTypeChange'; Description = 'Adjusts the start type for firewall-triggered services when the start type of the Base Filtering Engine (BFE) is disabled.'; Path = '\Microsoft\Windows\Windows Filtering Platform'; Value = 'Disabled' });
    [void]$SchTasksList.Add(@{Name = 'File History (maintenance mode)'; Description = 'Protects user files from accidental loss by copying them to a backup location when the system is unattended.'; Path = '\Microsoft\Windows\FileHistory'; Value = 'Disabled' });
    [void]$SchTasksList.Add(@{Name = 'Notifications'; Description = 'Location - Notifications'; Path = '\Microsoft\Windows\Location'; Value = 'Disabled' }); 
    [void]$SchTasksList.Add(@{Name = 'MapsUpdateTask'; Description = 'MapsUpdateTask'; Path = '\Microsoft\Windows\Maps'; Value = 'Disabled' });
    [void]$SchTasksList.Add(@{Name = 'Microsoft-Windows-DiskDiagnosticResolver'; Description = 'Warns users about faults reported by hard disks that support the Self Monitoring and Reporting Technology (S.M.A.R.T.) standard. This task is triggered automatically by the Diagnostic Policy Service when a S.M.A.R.T. fault is detected.'; Path = '\Microsoft\Windows\DiskDiagnostic'; Value = 'Disabled' }); 
    [void]$SchTasksList.Add(@{Name = 'MNO Metadata Parser'; Description = 'Mobile Broadband Accounts'; Path = '\Microsoft\Windows\Mobile Broadband Accounts'; Value = 'Disabled' });
    [void]$SchTasksList.Add(@{Name = 'ProactiveScan'; Description = 'NTFS volume health scan.'; Path = '\Microsoft\Windows\CHKDSK'; Value = 'Disabled' });
    [void]$SchTasksList.Add(@{Name = 'ProgramDataUpdater'; Description = 'Collects program telemetry information if opted-in to the Microsoft Customer Experience Improvement Program.'; Path = '\Microsoft\Windows\Application Experience'; Value = 'Disabled' });
    [void]$SchTasksList.Add(@{Name = 'ReconcileFeatures'; Description = 'One of scheduled tasks that perform optimizations or data collections on computers that maintain their state across reboots. When a VDI VM task reboots and discards all changes since last boot, optimizations intended for physical computers are not helpful. Source: https://docs.microsoft.com/en-us/windows-server/remote/remote-desktop-services/rds_vdi-recommendations-1909'; Path = '\Microsoft\Windows\Flighting\FeatureConfig\'; Value = 'Disabled' });
    [void]$SchTasksList.Add(@{Name = 'ReconcileLanguageResources'; Description = 'One of scheduled tasks that perform optimizations or data collections on computers that maintain their state across reboots. When a VDI VM task reboots and discards all changes since last boot, optimizations intended for physical computers are not helpful. Source: https://docs.microsoft.com/en-us/windows-server/remote/remote-desktop-services/rds_vdi-recommendations-1909'; Path = '\Microsoft\Windows\LanguageComponentsInstaller\'; Value = 'Disabled' });
    [void]$SchTasksList.Add(@{Name = 'RefreshCache'; Description = 'One of scheduled tasks that perform optimizations or data collections on computers that maintain their state across reboots. When a VDI VM task reboots and discards all changes since last boot, optimizations intended for physical computers are not helpful. Source: https://docs.microsoft.com/en-us/windows-server/remote/remote-desktop-services/rds_vdi-recommendations-1909'; Path = '\Microsoft\Windows\Flighting\OneSettings\'; Value = 'Disabled' });
    [void]$SchTasksList.Add(@{Name = 'ResolutionHost'; Description = 'The Windows Diagnostic Infrastructure Resolution host enables interactive resolutions for system problems detected by the Diagnostic Policy Service. It is triggered when necessary by the Diagnostic Policy Service in the appropriate user session. If the Diagnostic Policy Service is not running, the task will not run.'; Path = '\Microsoft\Windows\WDI'; Value = 'Disabled' });
    [void]$SchTasksList.Add(@{Name = 'ResPriStaticDbSync'; Description = 'One of scheduled tasks that perform optimizations or data collections on computers that maintain their state across reboots. When a VDI VM task reboots and discards all changes since last boot, optimizations intended for physical computers are not helpful. Source: https://docs.microsoft.com/en-us/windows-server/remote/remote-desktop-services/rds_vdi-recommendations-1909'; Path = '\Microsoft\Windows\Sysmain\'; Value = 'Disabled' });
    [void]$SchTasksList.Add(@{Name = 'ScanForUpdates'; Description = 'One of scheduled tasks that perform optimizations or data collections on computers that maintain their state across reboots. When a VDI VM task reboots and discards all changes since last boot, optimizations intended for physical computers are not helpful. Source: https://docs.microsoft.com/en-us/windows-server/remote/remote-desktop-services/rds_vdi-recommendations-1909'; Path = '\Microsoft\Windows\InstallService\'; Value = 'Disabled' });
    [void]$SchTasksList.Add(@{Name = 'ScanForUpdatesAsUser'; Description = 'One of scheduled tasks that perform optimizations or data collections on computers that maintain their state across reboots. When a VDI VM task reboots and discards all changes since last boot, optimizations intended for physical computers are not helpful. Source: https://docs.microsoft.com/en-us/windows-server/remote/remote-desktop-services/rds_vdi-recommendations-1909'; Path = '\Microsoft\Windows\InstallService\'; Value = 'Disabled' });
    [void]$SchTasksList.Add(@{Name = 'Scheduled'; Description = 'Performs periodic maintenance of the computer system by fixing problems automatically or reporting them through the Action Center.'; Path = '\Microsoft\Windows\Diagnosis'; Value = 'Disabled' });
    [void]$SchTasksList.Add(@{Name = 'SilentCleanup'; Description = 'One of scheduled tasks that perform optimizations or data collections on computers that maintain their state across reboots. When a VDI VM task reboots and discards all changes since last boot, optimizations intended for physical computers are not helpful. Source: https://docs.microsoft.com/en-us/windows-server/remote/remote-desktop-services/rds_vdi-recommendations-1909'; Path = '\Microsoft\Windows\DiskCleanup\'; Value = 'Disabled' });
    [void]$SchTasksList.Add(@{Name = 'SmartRetry'; Description = 'One of scheduled tasks that perform optimizations or data collections on computers that maintain their state across reboots. When a VDI VM task reboots and discards all changes since last boot, optimizations intended for physical computers are not helpful. Source: https://docs.microsoft.com/en-us/windows-server/remote/remote-desktop-services/rds_vdi-recommendations-1909'; Path = '\Microsoft\Windows\InstallService\'; Value = 'Disabled' });
    [void]$SchTasksList.Add(@{Name = 'SpaceAgentTask'; Description = 'One of scheduled tasks that perform optimizations or data collections on computers that maintain their state across reboots. When a VDI VM task reboots and discards all changes since last boot, optimizations intended for physical computers are not helpful. Source: https://docs.microsoft.com/en-us/windows-server/remote/remote-desktop-services/rds_vdi-recommendations-1909'; Path = '\Microsoft\Windows\SpacePort\'; Value = 'Disabled' });
    [void]$SchTasksList.Add(@{Name = 'SpaceManagerTask'; Description = 'One of scheduled tasks that perform optimizations or data collections on computers that maintain their state across reboots. When a VDI VM task reboots and discards all changes since last boot, optimizations intended for physical computers are not helpful. Source: https://docs.microsoft.com/en-us/windows-server/remote/remote-desktop-services/rds_vdi-recommendations-1909'; Path = '\Microsoft\Windows\SpacePort\'; Value = 'Disabled' });
    [void]$SchTasksList.Add(@{Name = 'StartupAppTask'; Description = 'Scans startup entries and raises notification to the user if there are too many startup entries.'; Path = '\Microsoft\Windows\Application Experience'; Value = 'Disabled' });
    [void]$SchTasksList.Add(@{Name = 'StorageSense'; Description = 'One of scheduled tasks that perform optimizations or data collections on computers that maintain their state across reboots. When a VDI VM task reboots and discards all changes since last boot, optimizations intended for physical computers are not helpful. Source: https://docs.microsoft.com/en-us/windows-server/remote/remote-desktop-services/rds_vdi-recommendations-1909'; Path = '\Microsoft\Windows\DiskFootprint\'; Value = 'Disabled' });
    [void]$SchTasksList.Add(@{Name = 'UninstallDeviceTask'; Description = 'One of scheduled tasks that perform optimizations or data collections on computers that maintain their state across reboots. When a VDI VM task reboots and discards all changes since last boot, optimizations intended for physical computers are not helpful. Source: https://docs.microsoft.com/en-us/windows-server/remote/remote-desktop-services/rds_vdi-recommendations-1909'; Path = '\Microsoft\Windows\Bluetooth\'; Value = 'Disabled' });
    [void]$SchTasksList.Add(@{Name = 'Usb-Notifications'; Description = 'One of scheduled tasks that perform optimizations or data collections on computers that maintain their state across reboots. When a VDI VM task reboots and discards all changes since last boot, optimizations intended for physical computers are not helpful. Source: https://docs.microsoft.com/en-us/windows-server/remote/remote-desktop-services/rds_vdi-recommendations-1909'; Path = '\Microsoft\Windows\USB\'; Value = 'Disabled' });
    [void]$SchTasksList.Add(@{Name = 'WIM-Hash-Management'; Description = 'One of scheduled tasks that perform optimizations or data collections on computers that maintain their state across reboots. When a VDI VM task reboots and discards all changes since last boot, optimizations intended for physical computers are not helpful. Source: https://docs.microsoft.com/en-us/windows-server/remote/remote-desktop-services/rds_vdi-recommendations-1909'; Path = '\Microsoft\Windows\WOF\'; Value = 'Disabled' });
    [void]$SchTasksList.Add(@{Name = 'UpdateLibrary'; Description = 'This task updates the cached list of folders and the security permissions on any new files in a users shared media library.'; Path = '\Microsoft\Windows\Windows Media Sharing'; Value = 'Disabled' });
    [void]$SchTasksList.Add(@{Name = 'WsSwapAssessmentTask'; Description = 'One of scheduled tasks that perform optimizations or data collections on computers that maintain their state across reboots. When a VDI VM task reboots and discards all changes since last boot, optimizations intended for physical computers are not helpful. Source: https://docs.microsoft.com/en-us/windows-server/remote/remote-desktop-services/rds_vdi-recommendations-1909'; Path = '\Microsoft\Windows\Sysmain\'; Value = 'Disabled' });

    Write-EventLog -EventId 39 -Message "[Citrix Optimize] Disable Scheduled Tasks" -LogName 'Citrix Virtual Desktop Optimization' -Source 'ScheduledTasks' -EntryType Information 
    Write-Host "[Citrix Optimize] Disable Scheduled Tasks" -ForegroundColor Cyan

    If ($SchTasksList.count -gt 0) {
        Foreach ($Item in $SchTasksList) {
            $TaskObject = Get-ScheduledTask -taskname $Item.name
            If ($TaskObject.State -ne 'Disabled') {
                Write-EventLog -EventId 39 -Message "Attempting to disable Scheduled Task: $($TaskObject.TaskName)" -LogName 'Citrix Virtual Desktop Optimization' -Source 'ScheduledTasks' -EntryType Information 
                Write-Verbose "Attempting to disable Scheduled Task: $($TaskObject.TaskName)"
                try {
                    disable-ScheduledTask -InputObject $TaskObject | Out-Null
                    Write-EventLog -EventId 39 -Message "Disabled Scheduled Task: $($TaskObject.TaskName)" -LogName 'Citrix Virtual Desktop Optimization' -Source 'ScheduledTasks' -EntryType Information 
                }
                catch {
                    Write-EventLog -EventId 139 -Message "Failed to disabled Scheduled Task: $($TaskObject.TaskName) - $($_.Exception.Message)" -LogName 'Citrix Virtual Desktop Optimization' -Source 'ScheduledTasks' -EntryType Error 
                }
            }
            ElseIf ($TaskObject.State -eq 'Disabled') {
                Write-EventLog -EventId 39 -Message "$($TaskObject.TaskName) Scheduled Task is already disabled - $($_.Exception.Message)" -LogName 'Citrix Virtual Desktop Optimization' -Source 'ScheduledTasks' -EntryType Warning
            }
            Else {
                Write-EventLog -EventId 139 -Message "Unable to find Scheduled Task: $($TaskObject.TaskName) - $($_.Exception.Message)" -LogName 'Citrix Virtual Desktop Optimization' -Source 'ScheduledTasks' -EntryType Error
            }
        }
    }
    Else {
        Write-EventLog -EventId 39 -Message "No Scheduled Tasks found to disable" -LogName 'Citrix Virtual Desktop Optimization' -Source 'ScheduledTasks' -EntryType Warning
    }
    #endregion

    #region Miscellaneous
    $MiscRegList = New-Object System.Collections.ArrayList
    [void]$MiscRegList.Add(@{Name = 'DeleteUserAppContainersOnLogoff'; Description = 'When new user logs in to Windows OS, new per-user firewall rules are created. These rules are not deleted when user logs off. This can have significant impact on performance.'; path = 'HKLM\SYSTEM\CurrentControlSet\Services\SharedAccess\Parameters\FirewallPolicy'; value = '1'; valuetype = 'Dword' });
    [void]$MiscRegList.Add(@{Name = 'EnableAutoLayout'; Description = 'Disabling background auto-layout can help improve EWF performance.'; path = 'HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\OptimalLayout'; value = '0'; valuetype = 'DWORD' });
    [void]$MiscRegList.Add(@{Name = 'ScreenSaveActive'; Description = 'Disable default system logon screensaver.'; path = 'HKU\.DEFAULT\Control Panel\Desktop'; value = '0'; valuetype = 'DWORD' });
    [void]$MiscRegList.Add(@{Name = 'HibernateEnabled'; Description = 'Disable Hibernate.'; path = 'HKLM\SYSTEM\CurrentControlSet\Control\Power'; value = '0'; valuetype = 'DWORD' });
    [void]$MiscRegList.Add(@{Name = 'CrashDumpEnabled'; Description = 'Disable memory dump creation.'; path = 'HKLM\SYSTEM\CurrentControlSet\Control\CrashControl'; value = '0'; valuetype = 'DWORD' });
    [void]$MiscRegList.Add(@{Name = 'NtfsDisableLastAccessUpdate'; Description = 'If you are using NTFS, you can increase the performance of EWF by disabling the last access date/time stamps.'; path = 'HKLM\SYSTEM\CurrentControlSet\Control\FileSystem'; value = '2147483651'; valuetype = 'Dword' });
    [void]$MiscRegList.Add(@{Name = 'AllowStorageSenseGlobal'; Description = 'Disable Storage Sense.'; path = 'HKLM\SOFTWARE\Policies\Microsoft\Windows\StorageSense'; value = '0'; valuetype = 'DWORD' });
    [void]$MiscRegList.Add(@{Name = 'ErrorMode'; Description = 'Disable system hard error messages.'; path = 'HKLM\System\CurrentControlSet\Control\Windows'; value = '2'; valuetype = 'DWORD' });
    [void]$MiscRegList.Add(@{Name = 'TimeOutValue'; Description = 'Increase Disk I/O Timeout to 200 seconds.'; path = 'HKLM\SYSTEM\CurrentControlSet\Services\Disk'; value = '0x000000C8'; valuetype = 'DWORD' });
    [void]$MiscRegList.Add(@{Name = 'NoAutoUpdate'; Description = 'Enables the detection, download, and installation of updates for Windows and other programs. NOTE: This read-only entry is analyzing if Windows Update has been disabled using Group Policy. This entry does NOT support disabling Windows Update. All of the relevant policies are under the path Computer configuration - Administrative Templates - Windows Components - Windows Update. For more information, please refer to official Microsoft documentation: https://docs.microsoft.com/en-us/windows/deployment/update/waas-wufb-group-policy'; path = 'HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU'; value = '1'; valuetype = 'DWORD' });

    Write-EventLog -EventId 89 -Message "Miscellaneous Items" -LogName 'Citrix Virtual Desktop Optimization' -Source 'Miscellaneous' -EntryType Information
    Write-Host "[Citrix Optimize] Miscellaneous Items" -ForegroundColor Cyan
    If ($MiscRegList.Count -gt 0) {
        Write-EventLog -EventId 89 -Message "Processing MiscRegList Settings ($($MiscRegList.Count) Hives)" -LogName 'Citrix Virtual Desktop Optimization' -Source 'Miscellaneous' -EntryType Information
        Write-Verbose "Processing MiscRegList Settings ($($MiscRegList.Count) Hives)"
        Foreach ($Key in $MiscRegList) {
            If ($Key.VDIState -eq 'Enabled') {
                If (Get-ItemProperty -Path $Key.path -Name $Key.Name -ErrorAction SilentlyContinue) { 
                    Write-EventLog -EventId 89 -Message "Found key, $($Key.path) Name $($Key.Name) Value $($Key.value)" -LogName 'Citrix Virtual Desktop Optimization' -Source 'Miscellaneous' -EntryType Information
                    Write-Verbose "Found key, $($Key.path) Name $($Key.Name) Value $($Key.value)"
                    Set-ItemProperty -Path $Key.path -Name $Key.Name -Value $Key.value -Force 
                }
                Else { 
                    If (Test-path $Key.path) {
                        Write-EventLog -EventId 89 -Message "Path found, creating new property -Path $($Key.path) -Name $($Key.Name) -PropertyType $($Key.valuetype) -Value $($Key.value)" -LogName 'Citrix Virtual Desktop Optimization' -Source 'Miscellaneous' -EntryType Information
                        Write-Verbose "Path found, creating new property -Path $($Key.path) Name $($Key.Name) PropertyType $($Key.valuetype) Value $($Key.value)"
                        New-ItemProperty -Path $Key.path -Name $Key.Name -PropertyType $Key.valuetype -Value $Key.value -Force | Out-Null 
                    }
                    Else {
                        Write-EventLog -EventId 89 -Message "Error: Creating Name $($Key.Name), Value $($Key.value) and Path $($Key.path)" -LogName 'Citrix Virtual Desktop Optimization' -Source 'Miscellaneous' -EntryType Information
                        Write-Verbose "Error: Creating Name $($Key.Name), Value $($Key.value) and Path $($Key.path)"
                        New-Item -Path $Key.path -Force | New-ItemProperty -Name $Key.Name -PropertyType $Key.valuetype -Value $Key.value -Force | Out-Null
                    }
                }
            }
        }
    }
    Else {
        Write-EventLog -EventId 89 -Message "No Miscellaneous Settings Found!" -LogName 'Citrix Virtual Desktop Optimization' -Source 'Miscellaneous' -EntryType Warning
        Write-Warning "No Miscellaneous Settings found"
    }

    Write-EventLog -EventId 89 -Message "Processing Powerscheme Settings" -LogName 'Citrix Virtual Desktop Optimization' -Source 'Miscellaneous' -EntryType Information
    Write-Verbose "Processing Powerscheme Settings"

    [String]$DesiredPlanID = "8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c"; #This is High Performance
    [String]$CurrentPlan = powercfg /GetActiveScheme
    # We could use RegEx, but it's just so hard to read. Insetad, using ":" as first delimiter and " " as second delimiter. Output of this command is localized, so we need to keep this as simple as possible. 
    [String]$CurrentPlanID = $CurrentPlan.Substring($CurrentPlan.IndexOf(":") + 2).Split(" ")[0];
    
    If ($CurrentPlanID -eq $DesiredPlanID) {
        Write-EventLog -EventId 89 -Message "Correct mode is selected. Power management schema ID: $CurrentPlanID" -LogName 'Citrix Virtual Desktop Optimization' -Source 'Miscellaneous' -EntryType Information
        Write-Verbose "Correct mode is selected. Power management schema ID: $CurrentPlanID";
    }
    Else {
        try {
            # Try to change power management plan
            Write-EventLog -EventId 89 -Message "Power management schema ID: $CurrentPlanID, Changing to High Performance" -LogName 'Citrix Virtual Desktop Optimization' -Source 'Miscellaneous' -EntryType Information
            Write-Verbose "Power management schema ID: $CurrentPlanID, Changing to High Performance";
            PowerCfg /SetActive $DesiredPlanID
        }
        catch {
            Write-EventLog -EventId 189 -Message "Failed to change power plan `n $($_.Exception.Message)" -LogName 'Citrix Virtual Desktop Optimization' -Source 'Miscellaneous' -EntryType Error
            Write-Warning "Failed to change power plan `n $($_.Exception.Message)"
        }
    }
    #endregion

    #region Maintenance Task
    #This contains maintenance tasks and optimizations that should be executed every time this image is updated.
    if ($hostname -like "*master*") {
        [Array]$EventLogs = wevtutil enum-logs
        Write-Host -ForegroundColor Yellow  'Clear event logs';
        # Clear all event log entries
        ForEach ($EventLog in $EventLogs) {
            Write-Verbose  "Clearing $EventLog";
            wevtutil cl "$EventLog" 2> $null;
        }
        # System event log contains events ID 104 ("Log Clear"), so it needs to be cleared as the last one again
        wevtutil cl "System";
        
        #Native Image Generation 32bit (NGEN)
        #This optimization pre-compiles .NET assemblies instead of using the just-in-time compilation using NGEN.exe.
        write-host "optimizing 32 bit .NET assemblies"
        write-host "THIS IS SLOW, it is normal for this operation to take a long time."
        .$Env:WinDir\Microsoft.Net\Framework\v4.0.*\ngen.exe Update;
        Write-Verbose "32 bit .NET assemblies optimized";

        #Native Image Generation 64bit (NGEN)
        #This optimization pre-compiles .NET assemblies instead of using the just-in-time compilation using NGEN.exe.
        If (Test-Path $Env:WinDir\Microsoft.Net\Framework64\v4.0.*\ngen.exe) {
            write-host "optimizing 64 bit .NET assemblies"
            write-host "THIS IS SLOW, it is normal for this operation to take a long time."
            .$Env:WinDir\Microsoft.Net\Framework64\v4.0.*\ngen.exe Update;
            Write-Verbose "64 bit .NET assemblies optimized";
        }
        Else {
            Write-Verbose "Skipping 64 bit, NGEN not found";
        }
    }
    #endregion

    Set-Location $CurrentLocation
    $EndTime = Get-Date
    $ScriptRunTime = New-TimeSpan -Start $StartTime -End $EndTime
    Write-EventLog -LogName 'Citrix Virtual Desktop Optimization' -Source 'COT' -EntryType Information -EventId 2 -Message "COT Total Run Time: $($ScriptRunTime.Hours) Hours $($ScriptRunTime.Minutes) Minutes $($ScriptRunTime.Seconds) Seconds"
    Write-Warning "A reboot is required for all changes to take effect"
    ########################  END OF SCRIPT  ########################
}