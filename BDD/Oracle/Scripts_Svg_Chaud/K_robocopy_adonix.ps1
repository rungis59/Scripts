# **********************************************************************************
# *                   SCRIPT DE ROBOCOPY ARBORESCENCE X3                           *
# **********************************************************************************
# ----------------------------------------------------------------------------------
# Modification par JG 30/10/09 - Cette version est totalement générique
# Modification par JG 08/03/10 - Modification du comportement des logs
# Modification par JG 08/03/10 - Modification de l'architecture des dossiers
# Modification par JG 28/10/10 - Modification chemin de sauvegarde X3
# Modification par RCA 03/04/2018 - Passage en powershell
# Modification par RCA 19/04/18 - Utilisation de variables globales
# Modification par RCA 06/05/19 - Test de la variable DBDIR si la base de donnees n'est pas stockée sur la meme partition que les dossiers X3
# ---------------------------------------------------------------------------------------------------------------------------------------------------
# OBJECTIF - Copie des arborescences Dossiers et Runtime

# Installer le Windows Resource Kits  - inutile en W2008 R2 robocopy se trouve nativement dans C:\Windows\SysWOW64
# Choisissez entre la version 32 bit et la version 64 bit (Décommentez)

# Variable LOG : nom du log

$varFile = [environment]::GetEnvironmentVariable("VarSvg", "User")

. $varFile

$LOG = "K_robocopy.log"

# Pour WINDOWS 2003, copiez Robocopy.exe et prenez la variable ci-dessous
# $ROBOCOPY = %REP%\Robocopy.exe
# Pour WINDOWS 2008, utilisez la variable ci-dessous
#$ROBOCOPY = C:\Windows\System32\Robocopy.exe

# Rotation des fichiers de log de svg Adonix
Remove-Item $REPLOG$LOG'.5' -ErrorAction SilentlyContinue
Rename-Item -Path $REPLOG$LOG'.4' -NewName $LOG'.5' -ErrorAction SilentlyContinue
Rename-Item -Path $REPLOG$LOG'.3' -NewName $LOG'.4' -ErrorAction SilentlyContinue
Rename-Item -Path $REPLOG$LOG'.2' -NewName $LOG'.3' -ErrorAction SilentlyContinue
Rename-Item -Path $REPLOG$LOG'.1' -NewName $LOG'.2' -ErrorAction SilentlyContinue
Rename-Item -Path $REPLOG$LOG -NewName $LOG'.1' -ErrorAction SilentlyContinue

ROBOCOPY $ADXDIR'Dossiers' $SVGDEST2'Dossiers' /MIR /NP /e /sec /w:2 /r:2 > $REPLOG$LOG 2>&1
ROBOCOPY $ADXDIR'Runtime' $SVGDEST2'Runtime' /MIR /NP /e /sec /w:2 /r:2 >> $REPLOG$LOG 2>&1
ROBOCOPY $ADXDIR'DOCUMENTATION' $SVGDEST2'DOCUMENTATION' /MIR /NP /e /sec /w:2 /r:2 >> $REPLOG$LOG 2>&1

If ($DBDIR)
{ROBOCOPY $DBDIR'database' $SVGDEST2'database' /MIR /NP /e /sec /w:2 /r:2 /XF *.* >> $REPLOG$LOG 2>&1}
else
{ROBOCOPY $ADXDIR'database' $SVGDEST2'database' /MIR /NP /e /sec /w:2 /r:2 /XF *.* >> $REPLOG$LOG 2>&1}

# Pour exclure un fichier, utilisez l'option /XF "chemin_fichier\fichier" "chemin_fichier\fichier2" etc...
# On peut exclure des type de ficher avec *.doc, *.txt ...
# Pour exclure un Dossier, utilisez l'option /XD "chemin_fichier\Dossier" "chemin_fichier\Dossier2" etc...
