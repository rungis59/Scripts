# ********************************************************************************************
# *	  			SCRIPT DE PARAMETRAGE MEMOIRE ORACLE SANS LA SAUVEGARDE A CHAUD EN PLACE     *
# ********************************************************************************************
# ----------------------------------------------------------------------------------
# Creation par RCA 04/05/2018 	- Creation du script
# Modification par RCA 08/10/2018 - Ajout du fichier init si pas present
# ----------------------------------------------------------------------------------
# OBJECTIF - Configure Enterprise Manager Express + la memoire Oracle sans les scripts de sauvegarde a chaud

# Variable REPBIS : Repertoire contenant les scripts d'installation et de parametrage Oracle
# Variable REPLOG : Repertoire contenant les logs
# Variable pfileDest : Chemin contenant le pfile
# Variable alias : Aliasnet8 de l’instance Oracle
# Variable LOG : Nom du fichier log
# Variable init : Chemin du fichier init.ora
# Variable ORACLE_BASE : Chemin du répertoire Oracle

# PRE REQUIS: Lancer le script secure_password3.ps1 et Copier tous les SQL dans le repertoire Scripts_Install

$REPBIS = "E:\Kardol_Scripts\Scripts_Install"
$REPLOG = "E:\Kardol_Scripts\Scripts_Install\Logs\"
$pfileDest = "F:\oracle\pfile.ora"
$alias = "X112"
$ORACLE_SID = "X112"
$SageDir = "E:\Sage\KARDOLU11\database\scripts"
$ORACLE_BASE = "E:\Oracle"
$REP2 = (get-item $REPBIS).parent.FullName

$ORACLE_DATABASE = $ORACLE_BASE+"\product\19.3.0\dbhome_1\database\init*"
$ORACLE_HOME = $ORACLE_BASE+"\product\19.3.0\dbhome_1"
$init = $ORACLE_HOME+"\database\init"+$ORACLE_SID+".ora"

$spool = $REPBIS+"\spool.tmp"
$LOG = "ParametrageMemoire.log"

$AESKeyFilePath3 = $REP2+"\AES_key\key3.txt"
$credentialFilePath3 = $REP2+"\AES_key\cred_password3.txt"
$AESKey3 = Get-Content $AESKeyFilePath3
$pwdTxt3 = Get-Content $credentialFilePath3
$securePwd3 = $pwdTxt3 | ConvertTo-SecureString -Key $AESKey3
$USERSYS = "SYS"
$credential3 = New-Object System.Management.Automation.PSCredential -ArgumentList $USERSYS, $securePwd3
$PWDSYSTEM = $credential3.GetNetworkCredential().Password
$t = $host.ui.RawUI.ForegroundColor
$host.ui.RawUI.ForegroundColor = "Green"

If(!(Test-Path -Path $ORACLE_DATABASE)){
	If((Test-Path -Path $SageDir))
	{New-Item -ItemType File -Path $init
	Add-Content -Path $init -Value "spfile=""$SageDir\spfile$ORACLE_SID.ora"""
	}
}

If(!(Test-Path -Path $REPLOG)){
    New-Item -ItemType "Directory" -path $REPLOG
}

$date = Get-date -Format g
echo $date >> $REPLOG$LOG

#Recuperation du chemin du spfile utilise
sqlplus $USERSYS/$PWDSYSTEM@$alias as sysdba @$REPBIS\spfile.sql $spool >> $REPLOG$LOG

$spileOriginal = (Get-content -path $spool).Trim()
$spfile = (Get-content -path $spool).Trim()
$spfileDir = (Get-item $spfile).Directory.FullName

Write-Output "Copie du spfile $spileOriginal"
If (Test-Path $spfile) 
{       $i = 0
    While (Test-Path $spfile) 
    {   $i += 1
        $spfile = $spfileDir+"\SPFILE"+$i+".ORA"
    }
}
Copy-Item -Path $spileOriginal -Destination $spfile -Force

Write-Output "Creation du pfile"
sqlplus $USERSYS/$PWDSYSTEM@$alias as sysdba @$REPBIS\pfile.sql $pfileDest >> $REPLOG$LOG

Write-Output "Suppression des en-têtes *x112__* et du paramètre memory_target"
$CleanPfile = Get-content $pfileDest | Select-string -pattern '^[x112]' -notmatch | Select-string -pattern 'memory_target' -notmatch | Select-string -pattern 'memory_max_target' -notmatch
Set-content -Path $pfileDest -Value $CleanPfile
#Mise en place d’Enterprise Manager Express
Add-Content -Path $pfileDest -Value "
dispatchers='(PROTOCOL=TCP)(SERVICE=$alias`XDB)'"

Write-Output "Redemarrage de la base avec le nouveau pfile"
$host.ui.RawUI.ForegroundColor = $t
sqlplus $USERSYS/$PWDSYSTEM@$alias as sysdba @$REPBIS\restart_database.sql $pfileDest

#Redemarrage du listener
stop-service OracleOraDB19Home1TNSListener
start-service OracleOraDB19Home1TNSListener

$host.ui.RawUI.ForegroundColor = "Green"
Write-Output "Creation du spfile et redemarrage de la base"
$host.ui.RawUI.ForegroundColor = $t
sqlplus $USERSYS/$PWDSYSTEM@$alias as sysdba @$REPBIS\NewSpfile.sql $pfileDest $spileOriginal

$host.ui.RawUI.ForegroundColor = "Green"
Write-Output "Ajustement parametres memoire
---------------------------------------------------------------------------------------------"
$pga = Read-Host "Merci de renseigner la pga_aggregate_target (en Mo)"
$pga = $pga+"M"
$db_cache = Read-Host "Merci de renseigner la db_cache_size (en Mo)"
$db_cache = $db_cache+"M"
$sga = Read-Host "Merci de renseigner la sga_target (en Mo)"
$sga = $sga+"M"
$shared = Read-Host "Merci de renseigner la shared pool (en Mo)"
$shared = $shared+"M"
$sga_max = Read-Host "Merci de renseigner la sga_max_size (en Mo)"
$sga_max = $sga_max+"M"

sqlplus $USERSYS/$PWDSYSTEM@$alias as sysdba @$REPBIS\memory.sql $pga $db_cache $sga $shared $sga_max >> $REPLOG$LOG

Write-Output "Redemarrage de la base avec les nouveaux parametres"
$host.ui.RawUI.ForegroundColor = $t
sqlplus $USERSYS/$PWDSYSTEM@$alias as sysdba @$REPBIS\restart_database2.sql

$host.ui.RawUI.ForegroundColor = "Green"
Write-Output "Creation du pfile ajuste avec les nouveaux parametres => $pfileDest"
sqlplus $USERSYS/$PWDSYSTEM@$alias as sysdba @$REPBIS\pfile.sql $pfileDest >> $REPLOG$LOG

$date = Get-date -Format g
echo $date >> $REPLOG$LOG
Write-Output "Ecriture dans le log des nouveaux parametres => $REPLOG$LOG"
sqlplus $USERSYS/$PWDSYSTEM@$alias as sysdba @$REPBIS\check.sql >> $REPLOG$LOG

Write-Output "Traitement terminé"
$host.ui.RawUI.ForegroundColor = $t
