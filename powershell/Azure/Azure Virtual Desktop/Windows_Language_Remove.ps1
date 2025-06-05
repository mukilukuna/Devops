# Script: Windows_Language_Remove.ps1
# Purpose: Windows Language Remove
$LangList = Get-WinUserLanguageList

$MarkedLang = $LangList | where LanguageTag -eq "en-US"

$LangList.Remove($MarkedLang)

Set-WinUserLanguageList $LangList -Force