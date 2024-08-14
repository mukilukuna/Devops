$appPackages = @(
    "Microsoft.WindowsCamera_2024.2404.4.0_x64__8wekyb3d8bbwe",
    "Microsoft.Getstarted_10.2312.1.0_x64__8wekyb3d8bbwe",
    "Microsoft.Xbox.TCUI_1.24.10001.0_x64__8wekyb3d8bbwe",
    "Microsoft.BingNews_4.55.62231.0_x64__8wekyb3d8bbwe",
    "Microsoft.XboxGameOverlay_1.54.4001.0_x64__8wekyb3d8bbwe",
    "Microsoft.XboxIdentityProvider_12.95.3001.0_x64__8wekyb3d8bbwe",
    "Microsoft.XboxSpeechToTextOverlay_1.21.13002.0_x64__8wekyb3d8bbwe",
    "Microsoft.ZuneVideo_10.22091.10061.0_x64__8wekyb3d8bbwe",
    "Microsoft.OutlookForWindows_1.2024.223.300_x64__8wekyb3d8bbwe",
    "Microsoft.People_10.2202.100.0_x64__8wekyb3d8bbwe",
    "Microsoft.XboxGamingOverlay_7.124.3191.0_x64__8wekyb3d8bbwe",
    "Microsoft.LanguageExperiencePacknl-NL_22621.60.224.0_neutral__8wekyb3d8bbwe",
    "Microsoft.ZuneMusic_11.2403.5.0_x64__8wekyb3d8bbwe",
    "Microsoft.MicrosoftSolitaireCollection_4.19.5100.0_x64__8wekyb3d8bbwe",
    "Microsoft.Winget.Source_2024.526.1811.716_neutral__8wekyb3d8bbwe",
    "Microsoft.MicrosoftOfficeHub_18.2405.1221.0_x64__8wekyb3d8bbwe",
    "Microsoft.GamingApp_2405.1001.6.0_x64__8wekyb3d8bbwe",
    "microsoft.windowscommunicationsapps_16005.14326.21904.0_x64__8wekyb3d8bbwe",
    "Microsoft.WindowsFeedbackHub_1.2405.21311.0_x64__8wekyb3d8bbwe",
    "Microsoft.GetHelp_10.2403.20861.0_x64__8wekyb3d8bbwe"
)

foreach ($package in $appPackages) {
    Remove-AppxPackage -Package $package
    Remove-AppxPackage -AllUsers -Package $package
    Remove-AppxProvisionedPackage -Online -PackageName $package
}