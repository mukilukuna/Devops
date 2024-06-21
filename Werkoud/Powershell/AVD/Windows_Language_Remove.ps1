$LangList = Get-WinUserLanguageList

$MarkedLang = $LangList | where LanguageTag -eq "en-US"

$LangList.Remove($MarkedLang)

Set-WinUserLanguageList $LangList -Force