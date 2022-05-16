$name = 'VMF-EDTFERMOB'
$username = "fermob.local\administrateur"
$password = ConvertTo-SecureString 'bistr0Z1p' -AsPlainText -Force
$cred = new-object -typename System.Management.Automation.PSCredential -argumentlist $username, $password
add-computer -computername $name -domainname fermob.local –credential $cred -restart –force