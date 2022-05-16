# **********************************************************************************
# *            SCRIPT DE SAUVEGARDE A CHAUD - METHODE RMAN 			               *
# **********************************************************************************
# ----------------------------------------------------------------------------------
# Création par JG 04/12/2014 		- Création du script
# Modification par JG 01/07/2015 	- Ajout du /FFT pour la compatibilité avec les NAS
# Modification par RCA 26/03/18		- Passage en powershell
# Modification par RCA 19/04/18 	- Utilisation de variables globales
# ----------------------------------------------------------------------------------
# OBJECTIF - Effectue la sauvegarde à chaud avec la commande RMAN - Compatible Oracle 10G/11G/12C

# Variable LOG : Nom du log de la sauvegarde à chaud
# Variable LOGRMAN : Nom du log de la sauvegarde RMAN
# Variable PWDORACLE : Mot de passe de l’utilisateur SYSTEM
# Variable PWDSYSTEM : Mot de passe de l’utilisateur SYS
# Variable NLS_LANG : Permet à RMAN d'afficher correctement les caractères
# Variable NLS_DATE_FORMAT : Permet à RMAN d'afficher correctement la date

# NOTE : le controlfile n'est plus copié par ce script mais dans le script RMAN à la fin de la sauvegarde.

$varFile = [environment]::GetEnvironmentVariable("VarSvg", "User")

. $varFile

#Lancer le script PRE REQUIS.ps1 au préalable
$AESKey2 = Get-Content $AESKeyFilePath2
$pwdTxt2 = Get-Content $credentialFilePath2
If ($pwdTxt2 -eq $null)
{exit}
$securePwd2 = $pwdTxt2 | ConvertTo-SecureString -Key $AESKey2
$credential2 = New-Object System.Management.Automation.PSCredential -ArgumentList $username2, $securePwd2

$AESKey3 = Get-Content $AESKeyFilePath3
$pwdTxt3 = Get-Content $credentialFilePath3
If ($pwdTxt3 -eq $null)
{exit}
$securePwd3 = $pwdTxt3 | ConvertTo-SecureString -Key $AESKey3
$credential3 = New-Object System.Management.Automation.PSCredential -ArgumentList $username3, $securePwd3

# GESTION LOG ET RÉPERTOIRE
$LOG = "K_svgchaud.log"
$LOGRMAN = "K_RMAN.log"

# GESTION ORACLE
$PWDORACLE = $credential2.GetNetworkCredential().Password
$PWDSYSTEM = $credential3.GetNetworkCredential().Password

# RMAN CONFIGURATION
$NLS_LANG = "american_america"
$NLS_DATE_FORMAT = "DD/MM/YYYY-HH24:mi:ss"

# EXPORT DATAPUMP
$strExportExe = $ORACLE_HOME+"\BIN\expdp.exe"
$strArguments = "$useroracle/$pwdoracle FULL=Y REUSE_DUMPFILES=Y DIRECTORY=$EXPORTORA DUMPFILE=$EXPORTFILE.dmp logfile=$EXPORTFILE.log FLASHBACK_TIME=\""TO_TIMESTAMP(to_char(sysdate,'dd/mm/yyyyhh24-mi-ss'),'dd/mm/yyyy hh24-mi-ss')\"""

# 7zip
if ($SVGDEST)
{$strArguments2 = "a -t7z -m0=LZMA2 -mx=1 -mmt=12 $SVGDEST`RMAN.7z $SVGBACKUPRMAN"
$strStdOut2 = $REPLOG+"StdOut7zip.log"
$strStdErr2 = $REPLOG+"StdErr7zip.log"}

$date = Get-date -Format g

# -- DEBUT ROTATION DES FICHIERS DE LOGS DE LA SAUVEGARDE --
Remove-Item $REPLOG$LOG'.5' -ErrorAction SilentlyContinue
Rename-Item -Path $REPLOG$LOG'.4' -NewName $LOG'.5' -ErrorAction SilentlyContinue
Rename-Item -Path $REPLOG$LOG'.3' -NewName $LOG'.4' -ErrorAction SilentlyContinue
Rename-Item -Path $REPLOG$LOG'.2' -NewName $LOG'.3' -ErrorAction SilentlyContinue
Rename-Item -Path $REPLOG$LOG'.1' -NewName $LOG'.2' -ErrorAction SilentlyContinue
Rename-Item -Path $REPLOG$LOG -NewName $LOG'.1' -ErrorAction SilentlyContinue

Remove-Item $REPLOG$LOGRMAN'.5'  -ErrorAction SilentlyContinue
Rename-Item -Path $REPLOG$LOGRMAN'.4' -NewName $LOGRMAN'.5' -ErrorAction SilentlyContinue
Rename-Item -Path $REPLOG$LOGRMAN'.3' -NewName $LOGRMAN'.4' -ErrorAction SilentlyContinue
Rename-Item -Path $REPLOG$LOGRMAN'.2' -NewName $LOGRMAN'.3' -ErrorAction SilentlyContinue
Rename-Item -Path $REPLOG$LOGRMAN'.1' -NewName $LOGRMAN'.2' -ErrorAction SilentlyContinue
Rename-Item -Path $REPLOG$LOGRMAN  -NewName $LOGRMAN'.1' -ErrorAction SilentlyContinue
# -- FIN ROTATION DES FICHIERS DE LOGS DE LA SAUVEGARDE --

# -- DEBUT CREATION DES REPERTOIRES SI NON EXISTANT --
if(!(Test-Path -Path $SVGBACKUPRMAN)){
    New-Item -ItemType "Directory" -path $SVGBACKUPRMAN
}
if(!(Test-Path -Path $EXPORTREP)){
    New-Item -ItemType "Directory" -path $EXPORTREP
}
if ($SVGDEST)
{if(!(Test-Path -Path $SVGDEST))
	{
    New-Item -ItemType "Directory" -path $SVGDEST
	}
}
if ($ARCLOGDEST)
{if(!(Test-Path -Path $ARCLOGDEST))
	{
    New-Item -ItemType "Directory" -path $ARCLOGDEST
	}
}
# -- FIN CREATION DES REPERTOIRES SI NON EXISTANT --

echo $date >> $REPLOG$LOG 2>&1

echo "***************************************************************************************************" >> $REPLOG$LOG
echo "*                                                                                                 *" >> $REPLOG$LOG
echo "*                Rapport sauvegarde a chaud solution Sage X3 <Client>                             *" >> $REPLOG$LOG
echo "*                                                                                                 *" >> $REPLOG$LOG
echo "***************************************************************************************************" >> $REPLOG$LOG

# -- DEBUT EXPORT ORACLE --
echo "**********************************************************" >> $REPLOG$LOG
echo "* Export complet de la base Oracle $ORACLE_SID vers $EXPORTFILE *" >> $REPLOG$LOG
echo "**********************************************************" >> $REPLOG$LOG
# Version Oracle 10G
# del %EXPORTREP%\%EXPORTFILE%.dmp
# expdp %useroracle%/%pwdoracle%@%aliasnet8% full = Y directory = %ExportOra% dumpfile = %EXPORTFILE%.dmp logfile = %EXPORTFILE%.log FLASHBACK_TIME = \"TO_TIMESTAMP(to_char(sysdate,'dd/mm/yyyyhh24-mi-ss'),'dd/mm/yyyy hh24-mi-ss')\"

# Version Oracle 11G
# expdp $useroracle/$pwdoracle@$aliasnet8 full=Y REUSE_DUMPFILES=Y directory=$ExportOra dumpfile=$EXPORTFILE'.dmp' logfile=$EXPORTFILE'.log' FLASHBACK_TIME=\"TO_TIMESTAMP(to_char(sysdate,'dd/mm/yyyyhh24-mi-ss'),'dd/mm/yyyy hh24-mi-ss')\"

# Export DATAPUMP
$strProcess = Start-Process -filepath $strExportExe -ArgumentList $strArguments -wait -NoNewWindow -PassThru

$date = Get-date -Format g
echo "$date Export Oracle termine - voir $EXPORTFILE.log pour details" >> $REPLOG$LOG 2>&1
if ($SVGDEST)
{echo "********************************************************" >> $REPLOG$LOG
echo "* Copie du fichier d'export de la base vers $SVGDEST *" >> $REPLOG$LOG
echo "********************************************************" >> $REPLOG$LOG

Copy-Item $EXPORTREP$EXPORTFILE.* -destination $SVGDEST -Errorvariable err 
if ($err) {echo $err >> $REPLOG$LOG}
else {echo "Copie OK" >> $REPLOG$LOG}
}
# -- FIN EXPORT ORACLE --

# -- DEBUT SAUVEGARDE ORACLE --
echo "***********************************************************************************" >> $REPLOG$LOG 
echo "* Copie des fichiers lies à la base dans le repertoire ORACLE_HOME vers $SVGBACKUPRMAN *" >> $REPLOG$LOG 
echo "***********************************************************************************" >> $REPLOG$LOG
#  COPIE DES FICHIERS LIÉS À LA BASE DANS LE RÉPERTOIRE ORACLE_HOME VERS LE SERVEUR X3 (SVGBACKUPRMAN)
Copy-Item $ORACLE_HOME\database\*$ORACLE_SID* -destination $SVGBACKUPRMAN -Errorvariable err 
if ($err) {echo $err >> $REPLOG$LOG}
else {echo "Copie OK" >> $REPLOG$LOG}

echo "***************************************************" >> $REPLOG$LOG
echo "* Copie des fichiers SPFILE systeme vers $SVGBACKUPRMAN*" >> $REPLOG$LOG
echo "***************************************************" >> $REPLOG$LOG
#  COPIE DES FICHIERS SPFILE SYSTEME VERS LE SERVEUR DE STOCKAGE DISTANT (SVGBACKUPRMAN)
Copy-Item $SPFILE -destination $SVGBACKUPRMAN -Errorvariable err
if ($err) {echo $err >> $REPLOG$LOG}
else {echo "Copie OK" >> $REPLOG$LOG}

if ($ARCLOGDEST)
{echo "***************************************************" >> $REPLOG$LOG
echo "* Copie des archivelogs systeme vers $ARCLOGDEST *" >> $REPLOG$LOG
echo "***************************************************" >> $REPLOG$LOG 
# COPIE DES ARCHIVELOGS SYSTEME VERS LE SERVEUR DE STOCKAGE DISTANT DANS LE RÉPERTOIRE DES ARCHIVES LOGS (ARCLOGDEST)
# Version Windows 2003
# %ROBOCOPY% %ARCHIVELOGS% %ARCLOGDEST% /MIR /NP /e /sec /w:2 /r:2 >> $REPLOG$LOG 2>&1
# Version Windows 2008 et +
# JG 01/07/2015 - Ajout du /FFT pour la compatibilité avec les NAS. Aucune incidence de Windows to Windows
ROBOCOPY $ARCHIVELOGS $ARCLOGDEST /FFT /MIR /NP /MT:16 /e /sec /w:2 /r:2 >> $REPLOG$LOG 2>&1
}

$date = Get-date -Format g
echo "************************************************" >> $REPLOG$LOG
echo "* Sauvegarde RMAN de la base de données Oracle *" >> $REPLOG$LOG
echo "************************************************" >> $REPLOG$LOG 
echo "$date Sauvegarde Oracle RMAN en cours - voir $LOGRMAN pour details" >> $REPLOG$LOG 2>&1

rman target $USERSYS/$PWDSYSTEM cmdfile=$REP\$RMAN LOG=$REPLOG$LOGRMAN

$date = Get-date -Format g
echo "$date Sauvegarde Oracle RMAN terminee - voir $LOGRMAN pour details" >> $REPLOG$LOG 2>&1
# -- FIN SAUVEGARDE ORACLE --

# -- DEBUT DEPLACEMENT SAUVEGARDE ORACLE --
echo "***********************************************************" >> $REPLOG$LOG
echo "* Deplacement sauvegarde RMAN de la base de donnees Oracle *" >> $REPLOG$LOG
echo "***********************************************************" >> $REPLOG$LOG 
# Version Windows 2003
# %ROBOCOPY% %SVGBACKUPRMAN% %SVGDEST% /MIR /NP /e /sec /w:2 /r:2 >> $REPLOG$LOG 2>&1
# Version Windows 2008 et +
# JG 01/07/2015 - Ajout du /FFT pour la compatibilité avec les NAS. Aucune incident de Windows to Windows
# ROBOCOPY $SVGBACKUPRMAN $SVGDEST /FFT /MIR /NP /MT:16 /e /sec /w:2 /r:2 >> $REPLOG$LOG 2>&1
# BBU : Modification de la copie en compression pour amélioration réplication vers AIP (D2D)

if ($SVGDEST)
{$strProcess2 = Start-Process -Filepath $str7zipExe -ArgumentList $strArguments2 -wait -NoNewWindow -PassThru -RedirectStandardOutput $strStdOut2 -RedirectStandardError $strStdErr2}

echo "*******************************" >> $REPLOG$LOG 
echo "*     Fin de la sauvegarde    *" >> $REPLOG$LOG
echo "*******************************" >> $REPLOG$LOG

$date = Get-date -Format g
$date >> $REPLOG$LOG 2>&1
# -- FIN DEPLACEMENT SAUVEGARDE ORACLE --

# envoi en mail du rapport de sauvegarde.
cscript $REP\K_envoi_mail_svg_log_v3.vbs

timeout 10
