# Script: Uninstall_Dropbox.ps1
# Purpose: Uninstall Dropbox
$dropboxUninstallerPath = "${env:ProgramFiles(x86)}\Dropbox\Client\DropboxUninstaller.exe"
$arguments = "/S"

Start-Process -FilePath $dropboxUninstallerPath -ArgumentList $arguments -WindowStyle Hidden -Wait
