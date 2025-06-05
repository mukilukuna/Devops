# Script: Uninstall_Forticlient.ps1
# Purpose: Uninstall Forticlient
$ProductGUID = "{86A227AF-FF8F-474A-9B74-C9A5C29E83E0}"
Start-Process -FilePath "msiexec.exe" -ArgumentList "/x $ProductGUID /qn /norestart" -Wait -NoNewWindow
