# Script: Remove_7-zipv2.ps1
# Purpose: Remove 7 zipv2
Start-Process "C:\Windows\System32\msiexec.exe" `
-ArgumentList "/i {23170F69-40C1-2702-2201-000001000000} /quiet /noreboot" -Wait


Get-ChildItem -Path "HKLM:SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall" -Recurse |   
Where-Object {
    $_.GetValue("DisplayName") -like "7-zip*" -and 
    ([version]($_.GetValue("DisplayVersion")) -lt [version]"23.0")
} |   
ForEach-Object {  
    $dn = $_.GetValue("DisplayName")  
    $uninstallGUID = "{" + $_.GetValue("UninstallString").Split("{")[-1]  
    Start-Process -FilePath "msiexec.exe" -ArgumentList  "/X", $uninstallGUID, "/qn"  
}
