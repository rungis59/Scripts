@echo off && mode con lines=70 cols=150 && color f1
::##################################################################################################################################
::#
::# check_oralock.cmd
::#
::# Description : Monitors current lock during a period for a Oracle database configured with a Sage applicative solution.
::#
::# Last date   : 14/10/2020
::#
::# Version     : WINDOWS - 2.08
::#
::# Author      : F.SUSSAN / SAGE
::#
::# Syntax      : check_oralock [/VPETF] [ <INTERVAL> ] [ <COUNT> ] [ <LOGIN> ]
::#
::# Notes       : This script must be executed on the applicative server in version Sage X3 V5, V6, V7+, V11 or V12.
::#               The database in version Oracle 10g/11g/12c/18c can be located on a different server and operating system (Linux/Unix).
::#               A SQL script is generated to be executed with SQL*Plus by a DB Admin user.
::#               It is running for a total period of 8 hours by default.
::#               It is executed in regular time interval (30 seconds by default) for a number of times (960 by default).
::#               A new trace file (logs\check_oralock_YYMMDD-HHMM.log) is generated during the monitoring.
::#               The deletion of oldest trace files is  managed.
::# 
::#               The monitoring covers following sections by default for all applicative logins.
::#               For each step:
::#               - NEW X3 sessions
::#               - NEW module usage
::#               - NEW login usage
::#               - ALL Locked symbols - Summary
::#               - NEW Locked symbols - Detail
::#               - Memory usage
::#               - Active sessions
::#               - Session statistics
::#               - Blocking sessions
::#               - Locks by user
::#               - Locked transactions
::#               - Locked objects
::#               - Current IO and CPU Workload
::#
::#               Only the first step:
::#               - Deadlocks
::#
::#               Only the first and last step:
::#               - ALL X3 sessions
::#               - ALL module usage
::#               - ALL login usage
::#               - Lock history
::#               - Top segment by lock wait
::# 
::#               ATTENTION, the ADXDIR variable, that specifies location where the runtime of the Sage X3 Solution is installed, is needed :
::#               - to initialize Oracle variables in the program (ORACLE_SID, ORACLE_HOME)
::#               - to map each process "sadora" (PID) attached to one X3 session with the corresponding Oracle process
::#
::#               ATTENTION, the section "Waits for mutexes" is available only if the fixed tables X$KGLOG is accessible for the admin oracle account.
::#               - You must before execute these SQL instructions connected sys as SYSDBA:
::#                 SQL> CREATE VIEW X$_KGLOB AS SELECT * FROM X$KGLOB;
::#                 SQL> GRANT SELECT ON X$_KGLOB TO SYSTEM;
::#                 SQL> CREATE SYNONYM SYSTEM.X$KGLOB FOR SYS.X$_KGLOB;
::#
::#               ATTENTION, the section "Deadlocks" is available only from Oracle 11g if the dynamic performance view is accessible for the admin oracle account.
::#               - You may have before execute this SQL instruction connected sys as SYSDBA:
::#                 SQL> GRANT SELECT ON V$DIAG_ALERT_EXT TO SYSTEM;
::#
::#               At the beginning of the report:
::#               - Lists all power schemes in the current user's environment (powercfg -l)
::#               - Displays detailed configuration information about the computer (systeminfo)
::#               - Lists infos for each logical volume drive locally (fsutil)
::#               - Displays the statistics log for the local server (net statistics server|workstation)
::#               - Displays all Windows event logs collected type system and application for the last month (wevtutil)
::#               - Displays old deadlock occurred (only from Oracle 11g)
::#
::#               During the monitoring for each step: 
::#               - Displays the total number of X3 sessions" and distinct logins connected during the interval
::#               - Displays the total number of X3 sessions per type (PRIMARY, SECONDARY, BATCH, WEB-SERVICES and VT TERMINAL)
::#               - Displays the total number of "Blocking locks" and "Deadlocks" detected with an alert message
::#               ATTENTION, the command line tool: "bin\diff.exe" is used for showing differences with the previous result of psadx.
::# 
::#               After each step (in option): 
::#               - collects Windows performance counters in an output file (typeperf_<SID>_YYMMDD-HHMM.log)
::#
::#               At the end of the report:
::#               - Displays new deadlock occurred (only from Oracle 11g and above)
::#               - Displays a summary about distinct number of deadlocks and blocking locks
::# 
::# Examples    : check_oralock
::#                   Monitors current locks in the Oracle database during the default period : every 30 secs 960 times = 8 hours.
::#               check_oralock 60 600
::#                   Monitors current locks in the Oracle database during the following period : every min 600 times = 10 hours.
::#               check_oralock 30 1440 PROD
::#                   Monitors current locks in the Oracle database for the login PROD during the following period : every 30 secs 1440 times = 12 hours.
::# 
::#               The following alert messages can be occurred during an interval (STEP) of the monitoring:
::#                   **** BLOCKING LOCK DETECTED (106:14344>102:1892 ) !! ****
::#                      The SQL session identified by SID=106 and PID=14344 is blocking another SQL session identified by SID=102 and PID=1892.
::#                   **** DEADLOCK DETECTED (106:14344<>102:1892) !! ****
::#                      A deadlock is occurred between 2 sessions identified by (SID=106, PID=14344) and (SID=102 and PID=1892) while waiting for same resources.
::# 
::# Exit status : = 0 : OK
::#               = 1 : ERROR
::#               = 2 : WARNING
::#
::# Copyright © 2011-2020 by SAGE Professional Services - All Rights Reserved.
::#
::##################################################################################################################################
::#
::# Modifications history
::# --------------------------------------------------------------------------------------------------------------------------------
::# ! Date       ! Version ! Author       ! Description
::# !------------+---------+--------------+-----------------------------------------------------------------------------------------
::# ! 13/02/2014 !  1.05   ! F.SUSSAN     ! Official use of the script by the French IT & System Sage X3 team.
::# !------------+---------+--------------+-----------------------------------------------------------------------------------------
::# ! 01/08/2014 !  1.06   ! F.SUSSAN     ! Calls functions for a better readability of the program.
::# !------------+---------+--------------+-----------------------------------------------------------------------------------------
::# ! 24/10/2014 !  1.07   ! F.SUSSAN     ! Uses the "ADXDIR" variable to initialize all others variables needed in the script.
::# !            !         !              ! Compatibility ensured for database located on a different server and operating system (multi-tier).
::# !            !         !              ! Displays the number of blocking lock and deadlock scanned in the trace file during the monitoring.
::# !            !         !              ! At the end of the report, a summary lock activity is displayed with statistics.
::# !------------+---------+--------------+-----------------------------------------------------------------------------------------
::# ! 20/03/2015 !  1.08   ! F.SUSSAN     ! Compatibility ensured in X3 V7 version with Oracle 11g R2.
::# !            !         !              ! Sets by default the variable "NBR_RET" about the number of days retention (=14).
::# !------------+---------+--------------+-----------------------------------------------------------------------------------------
::# ! 05/05/2015 !  1.08a  ! F.SUSSAN     ! Adds the case when the system format date is in Spanish : "dd-mm-aa" (Info_sysdate).
::# !            !         !              ! Adds /V option to display the version number, the last modified date of the program,
::# !            !         !              ! and the list of variables modified & functions defined.
::# !------------+---------+--------------+-----------------------------------------------------------------------------------------
::# ! 26/02/2016 !  1.09   ! F.SUSSAN     ! Adds the "Login usage" in the FOLDER section.
::# !            !         !              ! Makes a loop for all existing x3 folder if LOGIN variable is not set.
::# !------------+---------+--------------+-----------------------------------------------------------------------------------------
::# ! 19/09/2016 !  1.09a  ! F.SUSSAN     ! Compatibility ensured in X3 V7 version with Oracle 12c.
::# !            !         !              ! Replaces CREDAT_0 by CREDATTIM_0 from Sage X3 V7 in select from the AFCTCUR table.
::# !            !         !              ! Fixed the display for the "Login usage" in the FOLDER section.
::# !            !         !              ! Added the column "App.id" in the list of X3 sessions.
::# !            !         !              ! Added the column "Blocked" in the "Session statistics" section.
::# !            !         !              ! Fixed the "Status" (Blocking/Blocked) in the "Locks by user" section.
::# !            !         !              ! Added a new section "Top segment by lock wait" displayed during the first and last interval of monitoring.
::# !            !         !              ! Added a new section "Waits for mutexes" for 2 events: "Library cache" and "Cursor pin".
::# !            !         !              ! A notification email is also sent in case of deadlock detected during the monitoring.
::# !            !         !              ! Added the variable FLG_ALL to list all or only new element during the monitoring.
::# !------------+---------+--------------+-----------------------------------------------------------------------------------------
::# ! 05/10/2016 !  1.09b  ! F.SUSSAN     ! Added a system info summary in the beginning of the monitoring report.
::# !------------+---------+--------------+-----------------------------------------------------------------------------------------
::# ! 15/11/2016 !  2.01   ! F.SUSSAN     ! Added the function "Check_versys" to check the operating system version for Windows.
::# !            !         !              ! Fixed the timer in the function "Sleep".
::# !------------+---------+--------------+-----------------------------------------------------------------------------------------
::# ! 15/02/2017 !  2.02   ! F.SUSSAN     ! Deleted temporary psadx files at the end of the monitoring.
::# !            !         !              ! Added a display at the beginning of the report about:
::# !            !         !              ! - statistics log for the local server
::# !            !         !              ! In option:
::# !            !         !              ! - main Windows performance counters (/C or FLG_PRF='1')
::# !            !         !              ! - last windows event logs collected with system and application type (/E or FLG_EVT='1')
::# !------------+---------+--------------+-----------------------------------------------------------------------------------------
::# ! 27/04/2017 !  2.03   ! F.SUSSAN     ! Compatibility ensured for Oracle database 12c and Sage X3 product V11.
::# !            !         !              ! Added the function "Info_psadx" to replace the result of the psadx command from X3 V11.
::# !            !         !              ! Added a list of all power management plans (schemes) in the current user's environment.
::# !------------+---------+--------------+-----------------------------------------------------------------------------------------
::# ! 22/01/2018 !  2.03a  ! F.SUSSAN     ! Added the CREDAT variable to define column CREDAT_0 or CREDATTIM_0 from the AFCTCUR table.
::# !------------+---------+--------------+-----------------------------------------------------------------------------------------
::# ! 19/10/2018 !  2.04   ! F.SUSSAN     ! Added the USR_SYS variable to use an admin oracle account for connection without sysdba.
::# !            !         !              ! Compatibility ensured for Windows Server 2016.
::# !            !         !              ! Fixed problem of translation characters during binary execution (code page used = 1252).
::# !            !         !              ! Added supplemental session types such as Web page, Classic page and Eclipse from Sage X3 V7+.
::# !            !         !              ! Generated an output text file (tasklist*.log) in option containing running processes with 
::# !            !         !              ! associated information: datetime, process, PID, username, mem usage and CPU time (/T or FLG_TSK='1').
::# !            !         !              ! Added the LCK_TIME variable which is a threshold to alert for each detected blocking lock (30 secs by default).
::# !            !         !              ! Added new option (/F or FLG_FRG='1') to display fragmentation analysis report for each volume disk.
::# !            !         !              ! Added -t option with psadx command to display session type only with Sage X3 product before v11.
::# !            !         !              ! Displayed only the process id in the PID field without the thread id specified after (:).
::# !            !         !              ! Added old and new each deadlock occurred before and after the monitoring.
::# !            !         !              ! Fixed the display in list of login and module names when are empty or identical.
::# !            !         !              ! Added the LAN variable to display text according to language specified.
::# !------------+---------+--------------+-----------------------------------------------------------------------------------------
::# ! 07/11/2018 !  2.05   ! F.SUSSAN     ! Added the PROG variable to identify the main program name in the "Active sessions" item.
::# !            !         !              ! Fixed the display of the list and count of X3 sessions used from Sage X3 V11.
::# !------------+---------+--------------+-----------------------------------------------------------------------------------------
::# ! 04/03/2019 !  2.06   ! F.SUSSAN     ! Fixed trace file name where time command is in english (US) format display.
::# !            !         !              ! Defined the FLG_PSADX variable to indicate if result of psadx is issue from tables (ASSYM*).
::# !            !         !              ! Added the column "App.id" in the section "NEW Locked symbols - Detail".
::# !            !         !              ! Fixed display for Module and Login usage.
::# !            !         !              ! Used the "Waits for mutexes" item only when SYSTEM connection is used.
::# !            !         !              ! Changed order for list of variables to set.
::# !------------+---------+--------------+-----------------------------------------------------------------------------------------
::# ! 02/06/2020 !  2.07   ! F.SUSSAN     ! Added the function "Check_verapp" for checking Sage X3 application version (V5 to V12).
::# !            !         !              ! Added display of type and version for the Sage application (typeprd, apversion) in the "version" function.
::# !            !         !              ! Added infos for each logical volume drive locally at the beginning of the report.
::# !            !         !              ! Fixed when the EXCL_LOGIN variable is used.
::# !------------+---------+--------------+-----------------------------------------------------------------------------------------
::# ! 14/10/2020 !  2.08   ! F.SUSSAN     ! Added new compatibility for Oracle database 18c.
::# !            !         !              ! Added supplemental infos at the beginning of the report:
::# !            !         !              ! - Paging file usage (swap)
::# !            !         !              ! - Physical disks (including SSD/HDD) available from Windows Server 2008 R2
::# !            !         !              ! - Logical volume drives locally
::# !            !         !              ! Added list info version for each Sage X3 installed programs.
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
::#!!!!    SPECIFIC VARIABLES USED FOR THE OPERATION     !!!!#
::#!!!!--------------------------------------------------!!!!#

:: Name of the DB user with SYSTEM privileges (=system by default)
set DB_USER=

:: Interval in seconds (10-999] before the next execution of the monitoring SQL script (if null value = 30 seconds by default)
set INTERVAL=60

:: Count to define the number of times the monitoring SQL script is executed (if null value = 960 times)
set COUNT=

:: Login used as search criteria for the monitoring (=x3 folder, else all login existing)
set LOGIN=

:: Login excluded as search criteria for the monitoring (each value must be separated by a blank)
set EXCL_LOGIN=

:: Flag to collect Windows performance counters (by default 0 else 1)
set FLG_PRF=

:: Flag to display last Windows event logs collected type system and application (by default 0 else 1)
set FLG_EVT=

:: Flag to list currently running processes with associated information (by default 0 else 1)
set FLG_TSK=

:: Flag to display fragmentation analysis report for each volume disk (by default 0 else 1)
set FLG_FRG=

:: Lists all and not only new elements at the beginning and the end of the monitoring (='0' by default if null value)
set FLG_ALL=

::#!!!!--------------------------------------------------!!!!#
::#!!!!    OTHER OPTIONAL VARIABLES THAT CAN BE USED     !!!!#
::#!!!!             DEPENDING ON THE CONTEXT             !!!!#
::#!!!!--------------------------------------------------!!!!#

:: Number of days retention before deletion older trace files (='14' by default)
set NBR_RET=

:: Location of X3 folders for the Sage X3 solution
set ADXDOS=

:: Elapsed time threshold in seconds before making an alert when detecting blocking lock (if null value = 30 secs by default else must be range between 10 and 999)
set LCK_TIME=

:: 1st Oracle format date used (='DD/MM/YY' by default if null value)
set FMT_DAT1=

:: 2nd Oracle format date used (='DD/MM HH24:MI' by default if null value)
set FMT_DAT2=

:: 3rd Oracle format date used (='DD/MM/YY HH24:MI:SS' by default if null value)
set FMT_DAT3=

:: Display length used for SQL Text (='250' by default if null value)
set LEN_SQLT=

:: Number of first N rows returned (='20' by default if null value)
set TOP_NSQL=

:: Location of another script to execute at the beginning of the monitoring (by default located in the SCRIPTDIR directory)
set SCRIPTEXE=

:: The command line tool used for showing differences between files (if null value, the command "diff.exe" is used by defaut located in the sub-directory "\bin".
set CMD_DIFF=

:: Language used to display text from X3 tables (by default = 'FRA' else 'ENG', 'ITA', 'POR', 'SPA', 'GER' otherwise 'ARB', 'BRI', 'CHI', 'POL', 'RUS')
set LAN=

:: String used to identify the main program name for active sessions (='sadora.exe' by default)
set PROG=

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

:: Prints to confirm before execution (by default 1 else 0)
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
if (%1)==(/P)   (set FLG_PRF=1) && shift
if (%1)==(/M)   (set FLG_TSK=1) && shift
if (%1)==(/E)   (set FLG_EVT=1) && shift
if (%1)==(/F)   (set FLG_FRG=1) && shift
if (%1)==(/PE)  (set FLG_PRF=1) && (set FLG_EVT=1) && shift
if (%1)==(/EP)  (set FLG_PRF=1) && (set FLG_EVT=1) && shift
if (%1)==(/PET) (set FLG_PRF=1) && (set FLG_EVT=1) && (set FLG_TSK=1) && shift
if (%1)==(/PTE) (set FLG_PRF=1) && (set FLG_EVT=1) && (set FLG_TSK=1) && shift
if (%1)==(/EPT) (set FLG_PRF=1) && (set FLG_EVT=1) && (set FLG_TSK=1) && shift
if (%1)==(/ETP) (set FLG_PRF=1) && (set FLG_EVT=1) && (set FLG_TSK=1) && shift
if (%1)==(/TEP) (set FLG_PRF=1) && (set FLG_EVT=1) && (set FLG_TSK=1) && shift
if (%1)==(/TPE) (set FLG_PRF=1) && (set FLG_EVT=1) && (set FLG_TSK=1) && shift
if not (%1)==() (set INTERVAL=%1)
if not (%2)==() (set COUNT=%2)   
if not (%3)==() (set LOGIN=%3)   
if not (%4)==() goto :Usage

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

if defined LOGIN (
	call :Display_timestamp MONITORING %type_prd% LOCK ACTIVITY IN THE %type_db% DATABASE [%ORACLE_SID%] FOR THE LOGIN [%LOGIN%] EVERY %INTERVAL% SECS %COUNT% TIMES...
) else (
	call :Display_timestamp MONITORING %type_prd% LOCK ACTIVITY IN THE %type_db% DATABASE [%ORACLE_SID%] EVERY %INTERVAL% SECS %COUNT% TIMES...
)
if "%PAUSE%"=="1" call :Pause

:: Executes the loop SQL script for checking Oracle lock
call :Start_check_oralock || goto End
set RET=%ERRORLEVEL%
call :Display
call :Display_timestamp MONITORING ENDED. 

:: Checks the result of the SQL script execution
findstr "^ORA-" %file_log% 2>&1 >NUL
if errorlevel 1 (
	set RET=0
) else (
	set RET=1
)
if (%RET%)==(0) if not (%SUM_LCK%)==(0) (set RET=1)
if "%RET%"=="0" (
	if exist %file_sql% del %file_sql%>NUL
	if exist %file_adx% del %file_adx%>NUL
	call :Display STATUS : OK
) else (
	call :Display STATUS : KO
)
call :Display Trace file '%file_log%' generated.

:: Deletes older trace files
call :Display
forfiles /P "%LOGDIR%" /M "%progname%_%ORACLE_SID%_*.*" /D "-%NBR_RET%" /C "cmd /C del /S/F/Q @FILE|echo Deletion of : @FILE" 2>NUL

:: End of the program
goto End

:Init_variables
::#************************************************************#
::# Initializes variables used in the program
::#

:: Standard variables
set dbversion=Oracle Database 10g, 11g, 12c, 18c
set copyright=Copyright {C} 2011-2020
set author=Sage Group
for /F "delims=" %%i in ('hostname') do set hostname=%%i
for /F "delims=" %%i in ("%~nx0")    do set progname=%%~ni
for /F "delims=" %%i in ("%~nx0")    do set extname=%%~xi
set dirname=%~dp0
set dirname=%dirname:~,-1%
set file_log=
for /f "tokens=5 delims=- " %%i in ('findstr /C:"# Version" %dirname%\%progname%%extname% ^| findstr /v findstr ') do set version=%%i
set dbhome=%ORACLE_HOME%\bin
call set PATH=%dbhome%;%%PATH:%dbhome%=%%
call set PATH=%adxdir%\bin;%%PATH:%dbhome%=%%
set CURDIR=%CD%
call :Info_sysdate
if not defined SCRIPTDIR set SCRIPTDIR=%dirname%
if not defined LOGDIR    set LOGDIR=%SCRIPTDIR%\logs
if not defined DISPLAY   set DISPLAY=0
if not defined PAUSE     set PAUSE=0
if not defined DELAY     set DELAY=10

:: Specific variables
set type_db=ORACLE
if exist %ADXDIR%\bin\env.bat call %ADXDIR%\bin\env.bat
if not defined ADXDOS if exist "%ADXDIR%"\adxvolumes for /F "tokens=1,2,3 delims=: " %%i in ('type %ADXDIR%\adxvolumes ^| find /I "A:" ') do set ADXDOS=%%j:%%k
if not defined ADXDOS if exist %ADXDIR%\..\dossiers set ADXDOS=%ADXDIR:~,-8%\dossiers
if exist %ADXDIR%\SERV* for /f %%i in ('dir /B %ADXDIR%\SERV??') do set DOSS_REF=%%i
if exist %ADXDOS%\SERV* for /f %%i in ('dir /B %ADXDOS%\SERV??') do set DOSS_REF=%%i
if exist %ADXDIR%\SERV* for /f %%i in ('dir /B %ADXDIR%\SERV??') do set type_prd=%%i
if exist %ADXDOS%\SERV* for /f %%i in ('dir /B %ADXDOS%\SERV??') do set type_prd=%%i
if defined type_prd set type_prd=%type_prd:~4%
if not defined type_prd if defined ADXDOS for /f delims^=^"^ tokens^=4 %%i in ('type %ADXDOS%\FOLDERS.xml ^| find "MOTH1="') do set type_prd=%%i
if exist %ADXDOS%\%type_prd%\FIL\ASYSSMPROCES.fde (set FLG_PSADX=1) else (set FLG_PSADX=0)
if not defined DB_USER  set DB_USER=system
if not defined NBR_RET  set NBR_RET=14
if not defined INTERVAL set INTERVAL=30
if not defined COUNT    set COUNT=960
if not defined LCK_TIME set LCK_TIME=30
if not defined FMT_DAT1 set FMT_DAT1=DD/MM/YY
if not defined FMT_DAT2 set FMT_DAT2=DD/MM HH24:MI
if not defined FMT_DAT3 set FMT_DAT3=DD/MM/YY HH24:MI:SS
if not defined LEN_SQLT set LEN_SQLT=250
if not defined TOP_NSQL set TOP_NSQL=20
if not defined FLG_ALL  set FLG_ALL=0
if not defined CMD_DIFF set CMD_DIFF=diff.exe
if not defined FLG_PRF  set FLG_PRF=0
if not defined FLG_EVT  set FLG_EVT=0
if not defined FLG_TSK  set FLG_TSK=0
if not defined FLG_FRG  set FLG_FRG=0
if not defined LAN      set LAN=FRA
if not defined PROG     set PROG=sadora.exe
set CMD_SQL=sqlplus -s
set CON_SQL=%DB_USER%/%DB_PWD%
:: Defines the Oracle pack license required to display the "Lock history" section.
set ORA_PACK=DIAGNOSTIC
:: Defines the number of times that blocking locks  was detected during the monitoring
(set NEW_LCK=0) & (set SUM_LCK=0)
:: Defines the number of times that deadlocks was detected during the monitoring
(set NEW_DLO=0) & (set SUM_DLO=0)
:: Defines the number of distinct login and x3 session connected simultaneously during the monitoring
(set SUM_LOG=0) & (set SUM_SES=0)
:: Defines the number for each type of X3 session
(set SUM_PRM=0) & (set SUM_SEC=0) & (set SUM_BAT=0) & (set SUM_WEB=0) & (set SUM_TVT=0) & (set SUM_WPA=0) & (set SUM_CPA=0) & (set SUM_ECL=0)
:: Defines the code page used (West European Latin) to avoid problem of translation characters during binary execution
chcp 1252 >NUL
set TASK=adonix adxdsrv AdxSrvImp chrome eclipse ElastSch firefox iexplore httpd oracle node mongod sadora sadoss sadfsq sqlservr SyDocSrv Syracuse TNSLSNR
set CMD_PSADX=psadx
set LST_FINDPRG=Sage Safe Adonix Database 
goto:EOF
::#
::# End of Init_variables
::#************************************************************#

:Check_variables
::#************************************************************#
::# Checks the value for variables that are defined
::#
set RET=1

if not exist %ADXDIR%\bin\env.bat (
	echo ERROR: Invalid path for the variable "ADXDIR" [%ADXDIR%] !!
	exit /B %RET%
)
:: If the database is installed on the same server than the Sage X3 application
if not defined LOCAL (
 	sc query "OracleService%ORACLE_SID%">NUL
	if errorlevel 1 (
		echo ERROR: The database service is not defined [OracleService%ORACLE_SID%] !!
		exit /B %RET%
	)
	net start | findstr "OracleService%ORACLE_SID%$">NUL
	if errorlevel 1 (
		echo ERROR: The database service is not started [OracleService%ORACLE_SID%] !!
		exit /B %RET%
	)
)
if not exist "%ORACLE_HOME%\BIN" (
    echo ERROR: Invalid path for the variable "ORACLE_HOME" [%ORACLE_HOME%] !!
	exit /B %RET%
)
if not exist "%ORACLE_HOME%\BIN" (
    echo ERROR: Invalid path for the variable "ORACLE_HOME" [%ORACLE_HOME%] !!
	exit /B %RET%
)
if not defined ADXDOS (
	echo ERROR: You must specify the variable "ADXDOS" [%ADXDOS%] !!
	exit /B %RET%
)
if not defined DB_PWD (
	echo ERROR: The variable "DB_PWD" about password for the admin DB user [%DB_USER%] is not set !!
	exit /B %RET%
)
if defined ADXDOS if not exist %ADXDOS% (
	if not exist %ADXDOS%\X3_PUB (
		echo ERROR: The variable "ADXDOS" [%ADXDOS%] must match an existing X3 folder path !!
		exit /B %RET%
	)
)
if defined LOGIN if not exist %ADXDOS%\%LOGIN%\FIL (
    echo ERROR: The variable "LOGIN" [%LOGIN%] must match to an existing X3 folder !!
	exit /B %RET%
)
if defined LOGIN if defined EXCL_LOGIN (
	echo ERROR: The "LOGIN" [%LOGIN%] and "EXCL_LOGIN" [%EXCL_LOGIN%] variables must be set in exclusive mode !!
	exit /B %RET%
)
if defined EXCL_LOGIN set EXCL_LOGIN='%EXCL_LOGIN: =','%'
if defined EXCL_LOGIN call :Upper EXCL_LOGIN
echo %NBR_RET% | findstr /r "\<[1-9]\>">NUL
if errorlevel 1 (
	echo %NBR_RET% | findstr /r "\<[1-9][0-9]\>">NUL
	if errorlevel 1 (
		echo ERROR: Invalid number [%NBR_RET%] for the variable "NBR_RET" [must be range 1-99] !!
		exit /B %RET%
	)
)
echo %INTERVAL% | findstr /r "\<[1-9][0-9]\>">NUL
if errorlevel 1 (
	echo %INTERVAL% | findstr /r "\<[1-9][0-9][0-9]\>">NUL
	if errorlevel 1 (
		echo ERROR: Invalid number [%INTERVAL%] for the variable "INTERVAL" [must be range 10-999] !!
		exit /B %RET%
	)
)
echo %COUNT% | findstr /r "\<[1-9]\>">NUL
if errorlevel 1 (
	echo %COUNT% | findstr /r "\<[1-9][0-9]\>">NUL
	if errorlevel 1 (
		echo %COUNT% | findstr /r "\<[1-9][0-9][0-9]\>">NUL
		if errorlevel 1 (
			echo %COUNT% | findstr /r "\<[1-9][0-9][0-9][0-9]\>">NUL
			if errorlevel 1 (
				echo ERROR: Invalid number [%COUNT%] for the variable "COUNT" [must be range 1-9999] !!
				exit /B %RET%
			)
		)
	)
)
echo %LCK_TIME% | findstr /r "\<[1-9][0-9]\>">NUL
if errorlevel 1 (
	echo %LCK_TIME% | findstr /r "\<[1-9][0-9][0-9]\>">NUL
	if errorlevel 1 (
		echo ERROR: Invalid number [%LCK_TIME%] for the variable "LCK_TIME" [must be range 10-999] !!
		exit /B %RET%
	)
)
if not defined ADXDIR if exist %dirname%..\bin\env.bat (set ADXDIR=%dirname%..)
if not exist %ADXDIR%\bin\env.bat (
	echo ERROR: Invalid path for the variable "ADXDIR" [%ADXDIR%] !!
	exit /B %RET%
) else (
	call %ADXDIR%\bin\env.bat
)
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
if defined SCRIPTEXE if not (%SCRIPTEXE%)==(systeminfo) if not exist "%SCRIPTDIR%\%SCRIPTEXE%" if not exist "%SCRIPTEXE%" (
	echo ERROR: The script to execute [%SCRIPTEXE%] was not found !!
	exit /B %RET%
)
if defined CMD_DIFF if exist "%SCRIPTDIR%\%CMD_DIFF%"         cd /d %SCRIPTDIR%
if defined CMD_DIFF if exist "%SCRIPTDIR%\..\bin\%CMD_DIFF%"  cd /d %SCRIPTDIR%\..\bin
if defined CMD_DIFF if exist "%SCRIPTDIR%\bin\%CMD_DIFF%"     cd /d %SCRIPTDIR%\bin
set CMD_DIFF=%CD%\%CMD_DIFF%
cd /d %CURDIR%
if defined CMD_DIFF if not exist %CMD_DIFF% (
    echo WARNING: The command line tool "%CMD_DIFF%" was not found !!
	echo:
	set CMD_DIFF=
	set FLG_ALL=1
)
echo %FLG_PRF% | findstr /r "\<[0-1]\>">NUL
if errorlevel 1 (
	echo ERROR: Invalid flag [%FLG_PRF%] for the variable "FLG_PRF" [0-1] !!
	exit /B %RET%
)
echo %FLG_EVT% | findstr /r "\<[0-1]\>">NUL
if errorlevel 1 (
	echo ERROR: Invalid flag [%FLG_EVT%] for the variable "FLG_EVT" [0-1] !!
	exit /B %RET%
)
echo %FLG_TSK% | findstr /r "\<[0-1]\>">NUL
if errorlevel 1 (
	echo ERROR: Invalid flag [%FLG_TSK%] for the variable "FLG_TSK" [0-1] !!
	exit /B %RET%
)
echo %FLG_FRG% | findstr /r "\<[0-1]\>">NUL
if errorlevel 1 (
	echo ERROR: Invalid flag [%FLG_FRG%] for the variable "FLG_FRG" [0-1] !!
	exit /B %RET%
)
if exist %ADXDOS%\%DOSS_REF%\FIL\AFCTCUR.srf find "CREDATTIM" %ADXDOS%\%DOSS_REF%\FIL\AFCTCUR.srf >NUL
if errorlevel 1 (set CREDAT=CREDAT_0) else (set CREDAT=CREDATTIM_0)
echo %PAUSE% | findstr /r "\<[0-1]\>">NUL
if errorlevel 1 (
	echo ERROR: Invalid flag [%PAUSE%] for the variable "PAUSE" [0-1] !!
	exit /B %RET%
)
if defined LAN if not "%LAN%"=="FRA" if not "%LAN%"=="ENG" if not "%LAN%"=="ITA" if not "%LAN%"=="POR" if not "%LAN%"=="SPA" if not "%LAN%"=="GER" if not "%LAN%"=="ARB" if not "%LAN%"=="BRI" if not "%LAN%"=="CHI" if not "%LAN%"=="POL" if not "%LAN%"=="RUS" (
	echo ERROR: Invalid value [%LAN%] for the variable "LAN" [FRA, ENG, ITA, POR, SPA, GER, ARB, BRI, CHI, POL or RUS] !!
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
if not defined LOGIN for /f "tokens=1,2 delims=/:" %%i in ('time /t') do set IDENTIFIER=%ORACLE_SID%_%DAT%-%%i%%j
if defined LOGIN for /f "tokens=1,2 delims=/:" %%i in ('time /t') do set IDENTIFIER=%ORACLE_SID%_%DAT%-%%i%%j-%LOGIN%
set IDENTIFIER=%IDENTIFIER: =%
set file_sql=%SCRIPTDIR%\%progname%_%IDENTIFIER%.sql
set file_log=%LOGDIR%\%progname%_%IDENTIFIER%.log
set file_tmp=%LOGDIR%\%progname%_%IDENTIFIER%.tmp
set file_adx=%LOGDIR%\psadx_%IDENTIFIER%.log
set file_prf=%LOGDIR%\typeperf_%IDENTIFIER%.log
set file_tsk=%LOGDIR%\tasklist_%IDENTIFIER%.log
set file_adx_sql=%SCRIPTDIR%\%progname%_psadx.sql

:: Deletes the old temporary trace file if existing
if exist %file_tmp% del %file_tmp%>NUL

:: Displays the banner in the trace file
call :banner>NUL
goto:EOF
::#
::# End of Init_files
::#************************************************************#

:Start_check_oralock
::#************************************************************#
::# Start the loop SQL script for checking Oracle lock
::#

set NB=0
if defined LOGIN set OPTION=-b %LOGIN%
if "%FLG_TSK%"=="1" >>%file_tsk% echo Datetime;Process;PID;Username;Mem Usage;CPU Time
if "%VER_APP%"=="5" (set HKEY_REG=HKLM\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall) else (set HKEY_REG=HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall)

:loop
set /A NB=%NB%+1
if %NB% LEQ 2 (
	:: Generates the SQL script for listing the result of the psadx function (Only from Sage X3 product V11 and above)
	if "%FLG_PSADX%"=="1" call :Cre_info_psadx_ora_begin
	set FOLDER=
	if "%FLG_PSADX%"=="1" setlocal enabledelayedexpansion
	if "%FLG_PSADX%"=="1" if defined     LOGIN call :Cre_info_psadx_ora_body %LOGIN%
	if "%FLG_PSADX%"=="1" if not defined LOGIN for /F %%i in ('DIR /B %ADXDOS% ^| findstr /V "_ - ."') do if exist %ADXDOS%\%%i\REPORT if not "%%i" == "%DOSS_REF%" call :Cre_info_psadx_ora_body %%i
	if "%FLG_PSADX%"=="1" endlocal
	if "%FLG_PSADX%"=="1" call :Cre_info_psadx_ora_end

	:: Generates the SQL script for checking Oracle lock
	call :Cre_check_oralock

	:: Displays the content of the SQL script if asked
	call :Display_script LIST OF INSTRUCTIONS IN THE SQL SCRIPT [%file_sql%]
)
if "%NB%"=="1" if not defined SCRIPTEXE (
   echo:
   >>%file_log% echo ------------------------------------------------------------
   if "%format%"=="jj-mm-aa" (call :Display Chargement des informations systeme ...) else (call :Display Loading system information ...)
   systeminfo | find /V "KB" | find /V "]:" >>%file_log% 2>&1
   >>%file_log% echo ------------------------------------------------------------
   if "%format%"=="jj-mm-aa" (call :Display Liste infos sur l'utilisation du fichier d'échange ...) else (call :Display Listing info about paging file usage ...)
   >>%file_log% powershell -command "&{get-wmiobject -class "Win32_PageFileUsage" | Format-Table -auto Name,AllocatedBaseSize,CurrentUsage,PeakUsage,TempPageFile}"
   if not "%VER_SYS%" == "6.1" >>%file_log% echo ------------------------------------------------------------
   if not "%VER_SYS%" == "6.1" if "%format%"=="jj-mm-aa" (call :Display Liste infos sur les disques physiques ...) else (call :Display Listing info about physical disks ...)
   if not "%VER_SYS%" == "6.1" >>%file_log% powershell -command "&{Get-PhysicalDisk | Sort-Object -Property DeviceID | Format-Table -auto DeviceID,model,BusType,MediaType,size,HealthStatus}"
   >>%file_log% echo ------------------------------------------------------------
   if "%format%"=="jj-mm-aa" (call :Display Liste infos de chaque volume disque logique en local ...) else (call :Display Listing infos for each logical volume disk locally ...)
   >>%file_log% echo:
   setlocal enabledelayedexpansion
   for /F "tokens=2-16 delims=:\ " %%A in ('fsutil fsinfo drives') do (
      for %%d in (%%A %%B %%C %%D %%E %%F %%G %%H %%I %%J %%K %%L %%M %%N %%O) do (
         set VOL=&set TOT=&set FREE=&set UNIT=
         if "%format%"=="jj-mm-aa" for /F "tokens=2 delims=:" %%f in ('fsutil fsinfo volumeinfo %%d: ^| find "Nom du volume" ') do @(
            set VOL=%%f
            set VOL=!VOL: =!
         )
         if not "%format%"=="jj-mm-aa" for /F "tokens=2 delims=:" %%f in ('fsutil fsinfo volumeinfo %%d: ^| find "Volume Name" ') do @(
            set VOL=%%f
            set VOL=!VOL: =!
         )
		 if "%format%"=="jj-mm-aa" for /F "tokens=2 delims=()" %%f in ('fsutil volume diskfree %%d: ^| find "Nombre total d'octets libres" ') do set FREE=%%f
		 if "%format%"=="jj-mm-aa" for /F "tokens=2 delims=()" %%f in ('fsutil volume diskfree %%d: ^| find "Nombre total d'octets  " ') do set TOT=%%f
         if "%format%"=="jj-mm-aa" if "!FREE!"=="" for /F "tokens=2 delims=:"  %%f in ('fsutil volume diskfree %%d: ^| find "Nombre total d'octets libres" ') do set FREE=%%f
         if "%format%"=="jj-mm-aa" if "!TOT!"==""  for /F "tokens=2 delims=:"  %%f in ('fsutil volume diskfree %%d: ^| find "Nombre total d'octets  " ') do set TOT=%%f
         if "%format%"=="jj-mm-aa" if not "!FREE!"=="" set FREE=!FREE:Go= Go!
         if "%format%"=="jj-mm-aa" if not "!TOT!"==""  set TOT=!TOT:Go= Go!
         if "%format%"=="jj-mm-aa" for /F "tokens=2 delims=:" %%f in ('fsutil fsinfo ntfsinfo %%d: ^| find "Octets par cluster" ') do @(
            set UNIT=%%f
            set UNIT=!UNIT: =!
         )
         if not "%format%"=="jj-mm-aa" for /F "tokens=2 delims=()" %%f in ('fsutil volume diskfree %%d: ^| find "of free bytes" ') do set FREE=%%f
         if not "%format%"=="jj-mm-aa" for /F "tokens=2 delims=()" %%f in ('fsutil volume diskfree %%d: ^| find "of bytes" ') do set TOT=%%f
         if not "%format%"=="jj-mm-aa" if "!FREE!"=="" for /F "tokens=2 delims=:" %%f in ('fsutil volume diskfree %%d: ^| find "of free bytes" ') do set FREE=%%f
         if not "%format%"=="jj-mm-aa" if "!TOT!"==""  for /F "tokens=2 delims=:" %%f in ('fsutil volume diskfree %%d: ^| find "of bytes" ') do set TOT=%%f
         if not "%format%"=="jj-mm-aa" if not "!FREE!"=="" set FREE=!FREE:Gb= Gb!
         if not "%format%"=="jj-mm-aa" if not "!TOT!"==""  set TOT=!TOT:Gb= Gb!
         if not "%format%"=="jj-mm-aa" for /F "tokens=2 delims=:"  %%f in ('fsutil fsinfo ntfsinfo %%d: ^| find "Bytes Per Cluster" ') do @(
            set UNIT=%%f
            set UNIT=!UNIT: =!
         )
         if not "!TOT!"=="" if not "!VOL!"=="" >>%file_log% echo [!VOL!] 	%%d:\	Total: !TOT!  	Free: !FREE!  	Unit: !UNIT!
         if not "!TOT!"=="" if     "!VOL!"=="" >>%file_log% echo [Local Disk]	%%d:\	Total: !TOT!  	Free: !FREE!  	Unit: !UNIT!
       )
   )
   endlocal
   >>%file_log% echo ------------------------------------------------------------
   if "%format%"=="jj-mm-aa" (call :Display Liste chaque programme Safe X3 installe en local ...) else (call :Display Listing each installed Safe X3 program locally ...)
   >>%file_log% echo:
   setlocal enableDelayedExpansion
   set "key="&set "name="&set "ver="&set "dir="
   if exist %file_log%.tmp del %file_log%.tmp>NUL
   for %%h in (%computername%) do (
      for /f "delims=" %%A in ('reg query "\\%%h\%HKEY_REG%" /s 2^>nul') do (
         set "ln=%%A"
         if "!ln:~0,4!" equ "HKEY" (
         	if defined name if     defined LST_FINDPRG (echo !name! [!ver!] !dir! | findstr /I "%LST_FINDPRG%" >>%file_log%.tmp)
         	if defined name if not defined LST_FINDPRG (echo !name! [!ver!] !dir! >>%file_log%.tmp)
         	set "name="&set "ver="&set "dir="&set "key=%%A"
         ) else for /f "tokens=1,2*" %%A in ("!ln!") do (
            if "%%A" equ "DisplayName" set "name=%%C"
            if "%%A" equ "DisplayVersion" set "ver=%%C"
            rem if "%%A" equ "InstallSource" set "dir=%%C"
         )
      )
   )
   if defined name if     defined LST_FINDPRG (echo !name! [!ver!] !dir! | findstr /I "%LST_FINDPRG%" >>%file_log%.tmp)
   if defined name if not defined LST_FINDPRG (echo !name! [!ver!] !dir! >>%file_log%.tmp)
   if exist %file_log%.tmp (sort %file_log%.tmp >>%file_log% & del %file_log%.tmp)
   endlocal
   >>%file_log% echo ------------------------------------------------------------
   if "%format%"=="jj-mm-aa" (call :Display Liste des modes de gestion d'alimentation dans l'environnement actuel de l'utilisateur...) else (call :Display Listing all power schemes in the current user's environment ...)
   powercfg -l >>%file_log% 2>&1
   >>%file_log% echo ------------------------------------------------------------
   if "%FLG_EVT%"=="1" if "%format%"=="jj-mm-aa" (call :Display Chargement du journal d'evenement type serveur ...) else (call :Display Loading Event logs system type ...)
   if "%FLG_EVT%"=="1" >>%file_log% echo:
   if "%FLG_EVT%"=="1" wevtutil qe System /q:"*[System[(Level=2 or Level=3) and TimeCreated[timediff(@SystemTime) <= 2592000000]]]" /f:text /rd:true | findstr /V "N/A Opcode: Keyword:" >>%file_log% 2>&1
   if "%FLG_EVT%"=="1" >>%file_log% echo ------------------------------------------------------------
   if "%FLG_EVT%"=="1" if "%format%"=="jj-mm-aa" (call :Display Chargement du journal d'evenement type application ...) else (call :Display Loading Event logs application type ...)
   if "%FLG_EVT%"=="1" >>%file_log% echo:
   if "%FLG_EVT%"=="1" wevtutil qe Application /q:"*[System[(Level=2 or Level=3) and TimeCreated[timediff(@SystemTime) <= 2592000000]]]" /f:text /rd:true | findstr /V "N/A Opcode: Keyword:" >>%file_log% 2>&1
   if "%FLG_EVT%"=="1" >>%file_log% echo ------------------------------------------------------------
   if "%FLG_FRG%"=="1" echo Fragmentation analysis report for each volume disk...
   if "%FLG_FRG%"=="1" defrag /A /C >>%file_log% 2>&1
   if "%FLG_EVT%"=="1" >>%file_log% echo ------------------------------------------------------------
)
if "%NB%"=="1" if defined SCRIPTEXE (
	echo:
	>>%file_log% echo ------------------------------------------------------------
	setlocal enabledelayedexpansion
	if exist %SCRIPTEXE% call "%SCRIPTEXE%" >>%file_log% 2>&1
	if exist %SCRIPTDIR%\%SCRIPTEXE% call "%SCRIPTDIR%\%SCRIPTEXE%" >>%file_log% 2>&1
	endlocal
	>>%file_log% echo ------------------------------------------------------------
)
echo:
echo THIS MAY TAKE A WHILE, PLEASE WAIT...
if (%NB%) == (%COUNT%) (
	:: Generates the SQL script for listing the result of the psadx function (Only from Sage X3 product V11 and above)
	if "%FLG_PSADX%"=="1" setlocal enabledelayedexpansion
	if "%FLG_PSADX%"=="1" if defined     LOGIN call :Cre_info_psadx_ora_body %LOGIN%
	if "%FLG_PSADX%"=="1" if not defined LOGIN for /F %%i in ('DIR /B %ADXDOS% ^| findstr /V "_ - ."') do if exist %ADXDOS%\%%i\REPORT if not "%%i" == "%DOSS_REF%" call :Cre_info_psadx_ora_body %%i
	if "%FLG_PSADX%"=="1" endlocal
	if "%FLG_PSADX%"=="1" call :Cre_info_psadx_ora_end

	:: Generates the SQL script for checking Oracle lock
	call :Cre_check_oralock

	:: Displays the content of the SQL script if asked
	call :Display_script LIST OF INSTRUCTIONS IN THE SQL SCRIPT [%file_sql%]
)
>>%file_log% echo:
>>%file_log% echo STEP %NB%/%COUNT% %TIME:~,8%
>>%file_log% echo +-----------------+
if (%NB%)==(1)       >>%file_log% echo ^| ALL X3 sessions ^|
if (%NB%)==(%COUNT%) >>%file_log% echo ^| ALL X3 sessions ^|
if not (%NB%)==(1) if not (%NB%)==(%COUNT%) if (%FLG_ALL%)==(1) >>%file_log% echo ^| ALL X3 sessions ^|
if not (%NB%)==(1) if not (%NB%)==(%COUNT%) if exist %CMD_DIFF% if "%FLG_ALL%"=="0" >>%file_log% echo ^| NEW X3 sessions ^|
>>%file_log% echo +-----------------+
>>%file_log% echo:
if exist %file_adx% move /Y %file_adx% %file_adx%.old>NUL
if (%FLG_PSADX%)==(0) if exist     %ADXDOS%\%DOSS_REF%\FIL\AFCTCUR.srf >>%file_adx% %CMD_PSADX% -fgxit  %OPTION%
if (%FLG_PSADX%)==(0) if not exist %ADXDOS%\%DOSS_REF%\FIL\AFCTCUR.srf >>%file_adx% %CMD_PSADX% -fogxit %OPTION%
if (%FLG_PSADX%)==(0) if not (%NB%)==(1) if not (%NB%)==(%COUNT%) if exist %CMD_DIFF% if exist     %ADXDOS%\%DOSS_REF%\FIL\AFCTCUR.srf (>>%file_log% echo   Uid         Client                                                       Folder           Guser                App. Id.      Type             Process)
if (%FLG_PSADX%)==(0) if not (%NB%)==(1) if not (%NB%)==(%COUNT%) if exist %CMD_DIFF% if exist     %ADXDOS%\%DOSS_REF%\FIL\AFCTCUR.srf (>>%file_log% echo   ----------- ------------------------------------------------------------ ---------------- -------------------- ------------- ---------------- -------)
if (%FLG_PSADX%)==(0) if not (%NB%)==(1) if not (%NB%)==(%COUNT%) if exist %CMD_DIFF% if not exist %ADXDOS%\%DOSS_REF%\FIL\AFCTCUR.srf (>>%file_log% echo   Uid         Client                                                       Folder           Function          Guser                App. Id.      Type             Process)
if (%FLG_PSADX%)==(0) if not (%NB%)==(1) if not (%NB%)==(%COUNT%) if exist %CMD_DIFF% if not exist %ADXDOS%\%DOSS_REF%\FIL\AFCTCUR.srf (>>%file_log% echo   ----------- ------------------------------------------------------------ ---------------- ----------------- -------------------- ------------- ---------------- -------)
if exist %file_adx%.old if %NB% LSS %COUNT% if exist %CMD_DIFF% (%CMD_DIFF% %file_adx%.old %file_adx% >>%file_log%)
if not exist %file_adx%.old	if exist %file_adx% (type %file_adx% >>%file_log%)
if exist %file_adx%.old	if not defined CMD_DIFF (type %file_adx% >>%file_log%)
if exist %file_adx%.old	if (%NB%)==(%COUNT%) if defined CMD_DIFF (type %file_adx% >>%file_log%)
%CMD_SQL% %CON_SQL% @%file_sql% >NUL
if "%DISPLAY%"=="1" >>%file_log% echo %CMD_SQL% %CON_SQL% @%file_sql%
if not exist %file_tmp%.log  (
		call :Display -----
		call :Display ERROR: UNABLE TO CONNECT TO DATABASE [%CMD_SQL% %CON_SQL%] !!
		call :Display -----
		call :Display STATUS : KO
		set RET=1
		exit /B 1
) else (
	type %file_tmp%.log
)
for /f %%i in ('type %file_tmp%.log ^| find /c "**** BLOCKING LOCK DETECTED" ') do set NEW_LCK=%%i
for /f %%i in ('type %file_tmp%.log ^| find /c "NEW DEADLOCK DETECTED" ')       do set NEW_DLO=%%i
if exist %file_tmp%.log type %file_tmp%.log
if exist %file_tmp%.log type %file_tmp%.log >>%file_log%
:: Executes another shell script if defined
if defined SCRIPTEXE if not "%SCRIPTEXE%"=="systeminfo" (
	call :Display ------------------------------------------------------------
    call %SCRIPTEXE% >>%file_log%
    call :Display ------------------------------------------------------------
)
set /A DS=(%COUNT% - %NB%) * INTERVAL
set /A HH=%DS%/60/60
set /A MM=(%DS%/60)-60*%HH%
set /A SS=%DS%-60*(%DS%/60)
echo STEP %NB%/%COUNT% %TIME:~,8%
set /A SUM_LCK=%SUM_LCK%+%NEW_LCK%
set /A SUM_DLO=%SUM_DLO%+%NEW_DLO%
call :Display ------------------------------------------------------------
if not "%NEW_LCK%"=="0" (call :Display WARNING: %NEW_LCK% NEW BLOCKING LOCK RECORDED IN THE TRACE FILE !!)
if not "%NEW_DLO%"=="0" (call :Display WARNING: %NEW_DLO% NEW DEADLOCK RECORDED IN THE TRACE FILE !!)
if "%NEW_LCK%"=="0" if "%NEW_DLO%"=="0" (
	call :Display INFO: NO NEW BLOCKING LOCK AND DEADLOCK DETECTED.
) else (
	for /f "tokens=2 delims=***" %%i in ('type %file_tmp%.log ^| find "!! ****" ^| sort') do echo %%i
	for /f "tokens=2 delims=***" %%i in ('type %file_tmp%.log ^| find "!! ****" ^| sort') do echo %%i >>%file_log%
)
call :Display ------------------------------------------------------------

:: Calculates the number of distinct type sessions from Sage X3 V11 and above (BATCH, WEB PAGE, CLASSIC PAGE, WEB-SERVICES, ECLIPSE)
if "%FLG_PSADX%"=="1" for /f "tokens=2" %%i in ('type %file_tmp%.log ^| findstr /B "Total"') do set SUM_BAT=%%i
if "%FLG_PSADX%"=="1" for /f "tokens=3" %%i in ('type %file_tmp%.log ^| findstr /B "Total"') do set SUM_WPA=%%i
if "%FLG_PSADX%"=="1" for /f "tokens=4" %%i in ('type %file_tmp%.log ^| findstr /B "Total"') do set SUM_CPA=%%i
if "%FLG_PSADX%"=="1" for /f "tokens=5" %%i in ('type %file_tmp%.log ^| findstr /B "Total"') do set SUM_WEB=%%i
if "%FLG_PSADX%"=="1" for /f "tokens=6" %%i in ('type %file_tmp%.log ^| findstr /B "Total"') do set SUM_ECL=%%i
if "%FLG_PSADX%"=="1" for /f "tokens=7" %%i in ('type %file_tmp%.log ^| findstr /B "Total"') do set SUM_LOG=%%i
if "%FLG_PSADX%"=="1" for /f "tokens=8" %%i in ('type %file_tmp%.log ^| findstr /B "Total"') do set SUM_SES=%%i
if exist %file_tmp%.log del %file_tmp%.log>NUL

:: Calculates the number of distinct X3 sessions and logins
if "%FLG_PSADX%"=="0" if defined LOGIN     (for /f "skip=2 tokens=4" %%i in ('%CMD_PSADX% -g %OPTION%') do @echo %%i) | sort | find /v ")" >>%file_tmp%.log
if "%FLG_PSADX%"=="0" if not defined LOGIN (for /f "skip=2 tokens=3" %%i in ('%CMD_PSADX% -g') do @echo %%i) | sort | find /v ")" >>%file_tmp%.log
setlocal enabledelayedexpansion
set USR=
(
  if "%FLG_PSADX%"=="0" for /f "delims=" %%i in ('type %file_tmp%.log') do (
  set /A SUM_SES=!SUM_SES! + 1
  if "!USR!" neq "%%i" SET /A SUM_LOG=!SUM_LOG! + 1
  set "USR=%%i"
)
)
call :Display TOTAL SESSIONS : !SUM_SES!
call :Display TOTAL LOGINS   : !SUM_LOG!
endlocal
call :Display ------------------------------------------------------------

:: Calculates the number of distinct type sessions before Sage X3 V11 (PRIMARY, SECONDARY, BATCH, WEB-SERVICES, TERMINAL VT)
if "%FLG_PSADX%"=="0" if defined LOGIN     (for /f "skip=2 tokens=4" %%i in ('%CMD_PSADX% -t %OPTION%') do @echo %%i) | sort | find /v ")" >>%file_tmp%.log
if "%FLG_PSADX%"=="0" if not defined LOGIN (for /f "skip=2 tokens=3" %%i in ('%CMD_PSADX% -t') do @echo %%i) | sort | find /v ")" >>%file_tmp%.log
setlocal enabledelayedexpansion
(
if "%FLG_PSADX%"=="0" for /f "delims=" %%i in ('type %file_tmp%.log') do (
  if "%%i"=="1 "  set /A SUM_PRM=!SUM_PRM! + 1
  if "%%i"=="2 "  set /A SUM_SEC=!SUM_SEC! + 1
  if "%%i"=="3 "  set /A SUM_BAT=!SUM_BAT! + 1
  if "%%i"=="4 "  set /A SUM_WEB=!SUM_WEB! + 1
  if "%%i"=="5 "  set /A SUM_TVT=!SUM_TVT! + 1
  if "%%i"=="20 " set /A SUM_WEB=!SUM_WEB! + 1
  if "%%i"=="25 " set /A SUM_CPA=!SUM_CPA! + 1
  if "%%i"=="30 " set /A SUM_ECL=!SUM_ECL! + 1
  if "%%i"=="33 " set /A SUM_WPA=!SUM_WPA! + 1
  )
)
if !SUM_PRM! GTR 0 call :Display TOTAL PRIMARY        : !SUM_PRM!
if !SUM_SEC! GTR 0 call :Display TOTAL SECONDARY      : !SUM_SEC!
if !SUM_BAT! GTR 0 call :Display TOTAL BATCH          : !SUM_BAT!
if !SUM_WPA! GTR 0 call :Display TOTAL WEB PAGE       : !SUM_WPA!
if !SUM_CPA! GTR 0 call :Display TOTAL CLASSIC PAGE   : !SUM_CPA!
if !SUM_WEB! GTR 0 call :Display TOTAL WEB-SERVICES   : !SUM_WEB!
if !SUM_TVT! GTR 0 call :Display TOTAL TERMINAL VT    : !SUM_TVT!
if !SUM_ECL! GTR 0 call :Display TOTAL ECLIPSE        : !SUM_ECL!
set /A SUM_SES=!SUM_PRM! + !SUM_SEC! + !SUM_BAT! + !SUM_WPA! + !SUM_CPA! + !SUM_WEB! + !SUM_TVT!
if !SUM_SES! GTR 0 call :Display ------------------------------------------------------------
endlocal
call :Display TOTAL BLOCKING LOCKS : %SUM_LCK%
call :Display TOTAL DEADLOCKS      : %SUM_DLO%
call :Display ------------------------------------------------------------
echo See trace file '%file_log%' for more details...
echo:
if exist %file_tmp%.log del %file_tmp%.log>NUL
>>%file_log% echo ===============================================================================================================================================================================================================

:: Collects main Windows performance counters (optional)
if (%FLG_PRF%)==(1) call :Exec_typeperf

:: Lists currently running processes with associated information (optional)
if (%FLG_TSK%)==(1) call :Exec_tasklist

if not "%NB%"=="%COUNT%" (
	echo PLEASE, WAIT %INTERVAL% SECS FOR THE NEXT STEP [%HH%:%MM%:%SS% LEFT] OR PRESS ENTER TO CONTINUE OR [CTRL-C] TO STOP...
	call :Sleep %INTERVAL%
	goto :loop
)
:: Displays a summary of the total distinct number of blocking locks and deadlocks
if exist %SCRIPTDIR%\display_oralock.cmd call %SCRIPTDIR%\display_oralock.cmd %file_log%
call :Display End of report
if exist %file_adx%.old del %file_adx%.old>NUL
if exist %file_prf%.lst del %file_prf%.lst>NUL
if exist %file_tsk%.lst del %file_tsk%.lst>NUL
goto:EOF
::#
::# End of Start_check_oralock
::#************************************************************#

:Cre_check_oralock
::#************************************************************#
::# Generates the monitoring SQL script for checking Oracle lock
::#

 >%file_sql% echo Rem ---------------------------------------------------------------------------
>>%file_sql% echo Rem SQL script generated automatically in Oracle version [%VER_ORA%] by the program "%dirname%\%~nx0".
>>%file_sql% echo Rem %copyright% by %author% - All Rights Reserved.
>>%file_sql% echo Rem ---------------------------------------------------------------------------
>>%file_sql% echo Rem
>>%file_sql% echo set pages 0 lines 200 feed off head off trimspool on term off ver off
>>%file_sql% echo col FMT_USER new_value FMT3 NOPRINT
>>%file_sql% echo select 'a'^|^|to_char^(max^(length^(username^)^)^) FMT_USER from dba_users;
>>%file_sql% echo select 'a'^|^|to_char^(greatest^(max^(length^(u.username^)^),4^)^) FMT_USER from dba_users u
if not defined LOGIN  >>%file_sql% echo where u.username in ^(select replace^(username,'_REPORT',''^) from dba_users where username like '%%_REPORT'^)
if     defined LOGIN  >>%file_sql% echo where u.username = '%LOGIN%' -- Lists only for a login
if defined EXCL_LOGIN >>%file_sql% echo and   u.username not in ^(%EXCL_LOGIN%^) -- Excludes logins
>>%file_sql% echo /
>>%file_sql% echo alter session set nls_numeric_characters=', ';
>>%file_sql% echo alter session set nls_language=french;
>>%file_sql% echo alter session set nls_territory=france;
>>%file_sql% echo alter session set time_zone= 'GMT';
>>%file_sql% echo:
>>%file_sql% echo set term on pages 500 head on
>>%file_sql% echo:
>>%file_sql% echo spool %file_tmp%.log
>>%file_sql% echo:
if "%FLG_PSADX%"=="1" >>%file_sql% type %file_adx_sql%
>>%file_sql% echo PROMPT
>>%file_sql% echo PROMPT +--------------+
>>%file_sql% echo PROMPT ^| Memory usage ^|
>>%file_sql% echo PROMPT +--------------+
>>%file_sql% echo:
>>%file_sql% echo col aa for a20    head "Pool name"
>>%file_sql% echo col bb for 99G999 head "Size|(Mo)" just right
>>%file_sql% echo col nop noprint
>>%file_sql% echo:
>>%file_sql% echo select 1 nop, 'DB Buffer Cache' aa, sum^(bytes^)/1024/1024 bb from v$sgastat where pool is null and name = 'buffer_cache' group by name
>>%file_sql% echo union
>>%file_sql% echo select 1 nop, 'Shared Pool' aa, sum^(bytes^)/1024/1024 bb from v$sgastat where pool = 'shared pool' group by pool
>>%file_sql% echo union
>>%file_sql% echo select 1 nop, 'Large Pool' aa, sum^(bytes^)/1024/1024 bb from v$sgastat where pool = 'large pool' group by pool
>>%file_sql% echo union
>>%file_sql% echo select 1 nop, 'Java Pool' aa, sum^(bytes^)/1024/1024 bb from v$sgastat where pool = 'java pool' group by pool
>>%file_sql% echo union
>>%file_sql% echo select 1 nop, 'Redo Log Buffer' aa, sum^(bytes^)/1024/1024 bb from v$sgastat where pool is null and name = 'log_buffer' group by name
>>%file_sql% echo union
>>%file_sql% echo select 1 nop, 'Fixed SGA' aa, sum^(bytes^)/1024/1024 bb from v$sgastat where pool is null and name = 'fixed_sga' group by name
>>%file_sql% echo union
>>%file_sql% echo select 1 nop, 'Used UGA' aa, sum^(ss.value^)/1024/1024 bb from v$sesstat ss, v$statname sn where sn.statistic# = ss.statistic# and sn.name = 'session uga memory'
>>%file_sql% echo union
>>%file_sql% echo select 1 nop, 'Free SGA' aa, sum^(bytes/1024/1024^) bb from v$sgastat where name = 'free memory'
>>%file_sql% echo union
>>%file_sql% echo select 2 nop, '---------' aa, null bb from dual
>>%file_sql% echo union
>>%file_sql% echo select 3 nop, 'Allocated PGA' aa, sum^(pga_alloc_mem^)/1024/1024 bb from v$process
>>%file_sql% echo union
>>%file_sql% echo select 3 nop, 'Used PGA' aa, sum^(pga_used_mem^)/1024/1024 bb from v$process
>>%file_sql% echo union
>>%file_sql% echo select 4 nop, 'Free PGA' a, ^(max^(value^)-sum^(pga_alloc_mem^)^)/1024/1024 bb from v$pgastat, v$process where name = 'aggregate PGA target parameter'
>>%file_sql% echo union
>>%file_sql% echo select 5 nop, '--------------------' aa, null bb from dual
>>%file_sql% echo union
>>%file_sql% echo select 5 nop, '         TOTAL ^(SGA^)' aa, sum^(bytes^)/1024/1024 bb from v$sgastat where nvl^(pool, 'null'^) in ^('shared pool', 'large pool', 'java pool', 'null'^)
>>%file_sql% echo union
>>%file_sql% echo select 6 nop, '         TOTAL ^(PGA^)' aa, sum^(value^)/1024/1024 bb from v$pgastat where name = 'aggregate PGA target parameter'
>>%file_sql% echo union
>>%file_sql% echo select 7 nop, '         TOTAL ^(ORA^)' aa, sum^(value/1024/1024^) bb from v$parameter where name in ^('sga_target', 'pga_aggregate_target', 'memory_target'^)
>>%file_sql% echo union
>>%file_sql% echo select 8 nop, '           MAX ^(ORA^)' aa, sum^(value/1024/1024^) bb from v$parameter where name in ^('sga_max_size', 'pga_aggregate_target'^)
>>%file_sql% echo order by 1, 3 desc
>>%file_sql% echo /
>>%file_sql% echo col bb clear
>>%file_sql% echo:
>>%file_sql% echo PROMPT
>>%file_sql% echo PROMPT +-----------------+
>>%file_sql% echo PROMPT ^| Active sessions ^|
>>%file_sql% echo PROMPT +-----------------+
>>%file_sql% echo:
>>%file_sql% echo col aa for 99999        head "SID"
>>%file_sql% echo col bb for a6           head "PID" just right
>>%file_sql% echo col cc for 9999999      head "Serial#"
>>%file_sql% echo col dd for ^&FMT3        head "Username"
>>%file_sql% echo col ee for a9           head "Type"
>>%file_sql% echo col ff for a7           head "Program"
>>%file_sql% echo col gg for a20          head "OS User"
>>%file_sql% echo col hh for a25          head "Machine"
>>%file_sql% echo col ii for a11          head "Logon Time"
>>%file_sql% echo col jj for a8           head "LastExec"
>>%file_sql% echo col kk for 9G999G999    head "Consistent|Change"
>>%file_sql% echo col ll for 99G999G999   head "Physical|Reads"
>>%file_sql% echo col mm for 9999G999G999 head "Logical|Reads"
>>%file_sql% echo col nn for 999999       head "CPU|Usage|(s)"
>>%file_sql% echo col oo for 990D9        head "MEM|Usage|(Mo)"
>>%file_sql% echo:
>>%file_sql% echo select s.sid aa,
>>%file_sql% echo        lpad^(regexp_replace^(s.process, ':.*', ''^), 6, ' '^) bb,
>>%file_sql% echo        s.serial# cc,
>>%file_sql% echo        s.username dd,
>>%file_sql% echo        initcap^(lower^(replace^(s.server,'NONE','SHARED'^)^)^) ee,
>>%file_sql% echo        decode^(ltrim^(substr^(s.program,1,instr^(s.program,' '^)-1^)^),'',ltrim^(substr^(s.program,1,instr^(s.program,'.'^)-1^)^),ltrim^(substr^(s.program,1,instr^(s.program,' '^)-1^)^)^) ff,
>>%file_sql% echo        s.osuser gg,
>>%file_sql% echo        decode^(instr^(s.machine,'.'^),0,s.machine,substr^(s.machine,1,instr^(s.machine,'.'^)-1^)^) hh,
>>%file_sql% echo        to_char^(s.logon_time,'DD/MM HH24:MI'^) ii,
>>%file_sql% echo        lpad^(to_char^(trunc^(s.last_call_et/3600^)^),2,0^)^|^|':'^|^|
>>%file_sql% echo        lpad^(to_char^(trunc^(s.last_call_et/60^)-^(trunc^(s.last_call_et/3600^)*60^)^),2,0^)^|^|':'^|^|
>>%file_sql% echo        lpad^(to_char^(s.last_call_et-^(trunc^(s.last_call_et/60^)*60^)^),2,0^) jj,
>>%file_sql% echo        io.consistent_changes kk,
>>%file_sql% echo        io.physical_reads ll,
>>%file_sql% echo        io.block_gets + io.consistent_gets mm,
>>%file_sql% echo        se1.value/100 nn,
>>%file_sql% echo        se2.value/1024/1024 oo
>>%file_sql% echo from v$session s
>>%file_sql% echo join v$sess_io  io  on ^(io.sid = s.sid^)
>>%file_sql% echo join v$sesstat  se1 on ^(se1.sid = s.sid^)
>>%file_sql% echo join v$sesstat  se2 on ^(se2.sid = s.sid^)
>>%file_sql% echo join v$statname sn1 on ^(sn1.statistic# = se1.statistic#^)
>>%file_sql% echo join v$statname sn2 on ^(sn2.statistic# = se2.statistic#^)
>>%file_sql% echo where s.type = 'USER'
>>%file_sql% echo and   s.last_call_et ^< %INTERVAL%
>>%file_sql% echo and   s.username in ^(select replace^(username,'_REPORT',''^) from dba_users where username like '%%_REPORT'^)
if defined LOGIN      >>%file_sql% echo and   s.username = '%LOGIN%' -- Lists only for a login
if defined EXCL_LOGIN >>%file_sql% echo and   s.username not in ^(%EXCL_LOGIN%^) -- Excludes logins
>>%file_sql% echo and   s.audsid != SYS_CONTEXT^('USERENV', 'SESSIONID'^) -- Excludes owner processes
>>%file_sql% echo and   s.program = '%PROG%'
>>%file_sql% echo and   sn1.name = 'CPU used by this session'
>>%file_sql% echo and   sn2.name = 'session pga memory max'
>>%file_sql% echo order by s.last_call_et, s.sid
>>%file_sql% echo /
>>%file_sql% echo col bb clear
>>%file_sql% echo:
>>%file_sql% echo PROMPT
>>%file_sql% echo PROMPT +--------------------+
>>%file_sql% echo PROMPT ^| Session statistics ^|
>>%file_sql% echo PROMPT +--------------------+
>>%file_sql% echo:
>>%file_sql% echo col aa for ^&FMT3        head "Username"
>>%file_sql% echo col bb for 9999         head "Total"
>>%file_sql% echo col cc for 9999         head "Dedi-|cated"
>>%file_sql% echo col dd for 9999         head "Shared"
>>%file_sql% echo col ee for 90D9         head "MTS|Load|(%%)"
>>%file_sql% echo col ff for 9999         head "Active"
>>%file_sql% echo col gg for 9999         head "Blocked"
>>%file_sql% echo col hh for a17          head "First|Logon Time"
>>%file_sql% echo col ii for a17          head "Last|Logon Time"
>>%file_sql% echo col jj for 9G999G999    head "Max|Consistent|Change"
>>%file_sql% echo col kk for 99G999G999   head "Max|Physical|Reads"
>>%file_sql% echo col ll for 9999G999G999 head "Max|Logical|Reads"
>>%file_sql% echo col mm for 99999        head "Max|CPU|Usage|(s)"
>>%file_sql% echo col nn for 9G990D9      head "Max|MEM|Usage|(Mo)"
>>%file_sql% echo:
>>%file_sql% echo select s.username aa,
>>%file_sql% echo        count(s.server^) bb,
>>%file_sql% echo        sum(decode(s.server, 'DEDICATED', 1, 0^)^) cc,
>>%file_sql% echo        sum(decode(s.server, 'DEDICATED', 0, 1^)^) dd,
>>%file_sql% echo        (select decode(avg(ss.busy + ss.idle^), 0, 0, round((avg(ss.busy/(ss.busy + ss.idle^)^)^)*100, 2^)^) from v$shared_server ss^) ee,
>>%file_sql% echo        (select count(s1.server^) from v$session s1 where s1.type = 'USER' and s1.audsid != SYS_CONTEXT^('USERENV', 'SESSIONID'^) and s1.last_call_et ^<= %INTERVAL% and s1.username = s.username^) ff,
>>%file_sql% echo        sum(decode(s.blocking_session, '', 0, 1^)^) gg,
>>%file_sql% echo        to_char(min(s.logon_time^),'%FMT_DAT3%'^) hh,
>>%file_sql% echo        to_char(max(s.logon_time^),'%FMT_DAT3%'^) ii,
>>%file_sql% echo        max(io.consistent_changes^) jj,
>>%file_sql% echo        max(io.physical_reads^) kk,
>>%file_sql% echo        max(io.block_gets + io.consistent_gets^) ll,
>>%file_sql% echo        max(se1.value/100^) mm,
>>%file_sql% echo        max(se2.value/1024/1024^) nn
>>%file_sql% echo from v$session s
>>%file_sql% echo join v$sess_io  io  on (io.sid = s.sid^)
>>%file_sql% echo join v$sesstat  se1 on (se1.sid = s.sid^)
>>%file_sql% echo join v$sesstat  se2 on (se2.sid = s.sid^)
>>%file_sql% echo join v$statname sn1 on (sn1.statistic# = se1.statistic#^)
>>%file_sql% echo join v$statname sn2 on (sn2.statistic# = se2.statistic#^)
>>%file_sql% echo where s.type = 'USER'
>>%file_sql% echo and   s.username in ^(select replace^(username,'_REPORT',''^) from dba_users where username like '%%_REPORT'^)
if defined LOGIN      >>%file_sql% echo and   s.username = '%LOGIN%' -- Lists only for a login
if defined EXCL_LOGIN >>%file_sql% echo and   s.username not in ^(%EXCL_LOGIN%^) -- Excludes logins
>>%file_sql% echo and   s.audsid != SYS_CONTEXT^('USERENV', 'SESSIONID'^) -- Excludes owner processes
>>%file_sql% echo and   s.program = '%PROG%'
>>%file_sql% echo and   sn1.name = 'CPU used by this session'
>>%file_sql% echo and   sn2.name = 'session pga memory max'
>>%file_sql% echo group by s.username
>>%file_sql% echo /
>>%file_sql% echo:
::Lists info about sessions connected to the X3 folder (if LOGIN is defined)
if defined LOGIN (
	call :Info_x3folder %LOGIN%
) else (
	for /F %%i in ('DIR /B %ADXDOS% ^| findstr /V "_ - ."') do if exist %ADXDOS%\%%i\REPORT if not "%%i" == "%DOSS_REF%" call :Info_x3folder %%i
)
>>%file_sql% echo PROMPT
>>%file_sql% echo PROMPT +-------------------+
>>%file_sql% echo PROMPT ^| Blocking sessions ^|
>>%file_sql% echo PROMPT +-------------------+
>>%file_sql% echo:
>>%file_sql% echo col aa for 99999  head "SID"
>>%file_sql% echo col bb for a6     head "PID"          just right
>>%file_sql% echo col cc for 99999  head "Blocking|SID"
>>%file_sql% echo col dd for a8     head "Blocking|PID" just right
>>%file_sql% echo col ee for ^&FMT3  head "User"
>>%file_sql% echo col ff for a25    head "Type Lock"
>>%file_sql% echo col gg for a13    head "Lock|mode"
>>%file_sql% echo col hh for a13    head "Request|mode"
>>%file_sql% echo col ii for 99G999 head "Time|Elapsed|(s)"
>>%file_sql% echo col jj for a92    head "Diagnostic"
>>%file_sql% echo:
>>%file_sql% echo break on aa on bb on cc
>>%file_sql% echo:
>>%file_sql% echo with blocking_lock as ^(
>>%file_sql% echo   select s1.sid     blocking_sid,
>>%file_sql% echo          s1.process blocking_pid,
>>%file_sql% echo          s2.sid     blocked_sid,
>>%file_sql% echo          s2.process blocked_pid
>>%file_sql% echo   from v$lock l1
>>%file_sql% echo   inner join v$lock l2    on l2.id1 = l1.id1 and l2.id2 = l1.id2
>>%file_sql% echo   inner join v$session s1 on s1.sid = l1.sid
>>%file_sql% echo   inner join v$session s2 on l2.sid = s2.sid
>>%file_sql% echo   where l1.block   = 1
>>%file_sql% echo   and   l2.request ^> 0
>>%file_sql% echo ^)
>>%file_sql% echo select s.sid aa,
>>%file_sql% echo        lpad^(regexp_replace^(s.process, ':.*', ''^), 6, ' '^) bb,
>>%file_sql% echo        b.blocking_sid cc,
>>%file_sql% echo        lpad^(regexp_replace^(b.blocking_pid, ':.*', ''^), 6, ' '^) dd,
>>%file_sql% echo        s.username ee,
>>%file_sql% echo        l.type^|^|' ^('^|^|decode^(l.type,'TM','DML enqueue',
>>%file_sql% echo                                    'TX','Transaction enqueue',
>>%file_sql% echo                                    'UL','User supplied'^)^|^|'^)' ff,
>>%file_sql% echo        decode^(l.lmode, 0, '',
>>%file_sql% echo                        1, 'Null',
>>%file_sql% echo                        2, 'Row-S ^(SS^)',
>>%file_sql% echo                        3, 'Row-X ^(SX^)',
>>%file_sql% echo                        4, 'Share ^(S^)',
>>%file_sql% echo                        5, 'S/Row-X ^(SSX^)',
>>%file_sql% echo                        6, 'Exclusive ^(X^)'^) gg,
>>%file_sql% echo        decode^(l.request, 0, '',
>>%file_sql% echo                        1, 'Null',
>>%file_sql% echo                        2, 'Row-S ^(SS^)',
>>%file_sql% echo                        3, 'Row-X ^(SX^)',
>>%file_sql% echo                        4, 'Share ^(S^)',
>>%file_sql% echo                        5, 'S/Row-X ^(SSX^)',
>>%file_sql% echo                        6, 'Exclusive ^(X^)'^) hh,
>>%file_sql% echo        nvl^(l.ctime,0^) ii,
>>%file_sql% echo        case when b.blocking_sid is not null and l.request ^> '0' and l.ctime ^>=%LCK_TIME%
>>%file_sql% echo        then '**** BLOCKING LOCK DETECTED SINCE '^|^|to_char^(ctime^)^|^|' SECS ^('^|^|to_char^(b.blocking_sid^)^|^|':'^|^|regexp_replace^(b.blocking_pid, ':.*', ''^)^|^|'^)^>'^|^|
>>%file_sql% echo                                             '^('^|^|to_char^(b.blocked_sid^)^|^|':'^|^|regexp_replace^(b.blocked_pid, ':.*', ''^)^|^|'^) !! ****'
>>%file_sql% echo        else '' end jj
>>%file_sql% echo from v$session s
>>%file_sql% echo inner join v$lock l on l.sid = s.sid
>>%file_sql% echo left outer join blocking_lock b on b.blocked_sid = s.sid
>>%file_sql% echo where l.type in ^('TM', 'TX', 'UL'^)
>>%file_sql% echo and ^(l.request != 0 or 
>>%file_sql% echo     ^(l.request = 0 and lmode != 4 and ^(l.id1, l.id2^) in
>>%file_sql% echo          ^(select l2.id1, l2.id2 from v$lock l2 where l2.request != 0 and l2.id1 = l.id1 and l2.id2 = l.id2^)^)^)
>>%file_sql% echo order by l.ctime desc, l.request, s.sid
>>%file_sql% echo /
>>%file_sql% echo clear breaks
>>%file_sql% echo col bb clear
>>%file_sql% echo col dd clear
>>%file_sql% echo:
>>%file_sql% echo PROMPT
>>%file_sql% echo PROMPT +---------------+
>>%file_sql% echo PROMPT ^| Locks by user ^|
>>%file_sql% echo PROMPT +---------------+
>>%file_sql% echo:
>>%file_sql% echo col aa for 99999 head "SID"
>>%file_sql% echo col bb for a6    head "PID" just right
>>%file_sql% echo col cc for ^&FMT3 head "Username"
>>%file_sql% echo col dd for a13   head "Locked type"
>>%file_sql% echo col ee for a13   head "Locked mode"
>>%file_sql% echo col ff for a8    head "Status"
>>%file_sql% echo col gg for a30   head "Event name"
>>%file_sql% echo col hh for a13   head "SQL Id"
>>%file_sql% echo col ii for a%LEN_SQLT%  head "SQL Text" word_wrap
>>%file_sql% echo col jj for a%LEN_SQLT%  head ""
>>%file_sql% echo:
>>%file_sql% echo break on aa on bb on cc on dd on ee on ff on gg
>>%file_sql% echo:
>>%file_sql% echo select distinct s.sid aa,
>>%file_sql% echo        lpad^(regexp_replace^(s.process, ':.*', ''^), 6, ' '^) bb,
>>%file_sql% echo        o.oracle_username cc,
>>%file_sql% echo        lt.name^|^|' ^('^|^|l.type^|^|'^)' dd,
>>%file_sql% echo        decode^(o.locked_mode , 0, 'None',
>>%file_sql% echo                               1, 'Null',
>>%file_sql% echo                               2, 'Row-S ^(SS^)',
>>%file_sql% echo                               3, 'Row-X ^(SX^)',
>>%file_sql% echo                               4, 'Share ^(S^)',
>>%file_sql% echo                               5, 'S/Row-X ^(SSX^)',
>>%file_sql% echo                               6, 'Exclusive ^(X^)',
>>%file_sql% echo                               to_char^(o.locked_mode^)^) ee,
>>%file_sql% echo        decode^(s.blocking_session,'','Blocking', 'Blocked'^) ff,
>>%file_sql% echo        s.event gg,
>>%file_sql% echo        nvl^(s.sql_id, s.prev_sql_id^) hh,
>>%file_sql% echo        chr^(10^)^|^|nvl^(t1.sql_text, t2.sql_text^) ii,
>>%file_sql% echo        '----------------------------------------------------------------------------------------------------------------------------------' jj
>>%file_sql% echo from v$sqlarea t1,
>>%file_sql% echo      v$sqlarea t2,
>>%file_sql% echo      v$lock_type lt,
>>%file_sql% echo      v$session s,
>>%file_sql% echo      v$process p,
>>%file_sql% echo      v$lock l,
>>%file_sql% echo      v$locked_object o
>>%file_sql% echo where l.sid         = o.session_id
>>%file_sql% echo and   l.id1         = o.object_id
>>%file_sql% echo and   s.sid         = l.sid
>>%file_sql% echo and   lt.type       = l.type
>>%file_sql% echo and   p.addr        = s.paddr
>>%file_sql% echo and   t1.sql_id ^(+^) = s.sql_id
>>%file_sql% echo and   t2.sql_id ^(+^) = s.prev_sql_id
if defined LOGIN >>%file_sql% echo and   o.oracle_username = '%LOGIN%' -- Lists only for a login
if defined EXCL_LOGIN >>%file_sql% echo and   o.oracle_username not in ^(%EXCL_LOGIN%^) -- Excludes logins
>>%file_sql% echo order by 1, 6 desc
>>%file_sql% echo /
>>%file_sql% echo clear breaks
>>%file_sql% echo col bb clear
>>%file_sql% echo col ii clear
>>%file_sql% echo:
>>%file_sql% echo PROMPT
>>%file_sql% echo PROMPT +---------------------+
>>%file_sql% echo PROMPT ^| Locked transactions ^|
>>%file_sql% echo PROMPT +---------------------+
>>%file_sql% echo:
>>%file_sql% echo col aa for 99999   head "SID"
>>%file_sql% echo col bb for a6      head "PID" just right
>>%file_sql% echo col cc for a12     head "Blocking|SID:Serial#"
>>%file_sql% echo col dd for a8      head "Blocking|PID"
>>%file_sql% echo col ee for a15     head "OS User"
>>%file_sql% echo col ff for ^&FMT3   head "DB User"
>>%file_sql% echo col gg for a25     head "Machine"
>>%file_sql% echo col hh for a11     head "Logon Time|jj/mm hh:mm"
>>%file_sql% echo col ii for a5      head "Start Time|hh:mm"
>>%file_sql% echo col jj for 999G999 head "Nbr|Undo|Records"
>>%file_sql% echo col kk for a%LEN_SQLT%    head "SQL Text" word_wrap
>>%file_sql% echo col ll for a%LEN_SQLT%    head ""
>>%file_sql% echo:
>>%file_sql% echo select s.sid aa,
>>%file_sql% echo        lpad^(regexp_replace^(s.process, ':.*', ''^), 6, ' '^) bb,
>>%file_sql% echo        ^(select substr^(to_char^(s1.sid^)^|^|':'^|^|to_char^(s1.serial#^),1,12^) from v$session s1 where s1.sid = s.blocking_session^) cc,
>>%file_sql% echo        ^(select lpad^(regexp_replace^(s2.process, ':.*', ''^), 6, ' '^) from v$session s2 where s2.sid = s2.blocking_session^) dd,
>>%file_sql% echo        s.osuser ee,
>>%file_sql% echo        s.username ff,
>>%file_sql% echo        substr^(s.machine,1,instr^(s.machine,'.'^)-1^) gg,
>>%file_sql% echo        to_char^(s.logon_time,'%FMT_DAT2%'^) hh,
>>%file_sql% echo        to_char^(t.start_date,'HH24:MI'^) ii,
>>%file_sql% echo        t.used_urec jj,
>>%file_sql% echo        chr^(10^)^|^|decode^(q.sql_text, '', ltrim^(q.sql_text^), ltrim^(q.sql_text^)^) kk,
>>%file_sql% echo        '----------------------------------------------------------------------------------------------------------------------------------' ll
>>%file_sql% echo from v$session s
>>%file_sql% echo left  join v$sqlarea q     on q.sql_id   = s.sql_id
>>%file_sql% echo left  join v$process p     on p.addr     = s.paddr
>>%file_sql% echo right join v$transaction t on t.ses_addr = s.saddr
if defined LOGIN >>%file_sql% echo where   s.username = '%LOGIN%' -- Lists only for a login
if defined EXCL_LOGIN >>%file_sql% echo and   s.username not in ^(%EXCL_LOGIN%^) -- Excludes logins
>>%file_sql% echo order by s.sid
>>%file_sql% echo /
>>%file_sql% echo col bb clear
>>%file_sql% echo col kk clear
>>%file_sql% echo:
>>%file_sql% echo PROMPT
>>%file_sql% echo PROMPT +----------------+
>>%file_sql% echo PROMPT ^| Locked objects ^|
>>%file_sql% echo PROMPT +----------------+
>>%file_sql% echo:
>>%file_sql% echo col aa for 99999 head "SID"
>>%file_sql% echo col bb for a6    head "PID" just right
>>%file_sql% echo col cc for ^&FMT3 head "User"
>>%file_sql% echo col dd for a20   head "Table|Name"
>>%file_sql% echo col ee for a13   head "Locked|Mode"
>>%file_sql% echo col ff for a18   head "Locked|Rowid"
>>%file_sql% echo:
>>%file_sql% echo break on aa skip 1 on bb on cc on dd
>>%file_sql% echo:
>>%file_sql% echo select s.sid aa,
>>%file_sql% echo        lpad^(regexp_replace^(l.process, ':.*', ''^), 6, ' '^) bb,
>>%file_sql% echo        l.oracle_username cc,
>>%file_sql% echo        o.object_name dd,
>>%file_sql% echo        decode^(l.locked_mode , 0, 'None',
>>%file_sql% echo                               1, 'Null',
>>%file_sql% echo                               2, 'Row-S ^(SS^)',
>>%file_sql% echo                               3, 'Row-X ^(SX^)',
>>%file_sql% echo                               4, 'Share ^(S^)',
>>%file_sql% echo                               5, 'S/Row-X ^(SSX^)',
>>%file_sql% echo                               6, 'Exclusive ^(X^)',
>>%file_sql% echo                               to_char^(l.locked_mode^)^) ee,
>>%file_sql% echo        decode^(s.row_wait_file#, 0, '',
>>%file_sql% echo               s.row_wait_obj#, -1, '',
>>%file_sql% echo               dbms_rowid.rowid_create ^(1, s.row_wait_obj#, s.row_wait_file#, s.row_wait_block#, s.row_wait_row#^)^) ff
>>%file_sql% echo from dba_objects o,
>>%file_sql% echo      v$session s,
>>%file_sql% echo      v$locked_object l
>>%file_sql% echo where l.object_id = o.object_id
if defined LOGIN >>%file_sql% echo and   l.oracle_username = '%LOGIN%' -- Lists only for a login
if defined EXCL_LOGIN >>%file_sql% echo and   l.oracle_username not in ^(%EXCL_LOGIN%^) -- Excludes logins
>>%file_sql% echo and   s.sid       = l.session_id
>>%file_sql% echo order by 1
>>%file_sql% echo /
>>%file_sql% echo clear breaks
>>%file_sql% echo col bb clear
if /I (%DB_USER%)==(SYSTEM) >>%file_sql% echo:
if /I (%DB_USER%)==(SYSTEM) >>%file_sql% echo PROMPT
if /I (%DB_USER%)==(SYSTEM) >>%file_sql% echo PROMPT +-----------------------+
if /I (%DB_USER%)==(SYSTEM) if (%NB%)==(1)       >>%file_sql% echo PROMPT ^| ALL Waits for mutexes ^|
if /I (%DB_USER%)==(SYSTEM) if (%NB%)==(%COUNT%) >>%file_sql% echo PROMPT ^| ALL Waits for mutexes ^|
if /I (%DB_USER%)==(SYSTEM) if not (%NB%)==(1) if not (%NB%)==(%COUNT%) if (%FLG_ALL%)==(1) >>%file_sql% echo PROMPT ^| ALL Waits for mutexes ^|
if /I (%DB_USER%)==(SYSTEM) if not (%NB%)==(1) if not (%NB%)==(%COUNT%) if (%FLG_ALL%)==(0) >>%file_sql% echo PROMPT ^| NEW Waits for mutexes ^|
if /I (%DB_USER%)==(SYSTEM) >>%file_sql% echo PROMPT +-----------------------+
if /I (%DB_USER%)==(SYSTEM) >>%file_sql% echo:
if /I (%DB_USER%)==(SYSTEM) >>%file_sql% echo col aa for a%LEN_SQLT%        head "SQL Text" word_wrap
if /I (%DB_USER%)==(SYSTEM) >>%file_sql% echo col bb for 99999       head "SID"
if /I (%DB_USER%)==(SYSTEM) >>%file_sql% echo col cc for a6          head "PID" just right
if /I (%DB_USER%)==(SYSTEM) >>%file_sql% echo col dd for 99999       head "Blocking|SID"
if /I (%DB_USER%)==(SYSTEM) >>%file_sql% echo col ee for a8          head "Blocking|PID" just right
if /I (%DB_USER%)==(SYSTEM) >>%file_sql% echo col ff for a17         head "Datetime"
if /I (%DB_USER%)==(SYSTEM) >>%file_sql% echo col gg for 999G999G999 head "Sleeps"
if /I (%DB_USER%)==(SYSTEM) >>%file_sql% echo col hh for a15         head "Mutex type"
if /I (%DB_USER%)==(SYSTEM) >>%file_sql% echo col ii for a30         head "Location"
if /I (%DB_USER%)==(SYSTEM) >>%file_sql% echo col jj for a25         head "Object Name"
if /I (%DB_USER%)==(SYSTEM) >>%file_sql% echo col kk for 999G999G999 head "Executions"
if /I (%DB_USER%)==(SYSTEM) >>%file_sql% echo col ll for 999G999G999 head "Total|Locked"
if /I (%DB_USER%)==(SYSTEM) >>%file_sql% echo col mm for 999G999G999 head "Total|Pinned"
if /I (%DB_USER%)==(SYSTEM) >>%file_sql% echo:
if /I (%DB_USER%)==(SYSTEM) >>%file_sql% echo break on aa
if /I (%DB_USER%)==(SYSTEM) >>%file_sql% echo:
if /I (%DB_USER%)==(SYSTEM) >>%file_sql% echo select /*+ ORDERED USE_NL^(o^) */ 
if /I (%DB_USER%)==(SYSTEM) >>%file_sql% echo        lpad^('-',150,'-'^)^|^|chr^(10^)^|^|nvl^(decode^(o.owner, null, o.object_name, ''^), ''^) aa,
if /I (%DB_USER%)==(SYSTEM) >>%file_sql% echo        m.request_sid bb,
if /I (%DB_USER%)==(SYSTEM) >>%file_sql% echo        ^(select lpad^(regexp_replace^(r.process, ':.*', ''^), 6, ' '^) from v$session r where r.sid = m.request_sid^) cc,
if /I (%DB_USER%)==(SYSTEM) >>%file_sql% echo        case when m.blocking_sid = 0 then null else m.blocking_sid end dd,
if /I (%DB_USER%)==(SYSTEM) >>%file_sql% echo        ^(select lpad^(regexp_replace^(b.process, ':.*', ''^), 6, ' '^) from v$session b where b.sid = m.blocking_sid^) ee,
if /I (%DB_USER%)==(SYSTEM) >>%file_sql% echo        to_char^(m.sleep_timestamp, '%FMT_DAT3%'^) ff,
if /I (%DB_USER%)==(SYSTEM) >>%file_sql% echo        m.sleeps gg,
if /I (%DB_USER%)==(SYSTEM) >>%file_sql% echo        m.mutex_type hh,
if /I (%DB_USER%)==(SYSTEM) >>%file_sql% echo        --m.location ii,
if /I (%DB_USER%)==(SYSTEM) if     "%VER_ORA%"=="12.2" >>%file_sql% echo        nvl^(decode^(o.owner, null, '', o.owner^|^|'.'^|^|o.object_name^), ''^) jj
if /I (%DB_USER%)==(SYSTEM) if not "%VER_ORA%"=="12.2" >>%file_sql% echo        nvl^(decode^(o.owner, null, '', o.owner^|^|'.'^|^|o.object_name^), ''^) jj,
if /I (%DB_USER%)==(SYSTEM) >>%file_sql% echo        --o.executions kk,
if /I (%DB_USER%)==(SYSTEM) if not "%VER_ORA%"=="12.2" >>%file_sql% echo        o.tot_locked ll,
if /I (%DB_USER%)==(SYSTEM) if not "%VER_ORA%"=="12.2" >>%file_sql% echo        o.tot_pinned mm
if /I (%DB_USER%)==(SYSTEM) >>%file_sql% echo from ^(select distinct mutex_identifier,
if /I (%DB_USER%)==(SYSTEM) >>%file_sql% echo              sleep_timestamp,
if /I (%DB_USER%)==(SYSTEM) >>%file_sql% echo              mutex_type,
if /I (%DB_USER%)==(SYSTEM) >>%file_sql% echo              sleeps,
if /I (%DB_USER%)==(SYSTEM) >>%file_sql% echo              requesting_session request_sid,
if /I (%DB_USER%)==(SYSTEM) >>%file_sql% echo              blocking_session   blocking_sid,
if /I (%DB_USER%)==(SYSTEM) >>%file_sql% echo              location
if /I (%DB_USER%)==(SYSTEM) >>%file_sql% echo       from v$mutex_sleep_history^) m,
if /I (%DB_USER%)==(SYSTEM) >>%file_sql% echo       ^(select kglnahsh hash_value,
if /I (%DB_USER%)==(SYSTEM) >>%file_sql% echo               kglhdpar parent,
if /I (%DB_USER%)==(SYSTEM) >>%file_sql% echo               kglhdadr address,
if /I (%DB_USER%)==(SYSTEM) >>%file_sql% echo               kglnaown owner,
if /I (%DB_USER%)==(SYSTEM) >>%file_sql% echo               kglnaobj object_name,
if /I (%DB_USER%)==(SYSTEM) >>%file_sql% echo               kglhdnsp namespace,
if /I (%DB_USER%)==(SYSTEM) if     "%VER_ORA%"=="12.2" >>%file_sql% echo               kglhdexc executions
if /I (%DB_USER%)==(SYSTEM) if not "%VER_ORA%"=="12.2" >>%file_sql% echo               kglhdexc executions,
if /I (%DB_USER%)==(SYSTEM) if not "%VER_ORA%"=="12.2" >>%file_sql% echo               kglobt23 tot_locked,
if /I (%DB_USER%)==(SYSTEM) if not "%VER_ORA%"=="12.2" >>%file_sql% echo               kglobt24 tot_pinned
if /I (%DB_USER%)==(SYSTEM) >>%file_sql% echo        from x$kglob
if /I (%DB_USER%)==(SYSTEM) >>%file_sql% echo        where kglnaobj not like '%%dbms_stats%%'^) o
if /I (%DB_USER%)==(SYSTEM) if (%NB%)==(1)          >>%file_sql% echo where 1 = 1
if /I (%DB_USER%)==(SYSTEM) if (%NB%)==(%COUNT%)                        >>%file_sql% echo where sleep_timestamp ^> sysdate-%INTERVAL%*%COUNT%/86400
if /I (%DB_USER%)==(SYSTEM) if not (%NB%)==(1) if not (%NB%)==(%COUNT%) >>%file_sql% echo where sleep_timestamp ^> sysdate-%INTERVAL%/86400
if /I (%DB_USER%)==(SYSTEM) >>%file_sql% echo and    m.mutex_identifier = o.hash_value ^(+^)
if /I (%DB_USER%)==(SYSTEM) >>%file_sql% echo and   ^(o.address = o.parent or ^(o.parent is null^)^)
if /I (%DB_USER%)==(SYSTEM) >>%file_sql% echo and   ^(o.owner is null or o.owner in ^(select replace^(username,'_REPORT',''^) from dba_users where username like '%%_REPORT'^)^)
if /I (%DB_USER%)==(SYSTEM) >>%file_sql% echo order by 6, o.owner, o.object_name, m.request_sid, m.blocking_sid
if /I (%DB_USER%)==(SYSTEM) >>%file_sql% echo /
if /I (%DB_USER%)==(SYSTEM) >>%file_sql% echo clear breaks
if /I (%DB_USER%)==(SYSTEM) >>%file_sql% echo col aa clear
if /I (%DB_USER%)==(SYSTEM) >>%file_sql% echo col cc clear
if /I (%DB_USER%)==(SYSTEM) >>%file_sql% echo col ee clear
>>%file_sql% echo:
>>%file_sql% echo PROMPT
>>%file_sql% echo PROMPT +-----------------------------+
>>%file_sql% echo PROMPT ^| Current IO and CPU Workload ^|
>>%file_sql% echo PROMPT +-----------------------------+
>>%file_sql% echo:
>>%file_sql% echo col aa for a%LEN_SQLT%       head "SQL Text" word_wrap
>>%file_sql% echo col bb for 99999      head "SID  "
>>%file_sql% echo col cc for a6         head "PID" just right
>>%file_sql% echo col dd for a20        head "Target"
>>%file_sql% echo col ee for a17        head "Last operation"
>>%file_sql% echo col ff for 999G999    head "Duration|(>=10s)"
>>%file_sql% echo col gg for a12        head "Optimizer|Mode"
>>%file_sql% echo col hh for 99G999G999 head "Optimizer|Cost"
>>%file_sql% echo col ii for 99G999     head "CPU|Time|(s)"
>>%file_sql% echo col jj for 999G999    head "Elapsed|Time|(s)"
>>%file_sql% echo col kk for 99G999G999 head "Physical|Read|(Mb)"
>>%file_sql% echo col ll for 999G999    head "Physical|Write|(Mb)"
>>%file_sql% echo col t1 for a%LEN_SQLT%       head ""
>>%file_sql% echo col t2 for a%LEN_SQLT%       head ""
>>%file_sql% echo:
>>%file_sql% echo break on aa on t1 on gg on hh on ii on jj on kk on ll
>>%file_sql% echo:
>>%file_sql% echo select lpad^('-', %LEN_SQLT%, '-'^) t1,
>>%file_sql% echo        t.sql_text aa,
>>%file_sql% echo        lpad^('', %LEN_SQLT%, ''^) t2,
>>%file_sql% echo        o.sid bb,
>>%file_sql% echo        lpad^(regexp_replace^(s.process, ':.*', ''^), 6, ' '^) cc,
>>%file_sql% echo        o.target dd,
>>%file_sql% echo        to_char^(max^(o.start_time^),'%FMT_DAT3%'^) ee,
>>%file_sql% echo        max^(o.elapsed_seconds^) ff,
>>%file_sql% echo        t.optimizer_mode gg,
>>%file_sql% echo        t.optimizer_cost hh,
if "%VER_ORA%"=="10.1" >>%file_sql% echo        t.elapsed_time/1000000 jj
if "%VER_ORA%"=="10.2" >>%file_sql% echo        t.elapsed_time/1000000 jj
if not "%VER_ORA%"=="10.1" if not "%VER_ORA%"=="10.2" (
	>>%file_sql% echo        t.elapsed_time/1000000 jj,
	>>%file_sql% echo        t.physical_read_bytes/1024/1024 kk,
	>>%file_sql% echo        t.physical_write_bytes/1024/1024 ll
)
>>%file_sql% echo from v$sqlarea t, v$session s, v$session_longops o
>>%file_sql% echo where o.opname not like 'RMAN%%'
>>%file_sql% echo and   o.username in ^(select replace^(username,'_REPORT',''^) from dba_users where username like '%%_REPORT'^)
if defined LOGIN      >>%file_sql% echo and   o.username = '%LOGIN%' -- Lists only for a login
if defined EXCL_LOGIN >>%file_sql% echo and   o.username not in ^(%EXCL_LOGIN%^) -- Excludes logins
>>%file_sql% echo and   o.elapsed_seconds ^>= 10
>>%file_sql% echo and   s.sid        = o.sid
>>%file_sql% echo and   s.serial#    = o.serial#
>>%file_sql% echo and   t.address    = o.sql_address
>>%file_sql% echo and   t.hash_value = o.sql_hash_value
>>%file_sql% echo group by o.sid, s.process, o.username, t.optimizer_mode, t.optimizer_cost, o.target, t.cpu_time, t.elapsed_time,
if not "%VER_ORA%"=="10.1" if not "%VER_ORA%"=="10.2" (
	>>%file_sql% echo          t.physical_read_bytes, t.physical_write_bytes, t.sql_text
) else (
	>>%file_sql% echo          t.sql_text
)
>>%file_sql% echo order by 2, 4
>>%file_sql% echo /
>>%file_sql% echo clear breaks
>>%file_sql% echo col aa clear
>>%file_sql% echo col cc clear
>>%file_sql% echo col aa for 99999      head "SID  "
>>%file_sql% echo col bb for a6         head "PID" just right
>>%file_sql% echo col cc for a13        head "SQL Id."
>>%file_sql% echo col dd for a10        head "Plan Hash"
>>%file_sql% echo col ee for a20        head "Module Name"
>>%file_sql% echo col ff for a12        head "Schema|Name"
>>%file_sql% echo col gg for a11        head "Optim. Mode"
>>%file_sql% echo col hh for 999999     head "Optim. Cost"
>>%file_sql% echo col ii for 99G999G999 head "Executions"
>>%file_sql% echo col jj for 99G999G999 head "SQL App|Time|(ms)"
>>%file_sql% echo col kk for 990D99     head "SQL App|Time|(%%)"
>>%file_sql% echo col ll for 990D99     head "Tot App Time|(%%)"
>>%file_sql% echo col mm for a%LEN_SQLT%       head "SQL Text" word_wrap
>>%file_sql% echo:
>>%file_sql% echo break on aa on t1 on gg on hh on ii on jj on kk on ll
>>%file_sql% echo:
>>%file_sql% echo with sql_app_waits as
>>%file_sql% echo   ^(select rank^(^) over ^(order by s.application_wait_time desc^) ranking,
>>%file_sql% echo           s1.sid,
>>%file_sql% echo           lpad^(regexp_replace^(s1.process, ':.*', ''^), 6,' '^) process,
>>%file_sql% echo           s.sql_id,
>>%file_sql% echo           to_char^(s.plan_hash_value^) plan_hash_value,
>>%file_sql% echo           substr^(s.module,1,decode^(instr^(s.module,'.'^),0,decode^(instr^(s.module,' '^),0,40,instr(s.module,' '^)^)-1,instr^(s.module,'.'^)-1^)^) module,
>>%file_sql% echo           s.parsing_schema_name schema_name,
>>%file_sql% echo           s.optimizer_mode,
>>%file_sql% echo           s.optimizer_cost,
>>%file_sql% echo           s.application_wait_time/1000 app_time_ms,
>>%file_sql% echo           s.executions,
>>%file_sql% echo           s.elapsed_time,
>>%file_sql% echo           round^(s.application_wait_time * 100 / s.elapsed_time, 2^) app_time_pct,
>>%file_sql% echo           round^(s.application_wait_time * 100 / sum(s.application_wait_time^) over ^(^), 2^) pct_of_app_time,
>>%file_sql% echo           s.sql_text
>>%file_sql% echo    from v$sql s
>>%file_sql% echo    join v$session s1 on ^(s1.sql_id = s.sql_id^)
>>%file_sql% echo    where parsing_schema_name in ^(select replace^(username,'_REPORT',''^) from dba_users where username like '%%_REPORT'^)
if defined LOGIN      >>%file_sql% echo and   s.parsing_schema_name = '%LOGIN%' -- Lists only for a login
if defined EXCL_LOGIN >>%file_sql% echo and   s.parsing_schema_name not in ^(%EXCL_LOGIN%^) -- Excludes logins
>>%file_sql% echo    and   elapsed_time ^> 0
>>%file_sql% echo    and   s1.status    = 'ACTIVE'
>>%file_sql% echo    and   application_wait_time ^> 0
>>%file_sql% echo ^)
>>%file_sql% echo select sid aa,
>>%file_sql% echo        process bb,             
>>%file_sql% echo        sql_id cc,
>>%file_sql% echo        plan_hash_value dd,
>>%file_sql% echo        module ee,
>>%file_sql% echo        schema_name ff,
>>%file_sql% echo        optimizer_mode gg,
>>%file_sql% echo        optimizer_cost hh,
>>%file_sql% echo        executions ii,
>>%file_sql% echo        app_time_ms jj,
>>%file_sql% echo        app_time_pct kk,
>>%file_sql% echo        pct_of_app_time ll,
>>%file_sql% echo        sql_text mm
>>%file_sql% echo from sql_app_waits
>>%file_sql% echo where ranking ^<= %TOP_NSQL%
>>%file_sql% echo order by ranking
>>%file_sql% echo /
>>%file_sql% echo clear breaks
>>%file_sql% echo col bb clear
>>%file_sql% echo col mm clear
>>%file_sql% echo:
:: If the first or last interval of monitoring
if "%NB%"=="1" (
	:: Lists the lock history only if the Oracle diagnostic pack is activated during the first and last interval of monitoring
	call :Lock_history
	:: Displays top segment by lock wait
	call :Lock_wait
	:: Displays old deadlock occurred (only from Oracle 11g)
	if not "%VER_ORA%"=="10.1" if not "%VER_ORA%"=="10.2" call :Deadlock
)
if "%NB%"=="%COUNT%" (
	:: Lists the lock history only if the Oracle diagnostic pack is activated during the first and last interval of monitoring
	call :Lock_history
	:: Displays top segment by lock wait
	call :Lock_wait
	:: Displays new deadlock occurred (only from Oracle 11g)
	if not "%VER_ORA%"=="10.1" if not "%VER_ORA%"=="10.2" call :Deadlock
)
>>%file_sql% echo PROMPT
>>%file_sql% echo spool off
>>%file_sql% echo exit
goto:EOF
::#
::# End of Cre_check_oralock
::#************************************************************#

:Info_x3folder
::#************************************************************#
::# Lists info about sessions connected to the X3 folder (if LOGIN is defined)
::#
::# List of arguments passed to the function:
::#  %1 = Folder name
::#
set FOLDER=%1
echo %EXCL_LOGIN% | findstr /I /C:"\<%FOLDER%\>" 2>&1 >NUL
if not errorlevel 1 exit /B 2
if not "%VER_APP%"=="5" call :Info_x3folder_usage %FOLDER%
>>%file_sql% echo PROMPT
>>%file_sql% echo PROMPT +--------------------------------------+
if (%NB%)==(1)       >>%file_sql% echo PROMPT ^| ALL Locked symbols - Detail ^(%FOLDER%^)
if (%NB%)==(%COUNT%) >>%file_sql% echo PROMPT ^| ALL Locked symbols - Detail ^(%FOLDER%^)
if not (%NB%)==(1) if not (%NB%)==(%COUNT%) if (%FLG_ALL%)==(1) >>%file_sql% echo PROMPT ^| ALL Locked symbols - Detail ^(%FOLDER%^)
if not (%NB%)==(1) if not (%NB%)==(%COUNT%) if (%FLG_ALL%)==(0) >>%file_sql% echo PROMPT ^| NEW Locked symbols - Detail ^(%FOLDER%^)
>>%file_sql% echo PROMPT +--------------------------------------+
>>%file_sql% echo:
>>%file_sql% echo col aa for a50        head "Symbol"
>>%file_sql% echo col bb for a17        head "Date time"
>>%file_sql% echo col cc for 9999999999 head "App.id"
>>%file_sql% echo col dd for a12        head "Login"
>>%file_sql% echo col ee for a30        head "Name"
>>%file_sql% echo col ff for a7         head "Menu|Profile"
>>%file_sql% echo col gg for a7         head "Fct.|Profile"
>>%file_sql% echo col hh for a3         head "Max|PRM"
>>%file_sql% echo col ii for a3         head "Max|SEC"
>>%file_sql% echo:
if not "%VER_ORA%"=="12.1" if not "%VER_ORA%"=="12.2" (
	>>%file_sql% echo select l.LCKSYM_0  aa,
	>>%file_sql% echo        to_char^(l.LCKDAT_0, 'DD/MM/YY'^)^|^|' '^|^|substr^(to_char^(numtodsinterval^(l.LCKTIM_0, 'SECOND'^)^), 12, 8^) bb,
	>>%file_sql% echo        l.LCKPID_0 cc,
	>>%file_sql% echo        u.LOGIN_0  dd,
	>>%file_sql% echo        u.NOMUSR_0 ee,
	>>%file_sql% echo        u.PRFMEN_0 ff,
	>>%file_sql% echo        u.PRFFCT_0 gg,
	>>%file_sql% echo        decode^(p1.VALEUR_0, 0, '', p1.VALEUR_0^) hh,
	>>%file_sql% echo        decode^(p2.VALEUR_0, 0, '', p2.VALEUR_0^) ii
	>>%file_sql% echo from %FOLDER%.APLLCK l
	>>%file_sql% echo left join %DOSS_REF%.AUSRSOL s        on s.USR_0     = substr^(l.LCKSYM_0, instr^(l.LCKSYM_0, ' '^)+1^)
	>>%file_sql% echo left join %FOLDER%.AUTILIS u    on u.USR_0     = s.USR_0
	>>%file_sql% echo left join %FOLDER%.ADOVALAUS p1 on p1.CODUSR_0 = u.USR_0 and p1.param_0 = 'MAXSES1'
	>>%file_sql% echo left join %FOLDER%.ADOVALAUS p2 on p2.CODUSR_0 = u.USR_0 and p2.param_0 = 'MAXSES2'
if not "%NB%"=="1" if not "%NB%"=="%COUNT%" if not "%FLG_ALL%"=="1" >>%file_sql% echo where to_date^(to_char^(l.LCKDAT_0, 'DD/MM/YY'^)^|^|' '^|^|substr^(to_char^(numtodsinterval^(l.LCKTIM_0, 'SECOND'^)^), 12, 8^), 'DD/MM/YY HH24:MI:SS'^) ^> sysdate-2/3600
if not "%NB%"=="1" if not "%NB%"=="%COUNT%" if     "%FLG_ALL%"=="1" >>%file_sql% echo where l.LCKDAT_0 ^> sysdate-1
if "%NB%"=="1"       >>%file_sql% echo where l.LCKDAT_0 ^> sysdate-1
if "%NB%"=="%COUNT%" >>%file_sql% echo where l.LCKDAT_0 ^> sysdate-1
	>>%file_sql% echo order by l.LCKDAT_0, l.LCKTIM_0;
) else (
	>>%file_sql% echo select l.LCKSYM_0  aa,
	>>%file_sql% echo        to_char^(l.LCKDAT_0, 'DD/MM/YY'^)^|^|' '^|^|substr^(to_char^(numtodsinterval^(l.LCKTIM_0, 'SECOND'^)^), 12, 8^) bb,
	>>%file_sql% echo        l.LCKPID_0 cc
	>>%file_sql% echo from %FOLDER%.APLLCK l
if not "%NB%"=="1" if not "%NB%"=="%COUNT%" if "%FLG_ALL%"=="0" >>%file_sql% echo where to_date^(to_char^(l.LCKDAT_0, 'DD/MM/YY'^)^|^|' '^|^|substr^(to_char^(numtodsinterval^(l.LCKTIM_0, 'SECOND'^)^), 12, 8^), 'DD/MM/YY HH24:MI:SS'^) ^> sysdate-2/3600
if "%NB%"=="1"       >>%file_sql% echo where l.LCKDAT_0 ^> sysdate-1
if "%NB%"=="%COUNT%" >>%file_sql% echo where l.LCKDAT_0 ^> sysdate-1
	>>%file_sql% echo order by l.LCKDAT_0, l.LCKTIM_0;
)
>>%file_sql% echo:
goto:EOF
::#
::# End of Info_x3folder
::#************************************************************#

:Info_x3folder_usage
::#************************************************************#
::# Lists info about sessions connected to the X3 folder 
::#
::# ATTENTION: Not compatible for Sage X3 V5 products with Oracle 10g.
::#
::# List of arguments passed to the function:
::#  %1 = Folder name
::#
set FOLDER=%1
>>%file_sql% echo PROMPT
>>%file_sql% echo PROMPT +----------------------------+
if (%NB%)==(1)       >>%file_sql% echo PROMPT ^| ALL Module usage ^(%FOLDER%^)
if (%NB%)==(%COUNT%) >>%file_sql% echo PROMPT ^| ALL Module usage ^(%FOLDER%^)
if not (%NB%)==(1) if not (%NB%)==(%COUNT%) >>%file_sql% echo PROMPT ^| NEW Module usage ^(%FOLDER%^)
>>%file_sql% echo PROMPT +----------------------------+
>>%file_sql% echo:
>>%file_sql% echo col aa for a20 head "Module"
>>%file_sql% echo col bb for a30 head "Name"
>>%file_sql% echo col cc for 999 head "Count"
>>%file_sql% echo col dd for a45 head "Login (Name)"
>>%file_sql% echo col ee for a9  head "Last time"
>>%file_sql% echo:
>>%file_sql% echo select c.FCT_0 aa,
>>%file_sql% echo        nvl^(t.TEXTE_0,' '^) bb,
>>%file_sql% echo        count^(c.UID_0^) cc,
>>%file_sql% echo        case count^(c.UID_0^) when 1 then min^(c.LOGIN_0^)^|^|' ^('^|^|min^(u.NOMUSR_0^)^|^|'^)'
>>%file_sql% echo                            when 2 then min^(c.LOGIN_0^)^|^|', '^|^|max^(c.LOGIN_0^)
>>%file_sql% echo        			            else min^(c.LOGIN_0^)^|^|', '^|^|max^(c.LOGIN_0^)^|^|', ...' end dd,
if not "%VER_ORA%"=="12.1" if not "%VER_ORA%"=="12.2" >>%file_sql% echo        to_char^(trunc^(max^(c.CRETIM_0^)/3600^),'09'^)^|^|to_char^(to_date^(mod^(max^(c.CRETIM_0^),86400^),'SSSSS'^),':MI:SS'^) ee
if "%VER_ORA%"=="12.1"  >>%file_sql% echo        to_char^(max^(c.UPDDATTIM_0^)+2/24, 'HH24:MI:SS'^) ee
if "%VER_ORA%"=="12.2"  >>%file_sql% echo        to_char^(max^(c.UPDDATTIM_0^)+2/24, 'HH24:MI:SS'^) ee
>>%file_sql% echo from %DOSS_REF%.AFCTCUR c
>>%file_sql% echo left outer join %FOLDER%.AFONCTION f on f.CODINT_0 = c.FCT_0
>>%file_sql% echo left outer join %FOLDER%.ATEXTE t    on t.NUMERO_0 = f.NOM_0 and t.LAN_0 = '%LAN%'
>>%file_sql% echo inner join %FOLDER%.AUTILIS u        on u.USR_0 = c.USR_0
if not "%VER_ORA%"=="12.1" if not "%VER_ORA%"=="12.2" (
	>>%file_sql% echo where c.%CREDAT% ^> sysdate-1
) else (
	>>%file_sql% echo where c.UPDDATTIM_0 ^> sysdate-1
)
if not (%NB%)==(1) if not (%NB%)==(%COUNT%) if not "%VER_ORA%"=="12.1" if not "%VER_ORA%"=="12.2" >>%file_sql% echo and c.CRETIM_0 ^>= to_number^(to_char^(sysdate,'HH24'^)^)*60*60+^(to_number^(to_char^(sysdate,'MI'^)^)*60^)+to_number^(to_char^(sysdate,'SS'^)^)-%INTERVAL%
if not (%NB%)==(1) if not (%NB%)==(%COUNT%) if "%VER_ORA%"=="12.1" >>%file_sql% echo and c.UPDDATTIM_0 ^> current_timestamp-%INTERVAL%/86400
if not (%NB%)==(1) if not (%NB%)==(%COUNT%) if "%VER_ORA%"=="12.2" >>%file_sql% echo and c.UPDDATTIM_0 ^> current_timestamp-%INTERVAL%/86400
>>%file_sql% echo and not ^(c.FCT_0 = ' ' and C.MODULE_0 = '1'^)
>>%file_sql% echo group by c.FCT_0, t.TEXTE_0
if (%FLG_ALL%)==(0) if not (%NB%)==(1) if not (%NB%)==(%COUNT%) >>%file_sql% echo order by 5 desc, 1
if (%NB%)==(1)       >>%file_sql% echo order by 3 desc, 1
if (%NB%)==(%COUNT%) >>%file_sql% echo order by 3 desc, 1
>>%file_sql% echo /
>>%file_sql% echo:
>>%file_sql% echo PROMPT
>>%file_sql% echo PROMPT +----------------------------+
if (%NB%)==(1)       >>%file_sql% echo PROMPT ^| ALL Login usage ^(%FOLDER%^)
if (%NB%)==(%COUNT%) >>%file_sql% echo PROMPT ^| ALL Login usage ^(%FOLDER%^)
if not (%NB%)==(1) if not (%NB%)==(%COUNT%) >>%file_sql% echo PROMPT ^| NEW Login usage ^(%FOLDER%^)
>>%file_sql% echo PROMPT +----------------------------+
>>%file_sql% echo:
>>%file_sql% echo col aa for a12 head "Login"
>>%file_sql% echo col bb for a30 head "Name"
>>%file_sql% echo col cc for 999 head "Count"
>>%file_sql% echo col dd for a45 head "Module (Name)"
>>%file_sql% echo col ee for a9  head "Last time"
>>%file_sql% echo:
>>%file_sql% echo select c.LOGIN_0 aa,
>>%file_sql% echo        u.NOMUSR_0 bb,
>>%file_sql% echo        count^(c.UID_0^) cc,
>>%file_sql% echo        case count^(distinct c.FCT_0^) when 1 then case when min^(c.FCT_0^) = ' ' then ' ' else min^(c.FCT_0^)^|^|' ^('^|^|min^(nvl^(t.TEXTE_0,' '^)^)^|^|'^)' end
>>%file_sql% echo                                     when 2 then case when min^(c.FCT_0^) = ' ' then max^(c.FCT_0^)^|^|' ^('^|^|max^(nvl^(t.TEXTE_0,' '^)^)^|^|'^)' else min^(c.FCT_0^)^|^|', '^|^|max^(c.FCT_0^) end
>>%file_sql% echo        			                    else case when min^(c.FCT_0^) = ' ' then max^(c.FCT_0^)^|^|', ...' else min^(c.FCT_0^)^|^|', '^|^|max^(c.FCT_0^)^|^|', ...' end end dd,
if not "%VER_ORA%"=="12.1" if not "%VER_ORA%"=="12.2" >>%file_sql% echo        to_char^(trunc^(max^(c.CRETIM_0^)/3600^),'09'^)^|^|to_char^(to_date^(mod^(max^(c.CRETIM_0^),86400^),'SSSSS'^),':MI:SS'^) ee
if "%VER_ORA%"=="12.1" >>%file_sql% echo        to_char^(max^(c.upddattim_0^)+2/24, 'HH24:MI:SS'^) ee
if "%VER_ORA%"=="12.2" >>%file_sql% echo        to_char^(max^(c.upddattim_0^)+2/24, 'HH24:MI:SS'^) ee
>>%file_sql% echo from %DOSS_REF%.AFCTCUR c
>>%file_sql% echo left outer join %FOLDER%.AFONCTION f on f.CODINT_0 = c.FCT_0
>>%file_sql% echo left outer join %FOLDER%.ATEXTE t    on t.NUMERO_0 = f.NOM_0 and t.LAN_0 = '%LAN%'
>>%file_sql% echo inner join %FOLDER%.AUTILIS u        on u.USR_0 = c.USR_0
if not "%VER_ORA%"=="12.1" if not "%VER_ORA%"=="12.2" (
	>>%file_sql% echo where c.%CREDAT% ^> sysdate-1
) else (
	>>%file_sql% echo where c.UPDDATTIM_0 ^> sysdate-1
)
if not (%NB%)==(1) if not (%NB%)==(%COUNT%) if not "%VER_ORA%"=="12.1" if not "%VER_ORA%"=="12.2" >>%file_sql% echo and c.CRETIM_0 ^>= to_number^(to_char^(sysdate,'HH24'^)^)*60*60+^(to_number^(to_char^(sysdate,'MI'^)^)*60^)+to_number^(to_char^(sysdate,'SS'^)^)-%INTERVAL%
if not (%NB%)==(1) if not (%NB%)==(%COUNT%) if "%VER_ORA%"=="12.1" >>%file_sql% echo and c.UPDDATTIM_0 ^> current_timestamp-%INTERVAL%/86400
if not (%NB%)==(1) if not (%NB%)==(%COUNT%) if "%VER_ORA%"=="12.2" >>%file_sql% echo and c.UPDDATTIM_0 ^> current_timestamp-%INTERVAL%/86400
>>%file_sql% echo and not ^(c.FCT_0 = ' ' and C.MODULE_0 = '1'^)
>>%file_sql% echo group by c.LOGIN_0, u.NOMUSR_0
if (%FLG_ALL%)==(0) if not (%NB%)==(1) if not (%NB%)==(%COUNT%) >>%file_sql% echo order by 5 desc, 1
if (%NB%)==(1)       >>%file_sql% echo order by 3 desc, 1
if (%NB%)==(%COUNT%) >>%file_sql% echo order by 3 desc, 1
>>%file_sql% echo /
>>%file_sql% echo:
goto:EOF
::#
::# End of Info_x3folder_usage
::#************************************************************#

:Exec_typeperf
::#************************************************************#
::# Executes the typeperf command to collect main performance counters
::#
if (%NB%)==(1) if "%format%"=="jj-mm-aa" (call :List_typeperf_fra) else (call :List_typeperf_eng)
::if (%NB%)==(1) (typeperf -cf %file_prf%.lst -si 1 -sc 1 | find "\\" | find """" >%file_prf%)
if (%NB%)==(1) for /f "tokens=*" %%c in ('typeperf -cf %file_prf%.lst -si 1 -sc 1 ^| find "\\" ^| find """"') do @set TYPEPERF=%%c
if (%NB%)==(1) set TYPEPERF=%TYPEPERF:"=%
if (%NB%)==(1) >%file_prf% echo %TYPEPERF%
set TYPEPERF=
for /f "tokens=*" %%c in ('typeperf -cf %file_prf%.lst -si 1 -sc 1 ^| find /V "\\" ^| find """"') do @set TYPEPERF=%%c
set TYPEPERF=%TYPEPERF:"=%
>>%file_prf% echo %TYPEPERF%
goto:EOF
::#
::# End of Exec_typeperf
::#************************************************************#

:List_typeperf_eng
::#************************************************************#
::# Creates a file list of main Windows and SQL Server performance counters
::#
 >%file_prf%.lst echo \Process(Idle)\%% Processor Time
>>%file_prf%.lst echo \Process(_Total)\%% Processor Time
>>%file_prf%.lst echo \Memory\Pages/sec
>>%file_prf%.lst echo \Memory\Page Reads/sec
>>%file_prf%.lst echo \Memory\Page Writes/sec
>>%file_prf%.lst echo \System\Processor Queue Length
>>%file_prf%.lst echo \PhysicalDisk(*)\%% Disk Time
>>%file_prf%.lst echo \PhysicalDisk(*)\Avg. Disk sec/Read 
>>%file_prf%.lst echo \PhysicalDisk(*)\Avg. Disk sec/Write
>>%file_prf%.lst echo \PhysicalDisk(*)\Current Disk Queue Length
>>%file_prf%.lst echo \PhysicalDisk(*)\Disk Transfers/sec
>>%file_prf%.lst echo \PhysicalDisk(*)\Disk Reads/sec
>>%file_prf%.lst echo \PhysicalDisk(*)\Disk Writes/sec
>>%file_prf%.lst echo \Network Interface(*)\Bytes Total/sec
>>%file_prf%.lst echo \Network Interface(*)\Output Queue Length
>>%file_prf%.lst echo \Paging File\%%Usage
>>%file_prf%.lst echo \Memory\Available Mbytes
>>%file_prf%.lst echo \PhysicalDisk\Avg. Disk Queue Length
>>%file_prf%.lst echo \PhysicalDisk/%%idle time
goto:EOF
::#
::# End of List_typeperf_eng
::#************************************************************#

:List_typeperf_fra
::#************************************************************#
::# Creates a file list of main Windows and SQL Server performance counters in french language
::#
 >%file_prf%.lst echo \Processus(Idle)\%% temps processeur
>>%file_prf%.lst echo \Processus(_Total)\%% temps processeur
>>%file_prf%.lst echo \Mémoire\Pages/s
>>%file_prf%.lst echo \Mémoire\Lectures de pages/s
>>%file_prf%.lst echo \Mémoire\Écritures de pages/s
>>%file_prf%.lst echo \Système\Longueur de la file du processeur
>>%file_prf%.lst echo \Disque physique(*)\Pourcentage du temps disque
>>%file_prf%.lst echo \Disque physique(*)\Moyenne disque s/lecture
>>%file_prf%.lst echo \Disque physique(*)\Moyenne disque s/écriture
>>%file_prf%.lst echo \Disque physique(*)\Taille de file d'attente du disque actuelle
>>%file_prf%.lst echo \Disque physique(*)\Transferts disque/s
>>%file_prf%.lst echo \Disque physique(*)\Lectures disque/s
>>%file_prf%.lst echo \Disque physique(*)\Écritures disque/s
>>%file_prf%.lst echo \Interface réseau(*)\Total des octets/s
>>%file_prf%.lst echo \Interface réseau(*)\Longueur de la file d'attente de sortie
>>%file_prf%.lst echo \Fichier d'échange(*)\Pourcentage d'utilisation
>>%file_prf%.lst echo \Mémoire\Mégaoctets disponibles
>>%file_prf%.lst echo \Disque physique(*)\Longueur moyenne de file d'attente du disque
>>%file_prf%.lst echo \Disque physique(*)\%% d'inactivité
goto:EOF
::#
::# End of List_typeperf_fra
::#************************************************************#

:Lock_history
::#************************************************************#
::# Lists the lock history only if the Oracle diagnostic pack is activated
::#
>>%file_sql% echo set head off
>>%file_sql% echo select '+--------------+'^|^|chr^(10^)^|^|'^| Lock history ^|'^|^|chr^(10^)^|^|'+--------------+'
>>%file_sql% echo from v$parameter p
>>%file_sql% echo where p.name = 'control_management_pack_access'
>>%file_sql% echo and p.value like '%%%ORA_PACK%%%';
>>%file_sql% echo set head on
>>%file_sql% echo:
>>%file_sql% echo col aa for ^&FMT3       head "User"
>>%file_sql% echo col bb for a10       head "Process"
if not "%VER_ORA%"=="10.1" if not "%VER_ORA%"=="10.2" >>%file_sql% echo col cc for a15       head "Machine"
>>%file_sql% echo col dd for a30       head "Lock|Event"
>>%file_sql% echo col ee for a15       head "Object|Name"
>>%file_sql% echo col ff for 9G999G999 head "Waits"
>>%file_sql% echo col gg for 9G999G999 head "Wait|(s)"
>>%file_sql% echo col hh for 999       head "Wait|(%%)"
>>%file_sql% echo col ii for 990D9     head "PGA|Allocated|(Mo)"
>>%file_sql% echo col jj for 9G990D9   head "TEMP|Space used|(Mo)"
>>%file_sql% echo col kk for a%LEN_SQLT%      head "SQL Text" word_wrap
>>%file_sql% echo col ll for a%LEN_SQLT%      head ""
>>%file_sql% echo:
>>%file_sql% echo with ash_query as ^(
>>%file_sql% echo  select username,
>>%file_sql% echo         decode^(instr^(h.module,'@'^),0,h.module,substr^(h.module,1,instr^(h.module,'@'^)-1^)^) process,
if not "%VER_ORA%"=="10.1" if not "%VER_ORA%"=="10.2" >>%file_sql% echo         h.machine,
>>%file_sql% echo         h.program,
>>%file_sql% echo         h.event lock_event,
>>%file_sql% echo         o.object_name,
>>%file_sql% echo         count^(username^) waits,
>>%file_sql% echo         sum^(time_waited^)/1000 time_ms,
>>%file_sql% echo         rank^(^) over ^(order by sum^(time_waited^) desc^) time_rank,
>>%file_sql% echo         round^(sum^(time_waited^) * 100 / sum^(sum^(time_waited^)^) over ^(^), 2^) pct_of_time,
if not "%VER_ORA%"=="10.1" if not "%VER_ORA%"=="10.2" (
	>>%file_sql% echo         max^(h.pga_allocated/1024/1024^) pga_in_mb,
	>>%file_sql% echo         max^(h.temp_space_allocated/1024/1024^) tmp_in_mb,
)
>>%file_sql% echo         sql_text
>>%file_sql% echo  from  v$parameter p, v$active_session_history h
>>%file_sql% echo  join dba_users u using ^(user_id^)
>>%file_sql% echo  left outer join dba_objects o on ^(o.object_id = h.current_obj#^)
>>%file_sql% echo  left outer join v$sqlarea s using ^(sql_id^)
>>%file_sql% echo  where event like 'enq: %%'
>>%file_sql% echo  and   p.name = 'control_management_pack_access'
>>%file_sql% echo  and   p.value like '%%%ORA_PACK%%%'
>>%file_sql% echo  and   h.module not in ^('DBMS_SCHEDULER', 'SQL*Plus'^)
>>%file_sql% echo  and   u.username in ^(select replace^(username,'_REPORT',''^) from dba_users where username like '%%_REPORT'^)
if defined LOGIN      >>%file_sql% echo and   u.username = '%LOGIN%' -- Lists only for a login
if defined EXCL_LOGIN >>%file_sql% echo and   u.username not in ^(%EXCL_LOGIN%^) -- Excludes logins
>>%file_sql% echo  having sum^(time_waited^)/1000 ^>0
if not "%VER_ORA%"=="10.1" if not "%VER_ORA%"=="10.2" >>%file_sql% echo  group by username, h.module, h.machine, h.program, h.event, object_name, sql_text
if "%VER_ORA%"=="10.1" >>%file_sql% echo  group by username, h.module, h.program, h.event, object_name, sql_text
if "%VER_ORA%"=="10.2" >>%file_sql% echo  group by username, h.module, h.program, h.event, object_name, sql_text
>>%file_sql% echo ^)
>>%file_sql% echo select username aa,
>>%file_sql% echo        process bb,
if not "%VER_ORA%"=="10.1" if not "%VER_ORA%"=="10.2" >>%file_sql% echo        machine cc,
>>%file_sql% echo        lock_event dd,
>>%file_sql% echo        object_name ee,
>>%file_sql% echo        waits ff,
>>%file_sql% echo        time_ms gg,
>>%file_sql% echo        pct_of_time hh,
if not "%VER_ORA%"=="10.1" if not "%VER_ORA%"=="10.2" (
	>>%file_sql% echo        pga_in_mb ii,
	>>%file_sql% echo        tmp_in_mb jj,
)
>>%file_sql% echo        sql_text kk,
>>%file_sql% echo        lpad^('-', %LEN_SQLT%, '-'^) ll
>>%file_sql% echo from ash_query
>>%file_sql% echo where time_rank ^<= %TOP_NSQL%
>>%file_sql% echo order by time_rank
>>%file_sql% echo /
goto:EOF
::#
::# End of Lock_history
::#************************************************************#

:Lock_wait
::#************************************************************#
::# Displays top segment by lock wait for following Oracle events:
::# - row lock waits
::# - ITL waits
::#
>>%file_sql% echo:
>>%file_sql% echo PROMPT
>>%file_sql% echo PROMPT +--------------------------+
>>%file_sql% echo PROMPT ^| Top segment by lock wait ^|
>>%file_sql% echo PROMPT +--------------------------+
>>%file_sql% echo:
>>%file_sql% echo col aa for a30   head "Statistic name"
>>%file_sql% echo col bb for ^&FMT3   head "User"
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
>>%file_sql% echo             from ^(select ss.obj#,
>>%file_sql% echo                          ss.statistic_name,
>>%file_sql% echo                          max^(ss.value^) value
>>%file_sql% echo                   from v$segstat ss
>>%file_sql% echo                   where ss.statistic_name in ^('row lock waits', 'ITL waits'^)
>>%file_sql% echo                   and   ss.value ^> 0
>>%file_sql% echo                   group by ss.obj#, ss.statistic_name^) s
>>%file_sql% echo             join dba_objects o on ^(o.object_id = s.obj#^)
>>%file_sql% echo             where o.owner in ^(select replace^(username,'_REPORT',''^) from dba_users where username like '%%_REPORT'^)
if defined LOGIN      >>%file_sql% echo and   o.owner = '%LOGIN%' -- Lists only for a login
if defined EXCL_LOGIN >>%file_sql% echo and   o.owner not in ^(%EXCL_LOGIN%^) -- Excludes logins
>>%file_sql% echo            ^)
>>%file_sql% echo       where row_number ^<= %TOP_NSQL%^)
>>%file_sql% echo order by 1, 5 desc
>>%file_sql% echo /
>>%file_sql% echo clear breaks computes
goto:EOF
::#
::# End of Lock_wait
::#************************************************************#

:Deadlock
::#************************************************************#
::# Displays old or new deadlock occurred before or after the monitoring
::#
>>%file_sql% echo:
>>%file_sql% echo PROMPT
>>%file_sql% echo PROMPT +----------+
>>%file_sql% echo PROMPT ^| Deadlock ^|
>>%file_sql% echo PROMPT +----------+
>>%file_sql% echo PROMPT
>>%file_sql% echo:
>>%file_sql% echo set pages 0
>>%file_sql% echo select '**** ^('^|^|to_char(originating_timestamp, '%FMT_DAT3%')^|^|
if (%NB%)==(1)       >>%file_sql% echo        '^) OLD DEADLOCK DETECTED, more info in file '^|^|
if (%NB%)==(%COUNT%) >>%file_sql% echo        '^) NEW DEADLOCK DETECTED, more info in file '^|^|
>>%file_sql% echo        regexp_replace^(regexp_replace^(message_text,'.* file ',''^),'trc.','trc !! ****'^) msg
>>%file_sql% echo from v$diag_alert_ext
>>%file_sql% echo where component_id like 'rdbms%%'
>>%file_sql% echo and message_text like 'ORA-00060%%'
if (%NB%)==(%COUNT%) >>%file_sql% echo and originating_timestamp ^> sysdate-%INTERVAL%*%COUNT%/86400
>>%file_sql% echo /
>>%file_sql% echo set pages 500
goto:EOF
::#
::# End of Deadlock
::#************************************************************#

:Cre_info_psadx_ora_begin
::#************************************************************#
::# Generates begin of the SQL script for listing the result of the psadx function from Oracle (Only from Sage X3 product V11 and above)
::#
 >%file_adx_sql% echo:
>>%file_adx_sql% echo col aa for ^&FMT3   head "Folder"
>>%file_adx_sql% echo col bb for a17     head "Datetime"
>>%file_adx_sql% echo col cc for a15     head "Login"
>>%file_adx_sql% echo col dd for a15     head "Function"
>>%file_adx_sql% echo col ee for a21     head "Module"
>>%file_adx_sql% echo col ff for a12     head "Type"
>>%file_adx_sql% echo col gg for a14     head "Logon time" trunc
>>%file_adx_sql% echo col hh for 9999999 head "App.Id"
>>%file_adx_sql% echo col ii for 99999   head "DB.Id"
>>%file_adx_sql% echo col jj for a30     head "Processes"
>>%file_adx_sql% echo col nop NOPRINT
>>%file_adx_sql% echo:
>>%file_adx_sql% echo break on aa on bb on cc on dd on ee on ff on gg on hh on ii on jj on kk
>>%file_adx_sql% echo:
goto:EOF
::#
::# End of Cre_info_psadx_ora_begin
::#************************************************************#

:Cre_info_psadx_ora_body
::#************************************************************#
::# Generates body of the SQL script for listing the result of the psadx function from Oracle (Only from Sage X3 product V11 and above)
::#
::# List of arguments passed to the function:
::#  %1 = Folder name
::#
if not "!FOLDER!"=="" >>%file_adx_sql% echo union
set FOLDER=%1
>>%file_adx_sql% echo select i.fold_0 aa,
>>%file_adx_sql% echo        s.last_call_et nop,
>>%file_adx_sql% echo        p.processname_0 nop,
>>%file_adx_sql% echo        to_char^(s.prev_exec_start, '%FMT_DAT3%'^) bb,
>>%file_adx_sql% echo        i.alogin_0 cc,
>>%file_adx_sql% echo        f.fct_0 dd,
>>%file_adx_sql% echo        case when f.fct_0 = 'R_ACHGENVX3' then 'Syracuse' else nvl^(m.lanmes_0,'') end ee,
>>%file_adx_sql% echo        case when i.sessiontype_0 = 33 then 'Web page'
>>%file_adx_sql% echo             when i.sessiontype_0 = 25 then 'Classic page'
>>%file_adx_sql% echo             when i.sessiontype_0 = 14
>>%file_adx_sql% echo               or i.sessiontype_0 = 30 then 'Eclipse'
>>%file_adx_sql% echo             when i.sessiontype_0 = 35 then 'Batch'
>>%file_adx_sql% echo             when i.sessiontype_0 = 20 then 'Web services'
>>%file_adx_sql% echo             else to_char^(i.sessiontype_0^) end ff,
>>%file_adx_sql% echo        to_char^(s.logon_time, '%FMT_DAT3%'^) gg,
>>%file_adx_sql% echo        i.sessionid_0 hh,
>>%file_adx_sql% echo        to_number^(d.dbident1_0^) ii,
>>%file_adx_sql% echo        to_char^(p.processid_0^)^|^|':'^|^|to_char^(p.processname_0^)^|^|'^('^|^|
>>%file_adx_sql% echo        decode^(instr^(p.server_0,'.'^),0,p.server_0,substr^(p.server_0,1,instr^(p.server_0,'.'^)-1^)^)^|^|'^)' jj
>>%file_adx_sql% echo from %DOSS_REF%.asyssmdbasso d
>>%file_adx_sql% echo join %DOSS_REF%.asyssmintern i on i.sessionid_0 = d.sessionid_0
>>%file_adx_sql% echo join %DOSS_REF%.asyssmproces p on p.sessionid_0 = d.sessionid_0
>>%file_adx_sql% echo left outer join %DOSS_REF%.afctcur f on f.uid_0 = i.sessionid_0
>>%file_adx_sql% echo left outer join %DOSS_REF%.aplstd m  on m.lannum_0 = f.module_0 and m.lan_0 = '%LAN%' and m.lanchp_0 = 14
>>%file_adx_sql% echo join v$session s on s.sid = to_number^(d.dbident1_0^) and s.audsid = to_number^(d.dbident2_0^)
if defined LOGIN >>%file_adx_sql% echo where i.fold_0 = '%FOLDER%'  -- Lists only for a login
if defined EXCL_LOGIN >>%file_adx_sql% echo where i.fold_0 not in ^(%EXCL_LOGIN%^) -- Excludes logins
if defined LOGIN if not (%NB%)==(1) if not (%NB%)==(%COUNT%) if (%FLG_ALL%)==(0) >>%file_adx_sql% echo and   s.last_call_et ^<=%INTERVAL%
if defined EXCL_LOGIN if not (%NB%)==(1) if not (%NB%)==(%COUNT%) if (%FLG_ALL%)==(0) >>%file_adx_sql% echo and   s.last_call_et ^<=%INTERVAL%
if not defined LOGIN if not defined EXCL_LOGIN if not (%NB%)==(1) if not (%NB%)==(%COUNT%) if (%FLG_ALL%)==(0) >>%file_adx_sql% echo where s.last_call_et ^<=%INTERVAL%
goto:EOF
::#
::# End of Cre_info_psadx_ora_body
::#************************************************************#

:Cre_info_psadx_ora_end
::#************************************************************#
::# Generates end of the SQL script for listing the result of the psadx function from Oracle (Only from Sage X3 product V11 and above)
::#
>>%file_adx_sql% echo order by 1, 2, 3
>>%file_adx_sql% echo /
>>%file_adx_sql% echo clear breaks
>>%file_adx_sql% echo:
>>%file_adx_sql% echo col aa for ^&FMT3 head "Folder"
>>%file_adx_sql% echo col bb for 999 head "       Batch"
>>%file_adx_sql% echo col cc for 999 head "    Web Page"
>>%file_adx_sql% echo col dd for 999 head "Classic Page"
>>%file_adx_sql% echo col ee for 999 head "Web Services"
>>%file_adx_sql% echo col ff for 999 head "     Eclipse"
>>%file_adx_sql% echo col gg for 999 head "       Login"
>>%file_adx_sql% echo col hh for 999 head "     Session"
>>%file_adx_sql% echo col ii for 999 head "      Active"
>>%file_adx_sql% echo:
>>%file_adx_sql% echo with COUNT_LOGIN_PER_FOLDER as ^(
>>%file_adx_sql% echo select l.FOLD_0,
>>%file_adx_sql% echo        count^(distinct l.ALOGIN_0^) NBR_LOGIN
>>%file_adx_sql% echo from X3.ASYSSMDBASSO d
>>%file_adx_sql% echo join X3.ASYSSMINTERN l on l.SESSIONID_0 = d.SESSIONID_0
>>%file_adx_sql% echo join v$session s on s.sid = to_number^(d.dbident1_0^) and s.audsid = to_number^(d.dbident2_0^)
>>%file_adx_sql% echo group by l.FOLD_0
>>%file_adx_sql% echo ^)
>>%file_adx_sql% echo select i.FOLD_0 aa,
>>%file_adx_sql% echo        sum^(case when i.SESSIONTYPE_0 = 35                         then 1 else 0 end^) bb,
>>%file_adx_sql% echo        sum^(case when i.SESSIONTYPE_0 = 33                         then 1 else 0 end^) cc,
>>%file_adx_sql% echo        sum^(case when i.SESSIONTYPE_0 = 25                         then 1 else 0 end^) dd,
>>%file_adx_sql% echo        sum^(case when i.SESSIONTYPE_0 = 20                         then 1 else 0 end^) ee,
>>%file_adx_sql% echo        sum^(case when i.SESSIONTYPE_0 = 14 or i.SESSIONTYPE_0 = 30 then 1 else 0 end^) ff,
>>%file_adx_sql% echo        max^(l.NBR_LOGIN^) gg,
>>%file_adx_sql% echo        sum^(1^) hh,
>>%file_adx_sql% echo        sum^(case when s.last_call_et ^<= %INTERVAL% then 1 else 0 end^) ii
>>%file_adx_sql% echo from %DOSS_REF%.ASYSSMDBASSO d
>>%file_adx_sql% echo join %DOSS_REF%.ASYSSMINTERN i on i.SESSIONID_0 = d.SESSIONID_0
>>%file_adx_sql% echo join v$session s on s.sid = to_number^(d.dbident1_0^) and s.audsid = to_number^(d.dbident2_0^)
>>%file_adx_sql% echo join COUNT_LOGIN_PER_FOLDER l on l.FOLD_0 = i.FOLD_0
if defined LOGIN >>%file_adx_sql% echo and   i.FOLD_0 = '%LOGIN%'  -- Lists only for a login
>>%file_adx_sql% echo group by i.FOLD_0
>>%file_adx_sql% echo union all
>>%file_adx_sql% echo select 'Total',
>>%file_adx_sql% echo        sum^(case when i.SESSIONTYPE_0 = 35                         then 1 else 0 end^),
>>%file_adx_sql% echo        sum^(case when i.SESSIONTYPE_0 = 33                         then 1 else 0 end^),
>>%file_adx_sql% echo        sum^(case when i.SESSIONTYPE_0 = 25                         then 1 else 0 end^),
>>%file_adx_sql% echo        sum^(case when i.SESSIONTYPE_0 = 20                         then 1 else 0 end^),
>>%file_adx_sql% echo        sum^(case when i.SESSIONTYPE_0 = 14 or i.SESSIONTYPE_0 = 30 then 1 else 0 end^),
>>%file_adx_sql% echo        max^(l.NBR_LOGIN^),
>>%file_adx_sql% echo        sum^(1^),
>>%file_adx_sql% echo        sum^(case when s.last_call_et ^<= %INTERVAL% then 1 else 0 end^)
>>%file_adx_sql% echo from %DOSS_REF%.ASYSSMDBASSO d
>>%file_adx_sql% echo join %DOSS_REF%.ASYSSMINTERN i on i.SESSIONID_0 = d.SESSIONID_0
>>%file_adx_sql% echo join v$session s on s.sid = to_number^(d.dbident1_0^) and s.audsid = to_number^(d.dbident2_0^)
>>%file_adx_sql% echo join COUNT_LOGIN_PER_FOLDER l on l.FOLD_0 = i.FOLD_0
>>%file_adx_sql% echo where i.SESSIONTYPE_0 ^> 0
if defined LOGIN >>%file_adx_sql% echo and   i.FOLD_0 = '%LOGIN%'  -- Lists only for a login
>>%file_adx_sql% echo /
goto:EOF
::#
::# End of Cre_info_psadx_ora_end
::#************************************************************#

:Exec_tasklist
::#************************************************************#
::# Executes the tasklist command to list currently running processes with associated information:
::#    Datetime, Process, PID, Username, Mem Usage and CPU Time
::#
for /f delims^=^".^ tokens^=1^,2^,4^,10^,14^,16 %%i in ('tasklist /V /FO CSV ^| findstr "%TASK%" ^| sort') do @echo %TIME:~,8%;%%i.%%j;%%k;%%m;%%l;%%n >>%file_tsk%
goto:EOF
::#
::# End of Exec_tasklist
::#************************************************************#

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
if (%WAIT%)==(1) if "%VER_SYS%"=="5.2" (ping -n %SECS% localhost >NUL) else (timeout /t %SECS% >NUL)
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

:Info_sysdate
::#************************************************************#
::# Retrieves the system date in the "yymmdd" format
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
	echo ERROR: Unable to retrieves the system format date !!
	goto End
)
goto:EOF
::#
::# End of Info_sysdate
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
::# Banner displayed at the beginning of the script execution
::#
call :Display #------------------------------------------------------------------------------
call :Display #  %progname%%extname% - version %version% for %dbversion%.
call :Display #  Monitors current lock during a period in the Oracle database [%ORACLE_SID%].
call :Display #  %copyright% by %author% - All Rights Reserved.
call :Display #------------------------------------------------------------------------------
goto:EOF
::#
::# End of Banner
::#************************************************************#

:Usage
::#************************************************************#
::# Usage for the execution of the command
::#
echo Usage: %progname%%extname% [/VPETF] [ ^<INTERVAL^> ] [ ^<COUNT^> ] [ ^<LOGIN^> ]
echo:
echo        INTERVAL = Interval in seconds before the next execution to check lock activity (30 by default)
echo           COUNT = Number of times the lock activity is checked (960 by default)
echo           LOGIN = Login used ^(X3 folder^) for the monitoring (all existing by default)
echo:
echo              /V = Displays info about the program: version number, last date, variables modified and functions defined.
echo              /P = Collects Windows performance counters in an output file
echo              /E = Displays last Windows event logs collected type system and application
echo              /T = Lists running processes with associated information in an output text file
echo              /F = Displays fragmentation analysis report for each volume disk
echo:
echo     Exit status = 0 : OK
echo                 = 1 : ERROR
echo                 = 2 : WARN
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
