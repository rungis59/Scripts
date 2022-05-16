Option Explicit 
 'On Error Resume Next 
  
 Dim objFSO, strTopFolder, intFileCount
 
  
 strTopFolder = "\\192.168.8.214\EDI$\PTD\GVH\PROD\SAVE\OUT\2016"
 
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
 
 
 WScript.Echo "Le nombre de fichiers est de " & intFileCount