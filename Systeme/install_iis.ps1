Import-Module Servermanager
Add-WindowsFeature Application-Server, AS-NET-Framework -logPath C:\Windows\Logs\app_server.log -WhatIf

Add-WindowsFeature WAS, WAS-Process-Model, WAS-NET-Environment, WAS-Config-APIs -logPath C:\Windows\Logs\was_server.log -WhatIf