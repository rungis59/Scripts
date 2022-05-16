'Ce script permet de savoir le role du serveur sur lequel on est

set Shell = WScript.CreateObject("WScript.Shell")
Shell.Run("cscript Standby.vbs role_actuel")