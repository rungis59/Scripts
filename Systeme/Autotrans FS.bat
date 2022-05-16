if not exist "%userprofile%\Desktop\DFR.lnk" xcopy "\\aut-srv-dc1\dfr\FO_prod\DFR.lnk" "%userprofile%\Desktop\" /Y

if not exist "%userprofile%\Desktop\Excel.lnk" C:\Windows\System32\cscript.exe \\192.168.8.215\commun\shortcut.vbs

if not exist "%userprofile%\Desktop\Word.lnk" C:\Windows\System32\cscript.exe \\192.168.8.215\commun\shortcut2.vbs

if not exist "%userprofile%\Desktop\OIS.lnk" C:\Windows\System32\cscript.exe \\192.168.8.215\commun\shortcut4.vbs

if not exist "%userprofile%\Desktop\OUTLOOK.lnk" C:\Windows\System32\cscript.exe \\192.168.8.215\commun\shortcut5.vbs

if not exist "%userprofile%\Desktop\Powerpoint.lnk" C:\Windows\System32\cscript.exe \\192.168.8.215\commun\shortcut3.vbs