Dim Shell, DesktopPath, LNK
Dim fso

Set Shell = CreateObject("WScript.Shell")
DesktopPath = Shell.SpecialFolders("Desktop")
Set fso = CreateObject("Scripting.FileSystemObject")
   
If (fso.FileExists("C:\Program Files (x86)\Microsoft Office\Office12\EXCEL.EXE")) Then

Set LNK = Shell.CreateShortcut(DesktopPath & "\Excel.lnk")
LNK.TargetPath = "C:\Program Files (x86)\Microsoft Office\Office12\EXCEL.EXE"
LNK.Save
Else

Set LNK = Shell.CreateShortcut(DesktopPath & "\Excel.lnk")
LNK.TargetPath = "C:\Program Files (x86)\Microsoft Office\Office15\EXCEL.EXE"
LNK.Save

End If
