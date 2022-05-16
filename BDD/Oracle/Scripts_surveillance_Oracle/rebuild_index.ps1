# **********************************************************************************
# *           		 SCRIPT DE RECONSTRUCTION DES INDEX     		               *
# **********************************************************************************
# -----------------------------------------------------------------------------------------------------------------
# Création par RCA 19/04/2018 - Création du script en powershell
# Modification par RCA 17/10/2018 - Modification du script pour reconstruire les index de tous les dossiers
# -----------------------------------------------------------------------------------------------------------------
#  OBJECTIF - Lance le script rebuild_index_distant.ps1 avec 4 parametres :
# * p1 : dossier                                                       *
# * p2 : mot de passe                                                  *
# * p3 : Alias Net8                                                    *
# * p4 : nom du tablespace INDEX  

$varFile2 = [environment]::GetEnvironmentVariable("VarSve", "User")

. $varFile2

#Lancer le script PRE REQUIS.ps1 au préalable afin de renseigner le mot de passe du dossier
$username = "null"
$AESKey = Get-Content $AESKeyFilePath4
$pwdTxt = Get-Content $credentialFilePath4
If ($pwdTxt -eq $null)
{exit}
$securePwd = $pwdTxt | ConvertTo-SecureString -Key $AESKey
$credential = New-Object System.Management.Automation.PSCredential -ArgumentList $username, $securePwd
$PwdDossier = $credential.GetNetworkCredential().Password

$AESKey2 = Get-Content $AESKeyFilePath2
$pwdTxt2 = Get-Content $credentialFilePath2
If ($pwdTxt2 -eq $null)
{exit}
$securePwd2 = $pwdTxt2 | ConvertTo-SecureString -Key $AESKey2
$credential2 = New-Object System.Management.Automation.PSCredential -ArgumentList $user, $securePwd2
$mdpsystem = $credential2.GetNetworkCredential().Password

Set-Location $REP

Foreach ($directory in $(Get-ChildItem $StartingDir -name -Directory)) 
{
If ($directory -ne "X3_PUB" -and $directory -ne "PATCHS" -and $directory -ne "Uninstaller" -and $directory -ne "AUDROS" -and $directory -ne "Solution_Backup") 
    {$tablespaces = $directory+"_IDX"
    & .\rebuild_index_distant.ps1 -dossier $directory -password $PwdDossier -alias $aliasNet -tablespace $tablespaces
    }
}
