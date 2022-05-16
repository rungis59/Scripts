param(
[string]$version,
[string]$InstanceName,
[string]$collation,
[string]$TCPPort,
[string]$InstallDrive,
[string]$SAPWD,
[string]$c,
[string]$SQLAccountL,
[string]$SQLAccountP
) 

$date = Get-Date -format "yyyy-MM-dd HH:mm:ss" 
Write-Output "################################################################################
                    SQL Server installation script
################################################################################

Installation started at $date 
On computer $env:computername
Script parameters: $version $InstanceName $collation $TCPPort $InstallDrive "

################################################################################
# Step 1: Validating input parameters
################################################################################
Write-Output "$date Validating input parameters"

if (($version -eq "2008R2") -or ($version -eq "2012") -or ($version -eq "2014") -or ($version -eq "2016") -or ($version -eq "2017"))
{
}
else
{
Write-Output "$date Missing parameter with version of SQL Server. Possible options are: 2008R2, 2012, 2014, 2016, 2017

################################################################################
"
Get-Date -format "yyyy-MM-dd HH:mm:ss"
exit
}

if ($InstanceName)
{
}
else
{
Write-Output "$date Please provide Instance Name for SQL Server

################################################################################
"
Get-Date -format "yyyy-MM-dd HH:mm:ss"
exit
}
if ($collation)
{
}
else
{
Write-Output "$date Missing parameter with collation of server. Please provide correct collation like SQL_Latin1_General_BIN1, SQL_Latin1_General_CP1_CI_AS, etc.

################################################################################
"
Get-Date -format "yyyy-MM-dd HH:mm:ss"
exit
}

if ($InstallDrive)
{
}
else
{
Write-Output "$date Please provide Installation drive for SQL Server

################################################################################
"
Get-Date -format "yyyy-MM-dd HH:mm:ss"
exit
}

if ($SAPWD)
{
}
else
{
Write-Output "$date Please provide SA password

################################################################################
"
Get-Date -format "yyyy-MM-dd HH:mm:ss"
exit
}

if ($TCPPort)
{
Write-Output "$date Step 2: completed - Script is going to install SQL Server $version with Instance Name: $InstanceName using $TCPPort on $env:computername"

}
else
{
Write-Output "$date Step 2: failed

Please provide TCP Port for SQL Server

################################################################################
"
Get-Date -format "yyyy-MM-dd HH:mm:ss"
exit
}


################################################################################
# Step 2: .Net framework 3.5 sp1 
################################################################################
$date = Get-Date -format "yyyy-MM-dd HH:mm:ss" 
Write-Output "$date Checking if .NET 3.5 is installed"

$net_core_2012r2 = (Get-WindowsFeature -Name Net-Framework-Core).InstallState
$net_core_2008r2 = (Get-WindowsFeature -Name Net-Framework-Core).Installed

if (($net_core_2012r2 -eq "Installed") -or ($net_core_2008r2 -eq $True))
{
$message = ".NET Framework 3.5 is installed on the server"
Write-Output $message
}
else
{
$message = ".NET Framework 3.5 is missing on the server, please reach out to the Provisioning team and ask them to install .NET Framework 3.5"
Write-Output $message
exit
}
################################################################################
# Step 3: Disk alignment
################################################################################
 
$date = Get-Date -format "yyyy-MM-dd HH:mm:ss" 
Write-Output "$date Checking disk aligment"

$wql = "SELECT Label, Blocksize, Name FROM Win32_Volume WHERE FileSystem='NTFS'"

$disk_block_sizes = (Get-WmiObject -Query $wql -ComputerName '.' | Where-Object {$_.Name -notmatch "C:?"})  | Where-Object {$_.Name -notmatch "System"}
($disk_block_sizes |  Where-Object {$_.BlockSize -eq "65536"}).Name

$disks_wrong = ($disk_block_sizes |  Where-Object {$_.BlockSize -ne "65536"}).Name
$disks_64k = ($disk_block_sizes |  Where-Object {$_.BlockSize -eq "65536"}).Name

if ($disks_64k -ne $null)
{
$message = "Following disks are correctly formated, please check if following disk are with letters D:, F:, L:, T:, U: "
Write-Output $message $disks_64k
}
else
{
$message = "Following disks are formatted incorrectly, please consider reformating following disk"
Write-Output $message, $disks_wrong 
}

################################################################################
# Step 4: Granting required privileges to Admins group 
################################################################################
$date = Get-Date -format "yyyy-MM-dd HH:mm:ss" 
Write-Output "$date Granting required privileges to Admins group"

robocopy $InstallDrive`DBA\scripts C:\Windows\System32 ntrights.exe
$date = Get-Date -format "yyyy-MM-dd HH:mm:ss" 
Write-Output "$date Granting required privileges to Administrateurs group"
C:\Windows\System32\ntrights -u Administrateurs +r SeInteractiveLogonRight
C:\Windows\System32\ntrights -u Administrateurs +r SeBatchLogonRight
C:\Windows\System32\ntrights -u Administrateurs +r SeServiceLogonRight
C:\Windows\System32\ntrights -u Administrateurs +r SeNetworkLogonRight
C:\Windows\System32\ntrights -u Administrateurs +r SeTcbPrivilege
C:\Windows\System32\ntrights -u Administrateurs +r SeDebugPrivilege
C:\Windows\System32\ntrights -u Administrateurs +r SeSecurityPrivilege
C:\Windows\System32\ntrights -u Administrateurs +r SeBackupPrivilege

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

################################################################################
# Step 5: Install SQL Server with SP and CU
################################################################################

$date = Get-Date -format "yyyy-MM-dd HH:mm:ss" 
Write-Output "$date Starting SQL Server installation"

If(!(Test-Path -Path $InstallDrive`SQL)) {
	New-Item -ItemType Directory -Force -Path $InstallDrive`SQL}
	
$AGTSVCACCOUNT = "NT AUTHORITY\NETWORK SERVICE"
$SQLSVCACCOUNT = "NT AUTHORITY\NETWORK SERVICE"
$user = whoami
$InstallationDIR = $InstallDrive+"SQL\MSSQLServer\"
$SQLBackupDIR = $InstallDrive+"SQL\SQLBackup\" +$env:computername+"$"+$InstanceName
$SQLTempDBDIR = $InstallDrive+"SQL\SQLTempDB01\" + $sql_version_part +"."+ $InstanceName
$SQLTempDBDIR2016 = $InstallDrive+"SQL\SQLTempDB\" + $sql_version_part +"."+ $InstanceName 
$SQLTempDBLogDIR = $InstallDrive+"SQL\SQLTLog\" + $sql_version_part +"."+ $InstanceName
$SQLUserDBDIR = $InstallDrive+"SQL\SQLData00\" + $sql_version_part +"."+ $InstanceName
$SQLUserDBLogDIR = $InstallDrive+"SQL\SQLTLog\" + $sql_version_part +"."+ $InstanceName
$PID2017 = "6GPYM-VHN83-PHDM2-Q9T2R-KBV83"
$PID2016 = "B9GQY-GBG4J-282NY-QRG4X-KQBCR"
$PID2014 = "P7FRV-Y6X6Y-Y8C6Q-TB4QR-DMTTK"
$PID2012 = "YFC4R-BRRWB-TVP9Y-6WJQ9-MCJQ7"
$PID2008 = "FXHQY-JQF42-68VVV-PYVVR-RY3BB"

if ($version -eq "2017")
{
    if (-not $SQLAccountL -and -not $SQLAccountP)
	{
    Set-location $c
	.\Setup.exe /QS /ACTION=Install /FEATURES=SQLENGINE,CONN /UpdateEnabled=1 /UpdateSource="$InstallDrive`DBA\Updates" /ERRORREPORTING=0 /INSTANCEDIR=$InstallationDIR /INSTANCEID=$InstanceName /INSTANCENAME=$InstanceName /SQMREPORTING=0 /SQLSVCACCOUNT=$SQLSVCACCOUNT /AGTSVCACCOUNT=$AGTSVCACCOUNT /AGTSVCSTARTUPTYPE="Automatic" /BROWSERSVCSTARTUPTYPE="Automatic" /INSTALLSQLDATADIR=$InstallationDIR /SQLBACKUPDIR=$SQLBackupDIR /SQLCOLLATION=$collation /SQLSVCSTARTUPTYPE="Automatic" /SQLTEMPDBDIR=$SQLTempDBDIR2016 /SQLTEMPDBLOGDIR=$SQLTempDBLogDIR /SQLUSERDBDIR=$SQLUserDBDIR /SQLUSERDBLOGDIR=$SQLUserDBLogDIR /SQLTEMPDBFILECOUNT=4 /SQLTEMPDBFILESIZE=1048 /SQLTEMPDBFILEGROWTH=102 /SQLTEMPDBLOGFILESIZE=524 /SQLTEMPDBLOGFILEGROWTH=524 /IACCEPTSQLSERVERLICENSETERMS /SECURITYMODE=SQL /SAPWD=$SAPWD /PID=$PID2017 /SQLSYSADMINACCOUNTS=$user
    }
    elseif ($SQLAccountL -and -not $SQLAccountP)
    {
    Set-location $c
	.\Setup.exe /QS /ACTION=Install /FEATURES=SQLENGINE,CONN /UpdateEnabled=1 /UpdateSource="$InstallDrive`DBA\Updates" /ERRORREPORTING=0 /INSTANCEDIR=$InstallationDIR /INSTANCEID=$InstanceName /INSTANCENAME=$InstanceName /SQMREPORTING=0 /SQLSVCACCOUNT=$SQLAccountL /AGTSVCACCOUNT=$SQLAccountL /AGTSVCSTARTUPTYPE="Automatic" /BROWSERSVCSTARTUPTYPE="Automatic" /INSTALLSQLDATADIR=$InstallationDIR /SQLBACKUPDIR=$SQLBackupDIR /SQLCOLLATION=$collation /SQLSVCSTARTUPTYPE="Automatic" /SQLTEMPDBDIR=$SQLTempDBDIR2016 /SQLTEMPDBLOGDIR=$SQLTempDBLogDIR /SQLUSERDBDIR=$SQLUserDBDIR /SQLUSERDBLOGDIR=$SQLUserDBLogDIR /SQLTEMPDBFILECOUNT=4 /SQLTEMPDBFILESIZE=1048 /SQLTEMPDBFILEGROWTH=102 /SQLTEMPDBLOGFILESIZE=524 /SQLTEMPDBLOGFILEGROWTH=524 /IACCEPTSQLSERVERLICENSETERMS /SECURITYMODE=SQL /SAPWD=$SAPWD /PID=$PID2017 /SQLSYSADMINACCOUNTS=$user
    }
	elseif ($SQLAccountL -and $SQLAccountP)
	{
    Set-location $c
	.\Setup.exe /QS /ACTION=Install /FEATURES=SQLENGINE,CONN /UpdateEnabled=1 /UpdateSource="$InstallDrive`DBA\Updates" /ERRORREPORTING=0 /INSTANCEDIR=$InstallationDIR /INSTANCEID=$InstanceName /INSTANCENAME=$InstanceName /SQMREPORTING=0 /SQLSVCACCOUNT=$SQLAccountL /AGTSVCACCOUNT=$SQLAccountL /SQLSVCPASSWORD=$SQLAccountP /AGTSVCPASSWORD=$SQLAccountP /AGTSVCSTARTUPTYPE="Automatic" /BROWSERSVCSTARTUPTYPE="Automatic" /INSTALLSQLDATADIR=$InstallationDIR /SQLBACKUPDIR=$SQLBackupDIR /SQLCOLLATION=$collation /SQLSVCSTARTUPTYPE="Automatic" /SQLTEMPDBDIR=$SQLTempDBDIR2016 /SQLTEMPDBLOGDIR=$SQLTempDBLogDIR /SQLUSERDBDIR=$SQLUserDBDIR /SQLUSERDBLOGDIR=$SQLUserDBLogDIR /SQLTEMPDBFILECOUNT=4 /SQLTEMPDBFILESIZE=1048 /SQLTEMPDBFILEGROWTH=102 /SQLTEMPDBLOGFILESIZE=524 /SQLTEMPDBLOGFILEGROWTH=524 /IACCEPTSQLSERVERLICENSETERMS /SECURITYMODE=SQL /SAPWD=$SAPWD /PID=$PID2017 /SQLSYSADMINACCOUNTS=$user
    }

	$date = Get-Date -format "yyyy-MM-dd HH:mm:ss" 
	Write-Output "$date SQL Server installation completed"
}
if ($version -eq "2016")
{
    if (-not $SQLAccountL -and -not $SQLAccountP)
    {
    Set-location $c
	.\Setup.exe /QS /ACTION=Install /FEATURES=SQLENGINE,CONN /UpdateEnabled=1 /UpdateSource="$InstallDrive`DBA\Updates" /ERRORREPORTING=0 /INSTANCEDIR=$InstallationDIR /INSTANCEID=$InstanceName /INSTANCENAME=$InstanceName /SQMREPORTING=0 /SQLSVCACCOUNT=$SQLSVCACCOUNT /AGTSVCACCOUNT=$AGTSVCACCOUNT /AGTSVCSTARTUPTYPE="Automatic" /BROWSERSVCSTARTUPTYPE="Automatic" /INSTALLSQLDATADIR=$InstallationDIR /SQLBACKUPDIR=$SQLBackupDIR /SQLCOLLATION=$collation /SQLSVCSTARTUPTYPE="Automatic" /SQLTEMPDBDIR=$SQLTempDBDIR2016 /SQLTEMPDBLOGDIR=$SQLTempDBLogDIR /SQLUSERDBDIR=$SQLUserDBDIR /SQLUSERDBLOGDIR=$SQLUserDBLogDIR /SQLTEMPDBFILECOUNT=4 /SQLTEMPDBFILESIZE=1024 /SQLTEMPDBFILEGROWTH=102 /SQLTEMPDBLOGFILESIZE=524 /SQLTEMPDBLOGFILEGROWTH=524 /IACCEPTSQLSERVERLICENSETERMS /SECURITYMODE=SQL /SAPWD=$SAPWD /PID=$PID2016 /SQLSYSADMINACCOUNTS=$user
    }
	elseif ($SQLAccountL -and -not $SQLAccountP)
    {
    Set-location $c
	.\Setup.exe /QS /ACTION=Install /FEATURES=SQLENGINE,CONN /UpdateEnabled=1 /UpdateSource="$InstallDrive`DBA\Updates" /ERRORREPORTING=0 /INSTANCEDIR=$InstallationDIR /INSTANCEID=$InstanceName /INSTANCENAME=$InstanceName /SQMREPORTING=0 /SQLSVCACCOUNT=$SQLAccountL /AGTSVCACCOUNT=$SQLAccountL /AGTSVCSTARTUPTYPE="Automatic" /BROWSERSVCSTARTUPTYPE="Automatic" /INSTALLSQLDATADIR=$InstallationDIR /SQLBACKUPDIR=$SQLBackupDIR /SQLCOLLATION=$collation /SQLSVCSTARTUPTYPE="Automatic" /SQLTEMPDBDIR=$SQLTempDBDIR2016 /SQLTEMPDBLOGDIR=$SQLTempDBLogDIR /SQLUSERDBDIR=$SQLUserDBDIR /SQLUSERDBLOGDIR=$SQLUserDBLogDIR /SQLTEMPDBFILECOUNT=4 /SQLTEMPDBFILESIZE=1024 /SQLTEMPDBFILEGROWTH=102 /SQLTEMPDBLOGFILESIZE=524 /SQLTEMPDBLOGFILEGROWTH=524 /IACCEPTSQLSERVERLICENSETERMS /SECURITYMODE=SQL /SAPWD=$SAPWD /PID=$PID2016 /SQLSYSADMINACCOUNTS=$user
	    }
	elseif ($SQLAccountL -and $SQLAccountP)
	{
    Set-location $c
	.\Setup.exe /QS /ACTION=Install /FEATURES=SQLENGINE,CONN /UpdateEnabled=1 /UpdateSource="$InstallDrive`DBA\Updates" /ERRORREPORTING=0 /INSTANCEDIR=$InstallationDIR /INSTANCEID=$InstanceName /INSTANCENAME=$InstanceName /SQMREPORTING=0 /SQLSVCACCOUNT=$SQLAccountL /AGTSVCACCOUNT=$SQLAccountL /SQLSVCPASSWORD=$SQLAccountP /AGTSVCPASSWORD=$SQLAccountP /AGTSVCSTARTUPTYPE="Automatic" /BROWSERSVCSTARTUPTYPE="Automatic" /INSTALLSQLDATADIR=$InstallationDIR /SQLBACKUPDIR=$SQLBackupDIR /SQLCOLLATION=$collation /SQLSVCSTARTUPTYPE="Automatic" /SQLTEMPDBDIR=$SQLTempDBDIR2016 /SQLTEMPDBLOGDIR=$SQLTempDBLogDIR /SQLUSERDBDIR=$SQLUserDBDIR /SQLUSERDBLOGDIR=$SQLUserDBLogDIR /SQLTEMPDBFILECOUNT=4 /SQLTEMPDBFILESIZE=1024 /SQLTEMPDBFILEGROWTH=102 /SQLTEMPDBLOGFILESIZE=524 /SQLTEMPDBLOGFILEGROWTH=524 /IACCEPTSQLSERVERLICENSETERMS /SECURITYMODE=SQL /SAPWD=$SAPWD /PID=$PID2016 /SQLSYSADMINACCOUNTS=$user
	}
	
	$date = Get-Date -format "yyyy-MM-dd HH:mm:ss" 
	Write-Output "$date SQL Server installation completed"
}
elseif ($version -eq "2014")
{
    if (-not $SQLAccountL -and -not $SQLAccountP)
    {
    Set-location $c
	.\Setup.exe /QS /ACTION=Install /FEATURES=SQLENGINE,ADV_SSMS,CONN /UpdateEnabled=1 /UpdateSource=$InstallDrive`DBA\Updates /ERRORREPORTING=0 /INSTANCEDIR=$InstallationDIR /INSTANCEID=$InstanceName /INSTANCENAME=$InstanceName /SQMREPORTING=0 /SQLSVCACCOUNT=$SQLSVCACCOUNT /AGTSVCACCOUNT=$AGTSVCACCOUNT /AGTSVCSTARTUPTYPE="Automatic" /BROWSERSVCSTARTUPTYPE="Automatic" /INSTALLSQLDATADIR=$InstallationDIR /SQLBACKUPDIR=$SQLBackupDIR /SQLCOLLATION=$collation /SQLSVCSTARTUPTYPE="Automatic" /SQLTEMPDBDIR=$SQLTempDBDIR /SQLTEMPDBLOGDIR=$SQLTempDBLogDIR /SQLUSERDBDIR=$SQLUserDBDIR /SQLUSERDBLOGDIR=$SQLUserDBLogDIR /IACCEPTSQLSERVERLICENSETERMS /SECURITYMODE=SQL /SAPWD=$SAPWD /PID=$PID2014 /SQLSYSADMINACCOUNTS=$user
    }
	elseif ($SQLAccountL -and -not $SQLAccountP)
    {
    Set-location $c
	.\Setup.exe /QS /ACTION=Install /FEATURES=SQLENGINE,ADV_SSMS,CONN /UpdateEnabled=1 /UpdateSource=$InstallDrive`DBA\Updates /ERRORREPORTING=0 /INSTANCEDIR=$InstallationDIR /INSTANCEID=$InstanceName /INSTANCENAME=$InstanceName /SQMREPORTING=0 /SQLSVCACCOUNT=$SQLAccountL /AGTSVCACCOUNT=$SQLAccountL /AGTSVCSTARTUPTYPE="Automatic" /BROWSERSVCSTARTUPTYPE="Automatic" /INSTALLSQLDATADIR=$InstallationDIR /SQLBACKUPDIR=$SQLBackupDIR /SQLCOLLATION=$collation /SQLSVCSTARTUPTYPE="Automatic" /SQLTEMPDBDIR=$SQLTempDBDIR /SQLTEMPDBLOGDIR=$SQLTempDBLogDIR /SQLUSERDBDIR=$SQLUserDBDIR /SQLUSERDBLOGDIR=$SQLUserDBLogDIR /IACCEPTSQLSERVERLICENSETERMS /SECURITYMODE=SQL /SAPWD=$SAPWD /PID=$PID2014 /SQLSYSADMINACCOUNTS=$user
    }
	elseif ($SQLAccountL -and $SQLAccountP)
	{
    Set-location $c
	.\Setup.exe /QS /ACTION=Install /FEATURES=SQLENGINE,ADV_SSMS,CONN /UpdateEnabled=1 /UpdateSource=$InstallDrive`DBA\Updates /ERRORREPORTING=0 /INSTANCEDIR=$InstallationDIR /INSTANCEID=$InstanceName /INSTANCENAME=$InstanceName /SQMREPORTING=0 /SQLSVCACCOUNT=$SQLAccountL /AGTSVCACCOUNT=$SQLAccountL /SQLSVCPASSWORD=$SQLAccountP /AGTSVCPASSWORD=$SQLAccountP /AGTSVCSTARTUPTYPE="Automatic" /BROWSERSVCSTARTUPTYPE="Automatic" /INSTALLSQLDATADIR=$InstallationDIR /SQLBACKUPDIR=$SQLBackupDIR /SQLCOLLATION=$collation /SQLSVCSTARTUPTYPE="Automatic" /SQLTEMPDBDIR=$SQLTempDBDIR /SQLTEMPDBLOGDIR=$SQLTempDBLogDIR /SQLUSERDBDIR=$SQLUserDBDIR /SQLUSERDBLOGDIR=$SQLUserDBLogDIR /IACCEPTSQLSERVERLICENSETERMS /SECURITYMODE=SQL /SAPWD=$SAPWD /PID=$PID2014 /SQLSYSADMINACCOUNTS=$user
	}
	
	$date = Get-Date -format "yyyy-MM-dd HH:mm:ss" 
	Write-Output "$date SQL Server installation completed"
	
}
elseif ($version -eq "2012")
{
	if (-not $SQLAccountL -and -not $SQLAccountP)
    {
    Set-location $c
	.\Setup.exe /QS /ACTION=Install /FEATURES=SQLENGINE,ADV_SSMS,CONN /UpdateEnabled=1 /UpdateSource=$InstallDrive`DBA\Updates /ERRORREPORTING=0 /INSTANCEDIR=$InstallationDIR /INSTANCEID=$InstanceName /INSTANCENAME=$InstanceName /SQMREPORTING=0 /SQLSVCACCOUNT=$SQLSVCACCOUNT /AGTSVCACCOUNT=$AGTSVCACCOUNT /AGTSVCSTARTUPTYPE="Automatic" /BROWSERSVCSTARTUPTYPE="Automatic" /INSTALLSQLDATADIR=$InstallationDIR /SQLBACKUPDIR=$SQLBackupDIR /SQLCOLLATION=$collation /SQLSVCSTARTUPTYPE="Automatic" /SQLTEMPDBDIR=$SQLTempDBDIR /SQLTEMPDBLOGDIR=$SQLTempDBLogDIR /SQLUSERDBDIR=$SQLUserDBDIR /SQLUSERDBLOGDIR=$SQLUserDBLogDIR /IACCEPTSQLSERVERLICENSETERMS /SECURITYMODE=SQL /SAPWD=$SAPWD /PID=$PID2012 /SQLSYSADMINACCOUNTS=$user
    }
	elseif ($SQLAccountL -and -not $SQLAccountP)
    {
    Set-location $c
	.\Setup.exe /QS /ACTION=Install /FEATURES=SQLENGINE,ADV_SSMS,CONN /UpdateEnabled=1 /UpdateSource=$InstallDrive`DBA\Updates /ERRORREPORTING=0 /INSTANCEDIR=$InstallationDIR /INSTANCEID=$InstanceName /INSTANCENAME=$InstanceName /SQMREPORTING=0 /SQLSVCACCOUNT=$SQLAccountL /AGTSVCACCOUNT=$SQLAccountL /AGTSVCSTARTUPTYPE="Automatic" /BROWSERSVCSTARTUPTYPE="Automatic" /INSTALLSQLDATADIR=$InstallationDIR /SQLBACKUPDIR=$SQLBackupDIR /SQLCOLLATION=$collation /SQLSVCSTARTUPTYPE="Automatic" /SQLTEMPDBDIR=$SQLTempDBDIR /SQLTEMPDBLOGDIR=$SQLTempDBLogDIR /SQLUSERDBDIR=$SQLUserDBDIR /SQLUSERDBLOGDIR=$SQLUserDBLogDIR /IACCEPTSQLSERVERLICENSETERMS /SECURITYMODE=SQL /SAPWD=$SAPWD /PID=$PID2012 /SQLSYSADMINACCOUNTS=$user
	    }
	elseif ($SQLAccountL -and $SQLAccountP)
	{
    Set-location $c
	.\Setup.exe /QS /ACTION=Install /FEATURES=SQLENGINE,ADV_SSMS,CONN /UpdateEnabled=1 /UpdateSource=$InstallDrive`DBA\Updates /ERRORREPORTING=0 /INSTANCEDIR=$InstallationDIR /INSTANCEID=$InstanceName /INSTANCENAME=$InstanceName /SQMREPORTING=0 /SQLSVCACCOUNT=$SQLAccountL /AGTSVCACCOUNT=$SQLAccountL /SQLSVCPASSWORD=$SQLAccountP /AGTSVCPASSWORD=$SQLAccountP /AGTSVCSTARTUPTYPE="Automatic" /BROWSERSVCSTARTUPTYPE="Automatic" /INSTALLSQLDATADIR=$InstallationDIR /SQLBACKUPDIR=$SQLBackupDIR /SQLCOLLATION=$collation /SQLSVCSTARTUPTYPE="Automatic" /SQLTEMPDBDIR=$SQLTempDBDIR /SQLTEMPDBLOGDIR=$SQLTempDBLogDIR /SQLUSERDBDIR=$SQLUserDBDIR /SQLUSERDBLOGDIR=$SQLUserDBLogDIR /IACCEPTSQLSERVERLICENSETERMS /SECURITYMODE=SQL /SAPWD=$SAPWD /PID=$PID2012 /SQLSYSADMINACCOUNTS=$user
	}
	$date = Get-Date -format "yyyy-MM-dd HH:mm:ss" 
	Write-Output "$date SQL Server installation completed"
}
elseif ($version -eq "2008R2")
{
	if (-not $SQLAccountL -and -not $SQLAccountP)
    {
    Set-location $c
	.\Setup.exe /QS /ACTION=Install /FEATURES=SQLENGINE,ADV_SSMS,CONN /ERRORREPORTING=0 /INSTANCEDIR=$InstallationDIR /INSTANCEID=$InstanceName /INSTANCENAME=$InstanceName /SQMREPORTING=0 /SQLSVCACCOUNT=$SQLSVCACCOUNT /AGTSVCACCOUNT=$AGTSVCACCOUNT /AGTSVCSTARTUPTYPE="Automatic" /BROWSERSVCSTARTUPTYPE="Automatic" /INSTALLSQLDATADIR=$InstallationDIR /SQLBACKUPDIR=$SQLBackupDIR /SQLCOLLATION=$collation /SQLSVCSTARTUPTYPE="Automatic" /SQLTEMPDBDIR=$SQLTempDBDIR /SQLTEMPDBLOGDIR=$SQLTempDBLogDIR /SQLUSERDBDIR=$SQLUserDBDIR /SQLUSERDBLOGDIR=$SQLUserDBLogDIR /IACCEPTSQLSERVERLICENSETERMS /SECURITYMODE=SQL /SAPWD=$SAPWD /PID=$PID2008 /SQLSYSADMINACCOUNTS=$user
    }
	elseif ($SQLAccountL -and -not $SQLAccountP)
    {
    Set-location $c
	.\Setup.exe /QS /ACTION=Install /FEATURES=SQLENGINE,ADV_SSMS,CONN /ERRORREPORTING=0 /INSTANCEDIR=$InstallationDIR /INSTANCEID=$InstanceName /INSTANCENAME=$InstanceName /SQMREPORTING=0 /SQLSVCACCOUNT=$SQLAccountL /AGTSVCACCOUNT=$SQLAccountL /AGTSVCSTARTUPTYPE="Automatic" /BROWSERSVCSTARTUPTYPE="Automatic" /INSTALLSQLDATADIR=$InstallationDIR /SQLBACKUPDIR=$SQLBackupDIR /SQLCOLLATION=$collation /SQLSVCSTARTUPTYPE="Automatic" /SQLTEMPDBDIR=$SQLTempDBDIR /SQLTEMPDBLOGDIR=$SQLTempDBLogDIR /SQLUSERDBDIR=$SQLUserDBDIR /SQLUSERDBLOGDIR=$SQLUserDBLogDIR /IACCEPTSQLSERVERLICENSETERMS /SECURITYMODE=SQL /SAPWD=$SAPWD /PID=$PID2008 /SQLSYSADMINACCOUNTS=$user
	    }
	elseif ($SQLAccountL -and $SQLAccountP)
	{
    Set-location $c
	.\Setup.exe /QS /ACTION=Install /FEATURES=SQLENGINE,ADV_SSMS,CONN /ERRORREPORTING=0 /INSTANCEDIR=$InstallationDIR /INSTANCEID=$InstanceName /INSTANCENAME=$InstanceName /SQMREPORTING=0 /SQLSVCACCOUNT=$SQLAccountL /AGTSVCACCOUNT=$SQLAccountL /SQLSVCPASSWORD=$SQLAccountP /AGTSVCPASSWORD=$SQLAccountP /AGTSVCSTARTUPTYPE="Automatic" /BROWSERSVCSTARTUPTYPE="Automatic" /INSTALLSQLDATADIR=$InstallationDIR /SQLBACKUPDIR=$SQLBackupDIR /SQLCOLLATION=$collation /SQLSVCSTARTUPTYPE="Automatic" /SQLTEMPDBDIR=$SQLTempDBDIR /SQLTEMPDBLOGDIR=$SQLTempDBLogDIR /SQLUSERDBDIR=$SQLUserDBDIR /SQLUSERDBLOGDIR=$SQLUserDBLogDIR /IACCEPTSQLSERVERLICENSETERMS /SECURITYMODE=SQL /SAPWD=$SAPWD /PID=$PID2008 /SQLSYSADMINACCOUNTS=$user
	}

	$date = Get-Date -format "yyyy-MM-dd HH:mm:ss" 
	Write-Output "$date SQL Server installation completed"
}

