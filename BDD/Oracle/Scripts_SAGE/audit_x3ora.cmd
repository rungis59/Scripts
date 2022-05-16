@echo off && mode con lines=50 cols=132 && color f1
::##################################################################################################################################
::#
::# audit_x3ora.cmd
::#
::# Description : Makes an Oracle audit database for the Sage applicative solution.
::#
::# Last date   : 13/10/2020
::#
::# Version     : WINDOWS - 2.08
::#
::# Author      : F.SUSSAN / SAGE
::#
::# Syntax      : audit_x3ora [/V] [<TARGET> ...]
::#
::# Notes       : This script must be executed on the applicative server in version Sage X3 V5, V6, V7+, V11 or V12.
::#               The database in version Oracle 10g/11g/12c/18c can be located on a different server and operating system (Linux/Unix).
::#               A SQL script is generated to be executed with SQL*Plus by a DB Admin user.
::#
::#               All Oracle elements are checked by default else individually with the matching option: 
::#               - Host computer resource                                                  (HOST option)
::#               - Database info                                                           (DB   option)
::#               - Main init.ora system parameters                                         (INIT option)
::#               - RMAN configuration & backup                                             (BAK  option)
::#               - Memory usage and advisor                                                (MEM  option)
::#               - Tablespace info                                                         (TBSP option)
::#               - DB files info and IO activity & history                                 (FILE option)
::#               - Redo log info & activity                                                (REDO option)
::#               - UNDO usage & activity                                                   (UNDO option)
::#               - TEMP usage                                                              (TEMP option)
::#               - Tables with many or no index, most large fragmented and invalid objects (OBJ  option)
::#               - Oracle alert history (only from ora12c and above)                       (ERR  option)
::#               - Wait events & TOP timed events and contention per segment               (WAIT option)
::#               - User info & session activity                                            (USER option)
::#               - Lock activity & history (in option)                                     (LOCK option)
::#               - Objects & operations statistics                                         (STAT option)
::#               - Top SQL ordered by Elapsed time                                         (SQL  option)
::#               - Alert Oracle history                                                    (ERR  option)
::# 
::#               ATTENTION,
::#               - the ADXDIR variable, that specifies location where the runtime of the Sage X3 Solution is installed,
::#                 is needed to initialize Oracle variables in the program (ORACLE_SID, ORACLE_HOME).
::#               - the lock history is available only if the Oracle diagnostic pack is activated.
::# 
::# Examples    : audit_x3ora
::#                   Makes an Oracle audit for all elements in the database specified in settings
::#               audit_x3ora /TBSP /FILE
::#                   Makes an Oracle audit for tablespaces and datafiles elements in the database specified in settings
::# 
::# Exit status : = 0 : OK
::#               = 1 : !! ERROR !!
::#               = 2 : ** WARN **
::#
::# Copyright © 2011-2020 by SAGE Professional Services - All Rights Reserved.
::#
::##################################################################################################################################
::#
::# Modifications history
::# --------------------------------------------------------------------------------------------------------------------------------
::# ! Date       ! Version ! Author       ! Description
::# !------------+---------+--------------+-----------------------------------------------------------------------------------------
::# ! 01/08/2014 !  1.06   ! F.SUSSAN     ! Official use of the script by the French IT & System Sage X3 team.
::# !------------+---------+--------------+-----------------------------------------------------------------------------------------
::# ! 10/10/2014 !  1.07   ! F.SUSSAN     ! Uses the "ADXDIR" variable to initialize all others variables needed in the script.
::# !            !         !              ! The script is now compatible with all Sage X3 environments installed in multi-tier.
::# !------------+---------+--------------+-----------------------------------------------------------------------------------------
::# ! 20/02/2015 !  1.08   ! F.SUSSAN     ! Uses the column next_change# in v$log only in Oracle 11g R2.
::# !------------+---------+--------------+-----------------------------------------------------------------------------------------
::# ! 12/03/2015 !  1.08b  ! F.SUSSAN     ! Displays the content of the script generated only if DISPLAY variable is set.
::# !            !         !              ! Adds the current date in the trace file name.
::# !------------+---------+--------------+-----------------------------------------------------------------------------------------
::# ! 05/05/2015 !  1.08c  ! F.SUSSAN     ! Uses the SYSTEM oracle account to connect to the database.
::# !            !         !              ! Displays the lock history only if the Oracle diagnostic pack is activated.
::# !            !         !              ! Adds the "LOGIN" variable to display information only for a login.
::# !            !         !              ! Adds the case when the system format date is in Spanish : "dd-mm-aa" (Info_sysdate).
::# !            !         !              ! Adds /V option to display the version number, the last modified date of the program,
::# !            !         !              ! and the list of variables modified & functions defined.
::# !------------+---------+--------------+-----------------------------------------------------------------------------------------
::# ! 26/02/2016 !  1.08d  ! F.SUSSAN     ! Makes a distinct version in Oracle 10g and 11g for the item "TEMP usage".
::# !            !         !              ! Fixes the DB size in the DB section.
::# !            !         !              ! Adds a new item "IO activity" in the FILE section.
::# !            !         !              ! Adds missing DB files completely filled in the FILE section.
::# !------------+---------+--------------+-----------------------------------------------------------------------------------------
::# ! 25/04/2016 !  1.09   ! F.SUSSAN     ! Compatibility ensured with Sage Product Update in Oracle Database 12c.
::# !            !         !              ! Adds the "Limit|PGA Size|(Mo)" in the "Memory usage" module.
::# !            !         !              ! Adds the "Contention per segment" in the WAIT section.
::# !------------+---------+--------------+-----------------------------------------------------------------------------------------
::# ! 15/09/2016 !  1.09a  ! F.SUSSAN     ! Minor bug fixes and Improvements.
::# !------------+---------+--------------+-----------------------------------------------------------------------------------------
::# ! 21/09/2016 !  1.09b  ! F.SUSSAN     ! Added a new item "Statistics operations" in the STAT section.
::# !------------+---------+--------------+-----------------------------------------------------------------------------------------
::# ! 15/11/2016 !  2.01   ! F.SUSSAN     ! Added the function "Check_versys" to check the operating system version for Windows.
::# !            !         !              ! Fixed the timer in the function "Sleep".
::# !------------+---------+--------------+-----------------------------------------------------------------------------------------
::# ! 12/04/2017 !  2.02   ! F.SUSSAN     ! Optimized the SQL query for the "Session activity" module.
::# !------------+---------+--------------+-----------------------------------------------------------------------------------------
::# ! 10/07/2018 !  2.02a  ! F.SUSSAN     ! Fixed "IO activity" when no user connected.
::# !------------+---------+--------------+-----------------------------------------------------------------------------------------
::# ! 12/10/2018 !  2.03   ! F.SUSSAN     ! Compatibility ensured for Windows Server 2016.
::# !            !         !              ! Improved display of the "Most large fragmented objects" item in the OBJ section.
::# !            !         !              ! Added a new item "Datafile activity" in the FILE section.
::# !            !         !              ! Added the lock activity and history in the LOCK section.
::# !            !         !              ! Added the display plan for each sql statement in the SQL section.
::# !            !         !              ! Added a summary for the "Objects statistics" item in the STAT section.
::# !            !         !              ! Sets the variable "TIM" in the function "Info_sysdate".
::# !            !         !              ! Added the MODULE variable to specify a module name as search criteria for SQL queries.
::# !            !         !              ! Added the OPTION variable to be used with the dbms_xplan package for execution plan.
::# !            !         !              ! Added the STALE variable to consider that objects statistics are stale (8 days by default).
::# !            !         !              ! Added Oracle Alert History on the last 180 days by default (only from oracle 12c).
::# !            !         !              ! Fixed the used of v$iostat_file view only from 11gR2 in the "Datafile activity" item.
::# !            !         !              ! Changed the order of files specified in the "Datafile info" and status for controlfiles.
::# !            !         !              ! Fixed when the special character "!" is included in the Oracle password. 
::# !------------+---------+--------------+-----------------------------------------------------------------------------------------
::# ! 04/03/2019 !  2.04   ! F.SUSSAN     ! Sage X3 is now called Sage EM (Sage Business Cloud Enterprise Management).
::# !            !         !              ! Added DB_USER and DB_PWD variables to specify name and password for the DB user with
::# !            !         !              ! system privilege used for database connection.
::# !------------+---------+--------------+-----------------------------------------------------------------------------------------
::# ! 05/09/2019 !  2.05   ! F.SUSSAN     ! Rollback to the name of the Sage product : "Sage EM" => "Sage X3".
::# !            !         !              ! Compatibility ensured with Sage Product Update in Oracle Database 12c.
::# !            !         !              ! Added ORA_SID and ORA_HOME variables if the ADXDIR variable is not set.
::# !            !         !              ! Added "Sequences hit ratio" and "Contention for sequences" items in the OBJ section.
::# !            !         !              ! Added the "Tables with many or no index" item in the OBJ section.
::# !------------+---------+--------------+-----------------------------------------------------------------------------------------
::# ! 09/09/2019 !  2.05a  ! F.SUSSAN     ! Fixed when the variable ADXDIR is not set and when the instance name is set to lowercase. 
::# !------------+---------+--------------+-----------------------------------------------------------------------------------------
::# ! 06/12/2019 !  2.06   ! F.SUSSAN     ! Added TARGET option as prefix in the trace file name if one argument is passed to the script.
::# !            !         !              ! Displayed only sequences with default change (order, cache size>20) or causing some contention.
::# !------------+---------+--------------+-----------------------------------------------------------------------------------------
::# ! 02/06/2020 !  2.07   ! F.SUSSAN     ! Added the function "Check_verapp" for checking Sage X3 application version (V5 to V12).
::# !            !         !              ! Added display of type and version for the Sage application (typeprd, apversion) in the "version" function.
::# !------------+---------+--------------+-----------------------------------------------------------------------------------------
::# ! 13/10/2020 !  2.08   ! F.SUSSAN     ! Added new "Memory advisor" iteml in the MEM section.
::# !            !         !              ! Added new item "IO history" in the FILE section.
::# !            !         !              ! Added new "UNDO activity" item in the UNDO section.
::# !            !         !              ! Added new "Most large fragmented objects (detail)" item in the OBJ section.
::# !            !         !              ! Added new "TOP Timed events" in the WAIT section.
::# !            !         !              ! Added the SQL_TIME variable that is elapsed time in secs for displaying SQL statements in TOP SQL. 
::# !            !         !              ! Replaced the RMAN by BAK option.
::# !            !         !              ! Added the "Current users" info in the "TEMP usage" and "UNDO usage" items. 
::# --------------------------------------------------------------------------------------------------------------------------------
::##################################################################################################################################

::#!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!#
::#!!!!    THE FOLLOWING VARIABLES ARE TO BE MODIFIED    !!!!#
::#!!!!    DEPENDING ON YOUR SYSTEM IMPLEMENTATION.      !!!!#
::#!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!#

:: Location of the runtime for the Sage X3 solution
set ADXDIR=E:\Sage\X3V12\runtime
:: Password used for the DB user with SYSTEM privileges
set DB_PWD=oracle

::#!!!!--------------------------------------------------!!!!#
::#!!!!    OTHER OPTIONAL VARIABLES THAT CAN BE USED     !!!!#
::#!!!!             DEPENDING ON THE CONTEXT             !!!!#
::#!!!!--------------------------------------------------!!!!#

:: Name of the DB user with SYSTEM privileges (=system by default)
set DB_USER=

:: Login used as search criteria for the audit (=applicative folder, else all login existing)
set LOGIN=

:: List of target section to audit (='ALL' by default else any target option each separated by a blank: HOST, DB, INIT, BAK, MEM, TBSP, FILE, REDO, UNDO, TEMP, OBJ, WAIT, USER, LOCK, STAT, SQL, ERR
set TARGET=

:: First Oracle format date used (='DD/MM/YY' by default if null value)
set FMT_DAT1=

:: Second Oracle format date used (='DD/MM/YY HH24:MI' by default if null value)
set FMT_DAT2=

:: Second Oracle format date used (='DD/MM/YY HH24:MI:SS' by default if null value)
set FMT_DAT3=

:: Display length used for SQL Text (='200' by default if null value)
set LEN_SQLT=

:: Number of first N rows returned (='20' by default if null value)
set TOP_NSQL=

:: Name of the Oracle instance (required for the ORACLE_SID variable if the ADXDIR variable is not set)
set ORA_SID=

:: Location of the home directory in which the Oracle product is installed (required for the ORACLE_HOME variable if the ADXDIR variable is not set)
set ORA_HOME=

:: Module name used as search criteria for SQL statements (E.g. sadora)
set MODULE=

:: option used with dbms_xplan package to display a plan of each SQL statement (E.g. 'allstats last' by default else can be 'typical', 'all', 'advanced' or 'all allstats advanced') 
set OPTION=all allstats advanced

:: Number of days from which objects statistics are considered stale (='8' days by default)
set STALE=

:: Number of days to query Oracle alerts history (='180' days by default. Only from Oracle 12c and above)
set DAYS=

:: Minimum threshold of elapsed time in seconds for displaying SQL statements in TOP SQL (=1 by default)
set SQL_TIME=

::#!!!!--------------------------------------------------!!!!#
::#!!!!    OTHER OPTIONAL VARIABLES THAT CAN BE USED     !!!!#
::#!!!!    TO CHANGE THE DEFAULT VALUE.                  !!!!#
::#!!!!--------------------------------------------------!!!!#

:: Location of scripts directory (by default where the main script is located)
set SCRIPTDIR=

:: Location of directory that will contain output from the script (by default a sub-directory logs where the script is located)
set LOGDIR=

:: Displays the content of the script generated (by default 0 else 1)
set DISPLAY=

:: Prompts to confirm before execution (by default 1 else 0)
set PAUSE=

:: Delay in seconds to display the result before exit the program (by default 1 else must be range 1-99)
set DELAY=

::#!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!#
::#!!!!    END OF IMPLEMENTATION-DEPENDANT VARIABLES     !!!!#
::#!!!!    DO NOT MAKE ANY CHANGE BELOW THIS PART        !!!!#
::#!!!!    OR DO IT AT YOUR OWN RISK !!!                 !!!!#
::#!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!#
::#!!!!    IF YOU FIND ANY BUG OR POSSIBLE ENHANCEMENT   !!!!#
::#!!!!    PLEASE REPORT YOUR VENDOR / DISTRIBUTOR.      !!!!#
::#!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!#

:: Initializes variables used in the program
call :Init_variables || goto End

:: Displays the banner program
call :Banner

:: Gets options passed in the command line
if (%1)==(/?) goto :Usage
if (%1)==(/V) goto :Version
set OPTS=%*
call :Upper OPTS

(set FLG_DB=0) & (set FLG_HOST=0) & (set FLG_DB=0) & (set FLG_INIT=0) & (set FLG_BAK=0) & (set FLG_MEM=0) & (set FLG_TBSP=0) & (set FLG_FILE=0) & (set FLG_REDO=0) & (set FLG_UNDO=0) & (set FLG_TEMP=0) & (set FLG_OBJ=0) & (set FLG_ERR=0) & (set FLG_WAIT=0) & (set FLG_USER=0) & (set FLG_LOCK=0) & (set FLG_STAT=0) & (set FLG_SQL=0)
:Option
if not "%*"=="" set TARGET=%*
if defined TARGET call :Check_target || goto End
for /d %%i in (HOST DB INIT BAK MEM TBSP FILE REDO UNDO TEMP OBJ WAIT USER LOCK STAT SQL ERR) do if /I (%1)==(%%i) (set FLG_%%i=1)
if not defined TARGET if /I (%1)==() (set FLG_HOST=1) & (set FLG_DB=1) & (set FLG_INIT=1) & (set FLG_BAK=1) & (set FLG_MEM=1) & (set FLG_TBSP=1) & (set FLG_FILE=1) & (set FLG_REDO=1) & (set FLG_UNDO=1) & (set FLG_TEMP=1) & (set FLG_OBJ=1) & (set FLG_ERR=1) & (set FLG_WAIT=1) & (set FLG_USER=1) & (set FLG_LOCK=1) & (set FLG_STAT=1) & (set FLG_SQL=1)
if /I "%TARGET%"=="ALL" (set FLG_HOST=1) & (set FLG_DB=1) & (set FLG_INIT=1) & (set FLG_BAK=1) & (set FLG_MEM=1) & (set FLG_TBSP=1) & (set FLG_FILE=1) & (set FLG_REDO=1) & (set FLG_UNDO=1) & (set FLG_TEMP=1) & (set FLG_OBJ=1) & (set FLG_ERR=1) & (set FLG_WAIT=1) & (set FLG_USER=1) & (set FLG_LOCK=1) & (set FLG_STAT=1) & (set FLG_SQL=1) & (set FLG_ALL=1)
if /I not (%1)==(DB) if /I not (%1)==(HOST) if /I not (%1)==(DB) if /I not (%1)==(INIT) if /I not (%1)==(BAK) if /I not (%1)==(MEM) if /I not (%1)==(TBSP) if /I not (%1)==(FILE) if /I not (%1)==(REDO) if /I not (%1)==(UNDO) if /I not (%1)==(TEMP) if /I not (%1)==(OBJ) if /I not (%1)==(ERR) if /I not (%1)==(WAIT) if /I not (%1)==(USER)  if /I not (%1)==(LOCK) if /I not (%1)==(STAT) if /I not (%1)==(SQL) if /I not (%1)==() goto :Usage
if not (%1)==() shift
if not (%1)==() goto :Option

:: Checks the operating system version for Windows (2008, 2012 or 2016 required)
call :Check_versys || goto End

:: Checks the value for variables that are defined
call :Check_variables || goto End

:: Checks if the Oracle version is compatible (10g, 11g, 12c, 18c or 19c required)
call :Check_verora || goto End

:: Checks version for the Sage X3 application (v5 to v12)
call :Check_verapp

:: Creates non existent directories that will be used
call :Create_dir %LOGDIR% || goto End

:: Initializes files used in the program
call :Init_files
if not defined TARGET call :Display_timestamp STARTING AN ORACLE AUDIT FOR THE SAGE %type_prd% DATABASE [%ORACLE_SID%]... 
if     defined TARGET call :Display_timestamp STARTING AN ORACLE AUDIT [%TARGET%] FOR THE SAGE %type_prd% DATABASE [%ORACLE_SID%]... 

:: Generates the SQL script
call :Cre_audit

:: Displays the content of the SQL script if some elements are asked
if defined TARGET call :Display_script LIST OF INSTRUCTIONS IN THE SQL SCRIPT [%file_sql%]

:: Executes the loop SQL script
%CMD_SQL% %CON_SQL% @%file_sql%
findstr "^ORA-" %file_log% 2>&1 >NUL
if errorlevel 1 (
	set RET=0
) else (
	set RET=1
)
call :Display
call :Display_timestamp AUDIT ENDED.

:: Checks the result of the SQL script execution
del %file_tmp%>NUL
if "%RET%"=="0" (
	del %file_sql%>NUL
	call :Display STATUS : OK
) else (
	call :Display STATUS : KO
)
call :Display Trace file '%file_log%' generated.

:: End of the program
goto End

:Init_variables
::#************************************************************#
::# Initializes variables used in the program
::#
:: Standard variables
set dbversion=Oracle Database 10g, 11g, 12c or 18c
set copyright=Copyright {C} 2011-2020
set author=Sage Group
for /F "delims=" %%i in ('hostname') do set hostname=%%i
for /F "delims=" %%i in ("%~nx0")    do set progname=%%~ni
for /F "delims=" %%i in ("%~nx0")    do set extname=%%~xi
set dirname=%~dp0
set dirname=%dirname:~,-1%
for /f "tokens=5 delims=- " %%i in ('findstr /C:"# Version" %dirname%\%progname%%extname% ^| findstr /v findstr ') do set version=%%i
if exist %ADXDIR%\bin\env.bat call %ADXDIR%\bin\env.bat
if not defined ORACLE_SID  set ORACLE_SID=%ORA_SID%
if not defined ORACLE_HOME set ORACLE_HOME=%ORA_HOME%
set dbhome=%ORACLE_HOME%\bin
set file_log=
set type_prd=X3
call :Info_sysdate
if not defined SCRIPTDIR set SCRIPTDIR=%dirname%
if not defined LOGDIR    set LOGDIR=%SCRIPTDIR%\logs
if not defined DISPLAY   set DISPLAY=0
if not defined PAUSE     set PAUSE=0
if not defined DELAY     set DELAY=10

:: Specific variables
if not defined ADXDOS if exist "%ADXDIR%"\adxvolumes for /F "tokens=1,2,3 delims=: " %%i in ('type %ADXDIR%\adxvolumes ^| find /I "A:" ') do set ADXDOS=%%j:%%k
if not defined ADXDOS if exist %ADXDIR%\..\dossiers set ADXDOS=%ADXDIR:~,-8%\dossiers
if not defined FMT_DAT1 set FMT_DAT1=DD/MM/YY
if not defined FMT_DAT2 set FMT_DAT2=DD/MM/YY HH24:MI
if not defined FMT_DAT3 set FMT_DAT3=DD/MM/YY HH24:MI:SS
if not defined LEN_SQLT set LEN_SQLT=200
if not defined TOP_NSQL set TOP_NSQL=20
if not defined OPTION   set OPTION=allstats last
if not defined STALE    set STALE=8
if not defined DAYS     set DAYS=180
if not defined SQL_TIME set SQL_TIME=1
if not defined DB_USER  set DB_USER=system
set CMD_SQL=sqlplus -s
set CON_SQL=%DB_USER%/%DB_PWD%
set ORAPACK=DIAGNOSTIC
goto:EOF
::#
::# End of Init_variables
::#************************************************************#

:Check_variables
::#************************************************************#
::# Checks the value for variables that are defined
::#
set RET=1

if not defined ORA_SID if not defined ORA_HOME if not exist %ADXDIR%\bin\env.bat (
	echo ERROR: Invalid path for the variable "ADXDIR" [%ADXDIR%] !!
	exit /B %RET%
)
if not defined ORACLE_SID (
    echo ERROR: You must enter the variable "ORA_SID" !!
	exit /B %RET%
)
:: If the database is installed on the same server than the Sage X3 application
if not defined LOCAL (
 	sc query "OracleService%ORACLE_SID%">NUL
	if errorlevel 1 (
		echo ERROR: The database service is not defined [OracleService%ORACLE_SID%] !!
		exit /B %RET%
	)
	net start | findstr /I "OracleService%ORACLE_SID%$">NUL
	if errorlevel 1 (
		echo ERROR: The database service is not started [OracleService%ORACLE_SID%] !!
		exit /B %RET%
	)
)
if not defined ORACLE_HOME (
    echo ERROR: You must enter the variable "ORA_HOME" !!
	exit /B %RET%
)
:: If 
if not exist "%ORACLE_HOME%\BIN" (
    echo ERROR: Invalid path for the variable "ORACLE_HOME" [%ORACLE_HOME%] !!
	exit /B %RET%
)
if not defined DB_PWD (
	echo ERROR: The variable "DB_PWD" about password for the admin DB user [%DB_USER%] is not set !!
	exit /B %RET%
)
call :Check_datefmt FMT_DAT1 || exit /B %RET%
call :Check_datefmt FMT_DAT2 || exit /B %RET%
call :Check_datefmt FMT_DAT3 || exit /B %RET%
set RET=1
echo %LEN_SQLT% | findstr /r "\<[1-9]\>">NUL
if errorlevel 1 (
	echo %LEN_SQLT% | findstr /r "\<[1-9][0-9]\>">NUL
	if errorlevel 1 (
		echo %LEN_SQLT% | findstr /r "\<[1-9][0-9][0-9]\>">NUL
		if errorlevel 1 (
			echo ERROR: Invalid number [%LEN_SQLT%] for the variable "LEN_SQLT" [must be range 1-999] !!
			exit /B %RET%
		)
	)
)
echo %TOP_NSQL% | findstr /r "\<[1-9]\>">NUL
if errorlevel 1 (
	echo %TOP_NSQL% | findstr /r "\<[1-9][0-9]\>">NUL
	if errorlevel 1 (
		echo %TOP_NSQL% | findstr /r "\<[1-9][0-9][0-9]\>">NUL
		if errorlevel 1 (
			echo ERROR: Invalid number [%TOP_NSQL%] for the variable "TOP_NSQL" [must be range 1-999] !!
			exit /B %RET%
		)
	)
)
echo %STALE% | findstr /r "\<[1-9]\>">NUL
if errorlevel 1 (
	echo %STALE% | findstr /r "\<[1-9][0-9]\>">NUL
	if errorlevel 1 (
		echo ERROR: Invalid number [%STALE%] for the variable "STALE" [must be range 1-99] !!
		exit /B %RET%
	)
)
echo %DAYS% | findstr /r "\<[1-9]\>">NUL
if errorlevel 1 (
	echo %DAYS% | findstr /r "\<[1-9][0-9]\>">NUL
	if errorlevel 1 (
		echo %DAYS% | findstr /r "\<[1-9][0-9][0-9]\>">NUL
		if errorlevel 1 (
			echo ERROR: Invalid number [%DAYS%] for the variable "DAYS" [must be range 1-999] !!
			exit /B %RET%
		)
	)
)
echo %SQL_TIME% | findstr /r "\<[1-9]\>">NUL
if errorlevel 1 (
	echo %SQL_TIME% | findstr /r "\<[1-9][0-9]\>">NUL
	if errorlevel 1 (
		echo %SQL_TIME% | findstr /r "\<[1-9][0-9][0-9]\>">NUL
		if errorlevel 1 (
			echo ERROR: Invalid number [%SQL_TIME%] for the variable "SQL_TIME" [must be range 1-999] !!
			exit /B %RET%
		)
	)
)
if defined OPTION if /I not "%OPTION%"=="allstats last" if /I not "%OPTION%"=="typical" if /I not "%OPTION%"=="all" if /I not "%OPTION%"=="advanced" if /I not "%OPTION%"=="all allstats advanced" (
	echo ERROR: Bad option [%OPTION%] for the variable "OPTION" [E.g. allstats last] !!
	exit /B %RET%
)
echo %PAUSE% | findstr /r "\<[0-1]\>">NUL
if errorlevel 1 (
	echo ERROR: Invalid flag [%PAUSE%] for the variable "PAUSE" [0-1] !!
	exit /B %RET%
)
echo %DELAY% | findstr /r "\<[1-9]\>">NUL
if errorlevel 1 (
	echo %DELAY% | findstr /r "\<[1-9][0-9]\>">NUL
	if errorlevel 1 (
		echo ERROR: Invalid number [%DELAY%] for the variable "DELAY" [must be range 1-99] !!
		exit /B %RET%
	)
)
set RET=0
goto:EOF
::#
::# End of Check_variables
::#************************************************************#

:Init_files
::#************************************************************#
::# Initializes files used in the program
::#
if defined TARGET set TARGET=%TARGET: =_%
call :Lower TARGET
set IDENTIFIER=
if defined TARGET set IDENTIFIER=%TARGET%_
if not defined LOGIN set IDENTIFIER=%IDENTIFIER%%ORACLE_SID%_%DAT%-%TIM%
if defined LOGIN set IDENTIFIER=%IDENTIFIER%%ORACLE_SID%_%DAT%-%TIM%-%LOGIN%
set file_sql=%SCRIPTDIR%\%progname%_%IDENTIFIER%%.sql
set file_log=%LOGDIR%\%progname%_%IDENTIFIER%.log
set file_tmp=%LOGDIR%\%progname%_%IDENTIFIER%.tmp
:: Renames old files if existing
if exist %file_log% move /Y %file_log% %file_log%.old>NUL

:: Displays the banner in the trace file
call :banner>NUL
goto:EOF
::#
::# End of Init_files
::#************************************************************#

:Cre_audit
::#************************************************************#
::# Generates the audit SQL script
::#
 >%file_sql% echo Rem ---------------------------------------------------------------------------
>>%file_sql% echo Rem SQL script generated automatically by the program "%dirname%\%~nx0".
>>%file_sql% echo Rem %copyright% by %author% - All Rights Reserved.
>>%file_sql% echo Rem ---------------------------------------------------------------------------
>>%file_sql% echo Rem
>>%file_sql% echo set pages 1000 lines %LEN_SQLT% long 999999 serveroutput on size 99999 ver off feed off term off head off trimspool on
>>%file_sql% echo:
>>%file_sql% echo col FMT_TBSP new_value FMT1     noprint
>>%file_sql% echo col FMT_FILE new_value FMT2     noprint
>>%file_sql% echo col FMT_USER new_value FMT3     noprint
>>%file_sql% echo col FMT_TABS new_value FMT4     noprint
>>%file_sql% echo col FMT_OBJS new_value FMT5     noprint
>>%file_sql% echo col RPT_BLKS new_value RPT_BLKS noprint
>>%file_sql% echo col RPT_DBID new_value RPT_DBID noprint
>>%file_sql% echo col RPT_INST new_value RPT_INST noprint
>>%file_sql% echo col RPT_NAME new_value RPT_NAME noprint
>>%file_sql% echo col NOP NOPRINT
>>%file_sql% echo:
>>%file_sql% echo def TOP_NSQL=%TOP_NSQL%
>>%file_sql% echo def FMT_DAT1="%FMT_DAT1%"
>>%file_sql% echo def FMT_DAT2="%FMT_DAT2%"
>>%file_sql% echo def FMT_DAT3="%FMT_DAT3%"
>>%file_sql% echo def RQT_USER="select username from dba_users where default_tablespace not in ('SYSTEM','SYSAUX','PERFSTAT') and username not like ('%_REPORT')"
>>%file_sql% echo:
>>%file_sql% echo select 'a'^|^|to_char^(greatest^(max^(length^(f.tablespace_name^)^),10^)^) FMT_TBSP,
>>%file_sql% echo        'a'^|^|to_char^(greatest^(max^(length^(t.file_name^)^), max^(length^(f.file_name^)^), max^(length^(nvl^(p.value,' '^)^)^)^)^) FMT_FILE
>>%file_sql% echo from dba_temp_files t, dba_data_files f, v$parameter p where p.name = 'spfile';
>>%file_sql% echo select 'a'^|^|to_char^(max^(length^(username^)^)^)   FMT_USER from dba_users;
>>%file_sql% echo select 'a'^|^|to_char^(max^(length^(table_name^)^)^) FMT_TABS from dba_tables where owner in ^(^&RQT_USER^);
>>%file_sql% echo select 'a'^|^|max^(maxlen^) FMT_OBJS
>>%file_sql% echo from ^(select max^(length^(t.table_name^)^) maxlen from dba_tables  t where t.owner in ^(^&RQT_USER^) union
>>%file_sql% echo       select max^(length^(i.index_name^)^) maxlen from dba_indexes i where i.owner in ^(^&RQT_USER^)^);
>>%file_sql% echo select value           RPT_BLKS from v$parameter where name = 'db_block_size';
>>%file_sql% echo select dbid            RPT_DBID,
>>%file_sql% echo        instance_number RPT_INST,
>>%file_sql% echo        instance_name   RPT_NAME from v$database, v$instance;
>>%file_sql% echo:
>>%file_sql% echo alter session set nls_numeric_characters=', ';
>>%file_sql% echo alter session set nls_language=french;
>>%file_sql% echo alter session set nls_territory=france;
>>%file_sql% echo alter session set cursor_sharing=exact;
>>%file_sql% echo:
>>%file_sql% echo set term on head on
>>%file_sql% echo:
>>%file_sql% echo spool %file_log% append
if "%FLG_HOST%" == "1" call :Audit_host
if "%FLG_DB%"   == "1" call :Audit_db
if "%FLG_INIT%" == "1" call :Audit_init
if "%FLG_BAK%" == "1"  call :Audit_bak
if "%FLG_MEM%"  == "1" call :Audit_mem
if "%FLG_TBSP%" == "1" call :Audit_tbsp
if "%FLG_FILE%" == "1" call :Audit_file
if "%FLG_REDO%" == "1" call :Audit_redo
if "%FLG_UNDO%" == "1" call :Audit_undo
if "%FLG_TEMP%" == "1" call :Audit_temp
if "%FLG_OBJ%"  == "1" call :Audit_obj
if "%FLG_ERR%"  == "1" if not "%VER_ORA%"=="10.1" if not "%VER_ORA%"=="10.2" if not "%VER_ORA%"=="11.1" if not "%VER_ORA%"=="11.2" call :Audit_err
if "%FLG_WAIT%" == "1" call :Audit_wait
if "%FLG_USER%" == "1" call :Audit_user
if "%FLG_LOCK%" == "1" call :Audit_lock
if "%FLG_STAT%" == "1" call :Audit_stat
if "%FLG_SQL%"  == "1" call :Audit_sql
>>%file_sql% echo set pages 1000
>>%file_sql% echo:
>>%file_sql% echo clear breaks computes columns
>>%file_sql% echo:
>>%file_sql% echo PROMPT
>>%file_sql% echo PROMPT =============================================================================================================
>>%file_sql% echo PROMPT End of report
>>%file_sql% echo spool off
>>%file_sql% echo exit
goto:EOF
::#
::# End of Cre_audit
::#************************************************************#

:Audit_host
::#************************************************************#
::# Audits host computer for the database
::#
>>%file_sql% echo set head off
>>%file_sql% echo select 'Hostname : ['^|^|host_name^|^|']   User : ['^|^|user^|^|']   Date : ['^|^|to_char^(sysdate,'^&FMT_DAT2'^)^|^|']'
>>%file_sql% echo from v$instance
>>%file_sql% echo /
>>%file_sql% echo:
>>%file_sql% echo select *
>>%file_sql% echo from ^(select 'Platform ^('^|^|to_char^(timestamp,'^&FMT_DAT1'^)^|^|'^) : '^|^|platform_name^|^|'   Sockets : ['^|^|to_char^(nvl^(cpu_socket_count,1^)^)^|^|
>>%file_sql% echo               ']   Cores : ['^|^|to_char^(cpu_core_count^)^|^|']   CPUs : '^|^|lpad^('['^|^|to_char^(cpu_count^)^|^|']',4,' '^)
>>%file_sql% echo        from v$version,
>>%file_sql% echo             v$database,
>>%file_sql% echo             dba_cpu_usage_statistics
>>%file_sql% echo        where banner like 'TNS%%'
>>%file_sql% echo        order by timestamp desc^)
>>%file_sql% echo where rownum ^< 2
>>%file_sql% echo /
>>%file_sql% echo set head on
>>%file_sql% echo:
goto:EOF
::#
::# End of Audit_host
::#************************************************************#

:Audit_db
::#************************************************************#
::# Audits global info for the database and Oracle instance
::#
>>%file_sql% echo PROMPT
>>%file_sql% echo PROMPT +---------------+
>>%file_sql% echo PROMPT ^| Database info ^|
>>%file_sql% echo PROMPT +---------------+
>>%file_sql% echo:
>>%file_sql% echo col aa for a8         head "DB Name"
>>%file_sql% echo col bb for 9999999999 head "DBID"
>>%file_sql% echo col cc for a10        head "Creation"
>>%file_sql% echo col dd for a12        head "Log Mode"
>>%file_sql% echo col ee for a14        head "Startup time"
>>%file_sql% echo col ff for a16        head "Role"
>>%file_sql% echo col gg for a3         head "RAC"
>>%file_sql% echo:
>>%file_sql% echo select v1.name aa,
>>%file_sql% echo        v1.dbid bb,
>>%file_sql% echo        to_char^(v1.created, '^&FMT_DAT1'^) cc,
>>%file_sql% echo        v1.log_mode dd,
>>%file_sql% echo        to_char^(v2.startup_time, '^&FMT_DAT2'^) ee,
>>%file_sql% echo        v1.database_role ff,
>>%file_sql% echo        v3.rac gg
>>%file_sql% echo from v$instance v2,
>>%file_sql% echo      v$database v1,
>>%file_sql% echo      ^(select decode^(count^(1^), 0, 'NO', 'YES'^) RAC from ^(select 1 from v$active_instances where rownum = 1^)^) v3
>>%file_sql% echo /
>>%file_sql% echo:
>>%file_sql% echo col aa for a80 head "Product"
>>%file_sql% echo:
>>%file_sql% echo select banner aa
>>%file_sql% echo from v$version
>>%file_sql% echo where rownum = 1
>>%file_sql% echo /
>>%file_sql% echo:
>>%file_sql% echo col aa for a10  head "DB size"
>>%file_sql% echo col bb for a10  head "Used space"
>>%file_sql% echo col cc for a12  head "Free space"
>>%file_sql% echo col dd for a10  head "  Max size"
>>%file_sql% echo col ee for 999  head "Nbr files"
>>%file_sql% echo col ff for 999  head "Nbr Tbsp"
>>%file_sql% echo col gg for 9999 head "Nbr Arch"
>>%file_sql% echo col hh for a10  head " Size Arch"
>>%file_sql% echo:
>>%file_sql% echo select  round^(sum^(space.tot_size^)/1024^)^|^|' Go' aa,
>>%file_sql% echo         round^(sum^(space.tot_size^)/1024^)-round^(sum^(space.free_size^)/1024^) ^|^| ' Go' bb,
>>%file_sql% echo         round^(sum^(space.free_size^)/1024^) ^|^| ' Go'^|^|' ^('^|^|round^(sum^(space.free_size^)*100/sum^(space.tot_size^)^)^|^|'%%^)' cc,
>>%file_sql% echo         lpad^(round^(sum^(space.max_size^)/1024^)^|^|' Go',10,' '^) dd,
>>%file_sql% echo         count^(space.tablespace_name^) ee,
>>%file_sql% echo         count^(distinct tablespace_name^) ff,
>>%file_sql% echo         max^(arch.nbr^) gg,
>>%file_sql% echo         lpad^(to_char^(round^(nvl^(max^(arch.size_mb/1024^),0^),2^),'990D99'^)^|^|' Go',10,' '^) hh
>>%file_sql% echo from ^(select f1.tablespace_name,
>>%file_sql% echo              max^(f1.bytes/1024/1024^) tot_size,
>>%file_sql% echo              round^(sum^(f2.bytes/^(1024*1024^)^),3^) free_size,
>>%file_sql% echo              decode^(f1.maxbytes,0,max^(f1.bytes^),f1.maxbytes^)/1024/1024 max_size,
>>%file_sql% echo              f1.file_id NOP
>>%file_sql% echo       from dba_data_files f1
>>%file_sql% echo       left outer join dba_free_space f2 on ^(f2.file_id = f1.file_id^)
>>%file_sql% echo       group by f1.tablespace_name, f1.file_id, f1.file_name, f1.autoextensible, f1.maxbytes
>>%file_sql% echo       union
>>%file_sql% echo       select f1.tablespace_name aa,
>>%file_sql% echo              max^(f1.bytes/1024/1024^) tot_size,
>>%file_sql% echo              round^(sum^(f2.bytes_free/^(1024*1024^)^),3^) free_size,
>>%file_sql% echo              decode^(f1.maxbytes,0,max^(f1.bytes^),f1.maxbytes^)/1024/1024 max_size,
>>%file_sql% echo              f1.file_id NOP
>>%file_sql% echo       from v$temp_space_header f2, dba_temp_files f1
>>%file_sql% echo       where f2.file_id = f1.file_id
>>%file_sql% echo       group by f1.tablespace_name, f1.file_id, f1.file_name, f1.autoextensible, f1.maxbytes
>>%file_sql% echo      ^) space,
>>%file_sql% echo      ^(select count^(a.sequence#^) nbr,
>>%file_sql% echo              sum^(a.blocks * a.block_size^)/1024/1024 size_mb
>>%file_sql% echo       from v$archived_log a
>>%file_sql% echo       where a.status = 'A'
>>%file_sql% echo      ^) arch
>>%file_sql% echo /
>>%file_sql% echo:
>>%file_sql% echo PROMPT
>>%file_sql% echo PROMPT +---------------------+
>>%file_sql% echo PROMPT ^| Instance statistics ^|
>>%file_sql% echo PROMPT +---------------------+
>>%file_sql% echo:
>>%file_sql% echo col aa for a15  head "Resource"
>>%file_sql% echo col bb for 9999 head "Current"
>>%file_sql% echo col cc for 9999 head "Max"
>>%file_sql% echo col dd for a10  head "     Limit"
>>%file_sql% echo:
>>%file_sql% echo select resource_name aa,
>>%file_sql% echo        current_utilization bb,
>>%file_sql% echo        max_utilization cc,
>>%file_sql% echo        initcap^(limit_value^) dd
>>%file_sql% echo from v$resource_limit
>>%file_sql% echo where resource_name in ^('processes', 'sessions', 'transactions'^)
>>%file_sql% echo order by 1
>>%file_sql% echo /
goto:EOF
::#
::# End of Audit_db
::#************************************************************#

:Audit_init
::#************************************************************#
::# Audits the init.ora parameter for the database
::#
>>%file_sql% echo:
>>%file_sql% echo PROMPT
>>%file_sql% echo PROMPT +------------------------+
>>%file_sql% echo PROMPT ^| Main system parameters ^|
>>%file_sql% echo PROMPT +------------------------+
>>%file_sql% echo:
>>%file_sql% echo break on bb skip 1
>>%file_sql% echo:
>>%file_sql% echo col aa for a30 head "Parameter Name" trunc
>>%file_sql% echo col bb for a3  head "Def"
>>%file_sql% echo col cc for a55 head "Value" word_wrapped
>>%file_sql% echo col dd for a3  head "Alt|Sys"
>>%file_sql% echo col ee for a3  head "Alt|Ses"
>>%file_sql% echo col ff for a65 head "Description" trunc
>>%file_sql% echo:
>>%file_sql% echo select p.name aa,
>>%file_sql% echo --     decode^(p.isdefault,'TRUE','Yes','No'^) bb,
>>%file_sql% echo        decode^(p.type, '6', decode^(p.value,'0',p.value,decode^(mod^(to_number^(p.value^),1024^),0,to_char^(to_number^(p.value^)/1024/1024^)^|^|'M',p.value^)^), p.value^) cc,
>>%file_sql% echo --     decode^(p.issys_modifiable,'IMMEDIATE','Yes'^) dd,
>>%file_sql% echo --     decode^(p.isses_modifiable,'TRUE','Yes'^) ee,
>>%file_sql% echo        p.Description ff
>>%file_sql% echo from v$parameter p
>>%file_sql% echo where p.isdefault = 'FALSE'
>>%file_sql% echo order by 2, 1
>>%file_sql% echo /
>>%file_sql% echo clear breaks
>>%file_sql% echo col aa clear
>>%file_sql% echo col cc clear
>>%file_sql% echo col ff clear
goto:EOF
::#
::# End of Audit_init
::#************************************************************#

:Audit_bak
::#************************************************************#
::# Audits the configuration and RMAN backups files
::#
>>%file_sql% echo:
>>%file_sql% echo PROMPT
>>%file_sql% echo PROMPT +--------------------+
>>%file_sql% echo PROMPT ^| RMAN configuration ^|
>>%file_sql% echo PROMPT +--------------------+
>>%file_sql% echo:
>>%file_sql% echo col aa for a45 head "Name"
>>%file_sql% echo col bb for a80 head "Value"
>>%file_sql% echo:
>>%file_sql% echo select name aa,
>>%file_sql% echo    	 value bb
>>%file_sql% echo from v$rman_configuration
>>%file_sql% echo order by 1
>>%file_sql% echo /
>>%file_sql% echo:
>>%file_sql% echo PROMPT
>>%file_sql% echo PROMPT +-------------+
>>%file_sql% echo PROMPT ^| RMAN backup ^|
>>%file_sql% echo PROMPT +-------------+
>>%file_sql% echo:
>>%file_sql% echo col aa for a10        head "Backup|Type"
>>%file_sql% echo col bb for a12        head "Backup|Mode"
>>%file_sql% echo col cc for 9999999999 head "Backup|Stamp"
>>%file_sql% echo col dd for a14        head "Time|Completion"
>>%file_sql% echo col ee for 99         head "File#"
>>%file_sql% echo col ff for 999G999    head "File|Size|(Mo)"
>>%file_sql% echo col gg for ^&FMT1      head "Tablespace|Name"
>>%file_sql% echo col hh for 999G990D9  head "Compress|Ratio|(%%)"
>>%file_sql% echo col ii for 999        head "Nbr|Blocks|Corrupt."
>>%file_sql% echo:
>>%file_sql% echo break on aa on bb on cc skip 1
>>%file_sql% echo:
>>%file_sql% echo select b.btype aa,
>>%file_sql% echo        decode^(s.backup_type,'D','FULL', 'I', 'INCR LEVEL '^|^|to_char^(s.incremental_level^), 'ARCH'^) bb,
>>%file_sql% echo        b.id1 cc,
>>%file_sql% echo        to_char^(s.completion_time,'^&FMT_DAT2'^) dd,
>>%file_sql% echo        b.file# ee,
>>%file_sql% echo        trunc^(b.filesize/1024/1024^) ff,
>>%file_sql% echo        b.tsname gg,
>>%file_sql% echo        b.compression_ratio hh,
>>%file_sql% echo        b.marked_corrupt ii,
>>%file_sql% echo        s.completion_time NOP
>>%file_sql% echo from v$backup_datafile_details b join v$backup_set s
>>%file_sql% echo on ^(b.id1 = s.set_stamp and b.id2 = s.set_count^)
>>%file_sql% echo where b.btype = 'BACKUPSET'
>>%file_sql% echo union all
>>%file_sql% echo select b.btype aa,
>>%file_sql% echo        NULL bb,
>>%file_sql% echo        b.id1 dd,
>>%file_sql% echo        to_char^(c.completion_time,'^&FMT_DAT2'^) ee,
>>%file_sql% echo        b.file# ff,
>>%file_sql% echo        trunc^(b.filesize/1024/1024^) gg,
>>%file_sql% echo        b.tsname hh,
>>%file_sql% echo        b.compression_ratio ii,
>>%file_sql% echo        b.marked_corrupt jj,
>>%file_sql% echo        c.completion_time NOP
>>%file_sql% echo from v$backup_datafile_details b join v$datafile_copy c
>>%file_sql% echo on ^(b.id1 = c.recid and b.id2 = c.stamp^)
>>%file_sql% echo where b.btype = 'IMAGECOPY'
>>%file_sql% echo order by 1, 10, 5
>>%file_sql% echo /
>>%file_sql% echo clear breaks
goto:EOF
::#
::# End of Audit_bak
::#************************************************************#

:Audit_mem
::#************************************************************#
::# Audits the memory usage and advisor for the Oracle instance
::#
>>%file_sql% echo:
>>%file_sql% echo PROMPT
>>%file_sql% echo PROMPT +--------------+
>>%file_sql% echo PROMPT ^| Memory usage ^|
>>%file_sql% echo PROMPT +--------------+
>>%file_sql% echo:
>>%file_sql% echo col aa for 999G990 head "Cur|SGA Size|(Mo)"
>>%file_sql% echo col bb for 999G990 head "Cur|PGA Size|(Mo)"
>>%file_sql% echo col cc for 999G990 head "Cur|MEM Size|(Mo)"
>>%file_sql% echo col dd for 999G990 head "Alloc|PGA Size|(Mo)"
>>%file_sql% echo col ee for 999G990 head "Max|MEM Size|(Mo)"
>>%file_sql% echo col ff for 999G990 head "Limit|PGA Size|(Mo)"
>>%file_sql% echo col gg for a1      head ""
>>%file_sql% echo:
>>%file_sql% echo select sga.value/1024/1024 aa,
>>%file_sql% echo        '+' gg,
>>%file_sql% echo        max_pga.value/1024/1024 bb,
>>%file_sql% echo        '=' gg,
if not "%VER_ORA%"=="11.1" if not "%VER_ORA%"=="11.2" if not "%VER_ORA%"=="12.1" if not "%VER_ORA%"=="12.2" if not "%VER_ORA%"=="18.0" (
>>%file_sql% echo      ^(sga.value + max_pga.value^)/1024/1024 cc,
>>%file_sql% echo        pga.value/1024/1024 dd,
>>%file_sql% echo      ^(max_sga.value + max_pga.value^)/1024/1024 ee
)
if not "%VER_ORA%"=="10.1" if not "%VER_ORA%"=="10.2" if not "%VER_ORA%"=="12.1" if not "%VER_ORA%"=="12.2" if not "%VER_ORA%"=="18.0" (
>>%file_sql% echo        case when mem.value = 0 then ^(sga.value+max_pga.value^)/1024/1024 else mem.value/1024/1024 end cc,
>>%file_sql% echo        pga.value/1024/1024 dd,
>>%file_sql% echo        max_mem.value/1024/1024 ee
)
if "%VER_ORA%"=="12.1" (
>>%file_sql% echo        case when mem.value = 0 then ^(sga.value+max_pga.value^)/1024/1024 else mem.value/1024/1024 end cc,
>>%file_sql% echo        pga.value/1024/1024 dd,
>>%file_sql% echo        max_mem.value/1024/1024 ee,
>>%file_sql% echo        lim_pga.value/1024/1024 ff
)
if "%VER_ORA%"=="12.2" (
>>%file_sql% echo        case when mem.value = 0 then ^(sga.value+max_pga.value^)/1024/1024 else mem.value/1024/1024 end cc,
>>%file_sql% echo        pga.value/1024/1024 dd,
>>%file_sql% echo        max_mem.value/1024/1024 ee,
>>%file_sql% echo        lim_pga.value/1024/1024 ff
)
if "%VER_ORA%"=="18.0" (
>>%file_sql% echo        case when mem.value = 0 then ^(sga.value+max_pga.value^)/1024/1024 else mem.value/1024/1024 end cc,
>>%file_sql% echo        pga.value/1024/1024 dd,
>>%file_sql% echo        max_mem.value/1024/1024 ee,
>>%file_sql% echo        lim_pga.value/1024/1024 ff
)
>>%file_sql% echo from ^(select s1.bytes-s2.bytes value from v$sgainfo s1, v$sgainfo s2
>>%file_sql% echo       where s1.name = 'Maximum SGA Size' and s2.name = 'Free SGA Memory Available'^) sga,
>>%file_sql% echo      ^(select value from v$pgastat where name = 'total PGA allocated'^) pga,
>>%file_sql% echo      ^(select to_number^(value^) value from v$parameter where name = 'sga_max_size'^) max_sga,
if not "%VER_ORA%"=="10.1" if not "%VER_ORA%"=="10.2" (
>>%file_sql% echo      ^(select to_number^(value^) value from v$parameter where name = 'memory_target'^) mem,
>>%file_sql% echo      ^(select to_number^(value^) value from v$parameter where name = 'memory_max_target'^) max_mem,
)
if "%VER_ORA%"=="12.1" (
>>%file_sql% echo      ^(select to_number^(value^) value from v$parameter where name = 'pga_aggregate_limit'^) lim_pga,
)
if "%VER_ORA%"=="12.2" (
>>%file_sql% echo      ^(select to_number^(value^) value from v$parameter where name = 'pga_aggregate_limit'^) lim_pga,
)
if "%VER_ORA%"=="18.0" (
>>%file_sql% echo      ^(select to_number^(value^) value from v$parameter where name = 'pga_aggregate_limit'^) lim_pga,
)
>>%file_sql% echo      ^(select value from v$pgastat where name = 'aggregate PGA target parameter'^)  max_pga
>>%file_sql% echo /
>>%file_sql% echo:
>>%file_sql% echo PROMPT
>>%file_sql% echo PROMPT +----------------+
>>%file_sql% echo PROMPT ^| Memory advisor ^|
>>%file_sql% echo PROMPT +----------------+
>>%file_sql% echo:
>>%file_sql% echo col aa for a1          head ">|"
>>%file_sql% echo col bb for 99G999      head "SGA Size|(Mo)"
>>%file_sql% echo col cc for 9G999       head "SGA Size|(%%)"
>>%file_sql% echo col dd for 999G999G999 head "Estd|DB Time|(s)"
>>%file_sql% echo col ee for 999G999     head "Tot Estd| Phys Rds|(M)"
>>%file_sql% echo col ff for a9          head "Gap Estd| Phys Rds|      (%%)"
>>%file_sql% echo col gg for a51         head "Diagnostic alert (Gap>=50%%)"
>>%file_sql% echo:
>>%file_sql% echo select decode^(sga_size_factor*100,100,'^>'^) aa,
>>%file_sql% echo        sga_size bb,
>>%file_sql% echo        sga_size_factor*100 cc,
>>%file_sql% echo        estd_db_time dd,
>>%file_sql% echo        estd_physical_reads/1024/1024 ee,
>>%file_sql% echo        case when sga_size_factor*100^<= 100 then '+' else '-' end ^|^|to_char^(nvl^(estd_physical_reads-lead^(estd_physical_reads^) over ^(order by sga_size^), 0^)*100/replace^(estd_physical_reads,0,1^),'9990D99'^) ff,
>>%file_sql% echo        case when sga_size_factor*100 = 100 then case when nvl^(lead^(estd_physical_reads,1^) over ^(order by sga_size^) - lead^(estd_physical_reads,2^) over ^(order by sga_size^), 0^)*100/replace^(lead^(estd_physical_reads,1^) over ^(order by sga_size^),0,1^) ^>= 50 then '** WARNING: You should increase the SGA value !! **' else '' end end gg
>>%file_sql% echo from v$sga_target_advice
>>%file_sql% echo where sga_size_factor*100 between 50 and 150
>>%file_sql% echo order by 2
>>%file_sql% echo /
>>%file_sql% echo:
>>%file_sql% echo col aa for a1          head ">|"
>>%file_sql% echo col bb for 999G999     head "PGA Size|(Mo)"
>>%file_sql% echo col cc for 9G999       head "PGA Size|(%%)"
>>%file_sql% echo col dd for 999G999G999 head "Estd|Extra|(Mo)"
>>%file_sql% echo col ee for 999G999     head "Tot Estd|Overalloc|"
>>%file_sql% echo col ff for a9          head "Gap Estd|Overalloc|      (%%)"
>>%file_sql% echo col gg for a51         head "Diagnostic alert (Gap>=50%%)"
>>%file_sql% echo:
>>%file_sql% echo select decode^(pga_target_factor*100,100,'^>'^) aa,
>>%file_sql% echo        round^(pga_target_for_estimate/1024/1024^) bb,
>>%file_sql% echo        pga_target_factor*100 cc,
>>%file_sql% echo        round^(estd_extra_bytes_rw/1024/1024^) dd,
>>%file_sql% echo        estd_overalloc_count ee,
>>%file_sql% echo        case when pga_target_factor*100^<= 100 then '+' else '-' end ^|^|to_char^(nvl^(estd_overalloc_count-lead^(estd_overalloc_count^) over ^(order by pga_target_for_estimate^), 0^)*100/replace^(estd_overalloc_count,0,1^),'9990D99'^) ff,
>>%file_sql% echo        case when pga_target_factor*100 = 100 then case when nvl^(lead^(estd_overalloc_count,1^) over ^(order by pga_target_for_estimate^) - lead^(estd_overalloc_count,2^) over ^(order by pga_target_for_estimate^), 0^)*100/replace^(lead^(estd_overalloc_count,1^) over (order by pga_target_for_estimate^),0,1^) ^>= 50 then '** WARNING: You should increase the PGA value !! **' else '' end end gg
>>%file_sql% echo from v$pga_target_advice
>>%file_sql% echo where pga_target_factor*100 between 25 and 400
>>%file_sql% echo order by 2
>>%file_sql% echo /
goto:EOF
::#
::# End of Audit_mem
::#************************************************************#

:Audit_tbsp
::#************************************************************#
::# Audits tablespaces in the database
::#
>>%file_sql% echo:
>>%file_sql% echo PROMPT
>>%file_sql% echo PROMPT +-----------------+
>>%file_sql% echo PROMPT ^| Tablespace info ^|
>>%file_sql% echo PROMPT +-----------------+
>>%file_sql% echo:
>>%file_sql% echo col aa for ^&FMT1 head "Tablespace|Name"
>>%file_sql% echo col bb for 9G999 head "Init|Extent|(Ko)"
>>%file_sql% echo col cc for 9G999 head "Next|Extent|(Ko)"
>>%file_sql% echo col dd for 999   head "Min|Ext"
>>%file_sql% echo col ee for a10   head "Max|Ext"
>>%file_sql% echo col ff for 999   head "Pct|Inc"
>>%file_sql% echo col gg for a9    head "Contents"
>>%file_sql% echo col hh for a9    head "Status"
>>%file_sql% echo col ii for a10   head "Extent|Manag"
>>%file_sql% echo col jj for a7    head "Segment|Space|Manag"
>>%file_sql% echo col kk for a7    head "Alloc|Type"
>>%file_sql% echo col ll for a9    head "Logging"
>>%file_sql% echo col mm for a11   head "Retention"
>>%file_sql% echo col nn for a12   head "Default|Compression"
>>%file_sql% echo:
>>%file_sql% echo select tablespace_name aa,
>>%file_sql% echo        initial_extent/1024 bb,
>>%file_sql% echo        next_extent/1024 cc,
>>%file_sql% echo        min_extents dd,
>>%file_sql% echo        decode^(least^(max_extents,'999999'^),'999999','UNLIMITED',to_char^(max_extents,'99G999G999'^)^) ee,
>>%file_sql% echo        pct_increase ff,
>>%file_sql% echo        contents gg,
>>%file_sql% echo        status hh,
>>%file_sql% echo        extent_management ii,
>>%file_sql% echo        segment_space_management jj,
>>%file_sql% echo        allocation_type kk,
>>%file_sql% echo        logging ll,
if not "%VER_ORA%"=="10.1" if not "%VER_ORA%"=="10.2" (
	>>%file_sql% echo        retention mm,
	>>%file_sql% echo        nvl^(compress_for,'NOCOMPRESS'^) nn
) else (
	>>%file_sql% echo        retention mm
)
>>%file_sql% echo from dba_tablespaces
>>%file_sql% echo order by tablespace_name
>>%file_sql% echo /
goto:EOF
::#
::# End of Audit_tbsp
::#************************************************************#

:Audit_file
::#************************************************************#
::# Audits DB files info and IO activity & history
::#
>>%file_sql% echo:
>>%file_sql% echo PROMPT
>>%file_sql% echo PROMPT +---------------+
>>%file_sql% echo PROMPT ^| Datafile info ^|
>>%file_sql% echo PROMPT +---------------+
>>%file_sql% echo:
>>%file_sql% echo col aa for a4        head "Type"
>>%file_sql% echo col bb for 999       head "Grp"
>>%file_sql% echo col cc for ^&FMT2     head "File|Name"
>>%file_sql% echo col dd for a8        head "Status"
>>%file_sql% echo col ee for 9G999G999 head "Size|(Mo)"
>>%file_sql% echo col ff noprint
>>%file_sql% echo col gg noprint
>>%file_sql% echo:
>>%file_sql% echo break on aa skip 1 on bb on ff on report
>>%file_sql% echo compute sum label "" of ee on aa report
>>%file_sql% echo:
>>%file_sql% echo select 'Ctrl' aa,
>>%file_sql% echo        to_number^(null^) bb,
>>%file_sql% echo        name cc,
>>%file_sql% echo        nvl(status, 'VALID') dd,
if not "%VER_ORA%"=="10.1" if not "%VER_ORA%"=="10.2" (
	>>%file_sql% echo        block_size*file_size_blks/1024/1024 ee,
) else (
	>>%file_sql% echo        null ee,
)
>>%file_sql% echo        null ff,
>>%file_sql% echo        null gg
>>%file_sql% echo from v$controlfile
>>%file_sql% echo union
>>%file_sql% echo select 'Data' aa,
>>%file_sql% echo        to_number^(null^) bb,
>>%file_sql% echo        name cc,
>>%file_sql% echo        replace^(status, 'SYSTEM', 'ONLINE'^) dd,
>>%file_sql% echo        bytes / ^(1024*1024^) ee,
>>%file_sql% echo        ts# ff,
>>%file_sql% echo        file# gg
>>%file_sql% echo from v$datafile
>>%file_sql% echo where ts# not in ^(select ts# from v$tablespace
>>%file_sql% echo                   where name in ^(select value from v$parameter where name='undo_tablespace'^)^)
>>%file_sql% echo union
>>%file_sql% echo select 'Temp' aa,
>>%file_sql% echo        to_number^(null^) bb,
>>%file_sql% echo        name cc,
>>%file_sql% echo        status dd,
>>%file_sql% echo        bytes / ^(1024*1024^) ee,
>>%file_sql% echo        ts# ff,
>>%file_sql% echo        file# gg
>>%file_sql% echo from v$tempfile
>>%file_sql% echo union
>>%file_sql% echo select 'Redo' aa,
>>%file_sql% echo        lf.group# bb,
>>%file_sql% echo        lf.member cc,
>>%file_sql% echo        l.status dd,
>>%file_sql% echo        l.bytes / ^(1024 * 1024^) ee,
>>%file_sql% echo        null ff,
>>%file_sql% echo        null gg
>>%file_sql% echo from v$log l, v$logfile lf
>>%file_sql% echo where l.group# = lf.group#
>>%file_sql% echo union
>>%file_sql% echo select 'Undo' aa,
>>%file_sql% echo         to_number^(null^) bb,
>>%file_sql% echo         name cc,
>>%file_sql% echo         status dd,
>>%file_sql% echo         bytes / ^(1024*1024^) ee,
>>%file_sql% echo        null ff,
>>%file_sql% echo        null gg
>>%file_sql% echo from v$datafile
>>%file_sql% echo where ts# in ^(select ts# from v$tablespace
>>%file_sql% echo               where name in ^(select value from v$parameter where name='undo_tablespace'^)^)
>>%file_sql% echo order by 1, 2, 6, 7
>>%file_sql% echo /
>>%file_sql% echo col ff clear
>>%file_sql% echo col gg clear
>>%file_sql% echo clear breaks computes
>>%file_sql% echo:
>>%file_sql% echo PROMPT
>>%file_sql% echo PROMPT +----------------+
>>%file_sql% echo PROMPT ^| Datafile usage ^|
>>%file_sql% echo PROMPT +----------------+
>>%file_sql% echo:
>>%file_sql% echo col aa for ^&FMT1       head "Tablespace|Name"
>>%file_sql% echo col bb for ^&FMT2       head "File Name"
>>%file_sql% echo col cc for 9G999G999   head "Size|(Mo)"
>>%file_sql% echo col dd for 999G999     head "Free|(Mo)"
>>%file_sql% echo col ee for 999         head "Free|(%%)"
>>%file_sql% echo col ff for a3          head "Aut|Ext"
>>%file_sql% echo col gg for 999G999G999 head "Max|Size|(Mo)"
>>%file_sql% echo:
>>%file_sql% echo break on aa on report
>>%file_sql% echo compute sum label "" of cc dd gg on report
>>%file_sql% echo:
>>%file_sql% echo select f1.tablespace_name aa,
>>%file_sql% echo        f1.file_name bb,
>>%file_sql% echo        max^(f1.bytes/1024/1024^) cc,
>>%file_sql% echo        round^(sum^(nvl(f2.bytes,0)/^(1024*1024^)^),3^) dd,
>>%file_sql% echo        round^(sum^(f2.bytes/^(1024*1024^)^),3^)*100/max^(f1.bytes/1024/1024^) ee,
>>%file_sql% echo        initcap^(replace^(f1.autoextensible,'NO',''^)^) ff,
>>%file_sql% echo        to_number^(decode^(f1.maxbytes,0,null,f1.maxbytes/1024/1024^)^) gg,
>>%file_sql% echo        f1.file_id NOP
>>%file_sql% echo from dba_data_files f1
>>%file_sql% echo left outer join dba_free_space f2 on (f2.file_id = f1.file_id)
>>%file_sql% echo group by f1.tablespace_name, f1.file_id, f1.file_name, f1.autoextensible, f1.maxbytes
>>%file_sql% echo union
>>%file_sql% echo select f1.tablespace_name aa,
>>%file_sql% echo        decode^(greatest^(length^(f1.file_name^),55^),55, f1.file_name,
>>%file_sql% echo               '..'^|^|substr^(f1.file_name,-50^)^) bb,
>>%file_sql% echo        max^(f1.bytes/1024/1024^) cc,
>>%file_sql% echo        round^(sum^(f2.bytes_free/^(1024*1024^)^),3^) dd,
>>%file_sql% echo        round^(sum^(f2.bytes_free/^(1024*1024^)^),3^)*100/max^(f1.bytes/1024/1024^) ee,
>>%file_sql% echo        initcap^(replace^(f1.autoextensible,'NO',''^)^) ff,
>>%file_sql% echo        to_number^(decode^(f1.maxbytes,0,null,f1.maxbytes/1024/1024^)^) gg,
>>%file_sql% echo        f1.file_id NOP
>>%file_sql% echo from v$temp_space_header f2, dba_temp_files f1
>>%file_sql% echo where f2.file_id = f1.file_id
>>%file_sql% echo group by f1.tablespace_name, f1.file_id, f1.file_name, f1.autoextensible, f1.maxbytes
>>%file_sql% echo order by 1, 8
>>%file_sql% echo /
>>%file_sql% echo clear breaks computes
>>%file_sql% echo:
>>%file_sql% echo PROMPT
>>%file_sql% echo PROMPT +-------------------+
>>%file_sql% echo PROMPT ^| Datafile activity ^|
>>%file_sql% echo PROMPT +-------------------+
>>%file_sql% echo:
>>%file_sql% echo col aa for 999           head "Id"
>>%file_sql% echo col bb for ^&FMT2         head "File Name"
>>%file_sql% echo col cc for a9            head "Asynch|IO"
>>%file_sql% echo col dd for 990D99        head "Total| IO| (%%)"
>>%file_sql% echo col ee for 9G990D99      head "Av |Read|(ms)"
>>%file_sql% echo col ff for 9G990D99      head "Av |Write|(ms)"
>>%file_sql% echo:
>>%file_sql% echo col sum_io1 new_value st1   NOPRINT
>>%file_sql% echo col sum_io2 new_value st2   NOPRINT
>>%file_sql% echo col sum_io  new_value total NOPRINT
>>%file_sql% echo:
>>%file_sql% echo set pages 0
>>%file_sql% echo select nvl^(sum(a.phyrds+a.phywrts^),0^) sum_io1 from v$filestat a;
>>%file_sql% echo select nvl^(sum(b.phyrds+b.phywrts^),0^) sum_io2 from v$tempstat b;
>>%file_sql% echo select ^&st1+^&st2 sum_io from dual;
>>%file_sql% echo set pages 1000
>>%file_sql% echo:
>>%file_sql% echo compute avg of ee ff on report
>>%file_sql% echo compute sum of dd    on report
>>%file_sql% echo break on NOP skip 1  on report
>>%file_sql% echo:
>>%file_sql% echo select a.file# aa,
>>%file_sql% echo        b.name bb,
if not "%VER_ORA%"=="10.1" if not "%VER_ORA%"=="10.2" if not "%VER_ORA%"=="11.1" (
	>>%file_sql% echo        c.asynch_io cc,
)
>>%file_sql% echo        100*^(a.phyrds+a.phywrts^)/^&total dd,
>>%file_sql% echo        round^(a.readtim/greatest^(a.phyrds,1^),3^)*10 ee,
>>%file_sql% echo        round^(a.writetim/greatest^(a.phywrts,1^),3)*10 ff,
>>%file_sql% echo        decode^(instr^(b.name,'/'^),0, substr^(b.name,1,instr^(name,'\',-1^)-1^), substr^(b.name,1,instr^(b.name,'/',-1^)-1^)^) NOP
if not "%VER_ORA%"=="10.1" if not "%VER_ORA%"=="10.2" if not "%VER_ORA%"=="11.1" (
	>>%file_sql% echo from v$filestat a, v$dbfile b, v$iostat_file c
	>>%file_sql% echo where a.file#   = b.file#
	>>%file_sql% echo and   c.file_no = a.file#
	>>%file_sql% echo and   c.filetype_name = 'Data File'
)
if "%VER_ORA%"=="10.1" >>%file_sql% echo from v$filestat a, v$dbfile b
if "%VER_ORA%"=="10.2" >>%file_sql% echo from v$filestat a, v$dbfile b
if "%VER_ORA%"=="11.1" >>%file_sql% echo from v$filestat a, v$dbfile b
if "%VER_ORA%"=="10.1" >>%file_sql% echo where a.file#   = b.file#
if "%VER_ORA%"=="10.2" >>%file_sql% echo where a.file#   = b.file#
if "%VER_ORA%"=="11.1" >>%file_sql% echo where a.file#   = b.file#
>>%file_sql% echo union
>>%file_sql% echo select a.file# aa,
>>%file_sql% echo        b.name bb,
if not "%VER_ORA%"=="10.1" if not "%VER_ORA%"=="10.2" if not "%VER_ORA%"=="11.1" (
	>>%file_sql% echo        c.asynch_io cc,
)
>>%file_sql% echo        100*^(a.phyrds+a.phywrts^)/^&total dd,
>>%file_sql% echo        round^(a.readtim/greatest^(a.phyrds,1^),3^)*10 ee,
>>%file_sql% echo        round^(a.writetim/greatest^(a.phywrts,1^),3^)*10 ff,
>>%file_sql% echo        decode^(instr^(b.name,'/'^),0, substr^(b.name,1,instr^(name,'\',-1^)-1^), substr^(b.name,1,instr^(b.name,'/',-1^)-1^)^) NOP
if not "%VER_ORA%"=="10.1" if not "%VER_ORA%"=="10.2" if not "%VER_ORA%"=="11.1" (
	>>%file_sql% echo from v$tempstat a, v$tempfile b, v$iostat_file c
	>>%file_sql% echo where a.file# = b.file#
	>>%file_sql% echo and   c.file_no = a.file#
	>>%file_sql% echo and   c.filetype_name = 'Temp File'
	>>%file_sql% echo order by 7, 4 desc, 2
)
if "%VER_ORA%"=="10.1" >>%file_sql% echo from v$tempstat a, v$tempfile b
if "%VER_ORA%"=="10.1" >>%file_sql% echo where a.file# = b.file#
if "%VER_ORA%"=="10.1" >>%file_sql% echo order by 6, 3 desc, 2
if "%VER_ORA%"=="10.2" >>%file_sql% echo from v$tempstat a, v$tempfile b
if "%VER_ORA%"=="10.2" >>%file_sql% echo where a.file# = b.file#
if "%VER_ORA%"=="10.2" >>%file_sql% echo order by 6, 3 desc, 2
if "%VER_ORA%"=="11.1" >>%file_sql% echo from v$tempstat a, v$tempfile b
if "%VER_ORA%"=="11.1" >>%file_sql% echo where a.file# = b.file#
if "%VER_ORA%"=="11.1" >>%file_sql% echo order by 6, 3 desc, 2
>>%file_sql% echo /
>>%file_sql% echo clear breaks computes
>>%file_sql% echo:
>>%file_sql% echo PROMPT
>>%file_sql% echo PROMPT +-------------+
>>%file_sql% echo PROMPT ^| IO activity ^|
>>%file_sql% echo PROMPT +-------------+
>>%file_sql% echo:
>>%file_sql% echo set pages 0
>>%file_sql% echo col NBR_SESS new_value NBR_SESS NOPRINT
>>%file_sql% echo select greatest^(count^(username^),1^) NBR_SESS from v$session where username in ^(^&RQT_USER^);
>>%file_sql% echo select 'Total sessions : '^|^|ltrim^('^&NBR_SESS'^) from dual;
>>%file_sql% echo set pages 1000
>>%file_sql% echo:
>>%file_sql% echo col aa for a3        head "Avg|Max"
>>%file_sql% echo col bb for 99G999    head "Read|IOPS"
>>%file_sql% echo col cc for 99G999    head "Write|IOPS"
>>%file_sql% echo col dd for 990D99    head "Read|MBPS"
>>%file_sql% echo col ee for 990D99    head "Write|MBPS"
>>%file_sql% echo col ff for 99G999    head "Total|IOPS"
>>%file_sql% echo col gg for 9G990D99  head "Total|MBPS"
>>%file_sql% echo col hh for 9G990D99  head "IOPS|/Session"
>>%file_sql% echo:
>>%file_sql% echo select 'Avg' aa,
>>%file_sql% echo        avg^(read_iops^)  bb,
>>%file_sql% echo        avg^(write_iops^) cc,
>>%file_sql% echo        avg^(read_mbps^)/1024/1024  dd,
>>%file_sql% echo        avg^(write_mbps^)/1024/1024 ee,
>>%file_sql% echo        round^(avg^(read_iops + write_iops^)^) ff,
>>%file_sql% echo        ^(avg^(read_mbps + write_mbps^)^)/1024/1024 gg,
>>%file_sql% echo        ^(round^(avg^(read_iops + write_iops^)^)^)/^&NBR_SESS hh
>>%file_sql% echo from ^(select h.snap_id,
>>%file_sql% echo              sum^(case h.metric_name when 'Physical Read Total IO Requests Per Sec'  then round^(average^) end^) read_iops,
>>%file_sql% echo              sum^(case h.metric_name when 'Physical Write Total IO Requests Per Sec' then round^(average^) end^) write_iops,
>>%file_sql% echo              sum^(case h.metric_name when 'Physical Read Total Bytes Per Sec'        then round^(average^) end^) read_mbps,
>>%file_sql% echo              sum^(case h.metric_name when 'Physical Write Total Bytes Per Sec'       then round^(average^) end^) write_mbps
>>%file_sql% echo       from dba_hist_sysmetric_summary h
>>%file_sql% echo       group by h.snap_id^)
>>%file_sql% echo union
>>%file_sql% echo select 'Max' aa,
>>%file_sql% echo        max^(read_iops^)  bb,
>>%file_sql% echo        max^(write_iops^) cc,
>>%file_sql% echo        max^(read_mbps^)/1024/1024  dd,
>>%file_sql% echo        max^(write_mbps^)/1024/1024 ee,
>>%file_sql% echo        max^(read_iops + write_iops^) ff,
>>%file_sql% echo        ^(max^(read_mbps + write_mbps^)^)/1024/1024 gg,
>>%file_sql% echo        ^(max^(read_iops + write_iops^)^)/^&NBR_SESS hh
>>%file_sql% echo from ^(select h.snap_id,
>>%file_sql% echo              sum^(case h.metric_name when 'Physical Read Total IO Requests Per Sec'  then round^(average^) end^) read_iops,
>>%file_sql% echo              sum^(case h.metric_name when 'Physical Write Total IO Requests Per Sec' then round^(average^) end^) write_iops,
>>%file_sql% echo              sum^(case h.metric_name when 'Physical Read Total Bytes Per Sec'        then round^(average^) end^) read_mbps,
>>%file_sql% echo              sum^(case h.metric_name when 'Physical Write Total Bytes Per Sec'       then round^(average^) end^) write_mbps
>>%file_sql% echo       from dba_hist_sysmetric_summary h
>>%file_sql% echo       group by h.snap_id^)
>>%file_sql% echo /
>>%file_sql% echo clear breaks computes
>>%file_sql% echo:
>>%file_sql% echo PROMPT
>>%file_sql% echo PROMPT +------------+
>>%file_sql% echo PROMPT ^| IO history ^|
>>%file_sql% echo PROMPT +------------+
>>%file_sql% echo:
>>%file_sql% echo col begin_snap_in new_value begin_snap NOPRINT
>>%file_sql% echo col begin_date_in new_value begin_date NOPRINT
>>%file_sql% echo col end_snap_in   new_value end_snap   NOPRINT
>>%file_sql% echo col end_date_in   new_value end_date   NOPRINT
>>%file_sql% echo:
>>%file_sql% echo set pages 0
>>%file_sql% echo select min^(snap_id^) begin_snap_in, to_char^(min^(begin_time^),'^&FMT_DAT1'^) begin_date_in,
>>%file_sql% echo        max^(snap_id^)   end_snap_in, to_char^(max^(begin_time^),'^&FMT_DAT1'^) end_date_in
>>%file_sql% echo from dba_hist_sysmetric_summary;
>>%file_sql% echo set pages 2000
>>%file_sql% echo:
>>%file_sql% echo set term on head on
>>%file_sql% echo:
>>%file_sql% echo def begin_hour=00:00
>>%file_sql% echo def end_hour=23:59
>>%file_sql% echo:
>>%file_sql% echo PROMPT Begin : ^&begin_date ^&begin_hour
>>%file_sql% echo PROMPT End   : ^&end_date ^&end_hour
>>%file_sql% echo:
>>%file_sql% echo col aa for a8       head "Snap|Date"
>>%file_sql% echo col bb for a5       head "Snap|Time"
>>%file_sql% echo col cc for 99999    head "Snap|ID"
>>%file_sql% echo col dd for 99G999   head "TOTAL|IOPS"
>>%file_sql% echo col ee for 9G990D99 head "TOTAL|(MB/s)"
>>%file_sql% echo col ff for 99G999   head "Read|IOPS"
>>%file_sql% echo col gg for 99G999   head "Write|IOPS"
>>%file_sql% echo col hh for 990D9    head "Ratio|IOPS"
>>%file_sql% echo col ii for 9G990D99 head "Read/s|(MB/s)"
>>%file_sql% echo col jj for 9G990D99 head "Write/s|(MB/s)"
>>%file_sql% echo col kk for 9G990D9  head "Ratio|(MB/s)"
>>%file_sql% echo:
>>%file_sql% echo break on aa skip 1 on report
>>%file_sql% echo compute avg label 'avg' min label 'Min' max label 'Max' of dd ee on report
>>%file_sql% echo:
>>%file_sql% echo select to_char^(min^(h.begin_time^),'^&FMT_DAT1'^) aa,
>>%file_sql% echo        to_char^(min^(h.begin_time^),'HH24:MI'^) bb,
>>%file_sql% echo        h.snap_id cc,
>>%file_sql% echo        sum^(case h.metric_name        when 'Physical Read Total IO Requests Per Sec'  then round^(average^) end^) +
>>%file_sql% echo               sum^(case h.metric_name when 'Physical Write Total IO Requests Per Sec' then round^(average^) end^) dd,
>>%file_sql% echo        round^(^(sum^(case h.metric_name when 'Physical Read Total Bytes Per Sec'        then round^(average^) end^) +
>>%file_sql% echo               sum^(case h.metric_name when 'Physical Write Total Bytes Per Sec'       then round^(average^) end^)^)/1024/1024, 2^) ee,
>>%file_sql% echo        sum^(case h.metric_name        when 'Physical Read Total IO Requests Per Sec'  then round^(average^) end^) ff,
>>%file_sql% echo        sum^(case h.metric_name        when 'Physical Write Total IO Requests Per Sec' then round^(average^) end^) gg,
>>%file_sql% echo        round^(sum^(case h.metric_name  when 'Physical Read Total IO Requests Per Sec'  then round^(average^) end^) /
>>%file_sql% echo               sum^(case h.metric_name when 'Physical Write Total IO Requests Per Sec' then round^(average^) end^),1^) hh,
>>%file_sql% echo        round^(sum^(case h.metric_name  when 'Physical Read Total Bytes Per Sec'        then round^(average^) end^)/1024/1024, 2^) ii,
>>%file_sql% echo        round^(sum^(case h.metric_name  when 'Physical Write Total Bytes Per Sec'       then round^(average^) end^)/1024/1024, 2^) jj,
>>%file_sql% echo        round^(sum^(case h.metric_name  when 'Physical Read Total Bytes Per Sec'        then round^(average^) end^) /
>>%file_sql% echo               sum^(case h.metric_name when 'Physical Write Total Bytes Per Sec'       then round^(average^) end^),1^) kk
>>%file_sql% echo from dba_hist_sysmetric_summary h
>>%file_sql% echo where h.snap_id between ^&begin_snap and ^&end_snap
>>%file_sql% echo   and h.dbid             = ^&RPT_DBID
>>%file_sql% echo   and h.instance_number  = ^&RPT_INST
>>%file_sql% echo   and begin_time between to_date^(trunc^(begin_time^)^|^|' ^&begin_hour','^&FMT_DAT3'^)
>>%file_sql% echo                      and to_date^(trunc^(begin_time^)^|^|' ^&end_hour','^&FMT_DAT3'^)
>>%file_sql% echo group by h.snap_id
>>%file_sql% echo order by 3
>>%file_sql% echo /
>>%file_sql% echo clear breaks computes
goto:EOF
::#
::# End of Audit_file
::#************************************************************#

:Audit_redo
::#************************************************************#
::# Audits info and activity for redologs in the database
::#
>>%file_sql% echo:
>>%file_sql% echo PROMPT
>>%file_sql% echo PROMPT +---------------+
>>%file_sql% echo PROMPT ^| Redo log info ^|
>>%file_sql% echo PROMPT +---------------+
>>%file_sql% echo:
>>%file_sql% echo break on aa skip 1 on bb on cc on dd on report
>>%file_sql% echo compute sum of ff on report
>>%file_sql% echo:
>>%file_sql% echo col aa for 9              head "Grp"
>>%file_sql% echo col bb for 999999         head "Log Seq"
>>%file_sql% echo col cc for 99999999999999 head "First SCN"
if not "%VER_ORA%"=="10.1" if not "%VER_ORA%"=="10.2" if not "%VER_ORA%"=="11.1" >>%file_sql% echo col dd for 99999999999999 head "Last|SCN"
>>%file_sql% echo col ee for ^&FMT2         head "File"
>>%file_sql% echo col ff for 99G999         head "Size|(Mo)"
>>%file_sql% echo col gg for a8             head "Status"
>>%file_sql% echo col hh for a19            head "Switch time"
>>%file_sql% echo col ii for a5             head "Archived?"
>>%file_sql% echo:
>>%file_sql% echo select a.group# aa,
>>%file_sql% echo        a.sequence# bb,
>>%file_sql% echo        a.first_change# cc,
if not "%VER_ORA%"=="10.1" if not "%VER_ORA%"=="10.2" if not "%VER_ORA%"=="11.1"  >>%file_sql% echo        to_number^(decode^(a.next_time,null,null,a.next_change#-1^)^) dd,
>>%file_sql% echo        b.member ee,
>>%file_sql% echo        a.bytes/1024/1024 ff,
>>%file_sql% echo        a.status gg,
>>%file_sql% echo        to_char^(a.first_time,'^&FMT_DAT3'^) hh,
>>%file_sql% echo        decode^(a.archived,'YES','Yes','NO','No'^) ii
>>%file_sql% echo from v$log a, v$logfile b
>>%file_sql% echo where a.group# = b.group#
>>%file_sql% echo order by a.group#
>>%file_sql% echo /
>>%file_sql% echo clear breaks computes
>>%file_sql% echo:
>>%file_sql% echo PROMPT
>>%file_sql% echo PROMPT +-------------------+
>>%file_sql% echo PROMPT ^| Redo log activity ^|
>>%file_sql% echo PROMPT +-------------------+
>>%file_sql% echo:
>>%file_sql% echo col Week for a4   head "Week"
>>%file_sql% echo col Day  for a10  head "Day"
>>%file_sql% echo col aa   for a3   head " 00"
>>%file_sql% echo col bb   for a3   head " 01"
>>%file_sql% echo col cc   for a3   head " 02"
>>%file_sql% echo col dd   for a3   head " 03"
>>%file_sql% echo col ee   for a3   head " 04"
>>%file_sql% echo col ff   for a3   head " 05"
>>%file_sql% echo col gg   for a3   head " 06"
>>%file_sql% echo col hh   for a3   head " 07"
>>%file_sql% echo col ii   for a3   head " 08"
>>%file_sql% echo col jj   for a3   head " 09"
>>%file_sql% echo col kk   for a3   head " 10"
>>%file_sql% echo col ll   for a3   head " 11"
>>%file_sql% echo col mm   for a3   head " 12"
>>%file_sql% echo col nn   for a3   head " 13"
>>%file_sql% echo col oo   for a3   head " 14"
>>%file_sql% echo col pp   for a3   head " 15"
>>%file_sql% echo col qq   for a3   head " 16"
>>%file_sql% echo col rr   for a3   head " 17"
>>%file_sql% echo col ss   for a3   head " 18"
>>%file_sql% echo col tt   for a3   head " 19"
>>%file_sql% echo col uu   for a3   head " 20"
>>%file_sql% echo col vv   for a3   head " 21"
>>%file_sql% echo col ww   for a3   head " 22"
>>%file_sql% echo col xx   for a3   head " 23"
>>%file_sql% echo col yy   for 9999 head "Sum"
>>%file_sql% echo col zz   for 999  head "Avg"
>>%file_sql% echo:
>>%file_sql% echo compute max label "Max" avg label "Avg" of yy zz on report
>>%file_sql% echo break on Week skip 1 on report
>>%file_sql% echo:
>>%file_sql% echo select to_char^(first_time,'WW'^) Week,
>>%file_sql% echo        max^(first_time^) NOP,
>>%file_sql% echo        substr^(to_char^(first_time,'Day'^),1,3^)^|^|to_char^(first_time,' DD/MM'^) Day,
>>%file_sql% echo        lpad^(decode^(sum^(decode^(substr^(to_char^(first_time,'HH24'^),1,2^),'00',1,0^)^),0,'-',sum^(decode^(substr^(to_char^(first_time,'HH24'^),1,2^),'00',1,0^)^)^),3,' '^) aa,
>>%file_sql% echo        lpad^(decode^(sum^(decode^(substr^(to_char^(first_time,'HH24'^),1,2^),'01',1,0^)^),0,'-',sum^(decode^(substr^(to_char^(first_time,'HH24'^),1,2^),'01',1,0^)^)^),3,' '^) bb,
>>%file_sql% echo        lpad^(decode^(sum^(decode^(substr^(to_char^(first_time,'HH24'^),1,2^),'02',1,0^)^),0,'-',sum^(decode^(substr^(to_char^(first_time,'HH24'^),1,2^),'02',1,0^)^)^),3,' '^) cc,
>>%file_sql% echo        lpad^(decode^(sum^(decode^(substr^(to_char^(first_time,'HH24'^),1,2^),'03',1,0^)^),0,'-',sum^(decode^(substr^(to_char^(first_time,'HH24'^),1,2^),'03',1,0^)^)^),3,' '^) dd,
>>%file_sql% echo        lpad^(decode^(sum^(decode^(substr^(to_char^(first_time,'HH24'^),1,2^),'04',1,0^)^),0,'-',sum^(decode^(substr^(to_char^(first_time,'HH24'^),1,2^),'04',1,0^)^)^),3,' '^) ee,
>>%file_sql% echo        lpad^(decode^(sum^(decode^(substr^(to_char^(first_time,'HH24'^),1,2^),'05',1,0^)^),0,'-',sum^(decode^(substr^(to_char^(first_time,'HH24'^),1,2^),'05',1,0^)^)^),3,' '^) ff,
>>%file_sql% echo        lpad^(decode^(sum^(decode^(substr^(to_char^(first_time,'HH24'^),1,2^),'06',1,0^)^),0,'-',sum^(decode^(substr^(to_char^(first_time,'HH24'^),1,2^),'06',1,0^)^)^),3,' '^) gg,
>>%file_sql% echo        lpad^(decode^(sum^(decode^(substr^(to_char^(first_time,'HH24'^),1,2^),'07',1,0^)^),0,'-',sum^(decode^(substr^(to_char^(first_time,'HH24'^),1,2^),'07',1,0^)^)^),3,' '^) hh,
>>%file_sql% echo        lpad^(decode^(sum^(decode^(substr^(to_char^(first_time,'HH24'^),1,2^),'08',1,0^)^),0,'-',sum^(decode^(substr^(to_char^(first_time,'HH24'^),1,2^),'08',1,0^)^)^),3,' '^) ii,
>>%file_sql% echo        lpad^(decode^(sum^(decode^(substr^(to_char^(first_time,'HH24'^),1,2^),'09',1,0^)^),0,'-',sum^(decode^(substr^(to_char^(first_time,'HH24'^),1,2^),'09',1,0^)^)^),3,' '^) jj,
>>%file_sql% echo        lpad^(decode^(sum^(decode^(substr^(to_char^(first_time,'HH24'^),1,2^),'10',1,0^)^),0,'-',sum^(decode^(substr^(to_char^(first_time,'HH24'^),1,2^),'10',1,0^)^)^),3,' '^) kk,
>>%file_sql% echo        lpad^(decode^(sum^(decode^(substr^(to_char^(first_time,'HH24'^),1,2^),'11',1,0^)^),0,'-',sum^(decode^(substr^(to_char^(first_time,'HH24'^),1,2^),'11',1,0^)^)^),3,' '^) ll,
>>%file_sql% echo        lpad^(decode^(sum^(decode^(substr^(to_char^(first_time,'HH24'^),1,2^),'12',1,0^)^),0,'-',sum^(decode^(substr^(to_char^(first_time,'HH24'^),1,2^),'12',1,0^)^)^),3,' '^) mm,
>>%file_sql% echo        lpad^(decode^(sum^(decode^(substr^(to_char^(first_time,'HH24'^),1,2^),'13',1,0^)^),0,'-',sum^(decode^(substr^(to_char^(first_time,'HH24'^),1,2^),'13',1,0^)^)^),3,' '^) nn,
>>%file_sql% echo        lpad^(decode^(sum^(decode^(substr^(to_char^(first_time,'HH24'^),1,2^),'14',1,0^)^),0,'-',sum^(decode^(substr^(to_char^(first_time,'HH24'^),1,2^),'14',1,0^)^)^),3,' '^) oo,
>>%file_sql% echo        lpad^(decode^(sum^(decode^(substr^(to_char^(first_time,'HH24'^),1,2^),'15',1,0^)^),0,'-',sum^(decode^(substr^(to_char^(first_time,'HH24'^),1,2^),'15',1,0^)^)^),3,' '^) pp,
>>%file_sql% echo        lpad^(decode^(sum^(decode^(substr^(to_char^(first_time,'HH24'^),1,2^),'16',1,0^)^),0,'-',sum^(decode^(substr^(to_char^(first_time,'HH24'^),1,2^),'16',1,0^)^)^),3,' '^) qq,
>>%file_sql% echo        lpad^(decode^(sum^(decode^(substr^(to_char^(first_time,'HH24'^),1,2^),'17',1,0^)^),0,'-',sum^(decode^(substr^(to_char^(first_time,'HH24'^),1,2^),'17',1,0^)^)^),3,' '^) rr,
>>%file_sql% echo        lpad^(decode^(sum^(decode^(substr^(to_char^(first_time,'HH24'^),1,2^),'18',1,0^)^),0,'-',sum^(decode^(substr^(to_char^(first_time,'HH24'^),1,2^),'18',1,0^)^)^),3,' '^) ss,
>>%file_sql% echo        lpad^(decode^(sum^(decode^(substr^(to_char^(first_time,'HH24'^),1,2^),'19',1,0^)^),0,'-',sum^(decode^(substr^(to_char^(first_time,'HH24'^),1,2^),'19',1,0^)^)^),3,' '^) tt,
>>%file_sql% echo        lpad^(decode^(sum^(decode^(substr^(to_char^(first_time,'HH24'^),1,2^),'20',1,0^)^),0,'-',sum^(decode^(substr^(to_char^(first_time,'HH24'^),1,2^),'20',1,0^)^)^),3,' '^) uu,
>>%file_sql% echo        lpad^(decode^(sum^(decode^(substr^(to_char^(first_time,'HH24'^),1,2^),'21',1,0^)^),0,'-',sum^(decode^(substr^(to_char^(first_time,'HH24'^),1,2^),'21',1,0^)^)^),3,' '^) vv,
>>%file_sql% echo        lpad^(decode^(sum^(decode^(substr^(to_char^(first_time,'HH24'^),1,2^),'22',1,0^)^),0,'-',sum^(decode^(substr^(to_char^(first_time,'HH24'^),1,2^),'22',1,0^)^)^),3,' '^) ww,
>>%file_sql% echo        lpad^(decode^(sum^(decode^(substr^(to_char^(first_time,'HH24'^),1,2^),'23',1,0^)^),0,'-',sum^(decode^(substr^(to_char^(first_time,'HH24'^),1,2^),'23',1,0^)^)^),3,' '^) xx,
>>%file_sql% echo        count^(first_time^) yy,
>>%file_sql% echo        count^(first_time^)/24 zz
>>%file_sql% echo from v$log_history
>>%file_sql% echo where trunc^(first_time^) ^>= trunc^(sysdate-30^)
>>%file_sql% echo group by to_char^(first_time,'WW'^), substr^(to_char^(first_time,'Day'^),1,3^)^|^|to_char^(first_time,' DD/MM'^)
>>%file_sql% echo order by 2
>>%file_sql% echo /
>>%file_sql% echo clear breaks computes
goto:EOF
::#
::# End of Audit_redo
::#************************************************************#

:Audit_undo
::#************************************************************#
::# Audits usage and activity for the UNDO tablespace in the database
::#
>>%file_sql% echo:
>>%file_sql% echo PROMPT
>>%file_sql% echo PROMPT +------------+
>>%file_sql% echo PROMPT ^| UNDO usage ^|
>>%file_sql% echo PROMPT +------------+
>>%file_sql% echo:
>>%file_sql% echo col aa for ^&FMT1   head "Tablespace|Name"
>>%file_sql% echo col bb for 999G999 head "Total|Size|(Mo)"
>>%file_sql% echo col cc for 999G999 head "Used|Space|(Mo)"
>>%file_sql% echo col dd for 999     head "Used|Space|(%%)"
>>%file_sql% echo col ee for 999     head "Current|Users"
>>%file_sql% echo:
>>%file_sql% echo select y.tablespace_name aa,
>>%file_sql% echo        y.totmb bb,
>>%file_sql% echo        nvl^(x.usedmb,0^) cc,
>>%file_sql% echo        round^(nvl^(x.usedmb,0^)*100/y.totmb,2^) dd,
>>%file_sql% echo        nvl^(z.totses,0^) ee
>>%file_sql% echo from ^( select a.tablespace_name, nvl^(sum^(bytes^),0^)/^(1024*1024^) usedmb
>>%file_sql% echo        from dba_undo_extents a
>>%file_sql% echo        where tablespace_name in ^(select upper^(value^) from v$parameter where name='undo_tablespace'^)
>>%file_sql% echo        and status in ^('ACTIVE','UNEXPIRED'^)
>>%file_sql% echo        group by a.tablespace_name ^) x,
>>%file_sql% echo      ^( select b.tablespace_name, sum^(bytes^)/^(1024*1024^) totmb
>>%file_sql% echo        from dba_data_files b
>>%file_sql% echo        where tablespace_name in ^(select upper^(value^) from v$parameter where name='undo_tablespace'^)
>>%file_sql% echo        group by b.tablespace_name ^) y,
>>%file_sql% echo      ^( select count(distinct t.ses_addr) totses 
>>%file_sql% echo        from v$transaction t^) z
>>%file_sql% echo where y.tablespace_name = x.tablespace_name ^(+^)
>>%file_sql% echo order by y.tablespace_name
>>%file_sql% echo /
>>%file_sql% echo:
>>%file_sql% echo PROMPT
>>%file_sql% echo PROMPT +---------------+
>>%file_sql% echo PROMPT ^| UNDO activity ^|
>>%file_sql% echo PROMPT +---------------+
>>%file_sql% echo:
>>%file_sql% echo col aa for a3        head "Day"
>>%file_sql% echo col bb for a5        head "Date"
>>%file_sql% echo col cc for a2        head "HH"
>>%file_sql% echo col dd for 999G999   head "Max|Used|Blocks"
>>%file_sql% echo col ee for 99G999    head "Total|Active|(Go)"
>>%file_sql% echo col ff for 999G999   head "Total|Unexpired|(Go)"
>>%file_sql% echo col gg for 999G999   head "Total|Expired|(Go)"
>>%file_sql% echo col hh for 9G999G999 head "Max|Transac|Executed"
>>%file_sql% echo col ii for 999999    head "Longest|Query|(s)"
>>%file_sql% echo col jj for 999       head "Max|Concur|-rency"
>>%file_sql% echo col kk for 9999      head "Total|Blks|/sec"
>>%file_sql% echo col ll for 9G999G999 head "Min|Tuned|Undo|Retention"
>>%file_sql% echo col mm for 9G999G999 head "Max|Tuned|Undo|Retention"
>>%file_sql% echo col nn for 9G999G999 head "Gap|Tuned|Undo|Retention"
>>%file_sql% echo col oo for 99        head "Snapshot|Too Old|ORA-01555"
>>%file_sql% echo:
>>%file_sql% echo break on aa skip 1 on bb on report
>>%file_sql% echo compute min label 'MIN ^|' avg label 'MOY ^|' max label 'MAX ^|' of dd ee ff gg hh ii jj kk ll mm nn oo pp qq rr on report
>>%file_sql% echo:
>>%file_sql% echo select substr^(to_char^(max^(begin_time^),'Day'^),1,3^) aa,
>>%file_sql% echo        to_char^(max^(begin_time^),'DD/MM'^) bb,
>>%file_sql% echo        to_char^(max^(begin_time^),'HH24'^) cc,
>>%file_sql% echo        max^(undoblks^) dd,
>>%file_sql% echo        max^(activeblks*^&RPT_BLKS/1024/1024^) ee,
>>%file_sql% echo        max^(unexpiredblks*^&RPT_BLKS/1024/1024^) ff,
>>%file_sql% echo        max^(expiredblks*^&RPT_BLKS/1024/1024^) gg,
>>%file_sql% echo        max^(txncount^) hh,
>>%file_sql% echo        max^(maxquerylen^) ii,
>>%file_sql% echo        max^(maxconcurrency^) jj,
>>%file_sql% echo        max^(undoblks/^(^(end_time-begin_time^)*3600*24^)^) kk,
if not "%VER_ORA%"=="10.1" if not "%VER_ORA%"=="10.2" (
	>>%file_sql% echo        min^(tuned_undoretention^) ll,
	>>%file_sql% echo        max^(tuned_undoretention^) mm,
	>>%file_sql% echo        max^(tuned_undoretention^)-min^(tuned_undoretention^) nn,
)
>>%file_sql% echo        to_number^(replace^(sum^(ssolderrcnt^),  0,NULL^)^) oo,
>>%file_sql% echo        trunc^(begin_time,'HH24'^) NOP
>>%file_sql% echo -- 10g
>>%file_sql% echo from dba_hist_undostat
>>%file_sql% echo group by trunc^(begin_time,'HH24'^)
>>%file_sql% echo union
>>%file_sql% echo select substr^(to_char^(max^(begin_time^),'Day'^),1,3^) aa,
>>%file_sql% echo        to_char^(max^(begin_time^),'DD/MM'^) bb,
>>%file_sql% echo        to_char^(max^(begin_time^),'HH24'^) cc,
>>%file_sql% echo        max^(undoblks^) dd,
>>%file_sql% echo        max^(activeblks*^&RPT_BLKS/1024/1024^) ee,
>>%file_sql% echo        max^(unexpiredblks*^&RPT_BLKS/1024/1024^) ff,
>>%file_sql% echo        max^(expiredblks*^&RPT_BLKS/1024/1024^) gg,
>>%file_sql% echo        max^(txncount^) hh,
>>%file_sql% echo        max^(maxquerylen^) ii,
>>%file_sql% echo        max^(maxconcurrency^) jj,
>>%file_sql% echo        max^(undoblks/^(^(end_time-begin_time^)*3600*24^)^) kk,
if not "%VER_ORA%"=="10.1" if not "%VER_ORA%"=="10.2" (
	>>%file_sql% echo        min^(tuned_undoretention^) ll,
	>>%file_sql% echo        max^(tuned_undoretention^) mm,
	>>%file_sql% echo        max^(tuned_undoretention^)-min^(tuned_undoretention^) nn,
)
>>%file_sql% echo        to_number^(replace^(sum^(ssolderrcnt^),  0,NULL^)^) oo,
>>%file_sql% echo        trunc^(begin_time,'HH24'^) NOP
>>%file_sql% echo from v$undostat
>>%file_sql% echo where trunc^(begin_time,'HH24'^) = trunc^(sysdate,'HH24'^)
>>%file_sql% echo group by trunc^(begin_time,'HH24'^)
if not "%VER_ORA%"=="10.1" if not "%VER_ORA%"=="10.2" >>%file_sql% echo order by 16
if "%VER_ORA%"=="10.1" >>%file_sql% echo order by 13
if "%VER_ORA%"=="10.2" >>%file_sql% echo order by 13
>>%file_sql% echo /
>>%file_sql% echo clear breaks computes columns
goto:EOF
::#
::# End of Audit_undo
::#************************************************************#

:Audit_temp
::#************************************************************#
::# Audits usage for the TEMP tablespace in the database
::#
>>%file_sql% echo:
>>%file_sql% echo PROMPT
>>%file_sql% echo PROMPT +------------+
>>%file_sql% echo PROMPT ^| TEMP usage ^|
>>%file_sql% echo PROMPT +------------+
>>%file_sql% echo:
>>%file_sql% echo col aa for ^&FMT1   head "Tablespace|Name"
>>%file_sql% echo col bb for 999G999 head "Total|Size|(Mo)"
>>%file_sql% echo col cc for 999G999 head "Used|Space|(Mo)"
>>%file_sql% echo col dd for 999     head "Used|Space|(%%)"
>>%file_sql% echo col ee for 999     head "Current|Users"
>>%file_sql% echo:
if "%VER_ORA%"=="10.1" (	
	>>%file_sql% echo with temptbs as ^(select tablespace_name, sum^(bytes^)/1024/1024 mb_total from dba_temp_files group by tablespace_name^)
	>>%file_sql% echo select t.tablespace_name aa,
	>>%file_sql% echo        max^(t.mb_total^) bb,
	>>%file_sql% echo        sum^(e.bytes_used^)/1024/1024 cc,
	>>%file_sql% echo        ^(sum^(e.bytes_used^)/1024/1024^)*100/max^(t.mb_total^) dd,
	>>%file_sql% echo        max^(s.current_users^) ee
	>>%file_sql% echo from temptbs t
	>>%file_sql% echo join v$temp_extent_pool e on e.tablespace_name = t.tablespace_name
	>>%file_sql% echo join v$sort_segment s     on s.tablespace_name = t.tablespace_name
	>>%file_sql% echo group by t.tablespace_name
)
if "%VER_ORA%"=="10.2" (	
	>>%file_sql% echo with temptbs as ^(select tablespace_name, sum^(bytes^)/1024/1024 mb_total from dba_temp_files group by tablespace_name^)
	>>%file_sql% echo select t.tablespace_name aa,
	>>%file_sql% echo        max^(t.mb_total^) bb,
	>>%file_sql% echo        sum^(e.bytes_used^)/1024/1024 cc,
	>>%file_sql% echo        ^(sum^(e.bytes_used^)/1024/1024^)*100/max^(t.mb_total^) dd,
	>>%file_sql% echo        max^(s.current_users^) ee
	>>%file_sql% echo from temptbs t
	>>%file_sql% echo join v$temp_extent_pool e on e.tablespace_name = t.tablespace_name
	>>%file_sql% echo join v$sort_segment s     on s.tablespace_name = t.tablespace_name
	>>%file_sql% echo group by t.tablespace_name
)
if not "%VER_ORA%"=="10.1" if not "%VER_ORA%"=="10.2" (	
	>>%file_sql% echo select t.tablespace_name aa,
	>>%file_sql% echo        t.tablespace_size/1024/1024 bb,
	>>%file_sql% echo        ^(t.tablespace_size-t.free_space^)/1024/1024 cc,
	>>%file_sql% echo        round^(^(t.tablespace_size-t.free_space^)*100/t.tablespace_size^) dd,
	>>%file_sql% echo        max^(s.current_users^) ee
	>>%file_sql% echo from dba_temp_free_space t
	>>%file_sql% echo join v$sort_segment s on s.tablespace_name = t.tablespace_name
)
>>%file_sql% echo /
goto:EOF
::#
::# End of Audit_temp
::#************************************************************#

:Audit_obj
::#************************************************************#
::# Audits tables with many or no index, most large fragmented objects and invalid objects
::#
>>%file_sql% echo PROMPT
>>%file_sql% echo PROMPT +------------------------------+
>>%file_sql% echo PROMPT ^| Tables with many or no index ^|
>>%file_sql% echo PROMPT +------------------------------+
>>%file_sql% echo:
>>%file_sql% echo break on aa skip 1 on bb
>>%file_sql% echo:
>>%file_sql% echo col aa for ^&FMT3 head "Owner"
>>%file_sql% echo col bb for ^&FMT5 head "Table|Name"
>>%file_sql% echo col cc for 999   head "Nbr|Index"
>>%file_sql% echo col dd for a25   head "Diagnostic Nb=0 or >=10"
>>%file_sql% echo:
>>%file_sql% echo select owner aa,
>>%file_sql% echo        table_name bb,
>>%file_sql% echo        nb_indexes cc,
>>%file_sql% echo        decode^(greatest^(nb_indexes, 10^),nb_indexes,'### -^> Alert... ###',''^) dd
>>%file_sql% echo from ^(select i.owner, i.table_name, count^(distinct i.index_name^) nb_indexes
>>%file_sql% echo       from dba_indexes i
if not defined LOGIN >>%file_sql% echo       where i.owner in ^(^&RQT_USER^)
if defined LOGIN >>%file_sql% echo       where i.owner = '%LOGIN%'    -- Lists only for a login 
>>%file_sql% echo       and   i.table_name not like 'BIN$%%'
>>%file_sql% echo       and   i.index_name not like 'SYS_%%'
>>%file_sql% echo       group by i.owner, i.table_name
>>%file_sql% echo       having count^(i.index_name^) ^> 7^)
>>%file_sql% echo union
>>%file_sql% echo select t.owner aa,
>>%file_sql% echo        t.table_name bb,
>>%file_sql% echo        0 cc,
>>%file_sql% echo        '### -^> Alert... ###' dd
>>%file_sql% echo from dba_tables t
if not defined LOGIN >>%file_sql% echo where t.owner in ^(^&RQT_USER^)
if defined LOGIN >>%file_sql% echo where t.owner = '%LOGIN%'    -- Lists only for a login 
>>%file_sql% echo and   not exists ^(select 'X' from dba_indexes i
>>%file_sql% echo                   where i.owner      = t.owner
>>%file_sql% echo                   and   i.table_name = t.table_name^)
>>%file_sql% echo order by 1, 3 desc, 2
>>%file_sql% echo /
>>%file_sql% echo clear breaks
>>%file_sql% echo:
>>%file_sql% echo PROMPT
>>%file_sql% echo PROMPT +-----------------------------------------+
>>%file_sql% echo PROMPT ^| Most large fragmented objects ^(summary^) ^|
>>%file_sql% echo PROMPT +-----------------------------------------+
>>%file_sql% echo:
>>%file_sql% echo col aa for ^&FMT3 head "Owner"
>>%file_sql% echo col bb for ^&FMT5 head "Table|Name"
>>%file_sql% echo col cc for 990D9 head "Total Size|(>1Go)"
>>%file_sql% echo:
>>%file_sql% echo break on aa skip 1 on report
>>%file_sql% echo compute sum label TOTAL of cc on report
>>%file_sql% echo:
>>%file_sql% echo select e.owner aa,
>>%file_sql% echo        regexp_replace^(e.segment_name,'_.*',''^) bb,
>>%file_sql% echo        sum^(e.bytes^)/1024/1024/1024 cc
>>%file_sql% echo from sys.dba_extents e
if not defined LOGIN >>%file_sql% echo where e.owner in ^(^&RQT_USER^)
if defined LOGIN >>%file_sql% echo where e.owner = '%LOGIN%'    -- Lists only for a login 
>>%file_sql% echo and e.segment_type in ^('TABLE','INDEX'^)
>>%file_sql% echo group by e.owner, regexp_replace^(e.segment_name,'_.*',''^)
>>%file_sql% echo having sum^(e.bytes^)/1024/1024/1024 ^>= 1
>>%file_sql% echo order by 1, 3 desc
>>%file_sql% echo /
>>%file_sql% echo clear breaks computes
>>%file_sql% echo:
>>%file_sql% echo PROMPT
>>%file_sql% echo PROMPT +----------------------------------------+
>>%file_sql% echo PROMPT ^| Most large fragmented objects ^(detail^) ^|
>>%file_sql% echo PROMPT +----------------------------------------+
>>%file_sql% echo:
>>%file_sql% echo col aa for ^&FMT3   head "Owner"
>>%file_sql% echo col bb for ^&FMT1   head "Tablespace|Name"
>>%file_sql% echo col cc for a5      head "Object|Type"
>>%file_sql% echo col dd for ^&FMT5   head "Object|Name"
>>%file_sql% echo col ee for 999G999 head "Size|(Mo)"
>>%file_sql% echo col ff for 9G999   head "Count|Frag.|>=50"
>>%file_sql% echo:
>>%file_sql% echo break on aa on bb skip 1
>>%file_sql% echo:
>>%file_sql% echo select e.owner aa,
>>%file_sql% echo        e.tablespace_name bb,
>>%file_sql% echo        e.segment_type cc,
>>%file_sql% echo        e.segment_name dd,
>>%file_sql% echo 	     sum^(e.bytes^)/1024/1024 ee,
>>%file_sql% echo        count^(e.segment_name^) ff
>>%file_sql% echo from sys.dba_extents e
if not defined LOGIN >>%file_sql% echo where e.owner in ^(^&RQT_USER^)
if defined LOGIN >>%file_sql% echo where e.owner = '%LOGIN%'    -- Lists only for a login 
>>%file_sql% echo and e.segment_type in ^('TABLE','INDEX'^)
>>%file_sql% echo group by e.owner, e.segment_type, e.segment_name, e.tablespace_name
>>%file_sql% echo having count^(e.segment_name^) ^>= 50
>>%file_sql% echo order by 1, 2, 6 desc
>>%file_sql% echo /
>>%file_sql% echo clear breaks
>>%file_sql% echo:
>>%file_sql% echo PROMPT
>>%file_sql% echo PROMPT +---------------------+
>>%file_sql% echo PROMPT ^| Sequences hit ratio ^|
>>%file_sql% echo PROMPT +---------------------+
>>%file_sql% echo PROMPT
>>%file_sql% echo:
>>%file_sql% echo col aa for 9           head "Inst Id."
>>%file_sql% echo col bb for 999G999G999 head "Gets"
>>%file_sql% echo col cc for 999G999G999 head "Misses"
>>%file_sql% echo col dd for 990D99      head "Hit Ratio (%%)"
>>%file_sql% echo col ee for a30         head "Diagnostic"
>>%file_sql% echo:
>>%file_sql% echo break on aa skip 1
>>%file_sql% echo:
>>%file_sql% echo select r.inst_id aa,
>>%file_sql% echo        sum^(r.gets^) bb,
>>%file_sql% echo        sum^(r.getmisses^) cc,
>>%file_sql% echo        round^(^(1-^(sum^(r.getmisses^) / sum^(r.gets + r.getmisses^)^)^)*100 ,2^) dd,
>>%file_sql% echo        decode^(greatest^(round^(^(1-^(sum^(r.getmisses^) / sum^(r.gets + r.getmisses^)^)^)*100 ,2^),95^),95,'### -^> Alert ^<95% ###'^) ee
>>%file_sql% echo from gv$rowcache r
>>%file_sql% echo where r.gets ^> 0
>>%file_sql% echo and   r.parameter = 'dc_sequences'
>>%file_sql% echo having sum^(r.modifications^) ^> 0
>>%file_sql% echo group by r.inst_id
>>%file_sql% echo order by r.inst_id
>>%file_sql% echo /
>>%file_sql% echo clear breaks
>>%file_sql% echo:
>>%file_sql% echo PROMPT
>>%file_sql% echo PROMPT +--------------------------+
>>%file_sql% echo PROMPT ^| Contention for sequences ^|
>>%file_sql% echo PROMPT +--------------------------+
>>%file_sql% echo PROMPT
>>%file_sql% echo:
>>%file_sql% echo col aa for ^&FMT3   head "Owner"
>>%file_sql% echo col bb for ^&FMT5   head "Name"
>>%file_sql% echo col cc for a7      head "Order"
>>%file_sql% echo col dd for 9999    head "Size"
>>%file_sql% echo col ee for a5      head "Total"
>>%file_sql% echo col ff for a50     head "Event wait"
>>%file_sql% echo:
>>%file_sql% echo break on aa skip 1
>>%file_sql% echo:
>>%file_sql% echo with ash_seq as ^(
>>%file_sql% echo select substr^(dbms_lob.substr^(s.sql_text,4000,1^), 8, dbms_lob.instr^(s.sql_text, '.seq_'^)-8^) owner,
>>%file_sql% echo              upper^(replace^(substr^(dbms_lob.substr^(s.sql_text,4000,1^), dbms_lob.instr^(s.sql_text, '.seq_'^)+1^), '.nextval from dual',''^)^) name,
>>%file_sql% echo              h.event
>>%file_sql% echo from dba_hist_sqltext s
>>%file_sql% echo left outer join dba_hist_active_sess_history h using ^(sql_id^)
>>%file_sql% echo where dbms_lob.instr^(s.sql_text, 'nextval from dual'^) ^> 0
>>%file_sql% echo and   dbms_lob.instr^(s.sql_text, 'dbms_lob'^) = 0
>>%file_sql% echo and   dbms_lob.instr^(s.sql_text, 'DBMS_LOB'^) = 0
>>%file_sql% echo and   h.event is not null
>>%file_sql% echo --and   ^(h.event = 'row cache lock' or h.event like 'gc current block %-way' or h.event like '%%SV -%%'^)
>>%file_sql% echo ^)
>>%file_sql% echo select s.sequence_owner aa,
>>%file_sql% echo        s.sequence_name bb,
>>%file_sql% echo        max^(case when s.order_flag = 'Y' then 'ORDER' else 'NOORDER' end^) cc,
>>%file_sql% echo        max^(s.cache_size^) dd,
>>%file_sql% echo        replace^(to_char^(count^(h.event^)^),'0',''^) ee,
>>%file_sql% echo        h.event ff
>>%file_sql% echo from dba_sequences s
>>%file_sql% echo join ash_seq h on h.owner = s.sequence_owner and h.name = s.sequence_name
if not defined LOGIN >>%file_sql% echo where s.sequence_owner in ^(^&RQT_USER^)
if defined LOGIN >>%file_sql% echo where s.sequence_owner = '%LOGIN%'    -- Lists only for a login 
>>%file_sql% echo group by s.sequence_owner, s.sequence_name, h.event
>>%file_sql% echo union
>>%file_sql% echo select s.sequence_owner,
>>%file_sql% echo        s.sequence_name,
>>%file_sql% echo        case when s.order_flag = 'Y' then 'ORDER' else 'NOORDER' end,
>>%file_sql% echo        s.cache_size,
>>%file_sql% echo        '',
>>%file_sql% echo        ''
>>%file_sql% echo from dba_sequences s
if not defined LOGIN >>%file_sql% echo where s.sequence_owner in ^(^&RQT_USER^)
if defined LOGIN >>%file_sql% echo where s.sequence_owner = '%LOGIN%'    -- Lists only for a login 
>>%file_sql% echo and   s.last_number ^> 1
>>%file_sql% echo and   ^(^(s.order_flag = 'Y' and exists ^( 
>>%file_sql% echo            select 'X' from dba_sequences s1
>>%file_sql% echo                       join ash_seq h on h.owner = s1.sequence_owner and h.name = s1.sequence_name
>>%file_sql% echo                       where s1.sequence_owner = s.sequence_owner
>>%file_sql% echo                       and   s1.sequence_name  = s.sequence_name^)^) or s.cache_size ^> 20^)
>>%file_sql% echo /
>>%file_sql% echo clear breaks
>>%file_sql% echo:
>>%file_sql% echo PROMPT
>>%file_sql% echo PROMPT +-----------------+
>>%file_sql% echo PROMPT ^| Invalid Objects ^|
>>%file_sql% echo PROMPT +-----------------+
>>%file_sql% echo PROMPT
>>%file_sql% echo:
>>%file_sql% echo col aa for a13 head "Owner"
>>%file_sql% echo col bb for a15 head "Object|Type"
>>%file_sql% echo col cc for a30 head "Object|Name"
>>%file_sql% echo col dd for a16 head "Creation"
>>%file_sql% echo col ee for a16 head "Update"
>>%file_sql% echo col ff for a8  head "Status"
>>%file_sql% echo:
>>%file_sql% echo break on aa skip 1
>>%file_sql% echo:
>>%file_sql% echo select o.owner aa,
>>%file_sql% echo        o.object_type bb,
>>%file_sql% echo        o.object_name cc,
>>%file_sql% echo        to_char^(o.created,       '^&FMT_DAT2'^) dd,
>>%file_sql% echo        to_char^(o.last_ddl_time, '^&FMT_DAT2'^) ee,
>>%file_sql% echo        o.status ff
>>%file_sql% echo from dba_objects o
>>%file_sql% echo where o.status = 'INVALID'
if defined LOGIN >>%file_sql% echo and o.owner = '%LOGIN%'    -- Lists only for a login 
>>%file_sql% echo union
>>%file_sql% echo select i.owner aa,
>>%file_sql% echo        'INDEX' bb,
>>%file_sql% echo        i.index_name cc,
>>%file_sql% echo        to_char^(o.created,       '^&FMT_DAT2'^) dd,
>>%file_sql% echo        to_char^(o.last_ddl_time, '^&FMT_DAT2'^) ee,
>>%file_sql% echo        i.status ff
>>%file_sql% echo from dba_objects o, dba_indexes i
>>%file_sql% echo where i.status      = 'UNUSABLE'
if defined LOGIN >>%file_sql% echo and i.owner = '%LOGIN%'    -- Lists only for a login 
>>%file_sql% echo   and o.owner       = i.owner
>>%file_sql% echo   and o.object_name = i.index_name
>>%file_sql% echo order by 1, 2
>>%file_sql% echo /
>>%file_sql% echo clear breaks
goto:EOF
::#
::# End of Audit_obj
::#************************************************************#

:Audit_err
::#************************************************************#
::# Audits Oracle alerts history (only from Oracle 12c and above)
::#
>>%file_sql% echo:
>>%file_sql% echo PROMPT +---------------+
>>%file_sql% echo PROMPT ^| Oracle alerts ^|
>>%file_sql% echo PROMPT +---------------+
>>%file_sql% echo:
>>%file_sql% echo col aa for 9999 head "Nbr"
>>%file_sql% echo col bb for a80  head "Alert during last %DAYS% days"
>>%file_sql% echo col cc for a17  head "First time"
>>%file_sql% echo col dd for a17  head "Last time"
>>%file_sql% echo col ee for a9   head "Level"
>>%file_sql% echo col ff for a12  head "Type"
>>%file_sql% echo:
>>%file_sql% echo select count^(message_text^) aa,
>>%file_sql% echo        regexp_replace^(regexp_replace^(message_text, '\^(.*',''^), '\..*',''^) bb,
>>%file_sql% echo   	   to_char^(min^(originating_timestamp^), '%FMT_DAT3%'^) cc,
>>%file_sql% echo 	   to_char^(max^(originating_timestamp^), '%FMT_DAT3%'^) dd--,
>>%file_sql% echo 	   --max^(case when message_level = '1'  then 'Critical'
>>%file_sql% echo        --         when message_level = '2'  then 'Severe'
>>%file_sql% echo        --         when message_level = '8'  then 'Important'
>>%file_sql% echo        --         when message_level = '16' then 'Normal' end^) ee,
>>%file_sql% echo        --max^(case when message_type = '1' then 'Unknown'
>>%file_sql% echo        --         when message_type = '2' then 'Incident'
>>%file_sql% echo        --         when message_type = '3' then 'Error'
>>%file_sql% echo        --         when message_type = '4' then 'Warning'
>>%file_sql% echo        --         when message_type = '5' then 'Notification'
>>%file_sql% echo        --         when message_type = '6' then 'Trace' end^) ff
>>%file_sql% echo from v$diag_alert_ext
>>%file_sql% echo where originating_timestamp ^> sysdate -%DAYS%
>>%file_sql% echo and component_id = 'rdbms'
>>%file_sql% echo and message_type ^<='4'
>>%file_sql% echo and message_text like 'ORA-%%'
>>%file_sql% echo group by regexp_replace^(regexp_replace^(message_text, '\^(.*',''^), '\..*',''^)
>>%file_sql% echo order by max^(originating_timestamp^) desc
>>%file_sql% echo /
goto:EOF
::#
::# End of Audit_err
::#************************************************************#

:Audit_wait
::#************************************************************#
::# Audits wait events & TOP timed events and contention per segment
::#
>>%file_sql% echo:
>>%file_sql% echo PROMPT
>>%file_sql% echo PROMPT +-------------+
>>%file_sql% echo PROMPT ^| Wait events ^|
>>%file_sql% echo PROMPT +-------------+
>>%file_sql% echo:
>>%file_sql% echo col aa for 99            head "Rank"
>>%file_sql% echo col bb for a40           head "Event name"
>>%file_sql% echo col cc for a14           head "Class"
>>%file_sql% echo col dd for 9G999G999G999 head "Waits"
>>%file_sql% echo col ee for 9G999G999G999 head "Time|(s)"
>>%file_sql% echo col ff for 90D99         head "Time|(%%)"
>>%file_sql% echo:
>>%file_sql% echo select rownum aa,
>>%file_sql% echo        event bb,
>>%file_sql% echo        class cc,
>>%file_sql% echo        total_waits dd,
>>%file_sql% echo        round^(time_waited_micro/1000/1000^) ee,
>>%file_sql% echo        round^(time_waited_micro*100/sum ^(time_waited_micro^) over ^(^),2^) ff
>>%file_sql% echo from ^(select event, wait_class class, total_waits, time_waited_micro
>>%file_sql% echo         from v$system_event
>>%file_sql% echo         where wait_class ^<^> 'Idle'
>>%file_sql% echo       union
>>%file_sql% echo       select 'DB CPU', 'Cpu', null, sum^(value^)
>>%file_sql% echo         from v$sys_time_model
>>%file_sql% echo         where stat_name IN ^('DB CPU', 'background cpu time'^)
>>%file_sql% echo       order by 4 desc, 3^)
>>%file_sql% echo where rownum ^<= 10
>>%file_sql% echo /
>>%file_sql% echo:
>>%file_sql% echo PROMPT
>>%file_sql% echo PROMPT +------------------+
>>%file_sql% echo PROMPT ^| TOP timed events ^|
>>%file_sql% echo PROMPT +------------------+
>>%file_sql% echo:
>>%file_sql% echo col begin_snap_in new_value begin_snap NOPRINT
>>%file_sql% echo col begin_date_in new_value begin_date NOPRINT
>>%file_sql% echo col end_snap_in   new_value end_snap   NOPRINT
>>%file_sql% echo col end_date_in   new_value end_date   NOPRINT
>>%file_sql% echo:
>>%file_sql% echo set pages 0
>>%file_sql% echo select min^(snap_id^) begin_snap_in, to_char^(min^(begin_time^),'^&FMT_DAT1'^) begin_date_in,
>>%file_sql% echo        max^(snap_id^)   end_snap_in, to_char^(max^(begin_time^),'^&FMT_DAT1'^) end_date_in
>>%file_sql% echo from dba_hist_sysmetric_summary;
>>%file_sql% echo set pages 2000
>>%file_sql% echo:
>>%file_sql% echo set term on head on
>>%file_sql% echo:
>>%file_sql% echo def begin_hour=00:00
>>%file_sql% echo def end_hour=23:59
>>%file_sql% echo:
>>%file_sql% echo PROMPT Begin : ^&begin_date ^&begin_hour
>>%file_sql% echo PROMPT End   : ^&end_date ^&end_hour
>>%file_sql% echo:
>>%file_sql% echo col aa for 99999      head "Snap.id"
>>%file_sql% echo col bb for a14        head "Begin|Snap"
>>%file_sql% echo col cc for a5         head "End|Snap"
>>%file_sql% echo col dd for 9          head "Inst.Id"
>>%file_sql% echo col ee for a40        head "Event name (<>DB CPU)"
>>%file_sql% echo col ff for 99G999G999 head "Waits"
>>%file_sql% echo col gg for 999G999    head "Time(s)"
>>%file_sql% echo col hh for 99G999G999 head "Avg per|wait(ms)"
>>%file_sql% echo col ii for 999        head "DB time (%%)"
>>%file_sql% echo col jj for a15        head "Wait Class"
>>%file_sql% echo:
>>%file_sql% echo select snap_id aa,
>>%file_sql% echo        begin_snap bb,
>>%file_sql% echo        end_snap cc,
>>%file_sql% echo        inst_id dd,
>>%file_sql% echo        event_name ee,
>>%file_sql% echo        total_waits ff,
>>%file_sql% echo        time_waited gg,
>>%file_sql% echo        avg_time_ms hh,
>>%file_sql% echo        wait_pct ii,
>>%file_sql% echo        wait_class jj
>>%file_sql% echo from ^(
>>%file_sql% echo select snap_id,
>>%file_sql% echo        begin_snap,
>>%file_sql% echo        end_snap,
>>%file_sql% echo        inst_id,
>>%file_sql% echo        event_name,
>>%file_sql% echo        total_waits,
>>%file_sql% echo        time_waited,
>>%file_sql% echo        round^(^(time_waited/total_waits^)*1000^) avg_time_ms,
>>%file_sql% echo        round^(^(time_waited/db_time^)*100, 2^) wait_pct,
>>%file_sql% echo        wait_class
>>%file_sql% echo from ^(
>>%file_sql% echo select
>>%file_sql% echo   inst_id,
>>%file_sql% echo   snap_id, to_char^(begin_snap, 'DD/MM/YY HH24:MI'^) begin_snap,
>>%file_sql% echo   to_char^(end_snap, 'HH24:MI'^) end_snap,
>>%file_sql% echo   event_name,
>>%file_sql% echo   wait_class,
>>%file_sql% echo   total_waits,
>>%file_sql% echo   time_waited,
>>%file_sql% echo   dense_rank^(^) over ^(partition by inst_id, snap_id order by time_waited desc^)-1 wait_rank,
>>%file_sql% echo   max^(time_waited^) over ^(partition by inst_id, snap_id^) db_time
>>%file_sql% echo from ^(
>>%file_sql% echo select s.instance_number inst_id,
>>%file_sql% echo        s.snap_id,
>>%file_sql% echo        s.begin_interval_time begin_snap,
>>%file_sql% echo        s.end_interval_time end_snap,
>>%file_sql% echo        st.event_name,
>>%file_sql% echo        st.wait_class,
>>%file_sql% echo        st.total_waits - lag^(st.total_waits, 1, st.total_waits^) over
>>%file_sql% echo          ^(partition by s.startup_time, s.instance_number, st.event_name order by s.snap_id^) total_waits,
>>%file_sql% echo        st.time_waited - lag^(st.time_waited, 1, st.time_waited^) over
>>%file_sql% echo          ^(partition by s.startup_time, s.instance_number, st.event_name order by s.snap_id^) time_waited,
>>%file_sql% echo        min^(s.snap_id^) over ^(partition by s.startup_time, s.instance_number, st.event_name^) min_snap_id
>>%file_sql% echo from ^(
if not "%VER_ORA%"=="10.1" if not "%VER_ORA%"=="10.2" >>%file_sql% echo select dbid, instance_number, snap_id, event_name, wait_class, total_waits_fg total_waits, round^(time_waited_micro_fg/1000000, 2^) time_waited
if "%VER_ORA%"=="10.1" >>%file_sql% echo select dbid, instance_number, snap_id, event_name, wait_class, total_waits, round^(time_waited_micro/1000000, 2^) time_waited
if "%VER_ORA%"=="10.2" >>%file_sql% echo select dbid, instance_number, snap_id, event_name, wait_class, total_waits, round^(time_waited_micro/1000000, 2^) time_waited
>>%file_sql% echo from dba_hist_system_event
>>%file_sql% echo where wait_class not in ^('Idle', 'System I/O'^)
>>%file_sql% echo union all
>>%file_sql% echo select dbid, instance_number, snap_id, stat_name event_name, null wait_class, null total_waits, round^(value/1000000, 2^) time_waited
>>%file_sql% echo from dba_hist_sys_time_model
>>%file_sql% echo where stat_name in ^('DB CPU', 'DB time'^)
>>%file_sql% echo ^) st, dba_hist_snapshot s
>>%file_sql% echo where st.instance_number = s.instance_number
>>%file_sql% echo and st.snap_id = s.snap_id
>>%file_sql% echo and st.dbid    = s.dbid
>>%file_sql% echo and s.dbid     = ^&RPT_DBID
>>%file_sql% echo and s.begin_interval_time between to_date^(trunc^(s.begin_interval_time^)^|^|' ^&begin_hour','^&FMT_DAT3'^)
>>%file_sql% echo                               and to_date^(trunc^(s.begin_interval_time^)^|^|' ^&end_hour',  '^&FMT_DAT3'^)
>>%file_sql% echo ^) where snap_id ^> min_snap_id and nvl^(total_waits,1^) ^> 0
>>%file_sql% echo ^) where event_name not in ^('DB time', 'DB CPU'^) and wait_rank ^<= 5
>>%file_sql% echo order by 8 desc
>>%file_sql% echo ^) where rownum ^<= %TOP_NSQL%*2
>>%file_sql% echo /
>>%file_sql% echo:
>>%file_sql% echo PROMPT
>>%file_sql% echo PROMPT +------------------------+
>>%file_sql% echo PROMPT ^| Contention per segment ^|
>>%file_sql% echo PROMPT +------------------------+
>>%file_sql% echo:
>>%file_sql% echo col aa for a30   head "Statistic name"
>>%file_sql% echo col bb for a10   head "Owner"
>>%file_sql% echo col cc for a30   head "Object name"
>>%file_sql% echo col dd for a10   head "Type"
>>%file_sql% echo col ee for 990D9 head "Value|(%%)"
>>%file_sql% echo:
>>%file_sql% echo break on aa skip 1
>>%file_sql% echo compute sum of ee on aa
>>%file_sql% echo:
>>%file_sql% echo select statistic_name aa,
>>%file_sql% echo        owner bb,
>>%file_sql% echo        object_name cc,
>>%file_sql% echo        object_type dd,
>>%file_sql% echo        pct_value ee
>>%file_sql% echo from ^(select statistic_name, owner, object_name, object_type, pct_value
>>%file_sql% echo       from ^(select s.statistic_name,
>>%file_sql% echo                    o.owner,
>>%file_sql% echo                    o.object_type,
>>%file_sql% echo                    o.object_name,
>>%file_sql% echo                    row_number^(^) over ^(partition by s.statistic_name order by s.value desc^) row_number,
>>%file_sql% echo                    round^(s.value * 100 / sum^(s.value^) over ^(partition by s.statistic_name^), 2^) pct_value
>>%file_sql% echo             from v$segstat s
>>%file_sql% echo             join dba_objects o on ^(o.object_id = s.obj#^)
>>%file_sql% echo             where s.value ^> 0
>>%file_sql% echo             and   o.owner in ^(^&RQT_USER^)
if defined LOGIN >>%file_sql% echo and o.owner = '%LOGIN%'    -- Lists only for a login 
>>%file_sql% echo      ^)
>>%file_sql% echo       where rownum ^<= ^&TOP_NSQL^)
>>%file_sql% echo order by 1, 5 desc
>>%file_sql% echo /
>>%file_sql% echo clear breaks
goto:EOF
::#
::# End of Audit_wait
::#************************************************************#

:Audit_user
::#************************************************************#
::# Audits user sessions in the database
::#
>>%file_sql% echo:
>>%file_sql% echo PROMPT
>>%file_sql% echo PROMPT +-----------+
>>%file_sql% echo PROMPT ^| User info ^|
>>%file_sql% echo PROMPT +-----------+
>>%file_sql% echo:
>>%file_sql% echo col aa for ^&FMT3 head "Username"
>>%file_sql% echo col bb for a10   head "Profile"
>>%file_sql% echo col cc for a16   head "Status" trunc
>>%file_sql% echo col dd for ^&FMT1 head "Default|Tablespace"
>>%file_sql% echo col ee for a10   head "Quota|(Mo)"
>>%file_sql% echo col ff for ^&FMT1 head "Temporary|Tablespace"
>>%file_sql% echo col gg for a10   head "Creation|Date"
>>%file_sql% echo col hh for a10   head "Lock|Date"
>>%file_sql% echo col ii for a10   head "Expiry|Date"
>>%file_sql% echo:
>>%file_sql% echo select u.username aa,
>>%file_sql% echo        u.profile bb,
>>%file_sql% echo        u.account_status cc,
>>%file_sql% echo        q.tablespace_name dd,
>>%file_sql% echo        decode^(q.max_bytes, -1, 'UNLIMITED', ceil^(q.max_bytes / 1024 / 1024^)^|^|'M'^) ee,
>>%file_sql% echo        u.temporary_tablespace ff,
>>%file_sql% echo        to_char^(u.created,'^&FMT_DAT1'^) gg,
>>%file_sql% echo        to_char^(u.lock_date,'^&FMT_DAT1'^) hh,
>>%file_sql% echo        to_char^(u.expiry_date,'^&FMT_DAT1'^) ii
>>%file_sql% echo from dba_ts_quotas q, dba_users u
if not defined LOGIN >>%file_sql% echo where u.username is not null
if defined LOGIN >>%file_sql% echo where u.username = '%LOGIN%'    -- Lists only for a login 
>>%file_sql% echo and   q.username = u.username
>>%file_sql% echo and   q.tablespace_name = u.default_tablespace
>>%file_sql% echo order by 3 desc, 1
>>%file_sql% echo /
>>%file_sql% echo:
>>%file_sql% echo PROMPT
>>%file_sql% echo PROMPT +------------------+
>>%file_sql% echo PROMPT ^| Session activity ^|
>>%file_sql% echo PROMPT +------------------+
>>%file_sql% echo:
>>%file_sql% echo col aa for ^&FMT3        head "Username"
>>%file_sql% echo col bb for a30          head "OS User:Program"
>>%file_sql% echo col dd for a11          head "SID:|Serial#"
>>%file_sql% echo col cc for a10          head "PID"
>>%file_sql% echo col ee for a11          head "Last|Connexion"
>>%file_sql% echo col ff for a5           head "Last|Exec|(s)"
>>%file_sql% echo col gg for 999G999      head "Consist|Change"
>>%file_sql% echo col hh for 999G999G999  head "Physical|Reads"
>>%file_sql% echo col ii for 9999G999G999 head "Logical|Reads"
>>%file_sql% echo col jj for 9999         head "Open|Curs"
>>%file_sql% echo col kk for 99999        head "CPU|Usage|(%%)"
>>%file_sql% echo col ll for 990D9        head "MEM|Usage|(Mo)" just right
>>%file_sql% echo:
>>%file_sql% echo break on aa on bb skip 1 on cc on report
>>%file_sql% echo compute count label "Count" of bb on bb report
>>%file_sql% echo compute max label "Max" of jj kk ll on jj kk ll report
>>%file_sql% echo:
>>%file_sql% echo select s.username aa,
>>%file_sql% echo        osuser^|^|':'^|^|decode^(ltrim^(substr^(s.program,1,instr^(s.program,' '^)-1^)^),'',ltrim^(substr^(s.program,1,instr^(s.program,'.'^)-1^)^),ltrim^(substr^(s.program,1,instr^(s.program,' '^)-1^)^)^) bb,
>>%file_sql% echo        to_char^(s.sid^)^|^|':'^|^|to_char^(serial#^) cc,
>>%file_sql% echo        process dd,
>>%file_sql% echo        to_char^(s.logon_time,'DD/MM HH24:MI'^) ee,
>>%file_sql% echo        decode^(s.status, 'ACTIVE', to_char^(s.last_call_et^), to_char^(sysdate - ^(s.last_call_et^)/86400, 'HH24:MI'^)^) ff,
>>%file_sql% echo        consistent_changes gg,
>>%file_sql% echo        physical_reads hh,
>>%file_sql% echo        block_gets + consistent_gets ii,
>>%file_sql% echo        se3.value jj,
>>%file_sql% echo        round^(se4.value/100^) kk,
>>%file_sql% echo        round^(se1.value + se2.value^)/1024/1024 ll
>>%file_sql% echo from v$session s
>>%file_sql% echo join v$sess_io  io  on  io.sid        = s.sid
>>%file_sql% echo join v$sesstat  se1 on se1.sid        = s.sid
>>%file_sql% echo join v$sesstat  se2 on se2.sid        = s.sid
>>%file_sql% echo join v$sesstat  se3 on se3.sid        = s.sid
>>%file_sql% echo join v$sesstat  se4 on se4.sid        = s.sid
>>%file_sql% echo join v$statname sn1 on sn1.statistic# = se1.statistic#
>>%file_sql% echo join v$statname sn2 on sn2.statistic# = se2.statistic#
>>%file_sql% echo join v$statname sn3 on sn3.statistic# = se3.statistic#
>>%file_sql% echo join v$statname sn4 on sn4.statistic# = se4.statistic#
if not defined LOGIN >>%file_sql% echo where s.username is not null
if defined LOGIN >>%file_sql% echo where s.username = '%LOGIN%'    -- Lists only for a login 
>>%file_sql% echo and sn1.name       = 'session pga memory'
>>%file_sql% echo and sn2.name       = 'session uga memory'
>>%file_sql% echo and sn3.name       = 'opened cursors current'
>>%file_sql% echo and sn4.name       = 'CPU used by this session'
>>%file_sql% echo order by 1, 2, s.status, se4.value desc
>>%file_sql% echo /
>>%file_sql% echo clear breaks computes
>>%file_sql% echo:
goto:EOF
::#
::# End of Audit_user
::#************************************************************#

:Audit_lock
::#************************************************************#
::# Audits locks activity and history (Oracle diagnostic pack required)
::#
>>%file_sql% echo PROMPT
>>%file_sql% echo PROMPT +---------------+
>>%file_sql% echo PROMPT ^| Lock activity ^|
>>%file_sql% echo PROMPT +---------------+
>>%file_sql% echo:
>>%file_sql% echo col aa for a4   head "Lock|Type"
>>%file_sql% echo col bb for ^&FMT3  head "Blocking|user"
>>%file_sql% echo col cc for 9999 head "Blocking|SID"
>>%file_sql% echo col dd for ^&FMT3  head "Blocked|user"
>>%file_sql% echo col ee for 9999 head "Blocked|SID"
>>%file_sql% echo col ff for a%LEN_SQLT% head "SQL text"
>>%file_sql% echo:
>>%file_sql% echo select distinct l2.type aa,
>>%file_sql% echo                 s1.username bb,
>>%file_sql% echo                 s1.sid cc,
>>%file_sql% echo                 s2.username dd,
>>%file_sql% echo                 s2.sid ee,
>>%file_sql% echo                 sq.sql_text ff
>>%file_sql% echo from v$lock l1
>>%file_sql% echo join v$lock l2 using ^(id1, id2^)
>>%file_sql% echo join v$session s1 on ^(s1.sid = l1.sid^)
>>%file_sql% echo join v$session s2 on ^(s2.sid = l2.sid^)
>>%file_sql% echo left outer join v$sql sq on ^(sq.sql_id = s2.sql_id^)
>>%file_sql% echo where l1.block = 1
>>%file_sql% echo and   l2.request ^> 0
>>%file_sql% echo /
>>%file_sql% echo select distinct s1.username^|^|'@'^|^|s1.machine^|^|'^( INST='^|^|s1.inst_id^|^|' SID='^|^|s1.sid^|^|' ^) is blocking '^|^|
>>%file_sql% echo                 s2.username^|^|'@'^|^|s2.machine^|^|'^( INST='^|^|s1.inst_id^|^|' SID='^|^|s2.sid^|^|' ^)' blocking_status
>>%file_sql% echo from gv$lock l1, gv$session s1,
>>%file_sql% echo      gv$lock l2, gv$session s2
>>%file_sql% echo where s1.sid     = l1.sid
>>%file_sql% echo   and s2.sid     = l2.sid
>>%file_sql% echo   and l1.block   = 1
>>%file_sql% echo   and l2.request ^> 0
>>%file_sql% echo   and l1.id1     = l2.id1
>>%file_sql% echo   and l2.id2     = l2.id2
>>%file_sql% echo   and l1.inst_id = s1.inst_id
>>%file_sql% echo /
>>%file_sql% echo:
>>%file_sql% echo set head off
>>%file_sql% echo select '+--------------+'^|^|chr^(10^)^|^|'^| Lock history ^|'^|^|chr^(10^)^|^|'+--------------+'
>>%file_sql% echo from v$parameter p
>>%file_sql% echo where p.name = 'control_management_pack_access'
>>%file_sql% echo and p.value like '%%%ORAPACK%%%';
>>%file_sql% echo set head on
>>%file_sql% echo:
>>%file_sql% echo col aa for a12       head "Username"
>>%file_sql% echo col bb for a35       head "Module"
>>%file_sql% echo col cc for 99999     head "Blocking|Session"
>>%file_sql% echo col dd for a4        head "Lock|Type"
>>%file_sql% echo col ee for a20       head "Object|Name"
>>%file_sql% echo col ff for 9G999G999 head "Waits"
>>%file_sql% echo col gg for 9G999G999 head "Wait|(s)"
>>%file_sql% echo col hh for 999       head "Wait|(%%)"
>>%file_sql% echo col ii for 990D9     head "PGA|Allocated|(Mo)"
>>%file_sql% echo col jj for 9990D9    head "Temp space|Used|(Mo)"
>>%file_sql% echo col kk for a%LEN_SQLT%        head "SQL Text" word_wrap
>>%file_sql% echo col ll for a%LEN_SQLT%        head ""
>>%file_sql% echo:
>>%file_sql% echo with ash_query as ^(
>>%file_sql% echo select username,
>>%file_sql% echo        h.module,
>>%file_sql% echo        h.program,
>>%file_sql% echo        h.blocking_session,
>>%file_sql% echo        substr^(event,6,2^) lock_type,
>>%file_sql% echo        o.object_name,
>>%file_sql% echo        count^(username^) waits,
>>%file_sql% echo        sum^(time_waited^)/1000 time_ms,
>>%file_sql% echo        rank^(^) over ^(order by sum^(time_waited^) desc^) time_rank,
>>%file_sql% echo        round^(sum^(time_waited^) * 100 / sum^(sum^(time_waited^)^) over ^(^), 2^) pct_of_time,
if not "%VER_ORA%"=="10.1" if not "%VER_ORA%"=="10.2" (
	>>%file_sql% echo         max^(h.pga_allocated/1024/1024^) pga_in_mb,
	>>%file_sql% echo         max^(h.temp_space_allocated/1024/1024^) tmp_in_mb,
)
>>%file_sql% echo         sql_text
>>%file_sql% echo  from  v$parameter p, v$active_session_history h
>>%file_sql% echo  join dba_users u using ^(user_id^)
>>%file_sql% echo  left outer join dba_objects o on ^(o.object_id = h.current_obj#^)
>>%file_sql% echo  left outer join v$sql s using ^(sql_id^)
>>%file_sql% echo  where event like 'enq: %'
if defined LOGIN >>%file_sql% echo and   username = '%LOGIN%'    -- Lists only for a login 
>>%file_sql% echo  and   p.name = 'control_management_pack_access'
>>%file_sql% echo  and   p.value like '%%%ORAPACK%%%'
>>%file_sql% echo  and   h.module not in ^('DBMS_SCHEDULER', 'SQL*Plus'^)
>>%file_sql% echo  having sum^(time_waited^)/1000 ^>0
>>%file_sql% echo  and   username not in ^(select username from dba_users where default_tablespace in ^('SYS', 'SYSTEM'^)^)
>>%file_sql% echo  group by username, h.module, h.program, h.blocking_session, substr^(event,6,2^), object_name, sql_text
>>%file_sql% echo ^)
>>%file_sql% echo select username aa,
>>%file_sql% echo        module bb,
>>%file_sql% echo        blocking_session cc,
>>%file_sql% echo        lock_type dd,
>>%file_sql% echo        object_name ee,
>>%file_sql% echo        waits ff,
>>%file_sql% echo        time_ms gg,
>>%file_sql% echo        pct_of_time hh,
if not "%VER_ORA%"=="10.1" if not "%VER_ORA%"=="10.2" (
	>>%file_sql% echo        pga_in_mb ii,
	>>%file_sql% echo        tmp_in_mb jj,
)
>>%file_sql% echo        sql_text kk,
>>%file_sql% echo        lpad^('-',150,'-'^) ll
>>%file_sql% echo from ash_query
>>%file_sql% echo where time_rank ^<= %TOP_NSQL%
>>%file_sql% echo order by time_rank
>>%file_sql% echo /
goto:EOF
::#
::# End of Audit_lock
::#************************************************************#

:Audit_stat
::#************************************************************#
::# Audits statistics computed for objects and operations in the database
::#
>>%file_sql% echo:
>>%file_sql% echo PROMPT
>>%file_sql% echo PROMPT +--------------------+
>>%file_sql% echo PROMPT ^| Objects statistics ^|
>>%file_sql% echo PROMPT +--------------------+
>>%file_sql% echo:
>>%file_sql% echo col aa for ^&FMT3 head "Owner"
>>%file_sql% echo col bb for a6    head "Type"
>>%file_sql% echo col cc for 9999  head "Up to|date"
>>%file_sql% echo col dd for 9999  head "Stale|%STALE% days"
>>%file_sql% echo col ee for 9999  head "Stale|(%%)"
>>%file_sql% echo col ff for a8    head "Last|Analyzed|(Min)"
>>%file_sql% echo col gg for a8    head "Last|Analyzed|(Max)"
>>%file_sql% echo:
>>%file_sql% echo break on aa skip 1 on bb
>>%file_sql% echo:
>>%file_sql% echo select t.owner aa,
>>%file_sql% echo        max^('Table'^) bb,
>>%file_sql% echo        sum^(case when trunc^(t.last_analyzed^) ^> trunc^(sysdate-%STALE%^) then 1 else 0 end^) cc,
>>%file_sql% echo        sum^(case when trunc^(t.last_analyzed^) ^> trunc^(sysdate-%STALE%^) then 0 else 1 end^) dd,
>>%file_sql% echo        least^(sum^(case when trunc^(t.last_analyzed^) ^> trunc^(sysdate-%STALE%^) then 0 else 1 end^)*100/replace^(count^(t.last_analyzed^),0,1^), 100^) ee,
>>%file_sql% echo        to_char^(min^(t.last_analyzed^),'^&FMT_DAT1'^) ff,
>>%file_sql% echo        to_char^(max^(t.last_analyzed^),'^&FMT_DAT1'^) gg
>>%file_sql% echo from   dba_tables t
>>%file_sql% echo where  t.owner in ^(^&RQT_USER^)
>>%file_sql% echo group by t.owner
>>%file_sql% echo union all
>>%file_sql% echo select i.owner aa,
>>%file_sql% echo        max^('Index'^) bb,
>>%file_sql% echo        sum^(case when trunc^(i.last_analyzed^) ^> trunc^(sysdate-%STALE%^) then 1 else 0 end^) cc,
>>%file_sql% echo        sum^(case when trunc^(i.last_analyzed^) ^> trunc^(sysdate-%STALE%^) then 0 else 1 end^) dd,
>>%file_sql% echo        least^(sum^(case when trunc^(i.last_analyzed^) ^> trunc^(sysdate-%STALE%^) then 0 else 1 end^)*100/replace^(count^(i.last_analyzed^),0,1^), 100^) ee,
>>%file_sql% echo        to_char^(min^(i.last_analyzed^),'^&FMT_DAT1'^) ff,
>>%file_sql% echo        to_char^(max^(i.last_analyzed^),'^&FMT_DAT1'^) gg
>>%file_sql% echo from  dba_indexes i
>>%file_sql% echo where i.owner in ^(^&RQT_USER^)
>>%file_sql% echo and   i.index_name not like 'SYS%'
>>%file_sql% echo group by i.owner
>>%file_sql% echo union all
>>%file_sql% echo select c.owner aa,
>>%file_sql% echo        max^('Column'^) bb,
>>%file_sql% echo        sum^(case when trunc^(c.last_analyzed^) ^> trunc^(sysdate-%STALE%^) then 1 else 0 end^) cc,
>>%file_sql% echo        sum^(case when trunc^(c.last_analyzed^) ^> trunc^(sysdate-%STALE%^) then 0 else 1 end^) dd,
>>%file_sql% echo        least^(sum^(case when trunc^(c.last_analyzed^) ^> trunc^(sysdate-%STALE%^) then 0 else 1 end^)*100/replace^(count^(c.last_analyzed^),0,1^), 100^) ee,
>>%file_sql% echo        to_char^(min^(c.last_analyzed^),'^&FMT_DAT1'^) ff,
>>%file_sql% echo        to_char^(max^(c.last_analyzed^),'^&FMT_DAT1'^) gg
>>%file_sql% echo from  dba_tab_cols c
>>%file_sql% echo where c.owner in ^(^&RQT_USER^)
>>%file_sql% echo and   c.last_analyzed is not null
>>%file_sql% echo and   exists ^(select 'X'
>>%file_sql% echo               from dba_ind_columns i
>>%file_sql% echo               where i.table_owner = c.owner
>>%file_sql% echo               and   i.table_name  = c.table_name
>>%file_sql% echo               and   i.column_name = c.column_name^)
>>%file_sql% echo group by c.owner
>>%file_sql% echo order by 1, 2 desc
>>%file_sql% echo /
>>%file_sql% echo clear breaks
>>%file_sql% echo:
>>%file_sql% echo PROMPT -- Detail --
>>%file_sql% echo:
>>%file_sql% echo col aa for ^&FMT3 head "Owner"
>>%file_sql% echo col bb for a7    head "Type"
>>%file_sql% echo col cc for a10   head "Last|Analyzed"
>>%file_sql% echo col dd for 9999  head "Count"
>>%file_sql% echo:
>>%file_sql% echo break on aa on bb skip 1
>>%file_sql% echo:
>>%file_sql% echo select t.owner aa,
>>%file_sql% echo        'Table' bb,
>>%file_sql% echo        to_char^(trunc^(t.last_analyzed^),'^&FMT_DAT1'^) cc,
>>%file_sql% echo        count^(t.last_analyzed^) dd,
>>%file_sql% echo        trunc^(t.last_analyzed^) NOP
>>%file_sql% echo from   dba_tables t
if not defined LOGIN >>%file_sql% echo where  t.owner in ^(select username from dba_users where default_tablespace not in ^('SYSTEM','SYSAUX','PERFSTAT'^)^)
if defined LOGIN >>%file_sql% echo where t.owner = '%LOGIN%'    -- Lists only for a login 
>>%file_sql% echo group by t.owner, trunc^(t.last_analyzed^)
>>%file_sql% echo union
>>%file_sql% echo select i.owner aa,
>>%file_sql% echo        'Index' bb,
>>%file_sql% echo        to_char^(trunc^(i.last_analyzed^),'^&FMT_DAT1'^) cc,
>>%file_sql% echo        count^(i.last_analyzed^) dd,
>>%file_sql% echo        trunc^(i.last_analyzed^) NOP
>>%file_sql% echo from  dba_indexes i
if not defined LOGIN >>%file_sql% echo where i.owner in ^(select username from dba_users where default_tablespace not in ^('SYSTEM','SYSAUX','PERFSTAT'^)^)
if defined LOGIN >>%file_sql% echo where i.owner = '%LOGIN%'    -- Lists only for a login 
>>%file_sql% echo and   i.index_name not like 'SYS%%'
>>%file_sql% echo group by i.owner, trunc^(i.last_analyzed^)
>>%file_sql% echo union
>>%file_sql% echo select c.owner aa,
>>%file_sql% echo        'Column' bb,
>>%file_sql% echo        to_char^(trunc^(c.last_analyzed^),'^&FMT_DAT1'^) cc,
>>%file_sql% echo        count^(c.last_analyzed^) dd,
>>%file_sql% echo        trunc^(c.last_analyzed^) NOP
>>%file_sql% echo from  dba_tab_cols c
if not defined LOGIN >>%file_sql% echo where c.owner in ^(select username from dba_users where default_tablespace not in ^('SYSTEM','SYSAUX','PERFSTAT'^)^)
if defined LOGIN >>%file_sql% echo where c.owner = '%LOGIN%'    -- Lists only for a login 
>>%file_sql% echo and   c.last_analyzed is not null
>>%file_sql% echo and   exists ^(select 'X'
>>%file_sql% echo               from dba_ind_columns i1
>>%file_sql% echo               where i1.table_owner = c.owner
>>%file_sql% echo               and   i1.table_name  = c.table_name
>>%file_sql% echo               and   i1.column_name = c.column_name^)
>>%file_sql% echo group by c.owner, trunc^(c.last_analyzed^)
>>%file_sql% echo order by 1, 2 desc, 5 desc
>>%file_sql% echo /
>>%file_sql% echo clear breaks
>>%file_sql% echo:
>>%file_sql% echo PROMPT +-----------------------+
>>%file_sql% echo PROMPT ^| Statistics operations ^|
>>%file_sql% echo PROMPT +-----------------------+
>>%file_sql% echo:
>>%file_sql% echo col aa for a8  head "Date"
>>%file_sql% echo col bb for a8  head "Time"
>>%file_sql% echo col cc for a30 head "Operation"
>>%file_sql% echo col dd for a17 head "End Time"
>>%file_sql% echo col ee for a9  head "Duration"
>>%file_sql% echo:
>>%file_sql% echo break on aa skip 1
>>%file_sql% echo:
>>%file_sql% echo select to_char^(start_time,'^&FMT_DAT1'^) aa,
>>%file_sql% echo        to_char^(start_time,'HH24:MI:SS'^) bb,
>>%file_sql% echo        operation cc,
>>%file_sql% echo        to_char^(end_time,'^&FMT_DAT3'^) dd,
>>%file_sql% echo        lpad^(decode^(extract^(hour   from end_time-start_time^),0,'',extract^(hour   from end_time-start_time^)^|^|'h'^)^|^|
>>%file_sql% echo             decode^(extract^(minute from end_time-start_time^),0,'',extract^(minute from end_time-start_time^)^|^|'m'^)^|^|
>>%file_sql% echo             round^(extract^(second from end_time-start_time^)^)^|^|'s',9,' '^) ee,
>>%file_sql% echo        start_time NOP
>>%file_sql% echo from dba_optstat_operations
>>%file_sql% echo where trunc^(start_time^) ^> trunc^(sysdate-8^)
>>%file_sql% echo and   operation not in ^('gather_database_stats^(auto^)', 'copy_table_stats'^)
>>%file_sql% echo order by 6
>>%file_sql% echo /
>>%file_sql% echo clear breaks
>>%file_sql% echo:
goto:EOF
::#
::# End of Audit_stat
::#************************************************************#

:Audit_sql
::#************************************************************#
::# Audits TOP SQL with longest elapsed time
::#
>>%file_sql% echo:
>>%file_sql% echo PROMPT
>>%file_sql% echo PROMPT +-------------------------------------------+
>>%file_sql% echo PROMPT ^| Top ^&TOP_NSQL SQL ordered by Elapsed time ^(^>=%SQL_TIME%s^)^|
>>%file_sql% echo PROMPT +-------------------------------------------+
>>%file_sql% echo PROMPT
>>%file_sql% echo:
>>%file_sql% echo set pages 0
>>%file_sql% echo:
>>%file_sql% echo col aa for a%LEN_SQLT% head "qry_sql_text" word_wrap fold_after
>>%file_sql% echo col aa for a150 head "qry_sql_text" word_wrap fold_after
>>%file_sql% echo col bb for a30  head "plan hash"
>>%file_sql% echo col cc for a30  head "Last Date"
>>%file_sql% echo col dd for a55  head "Module Name"
>>%file_sql% echo col ee for a30  head "Schema|Name"
>>%file_sql% echo col ff for a30  head "Optim.|Mode"
>>%file_sql% echo col gg for a30  head "Optim.|Cost"
>>%file_sql% echo col hh for a30  head "Rows"
>>%file_sql% echo col ii for a30  head "Rows / exec"
>>%file_sql% echo col jj for a30  head "Executions"
>>%file_sql% echo col kk for a30  head "Ela time(ms)"
>>%file_sql% echo col ll for a30  head "Ela / exec"
>>%file_sql% echo col mm for a30  head "CPU time(ms)"
>>%file_sql% echo col nn for a30  head "CPU / exec"
>>%file_sql% echo col oo for a30  head "Logical I/O"
>>%file_sql% echo col pp for a30  head "Lio / Exec"
>>%file_sql% echo col qq for a30  head "Lio / Row"
>>%file_sql% echo col rr for a30  head "Physical I/O"
>>%file_sql% echo col ss for a30  head "PIO / Exec"
>>%file_sql% echo col tt for a30  head "PIO / Row"
>>%file_sql% echo:
>>%file_sql% echo col BLANK for a30 fold_before
>>%file_sql% echo:
>>%file_sql% echo select '['^|^|ltrim^(to_char^(rownum,'009'^)^)^|^|'] ===============================================================================================================================================',
>>%file_sql% echo        sps.sql_text^|^|chr^(10^)^|^|chr^(13^) aa,
>>%file_sql% echo        null BLANK,
>>%file_sql% echo        'Plan Hash    :   '^|^|sps.plan_hash_value bb,
>>%file_sql% echo        'Last Date   : '^|^|substr^(sps.last_load_time,1,16^) cc,
>>%file_sql% echo        'Module Name : '^|^|decode^(greatest^(length^(sps.module^),13^),13,lpad^(sps.module,13,' '^),sps.module^) dd,
>>%file_sql% echo        null BLANK,
>>%file_sql% echo        'Schema name  : '^|^|lpad^(sps.schema_name,12,' '^) ee,
>>%file_sql% echo        'Optim. Mode : '^|^|lpad^(sps.optimizer_mode,12,' '^) ff,
>>%file_sql% echo        'Optim. Cost :'^|^|to_char^(sps.optimizer_cost,'9G999G999G999'^) gg,
>>%file_sql% echo        null BLANK,
>>%file_sql% echo        'Rows         :'^|^|to_char^(nbr_rows,'9999G999G999'^) hh,
>>%file_sql% echo        'Rows / Exec : '^|^|to_char^(round^(nbr_rows/decode^(execs,0,1,execs^)^),'999G999G999'^) ii,
>>%file_sql% echo        'Executions  :'^|^|to_char^(execs,'9G999G999G999'^) jj,
>>%file_sql% echo        null BLANK,
>>%file_sql% echo        'Ela Time^(s^)  : '^|^|lpad^(to_char^(ela_time/1000000, '999G990D9'^),12^) kk,
>>%file_sql% echo        'Ela  / Exec :  **'^|^|to_char^(round^(^(ela_time/1000000^)/execs,6^), '9G990D9'^)^|^|' **' ll,
>>%file_sql% echo        null BLANK,
>>%file_sql% echo        'CPU Time^(s^)  : '^|^|lpad^(to_char^(cpu_time/1000000, '999G990D9'^),12^) mm,
>>%file_sql% echo        'CPU  / Exec :'^|^|to_char^(round^(^(cpu_time/1000000^)/execs,6^), '9G999G990D9'^) nn,
>>%file_sql% echo        null BLANK,
>>%file_sql% echo        'Logical  I/O :'^|^|to_char^(lios,'9999G999G999'^) oo,
>>%file_sql% echo        'LIO  / Exec : '^|^|to_char^(round^(lios/decode^(execs,0,NULL,execs^)^),'999G999G999'^) pp,
>>%file_sql% echo        'LIO  / Row  :'^|^|to_char^(round^(lios/decode^(nbr_rows,0,NULL,nbr_rows^)^),'9G999G999G999'^) qq,
>>%file_sql% echo        null BLANK,
>>%file_sql% echo        'Physical I/O : '^|^|to_char^(pios,'999G999G999'^) rr,
>>%file_sql% echo        'PIO  / Exec : '^|^|to_char^(round^(pios/decode^(execs,0,NULL,execs^)^),'999G999G999'^) ss,
>>%file_sql% echo        'PIO  / Row  :' ^|^|to_char^(round^(pios/decode^(nbr_rows,0,NULL,nbr_rows^)^),'9G999G999G999'^) tt
>>%file_sql% echo from ^(select s.sql_text,
>>%file_sql% echo              s.plan_hash_value,
>>%file_sql% echo              s.last_load_time,
>>%file_sql% echo              s.module,
>>%file_sql% echo              s.optimizer_mode,
>>%file_sql% echo              s.optimizer_cost,
>>%file_sql% echo              u.username schema_name,
>>%file_sql% echo              s.rows_processed nbr_rows,
>>%file_sql% echo              s.executions execs,
>>%file_sql% echo              s.elapsed_time ela_time,
>>%file_sql% echo              s.cpu_time,
>>%file_sql% echo              s.buffer_gets lios,
>>%file_sql% echo              s.disk_reads pios
>>%file_sql% echo       from dba_users u, v$sql s
>>%file_sql% echo       where u.user_id = s.parsing_schema_id
>>%file_sql% echo       and   s.module like '%%%MODULE%%%'
>>%file_sql% echo       and   exists ^(select 'X' from v$sql_plan p where p.hash_value = s.hash_value and p.child_number = s.child_number^)
>>%file_sql% echo       order by s.elapsed_time / s.executions desc^) sps
>>%file_sql% echo where sps.execs ^> 0
>>%file_sql% echo and   ^(sps.ela_time/1000000^)/sps.execs ^>= %SQL_TIME%
if not defined LOGIN >>%file_sql% echo   and sps.schema_name in ^(select username from dba_users where default_tablespace not in ^('SYSTEM','SYSAUX','PERFSTAT'^)^)
if defined LOGIN >>%file_sql% echo and sps.schema_name = '%LOGIN%'    -- Lists only for a login 
>>%file_sql% echo   and sps.sql_text not like '%%SQL Analyze%%'
>>%file_sql% echo   and sps.sql_text not like '%%DBMS%%'
>>%file_sql% echo   and sps.sql_text not like '%%dbms%%'
>>%file_sql% echo   and sps.sql_text not like '%%$_%%'
>>%file_sql% echo   and sps.sql_text not like '%%sys.%%'
>>%file_sql% echo   and sps.sql_text not like '%%dba_%%'
>>%file_sql% echo   and rownum ^<= ^&TOP_NSQL
>>%file_sql% echo /
>>%file_sql% echo col aa clear
>>%file_sql% echo spool off
>>%file_sql% echo:
>>%file_sql% echo set term off head off pages 0
>>%file_sql% echo spool %file_tmp%
>>%file_sql% echo select 'select ''['^|^|ltrim^(to_char^(rownum,'009'^)^)^|^|'] '^|^|lpad^('-',%LEN_SQLT%-15,'-'^)^|^|'''from dual'^|^|chr^(10^)^|^|'union all'^|^|chr^(10^)^|^|
>>%file_sql% echo        'select plan_table_output from table^(dbms_xplan.display_cursor^('''^|^|to_char^(sps.hash_value^)^|^|''','^|^|
>>%file_sql% echo        to_char^(sps.child_number^)^|^|', ''%OPTION%''^)^);'
>>%file_sql% echo from ^(select s.hash_value, s.child_number, s.executions execs, s.elapsed_time ela_time, u.username schema_name, s.sql_text
>>%file_sql% echo       from dba_users u, v$sql s
>>%file_sql% echo       where u.user_id = s.parsing_schema_id
>>%file_sql% echo       and   s.module like '%%%MODULE%%%'
>>%file_sql% echo       and   exists ^(select 'X' from v$sql_plan p where p.hash_value = s.hash_value and p.child_number = s.child_number^)
>>%file_sql% echo       order by s.elapsed_time / s.executions desc^) sps
>>%file_sql% echo where sps.execs ^> 0
>>%file_sql% echo and   ^(sps.ela_time/1000000^)/sps.execs ^>= %SQL_TIME%
if not defined LOGIN >>%file_sql% echo   and sps.schema_name in ^(select username from dba_users where default_tablespace not in ^('SYSTEM','SYSAUX','PERFSTAT'^)^)
if defined LOGIN >>%file_sql% echo and sps.schema_name = '%LOGIN%'    -- Lists only for a login 
>>%file_sql% echo   and sps.sql_text not like '%%SQL Analyze%%'
>>%file_sql% echo   and sps.sql_text not like '%%DBMS%%'
>>%file_sql% echo   and sps.sql_text not like '%%dbms%%'
>>%file_sql% echo   and sps.sql_text not like '%%$_%%'
>>%file_sql% echo   and sps.sql_text not like '%%sys.%%'
>>%file_sql% echo   and sps.sql_text not like '%%dba_%%' 
>>%file_sql% echo   and rownum ^<= ^&TOP_NSQL
>>%file_sql% echo /
>>%file_sql% echo spool off
>>%file_sql% echo set term on pages 1000
>>%file_sql% echo spool %file_log% append
>>%file_sql% echo PROMPT
>>%file_sql% echo start %file_tmp%
>>%file_sql% echo set term on head on pages 1000
goto:EOF
::#
::# End of Audit_sql
::#************************************************************#

:Check_datefmt
::#************************************************************#
::# Checks if the Oracle date format is valid
::#
::# List of arguments passed to the function:
::#  %1 = format date variable
::#
set file_tmp=%dirname%\%progname%.tmp
 >%file_tmp% echo spool %file_tmp%.log
>>%file_tmp% echo whenever sqlerror exit sql.sqlcode
>>%file_tmp% echo connect %DB_USER%/%DB_PWD%
setlocal enabledelayedexpansion
if not defined %~1 endlocal & exit /B
set FMT=!%1!

:: Generates the SQL script to execute
>>%file_tmp% echo select to_char^(sysdate, '!FMT!'^) %1 from dual;
>>%file_tmp% echo spool off
>>%file_tmp% echo exit

:: Executes the SQL Script
sqlplus -s /nolog @%file_tmp% >NUL

:: Checks the result of the SQL script execution
for /f "delims=" %%a in ("!FMT!") do endlocal & set "FMT=%%a"
findstr "^ORA-" %file_tmp%.log 2>&1 >NUL
if errorlevel 1 (
	set RET=0
) else (
	findstr "ORA-" %file_tmp%.log
	if not defined FMT (
		echo ---------
		echo ERROR: Invalid Oracle date format for variable "%1" [%FMT%] !!
		echo ---------
	)
	set RET=1
	call :Display STATUS : KO
	exit /B %RET%
)
del %file_tmp% %file_tmp%.log
goto:EOF
::#
::# End of Check_datefmt
::#************************************************************#

:Check_target
::#************************************************************#
::# Checks target used for auditing each section  
::#
set RET=0
if defined TARGET set TARGET=%TARGET:"=%
call :Upper TARGET
for %%i in (%TARGET%) do for /d %%j in (HOST DB INIT RMAN MEM TBSP FILE REDO UNDO TEMP OBJ WAIT USER LOCK STAT SQL ERR ALL) do if /I (%%i)==(%%j) (set FLG_%%i=1)
if (%FLG_HOST%)==(0) if (%FLG_DB%)==(0) if (%FLG_INIT%)==(0) if (%FLG_BAK%)==(0) if (%FLG_MEM%)==(0) if (%FLG_TBSP%)==(0) if (%FLG_FILE%)==(0) if (%FLG_REDO%)==(0) if (%FLG_UNDO%)==(0) if (%FLG_TEMP%)==(0) if (%FLG_OBJ%)==(0) if (%FLG_ERR%)==(0) if (%FLG_WAIT%)==(0) if (%FLG_USER%)==(0) if (%FLG_LOCK%)==(0) if (%FLG_STAT%)==(0) if (%FLG_SQL%)==(0) set RET=1
if (%RET%)==(1) echo ERROR: Invalid option [%TARGET%] for the variable "TARGET" !!
exit /B %RET%
::#
::# End of Check_target
::#*******************************************************

:Display_script
::#************************************************************#
::# Displays the content of the script generated if asked
::#
::# List of arguments passed to the function:
::#  %* = script file
::#
if "%DISPLAY%"=="0" exit /B
set ARGS=%*
for /f "tokens=2 delims=[]" %%i in ('echo %ARGS%') do set filename=%%i
 >%file_tmp% echo:
>>%file_tmp% echo %ARGS%
>>%file_tmp% echo ====================================================================================
>>%file_tmp% (type %filename% | findstr /I /V "^#")
>>%file_tmp% echo ====================================================================================
type %file_tmp%
if "%PAUSE%"=="1" call :Pause
 >%file_tmp% echo:
>>%file_tmp% echo %ARGS%
>>%file_tmp% echo ====================================================================================
>>%file_tmp% (type %filename% | findstr /I /V "^#")
>>%file_tmp% echo ====================================================================================
type %file_tmp% >>%file_log%
del %file_tmp%
goto:EOF
::#
::# End of Display_script
::#************************************************************#

:Pause
::#************************************************************#
::# Makes a pause before execution if asked
::#
echo PRESS ANY KEY TO CONTINUE OR [CTRL-C] TO CANCEL...
pause>NUL
echo:
goto:EOF
::#
::# End of Pause
::#************************************************************#

:Info_sysdate
::#************************************************************#
::# Retrieves the system date in the "yymmdd" format and time in the "HHMM" format 
::#
for /f "tokens=2 delims=()" %%i in ('ver ^| date') do set format=%%i

:: Case when the system format date is in French : "jj-mm-aa"
if "%format%"=="jj-mm-aa" for /F "tokens=1,2,3 delims=/ " %%i in ('echo %DATE:~,-4%%DATE:~-2%') do set DAT=%%k%%j%%i
if "%format%"=="dd-mm-yy" for /F "tokens=1,2,3 delims=/ " %%i in ('echo %DATE:~,-4%%DATE:~-2%') do set DAT=%%k%%j%%i
if "%format%"=="jj-mm-aa" set SYSDATE=%DATE%
if "%format%"=="dd-mm-yy" set SYSDATE=%DATE%

:: Case when the system format date is in English : "day mm/dd/yyyy"
if "%format%"=="mm-jj-aa" for /F "tokens=1,2,3 delims=/" %%i in ('echo %DATE:~4,-4%%DATE:~-2%') do set DAT=%%k%%i%%j
if "%format%"=="mm-dd-yy" for /F "tokens=1,2,3 delims=/" %%i in ('echo %DATE:~4,-4%%DATE:~-2%') do set DAT=%%k%%i%%j
if "%format%"=="mm-jj-aa" for /F "tokens=1,2,3 delims=/" %%i in ('echo %DATE:~4%') do set SYSDATE=%%j/%%i/%%k
if "%format%"=="mm-dd-yy" for /F "tokens=1,2,3 delims=/" %%i in ('echo %DATE:~4%') do set SYSDATE=%%j/%%i/%%k

:: Case when the system format date is in Spanish : "dd-mm-aa"
if "%format%"=="dd-mm-aa" for /F "tokens=1,2,3 delims=/" %%i in ('echo %DATE:~4,-4%%DATE:~-2%') do set DAT=%%k%%i%%j
if "%format%"=="dd-mm-aa" set SYSDATE=%DATE%

for /f "tokens=1,2,3 delims=: " %%i in ('time /t') do set TIM=%%i%%j
if not defined DAT (
	echo ERROR: Unable to retrieves the system format datetime !!
	goto End
)
goto:EOF
::#
::# End of Info_sysdate
::#************************************************************#

:Create_dir
::#************************************************************#
::# Creates directory if not existing
::#
::# List of arguments passed to the function:
::#  %1 = full path for the directory
::#
set RET=0
if (%1)==() echo ERROR: The argument passed to the function is null or empty !! && exit /B 1
if not exist %1 mkdir %1 2>NUL
if errorlevel 1 (
	call :Display ERROR: Failed to create directory [%1] !!
	set RET=1
)
exit /B %RET%
::#
::# End of Create_dir
::#************************************************************#

:Sleep
::#************************************************************#
::# Wait loop for a number of seconds
::#
::# List of arguments passed to the function:
::#  %1 = number of seconds to wait    (0 by default)
::#  %2 = Flag to force automatic wait (0 by default)
::#
:: Automatic wait for the display when the program runs from Windows Explorer
if not (%1)==() (set SECS=%1) else (set SECS=0)
if not (%2)==() (set WAIT=1)  else (set WAIT=0)

for /F "usebackq delims=" %%i in ('%CMDCMDLINE%') do if not "%%i"==""%ComSpec%" " set WAIT=1
if (%WAIT%)==(1) if "%VER_SYS%"=="5.2" (ping -n %SEC% localhost>NUL) else (timeout /t %SECS%>NUL)
goto:EOF
::#
::# End of Sleep
::#************************************************************#

:Check_verora
::#************************************************************#
::# Checks Oracle version (must be 10.x, 11.x, 12.x, 18c or 19c)
::#
set RET=1
for /f "tokens=3 delims= " %%i in ('%ORACLE_HOME%\bin\sqlplus -V') do set VER_ORA=%%i
for /f "tokens=1,2 delims=." %%i in ('echo %VER_ORA%') do set VER_ORA=%%i.%%j
if not "%VER_ORA%"=="10.1" if not "%VER_ORA%"=="10.2" if not "%VER_ORA%"=="11.1" if not "%VER_ORA%"=="11.2" if not "%VER_ORA%"=="12.1" if not "%VER_ORA%"=="12.2" if not "%VER_ORA%"=="18.0" if not "%VER_ORA%"=="19.0" (
	echo ERROR: Bad version number for Oracle [%VER_ORA%] : 10g, 11g, 12c, 18c or 19c required !!
	echo:
	exit /B 1
)
set RET=0
goto:EOF
::#
::# End of Check_verora
::#************************************************************#

:Check_versys
::#************************************************************#
::# Checks operating system version for Windows (must be 2003, 2008, 2012 or 2016)
::#
set RET=1
for /f "tokens=4,5 delims=. " %%i in ('ver') do set VER_SYS=%%i.%%j
if "%OS%"=="Windows_NT" (
	if not "%VER_SYS%" == "5.2" if not "%VER_SYS%" == "6.1" if not "%VER_SYS%" == "6.2" if not "%VER_SYS%" == "6.3" if not "%VER_SYS%" == "10.0" (
		echo ERROR: Bad version number for Windows [%VER_SYS%] : 2008, 2012 or 2016 required !!
		exit /B %RET%
	) else (set RET = 0)
) else (
	echo ERROR: The operating system [%OS%] is not compatible: Windows required !!
	exit /B %RET%
)
goto:EOF
::#
::# End of Check_versys
::#************************************************************#

:Check_verapp
::#************************************************************#
::# Checks version, release and patch level for the Sage X3 application (must be v5 to v12)
::#
set RET=1
if not defined ADXDOS exit /B 2
(set REL_APP=) & (set VER_APP=) & (set PATCH=)
if exist "%ADXDOS%\FOLDERS.xml" if not defined VER_APP for /f "tokens=3-5 delims=(). " %%i in ('type "%ADXDOS%\FOLDERS.xml" ^| find ")</NEWVER>"') do (set VER_APP=%%i& set REL_APP=%%j& set PATCH=%%k)
if exist "%ADXDOS%\FOLDERS.xml" if not defined VER_APP for /f "tokens=3,4 delims=>.<" %%i in ('type "%ADXDOS%\FOLDERS.xml" ^| find "NEWVER"') do (set VER_APP=%%i& set REL_APP=%%j)
if exist "%ADXDOS%\FOLDERS.xml" if not defined PATCH for /f "tokens=3 delims=><" %%i in ('type "%ADXDOS%\FOLDERS.xml" ^| find "PATCH"') do set PATCH=%%i
if exist "%ADXDOS%\FOLDERS.xml" if not defined VER_APP for /f "tokens=3 delims=><" %%i in ('type "%ADXDOS%\FOLDERS.xml" ^| find "VERSION"') do set VER_APP=%%i
set PATCH=%PATCH:P=%
if "%VER_APP%"=="" exit /B 2
if defined VER_APP if not defined REL_APP if /I %VER_APP% GEQ 150 (set VER_APP=%VER_APP:~1,1%& set REL_APP=%VER_APP:~-1%)
if defined VER_APP if not defined REL_APP if /I %VER_APP% GEQ 130 set REL_APP=%VER_APP%
if defined VER_APP if not defined REL_APP if /I %VER_APP% GEQ 130 set VER_APP=%VER_APP:~,2%0
if /I %VER_APP% GEQ 130 if /I not %VER_APP% GEQ 150 ( 
	echo ERROR: Bad version number for Sage X3 application [V%VER_APP%] : V5, V6, V7+, V11 or V12 required !!
	exit /B %RET%
)
set apversion=%VER_APP%.%REL_APP%.%PATCH%
set RET = 0
goto:EOF
::#
::# End of Check_verapp
::#************************************************************#

:Upper
::#************************************************************#
::# Converts lowercase character to uppercase for a variable
::#
setlocal enabledelayedexpansion
if not defined %~1 endlocal & exit /B
set STR=!%1!
if not "%STR%"=="%%" for %%z in (A B C D E F G H I J K L M N O P Q R S T U V W X Y Z) do call set STR=!STR:%%z=%%z!
for /f "delims=" %%a in ("!STR!") do endlocal & set "%1=%%a"
exit /B 0
::#
::# End of Upper
::#************************************************************#
::#

:Lower
::#************************************************************#
::# Converts uppercase character to lowercase for a variable
::#
setlocal enabledelayedexpansion
if not defined %~1 endlocal & exit /B
set STR=!%1!
if not "%STR%"=="%%" for %%z in (a b c d e f g h i j k l m n o p q r s t u v w x y z) do call set STR=!STR:%%z=%%z!
for /f "delims=" %%a in ("!STR!") do endlocal & set "%1=%%a"
exit /B 0
::#
::# End of Lower
::#************************************************************#
::#

:Display_timestamp
::#************************************************************#
::# Displays timestamp and redirects a message to the trace file
::#
::# List of arguments passed to the function:
::#  %* = message text
::#
set ARGS=%*
call :Display %SYSDATE% %TIME:~,8% %ARGS%
goto:EOF
::#
::# End of Display_timestamp
::#************************************************************#

:Display
::#************************************************************#
::# Displays and redirects a message to the trace file
::#
::# List of arguments passed to the function:
::#  %* = message text
::#
set ARGS=%*
if not defined ARGS (echo:) else (echo %ARGS%)
if not defined file_log exit /B
if not defined ARGS (echo: >>%file_log%) else (echo %ARGS% >>%file_log%)
goto:EOF
::#
::# End of Display
::#************************************************************#

:Version
::#************************************************************#
::# Displays the version number, the last modified date of the program,
::# and the list of variables modified & functions defined.
::#
set file_tmp=%dirname%\%progname%.tmp
for /f "tokens=5" %%i in ('findstr /C:"Last date" %dirname%\%progname%%extname% ^| findstr /V findstr') do set lastdate=%%i
call :Check_verapp
if     "%VER_APP%"=="" if defined ADXDOS echo WARNING: Unable to identify version for the Sage X3 application !!
if     "%VER_APP%"=="" >%file_tmp% echo %dirname%\%progname%%extname% - WINDOWS v%version% ^(%lastdate%^)
if not "%VER_APP%"=="" >%file_tmp% echo %dirname%\%progname%%extname% - WINDOWS v%version% ^(%lastdate%^) for Sage %type_prd% %apversion%
>>%file_tmp% echo:
>>%file_tmp% echo List of variables modified:
>>%file_tmp% echo --------------------------
set END=
for /f "tokens=1* delims=:" %%i in ('findstr /n /c:"END OF IMPLEMENTATION-DEPENDANT VARIABLES" %dirname%\%progname%%extname% ^| findstr /v findstr') do if not defined END set END=%%i
for /f "tokens=1,* delims=[:]" %%i in ('findstr /n "^set" %dirname%\%progname%%extname% ^| findstr /v "=$"') do @if %%i leq %END% (>>%file_tmp% echo %%j)
>>%file_tmp% echo:
>>%file_tmp% echo List of functions defined:
>>%file_tmp% echo -------------------------
for /f "delims=: " %%i in ('findstr "^:[A-Z]" %dirname%\%progname%%extname%') do @echo %%i >>%file_tmp%
type %file_tmp% | more
del %file_tmp%
goto End
::#
::# End of Version
::#************************************************************#

:Banner
::#************************************************************#
::# Banner displayed at the beginning of the command execution
::#
call :Display #------------------------------------------------------------------------------
call :Display #  %progname%%extname% - version %version% for %dbversion%.
call :Display #  Makes an Oracle audit database for the Sage %type_prd% solution [%ORACLE_SID%].
call :Display #  %copyright% by %author% - All Rights Reserved.
call :Display #------------------------------------------------------------------------------
goto:EOF
::#
::# End of Banner
::#************************************************************#

:Usage
::#************************************************************#
::# Usage for the execution of the command                     #
::#                                                            #
echo Usage: %progname%%extname% [/V] [^<TARGET^> ...]
echo:
echo        By default, all Oracle elements are checked in the database specified in settings
echo        else individually with the following options:
echo            HOST = Audits host computer for the database
echo              DB = Audits Database info                            
echo            INIT = Audits Main init.ora system parameters          
echo             BAK = Audits RMAN configuration & backup              
echo             MEM = Audits Memory usage and advisor                 
echo            TBSP = Audits Tablespace info                          
echo            FILE = Audits DB files info and IO activity & history  
echo            REDO = Audits Redo log info & activity                 
echo            UNDO = Audits UNDO usage & activity                    
echo            TEMP = Audits TEMP usage                               
echo             OBJ = Audits Most large fragmented and invalid objects
echo            WAIT = Audits Wait & TOP timed events                  
echo            USER = Audits User info & session activity             
echo            LOCK = Audits Lock activity & history (optional)       
echo            STAT = Audits Statistics objects & operations          
echo             SQL = Audits Top SQL ordered by Elapsed time          
echo             ERR = Audits alert Oracle history ^(only from oracle 12c and above^)
echo:
echo              /V = Displays info about the program: version number, last date, variables modified and functions defined.
echo:
echo     Exit status = 0 : OK
echo                 = 1 : ERROR
echo                 = 2 : WARNING
::#
::# End of Usage
::#************************************************************#

:End
::#************************************************************#
::# End of the program
::#

:: Waits for the display
call :sleep %DELAY%

:: Returns the exit code
exit /B %RET%
