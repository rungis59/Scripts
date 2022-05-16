$SourceFileLocation = "%windir%\System32\logoff.exe"
$ShortcutLocation = "C:\Users\$env:USERNAME\Desktop\Ferme la session.lnk"
$WScriptShell = New-Object -ComObject WScript.Shell
$Shortcut = $WScriptShell.CreateShortcut($ShortcutLocation)
$Shortcut.TargetPath = $SourceFileLocation
$Shortcut.IconLocation = "shell32.dll,27"
$Shortcut.Save()