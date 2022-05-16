param(
[string]$version,
[string]$InstanceName,
[string]$collation,
[string]$TCPPort,
[string]$InstallDrive,
[string]$SAPWD
) 


if ($version -eq "2017" -or $version -eq "2016")
{
$date = Get-Date -format "yyyy-MM-dd HH:mm:ss" 
echo "$date Starting installation of Microsoft SQL Server Management Studio - it can take few minutes, please wait..."
Start-Process $InstallDrive`DBA\Updates\SSMS-Setup.exe -argumentlist " /install /norestart /passive /log $InstallDrive`DBA\logs\SSMS.txt" -wait
$date = Get-Date -format "yyyy-MM-dd HH:mm:ss" 
echo "$date Installation of Microsoft SQL Server Management Studio completed"
}

