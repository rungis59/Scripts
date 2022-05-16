Sub ReplywithNote()

Dim olApp As Object
Dim olNS As Object
Dim Fldr As Object
Dim olMail As Outlook.MailItem
Dim i As Long
Dim myDestFolder As Outlook.Folder

Set olApp = CreateObject("Outlook.Application")
Set olNS = olApp.GetNamespace("MAPI")
Set Fldr = olNS.GetDefaultFolder(olFolderInbox)
Set myDestFolder = Fldr.Folders("Accenture")
i = 1

For Each olMail In Fldr.Items
    If InStr(olMail.Subject, "Lettre de mise en cause valorisée") <> 0 Then
    With olMail.ReplyAll
            .Subject = olMail.Subject
            .BodyFormat = olFormatHTML
            .HTMLBody = "Bonjour, nous vous validons le devis " & olMail.Subject & vbCr & olMail.HTMLBody
            .Display '~~> change to .Send if it is already ok
    End With
    
    olMail.Move myDestFolder
    
i = i + 1
End If
Next olMail
End Sub