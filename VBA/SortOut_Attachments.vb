' Based on macro written by Michael Bauer, vboffice.net
' http://www.vboffice.net/en/developers/print-attachments-automatically
  
' use  Declare PtrSafe Function with 64-bit Outlook
Private Declare PtrSafe Function ShellExecute Lib "shell32.dll" Alias _
  "ShellExecuteA" (ByVal hwnd As Long, ByVal lpOperation As String, _
  ByVal lpFile As String, ByVal lpParameters As String, _
  ByVal lpDirectory As String, ByVal nShowCmd As Long) As Long
Sub SortOut_Attachments()
 Dim oMail As Outlook.MailItem
 Dim obj As Object
 'On Error Resume Next
  
For Each obj In ActiveExplorer.Selection
Set oMail = obj
  
  Dim colAtts As Outlook.Attachments
  Dim oAtt As Outlook.Attachment
  Dim sFile As String
  Dim sDirectory As String
  Dim sFileType As String
  
  sDirectory = "C:\print\"
  
  Set colAtts = oMail.Attachments
  
  If colAtts.Count Then
    For Each oAtt In colAtts
  
      sFileType = LCase$(Mid$(oAtt.FileName, 9, 3))
  
      Select Case sFileType
  
      Case "dro", "pv_"
  
        sFile = sDirectory & oAtt.FileName
        oAtt.SaveAsFile sFile
        ShellExecute 0, "print", sFile, vbNullString, vbNullString, 0
      End Select
    Next
  End If
   
Next
End Sub