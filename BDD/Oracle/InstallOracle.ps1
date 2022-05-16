# **********************************************************************************
# *           				 SCRIPT D'INSTALLATION ORACLE  				           *
# **********************************************************************************
# ----------------------------------------------------------------------------------
# Création par RCA 26/04/2018 	- Création du script
# ----------------------------------------------------------------------------------
# OBJECTIF - Installe Oracle en mode silencieux a l'aide d'un fichier de reponse

# Variable ORACLE_BASE : Chemin du répertoire Oracle
# Variable str7zipExe : Chemin du programme 7Zip
# Variable REPSOURCES : Repertoire des sources Oracle
# Variable rspFile : Fichier de reponse
# Variable REPLOG : Repertoire contenant les logs
# Variable ORACLE_HOME : Chemin du répertoire Oracle
# Variable Dest : Repertoire ou on decompresse les archives ZIP d'install Oracle
# Variable registryPath : Cle de registre cree apres l'installation

# PRE REQUIS : Installer JRE
# !!! NE PAS OUBLIER DE COPIER LE FICHIER OracleInstall.RSP dans $ORACLE_BASE

$ORACLE_BASE = "C:\Oracle"
$str7zipExe = "C:\Program Files\7-Zip\7z.exe"
$REPSOURCES = "C:\Oracle\Sources"

$rspFile = $ORACLE_BASE+"\OracleInstall.rsp"
$REPLOG = $ORACLE_BASE+"\Logs\"
$ORACLE_HOME = $ORACLE_BASE+"\product\12.1.0\dbhome_1"
$hostname = hostname
$Dest = $REPSOURCES+"\Oracle_Database"
$registryPath = "HKLM:\SOFTWARE\ORACLE\KEY_OraDB12Home1" 

if(!(Test-Path -Path $Dest))
	{
    New-Item -ItemType "Directory" -path $Dest
	}

if(!(Test-Path -Path $REPLOG))
	{
    New-Item -ItemType "Directory" -path $REPLOG
	}
	
#Decompresse les archives ZIP d'install Oracle avec 7Zip dans le repertoire $Dest
Foreach ($Archive in Get-ChildItem $REPSOURCES\*.zip) {
$strArguments = "x $Archive -o$Dest -r -y"
$strStdOut = $REPLOG+"StdOut7zip.log"
$strStdErr = $REPLOG+"StdErr7zip.log"
$strProcess = Start-Process -Filepath $str7zipExe -ArgumentList $strArguments -wait -NoNewWindow -PassThru -RedirectStandardOutput $strStdOut -RedirectStandardError $strStdErr}

#Personnalise le fichier de reponse d'install Oracle
(Get-Content -Path $rspFile) | Foreach-Object {
    $_ -Replace "ORACLE_HOSTNAME=", "ORACLE_HOSTNAME=$hostname" `
       -Replace "ORACLE_HOME=", "ORACLE_HOME=$ORACLE_HOME" `
       -Replace "ORACLE_BASE=", "ORACLE_BASE=$ORACLE_BASE"
    } | Set-Content -Path $rspFile

#Installation d'Oracle
IF(!(Test-Path $registryPath))
{Set-location $Dest\database
.\setup.exe -silent -nowelcome -noconfig -nowait -responseFile $rspFile}

Stop-Process -Name "powershell"
