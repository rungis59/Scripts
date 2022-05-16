Option Explicit 

'Set Dimension
 DIM fso 

'Set Object
 Set fso = CreateObject("Scripting.FileSystemObject") 

'Create Condition
 If (fso.FileExists("C:\Temp\test.txt")) Then
 'Alert User
 WScript.Echo("File exists!")
 WScript.Quit()
 Else
 'Alert User
 WScript.Echo("File does not exist!")
 End If 

'Exit Script
 WScript.Quit()
