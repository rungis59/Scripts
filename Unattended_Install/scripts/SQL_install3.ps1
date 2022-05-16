param(
[string]$version,
[string]$InstanceName,
[string]$collation,
[string]$TCPPort,
[string]$InstallDrive,
[string]$SAPWD
) 

$date = Get-Date -format "yyyyMMdd_HHmmss" 

if ($version -eq "2016")
{
	New-Item -ItemType directory -Path $InstallDrive`DBA\logs -Force
	$date = Get-Date -format "yyyy-MM-dd HH:mm:ss" 
	Write-Output "$date SQL Server installation completed, starting installation of Microsoft System CLR Types for Microsoft SQL Server 2016"
	$ArgumentList = "/i $InstallDrive`DBA\scripts\SQLSysClrTypes.msi /passive /norestart /quiet /log $InstallDrive`DBA\logs\"+$InstanceName+"_SQLSysClrTypes.log"
	Start-Process C:\Windows\System32\msiexec.exe -ArgumentList $ArgumentList -wait

	$date = Get-Date -format "yyyy-MM-dd HH:mm:ss" 
	Write-Output "$date Starting installation of Microsoft® SQL Server® 2016 Shared Management Objects"
	$ArgumentList =  "/i $InstallDrive`DBA\scripts\SharedManagementObjects.msi /passive /norestart /quiet /log $InstallDrive`DBA\logs\"+$InstanceName+"_SharedManagementObjects.log" 	
	Start-Process C:\Windows\System32\msiexec.exe -ArgumentList $ArgumentList -wait

	$date = Get-Date -format "yyyy-MM-dd HH:mm:ss" 
	Write-Output "$date Starting installation Microsoft Windows PowerShell Extensions for Microsoft SQL Server 2016"
	$ArgumentList = "/i $InstallDrive`DBA\scripts\PowerShellTools.msi /passive /norestart /quiet /log $InstallDrive`DBA\logs\"+$InstanceName+"_PowerShellTools.txt"
	Start-Process C:\Windows\System32\msiexec.exe -ArgumentList $ArgumentList -wait
	$date = Get-Date -format "yyyy-MM-dd HH:mm:ss" 
	Write-Output "$date Installation of all additonal packages completed"
	
	$date = Get-Date -format "yyyy-MM-dd HH:mm:ss" 
	Write-Output "$date Running admin access script"

	cd "C:\Program Files\Microsoft SQL Server\130\Tools\PowerShell\Modules"
	Import-Module (Resolve-Path('SQLPS')) -DisableNamechecking

	start-service -displayname "SQL Server ($InstanceName)"
	start-service -displayname "SQL Server Agent ($InstanceName)"

	$Log = $InstallDrive+"DBA\logs\"+$InstanceName+"_01_Admin_Access.txt"
}

if ($version -eq "2017")
{
$sql_version_part = "MSSQL14"
$sql_version_number = "140"  
}
elseif ($version -eq "2016")
{
$sql_version_part = "MSSQL13"
$sql_version_number = "130"
}
elseif ($version -eq "2014")
{
$sql_version_part = "MSSQL12"
$sql_version_number = "120"
}
elseif($version -eq "2012")
{
$sql_version_part = "MSSQL11"
$sql_version_number = "110"
}
elseif($version -eq "2008R2")
{
$sql_version_part = "MSSQL10_50"
$sql_version_number = "100"
}


<#################################################################################
# Step 7: Database Server Options
################################################################################

$date = Get-Date -format "yyyy-MM-dd HH:mm:ss" 
Write-Output "$date Running 0_database_server_options script"

$Log = $InstallDrive+"DBA\logs\"+$InstanceName+"_06_database_server_options.txt"
if ($InstanceName -eq "MSSQLSERVER")
    {
    Invoke-Sqlcmd -InputFile $InstallDrive`DBA\scripts\06_database_server_options.sql -ServerInstance . -verbose > $Log 4>&1
    }
else
    {
   Invoke-Sqlcmd -InputFile $InstallDrive`DBA\scripts\06_database_server_options.sql -ServerInstance .\$InstanceName -verbose > $Log 4>&1
   }
#>

################################################################################
# Step 8: TCP Port configuration
################################################################################
$date = Get-Date -format "yyyy-MM-dd HH:mm:ss" 
Write-Output "$date Running TCP IP configuration for SQL Server"

$TCPPath = 'HKLM:\SOFTWARE\Microsoft\\Microsoft SQL Server\' + $sql_version_part +'.'+ $InstanceName + '\MSSQLServer\SuperSocketNetLib\Tcp\IPAll'
set-itemproperty -path $TCPPath -name TcpPort -value $TCPPort
set-itemproperty -path $TCPPath -name TcpDynamicPorts -value ""

$date = Get-Date -format "yyyy-MM-dd HH:mm:ss" 

################################################################################
# Step 9: Adding trace flags
################################################################################
$date = Get-Date -format "yyyy-MM-dd HH:mm:ss" 
Write-Output "$date Running Trace flag configuration for SQL Server"

$TraceFlagPath = 'HKLM:\SOFTWARE\Microsoft\\Microsoft SQL Server\' + $sql_version_part +'.'+ $InstanceName + '\MSSQLServer\Parameters'

if ($version -eq "2016" -or $version -eq "2017")
{
New-ItemProperty -path $TraceFlagPath -name SQLArg5 -Value "-T3226" -Force | Out-Null
}
else
{
New-ItemProperty -path $TraceFlagPath -name SQLArg3 -Value "-T1117" -Force | Out-Null
New-ItemProperty -path $TraceFlagPath -name SQLArg4 -Value "-T1118" -Force | Out-Null
New-ItemProperty -path $TraceFlagPath -name SQLArg5 -Value "-T3226" -Force | Out-Null
New-ItemProperty -path $TraceFlagPath -name SQLArg6 -Value "-T4199" -Force | Out-Null
}

$date = Get-Date -format "yyyy-MM-dd HH:mm:ss" 
Write-Output "$date Stopping SQL Server"
stop-service -displayname "SQL Server ($InstanceName)" -force
$date = Get-Date -format "yyyy-MM-dd HH:mm:ss" 
Write-Output "$date Starting SQL Server"
start-service -displayname "SQL Server ($InstanceName)"
start-service -displayname "SQL Server Agent ($InstanceName)"

################################################################################
# Step 10: Review summary
################################################################################
$date = Get-Date -format "yyyy-MM-dd HH:mm:ss" 
Write-Output "$date Installation completed"
Set-Location $InstallDrive`DBA
notepad "C:\Program Files\Microsoft SQL Server\$sql_version_number\Setup Bootstrap\LOG\Summary.txt"
