# Script: RemoveAppxpackage.ps1
# Purpose: RemoveAppxpackage
$appPackages = @(
    "Microsoft.WindowsCamera",
    "Microsoft.Getstarted",
    "Microsoft.Xbox.TCUI",
    "Microsoft.BingNews",
    "Microsoft.XboxGameOverlay",
    "Microsoft.XboxIdentityProvider",
    "Microsoft.XboxSpeechToTextOverlay",
    "Microsoft.ZuneVideo",
    "Microsoft.OutlookForWindows",
    "Microsoft.People",
    "Microsoft.XboxGamingOverlay",
    "Microsoft.LanguageExperiencePacknl-NL",
    "Microsoft.ZuneMusic",
    "Microsoft.MicrosoftSolitaireCollection",
    "Microsoft.Winget.Source",
    "Microsoft.MicrosoftOfficeHub",
    "Microsoft.GamingApp",
    "microsoft.windowscommunicationsapps",
    "Microsoft.WindowsFeedbackHub",
    "Microsoft.GetHelp",
    "NotepadPlusPlus"
)

# Haal alle geïnstalleerde pakketten op
$installedPackages = Get-AppxPackage

foreach ($packageName in $appPackages) {
    foreach ($package in $installedPackages) {
        if ($package.Name -like "*$packageName*") {
            Remove-AppxPackage -Package $package.PackageFullName
            Remove-AppxProvisionedPackage -Online -PackageName $package.PackageFullName
        }
    }
}
