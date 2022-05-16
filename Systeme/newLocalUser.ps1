$password = ConvertTo-SecureString 'S@geX3' -AsPlainText -Force
New-LocalUser "sagex3" -Password $password -PasswordNeverExpires
Add-LocalGroupMember -Group "Administrateurs" -Member "sagex3"
Add-LocalGroupMember -Group "Utilisateurs du Bureau à distance" -Member "sagex3"
