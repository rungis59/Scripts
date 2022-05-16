' Ce script active la base de standby en base de prod
' Attention, à n'utiliser qu'en cas de perte de la base de prod.
 
set Shell = WScript.CreateObject("WScript.Shell")
Shell.Run("cscript Standby.vbs activation_standard")

