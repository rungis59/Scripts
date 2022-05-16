$instance  = "SAGEX3"
$sqlinternallogin = "sa"
$sqlinternalpwd  = "S@geX3"
$sqlbase = "rossel"
$servername = hostname


$Query = @"
USE rossel;
GO
-- Reset the database recovery model.
ALTER DATABASE rossel
SET RECOVERY FULL;
GO
"@

Invoke-Sqlcmd -ServerInstance $servername\$instance -Username $sqlinternallogin -Password $sqlinternalpwd -Database $sqlbase -Query $Query -Querytimeout 0 -Verbose


