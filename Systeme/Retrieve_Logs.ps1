$3 = [DateTime]::Today.AddDays(-1).AddHours(01)

$A = Get-EventLog -LogName System -ComputerName "AUT-SRV-TS2.autotrans.fr" -EntryType Error -Newest 5 -After $3
$A | export-csv "\\aut-srv-dc1\informatique$\LOG\AUT-SRV-TS2.autotrans.fr\System Logs.csv"
$B = Get-EventLog -LogName Application -ComputerName "AUT-SRV-TS2.autotrans.fr" -EntryType Error -Newest 5 -After $3
$B | export-csv "\\aut-srv-dc1\informatique$\LOG\AUT-SRV-TS2.autotrans.fr\Application Logs.csv"

$C = Get-EventLog -LogName System -ComputerName "AUT-SRV-BACKUP.autotrans.fr" -EntryType Error -Newest 5 -After $3
$C | export-csv "\\aut-srv-dc1\informatique$\LOG\AUT-SRV-BACKUP.autotrans.fr\System Logs.csv"
$D = Get-EventLog -LogName Application -ComputerName "AUT-SRV-BACKUP.autotrans.fr" -EntryType Error -Newest 5 -After $3
$D | export-csv "\\aut-srv-dc1\informatique$\LOG\AUT-SRV-BACKUP.autotrans.fr\Application Logs.csv"

$E = Get-EventLog -LogName System -ComputerName "AUT-SRV-DC2012.autotrans.fr" -EntryType Error -Newest 5 -After $3
$E | export-csv "\\aut-srv-dc1\informatique$\LOG\AUT-SRV-DC2012.autotrans.fr\System Logs.csv"
$F = Get-EventLog -LogName Application -ComputerName "AUT-SRV-DC2012.autotrans.fr" -EntryType Error -Newest 5 -After $3
$F | export-csv "\\aut-srv-dc1\informatique$\LOG\AUT-SRV-DC2012.autotrans.fr\Application Logs.csv"

$G = Get-EventLog -LogName System -ComputerName "AUT-SRV-DB2008.autotrans.fr" -EntryType Error -Newest 5 -After $3
$G | export-csv "\\aut-srv-dc1\informatique$\LOG\AUT-SRV-DB2008.autotrans.fr\System Logs.csv"
$H = Get-EventLog -LogName Application -ComputerName "AUT-SRV-DB2008.autotrans.fr" -EntryType Error -Newest 5 -After $3
$H | export-csv "\\aut-srv-dc1\informatique$\LOG\AUT-SRV-DB2008.autotrans.fr\Application Logs.csv"

$I = Get-EventLog -LogName System -ComputerName "AUT-SRV-SQL.autotrans.fr" -EntryType Error -Newest 5 -After $3
$I | export-csv "\\aut-srv-dc1\informatique$\LOG\AUT-SRV-SQL.autotrans.fr\System Logs.csv"
$J = Get-EventLog -LogName Application -ComputerName "AUT-SRV-SQL.autotrans.fr" -EntryType Error -Newest 5 -After $3
$J | export-csv "\\aut-srv-dc1\informatique$\LOG\AUT-SRV-SQL.autotrans.fr\Application Logs.csv"

$K = Get-EventLog -LogName System -ComputerName "AUT-SRV-WWW2K8.autotrans.fr" -EntryType Error -Newest 5 -After $3
$K | export-csv "\\aut-srv-dc1\informatique$\LOG\AUT-SRV-WWW2K8.autotrans.fr\System Logs.csv"
$L = Get-EventLog -LogName Application -ComputerName "AUT-SRV-WWW2K8.autotrans.fr" -EntryType Error -Newest 5 -After $3
$L | export-csv "\\aut-srv-dc1\informatique$\LOG\AUT-SRV-WWW2K8.autotrans.fr\Application Logs.csv"

$M = Get-EventLog -LogName System -ComputerName "AUT-SRV-DC02K8.autotrans.fr" -EntryType Error -Newest 5 -After $3
$M | export-csv "\\aut-srv-dc1\informatique$\LOG\AUT-SRV-DC02K8.autotrans.fr\System Logs.csv"
$N = Get-EventLog -LogName Application -ComputerName "AUT-SRV-DC02K8.autotrans.fr" -EntryType Error -Newest 5 -After $3
$N | export-csv "\\aut-srv-dc1\informatique$\LOG\AUT-SRV-DC02K8.autotrans.fr\Application Logs.csv"

$O = Get-EventLog -LogName System -ComputerName "AUT-SRV-DC1.autotrans.fr" -EntryType Error -Newest 5 -After $3
$O | export-csv "\\aut-srv-dc1\informatique$\LOG\AUT-SRV-DC1.autotrans.fr\System Logs.csv"
$P = Get-EventLog -LogName Application -ComputerName "AUT-SRV-DC1.autotrans.fr" -EntryType Error -Newest 5 -After $3
$P | export-csv "\\aut-srv-dc1\informatique$\LOG\AUT-SRV-DC1.autotrans.fr\Application Logs.csv"

$Q = Get-EventLog -LogName System -ComputerName "AUT-SRV-TOS2012.autotrans.fr" -EntryType Error -Newest 5 -After $3
$Q | export-csv "\\aut-srv-dc1\informatique$\LOG\AUT-SRV-TOS2012.autotrans.fr\System Logs.csv"
$R = Get-EventLog -LogName Application -ComputerName "AUT-SRV-TOS2012.autotrans.fr" -EntryType Error -Newest 5 -After $3
$R | export-csv "\\aut-srv-dc1\informatique$\LOG\AUT-SRV-TOS2012.autotrans.fr\Application Logs.csv"

$V = Get-EventLog -LogName System -ComputerName "AUT-SRV-SBI.autotrans.fr" -EntryType Error -Newest 5 -After $3
$V | export-csv "\\aut-srv-dc1\informatique$\LOG\AUT-SRV-SBI.autotrans.fr\System Logs.csv"
$X = Get-EventLog -LogName Application -ComputerName "AUT-SRV-SBI.autotrans.fr" -EntryType Error -Newest 5 -After $3
$X | export-csv "\\aut-srv-dc1\informatique$\LOG\AUT-SRV-SBI.autotrans.fr\Application Logs.csv"

$1 = Get-EventLog -LogName System -ComputerName "AUT-SRV-UPS.autotrans.fr" -EntryType Error -Newest 5 -After $3
$1 | export-csv "\\aut-srv-dc1\informatique$\LOG\AUT-SRV-UPS.autotrans.fr\System Logs.csv"
$2 = Get-EventLog -LogName Application -ComputerName "AUT-SRV-UPS.autotrans.fr" -EntryType Error -Newest 5 -After $3
$2 | export-csv "\\aut-srv-dc1\informatique$\LOG\AUT-SRV-UPS.autotrans.fr\Application Logs.csv"