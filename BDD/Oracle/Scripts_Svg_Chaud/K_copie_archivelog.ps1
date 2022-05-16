# **********************************************************************************
# *                   SCRIPT DE COPIE DES ARCHIVELOGS                              *
# **********************************************************************************
# ----------------------------------------------------------------------------------
# Modification par JG 30/10/09 - Cette version est totalement générique
# Modification par JG 08/03/10 - Modification du comportement des logs
# Modification par JG 08/03/10 - Modification de l'architecture des dossiers
# Modification par JG 28/10/10 - Chemin SVGDEST modifie
# Modification par JG 09/08/11 - Passage en robocopy
# Modification par RCA 23/03/18 - Passage en powershell
# Modification par RCA 19/04/18 - Utilisation de variables globales
# ----------------------------------------------------------------------------------

#  OBJECTIF - Script de copie des archivelog vers un serveur distant

#  Variable LOG : Nom du log généré par le script

$varFile = [environment]::GetEnvironmentVariable("VarSvg", "User")

. $varFile

$LOG = "K_copie_archivelog.log"

Get-date -Format g >> $REPLOG$LOG 2>&1
ROBOCOPY $ARCHIVELOGS $ARCLOGDEST /MIR /NP /e /sec /w:2 /r:2 >> $REPLOG$LOG 2>&1
