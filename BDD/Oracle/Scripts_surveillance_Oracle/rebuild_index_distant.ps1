param([string]$dossier,$password,$alias,$tablespace)  #Ne jamais modifier cette ligne

# **********************************************************************
# * Nom : rebuild_index_distant.ps1                                    *
# *                                                                    *
# * Date : 20/04/18                                                    *
# * Auteur : CAMY Régis                                                *
# *                                                                    *
# **********************************************************************
# OBJECTIF - Genere un fichier rebuild_X3index.sql qui contient toutes les instrcutions SQL 
# pour reconstruire les index des dossiers specifies dans le fichier Variables.ps1

# modif MB 12/02/07  On revient à l'utilisation d'un fichier rebuild_X3index.sql
# car la tentative d'exécution en direct des instructions 
# mise en place avec QUALEA en mars 2006 ne fonctionne pas
# On a maintenant deux fichier de log : 
#		un pour les sorties sql du type Index modifié = rebuild_X3index_DOSSIER.log
#		un pour les heures de début et fin = rebuild_index_DOSSIER.log

# JG 24/11/2010 - Ajout d'un repertoire des logs
# RCA 06/04/2018 - Passage en powershell

$varFile2 = [environment]::GetEnvironmentVariable("VarSve", "User")

. $varFile2

$date = Get-date -Format g
$RebuildTMP = $REP + "\rebuild_index.tmp"
$ScriptRebuild = $REP + "\rebuild_"+$dossier+"_index.sql"

echo "debut traitement : $date" >> $REPLOG\rebuild_index_$dossier.log
echo $dossier >> $REPLOG\rebuild_index_$dossier.log

sqlplus $dossier/$password@$alias @$ScriptSpool $tablespace $RebuildTMP

$Gc = Get-content -Path $RebuildTMP
$Gc2 = $Gc[2..($Gc.count)] 
$Utf8NoBomEncoding = New-Object System.Text.UTF8Encoding $False

[System.IO.File]::WriteAllLines($ScriptRebuild, $Gc2, $Utf8NoBomEncoding)

"spool $REPLOG\rebuild_X3index_$dossier.log;
" + (Get-Content $ScriptRebuild -Raw) | Set-Content $ScriptRebuild
Add-Content -Path $ScriptRebuild -Value "exit"

sqlplus $dossier/$password@$alias @$ScriptRebuild

$date = Get-date -Format g
echo "fin traitement : $date" >> $REPLOG\rebuild_index_$dossier.log
