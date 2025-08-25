# PowerShell script to replace content in the hosts file

# Run this script as an Administrator

# Step 1: Define the path of the hosts file
$hostsPath = "C:\Windows\System32\drivers\etc\hosts"

# Step 2: Backup the current hosts file
$backupPath = "$hostsPath.bak"
Copy-Item -Path $hostsPath -Destination $backupPath -Force
Write-Host "Backup of the current hosts file created at $backupPath"

# Step 3: Define the new content for the hosts file
$newContent = @"
10.202.10.4   vereuazusto.privatelink.file.core.windows.net
"@

# Step 4: Replace the content of the hosts file
Set-Content -Path $hostsPath -Value $newContent -Force