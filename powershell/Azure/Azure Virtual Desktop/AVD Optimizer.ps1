#AVD Optimizer version: 0.9.2.3
#VDOT gedeelte is gebasseerd op 2.1.2009.1.
#START#Services changes
Get-Service -Name "AJRouter" -ErrorAction "SilentlyContinue" | Set-Service -StartupType "Disabled" -ErrorAction "SilentlyContinue" | Out-Null
Get-Service -Name "ALG" -ErrorAction "SilentlyContinue" | Set-Service -StartupType "Disabled" -ErrorAction "SilentlyContinue" | Out-Null
Get-Service -Name "BTAGService" -ErrorAction "SilentlyContinue" | Set-Service -StartupType "Disabled" -ErrorAction "SilentlyContinue" | Out-Null
Get-Service -Name "bthserv" -ErrorAction "SilentlyContinue" | Set-Service -StartupType "Disabled" -ErrorAction "SilentlyContinue" | Out-Null
Get-Service -Name "DPS" -ErrorAction "SilentlyContinue" | Set-Service -StartupType "Disabled" -ErrorAction "SilentlyContinue" | Out-Null
Get-Service -Name "WdiServiceHost" -ErrorAction "SilentlyContinue" | Set-Service -StartupType "Disabled" -ErrorAction "SilentlyContinue" | Out-Null
Get-Service -Name "WdiSystemHost" -ErrorAction "SilentlyContinue" | Set-Service -StartupType "Disabled" -ErrorAction "SilentlyContinue" | Out-Null
Get-Service -Name "MapsBroker" -ErrorAction "SilentlyContinue" | Set-Service -StartupType "Disabled" -ErrorAction "SilentlyContinue" | Out-Null
Get-Service -Name "EFS" -ErrorAction "SilentlyContinue" | Set-Service -StartupType "Disabled" -ErrorAction "SilentlyContinue" | Out-Null
Get-Service -Name "fdPHost" -ErrorAction "SilentlyContinue" | Set-Service -StartupType "Disabled" -ErrorAction "SilentlyContinue" | Out-Null
Get-Service -Name "FDResPub" -ErrorAction "SilentlyContinue" | Set-Service -StartupType "Disabled" -ErrorAction "SilentlyContinue" | Out-Null
Get-Service -Name "UI0Detect" -ErrorAction "SilentlyContinue" | Set-Service -StartupType "Disabled" -ErrorAction "SilentlyContinue" | Out-Null
Get-Service -Name "SharedAccess" -ErrorAction "SilentlyContinue" | Set-Service -StartupType "Disabled" -ErrorAction "SilentlyContinue" | Out-Null
Get-Service -Name "CscService" -ErrorAction "SilentlyContinue" | Set-Service -StartupType "Disabled" -ErrorAction "SilentlyContinue" | Out-Null
Get-Service -Name "CSC" -ErrorAction "SilentlyContinue" | Set-Service -StartupType "Disabled" -ErrorAction "SilentlyContinue" | Out-Null
Get-Service -Name "SEMgrSvc" -ErrorAction "SilentlyContinue" | Set-Service -StartupType "Disabled" -ErrorAction "SilentlyContinue" | Out-Null
Get-Service -Name "SstpSvc" -ErrorAction "SilentlyContinue" | Set-Service -StartupType "Disabled" -ErrorAction "SilentlyContinue" | Out-Null
Get-Service -Name "SensrSvc" -ErrorAction "SilentlyContinue" | Set-Service -StartupType "Disabled" -ErrorAction "SilentlyContinue" | Out-Null
Get-Service -Name "shpamsvc" -ErrorAction "SilentlyContinue" | Set-Service -StartupType "Disabled" -ErrorAction "SilentlyContinue" | Out-Null
Get-Service -Name "SSDPSRV" -ErrorAction "SilentlyContinue" | Set-Service -StartupType "Disabled" -ErrorAction "SilentlyContinue" | Out-Null
Get-Service -Name "upnphost" -ErrorAction "SilentlyContinue" | Set-Service -StartupType "Disabled" -ErrorAction "SilentlyContinue" | Out-Null
Get-Service -Name "WMPNetworkSvc" -ErrorAction "SilentlyContinue" | Set-Service -StartupType "Disabled" -ErrorAction "SilentlyContinue" | Out-Null
Get-Service -Name "icssvc" -ErrorAction "SilentlyContinue" | Set-Service -StartupType "Disabled" -ErrorAction "SilentlyContinue" | Out-Null
Get-Service -Name "dot3svc" -ErrorAction "SilentlyContinue" | Set-Service -StartupType "Disabled" -ErrorAction "SilentlyContinue" | Out-Null
Get-Service -Name "wisvc" -ErrorAction "SilentlyContinue" | Set-Service -StartupType "Disabled" -ErrorAction "SilentlyContinue" | Out-Null
Get-Service -Name "Wcmsvc" -ErrorAction "SilentlyContinue" | Set-Service -StartupType "Disabled" -ErrorAction "SilentlyContinue" | Out-Null
Get-Service -Name "UALSVC" -ErrorAction "SilentlyContinue" | Set-Service -StartupType "Disabled" -ErrorAction "SilentlyContinue" | Out-Null
Get-Service -Name "TapiSrv" -ErrorAction "SilentlyContinue" | Set-Service -StartupType "Disabled" -ErrorAction "SilentlyContinue" | Out-Null
Get-Service -Name "TieringEngineService" -ErrorAction "SilentlyContinue" | Set-Service -StartupType "Disabled" -ErrorAction "SilentlyContinue" | Out-Null
Get-Service -Name "svsvc" -ErrorAction "SilentlyContinue" | Set-Service -StartupType "Disabled" -ErrorAction "SilentlyContinue" | Out-Null
Get-Service -Name "sacsvr" -ErrorAction "SilentlyContinue" | Set-Service -StartupType "Disabled" -ErrorAction "SilentlyContinue" | Out-Null
Get-Service -Name "SNMPTRAP" -ErrorAction "SilentlyContinue" | Set-Service -StartupType "Disabled" -ErrorAction "SilentlyContinue" | Out-Null
Get-Service -Name "SensorService" -ErrorAction "SilentlyContinue" | Set-Service -StartupType "Disabled" -ErrorAction "SilentlyContinue" | Out-Null
Get-Service -Name "SensorDataService" -ErrorAction "SilentlyContinue" | Set-Service -StartupType "Disabled" -ErrorAction "SilentlyContinue" | Out-Null
Get-Service -Name "RasMan" -ErrorAction "SilentlyContinue" | Set-Service -StartupType "Disabled" -ErrorAction "SilentlyContinue" | Out-Null
Get-Service -Name "RmSvc" -ErrorAction "SilentlyContinue" | Set-Service -StartupType "Disabled" -ErrorAction "SilentlyContinue" | Out-Null
Get-Service -Name "PcaSvc" -ErrorAction "SilentlyContinue" | Set-Service -StartupType "Disabled" -ErrorAction "SilentlyContinue" | Out-Null
Get-Service -Name "wercplsupport" -ErrorAction "SilentlyContinue" | Set-Service -StartupType "Disabled" -ErrorAction "SilentlyContinue" | Out-Null
Get-Service -Name "NcaSvc" -ErrorAction "SilentlyContinue" | Set-Service -StartupType "Disabled" -ErrorAction "SilentlyContinue" | Out-Null
Get-Service -Name "NcbService" -ErrorAction "SilentlyContinue" | Set-Service -StartupType "Disabled" -ErrorAction "SilentlyContinue" | Out-Null
Get-Service -Name "smphost" -ErrorAction "SilentlyContinue" | Set-Service -StartupType "Disabled" -ErrorAction "SilentlyContinue" | Out-Null
Get-Service -Name "MSiSCSI" -ErrorAction "SilentlyContinue" | Set-Service -StartupType "Disabled" -ErrorAction "SilentlyContinue" | Out-Null
Get-Service -Name "diagnosticshub.standardcollector.service" -ErrorAction "SilentlyContinue" | Set-Service -StartupType "Disabled" -ErrorAction "SilentlyContinue" | Out-Null
Get-Service -Name "lltdsvc" -ErrorAction "SilentlyContinue" | Set-Service -StartupType "Disabled" -ErrorAction "SilentlyContinue" | Out-Null
Get-Service -Name "iphlpsvc" -ErrorAction "SilentlyContinue" | Set-Service -StartupType "Disabled" -ErrorAction "SilentlyContinue" | Out-Null
Get-Service -Name "lfsvc" -ErrorAction "SilentlyContinue" | Set-Service -StartupType "Disabled" -ErrorAction "SilentlyContinue" | Out-Null
Get-Service -Name "Eaphost" -ErrorAction "SilentlyContinue" | Set-Service -StartupType "Disabled" -ErrorAction "SilentlyContinue" | Out-Null
Get-Service -Name "dmwappushservice" -ErrorAction "SilentlyContinue" | Set-Service -StartupType "Disabled" -ErrorAction "SilentlyContinue" | Out-Null
Get-Service -Name "DcpSvc" -ErrorAction "SilentlyContinue" | Set-Service -StartupType "Disabled" -ErrorAction "SilentlyContinue" | Out-Null
Get-Service -Name "BITS" -ErrorAction "SilentlyContinue" | Set-Service -StartupType "Disabled" -ErrorAction "SilentlyContinue" | Out-Null
Get-Service -Name "AppMgmt" -ErrorAction "SilentlyContinue" | Set-Service -StartupType "Disabled" -ErrorAction "SilentlyContinue" | Out-Null
Get-Service -Name "SysMain" -ErrorAction "SilentlyContinue" | Set-Service -StartupType "Disabled" -ErrorAction "SilentlyContinue" | Out-Null
#VMware OSOT waardes vanaf hieronder
Get-Service -Name "DusmSvc" -ErrorAction "SilentlyContinue" | Set-Service -StartupType "Disabled" -ErrorAction "SilentlyContinue" | Out-Null
#END#Services changes

#START#Scheduled tasks changes
Get-ScheduledTask -TaskPath "\Microsoft\Windows\Power Efficiency Diagnostics\" -TaskName AnalyzeSystem | Unregister-ScheduledTask -Confirm:$false -ErrorAction "SilentlyContinue"
Get-ScheduledTask -TaskPath "\Microsoft\Windows\Windows Filtering Platform\" -TaskName BfeOnServiceStartTypeChange | Unregister-ScheduledTask -Confirm:$false -ErrorAction "SilentlyContinue"
Get-ScheduledTask -TaskPath "\Microsoft\Windows\Customer Experience Improvement Program\" -TaskName Consolidator | Unregister-ScheduledTask -Confirm:$false -ErrorAction "SilentlyContinue"
Get-ScheduledTask -TaskPath "\Microsoft\Windows\CloudExperienceHost\" -TaskName CreateObjectTask | Unregister-ScheduledTask -Confirm:$false -ErrorAction "SilentlyContinue"
Get-ScheduledTask -TaskPath "\Microsoft\Windows\Shell\" -TaskName IndexerAutomaticMaintenance | Unregister-ScheduledTask -Confirm:$false -ErrorAction "SilentlyContinue"
Get-ScheduledTask -TaskPath "\Microsoft\Windows\Customer Experience Improvement Program\" -TaskName KernelCeipTask | Unregister-ScheduledTask -Confirm:$false -ErrorAction "SilentlyContinue"
Get-ScheduledTask -TaskPath "\Microsoft\Windows\Application Experience\" -TaskName "Microsoft Compatibility Appraiser" | Unregister-ScheduledTask -Confirm:$false -ErrorAction "SilentlyContinue"
Get-ScheduledTask -TaskPath "\Microsoft\Windows\DiskDiagnostic\" -TaskName Microsoft-Windows-DiskDiagnosticDataCollector | Unregister-ScheduledTask -Confirm:$false -ErrorAction "SilentlyContinue"
Get-ScheduledTask -TaskPath "\Microsoft\Windows\DiskDiagnostic\" -TaskName Microsoft-Windows-DiskDiagnosticResolver | Unregister-ScheduledTask -Confirm:$false -ErrorAction "SilentlyContinue"
Get-ScheduledTask -TaskPath "\Microsoft\Windows\Mobile Broadband Accounts\" -TaskName "MNO Metadata Parser" | Unregister-ScheduledTask -Confirm:$false -ErrorAction "SilentlyContinue"
Get-ScheduledTask -TaskPath "\Microsoft\Windows\Ras\" -TaskName MobilityManager | Unregister-ScheduledTask -Confirm:$false -ErrorAction "SilentlyContinue"
Get-ScheduledTask -TaskPath "\Microsoft\Windows\Location\" -TaskName Notifications | Unregister-ScheduledTask -Confirm:$false -ErrorAction "SilentlyContinue"
Get-ScheduledTask -TaskPath "\Microsoft\Windows\CHKDSK\" -TaskName ProactiveScan | Unregister-ScheduledTask -Confirm:$false -ErrorAction "SilentlyContinue"
Get-ScheduledTask -TaskPath "\Microsoft\Windows\MemoryDiagnostic\" -TaskName ProcessMemoryDiagnosticEvents | Unregister-ScheduledTask -Confirm:$false -ErrorAction "SilentlyContinue"
Get-ScheduledTask -TaskPath "\Microsoft\Windows\Application Experience\" -TaskName ProgramDataUpdater | Unregister-ScheduledTask -Confirm:$false -ErrorAction "SilentlyContinue"
Get-ScheduledTask -TaskPath "\Microsoft\Windows\Autochk\" -TaskName Proxy | Unregister-ScheduledTask -Confirm:$false -ErrorAction "SilentlyContinue"
Get-ScheduledTask -TaskPath "\Microsoft\Windows\Windows Error Reporting\" -TaskName QueueReporting | Unregister-ScheduledTask -Confirm:$false -ErrorAction "SilentlyContinue"
Get-ScheduledTask -TaskPath "\Microsoft\Windows\Registry\" -TaskName RegIdleBackup | Unregister-ScheduledTask -Confirm:$false -ErrorAction "SilentlyContinue"
Get-ScheduledTask -TaskPath "\Microsoft\Windows\WDI\" -TaskName ResolutionHost | Unregister-ScheduledTask -Confirm:$false -ErrorAction "SilentlyContinue"
Get-ScheduledTask -TaskPath "\Microsoft\Windows\MemoryDiagnostic\" -TaskName RunFullMemoryDiagnostic | Unregister-ScheduledTask -Confirm:$false -ErrorAction "SilentlyContinue"
Get-ScheduledTask -TaskPath "\Microsoft\Windows\Diagnosis\" -TaskName Scheduled | Unregister-ScheduledTask -Confirm:$false -ErrorAction "SilentlyContinue"
Get-ScheduledTask -TaskPath "\Microsoft\Windows\AppID\" -TaskName SmartScreenSpecific | Unregister-ScheduledTask -Confirm:$false -ErrorAction "SilentlyContinue"
Get-ScheduledTask -TaskPath "\Microsoft\Windows\Servicing\" -TaskName StartComponentCleanup | Unregister-ScheduledTask -Confirm:$false -ErrorAction "SilentlyContinue"
Get-ScheduledTask -TaskPath "\Microsoft\Windows\Application Experience\" -TaskName StartupAppTask | Unregister-ScheduledTask -Confirm:$false -ErrorAction "SilentlyContinue"
Get-ScheduledTask -TaskPath "\Microsoft\Windows\Bluetooth\" -TaskName "UninstallDeviceTask" | Unregister-ScheduledTask -Confirm:$false -ErrorAction "SilentlyContinue"
Get-ScheduledTask -TaskPath "\Microsoft\Windows\UPnP\" -TaskName "UPnPHostConfig" | Unregister-ScheduledTask -Confirm:$false -ErrorAction "SilentlyContinue"
Get-ScheduledTask -TaskPath "\Microsoft\Windows\Customer Experience Improvement Program\" -TaskName "UsbCeip" | Unregister-ScheduledTask -Confirm:$false -ErrorAction "SilentlyContinue"
Get-ScheduledTask -TaskPath "\Microsoft\Windows\RecoveryEnvironment\" -TaskName "VerifyWinRE" | Unregister-ScheduledTask -Confirm:$false -ErrorAction "SilentlyContinue"
Get-ScheduledTask -TaskPath "\Microsoft\Windows\Windows Defender\" -TaskName "Windows Defender Cache Maintenance" | Unregister-ScheduledTask -Confirm:$false -ErrorAction "SilentlyContinue"
Get-ScheduledTask -TaskPath "\Microsoft\Windows\Windows Defender\" -TaskName "Windows Defender Cleanup" | Unregister-ScheduledTask -Confirm:$false -ErrorAction "SilentlyContinue"
Get-ScheduledTask -TaskPath "\Microsoft\Windows\Windows Defender\" -TaskName "Windows Defender Scheduled Scan" | Unregister-ScheduledTask -Confirm:$false -ErrorAction "SilentlyContinue"
Get-ScheduledTask -TaskPath "\Microsoft\Windows\Windows Defender\" -TaskName "Windows Defender Verification" | Unregister-ScheduledTask -Confirm:$false -ErrorAction "SilentlyContinue"
Get-ScheduledTask -TaskPath "\Microsoft\Windows\Windows Media Sharing\" -TaskName UpdateLibrary | Unregister-ScheduledTask -Confirm:$false -ErrorAction "SilentlyContinue"
Get-ScheduledTask -TaskPath "\Microsoft\Windows\Maintenance\" -TaskName WinSAT  | Unregister-ScheduledTask -Confirm:$false -ErrorAction "SilentlyContinue"
Get-ScheduledTask -TaskPath "\Microsoft\Windows\Workplace Join\" -TaskName "Recovery-Check" | Unregister-ScheduledTask -Confirm:$false -ErrorAction "SilentlyContinue"
Get-ScheduledTask -TaskPath "\Microsoft\Windows\AppID\" -TaskName "EDP Policy Manager" | Unregister-ScheduledTask -Confirm:$false -ErrorAction "SilentlyContinue"
Get-ScheduledTask -TaskPath "\Microsoft\Windows\ApplicationData\" -TaskName CleanupTemporaryState | Unregister-ScheduledTask -Confirm:$false -ErrorAction "SilentlyContinue"
Get-ScheduledTask -TaskPath "\Microsoft\Windows\ApplicationData\" -TaskName DsSvcCleanup | Unregister-ScheduledTask -Confirm:$false -ErrorAction "SilentlyContinue"
Get-ScheduledTask -TaskPath "\Microsoft\Windows\CertificateServicesClient\" -TaskName AikCertEnrollTask | Unregister-ScheduledTask -Confirm:$false -ErrorAction "SilentlyContinue"
Get-ScheduledTask -TaskPath "\Microsoft\Windows\Data Integrity Scan\" -TaskName "Data Integrity Scan" | Unregister-ScheduledTask -Confirm:$false -ErrorAction "SilentlyContinue"
Get-ScheduledTask -TaskPath "\Microsoft\Windows\Data Integrity Scan\" -TaskName "Data Integrity Scan for Crash Recovery" | Unregister-ScheduledTask -Confirm:$false -ErrorAction "SilentlyContinue"
Get-ScheduledTask -TaskPath "\Microsoft\Windows\Device Information\" -TaskName Device | Unregister-ScheduledTask -Confirm:$false -ErrorAction "SilentlyContinue"
Get-ScheduledTask -TaskPath "\Microsoft\Windows\DiskCleanup\" -TaskName SilentCleanup | Unregister-ScheduledTask -Confirm:$false -ErrorAction "SilentlyContinue"
Get-ScheduledTask -TaskPath "\Microsoft\Windows\Location\" -TaskName WindowsActionDialog | Unregister-ScheduledTask -Confirm:$false -ErrorAction "SilentlyContinue"
Get-ScheduledTask -TaskPath "\Microsoft\Windows\MUI\" -TaskName LPRemove | Unregister-ScheduledTask -Confirm:$false -ErrorAction "SilentlyContinue"
Get-ScheduledTask -TaskPath "\Microsoft\Windows\NetTrace\" -TaskName GatherNetworkInfo | Unregister-ScheduledTask -Confirm:$false -ErrorAction "SilentlyContinue"
Get-ScheduledTask -TaskPath "\Microsoft\Windows\Speech\" -TaskName SpeechModelDownloadTask | Unregister-ScheduledTask -Confirm:$false -ErrorAction "SilentlyContinue"
Get-ScheduledTask -TaskPath "\Microsoft\Windows\UpdateOrchestrator\" -TaskName "Schedule Scan" | Unregister-ScheduledTask -Confirm:$false -ErrorAction "SilentlyContinue"
Get-ScheduledTask -TaskPath "\Microsoft\Windows\WindowsUpdate\" -TaskName "Automatic App Update" | Unregister-ScheduledTask -Confirm:$false -ErrorAction "SilentlyContinue"
Get-ScheduledTask -TaskPath "\Microsoft\Windows\WindowsUpdate\" -TaskName "Scheduled Start" | Unregister-ScheduledTask -Confirm:$false -ErrorAction "SilentlyContinue"
Get-ScheduledTask -TaskPath "\Microsoft\Windows\WindowsUpdate\" -TaskName sih | Unregister-ScheduledTask -Confirm:$false -ErrorAction "SilentlyContinue"
Get-ScheduledTask -TaskPath "\Microsoft\Windows\WindowsUpdate\" -TaskName sihboot | Unregister-ScheduledTask -Confirm:$false -ErrorAction "SilentlyContinue"
#VMware OSOT waardes vanaf hieronder
Get-ScheduledTask -TaskPath "\Microsoft\Windows\Feedback\Siuf\" -TaskName DmClient | Unregister-ScheduledTask -Confirm:$false -ErrorAction "SilentlyContinue"
Get-ScheduledTask -TaskPath "\Microsoft\Office\" -TaskName "Office Automatic Updates 2.0" | Unregister-ScheduledTask -Confirm:$false -ErrorAction "SilentlyContinue"
Get-ScheduledTask -TaskPath "\Microsoft\Office\" -TaskName OfficeTelemetryAgentFallBack2016 | Unregister-ScheduledTask -Confirm:$false -ErrorAction "SilentlyContinue"
Get-ScheduledTask -TaskPath "\Microsoft\Office\" -TaskName OfficeTelemetryAgentLogOn2016 | Unregister-ScheduledTask -Confirm:$false -ErrorAction "SilentlyContinue"
Get-ScheduledTask -TaskPath "\Microsoft\Windows\LanguageComponentsInstaller\" -TaskName ReconcileLanguageResources | Unregister-ScheduledTask -Confirm:$false -ErrorAction "SilentlyContinue"
Get-ScheduledTask -TaskPath "\Microsoft\Windows\.NET Framework\" -TaskName ".NET Framework NGEN v4.0.30319" | Unregister-ScheduledTask -Confirm:$false -ErrorAction "SilentlyContinue"
Get-ScheduledTask -TaskPath "\Microsoft\Windows\.NET Framework\\" -TaskName ".NET Framework NGEN v4.0.30319 64" | Unregister-ScheduledTask -Confirm:$false -ErrorAction "SilentlyContinue"
Get-ScheduledTask -TaskPath "\Microsoft\Windows\.NET Framework" -TaskName ".NET Framework NGEN v4.0.30319 Critical" | Unregister-ScheduledTask -Confirm:$false -ErrorAction "SilentlyContinue"
Get-ScheduledTask -TaskPath "\Microsoft\Windows\.NET Framework\" -TaskName ".NET Framework NGEN v4.0.30319 64 Critical" | Unregister-ScheduledTask -Confirm:$false -ErrorAction "SilentlyContinue"
Get-ScheduledTask -TaskPath "\Microsoft\Windows\Application Experience\" -TaskName PcaPatchDBTask | Unregister-ScheduledTask -Confirm:$false -ErrorAction "SilentlyContinue"
Get-ScheduledTask -TaskPath "\Microsoft\Windows\WCM\" -TaskName WiFiTask | Unregister-ScheduledTask -Confirm:$false -ErrorAction "SilentlyContinue"
Get-ScheduledTask -TaskPath "\Microsoft\Windows\Management\Provisioning\" -TaskName Cellular | Unregister-ScheduledTask -Confirm:$false -ErrorAction "SilentlyContinue"
Get-ScheduledTask -TaskPath "\Microsoft\Windows\Sysmain\" -TaskName WsSwapAssessmentTask | Unregister-ScheduledTask -Confirm:$false -ErrorAction "SilentlyContinue"
Get-ScheduledTask -TaskPath "\Microsoft\Windows\BrokerInfrastructure\" -TaskName BgTaskRegistrationMaintenanceTask | Unregister-ScheduledTask -Confirm:$false -ErrorAction "SilentlyContinue"
Get-ScheduledTask -TaskPath "\Microsoft\Windows\StateRepository\" -TaskName MaintenanceTasks | Unregister-ScheduledTask -Confirm:$false -ErrorAction "SilentlyContinue"
Get-ScheduledTask -TaskPath "\Microsoft\Windows\WOF\" -TaskName WIM-Hash-Management | Unregister-ScheduledTask -Confirm:$false -ErrorAction "SilentlyContinue"
Get-ScheduledTask -TaskPath "\Microsoft\Windows\WOF\" -TaskName WIM-Hash-Validation | Unregister-ScheduledTask -Confirm:$false -ErrorAction "SilentlyContinue"
Get-ScheduledTask -TaskPath "\Microsoft\XblGameSave\" -TaskName XblGameSaveTask | Unregister-ScheduledTask -Confirm:$false -ErrorAction "SilentlyContinue"
Get-ScheduledTask -TaskPath "\Microsoft\Windows\Data Integrity Scan\" -TaskName "Data Integrity Check And Scan" | Unregister-ScheduledTask -Confirm:$false -ErrorAction "SilentlyContinue"
Get-ScheduledTask -TaskPath "\Microsoft\Windows\Management\Provisioning\" -TaskName Logon | Unregister-ScheduledTask -Confirm:$false -ErrorAction "SilentlyContinue"
Get-ScheduledTask -TaskPath "\Microsoft\Windows\ApplicationData\" -TaskName appuriverifierdaily | Unregister-ScheduledTask -Confirm:$false -ErrorAction "SilentlyContinue"
Get-ScheduledTask -TaskPath "\Microsoft\Windows\Flighting\OneSettings\" -TaskName RefreshCache | Unregister-ScheduledTask -Confirm:$false -ErrorAction "SilentlyContinue"
Get-ScheduledTask -TaskPath "\Microsoft\Windows\International\" -TaskName "Synchronize Language Settings" | Unregister-ScheduledTask -Confirm:$false -ErrorAction "SilentlyContinue"
Get-ScheduledTask -TaskPath "\Microsoft\Windows\Shell\" -TaskName FamilySafetyMonitor | Unregister-ScheduledTask -Confirm:$false -ErrorAction "SilentlyContinue"
Get-ScheduledTask -TaskPath "\Microsoft\Windows\Shell\" -TaskName FamilySafetyRefreshTask | Unregister-ScheduledTask -Confirm:$false -ErrorAction "SilentlyContinue"
Get-ScheduledTask -TaskPath "\Microsoft\Windows\Maps\" -TaskName MapsToastTask | Unregister-ScheduledTask -Confirm:$false -ErrorAction "SilentlyContinue"
Get-ScheduledTask -TaskPath "\Microsoft\Windows\SystemRestore\" -TaskName SR | Unregister-ScheduledTask -Confirm:$false -ErrorAction "SilentlyContinue"
Get-ScheduledTask -TaskPath "\Microsoft\Windows\Diagnosis\" -TaskName RecommendedTroubleshootingScanner | Unregister-ScheduledTask -Confirm:$false -ErrorAction "SilentlyContinue"
Get-ScheduledTask -TaskPath "\Microsoft\Windows\Flighting\FeatureConfig\" -TaskName ReconcileFeatures | Unregister-ScheduledTask -Confirm:$false -ErrorAction "SilentlyContinue"
Get-ScheduledTask -TaskPath "\Microsoft\Windows\Sysmain\" -TaskName ResPriStaticDbSync | Unregister-ScheduledTask -Confirm:$false -ErrorAction "SilentlyContinue"
Get-ScheduledTask -TaskPath "\Microsoft\Windows\PI\" -TaskName Sqm-Tasks | Unregister-ScheduledTask -Confirm:$false -ErrorAction "SilentlyContinue"
#END#Scheduled tasks changes

#START#Register changes
reg add "HKLM\SYSTEM\CurrentControlSet\Services\SharedAccess\Parameters\FirewallPolicy" /v "DeleteUserAppContainersOnLogoff" /t "REG_DWORD" /d 1 /f | Out-Null
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\OptimalLayout" /v "EnableAutoLayout" /t "REG_DWORD" /d 0 /f | Out-Null
reg add "HKU\.DEFAULT\Control Panel\Desktop" /v "ScreenSaveActive" /t "REG_DWORD" /d 0 /f | Out-Null
reg add "HKLM\SYSTEM\CurrentControlSet\Control\CrashControl" /v "CrashDumpEnabled" /t "REG_DWORD" /d 0 /f | Out-Null
reg add "HKLM\SYSTEM\CurrentControlSet\Control\FileSystem" /v "NtfsDisableLastAccessUpdate" /t "REG_DWORD" /d 1 /f | Out-Null
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" /v "NoAutoUpdate" /t "REG_DWORD" /d 1 /f | Out-Null
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Internet Settings\Cache\Paths\path4" /v "CacheLimit" /t "REG_DWORD" /d 0x100 /f | Out-Null
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Internet Settings\Cache\Paths\path3" /v "CacheLimit" /t "REG_DWORD" /d 0x100 /f | Out-Null
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Internet Settings\Cache\Paths\path2" /v "CacheLimit" /t "REG_DWORD" /d 0x100 /f | Out-Null
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Internet Settings\Cache\Paths\path1" /v "CacheLimit" /t "REG_DWORD" /d 0x100 /f | Out-Null
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Internet Settings\Cache\Paths" /v "Paths" /t "REG_DWORD" /d 0x4 /f | Out-Null
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Eventlog\System" /v "MaxSize" /t "REG_DWORD" /d 0x10000 /f | Out-Null
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Eventlog\Security" /v "MaxSize" /t "REG_DWORD" /d 0x10000 /f | Out-Null
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v "NoRemoteRecursiveEvents" /t "REG_DWORD" /d 0x1 /f | Out-Null
reg add "HKLM\SYSTEM\CurrentControlSet\Control" /v "ServicesPipeTimeout" /t "REG_DWORD" /d 0xafc8 /f | Out-Null
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection" /v "AllowTelemetry" /t "REG_DWORD" /d 0x0 /f | Out-Null
reg add "HKLM\SYSTEM\CurrentControlSet\Control\CrashControl" /v "DumpFileSize" /t "REG_DWORD" /d 0x2 /f | Out-Null
reg add "HKLM\SYSTEM\CurrentControlSet\Control\CrashControl" /v "IgnorePagefileSize" /t "REG_DWORD" /d 0x1 /f | Out-Null
reg add "HKLM\System\CurrentControlSet\Control\Session Manager\Memory Management" /v "DisablePagingExecutive" /t "REG_DWORD" /d 0x1 /f | Out-Null
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Print\Providers" /v "EventLog" /t "REG_DWORD" /d 0x1 /f | Out-Null
reg add "HKLM\SYSTEM\CurrentControlSet\Control\CrashControl" /v "logevent" /t "REG_DWORD" /d 0x0 /f | Out-Null
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "ClearPageFileAtShutdown" /t "REG_DWORD" /d 0x0 /f | Out-Null
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\ControlPanel\NameSpace\{025A5937-A6BE-4686-A844-36FE4BEC8B6D}" /v "8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c" /t "REG_SZ" /f | Out-Null
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Schedule\Maintenance" /v "MaintenanceDisabled" /t "REG_DWORD" /d 1 /f | Out-Null
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Keyboard Layout" /v "IgnoreRemoteKeyboardLayout" /d 1 /t "REG_DWORD" /f | Out-Null
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations" /v "ICEControl" /t "REG_DWORD" /d 2 /f | Out-Null
reg add "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" /v "HwSchMode" /t "REG_DWORD" /d 2 /f | Out-Null
#VMware OSOT waardes vanaf hieronder
reg add "HKLM\Software\Policies\Microsoft\Windows\TabletPC" /v "PreventHandwritingDataSharing" /t "REG_DWORD" /d 0 /f | Out-Null
reg add "HKLM\Software\Policies\Microsoft\Windows\HandwritingErrorReports"/v "PreventHandwritingErrorReports" /t "REG_DWORD" /d 1 /f | Out-Null
reg add "HKLM\Software\Policies\Microsoft\Messenger\Client" /v "CEIP" /t "REG_DWORD" /d 2 /f | Out-Null
reg add "HKLM\Software\Policies\Microsoft\SQMClient\Windows" /v "CEIPEnable" /t "REG_DWORD" /d 0 /f | Out-Null
reg add "HKLM\Software\Policies\Microsoft\PCHealth\ErrorReporting" /v "DoReport" /t "REG_DWORD" /d 0 /f | Out-Null
reg add "HKLM\SOFTWARE\Policies\Microsoft\FindMyDevice" /v "AllowFindMyDevice" /t "REG_DWORD" /d 0 /f | Out-Null
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Error Reporting" /v "DontSendAdditionalData" /t "REG_DWORD" /d 1 /f | Out-Null
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v "DisplayLastLogonInfo" /t "REG_DWORD" /d 0 /f | Out-Null
reg add "HKLM\SOFTWARE\Microsoft\Settings\FindMyDevice" /v "LocationSyncEnabled" /t "REG_DWORD" /d 0 /f | Out-Null
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\AdvertisingInfo" /v "DisabledByGroupPolicy" /t "REG_DWORD" /d 1 /f | Out-Null
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\AppCompat" /v "DisableInventory" /t "REG_DWORD" /d 1 /f | Out-Null
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v "DisableAutomaticRestartSignOn" /t "REG_DWORD" /d 1 /f | Out-Null
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\OOBE" /v "DisablePrivacyExperience" /t "REG_DWORD" /d 1 /f | Out-Null
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection" /v "MicrosoftEdgeDataOptIn" /t "REG_DWORD" /d 0 /f | Out-Null
reg add "HKLM\SOFTWARE\Policies\Microsoft\InputPersonalization" /v "RestrictImplicitTextCollection" /t "REG_DWORD" /d 1 /f | Out-Null
reg add "HKLM\SOFTWARE\Policies\Microsoft\InputPersonalization" /v "RestrictImplicitInkCollection" /t "REG_DWORD" /d 1 /f | Out-Null
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection" /v "LimitEnhancedDiagnosticDataWindowsAnalytics" /t "REG_DWORD" /d 0 /f | Out-Null
reg add "HKLM\Software\Policies\Microsoft\Windows\DataCollection" /v "DoNotShowFeedbackNotifications" /t "REG_DWORD" /d 1 /f | Out-Null
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\TextInput" /v "AllowLinguisticDataCollection" /t "REG_DWORD" /d 0 /f | Out-Null
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Error Reporting" /v "AutoApproveOSDumps" /t "REG_DWORD" /d 0 /f | Out-Null
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Error Reporting" /v "Disabled" /t "REG_DWORD" /d 1 /f | Out-Null
reg add "HKLM\SOFTWARE\Policies\Microsoft\MicrosoftEdge\BooksLibrary" /v "EnableExtendedBooksTelemetry" /t "REG_DWORD" /d 0 /f | Out-Null
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\AppCompat" /v "AITEnableAITEnable" /t "REG_DWORD" /d 0 /f | Out-Null
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\DeliveryOptimization\Config" /v "DownloadMode" /t "REG_DWORD" /d 0 /f | Out-Null
reg add "HKLM\Software\Policies\Microsoft\Office\16.0\Common\OfficeUpdate" /v "EnableAutomaticUpdates" /t "REG_DWORD" /d 0 /f | Out-Null
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" /v "DeferQualityUpdates" /t "REG_DWORD" /d 1 /f | Out-Null
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v "DisableStartupSound" /t "REG_DWORD" /d 1 /f | Out-Null
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\CloudContent" /v "DisableTailoredExperiencesWithDiagnosticData" /t "REG_DWORD" /d 1 /f | Out-Null
reg add "HKLM\Software\Policies\Microsoft\Windows\CloudContent" /v "DisableSoftLanding" /t "REG_DWORD" /d 1 /f | Out-Null
reg add "HKLM\SOFTWARE\Policies\Microsoft\Speech" /v "AllowSpeechModelUpdate" /t "REG_DWORD" /d 0 /f | Out-Null
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Search" /v "PreventIndexingLowDiskSpaceMB" /t "REG_DWORD" /d 500 /f | Out-Null
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Search" /v "PreventIndexingUncachedExchangeFolders" /t "REG_DWORD" /d 1 /f | Out-Null
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v "AllowOnlineTips" /t "REG_DWORD" /d 0 /f | Out-Null
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\System" /v "DontDisplayNetworkSelectionUI" /t "REG_DWORD" /d 1 /f | Out-Null
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v "NoWelcomeScreen" /t "REG_DWORD" /d 1 /f | Out-Null
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v "VerboseStatus" /t "REG_DWORD" /d 1 /f | Out-Null
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\DWM" /v "DisallowFlip3d" /t "REG_DWORD" /d 1 /f | Out-Null
reg add "HKLM\Software\Policies\Microsoft\Windows\EdgeUI" /v "DisableHelpSticker" /t "REG_DWORD" /d 1 /f | Out-Null
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Explorer" /v "NoNewAppAlert" /t "REG_DWORD" /d 1 /f | Out-Null
reg add "HKLM\SOFTWARE\Policies\Microsoft\Internet Explorer\SearchScopes" /v "ShowSearchSuggestionsGlobal" /t "REG_DWORD" /d 0 /f | Out-Null
reg add "HKLM\SOFTWARE\Policies\Microsoft\Internet Explorer\Main" /v "DisableFirstRunCustomize" /t "REG_DWORD" /d 1 /f | Out-Null
reg add "HKLM\SOFTWARE\Policies\Microsoft\Internet Explorer\Feeds" /v "BackgroundSyncStatus" /t "REG_DWORD" /d 0 /f | Out-Null
reg add "HKLM\SOFTWARE\Policies\Microsoft\Internet Explorer\FlipAhead" /v "Enabled" /t "REG_DWORD" /d 0 /f | Out-Null
reg add "HKLM\SOFTWARE\Policies\Microsoft\Internet Explorer\Main" /v "Play_Animations" /t "REG_SZ" /d "no" /f | Out-Null
reg add "HKLM\SOFTWARE\Policies\Microsoft\Internet Explorer\PrefetchPrerender" /v "Enabled" /t "REG_DWORD" /d 0 /f | Out-Null
reg add "HKLM\Software\Policies\Microsoft\Internet Explorer\Infodelivery\Restrictions" /v "NoUpdateCheck" /t "REG_DWORD" /d 1 /f | Out-Null
reg add "HKLM\Software\Policies\Microsoft\Internet Explorer\Infodelivery\Restrictions" /v "NoSplash" /t "REG_DWORD" /d 1 /f | Out-Null
reg add "HKLM\Software\Policies\Microsoft\Internet Explorer\Main" /v "EnableAutoUpgrade" /t "REG_DWORD" /d 0 /f | Out-Null
reg add "HKLM\Software\Policies\Microsoft\Internet Explorer\SQM" /v "DisableCustomerImprovementProgram" /t "REG_DWORD" /d 0 /f | Out-Null
reg add "HKLM\Software\Policies\Microsoft\Internet Explorer\Main" /v "TabProcGrowth" /t "REG_SZ" /d "low" /f | Out-Null   
reg add "HKLM\Software\Policies\Microsoft\Internet Explorer\Feed Discovery" /v "Enabled" /t "REG_DWORD" /d 0 /f | Out-Null
reg add "HKLM\Software\Policies\Microsoft\WindowsMediaPlayer" /v "GroupPrivacyAcceptance" /t "REG_DWORD" /d 1 /f | Out-Null
reg add "HKLM\Software\Policies\Microsoft\WindowsMediaPlayer" /v "PreventLibrarySharing" /t "REG_DWORD" /d 1 /f | Out-Null
reg add "HKLM\Software\Policies\Microsoft\WindowsStore" /v "DisableOSUpgrade" /t "REG_DWORD" /d 1 /f | Out-Null
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\AppPrivacy" /v "LetAppsRunInBackground" /t "REG_DWORD" /d 2 /f | Out-Null
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\AppPrivacy" /v "LetAppsRunInBackground_UserInControlOfTheseApps" /t "REG_MULTI_SZ" /d 2 /f | Out-Null
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\AppPrivacy" /v "LetAppsRunInBackground_ForceAllowTheseApps" /t "REG_MULTI_SZ" /f | Out-Null
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\AppPrivacy" /v "LetAppsRunInBackground_ForceDenyTheseApps" /t "REG_MULTI_SZ" /f | Out-Null
reg add "HKLM\Software\Policies\Microsoft\Windows\DeviceInstall\Settings" /v "DisableSendGenericDriverNotFoundToWER" /t "REG_DWORD" /d 1 /f | Out-Null
reg add "HKLM\Software\Policies\Microsoft\Windows\DeviceInstall\Settings" /v "DisableSystemRestore" /t "REG_DWORD" /d 1 /f | Out-Null
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Device Metadata" /v "PreventDeviceMetadataFromNetwork" /t "REG_DWORD" /d 2 /f | Out-Null
reg add "HKLM\Software\Policies\Microsoft\Windows\DeviceInstall\Settings" /v "DisableSendRequestAdditionalSoftwareToWER" /t "REG_DWORD" /d 1 /f | Out-Null
reg add "HKLM\Software\Policies\Microsoft\Windows\DeviceInstall\Settings" /v "DisableBalloonTips" /t "REG_DWORD" /d 1 /f | Out-Null
reg add "HKLM\Software\Policies\Microsoft\Windows\Maps" /v "AutoDownloadAndUpdateMapData" /t "REG_DWORD" /d 0 /f | Out-Null
reg add "HKLM\Software\Policies\Microsoft\Windows\Maps" /v "AllowUntriggeredNetworkTrafficOnSettingsPage" /t "REG_DWORD" /d 0 /f | Out-Null
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Messaging" /v "AllowMessageSync" /t "REG_DWORD" /d 0 /f | Out-Null
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\DeliveryOptimization" /v "DODownloadMode" /t "REG_DWORD" /d 99 /f | Out-Null
reg add "HKLM\Software\Policies\Microsoft\PCHealth\HelpSvc" /v "Headlines" /t "REG_DWORD" /d 0 /f | Out-Null
reg add "HKLM\Software\Policies\Microsoft\PCHealth\HelpSvc" /v "MicrosoftKBSearch" /t "REG_DWORD" /d 0 /f | Out-Null
reg add "HKLM\SOFTWARE\Policies\Microsoft\PeerDist\Service" /v "Enable" /t "REG_DWORD" /d 0 /f | Out-Null
reg add "HKLM\Software\Policies\Microsoft\Windows\HotspotAuthentication" /v "Enabled" /t "REG_DWORD" /d 0 /f | Out-Null
reg add "HKLM\System\CurrentControlSet\Control\Network" /v "NewNetworkWindowOff" /f | Out-Null
reg add "HKLM\Software\Microsoft\wcmsvc\wifinetworkmanager\config" /v "AutoConnectAllowedOEM" /t "REG_DWORD" /d 0 /f | Out-Null
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WwanSvc\CellularDataAccess" /v "LetAppsAccessCellularData" /t "REG_DWORD" /d 2 /f | Out-Null
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WDI\{3af8b24a-c441-4fa4-8c5c-bed591bfa867}" /v "ScenarioExecutionEnabled" /t "REG_DWORD" /d 0 /f | Out-Null
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WDI\{2698178D-FDAD-40AE-9D3C-1371703ADC5B}" /v "ScenarioExecutionEnabled" /t "REG_DWORD" /d 0 /f | Out-Null
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WDI\{ffc42108-4920-4acf-a4fc-8abdcc68ada4}" /v "ScenarioExecutionEnabled" /t "REG_DWORD" /d 0 /f | Out-Null
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WDI\{186f47ef-626c-4670-800a-4a30756babad}" /v "ScenarioExecutionEnabled" /t "REG_DWORD" /d 0 /f | Out-Null
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WDI\{eb73b633-3f4e-4ba0-8f60-8f3c6f53168f}" /v "ScenarioExecutionEnabled" /t "REG_DWORD" /d 0 /f | Out-Null
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WDI\{86432a0b-3c7d-4ddf-a89c-172faa90485d}" /v "ScenarioExecutionEnabled" /t "REG_DWORD" /d 0 /f | Out-Null
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WDI\{67144949-5132-4859-8036-a737b43825d8}" /v "ScenarioExecutionEnabled" /t "REG_DWORD" /d 0 /f | Out-Null
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\ScheduledDiagnostics" /v "EnabledExecution" /t "REG_DWORD" /d 0 /f | Out-Null
#END#Register changes

#START#Register deletes
reg delete "HKLM\SOFTWARE\Microsoft\Active Setup\Installed Components\{89820200-ECBD-11cf-8B85-00AA005B4340}" /f | Out-Null
reg delete "HKLM\SOFTWARE\Microsoft\Active Setup\Installed Components\{89820200-ECBD-11cf-8B85-00AA005B4383}" /f | Out-Null
reg delete "HKLM\Software\Policies\Microsoft\Windows\CloudContent\DisableWindowsConsumerFeatures" /f | Out-Null
reg delete "HKLM\Software\Policies\Microsoft\WindowsStore\AutoDownload" /f | Out-Null
reg delete "HKLM\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Run\Teams" /f | Out-Null
#VMware OSOT waardes vanaf hieronder
reg delete "HKLM\SOFTWARE\Microsoft\Active Setup\Installed Components\{89B4C1CD-B018-4511-B0A1-5476DBF70820}\StubPath" /f | Out-Null
reg delete "HKLM\SOFTWARE\Microsoft\Active Setup\Installed Components\{6BF52A52-394A-11d3-B153-00C04F79FAA6}\StubPath" /f | Out-Null
reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\WDI\{ffc42108-4920-4acf-a4fc-8abdcc68ada4}\EnabledScenarioExecutionLevel" /f | Out-Null
reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\WDI\{67144949-5132-4859-8036-a737b43825d8}\EnabledScenarioExecutionLevel" /f | Out-Null
#END#Register deletes
    
#START#Set Chrome/Edge settings
reg add "HKLM\SOFTWARE\Policies\Google\Chrome" /v "PromotionalTabsEnabled" /t "REG_DWORD" /d 0 /f | Out-Null
reg add "HKLM\Software\Policies\Microsoft\Edge" /v "BackgroundModeEnabled" /t "REG_DWORD" /d 0 /f | Out-Null
reg add "HKLM\Software\Policies\Google\Chrome" /v "HardwareAccelerationModeEnabled" /t "REG_DWORD" /d 0 /f | Out-Null
reg add "HKLM\Software\Policies\Microsoft\Edge" /v "HardwareAccelerationModeEnabled" /t "REG_DWORD" /d 0 /f | Out-Null
reg add "HKLM\Software\Policies\Google\Chrome" /v "BackgroundModeEnabled" /t "REG_DWORD" /d 0 /f | Out-Null
reg add "HKLM\Software\Policies\Google\Chrome" /v "TotalMemoryLimitMb" /t "REG_DWORD" /d 1024 /f | Out-Null
reg add "HKLM\Software\Policies\Microsoft\Edge" /v "TotalMemoryLimitMb" /t "REG_DWORD" /d 1024 /f | Out-Null
reg add "HKLM\Software\Policies\Google\Chrome" /v "HighEfficiencyModeEnabled" /t "REG_DWORD" /d 1 /f | Out-Null
reg add "HKLM\Software\Policies\Microsoft\Edge" /v "HighEfficiencyModeEnabled" /t "REG_DWORD" /d 1 /f | Out-Null
Get-ScheduledTask -TaskName "GoogleUpdateTaskMachine*" | Unregister-ScheduledTask -Confirm:$false -ErrorAction "SilentlyContinue"
Get-ScheduledTask -TaskName "MicrosoftEdgeUpdateTaskMachine*" | Unregister-ScheduledTask -Confirm:$false -ErrorAction "SilentlyContinue"
Get-Service -Name "MicrosoftEdgeElevationService" -ErrorAction "SilentlyContinue" | Set-Service -StartupType "Disabled" -ErrorAction "SilentlyContinue" | Out-Null
Get-Service -Name "GoogleChromeElevationService" -ErrorAction "SilentlyContinue" | Set-Service -StartupType "Disabled" -ErrorAction "SilentlyContinue" | Out-Null
Get-Service -Name "gupdate*" -ErrorAction "SilentlyContinue" | Set-Service -StartupType "Disabled" -ErrorAction "SilentlyContinue" | Out-Null
Get-Service -Name "edgeupdate*" -ErrorAction "SilentlyContinue" | Set-Service -StartupType "Disabled" -ErrorAction "SilentlyContinue" | Out-Null
#END#Set Chrome/Edge settings

#START#Set OneDrive settings
Get-ScheduledTask -TaskName "OneDrive Standalone Update Task-*" | Unregister-ScheduledTask -Confirm:$false -ErrorAction "SilentlyContinue"
Get-ScheduledTask -TaskName "OneDrive Per-Machine Standalone Update Task*" | Unregister-ScheduledTask -Confirm:$false -ErrorAction "SilentlyContinue"
#END#Set OneDrive settings

#START#Set Adobe settings
reg add "HKLM\SOFTWARE\Adobe\Acrobat Reader\DC\Installer" /v "ENABLE_CHROMEEXT" /t "REG_DWORD" /d 0 /f | Out-Null
reg add "HKLM\SOFTWARE\WOW6432Node\Policies\Adobe\Acrobat Reader\DC\FeatureLockDown" /v "bBrowserIntegration" /t "REG_DWORD" /d 1 /f | Out-Null
reg add "HKLM\SOFTWARE\Policies\Adobe\Adobe Acrobat\DC\FeatureLockDown" /v "bUpdater" /d 0 /t "REG_DWORD" /f | Out-Null
reg add "HKLM\SOFTWARE\WOW6432Node\Adobe\Adobe ARM\Legacy\Reader\{AC76BA86-7AD7-1033-7B44-AC0F074E4100}" /v "Mode" /d 0 /t "REG_DWORD" /f | Out-Null
reg add "HKLM\SOFTWARE\Adobe\Adobe Acrobat\DC\Installer" /v "DisableMaintenance" /d 1 /t "REG_DWORD" /f | Out-Null
Get-ScheduledTask -TaskName "Adobe Acrobat Update Task*" | Unregister-ScheduledTask -Confirm:$false -ErrorAction "SilentlyContinue"
Get-Service -Name "AdobeARMservice" -ErrorAction "SilentlyContinue" | Set-Service -StartupType "Disabled" -ErrorAction "SilentlyContinue" | Out-Null
#END#Set Adobe settings

#START#Set FSLogix settings
reg add "HKLM\SOFTWARE\FSLogix\Apps" /v "CleanupInvalidSessions" /t "REG_DWORD" /d 0 /f | Out-Null
reg add "HKLM\SOFTWARE\FSLogix\Apps" /v "RoamRecycleBin" /t "REG_DWORD" /d 1 /f | Out-Null
#END#Set FSLogix settings

#START#Roles deactiveren
$CheckWSVersion = (Get-WmiObject -class Win32_OperatingSystem).Caption
if ($CheckWSVersion -like "*Windows 10 Enterprise*" ) {
    $W10Features = @{
        FeatureName   = "Printing-XPSServices-Features", "SMB1Protocol", "WorkFolders-Client", `
            "FaxServicesClientPackage", "WindowsMediaPlayer", "MicrosoftWindowsPowerShellV2Root", `
            "MicrosoftWindowsPowerShellV2"
        Online        = $true
        NoRestart     = $true
        WarningAction = "SilentlyContinue"
        ErrorAction   = "SilentlyContinue"
    }
    Disable-WindowsOptionalFeature @W10Features | Out-Null
}
if ($CheckWSVersion -like "*Windows 11 Enterprise*" ) {
    $W11Features = @{
        FeatureName   = "Printing-XPSServices-Features", "SMB1Protocol", "WorkFolders-Client", "MicrosoftWindowsPowerShellV2Root", "MicrosoftWindowsPowerShellV2"
        Online        = $true
        NoRestart     = $true
        WarningAction = "SilentlyContinue"
        ErrorAction   = "SilentlyContinue"
    }
    Disable-WindowsOptionalFeature @W11Features | Out-Null
}
#END#Roles deactiveren

#START#VDOT run
#$DefaultUWP = "Microsoft.BingNews","Microsoft.BingWeather","Microsoft.GamingApp","Microsoft.GetHelp","Microsoft.Getstarted","Microsoft.MicrosoftOfficeHub","Microsoft.Office.OneNote","Microsoft.MicrosoftSolitaireCollection","Microsoft.People","Microsoft.PowerAutomateDesktop","Microsoft.SkypeApp","Microsoft.WindowsAlarms","microsoft.windowscommunicationsapps","Microsoft.WindowsFeedbackHub","Microsoft.WindowsMaps","Microsoft.WindowsSoundRecorder","Microsoft.Xbox.TCUI","Microsoft.XboxGameOverlay","Microsoft.XboxGamingOverlay","Microsoft.XboxIdentityProvider","Microsoft.XboxSpeechToTextOverlay","Microsoft.YourPhone","Microsoft.ZuneMusic","Microsoft.ZuneVideo","Microsoft.XboxApp","Microsoft.MixedReality.Portal","Microsoft.Microsoft3DViewer","MicrosoftTeams"
#,"*Microsoft.StorePurchaseApp*","*Microsoft.549981C3F5F10*"
#$DefaultUWP = "*3dbuilder*","*bingfinance*","*bingnews*","*bingsports*","*soundrecorder*","*Microsoft.Communicationsapps*","* Microsoft.OutlookForWindows*","*king.com.CandyCrushSodaSaga*","*king.com.**","*ClearChannelRadioDigital.iHeartRadio*","*4DF9E0F8.Netflix*","*6Wunderkinder.Wunderlist*","*Drawboard.DrawboardPDF*","*2FE3CB00.PicsArt-PhotoStudio*","*D52A8D61.FarmVille2CountryEscape*","*TuneIn.TuneInRadio*","*GAMELOFTSA.Asphalt8Airborne*","*TheNewYorkTimes.NYTCrossword*","*DB6EA5DB.CyberLinkMediaSuiteEssentials*","*Facebook.Facebook*","*flaregamesGmbH.RoyalRevolt2*","*Playtika.CaesarsSlotsFreeCasino*","*A278AB0D.MarchofEmpires*","*KeeperSecurityInc.Keeper*","*ThumbmunkeysLtd.PhototasticCollage*","*XINGAG.XING*","*89006A2E.AutodeskSketchBook*","*D5EA27B7.Duolingo-LearnLanguagesforFree*","*46928bounde.EclipseManager*","*ActiproSoftwareLLC.562882FEEB491*","*HP.ePrint.HPePrint*","*Microsoft.BingFoodAndDrink*","*Microsoft.BingTravel*","*Microsoft.BingHealthAndFitness*","*Microsoft.WindowsReadingList*","AD2F1837.HPJumpStart","Microsoft.Microsoft3DViewer","Microsoft.Wallet","Microsoft.XboxGameOverlay","Microsoft.XboxIdentityProvider","Microsoft.XboxSpeechToTextOverlay","Microsoft.FreshPaint","Microsoft.Office.Sway","Microsoft.SkypeApp","Microsoft.Getstarted","Microsoft.XboxGamingOverlay","Microsoft.Xbox.TCUI","Microsoft.WindowsFeedbackHub","Microsoft.GetHelp","Microsoft.messaging","Microsoft.MixedReality.Portal","Microsoft.MicrosoftStickyNotes","Microsoft.OneConnect","Microsoft.MicrosoftSolitaireCollection*","Microsoft.GamingApp*","*Microsoft.MicrosoftOfficeHub*","*Microsoft.NetworkSpeedTest*","*Microsoft.News*","*Microsoft.Office.Lens*","*Microsoft.Office.OneNote*","*Microsoft.People*","*Microsoft.RemoteDesktop*","*Microsoft.WindowsMaps*","*Microsoft.WindowsSoundRecorder*","*Microsoft.XboxApp*","*MicrosoftTeams*","*Microsoft.YourPhone*","*Microsoft.XboxGamingOverlay_5.721.10202.0_neutral_~_8wekyb3d8bbwe*","*Microsoft.PowerAutomateDesktop*","*DevHome*"
$AutoLoggersRegkeys = "CloudExperienceHostOOBE", "CloudExperienceHostOOBE", "WiFiSession", "WiFiDriverIHVSession", "WDIContextLog", "NtfsLog", "ReadyBoot", "TileStore", "UBPM"
$ScheduledTasks = "*Compatibility*", "NotificationTask", "ScheduledDefrag", "*Work Folders Logon Synchronization*"
Disable-WindowsOptionalFeature -Online -FeatureName WindowsMediaPlayer -NoRestart | Out-Null
Get-WindowsPackage -Online -PackageName "*Windows-mediaplayer*" | ForEach-Object { 
    Remove-WindowsPackage -PackageName $_.PackageName -Online -ErrorAction SilentlyContinue -NoRestart | Out-Null
}
foreach ($AutoLoggersRegkey in $AutoLoggersRegkeys) {
    New-ItemProperty -Path ("{0}" -f "hklm:\SYSTEM\CurrentControlSet\Control\WMI\Autologger\$AutoLoggersRegkey") -Name "Start" -PropertyType "DWORD" -Value 0 -Force -ErrorAction Stop | Out-Null
    New-ItemProperty -Path ("{0}" -f "hklm:\SYSTEM\CurrentControlSet\Control\WMI\Autologger\$AutoLoggersRegkey") -Name "Enabled" -PropertyType "DWORD" -Value 0 -Force -ErrorAction Stop | Out-Null
}
#foreach ($UWPs in $DefaultUWP) {
##    Get-AppxProvisionedPackage -Online | Where-Object { $_.PackageName -like ("*{0}*" -f $UWPs) } | Remove-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue | Out-Null
#    Get-AppxPackage -AllUsers -Name ("*{0}*" -f $UWPs) | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue 
#    Get-AppxPackage -Name ("*{0}*" -f $UWPs) | Remove-AppxPackage -ErrorAction SilentlyContinue | Out-Null
#}
foreach ($ScheduledTask in $ScheduledTasks) {
    Get-ScheduledTask -TaskName $ScheduledTask | Disable-ScheduledTask | Out-Null
}
Get-Service -Name "defragsvc" -ErrorAction "SilentlyContinue" | Set-Service -StartupType "Automatic" -ErrorAction "SilentlyContinue" | Out-Null
Get-Service -Name "autotimesvc" -ErrorAction "SilentlyContinue" | Set-Service -StartupType "Disabled" -ErrorAction "SilentlyContinue" | Out-Null
Get-Service -Name "BcastDVRUserService" -ErrorAction "SilentlyContinue" | Set-Service -StartupType "Disabled" -ErrorAction "SilentlyContinue" | Out-Null
Get-Service -Name "DiagSvc" -ErrorAction "SilentlyContinue" | Set-Service -StartupType "Disabled" -ErrorAction "SilentlyContinue" | Out-Null
Get-Service -Name "DiagTrack" -ErrorAction "SilentlyContinue" | Set-Service -StartupType "Disabled" -ErrorAction "SilentlyContinue" | Out-Null
Get-Service -Name "MessagingService" -ErrorAction "SilentlyContinue" | Set-Service -StartupType "Disabled" -ErrorAction "SilentlyContinue" | Out-Null
Get-Service -Name "SmsRouter" -ErrorAction "SilentlyContinue" | Set-Service -StartupType "Disabled" -ErrorAction "SilentlyContinue" | Out-Null
Get-Service -Name "VSS" -ErrorAction "SilentlyContinue" | Set-Service -StartupType "Disabled" -ErrorAction "SilentlyContinue" | Out-Null
Get-Service -Name "WerSvc" -ErrorAction "SilentlyContinue" | Set-Service -StartupType "Disabled" -ErrorAction "SilentlyContinue" | Out-Null
Get-Service -Name "XblAuthManager" -ErrorAction "SilentlyContinue" | Set-Service -StartupType "Disabled" -ErrorAction "SilentlyContinue" | Out-Null
Get-Service -Name "XboxGipSvc" -ErrorAction "SilentlyContinue" | Set-Service -StartupType "Disabled" -ErrorAction "SilentlyContinue" | Out-Null
Get-Service -Name "XboxNetApiSvc" -ErrorAction "SilentlyContinue" | Set-Service -StartupType "Disabled" -ErrorAction "SilentlyContinue" | Out-Null
reg add "HKLM\System\CurrentControlSet\Services\LanmanWorkstation\Parameters" /v "DisableBandwidthThrottling" /t "REG_DWORD" /d 1 /f | Out-Null
reg add "HKLM\System\CurrentControlSet\Services\LanmanWorkstation\Parameters" /v "FileInfoCacheEntriesMax" /t "REG_DWORD" /d 1024 /f | Out-Null
reg add "HKLM\System\CurrentControlSet\Services\LanmanWorkstation\Parameters" /v "DirectoryCacheEntriesMax" /t "REG_DWORD" /d 1024 /f | Out-Null
reg add "HKLM\System\CurrentControlSet\Services\LanmanWorkstation\Parameters" /v "FileNotFoundCacheEntriesMax" /t "REG_DWORD" /d 1024 /f | Out-Null
reg add "HKLM\System\CurrentControlSet\Services\LanmanWorkstation\Parameters" /v "DormantFileLimit" /t "REG_DWORD" /d 256 /f | Out-Null
reg add "HKLM\Software\Policies\Microsoft\Edge" /v "HideFirstRunExperience" /t "REG_DWORD" /d 1 /f | Out-Null
reg add "HKLM\Software\Policies\Microsoft\Edge" /v "HideInternetExplorerRedirectUXForIncompatibleSitesEnabled" /t "REG_DWORD" /d 1 /f | Out-Null
reg add "HKLM\Software\Policies\Microsoft\Edge" /v "ShowRecommendationsEnabled" /t "REG_DWORD" /d 0 /f | Out-Null
reg add "HKLM\Software\Policies\Microsoft\Edge" /v "StartupBoostEnabled" /t "REG_DWORD" /d 1 /f | Out-Null
reg add "HKLM\Software\Policies\Microsoft\Edge" /v "BackgroundModeEnabled" /t "REG_DWORD" /d 1 /f | Out-Null
Get-ChildItem -Path c:\ -Include *.tmp, *.dmp, *.etl, *.evtx, thumbcache*.db, *.log -File -Recurse -Force -ErrorAction SilentlyContinue | Remove-Item -ErrorAction SilentlyContinue
#END#VDOT run

#START#SelfDefined run
Get-Service -Name "wuauserv" -ErrorAction "SilentlyContinue" | Set-Service -StartupType "Disabled" -ErrorAction "SilentlyContinue" | Out-Null
Get-Service -Name "spectrum" -ErrorAction "SilentlyContinue" | Set-Service -StartupType "Disabled" -ErrorAction "SilentlyContinue" | Out-Null
Get-Service -Name "WbioSrvc" -ErrorAction "SilentlyContinue" | Set-Service -StartupType "Disabled" -ErrorAction "SilentlyContinue" | Out-Null
Get-Service -Name "WFDSConMgrSvc" -ErrorAction "SilentlyContinue" | Set-Service -StartupType "Disabled" -ErrorAction "SilentlyContinue" | Out-Null
Get-Service -Name "PhoneSvc" -ErrorAction "SilentlyContinue" | Set-Service -StartupType "Disabled" -ErrorAction "SilentlyContinue" | Out-Null
Get-Service -Name "OneDrive Updater Service" -ErrorAction "SilentlyContinue" | Set-Service -StartupType "Disabled" -ErrorAction "SilentlyContinue" | Out-Null
Get-Service -Name "AssignedAccessManagerSvc" -ErrorAction "SilentlyContinue" | Set-Service -StartupType "Disabled" -ErrorAction "SilentlyContinue" | Out-Null
Get-Service -Name "WwanSvc" -ErrorAction "SilentlyContinue" | Set-Service -StartupType "Disabled" -ErrorAction "SilentlyContinue" | Out-Null
Get-Service -Name "WlanSvc" -ErrorAction "SilentlyContinue" | Set-Service -StartupType "Disabled" -ErrorAction "SilentlyContinue" | Out-Null
Get-Service -Name "WaaSMedicSvc" -ErrorAction "SilentlyContinue" | Set-Service -StartupType "Disabled" -ErrorAction "SilentlyContinue" | Out-Null
Get-Service -Name "MixedRealityOpenXRSvc" -ErrorAction "SilentlyContinue" | Set-Service -StartupType "Disabled" -ErrorAction "SilentlyContinue" | Out-Null
Get-Service -Name "wcncsvc" -ErrorAction "SilentlyContinue" | Set-Service -StartupType "Disabled" -ErrorAction "SilentlyContinue" | Out-Null
Get-Service -Name "VacSvc" -ErrorAction "SilentlyContinue" | Set-Service -StartupType "Disabled" -ErrorAction "SilentlyContinue" | Out-Null
Get-Service -Name "SharedRealitySvc" -ErrorAction "SilentlyContinue" | Set-Service -StartupType "Disabled" -ErrorAction "SilentlyContinue" | Out-Null
Get-Service -Name "RetailDemo" -ErrorAction "SilentlyContinue" | Set-Service -StartupType "Disabled" -ErrorAction "SilentlyContinue" | Out-Null
Get-Service -Name "Fax" -ErrorAction "SilentlyContinue" | Set-Service -StartupType "Disabled" -ErrorAction "SilentlyContinue" | Out-Null
Get-Service -Name "appreadiness" -ErrorAction "SilentlyContinue" | Set-Service -StartupType "Disabled" -ErrorAction "SilentlyContinue" | Out-Null
Get-AppXPackage -AllUsers | ForEach-Object { Add-AppxPackage -DisableDevelopmentMode -Register -ForceApplicationShutdown "$($_.InstallLocation)\AppXManifest.xml" }
#END#SelfDefined run

#START#End of script
#Clear-Host
#Write-Host -ForegroundColor Red "VAO is klaar, nu zijn er een paar belangrijke punten die gedaan moeten worden:`n(1)Controleer of alles functioneert.`n(2)Test met de klant."
#END#End of script