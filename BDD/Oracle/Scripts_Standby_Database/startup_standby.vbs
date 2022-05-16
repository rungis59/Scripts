'Ce script permet un redémarrage de la stanby suite à un arret quelqonque de la base
'a condition que cette base n'ait pas été redémarrée en mode normal

set Shell = WScript.CreateObject("WScript.Shell")
Shell.Run("cscript Standby.vbs startup_standby_standard")

