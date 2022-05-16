#!/bin/bash
DATE=$(date +%Y-%m-%d--%H-%M-)

##Infos HANA
TENANT_DATABASE=NDB
INSTANCE_NUMBER=00
THREADS_TO_USE=4
HDBSQL_ACC=backup

##Export des bases
DO_BACKUP=true
#Retention
RETENTION_AUTOBACKUP=1 #+1 jours
#Chemin dossier
AUTOBACKUP_FOLDER=/hana/data/backup/auto
#Chemin lien
AUTOBACKUP=/hana_backup_auto

##Backup instance
DO_INSTANCE_BACKUP=true
#Retention
RETENTION_AUTOBACKUP_INSTANCE=0 #+1 jours
#Chemin dossier
AUTOBACKUP_INSTANCE_FOLDER=/hana/data/backup/instance
#Chemin lien
AUTOBACKUP_INSTANCE=/hana_backup_instance

##Exports manuels
PREPARE_MANUALBACKUP=true
#Chemin dossier
MANUALBACKUP_FOLDER=/hana/data/backup/manual
#Chemin lien
MANUALBACKUP=/hana_backup_manual

##Traces
DO_TRACE_CLEANUP=true
OLD_TRACES=7 #+1 jours

#Executables
HANAEXE=/hana/shared/$TENANT_DATABASE/HDB$INSTANCE_NUMBER/exe

#Arguments
case "$1" in
	install|"-i"|"--install") $HANAEXE/hdbuserstore -i SET $HDBSQL_ACC localhost:3${INSTANCE_NUMBER}15@$TENANT_DATABASE SYSTEM;exit 0;;
	lightweight|light|leger|mini|"-lw"|"--lightweight")
	THREADS_TO_USE=1
	PREPARE_MANUALBACKUP=false
	DO_TRACE_CLEANUP=false
	DO_BACKUP=true
	DO_INSTANCE_BACKUP=false
	echo "Lightweight Mode";;
	"help"|aide|"-h"|"--help")
	echo "$(basename "$0")"
	echo "	-h = help"
	echo "	-lw = mode leger (juste la sauvegarde des bases en utilisant seulement 1 thread, pas de backup d'instance ou netoyage des traces)"
	echo "	-i = mode installation (enregistrement des identifiants SYSTEM)"
	echo "sans arguments pour executer le script normalement"
	exit 0;;
	#*) exit 0;;
esac

#Mise en place du script pour execution à 20h tous les jours à faire manuellement:
#crontab -e
#0 20 * * * /hana/scripts/backup_bases.sh >/dev/null 2>&1

# Vérification des mount points
mount -a

#Creation de la structure de dossiers
if [ $DO_BACKUP = true ]; then
	if [ ! -d $AUTOBACKUP_FOLDER ]; then
		mkdir -p $AUTOBACKUP_FOLDER
		chmod 777 $AUTOBACKUP_FOLDER
	fi
	if [ ! -d $AUTOBACKUP ]; then
		ln -s $AUTOBACKUP_FOLDER $AUTOBACKUP
	fi
fi
if [ $PREPARE_MANUALBACKUP = true ]; then
	if [ ! -d $MANUALBACKUP_FOLDER ]; then
		mkdir -p $MANUALBACKUP_FOLDER
		chmod 777 $MANUALBACKUP_FOLDER
	fi
	if [ ! -d $MANUALBACKUP ]; then
		ln -s $MANUALBACKUP_FOLDER $MANUALBACKUP
	fi
fi
if [ $DO_INSTANCE_BACKUP = true ]; then
	if [ ! -d $AUTOBACKUP_INSTANCE_FOLDER ]; then
		mkdir -p $AUTOBACKUP_INSTANCE_FOLDER
		chmod 777 $AUTOBACKUP_INSTANCE_FOLDER
	fi
	if [ ! -d $AUTOBACKUP_INSTANCE ]; then
		ln -s $AUTOBACKUP_INSTANCE_FOLDER $AUTOBACKUP_INSTANCE
	fi
fi

if [ $DO_INSTANCE_BACKUP = true ]; then
	##Netoyage BACKUP CATALOG
	$HANAEXE/hdbsql -U $HDBSQL_ACC "ALTER SYSTEM RECLAIM LOG"
	OLD_BACKUP_DATE=$(date +%Y-%m-%d -d "$RETENTION_AUTOBACKUP_INSTANCE day ago")
	OLD_BACKUP_ID=$($HANAEXE/hdbsql -a -x -U $HDBSQL_ACC "SELECT TOP 1 ENTRY_ID/*, SYS_START_TIME*/ from sys.m_backup_catalog where (ENTRY_TYPE_NAME = 'complete data backup' or ENTRY_TYPE_NAME = 'data snapshot') and STATE_NAME = 'successful' and SYS_START_TIME < '$OLD_BACKUP_DATE 00:00:00' order by SYS_START_TIME desc")
	$HANAEXE/hdbsql -U $HDBSQL_ACC "BACKUP CATALOG DELETE ALL BEFORE BACKUP_ID $OLD_BACKUP_ID COMPLETE"
	#Supprime les dossiers de sauvegarde d'instance vide
	find "$AUTOBACKUP_INSTANCE/*" -type d -empty -delete
else
	echo "Pas de netoyage du backup catalog"
fi

if [ $DO_BACKUP = true ]; then
	##Backup bases
	#Log dates
	echo "$DATE" >> $AUTOBACKUP/log
	#Delete old backups
	find $AUTOBACKUP/*.tar.gz -type f -mtime +$RETENTION_AUTOBACKUP -exec rm -f {} \;
	#Foreach SBO database
	$HANAEXE/hdbsql -a -x -U $HDBSQL_ACC "SELECT \"dbName\" FROM SBOCOMMON.SRGC where \"dbName\" in ('SUNTEC_FR_PROD', 'SUNTEC_US_PROD', 'SCILAVOISIER_PROD')" | while read line
	do
		#Delete " from result
		line="${line//\"}"
		echo $line
		echo "$line" >> $AUTOBACKUP/log
		
		#Create backup sub-directory
		mkdir "$AUTOBACKUP/$DATE-$line/"
		chmod 777 "$AUTOBACKUP/$DATE-$line/"
		
		#Voir https://launchpad.support.sap.com/#/notes/2113228
		#Desactivation check pour eviter un timeout
		$HANAEXE/hdbsql -U $HDBSQL_ACC "UPDATE _SYS_STATISTICS.STATISTICS_SCHEDULE SET \"STATUS\" = 'Inactive' WHERE ID = 603"
		#Export base
		$HANAEXE/hdbsql -U $HDBSQL_ACC "EXPORT \"$line\".\"*\" AS BINARY INTO '$AUTOBACKUP/$DATE-$line/' WITH REPLACE THREADS $THREADS_TO_USE"
		BACKUP_RESULT=$?
		echo "$BACKUP_RESULT" >> $AUTOBACKUP/log
		#Reactivation check precedement desactive
		$HANAEXE/hdbsql -U $HDBSQL_ACC "UPDATE _SYS_STATISTICS.STATISTICS_SCHEDULE SET \"STATUS\" = 'Idle' WHERE ID = 603"
		
		#Compress Backup
		pushd $AUTOBACKUP
		tar -zvcf "$DATE-$line.tar.gz" "$DATE-$line/"
		#cp -f "$DATE-$line.tar.gz" "/mnt/backup/$line.tar.gz"
		popd
		
		#Remove backup sub-directory
		rm -rf "$AUTOBACKUP/$DATE-$line"
	done
else
	echo "Pas d'export des bases"
fi

if [ $DO_INSTANCE_BACKUP = true ]; then
	##Backup instance
	echo "$DATE" >> $AUTOBACKUP_INSTANCE/log
	echo "instance" >> $AUTOBACKUP_INSTANCE/log
	#Create backup sub-directory
	mkdir "$AUTOBACKUP_INSTANCE/$DATE"
	chmod 777 "$AUTOBACKUP_INSTANCE/$DATE"
	#Backup instance
	$HANAEXE/hdbsql -U $HDBSQL_ACC "BACKUP DATA USING FILE ('$AUTOBACKUP_INSTANCE/$DATE/')"
	BACKUP_RESULT=$?
	echo "$BACKUP_RESULT" >> $AUTOBACKUP_INSTANCE/log
else
	echo "Pas de backup d'instance"
fi

if [ $DO_TRACE_CLEANUP = true ]; then
	#Nettoyage des Traces
	find /hana/shared/$TENANT_DATABASE/HDB$INSTANCE_NUMBER/*/trace/*.trc -type f -mtime +$OLD_TRACES -exec rm -f {} \;
else
	echo "Pas de netoyage des traces"
fi
