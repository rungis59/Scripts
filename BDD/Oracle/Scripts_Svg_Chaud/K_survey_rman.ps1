# **********************************************************************************
# *            				SCRIPT DE VERIFICATION DES SAUVEGARDES RMAN		       *
# **********************************************************************************
# ----------------------------------------------------------------------------------
# Création par RCA 19/04/2018 		- Création du script
# ----------------------------------------------------------------------------------
# OBJECTIF - Liste toutes les sauvegardes RMAN realisees avec leur statut

$varFile = [environment]::GetEnvironmentVariable("VarSvg", "User")

. $varFile


$NLS_LANG = "american_america"
$NLS_DATE_FORMAT = "DD/MM/YYYY-HH24:mi:ss"

$AESKey2 = Get-Content $AESKeyFilePath2
$pwdTxt2 = Get-Content $credentialFilePath2
If ($pwdTxt2 -eq $null)
{exit}
$securePwd2 = $pwdTxt2 | ConvertTo-SecureString -Key $AESKey2
$credential2 = New-Object System.Management.Automation.PSCredential -ArgumentList $USERORACLE, $securePwd2
$PWDORACLE = $credential2.GetNetworkCredential().Password

sqlplus $USERORACLE/$PWDORACLE@$ALIASNET8 @$REP\k_survey_rman.sql $REPLOG"k_survey_rman_"$oracle_sid.log
