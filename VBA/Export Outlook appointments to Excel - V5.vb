Private Sub Shortcut(objOwner2 As String, strFlt As String, Column As String)
    Const SCRIPT_NAME = "Export Appointments to Excel"
    Const DAYS = -30
    Dim olApp As Object
    Dim olNS As Object
    Dim olFolder As Object
    Dim olApt As Object
    Dim FromDate As Date
    Dim ToDate As Date
    Dim objOwner
    Dim olkRes As Object
    Dim olkLst As Object
    Dim lngLastRow As Long
    Dim strRowNoList As String
    Dim StartingDate As Date
    Dim foundCell As Range
    Dim DateRow As Long
    Dim EndingDate As Date
    Dim n As Integer
    
    'FromDate = CDate("01/08/2018")
    FromDate = VBA.Format(DateAdd("d", DAYS, Now), "dd/mm/yyyy")
    
    lngLastRow = Cells(Rows.Count, "A").End(xlUp).Row - 7
    ToDate = Range("A" & lngLastRow).Value
    
    Set foundCell = Range("A2:A" & lngLastRow).Find(What:=FromDate, LookAt:=xlWhole)
    If Not foundCell Is Nothing Then
    DateRow = foundCell.Row
    Else
    MsgBox "Date non trouvée dans la colonne A", vbCritical + vbOKOnly, SCRIPT_NAME
    Exit Sub
    End If
    
    On Error Resume Next
    Set olApp = GetObject(, "Outlook.Application")
    If Err.Number > 0 Then Set olApp = CreateObject("Outlook.Application")
    On Error GoTo 0
    
    Set olNS = olApp.GetNamespace("MAPI")
    Set objOwner = olNS.CreateRecipient(objOwner2)
    objOwner.Resolve
       
    If objOwner.Resolved Then
    Set olFolder = olNS.GetSharedDefaultFolder(objOwner, 9)
    End If
    
    Set olkLst = olFolder.Items
    'N'utilise pas InstantSearch
	Set olkRes = olkLst.Restrict("@SQL=" & Chr(34) & "urn:schemas:httpmail:subject" & Chr(34) & " like '%" & strFlt & "%'")
    
        For Each olApt In olkRes
        If (olApt.Start >= FromDate And olApt.Start < ToDate) Then
        StartingDate = Format(olApt.Start, "dd/mm/yyyy")
        
            If Format(olApt.End, "hh:mm") = "00:00" Then
            EndingDate = VBA.Format(DateAdd("d", -1, olApt.End), "dd/mm/yyyy")
            For Each cell In Range("A" & DateRow & ":A" & lngLastRow)
            
                    If cell.Value = StartingDate And EndingDate = StartingDate Then
                    strRowNoList = cell.Row
                    Range(Column & strRowNoList).Value = "V"
                        With Range(Column & strRowNoList).Interior
                    .Pattern = xlSolid
                    .PatternColorIndex = xlAutomatic
                    .Color = 65535
                    .TintAndShade = 0
                    .PatternTintAndShade = 0
                        End With
                        With Range(Column & strRowNoList)
                    .HorizontalAlignment = xlCenter
                    .VerticalAlignment = xlBottom
                    .WrapText = False
                    .Orientation = 0
                    .AddIndent = False
                    .IndentLevel = 0
                    .ShrinkToFit = False
                    .ReadingOrder = xlContext
                    .MergeCells = False
                        End With
             
                     ElseIf cell.Value = StartingDate And EndingDate <> StartingDate Then
                     strRowNoList = cell.Row
                     n = DateDiff("d", StartingDate, EndingDate)
                     Range(Column & strRowNoList & ":" & Column & strRowNoList + n).Value = "V"
                        With Range(Column & strRowNoList & ":" & Column & strRowNoList + n).Interior
                    .Pattern = xlSolid
                    .PatternColorIndex = xlAutomatic
                    .Color = 65535
                    .TintAndShade = 0
                    .PatternTintAndShade = 0
                        End With
                        With Range(Column & strRowNoList & ":" & Column & strRowNoList + n)
                    .HorizontalAlignment = xlCenter
                    .VerticalAlignment = xlBottom
                    .WrapText = False
                    .Orientation = 0
                    .AddIndent = False
                    .IndentLevel = 0
                    .ShrinkToFit = False
                    .ReadingOrder = xlContext
                    .MergeCells = False
                        End With
                    
                    End If
            
                Next cell
            
            Else
            
            EndingDate = Format(olApt.End, "dd/mm/yyyy")
                
                For Each cell In Range("A" & DateRow & ":A" & lngLastRow)
            
                    If cell.Value = StartingDate And EndingDate = StartingDate Then
                    strRowNoList = cell.Row
                    Range(Column & strRowNoList).Value = "V"
                         With Range(Column & strRowNoList).Interior
                    .Pattern = xlSolid
                    .PatternColorIndex = xlAutomatic
                    .Color = 65535
                    .TintAndShade = 0
                    .PatternTintAndShade = 0
                         End With
                         With Range(Column & strRowNoList)
                    .HorizontalAlignment = xlCenter
                    .VerticalAlignment = xlBottom
                    .WrapText = False
                    .Orientation = 0
                    .AddIndent = False
                    .IndentLevel = 0
                    .ShrinkToFit = False
                    .ReadingOrder = xlContext
                    .MergeCells = False
                         End With
             
                     ElseIf cell.Value = StartingDate And EndingDate <> StartingDate Then
                     strRowNoList = cell.Row
                     n = DateDiff("d", StartingDate, EndingDate)
                     Range(Column & strRowNoList & ":" & Column & strRowNoList + n).Value = "V"
                        With Range(Column & strRowNoList & ":" & Column & strRowNoList + n).Interior
                    .Pattern = xlSolid
                    .PatternColorIndex = xlAutomatic
                    .Color = 65535
                    .TintAndShade = 0
                    .PatternTintAndShade = 0
                        End With
                        With Range(Column & strRowNoList & ":" & Column & strRowNoList + n)
                    .HorizontalAlignment = xlCenter
                    .VerticalAlignment = xlBottom
                    .WrapText = False
                    .Orientation = 0
                    .AddIndent = False
                    .IndentLevel = 0
                    .ShrinkToFit = False
                    .ReadingOrder = xlContext
                    .MergeCells = False
                        End With
                    
                    End If
            
                Next cell
               
            
            End If
       
       End If
       
       Next olApt
    
End Sub
Sub ListAppointments_v5()
  
    'NEO
      
    Shortcut "Nouredine EL OUARDANI", "Congé", "E"
     
    Shortcut "Nouredine EL OUARDANI", "RTT", "E"
      
    Shortcut "Nouredine EL OUARDANI", "Ecole", "E"
    
    
    MsgBox "Traitement Terminé"
    
    Set olApt = Nothing
    Set olFolder = Nothing
    Set olNS = Nothing
    Set olApp = Nothing
    Set olkLst = Nothing
    Set olkRes = Nothing
    

End Sub
