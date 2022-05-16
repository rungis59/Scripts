# **********************************************************************************
# *            SCRIPT D'EPURATION DES LOG "EPURATION_ARCHIVELOGS"                  *
# **********************************************************************************
# ----------------------------------------------------------------------------------
# Creation par JG 24/11/2010
# RCA: passage en powershell 03/04/2018
# Modification par RCA 19/04/18 - Utilisation de variables globales
# ----------------------------------------------------------------------------------
# Objectif - Script qui epure tout les mois le log des epurations des archivelogs

#  Variable LOG : Nom du log généré par le script

$varFile = [environment]::GetEnvironmentVariable("VarSvg", "User")

. $varFile

$LOG = "K_epure_archivelogs.log"

# -- rotation des fichiers log des mois precedents --
Remove-Item $REPLOG$LOG'.5' -ErrorAction SilentlyContinue
Rename-Item -Path $REPLOG$LOG'.4' -NewName $LOG'.5' -ErrorAction SilentlyContinue
Rename-Item -Path $REPLOG$LOG'.3' -NewName $LOG'.4' -ErrorAction SilentlyContinue
Rename-Item -Path $REPLOG$LOG'.2' -NewName $LOG'.3' -ErrorAction SilentlyContinue
Rename-Item -Path $REPLOG$LOG'.1' -NewName $LOG'.2' -ErrorAction SilentlyContinue
Rename-Item -Path $REPLOG$LOG -NewName $LOG'.1' -ErrorAction SilentlyContinue
