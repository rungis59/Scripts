$1 = Get-Credential -Credential autotrans\administrateur
Invoke-Command -ComputerName 192.168.8.212 -ScriptBlock { Get-EventLog -LogName System -EntryType Error -Newest 5 | export-csv "c:\LOG\System Logs.csv" } -credential $1
Invoke-Command -ComputerName 192.168.8.212 -ScriptBlock { Get-EventLog -LogName Application -EntryType Error -Newest 5 | export-csv "c:\LOG\Application Logs.csv" } -credential $1

Invoke-Command -ComputerName 192.168.8.211 -ScriptBlock { Get-EventLog -LogName System -EntryType Error -Newest 5 | export-csv "c:\LOG\System Logs.csv" } -credential $1
Invoke-Command -ComputerName 192.168.8.211 -ScriptBlock { Get-EventLog -LogName Application -EntryType Error -Newest 5 | export-csv "c:\LOG\Application Logs.csv" } -credential $1

Invoke-Command -ComputerName 192.168.8.221 -ScriptBlock { Get-EventLog -LogName System -EntryType Error -Newest 5 | export-csv "c:\LOG\System Logs.csv" } -credential $1
Invoke-Command -ComputerName 192.168.8.221 -ScriptBlock { Get-EventLog -LogName Application -EntryType Error -Newest 5 | export-csv "c:\LOG\Application Logs.csv" } -credential $1

Invoke-Command -ComputerName 192.168.8.214 -ScriptBlock { Get-EventLog -LogName System -EntryType Error -Newest 5 | export-csv "c:\LOG\System Logs.csv" } -credential $1
Invoke-Command -ComputerName 192.168.8.214 -ScriptBlock { Get-EventLog -LogName Application -EntryType Error -Newest 5 | export-csv "c:\LOG\Application Logs.csv" } -credential $1

Invoke-Command -ComputerName 192.168.8.204 -ScriptBlock { Get-EventLog -LogName System -EntryType Error -Newest 5 | export-csv "c:\LOG\System Logs.csv" } -credential $1
Invoke-Command -ComputerName 192.168.8.204 -ScriptBlock { Get-EventLog -LogName Application -EntryType Error -Newest 5 | export-csv "c:\LOG\Application Logs.csv" } -credential $1

Invoke-Command -ComputerName 192.168.9.200 -ScriptBlock { Get-EventLog -LogName System -EntryType Error -Newest 5 | export-csv "c:\LOG\System Logs.csv" } -credential $1
Invoke-Command -ComputerName 192.168.9.200 -ScriptBlock { Get-EventLog -LogName Application -EntryType Error -Newest 5 | export-csv "c:\LOG\Application Logs.csv" } -credential $1

Invoke-Command -ComputerName 192.168.8.205 -ScriptBlock { Get-EventLog -LogName System -EntryType Error -Newest 5 | export-csv "c:\LOG\System Logs.csv" } -credential $1
Invoke-Command -ComputerName 192.168.8.205 -ScriptBlock { Get-EventLog -LogName Application -EntryType Error -Newest 5 | export-csv "c:\LOG\Application Logs.csv" } -credential $1

Invoke-Command -ComputerName 192.168.8.215 -ScriptBlock { Get-EventLog -LogName System -EntryType Error -Newest 5 | export-csv "c:\LOG\System Logs.csv" } -credential $1
Invoke-Command -ComputerName 192.168.8.215 -ScriptBlock { Get-EventLog -LogName Application -EntryType Error -Newest 5 | export-csv "c:\LOG\Application Logs.csv" } -credential $1

Invoke-Command -ComputerName 192.168.8.220 -ScriptBlock { Get-EventLog -LogName System -EntryType Error -Newest 5 | export-csv "c:\LOG\System Logs.csv" } -credential $1
Invoke-Command -ComputerName 192.168.8.220 -ScriptBlock { Get-EventLog -LogName Application -EntryType Error -Newest 5 | export-csv "c:\LOG\Application Logs.csv" } -credential $1

Invoke-Command -ComputerName 192.168.8.223 -ScriptBlock { Get-EventLog -LogName System -EntryType Error -Newest 5 | export-csv "c:\LOG\System Logs.csv" } -credential $1
Invoke-Command -ComputerName 192.168.8.223 -ScriptBlock { Get-EventLog -LogName Application -EntryType Error -Newest 5 | export-csv "c:\LOG\Application Logs.csv" } -credential $1

Invoke-Command -ComputerName 192.168.8.209 -ScriptBlock { Get-EventLog -LogName System -EntryType Error -Newest 5 | export-csv "c:\LOG\System Logs.csv" } -credential $1
Invoke-Command -ComputerName 192.168.8.209 -ScriptBlock { Get-EventLog -LogName Application -EntryType Error -Newest 5 | export-csv "c:\LOG\Application Logs.csv" } -credential $1