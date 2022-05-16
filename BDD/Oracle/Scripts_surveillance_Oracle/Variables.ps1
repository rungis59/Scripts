# **********************************************************************************
# *            DEFINITION DES VARIABLES GLOBALES             *
# **********************************************************************************
# ----------------------------------------------------------------------------------
#  Variable REP : Repertoire contenant les scripts de surveillance Oracle
#  Variable REPBIS : Repertoire contenant les scripts de sauvegarde a chaud
#  Variable REPLOG : Repertoire contenant les logs
#  Variable alias : Alias net8 de la base oracle
#  Variable Oracle_SID : SID de l'instance Oracle
#  Variable user : User Oracle, généralement system
#  Variable AESKeyFilePath : Chemin pour stocker la clé AES
#  Variable credentialFilePath : Chemin pour stocker le fichier contenant le mot de passe crypte
#  Variable ScriptSpool : Script de spool rebuild_index.tmp
#  Variable repertoire : Chemin du alert_x150.log
#  Variable ScriptStats : Script de calcul des statistiques
#  Variable StartingDir : Repertoire contenant les dossiers X3

$StartingDir = "E:\Sage\KARDOLU11\dossiers"

$REP = "E:\Kardol_Scripts\Scripts_surveillance_Oracle"
$REPBIS = "E:\Kardol_Scripts\Scripts_Svg_Chaud"

$repertoire = "F:\Sage\KARDOLU11\database\dump"

$alias = "X160"
$Oracle_Sid = "X160"
$aliasNet = $alias

$REPLOG = $REP + "\logs"

$SecureDirectory = $REP+"\logs"
$AESKeyFilePath3 = $REPBIS+"\logs\AES_key\key3.txt"
$credentialFilePath3 = $REPBIS+"\logs\AES_key\cred_password3.txt"
$AESKeyFilePath2 = $REPBIS+"\logs\AES_key\key2.txt"
$credentialFilePath2 = $REPBIS+"\logs\AES_key\cred_password2.txt"
$AESKeyFilePath4 = $REP+"\logs\key4.txt"
$credentialFilePath4 = $REP+"\logs\cred_password4.txt"
$AESKeyFilePath = $REPBIS+"\logs\AES_key\key.txt"
$credentialFilePath = $REPBIS+"\logs\AES_key\cred_password.txt"

$username3 = "SYS"
$user = "SYSTEM"
$USERSYS = $username3

$ScriptStats = "Stats.sql"
$ScriptSpool = "rebuild_index.sql"
