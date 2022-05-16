#!/bin/bash
DATE=$(date +%Y-%m-%d)

#Infos HANA
TENANT_DATABASE=NDB
INSTANCE_NUMBER=00
#
HDBSQL_ACC=backup

#Executables
HANAEXE=/hana/shared/$TENANT_DATABASE/HDB$INSTANCE_NUMBER/exe

#Arguments
case "$1" in
	install) $HANAEXE/hdbuserstore -i SET $HDBSQL_ACC localhost:3${INSTANCE_NUMBER}15@$TENANT_DATABASE SYSTEM;exit 0;;
	#*) exit 0;;
esac

$HANAEXE/hdbsql -a -x -U $HDBSQL_ACC "CALL SUNTEC_FR_PROD.COPY_FROM_PROD_FR_TO_PROD_US();"