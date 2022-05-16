' Enchainement des sripts copy_arch et log_ecart avec pause de 20s entre les deux

set Shell = WScript.CreateObject("WScript.Shell")
Shell.Run("cscript Standby.vbs //B //T:500 copy_arch")
wscript.sleep 60000
Shell.Run("cscript Standby.vbs //B //T:120 log_ecart")


