' Ce script permet d'épurer les logs de la standby

set Shell = WScript.CreateObject("WScript.Shell")
Shell.Run("cscript Standby.vbs //B //T:120 epurelog")

