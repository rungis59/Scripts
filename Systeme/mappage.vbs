' ########################################################################
'  Written in VBScript.
'  Establishes map drives.
'  Assign to OU Group Policy under USER CONFIG, WINDOWS SETTINGS, SCRIPTS, LOGON SCRIPT.
'
'  This script will: 
'  (1) check if the drive is already connected and, if so, disconnect it.
'  (2) map the drive.
'
'  Arguments are as follows: 
'	 MAPIT  DRIVE-LETTER as string,  PATH as string, USER as string, PASSWORD as string
'	 (1) Do not specify colon in drive letter.
'	 (2) Do not end path with a forward slash.
'	 (3) If user and password are not required to establish map, then specify a zero-length string as follows:  ""
'
' Reference Microsoft info at:
' http://msdn.microsoft.com/library/default.asp?url=/library/en-us/script56/html/wsmthmapnetworkdrive.asp
' ########################################################################

' Create the Shell or environment for the commands:
Set WshShell = WScript.CreateObject("WScript.Shell")
' Define objects:
Set WshNetwork = WScript.CreateObject("WScript.Network")
Set oDrives = WshNetwork.EnumNetworkDrives()

' ====================================
' DEFINE WHO TO CONTACT for pop-up messages:
' ====================================
strContactMessage = "If you require assistance, please contact IT Support."

' ==================
' DEFINE DRIVES TO MAP:
' ==================
Mapit "m", "\\192.168.8.215\user\%username%", "", ""
Mapit "n", "\\192.168.8.215\logistique$", "", ""

' ========
' CLEAN UP:
' ========
Set WshShell = Nothing
Set WshNetwork = Nothing
Set oDrives = Nothing

' ##################################
' DO NOT MODIFY ANYTHING BELOW THIS POINT...
'   unless you are familiar with the proper settings.
' ##################################
Sub Mapit(strLetter, strPath, strUser, strPass)

	' Define the DriveLetter:
	DriveLetter = strLetter & ":"

	' Define the remote path:
	RemotePath = strPath

	' Pop-up Notices (set to False to disable notices, otherwise set to True):
	bPopReminder = True

	' Define known errors to trap:
	Dim arrErrCode(1)
	Dim arrErrDesc(1)
	arrErrCode(0) = -2147023694
	arrErrCode(1) = -2147024811
	arrErrDesc(0) = "Unable to map drive " & DriveLetter & " to " & RemotePath _
		& " due to a previously defined remembered map with the same letter." _
		& vbCrLf & vbCrLf & "Please MANUALLY disconnect map drive " & DriveLetter _
		& ", then Log Out and Log back in."
	arrErrDesc(1) = "Unable to map drive " & DriveLetter & " to " & RemotePath _
		& " since " & DriveLetter & ": was previously reserved by your computer." _
		& vbCrLf & vbCrLf & "(Refer to Management, Shared Folders, Shares)"

	' Define whether the map information should be removed from the current user's profile:
	bForceRemoveFromProfile = True
	bRemoveFromProfile = True

	' Define whether the map information should be stored in the current user's profile:
	bStoreInProfile = False

	' Check if already connected:
	AlreadyConnected = False
	For i = 0 To oDrives.Count - 1 Step 2
		If LCase(oDrives.Item(i)) = LCase(DriveLetter) Then AlreadyConnected = True
	Next

	' Attempt to map the drive.  If already mapped, first attempt disconnect:
	If AlreadyConnected = True then
		WshNetwork.RemoveNetworkDrive DriveLetter, bForceRemoveFromProfile, bRemoveFromProfile
		If Not strUser = "" Then
			WshNetwork.MapNetworkDrive DriveLetter, RemotePath, bStoreInProfile, strUser, strPass
		Else
			WshNetwork.MapNetworkDrive DriveLetter, RemotePath, bStoreInProfile
		End If
'		If bPopReminder Then WshShell.PopUp "Drive " & DriveLetter & " disconnected, then connected successfully to " & RemotePath
	Else
		On Error Resume Next
		If Not strUser = "" Then
			WshNetwork.MapNetworkDrive DriveLetter, RemotePath, bStoreInProfile, strUser, strPass 
		Else
			WshNetwork.MapNetworkDrive DriveLetter, RemotePath, bStoreInProfile
		End If
		If Err.Number <> 0 Then
			bKnownError = False
			For I = LBound(arrErrCode) To UBound(arrErrCode)
				If Err.Number = arrErrCode(I) Then
					bKnownError = True
					strPopMessage = arrErrDesc(I)
					' Display the Disconnect Network Drives window:
					If Err.Number = arrErrCode(0) Then
						Set objWSH = Wscript.CreateObject("WScript.Shell")
						objWSH.Run "rundll32.exe shell32.dll,SHHelpShortcuts_RunDLL Disconnect", 1, true
					End If
					Exit For
				End If
			Next
			If Not bKnownError Then
				strPopMessage = "Unable to map drive " & DriveLetter & " to " & RemotePath _
					& " due to reason stated below."
			End If
			' Display warning message:
			strPopMessage = "WARNING!!   WARNING!!   WARNING!!   WARNING!!" _
				& vbCrLf & vbCrLf & strPopMessage _
				& vbCrLf & vbCrLf & Err.Description & " (error " & Err.Number & ")" _
				& vbCrLf & vbCrLf & strContactMessage
			WshShell.PopUp strPopMessage
		Else
'			If bPopReminder Then WshShell.PopUp "Drive " & DriveLetter & " connected successfully to " & RemotePath
		End If
	End If

' ====================================
' Rename those mapped drive.
' Why have "Share1 on server1" when you can have "Share 1"
' ====================================

mDrive = "M:\"
Set oShell = CreateObject("Shell.Application")
oShell.NameSpace(mDrive).Self.Name = "User"

mDrive = "N:\"
Set oShell = CreateObject("Shell.Application")
oShell.NameSpace(mDrive).Self.Name = "Logistique"

	' Release resources:
	Set objWSH = Nothing

	' Slight pause to ensure each pass has time to commit:
	wscript.sleep 200
End Sub