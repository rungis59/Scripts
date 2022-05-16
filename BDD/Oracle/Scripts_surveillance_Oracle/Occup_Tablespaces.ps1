# **********************************************************************************
# *            SCRIPT DE VERIFICATION DE LA TAILLE DES TABLESPACES                 *
# **********************************************************************************
# ----------------------------------------------------------------------------------
# Modifié par JG 24/11/2010 - Cette version est totalement générique
# Modifié par JG 01/10/2014 - Modification du script SQL - Passage de Occup_Tablespace.sql à tbls_occupation.sql
# Modifié par JG 01/10/2014 - Modification du script BAT - Passage de Occup_Tablespace.cmd à tbls_occupation.bat
# Modifié par JG 04/12/2014 - Nom tbls_occupation passé en Occup_Tablespace après validation du fonctionnement
# Modifié par RCA 05/04/2018 - Passage en powershell
# ----------------------------------------------------------------------------------
#  OBJECTIF - Script de vérification de la taille des tablespaces

#  Variable LOG : Nom du log généré par le script

$varFile2 = [environment]::GetEnvironmentVariable("VarSve", "User")

. $varFile2

$AESKey2 = Get-Content $AESKeyFilePath2
$pwdTxt2 = Get-Content $credentialFilePath2
If ($pwdTxt2 -eq $null)
{exit}
$securePwd2 = $pwdTxt2 | ConvertTo-SecureString -Key $AESKey2
$credential2 = New-Object System.Management.Automation.PSCredential -ArgumentList $user, $securePwd2
$mdpsystem = $credential2.GetNetworkCredential().Password
$LOG = "K_Occup_tablespaces.log"

echo *-----------------------------------DEBUT------------------------------------------------* >> $REPLOG$LOG
sqlplus $user/$mdpsystem@$alias @$REP\'Occup_Tablespaces.sql' >> $REPLOG\$LOG
# Prendre la version ci-dessous si la base est déportée
# sqlplus %user%/%mdpsystem%@%alias% @%REP%\Occup_Tablespaces.sql >> %REPLOG%\%LOG%
echo *-----------------------------------FIN--------------------------------------------------* >> $REPLOG$LOG
echo ~ >> $REPLOG\$LOG
echo ~ >> $REPLOG\$LOG
echo ~ >> $REPLOG\$LOG