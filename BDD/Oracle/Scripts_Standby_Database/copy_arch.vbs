' Ce script permet de synchroniser la standby database avec la base de prod

set Shell = WScript.CreateObject("WScript.Shell")
Shell.Run("cscript Standby.vbs //B  //T:500 copy_arch")

