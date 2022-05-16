# **********************************************************************************
# *                  SCRIPT D'EPURATION DES ARCHIVELOGS 			               *
# **********************************************************************************
# ----------------------------------------------------------------------------------
# Création par Qualea en Mars 2006
# Modification par RCA le 06/09/2018 - Adaptation du script en powershell
# ----------------------------------------------------------------------------------
# OBJECTIF - Epure les archivelogs de plus de 2 jours

# Variable LOG : Nom du fichier de log
# Variable Rep_arch : Répertoire des archiveslogs
# Variable Time : Delai de conservation des archivelogs (en jours)

$varFile = [environment]::GetEnvironmentVariable("VarSvg", "User")

. $varFile

$LOG = $REP +"\logs\K_epure_archivelogs.log"
$Rep_arch = $ARCHIVELOGS + "*.ARC"
$Time = 2

Get-ChildItem -Path $Rep_arch -Recurse -File | ?{$_.CreationTime -lt (get-date).AddDays(-$Time)}`
| %{Remove-Item $_.FullName -Force -Verbose 4>&1 | Add-Content $LOG
Add-Content -path $LOG -Value (Get-Date -format g)}
