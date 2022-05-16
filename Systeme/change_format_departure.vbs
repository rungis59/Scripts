Option Explicit

On Error Resume Next

  Dim xlApp 
  Dim xlBook 
  Dim fso
  
  Set fso = CreateObject("Scripting.FileSystemObject")
  If (fso.FileExists("S:\MAIL\Departure_list\PJ\tosz136002_dacia_renault_departure_autotrans_yesterday.xls")) Then
  Set xlApp = CreateObject("Excel.Application") 
  xlApp.DisplayAlerts = False
  Set xlBook = xlApp.Workbooks.Open("S:\\Stocks\\script\\MACRO.xlsm", 0, True) 
  xlApp.Run "Macro2"
  xlApp.DisplayAlerts = True
  xlApp.Quit 

  Set xlBook = Nothing 
  Set xlApp = Nothing
Else

End If

Set fso = CreateObject("Scripting.FileSystemObject")
  If (fso.FileExists("S:\MAIL\Departure_list\PJ\tosz136003_dacia_renault_departure_autotrans_today.xls")) Then
  Set xlApp = CreateObject("Excel.Application") 
  xlApp.DisplayAlerts = False
  Set xlBook = xlApp.Workbooks.Open("S:\\Stocks\\script\\MACRO.xlsm", 0, True) 
  xlApp.Run "Macro3"
  xlApp.DisplayAlerts = True
  xlApp.Quit 

  Set xlBook = Nothing 
  Set xlApp = Nothing
Else

End If

WScript.Quit()
  