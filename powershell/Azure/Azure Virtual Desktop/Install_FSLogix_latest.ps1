$URILatestFSLogix = $InheritedVars.FSLogixURI #"https://aka.ms/fslogix_download"
$LatestFSLogixTempDestZip = "c:\temp\FSLogix.zip"
$LatestFSLogixTempDest = "c:\temp\FSLogix"
$ProgressPreference = 'SilentlyContinue'

#check for temp or old files and create/remove if neccessary
if (!(Test-Path -path "c:\temp")){
    New-Item -ItemType Directory "c:\temp"
}elseif (Test-Path $LatestFSLogixTempDestZip, $LatestFSLogixTempDest) {
    try {
        Remove-Item -Path $LatestFSLogixTempDestZip -Force -Recurse -ErrorAction SilentlyContinue
        Remove-Item -Path $LatestFSLogixTempDest -Force -Recurse -ErrorAction SilentlyContinue
    }
    catch [System.Management.Automation.ItemNotFoundException] {
        "Item does not exist"
    }
}
#get currect version
$version = Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* |  Where-Object {$_.DisplayName -like "*fslogix*"}   | Select-Object -ExpandProperty DisplayVersion; 
write-host "currently installed FSLogixVersion:"
$version

#download and install FSLogix
Invoke-WebRequest -Uri $URILatestFSLogix -OutFile $LatestFSLogixTempDestZip
Expand-Archive $LatestFSLogixTempDestZip -DestinationPath $LatestFSLogixTempDest
Start-Process -FilePath "$LatestFSLogixTempDest\x64\Release\FSLogixAppsSetup.exe" -ArgumentList "/install /quiet /norestart /log C:\temp\FSLogixLog.txt"

#clean resources
Start-Sleep -Seconds 30
try {
    Remove-Item -Path $LatestFSLogixTempDestZip -Force -Recurse -ErrorAction SilentlyContinue
    Remove-Item -Path $LatestFSLogixTempDest -Force -Recurse -ErrorAction SilentlyContinue
}
catch [System.Management.Automation.ItemNotFoundException] {
    "Item does not exist"
}

#output new version, does not seem to work without reboot
#$version = Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* |  Where-Object {$_.DisplayName -like "*fslogix*"}   | Select-Object -ExpandProperty DisplayVersion; 
#write-host "installed FSLogixVersion:"
#$version