# Set $acceptEula to $true to accepp the eula:
# Eula for Webview2: https://developer.microsoft.com/en-us/microsoft-edge/webview2/#download-section

$acceptEula = $true

if ($acceptEula -eq $false) {
    throw "Accept the EULA first"
}
$script:URILatestTeamsWebRTC = $InheritedVars.TeamsWebRTCURI #"https://aka.ms/msrdcwebrtcsvc/msi"
$script:TeamsBootstrapper = $InheritedVars.TeamsMSIBootstrapper #"https://go.microsoft.com/fwlink/?linkid=2243204"
$script:URILatestWebview2 = $InheritedVars.WebView2URI #"https://go.microsoft.com/fwlink/p/?LinkId=2124703"
$script:URINewTeamsIcon = $InheritedVars.NewTeamsIconURI #"https://stvennerdio.blob.core.windows.net/algemeen/new_teams_icon.ico"

#clean old files
$files = "$($env:temp)\WebView2.exe", "$($env:temp)\TeamsBootstrapper.exe", "$($env:temp)\TeamsWebRTC.msi", "C:\service\new_teams_icon.png", "c:\users\public\desktop\Microsoft Teams.lnk"
foreach ($file in $files) {
    if (Test-Path $file) { Remove-Item -path $file -force }
}

# Set IsWVDEnvironment to 1
New-Item -Path "HKLM:\SOFTWARE\Microsoft" -Name "Teams" -Force -ErrorAction Ignore
New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Teams" -Name "IsWVDEnvironment" -Value 1 -force

# Set ShareClientDesktop to 1
New-Item -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\AddIns\WebRTC Redirector\Policy" -Force
New-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\AddIns\WebRTC Redirector\Policy" -name ShareClientDesktop -PropertyType DWORD -Value 1 -Force

# Allow side-loading for trusted apps
New-Item -Path "HKLM:\Software\Policies\Microsoft\Windows" -Name "Appx" -Force -ErrorAction Ignore
New-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Windows\Appx" -Name "AllowAllTrustedApps" -Value 1 -force
New-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Windows\Appx" -Name "AllowDevelopmentWithoutDevLicense" -Value 1 -force

# Download and install WebView2
(New-Object System.Net.WebClient).DownloadFile("$URILatestWebview2", "$($env:temp)\WebView2.exe")
Start-Process -FilePath "$($env:temp)\WebView2.exe" -Wait -ArgumentList "/silent /install" -ErrorAction SilentlyContinue

# Download and install the New Teams
(New-Object System.Net.WebClient).DownloadFile("$TeamsBootstrapper", "$($env:temp)\TeamsBootstrapper.exe")
$rv = Start-Process -FilePath "$($env:temp)\TeamsBootstrapper.exe" -Wait -ArgumentList "-p" -PassThru -ErrorAction SilentlyContinue
$rv.ExitCode

# Download and install WebRTC
(New-Object System.Net.WebClient).DownloadFile("$URILatestTeamsWebRTC", "$($env:temp)\TeamsWebRTC.msi")
$rv = Start-Process "msiexec.exe" -ArgumentList "/i $($env:temp)\TeamsWebRTC.msi /qn" -Wait -PassThru 
$rv.ExitCode

# Create new teams shortcut on desktop
(New-Object System.Net.WebClient).DownloadFile("$URINewTeamsIcon", "C:\service\new_teams_icon.ico")
$WshShell = New-Object -COMObject WScript.Shell
$Shortcut = $WshShell.CreateShortcut("c:\users\public\desktop\Microsoft Teams.lnk")
$Shortcut.TargetPath = "ms-teams"
$Shortcut.IconLocation = "C:\service\new_teams_icon.ico"
$Shortcut.Save()