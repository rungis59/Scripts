Option Explicit

On Error Resume Next

ExcelMacroExample

Sub ExcelMacroExample() 

  Dim xlApp 
  Dim xlBook 

  Set xlApp = CreateObject("Excel.Application") 
  xlApp.DisplayAlerts = False
  Set xlBook = xlApp.Workbooks.Open("S:\\Stocks\\script\\MACRO.xlsm", 0, True) 
  xlApp.Run "Macro6"
  xlApp.DisplayAlerts = True
  xlApp.Quit 

  Set xlBook = Nothing 
  Set xlApp = Nothing 

End Sub