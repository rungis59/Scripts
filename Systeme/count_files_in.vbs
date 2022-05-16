Option Explicit 
 'On Error Resume Next 
  
 Dim objFSO, strTopFolder, intFileCount, countglobal, intFileCount2, intFileCount3 , intFileCount4 , intFileCount5 , intFileCount6 , intFileCount7 , intFileCount8 , intFileCount9
 
  
 strTopFolder = "\\192.168.8.214\EDI$\PTD\GVH\PROD\SAVE\IN\HR01\2016"
 
 Set objFSO = CreateObject("Scripting.FileSystemObject") 
  
 CountFiles(strTopFolder) 

 Sub CountFiles(strFolder) 
 '     On Error Resume Next 
     
    Dim objFolder, objFiles, subfolder 
     
    Set objFolder = objFSO.GetFolder(strFolder)  
    Set objFiles = objFolder.Files  
    intFileCount = intFileCount + objFiles.Count
     
    For Each subfolder In objFolder.SubFolders
        CountFiles(subfolder.Path) 
    Next 
 End Sub 
 
 Set objFSO = Nothing  
 Set strTopFolder = Nothing 
 

 
  
 strTopFolder = "\\192.168.8.214\EDI$\PTD\GVH\PROD\SAVE\IN\RD00\2016"
 
 Set objFSO = CreateObject("Scripting.FileSystemObject") 
  
 CountFiles(strTopFolder) 

 Sub CountFiles(strFolder) 
 '     On Error Resume Next 
     
    Dim objFolder, objFiles, subfolder 
     
    Set objFolder = objFSO.GetFolder(strFolder)  
    Set objFiles = objFolder.Files  
    intFileCount2 = intFileCount2 + objFiles.Count
     
    For Each subfolder In objFolder.SubFolders
        CountFiles(subfolder.Path) 
    Next 
 End Sub 
  Set objFSO = Nothing  
 Set strTopFolder = Nothing 
 
 

  
 strTopFolder = "\\192.168.8.214\EDI$\PTD\GVH\PROD\SAVE\IN\RD01\2016"
 
 Set objFSO = CreateObject("Scripting.FileSystemObject") 
  
 CountFiles(strTopFolder) 

 Sub CountFiles(strFolder) 
 '     On Error Resume Next 
     
    Dim objFolder, objFiles, subfolder 
     
    Set objFolder = objFSO.GetFolder(strFolder)  
    Set objFiles = objFolder.Files  
    intFileCount3 = intFileCount3 + objFiles.Count
     
    For Each subfolder In objFolder.SubFolders
        CountFiles(subfolder.Path) 
    Next 
 End Sub 
  Set objFSO = Nothing  
 Set strTopFolder = Nothing 
 
 

  
 strTopFolder = "\\192.168.8.214\EDI$\PTD\GVH\PROD\SAVE\IN\RD02\2016"
 
 Set objFSO = CreateObject("Scripting.FileSystemObject") 
  
 CountFiles(strTopFolder) 

 Sub CountFiles(strFolder) 
 '     On Error Resume Next 
     
    Dim objFolder, objFiles, subfolder 
     
    Set objFolder = objFSO.GetFolder(strFolder)  
    Set objFiles = objFolder.Files  
    intFileCount4 = intFileCount4 + objFiles.Count
     
    For Each subfolder In objFolder.SubFolders
        CountFiles(subfolder.Path) 
    Next 
 End Sub 
  Set objFSO = Nothing  
 Set strTopFolder = Nothing 
 
 
 
  
 strTopFolder = "\\192.168.8.214\EDI$\PTD\GVH\PROD\SAVE\IN\TD01\2016"
 
 Set objFSO = CreateObject("Scripting.FileSystemObject") 
  
 CountFiles(strTopFolder) 

 Sub CountFiles(strFolder) 
 '     On Error Resume Next 
     
    Dim objFolder, objFiles, subfolder 
     
    Set objFolder = objFSO.GetFolder(strFolder)  
    Set objFiles = objFolder.Files  
    intFileCount5 = intFileCount5 + objFiles.Count
     
    For Each subfolder In objFolder.SubFolders
        CountFiles(subfolder.Path) 
    Next 
 End Sub 
  Set objFSO = Nothing  
 Set strTopFolder = Nothing 
 
 
 
  
 strTopFolder = "\\192.168.8.214\EDI$\PTD\GVH\PROD\SAVE\IN\TR01\2016"
 
 Set objFSO = CreateObject("Scripting.FileSystemObject") 
  
 CountFiles(strTopFolder) 

 Sub CountFiles(strFolder) 
 '     On Error Resume Next 
     
    Dim objFolder, objFiles, subfolder 
     
    Set objFolder = objFSO.GetFolder(strFolder)  
    Set objFiles = objFolder.Files  
    intFileCount6 = intFileCount6 + objFiles.Count
     
    For Each subfolder In objFolder.SubFolders
        CountFiles(subfolder.Path) 
    Next 
 End Sub 
  Set objFSO = Nothing  
 Set strTopFolder = Nothing 
 
 
 

  
 strTopFolder = "\\192.168.8.214\EDI$\PTD\GVH\PROD\SAVE\IN\VA00\2016"
 
 Set objFSO = CreateObject("Scripting.FileSystemObject") 
  
 CountFiles(strTopFolder) 

 Sub CountFiles(strFolder) 
 '     On Error Resume Next 
     
    Dim objFolder, objFiles, subfolder 
     
    Set objFolder = objFSO.GetFolder(strFolder)  
    Set objFiles = objFolder.Files  
    intFileCount7 = intFileCount7 + objFiles.Count
     
    For Each subfolder In objFolder.SubFolders
        CountFiles(subfolder.Path) 
    Next 
 End Sub 
  Set objFSO = Nothing  
 Set strTopFolder = Nothing 
 
 
 
 
  
 strTopFolder = "\\192.168.8.214\EDI$\PTD\GVH\PROD\SAVE\IN\VA01\2016"
 
 Set objFSO = CreateObject("Scripting.FileSystemObject") 
  
 CountFiles(strTopFolder) 

 Sub CountFiles(strFolder) 
 '     On Error Resume Next 
     
    Dim objFolder, objFiles, subfolder 
     
    Set objFolder = objFSO.GetFolder(strFolder)  
    Set objFiles = objFolder.Files  
    intFileCount8 = intFileCount8 + objFiles.Count
     
    For Each subfolder In objFolder.SubFolders
        CountFiles(subfolder.Path) 
    Next 
 End Sub 
  Set objFSO = Nothing  
 Set strTopFolder = Nothing 
 
 
 

  
 strTopFolder = "\\192.168.8.214\EDI$\PTD\GVH\PROD\SAVE\IN\VA02\2016"
 
 Set objFSO = CreateObject("Scripting.FileSystemObject") 
  
 CountFiles(strTopFolder) 

 Sub CountFiles(strFolder) 
 '     On Error Resume Next 
     
    Dim objFolder, objFiles, subfolder 
     
    Set objFolder = objFSO.GetFolder(strFolder)  
    Set objFiles = objFolder.Files  
    intFileCount9 = intFileCount9 + objFiles.Count
     
    For Each subfolder In objFolder.SubFolders
        CountFiles(subfolder.Path) 
    Next 
 End Sub 
  Set objFSO = Nothing  
 Set strTopFolder = Nothing 
 
 
 countglobal = intFileCount + intFileCount2 + intFileCount3 + intFileCount4 + intFileCount5 + intFileCount6 + intFileCount7 + intFileCount8 + intFileCount9
 
 
 WScript.Echo "Le nombre de fichiers est de " & countglobal