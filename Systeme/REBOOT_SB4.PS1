$password = "capadoce" | ConvertTo-SecureString -asPlainText -Force
$username = "sb4\administrateur"
$credential = New-Object System.Management.Automation.PSCredential($username,$password)
Restart-Computer sb4 -credential $credential -Force