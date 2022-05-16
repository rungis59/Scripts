# **********************************************************************************
# *           			 SCRIPT DE CONFIGURATION ORACLE 				           *
# **********************************************************************************
# ----------------------------------------------------------------------------------
# Création par RCA 26/04/2018 	- Création du script
# Modification par RCA 16/05/2019 - Adaptation du script pour Oracle 12cR2
# ----------------------------------------------------------------------------------
# OBJECTIF - Configure Oracle en creant le listener, le tnsnames et l'init si X3 est deja installe
# !!! NE PAS OUBLIER DE COPIER LE FICHIER NETCA12.RSP dans $ORACLE_BASE

# Variable ORACLE_BASE : Chemin du répertoire Oracle
# Variable ORACLE_SID : Sid de l’instance Oracle
# Variable ALIASNET8 : Aliasnet8 de l’instance Oracle
# Variable SageDir : Repertoire des scripts Sage
# Variable Port : Port Oracle
# Variable ORACLE_HOME : Chemin du répertoire Oracle
# Variable tnsnames : Chemin du fichier tnsnames.ora
# Variable listener : Chemin du fichier listener.ora
# Variable sqlnet : Chemin du fichier sqlnet.ora
# Variable init : Chemin du fichier init.ora
# Variable ValueTNS : Contenu du fichier tnsnames.ora
# Variable ValueLSN : Contenu du fichier listener.ora


$ORACLE_BASE = "C:\Oracle"
$ORACLE_SID = "X112"
$ALIASNET8 = "X112"
$SageDir = "E:\Sage\X3U12\database\scripts"
$Port = "1521"

$ORACLE_HOME = $ORACLE_BASE+"\product\12.2.0\dbhome_1"
$hostname = hostname
$tnsnames = $ORACLE_HOME+"\NETWORK\ADMIN\tnsnames.ora"
$listener = $ORACLE_HOME+"\NETWORK\ADMIN\listener.ora"
$sqlnet = $ORACLE_HOME+"\NETWORK\ADMIN\sqlnet.ora"
$init = $ORACLE_HOME+"\database\init"+$ORACLE_SID+".ora"
$ValueTNS = "
ORACLR_CONNECTION_DATA =
  (DESCRIPTION =
    (ADDRESS_LIST =
      (ADDRESS = (PROTOCOL = IPC)(KEY = EXTPROC1521))
    )
    (CONNECT_DATA =
      (SID = CLRExtProc)
      (PRESENTATION = RO)
    )
  )

$ALIASNET8 = 
  (DESCRIPTION =
    (ADDRESS_LIST =
      (ADDRESS = (PROTOCOL = TCP)(HOST = $hostname)(port = $Port))
    )
    (CONNECT_DATA =
      (SID = $ORACLE_SID)
	  )
	  )"
$ValueLSN = "
SID_LIST_LISTENER =
  (SID_LIST =
    (SID_DESC =
      (SID_NAME = CLRExtProc)
      (ORACLE_HOME = $ORACLE_HOME)
      (PROGRAM = extproc)
      (ENVS = ""EXTPROC_DLLS=ONLY:$ORACLE_HOME\bin\oraclr12.dll"")
    )
		(SID_DESC =
        (SID_NAME = $ORACLE_SID)
        (ORACLE_HOME = $ORACLE_HOME)
  )
  )

LISTENER =
  (DESCRIPTION_LIST =
    (DESCRIPTION =
      (ADDRESS = (PROTOCOL = TCP)(HOST = $hostname)(PORT = $Port))
      (ADDRESS = (PROTOCOL = IPC)(KEY = EXTPROC1521))
    )
  )"

#Configuration d'Oracle
netca /silent /responsefile $ORACLE_BASE\netca12.rsp

#Personnalise le fichier tnsnames.ora
If(!(Test-Path -Path $tnsnames))
{New-Item -ItemType File -Path $tnsnames
Add-Content -Path $tnsnames -Value $ValueTNS}
else { 
Clear-content -Path $tnsnames
Add-Content -Path $tnsnames -Value $ValueTNS}

#Personnalise le fichier listener.ora
If(!(Test-Path -Path $listener))
{New-Item -ItemType File -Path $listener
Add-Content -Path $listener -Value $ValueLSN}
else { 
Clear-content -Path $listener
Add-Content -Path $listener -Value $ValueLSN}

#Personnalise le fichier sqlnet.ora
$data = Get-Content -Path $sqlnet
$data | Foreach {
    $items = $_.split("=")
    if ($items[0] -match "SQLNET.AUTHENTICATION_SERVICES" -and $items[1] -match "NTS") 
    {$data -replace 'NTS', 'NONE' | Set-Content -Path $sqlnet
     }
                }
Add-Content -Path $sqlnet -Value "SQLNET.ALLOWED_LOGON_VERSION_CLIENT=8
SQLNET.ALLOWED_LOGON_VERSION_SERVER=8"

#Creation du init
If((Test-Path -Path $SageDir))
{New-Item -ItemType File -Path $init
Add-Content -Path $init -Value "spfile=""$SageDir\spfile$ORACLE_SID.ora"""}

#Redemarrage du listener
stop-service OracleOraDB12Home1TNSListener
start-service OracleOraDB12Home1TNSListener
