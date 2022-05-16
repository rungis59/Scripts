# **********************************************************************************
# *           		 SCRIPT DE CALCUL DES STATISTIQUES	     		               *
# **********************************************************************************
# ----------------------------------------------------------------------------------------------
# JG 24/11/2010 - Chemin des log modifie
# RCA 06/04/2018 - Passage en powershell
# RCA 17/10/2018 - Modification du script pour calculer les statistiques sur tous les dossiers
# ----------------------------------------------------------------------------------------------
#  OBJECTIF - Ce script lance le calcul des stats pour chaque dossier X3

$varFile2 = [environment]::GetEnvironmentVariable("VarSve", "User")

. $varFile2

#Lancer le script secure_password3.ps1 au préalable si ce n'est pas déjà fait
$AESKey3 = Get-Content $AESKeyFilePath3
$pwdTxt3 = Get-Content $credentialFilePath3
If ($pwdTxt3 -eq $null)
{exit}
$securePwd3 = $pwdTxt3 | ConvertTo-SecureString -Key $AESKey3
$credential3 = New-Object System.Management.Automation.PSCredential -ArgumentList $username3, $securePwd3
$PWDSYSTEM = $credential3.GetNetworkCredential().Password
$LOG = "stat.log"

$date = Get-date -Format g
echo $date >> $REPLOG\$LOG 2>&1

Foreach ($directory in $(Get-ChildItem $StartingDir -name -Directory)) 
{
If ($directory -ne "X3_PUB" -and $directory -ne "PATCHS" -and $directory -ne "Uninstaller" -and $directory -ne "AUDROS" -and $directory -ne "Solution_Backup" -and $directory -ne "SERVX3") 
    {echo "Dossier $directory" >> $REPLOG\$LOG
	sqlplus $USERSYS/$PWDSYSTEM@$alias as sysdba @$REP\$ScriptStats $directory >> $REPLOG\$LOG
	}
}

$date = Get-date -Format g
echo $date >> $REPLOG\$LOG 2>&1
