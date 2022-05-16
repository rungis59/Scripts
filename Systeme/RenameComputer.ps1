$name = 'VMF-EDTFERMOB'
$username = "fermob.local\administrateur"
$password = ConvertTo-SecureString 'bistr0Z1p' -AsPlainText -Force
$cred = new-object -typename System.Management.Automation.PSCredential -argumentlist $username, $password
RENAME-COMPUTER –computername localhost –newname $name -Restart
