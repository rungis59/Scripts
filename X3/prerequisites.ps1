New-NetFirewallRule -DisplayName 'Sage X3' -Direction Inbound -Action Allow -Protocol TCP -LocalPort @('80', '1818', '1890', '1895', '8127', '1801', '1802', '1803', '1521', '27017', '9200', '9300', '8124', '1433', '1434', '20100', '1522')
New-NetFirewallRule -DisplayName 'SQL' -Direction Inbound -Action Allow -Protocol UDP -Profile Any -LocalPort @('1434')
powercfg.exe -SETACTIVE 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c
$password = ConvertTo-SecureString 'S@geX3' -AsPlainText -Force
New-LocalUser "sagex3" -Password $password -PasswordNeverExpires -UserMayNotChangePassword
Add-LocalGroupMember -Group "Administrateurs" -Member "sagex3"
Set-MpPreference -DisableRealtimeMonitoring $true
Install-WindowsFeature Net-Framework-Core
