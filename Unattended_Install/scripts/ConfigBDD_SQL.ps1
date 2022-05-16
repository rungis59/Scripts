param(
[Parameter(Position=0,mandatory=$true)]
[string]$REPLOG,
[Parameter(Position=1,mandatory=$true)]
[string]$RepXML
) 

Start-Transcript -path $replog\ConfigBDD_SQL.log -append

echo "Définition des variables"
set-location $RepXML
.\Variables.ps1 $REPLOG $RepXML

$varFile = [environment]::GetEnvironmentVariable("VarGlo", "User")

. $varFile

echo "
Démarrage de la configuration de la base de données $date

Génération du fichier - database_CrDb.bat"

$database_CrDb_bat = "
  
@echo off
if exist ${database.adonix.sqldirscr}\database_CrDb.end del ${database.adonix.sqldirscr}\database_CrDb.end

     ""${database.software.sqlodbctools}\Binn\sqlcmd.exe"" -S $servername\$solutionname -U ${database.software.sqlinternallogin} -d master -i ${database.adonix.sqldirscr}\database_CrDb.sql -o ${database.adonix.dbdirtra}\database_CrDb.log -P ${database.software.sqlinternalpwd}
Echo database_CrDb.bat > ${database.adonix.sqldirscr}\database_CrDb.end
"

Set-Content -Path ${database.adonix.sqldirscr}\database_CrDb.bat -Value $database_CrDb_bat

echo "
Génération du fichier - database_CrDb.sql"

$database_CrDb_sql = "USE master
GO

CREATE DATABASE [${database.adonix.sqlbase}] 
ON
( NAME = [${database.adonix.sqlbase}_data],
  FILENAME='${database.adonix.sqldirdat}\${database.adonix.sqlbase}_data.mdf',
  SIZE=2000MB,
  MAXSIZE=UNLIMITED,
  FILEGROWTH=10% )
LOG ON
( NAME = [${database.adonix.sqlbase}_log],
  FILENAME='${database.adonix.sqldirlog}\${database.adonix.sqlbase}_log.ldf',
  SIZE=1000MB,
  MAXSIZE=UNLIMITED,
  FILEGROWTH=10% )
COLLATE Latin1_general_BIN 

GO

alter database [${database.adonix.sqlbase}] set read_committed_snapshot on
"

Set-Content -Path ${database.adonix.sqldirscr}\database_CrDb.sql -Value $database_CrDb_sql

echo "
Fin de la génération de scripts

Début de la vérification des pré-requis"

$ErrorActionPreference="SilentlyContinue"
$InvokeSQL = get-command Invoke-Sqlcmd

if (-not $InvokeSQL)
{echo 'Pré-requis non respecté : veuillez installer Windows PowerShell Extensions for Microsoft SQL Server'
break
}

if(!(Test-Path -Path ${database.adonix.sqldirdat})){
New-Item -ItemType "Directory" -path ${database.adonix.sqldirdat}
}

if(!(Test-Path -Path ${database.adonix.sqldirlog})){
New-Item -ItemType "Directory" -path ${database.adonix.sqldirlog}
}

$ErrorActionPreference = "Continue"

echo "
Fin de la vérification des pré-requis

Début de la vérification de l'utilisateur SysAdmin:  ${database.software.sqlinternallogin}"

$Error.Clear()
Invoke-Sqlcmd -ServerInstance $servername\$solutionname -Username ${database.software.sqlinternallogin} -Password ${database.software.sqlinternalpwd} -Query "SELECT GETDATE() AS TimeOfQuery" | out-null
If ($Error.Count -ne 0){
    echo "Connection failed 
    $error[0]"
    break
    }

echo "Fin de la vérification de l'utilisateur ${database.software.sqlinternallogin}

Début de l'exécution des scripts

Exécution du script - database_CrDb.bat"

cd ${database.adonix.sqldirscr}
.\database_CrDb.bat

echo "Please see traces, file ${database.adonix.dbdirtra}\database_CrDb.log above

Fin de l'exécution des scripts

Début de la vérification de la base de données"

if (${database.software.dbver} -eq "14")
{
	$DS = Invoke-Sqlcmd -ServerInstance $servername\$solutionname -Username ${database.software.sqlinternallogin} -Password ${database.software.sqlinternalpwd} -Query "SELECT state_desc FROM sys.databases where name='${database.adonix.sqlbase}'" -As DataSet
	$DSresult = $DS.Tables[0].Rows | ForEach-Object { echo $_.state_desc }

		if ($DSresult -eq 'ONLINE')
		{echo "
		La vérification de la base de données a réussie."
		echo "
		${database.adonix.sqlbase} $DSresult"
		}

		else {echo "
		La vérification de la base de données a échouée."
		echo "
		${database.adonix.sqlbase} $DSresult"
		break
			}
}

echo "
Début de la mise à jour du fichier adxinstalls"

[xml]$myXML = Get-Content $AdxRep\inst\adxinstalls.xml -Encoding utf8

($myXML.install.module | where { $_.type -eq "SQLSERVER" -and $_.family -eq "DATABASE" }).'component.database.installstatus' = 'active'
($myXML.install.module | where { $_.type -eq "SQLSERVER" -and $_.family -eq "DATABASE" }).'component.database.servername' = ${software.adonix.solutionsrv}
($myXML.install.module | where { $_.type -eq "SQLSERVER" -and $_.family -eq "DATABASE" }).'database.adonix.sqlbase' = ${database.adonix.sqlbase}
($myXML.install.module | where { $_.type -eq "SQLSERVER" -and $_.family -eq "DATABASE" }).'database.adonix.sqlinstance' = $solutionname
($myXML.install.module | where { $_.type -eq "SQLSERVER" -and $_.family -eq "DATABASE" }).'database.adonix.sqlsizdat' = ${database.adonix.sqlsizdat}
($myXML.install.module | where { $_.type -eq "SQLSERVER" -and $_.family -eq "DATABASE" }).'database.adonix.sqlsizlog' = ${database.adonix.sqlsizlog}
($myXML.install.module | where { $_.type -eq "SQLSERVER" -and $_.family -eq "DATABASE" }).'database.software.dbhome' = ${database.software.dbhome}
($myXML.install.module | where { $_.type -eq "SQLSERVER" -and $_.family -eq "DATABASE" }).'database.software.dbver' = ${database.software.dbver}
($myXML.install.module | where { $_.type -eq "SQLSERVER" -and $_.family -eq "DATABASE" }).'database.software.sqlinternalpwd' = ${database.software.sqlinternalpwd}

$sqlfolderpwd = Select-String -Path $AdxRep\inst\adxinstalls.xml -Pattern 'database.software.sqlfolderpwd'
    if (-not $sqlfolderpwd)
    {
    $child = $myXML.CreateElement("database.software.sqlfolderpwd", $myXML.install.NamespaceURI)
    $child.InnerXml = ${database.software.sqlfolderpwd}
    $null = ($myXML.install.module | where { $_.type -eq "SQLSERVER" -and $_.family -eq "DATABASE" }).appendchild($child)
    }
        else {
            ($myXML.install.module | where { $_.type -eq "SQLSERVER" -and $_.family -eq "DATABASE" }).'database.software.sqlfolderpwd' = ${database.software.sqlfolderpwd}
             }

$sqlinternallogin = Select-String -Path $AdxRep\inst\adxinstalls.xml -Pattern 'database.software.sqlinternallogin'
    if (-not $sqlinternallogin)
    {
    $child2 = $myXML.CreateElement("database.software.sqlinternallogin", $myXML.install.NamespaceURI)
    $child2.InnerXml = ${database.software.sqlinternallogin}
    $null2 = ($myXML.install.module | where { $_.type -eq "SQLSERVER" -and $_.family -eq "DATABASE" }).appendchild($child2) 
    }
    else {
        ($myXML.install.module | where { $_.type -eq "SQLSERVER" -and $_.family -eq "DATABASE" }).'database.software.sqlinternallogin' = ${database.software.sqlinternallogin}
         }

$sqlodbctools = Select-String -Path $AdxRep\inst\adxinstalls.xml -Pattern 'database.software.sqlodbctools'
    if (-not $sqlodbctools)
    {
    $child3 = $myXML.CreateElement("database.software.sqlodbctools", $myXML.install.NamespaceURI)
    $child3.InnerXml = ${database.software.sqlodbctools}
    $null3 = ($myXML.install.module | where { $_.type -eq "SQLSERVER" -and $_.family -eq "DATABASE" }).appendchild($child3) 
     }
        else {
            ($myXML.install.module | where { $_.type -eq "SQLSERVER" -and $_.family -eq "DATABASE" }).'database.software.sqlodbctools' = ${database.software.sqlodbctools}
             }

$myXML.Save("$AdxRep\inst\adxinstalls.xml")

echo "
Fin de la mise à jour du fichier adxinstall

Début de la mise à jour de la solution"

cp $RepXML\solution.xml $RepDossiers

[xml]$myXML = Get-Content $RepDossiers\solution.xml -Encoding utf8

($myXML.solution.module | where { $_.type -eq "SQLSERVER" -and $_.family -eq "DATABASE" }).'component.database.name' = $solutionname
($myXML.solution.module | where { $_.type -eq "SQLSERVER" -and $_.family -eq "DATABASE" }).'component.database.path' = $databasePath
($myXML.solution.module | where { $_.type -eq "SQLSERVER" -and $_.family -eq "DATABASE" }).'component.database.servername' = ${software.adonix.solutionsrv}
($myXML.solution.module | where { $_.type -eq "SQLSERVER" -and $_.family -eq "DATABASE" }).'database.adonix.dbdirtra' = ${database.adonix.dbdirtra}
($myXML.solution.module | where { $_.type -eq "SQLSERVER" -and $_.family -eq "DATABASE" }).'database.adonix.sqlbase' = ${database.adonix.sqlbase}
($myXML.solution.module | where { $_.type -eq "SQLSERVER" -and $_.family -eq "DATABASE" }).'database.adonix.sqldirdat' = ${database.adonix.sqldirdat}
($myXML.solution.module | where { $_.type -eq "SQLSERVER" -and $_.family -eq "DATABASE" }).'database.adonix.sqldirlog' = ${database.adonix.sqldirlog}
($myXML.solution.module | where { $_.type -eq "SQLSERVER" -and $_.family -eq "DATABASE" }).'database.adonix.sqldirscr' = ${database.adonix.sqldirscr}
($myXML.solution.module | where { $_.type -eq "SQLSERVER" -and $_.family -eq "DATABASE" }).'database.adonix.sqlinstance' = $solutionname
($myXML.solution.module | where { $_.type -eq "SQLSERVER" -and $_.family -eq "DATABASE" }).'database.adonix.sqlsizdat' = ${database.adonix.sqlsizdat}
($myXML.solution.module | where { $_.type -eq "SQLSERVER" -and $_.family -eq "DATABASE" }).'database.adonix.sqlsizlog' = ${database.adonix.sqlsizlog}
($myXML.solution.module | where { $_.type -eq "SQLSERVER" -and $_.family -eq "DATABASE" }).'database.software.dbhome' = ${database.software.dbhome}
($myXML.solution.module | where { $_.type -eq "SQLSERVER" -and $_.family -eq "DATABASE" }).'database.software.dbver' = ${database.software.dbver}
($myXML.solution.module | where { $_.type -eq "SQLSERVER" -and $_.family -eq "DATABASE" }).'database.software.sqlfolderpwd' = ${database.software.sqlfolderpwd}
($myXML.solution.module | where { $_.type -eq "SQLSERVER" -and $_.family -eq "DATABASE" }).'database.software.sqlinternallogin' = ${database.software.sqlinternallogin}
($myXML.solution.module | where { $_.type -eq "SQLSERVER" -and $_.family -eq "DATABASE" }).'database.software.sqlinternalpwd' = ${database.software.sqlinternalpwd}
($myXML.solution.module | where { $_.type -eq "SQLSERVER" -and $_.family -eq "DATABASE" }).'database.software.sqlodbctools' = ${database.software.sqlodbctools}

$myXML.Save("$RepDossiers\solution.xml")

echo "
Fin de la mise à jour de la solution"
$date = Get-Date -format "dd/MM/yyyy HH:mm:ss"
echo "
Fin de la configuration $date

Lancement de la configuration de l'application"

Stop-Transcript

set-location $RepXML
.\ConfigApplication.ps1 $REPLOG $RepXML

