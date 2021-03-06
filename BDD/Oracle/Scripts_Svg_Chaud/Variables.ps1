# **********************************************************************************
# *           		 DEFINITION DES VARIABLES GLOBALES            				   *
# **********************************************************************************
# Création par RCA 19/04/2018 		- Création du script
# ----------------------------------------------------------------------------------
# OBJECTIF - Stocke les variables globales qui seront utilisees par les autres scripts de sauvegarde a chaud 
# ----------------------------------------------------------------------------------
# Variable REP : Répertoire contenant les scripts de sauvegarde a chaud
# Variable REP2 : Répertoire contenant les scripts de surveillance Oracle
# Variable REPLOG : Répertoire contenant les logs
# Variable ORACLE_SID : Sid de l’instance Oracle
# Variable ARCLOGDEST : Répertoire de destination des archivelogs
# Variable ARCHIVELOGS : Répertoire des archiveslogs originaux
# Variable ADXDIR : Répertoire de la solution X3
# Variable DBDIR : Répertoire de la base de données X3
# Variable ORACLE_HOME : Chemin du répertoire Oracle
# Variable EXPORTREP : Chemin de l'export Oracle
# Variable EXPORTFILE : Nom de l’export Oracle
# Variable SPFILE : Chemin du SPFILE
# Variable ALIASNET8 : Aliasnet8 de l’instance Oracle
# Variable USERORACLE : User Oracle utilisé pour le script
# Variable username3 : User Oracle SYS
# Variable SVGDEST : Chemin stockage distant pour Oracle
# Variable SVGBACKUPRMAN : Répertoire local de sauvegarde RMAN
# Variable EXPORTORA : Nom du répertoire virtuel de Oracle pour l'export Oracle.
# Variable RMAN : Nom du script RMAN
# Variable str7zipExe : Chemin du programme 7Zip
# Variable AESKeyFilePath : Chemin pour stocker la clé AES
# Variable credentialFilePath : Chemin pour stocker le fichier contenant le mot de passe crypte
# Variable BackupBDD : Chemin pour stocker les donnees Oracle
# Variable SVGDEST2 : Chemin distant pour stocker l'arborescence X3
# Variable ExportDir : Chemin pour stocker l'export Datapump
# Variable sqlnet: Chemin du fichier sqlnet.ora
# Variable Rep_AES_key: Répertoire contenant une cle aleatoire AES
# Variable RestartDatabase : Script de redemarrage de la base de donnees en mode archivelog
# Variable ArchiveLog : Passage de la base en archivelog
# Variable directory : Creation du repertoire virtuel Oracle

$REP = "E:\Kardol_Scripts\Scripts_Svg_Chaud"
$REP2 = "E:\Kardol_Scripts\Scripts_surveillance_Oracle\"
$ADXDIR = "E:\Sage\KARDOLU11\"
$DBDIR = "F:\Sage\KARDOLU11\"

$ORACLE_SID = "X112"
$ALIASNET8 = "X112"

$ARCLOGDEST = "\\standby-v11\f$\Backupdirectory\" + $ORACLE_SID + "\BackupArchivelogs\"
$SVGDEST2 = "\\standby-v11\f$\Backupdirectory\" + $ORACLE_SID + "\BackupX3\"
$SVGDEST = "\\standby-v11\f$\Backupdirectory\" + $ORACLE_SID + "\BackupBDD\"

$ORACLE_HOME = "E:\Oracle\Product\19.3.0\dbhome_1"
$SPFILE = "E:\Sage\X3V12\database\scripts\SPFILEX112.ora"

# Pas necessaire de creer les repertoires ci-dessous, le script des pre requis le fait
$SVGBACKUPRMAN = "F:\Backupdirectory\" + $ORACLE_SID + "\BackupBDD\"
$EXPORTREP = "F:\Oradata\" + $ORACLE_SID + "\"
$ExportDir = "F:\oradata\" + $ORACLE_SID
$ARCHIVELOGS = "F:\Oradata\" + $ORACLE_SID + "\archivelogs\"

$USERORACLE = "SYSTEM"
$username3 = "SYS"
$EXPORTORA = "EXPORA"
$RMAN = "K_SVG_RMAN.rman"

$str7zipExe = "C:\Program Files\7-Zip\7z.exe"

$achivelog_format = "arch_"+$ORACLE_SID+"_%r_%t_%s.arc"
$archivelogDir = $ARCHIVELOGS
$sqlnet = $ORACLE_HOME+"\NETWORK\ADMIN\sqlnet.ora"
$Rep_AES_key = $REP+"\logs\AES_key"
$AESKeyFilePath = $Rep_AES_key+"\key.txt"
$credentialFilePath = $Rep_AES_key+"\cred_password.txt"
$REPLOG = $REP + "\logs\"
$EXPORTFILE = "Export_" + $ORACLE_SID
$username2 = $USERORACLE
$USERSYS = $username3
$BackupBDD = $SVGBACKUPRMAN
$AESKeyFilePath2 = $REP+"\logs\AES_key\key2.txt"
$credentialFilePath2 = $REP+"\logs\AES_key\cred_password2.txt"
$AESKeyFilePath3 = $REP+"\logs\AES_key\key3.txt"
$credentialFilePath3 = $REP+"\logs\AES_key\cred_password3.txt"
$SecureDirectory = $Rep_AES_key
$SecureDirectory2 = $REP2+"logs"
$RestartDatabase = "restart_database.sql"
$ArchiveLog = "archivelog.sql"
$directory = "directory.sql"
$alias = $ALIASNET8
