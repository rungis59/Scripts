$Language = (Get-WinUserLanguageList)[0].LanguageTag
if ($Language -ne "fr-FR")
{Set-WinUILanguageOverride -Language fr-FR}