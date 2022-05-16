' Based on macro written by Michael Bauer, vboffice.net
' http://www.vboffice.net/en/developers/print-attachments-automatically
  
' use  Declare PtrSafe Function with 64-bit Outlook
Private Declare PtrSafe Function ShellExecute Lib "shell32.dll" Alias _
  "ShellExecuteA" (ByVal hwnd As Long, ByVal lpOperation As String, _
  ByVal lpFile As String, ByVal lpParameters As String, _
  ByVal lpDirectory As String, ByVal nShowCmd As Long) As Long
Sub PrintAttachmentsSelectedMsg()
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
  
  sDirectory = "D:\print\"
  
  Set colAtts = oMail.Attachments
  
  If colAtts.Count Then
    For Each oAtt In colAtts
  
' This code looks at the last 4 characters in a filename
      sFileType = LCase$(Right$(oAtt.FileName, 4))
  
      Select Case sFileType
  
' Add additional file types below
      Case ".xls", ".doc", "docx", ".pdf"
  
        sFile = sDirectory & oAtt.FileName
        oAtt.SaveAsFile sFile
        ShellExecute 0, "print", sFile, vbNullString, vbNullString, 0
      End Select
    Next
  End If
   
Next
End Sub

