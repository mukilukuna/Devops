Get-AppxPackage Microsoft.XboxApp | Remove-AppxPackage -ErrorAction Stop
Get-AppxPackage Microsoft.XboxGameOverlay | Remove-AppxPackage -ErrorAction Stop
Get-AppxPackage Microsoft.XboxIdentityProvider | Remove-AppxPackage -ErrorAction Stop
Get-AppxPackage Microsoft.XboxSpeechToTextOverlay | Remove-AppxPackage -ErrorAction Stop

Get-AppxPackage -Name *OutlookForWindows* | Remove-AppxPackage -ErrorAction Stop

Get-AppxPackage Microsoft.windowscommunicationsapps | Remove-AppxPackage -ErrorAction Stop

Get-AppxPackage -Name "MicrosoftTeams" -AllUsers | Remove-AppxPackage
Get-AppXProvisionedPackage -Online | Where {$_.DisplayName -eq "MicrosoftTeams"} | Remove-AppxProvisionedPackage -Online