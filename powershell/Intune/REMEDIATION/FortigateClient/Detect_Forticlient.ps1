# Script: Detect_Forticlient.ps1
# Purpose: Detect Forticlient
if(Test-Path -Path "C:\Program Files\Fortinet\FortiClient\FortiClient.exe")
{
    if((get-item -Path "C:\Program Files\Fortinet\FortiClient\FortiClient.exe").VersionInfo.FileVersion -lt "7.0.8.0427")
    {
        Write-Output "Verouderd: applicatie moet verwijderd worden"
        exit 1
    }
    else {
        Write-Output "Goed: versie is nieuw"
        exit 0
        }
}
else
{
    Write-Output "Goed: Fortigate is niet geinstalleerd"
    exit 0
}