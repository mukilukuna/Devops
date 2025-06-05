# Script: SCR_WINGET_CONFIG.ps1
# Purpose: SCR WINGET CONFIG
$RegistryPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AppInstaller"

New-Item $RegistryPath -Fo

New-ItemProperty $RegistryPath "EnableAppInstaller" -V 1 -Pr DWORD -Fo
New-ItemProperty $RegistryPath "EnableExperimentalFeatures" -V 1 -Pr DWORD -Fo
New-ItemProperty $RegistryPath "EnableLocalManifestFiles" -V 1 -Pr DWORD -Fo
New-ItemProperty $RegistryPath "SourceAutoUpdateInterval" -v "5" -pr DWORD -Fo