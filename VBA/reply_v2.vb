Sub ReplywithNote_v2()

Dim olApp As Object
Dim olNS As Object
Dim Fldr As Object
Dim olMail As Outlook.MailItem
Dim i As Long
Dim subfolder As Outlook.Folder
Dim subfolder2 As Outlook.Folder
Dim DestSubfolder1 As Outlook.Folder
Dim DestSubfolder2 As Outlook.Folder

Set olApp = CreateObject("Outlook.Application")
Set olNS = olApp.GetNamespace("MAPI")
Set Fldr = olNS.GetDefaultFolder(olFolderInbox)
Set subfolder = Fldr.folders("CAT Accenture")
Set subfolder2 = subfolder.folders("0 - A valider")
Set DestSubfolder1 = subfolder.folders("2 - DEVIS VALIDES")
Set DestSubfolder2 = DestSubfolder1.folders("1 - CAT")
i = 1

For Each olMail In subfolder2.Items
    If InStr(olMail.Subject, "Lettre de mise en cause valorisée") <> 0 Then
    With olMail.ReplyAll
            .Subject = olMail.Subject
            .BodyFormat = olFormatHTML
            .HTMLBody = "Bonjour, nous vous validons le devis " & olMail.Subject & vbCr & olMail.HTMLBody
            .Display '~~> change to .Send if it is already ok
    End With
    
    olMail.Move DestSubfolder2
    
i = i + 1
End If
Next olMail
End Sub