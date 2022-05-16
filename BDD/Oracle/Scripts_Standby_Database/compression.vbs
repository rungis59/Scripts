'Ce script permet de compresser les archivelogs

set Shell = WScript.CreateObject("WScript.Shell")
Shell.Run("cscript Standby.vbs //B //T:240 compresse")

