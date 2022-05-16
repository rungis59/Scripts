'Script servant à activer la base standby en read only et n'affectant pas la base primary
' l usage en read only permet soit un simmple test de bon fonctionnement de la base
' soit une utilisation en base de warehouse par ex.
' Attention, dans ce mode, la connexion d'un client X3 n'est pas possible
' cette activation ne nécessite pas de recréer la standby

set Shell = WScript.CreateObject("WScript.Shell")
Shell.Run("cscript Standby.vbs activation_read_only")

