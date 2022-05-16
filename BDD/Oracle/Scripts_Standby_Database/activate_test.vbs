'Script servant à activer la base standby pour test et n'affectant pas la base primary
'Attention, après avoir utilisé ce script, il faut recréer la standby

set Shell = WScript.CreateObject("WScript.Shell")
Shell.Run("cscript Standby.vbs activation_test")

