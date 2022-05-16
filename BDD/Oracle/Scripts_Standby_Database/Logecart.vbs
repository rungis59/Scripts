' Ce script calcul l'ecart de synchro entre la primary et la standby
' et envoie un mail si l'ecart est superieur a 5 ou si une des 2 bases est inaccessible

set Shell = WScript.CreateObject("WScript.Shell")
Shell.Run("cscript Standby.vbs //B //T:120 log_ecart")

