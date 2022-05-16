@echo off && mode con lines=50 cols=132 && color f1
::##################################################################################################################################
::#
::# check_sqllock.cmd
::#
::# Description : Monitors current lock during a period for a SQL Server database configured with a Sage X3 product v5 to v12.
::#
::# Last date   : 27/11/2020
::#
::# Version     : WINDOWS - 2.11e
::#
::# Author      : F.SUSSAN / SAGE
::#
::# Syntax      : check_sqllock [/VPETF] [ <INTERVAL> ] [ <COUNT> ] [ <LOGIN> ]
::#
::# Notes       : This script must be executed on the Sage X3 applicative server in v5, v6, v7+, v11 or v12 version.
::#               The database in version SQL Server 2005/2008/2012/2014/2016/2017, can be located on a different Windows server.
::#               A SQL script is generated to be executed with osql with the "sa" account.
::#               It is running for a total period of 8 hours by default.
::#               It is executed in regular time interval (30 seconds by default) for a number of times (960 by default).
::#               A new trace file (logs\check_sqllock_YYMMDD-HHMM.log) is generated during the monitoring.
::#               The deletion of oldest trace files is  managed.
::# 
::#               The monitoring covers the following items by default for all applicative logins :
::#               - X3 sessions
::#               - X3 module usage
::#               - X3 locked symbols
::#               - Memory usage
::#               - Memory metrics
::#               - Temp usage
::#               - Session usage
::#               - Active sessions
::#               - Active processes
::#               - Lock Escalation disable
::#               - Lock Escalation + Waits
::#               - Detecting blocking
::#               - Blocked sessions
::#               - Blocking processes
::#               - Locked objects
::#               - Active locks
::#               - Opened cursors
::#               - Current IO and CPU Workload
::# 
::#               ATTENTION, the ADXDIR variable, that specifies location where the runtime of the Sage X3 Solution is installed, is needed :
::#               - to initialize SQL Server variables in the program (DB_NAM, SQLS7_SID)
::#               - to map each process "sadoss" (PID) attached to one X3 session with the corresponding SQL Server process
::#
::#               At the beginning of the report:
::#               - Lists all power schemes in the current user's environment (powercfg -l)
::#               - Displays detailed configuration information about the computer (systeminfo)
::#               - Lists infos for each logical volume drive locally (fsutil)
::#               - Displays the statistics log for the local server (net statistics server|workstation)
::#               - Displays in option all Windows event logs collected type system and application for the last month (wevtutil)
::#               - Displays in option fragmentation analysis report for each volume disk (defrag)
::#
::#               During the monitoring for each step: 
::#               - Displays the total number of X3 sessions" and distinct logins connected during the interval
::#               - Displays the total number of X3 sessions per type (PRIMARY, SECONDARY, BATCH, WEB-SERVICES and VT TERMINAL)
::#               - Displays the total number of "Blocking locks" and "Lock escalation" detected with an alert message
::#               ATTENTION, the lock escalation disable is not available in SQL Server 2005.
::#               ATTENTION, the command line tool: "bin\diff.exe" is used for showing differences with the previous result of psadx.
::#               ATTENTION, blocking locks are detected only if they exceeds the default threshold (>=30 secs).
::# 
::#               After each step (in option): 
::#               - collects Windows and SQL Server performance counters in an output file (typeperf_<SID>_YYMMDD-HHMM.log)
::#
::#               At the end of the report:
::#               - Displays a summary about distinct number of escalation and blocking locks
::# 
::# Examples    : check_sqllock
::#                   Monitors current locks in the SQL Server database during the default period : every 30 secs 960 times = 8 hours.
::#               check_sqllock 60 600
::#                   Monitors current locks in the SQL Server database during the following period : every min 600 times = 10 hours.
::#               check_sqllock 30 1440 PROD
::#                   Monitors current locks in the SQL Server database for the login PROD during the following period : every 30 secs 1440 times = 12 hours.
::# 
::#               The following alert messages can be occurred during an interval (STEP) of the monitoring:
::#                   **** LOCK ESCALATION DETECTED (106:14344>ALISTER) !! ****
::#                      A lock escalation is occurred on the ALISTER table by the SQL session identified by SID=106 and PID=14344.
::#                   **** BLOCKING LOCK DETECTED SINCE 37 SECS (106:14344>102:1892 ) !! ****
::#                      The SQL session identified by SID=106 and PID=14344 is blocking another SQL session identified by SID=102 and PID=1892 for at least 37 secs.
::# 
::# Exit status : = 0 : OK
::#               = 1 : ERROR
::#               = 2 : WARNING
::#
::# Copyright Â© 2011-2020 by SAGE Professional Services - All Rights Reserved.
::#
::##################################################################################################################################
::#
::# Modifications history
::# --------------------------------------------------------------------------------------------------------------------------------
::# ! Date       ! Version ! Author       ! Description
::# !------------+---------+--------------+-----------------------------------------------------------------------------------------
::# ! 24/10/2014 !  1.07   ! F.SUSSAN     ! Official use of the script by the French IT & System Sage X3 team.
::# !------------+---------+--------------+-----------------------------------------------------------------------------------------
::# ! 21/01/2015 !  1.08   ! F.SUSSAN     ! This script is now compatible in multi-tiers when the database server
::# !            !         !              ! is separated from the applicative server.
::# !            !         !              ! Using the "format" function compatible only from SQL Sever 2012.
::# !            !         !              ! Adds the SQL version in the banner of the SQL script generated.
::# !------------+---------+--------------+-----------------------------------------------------------------------------------------
::# ! 25/02/2015 !  1.08a  ! F.SUSSAN     ! Correction in the checking of the SQL Server version (VER_SQL). 
::# !            !         !              ! Uses "DB_SRV\DB_SVC" variables as SQL instance in the SQL connexion.
::# !            !         !              ! Adds the checking of the variable "LOGIN".
::# !------------+---------+--------------+-----------------------------------------------------------------------------------------
::# ! 20/03/2015 !  1.08b  ! F.SUSSAN     ! Compatibility ensured in X3 V7 version with Oracle 11g R2.
::# !            !         |              ! Displays the content of the script generated only if DISPLAY variable is set.
::# !            !         !              ! Makes a loop for all existing x3 folder if LOGIN variable is not set.
::# !            !         !              ! Sets by default the variable "NBR_RET" about the number of days retention (=14).
::# !------------+---------+--------------+-----------------------------------------------------------------------------------------
::# ! 05/05/2015 !  1.08c  ! F.SUSSAN     ! Adds the case when the system format date is in Spanish : "dd-mm-aa" (Info_sysdate).
::# !            !         !              ! Adds /V option to display the version number, the last modified date of the program,
::# !            !         !              ! and the list of variables modified & functions defined.
::# !------------+---------+--------------+-----------------------------------------------------------------------------------------
::# ! 12/02/2016 !  1.08d  ! F.SUSSAN     ! Compatibility ensured in X3 V7 version with SQL Server 2012.
::# !            !         !              ! Adds the function "Info_x3folder_usage" not compatible for Sage X3 V5 products. 
::# !------------+---------+--------------+-----------------------------------------------------------------------------------------
::# ! 26/02/2016 !  1.09   ! F.SUSSAN     ! Compatibility ensured from X3 PU8 version with SQL Server 2014.
::# !            !         !              ! Connects SQL Server using windows authentication if "DB_PWD" variable is null.
::# !            !         !              ! Adds the login usage in the FOLDER section.
::# !            !         !              ! Fixes error "Arithmetic overflow error converting numeric to data type numeric."
::# !            !         !              ! Fixes error "Error converting data type nvarchar to bigint."
::# !            !         !              ! Fixes value "Wait Time (s)" for the "Blocking processes" item.
::# !------------+---------+--------------+-----------------------------------------------------------------------------------------
::# ! 12/05/2016 !  1.09a  ! F.SUSSAN     ! Adds the Windows authentication mode to connect database if the variable "DB_PWD" is not set.
::# !            !         !              ! Adds the variable "DB_USER" to define a SQL Admin account other than the "sa" account by default.
::# !            !         !              ! Adds the variable SQL_SID to initialize if needed (e.g. in case of an existing SQL listener).
::# !            !         !              ! Adds the column "App.id" in the list of X3 sessions and the section "Locked symbols".
::# !            !         !              ! In each step, it is possible to press enter to continue immediately on the next interval.
::# !------------+---------+--------------+-----------------------------------------------------------------------------------------
::# ! 28/06/2016 !  1.09b  ! F.SUSSAN     ! Fixed the check version for SQL Server if the DB server <> application server.
::# !------------+---------+--------------+-----------------------------------------------------------------------------------------
::# ! 05/10/2016 !  1.09c  ! F.SUSSAN     ! Added a system summary in the beginning of the monitoring report.
::# !------------+---------+--------------+-----------------------------------------------------------------------------------------
::# ! 15/11/2016 !  2.01   ! F.SUSSAN     ! Added the function "Check_versys" to check the operating system version for Windows.
::# !            !         !              ! Fixed the timer in the function "Sleep".
::# !------------+---------+--------------+-----------------------------------------------------------------------------------------
::# ! 05/01/2017 !  2.02   ! F.SUSSAN     ! Sets the variable "TIM" in the function "Info_sysdate".
::# !            !         !              ! Fixed the name for the SQL script when the system format date = "mm-dd-yy".
::# !------------+---------+--------------+-----------------------------------------------------------------------------------------
::# ! 15/02/2017 !  2.03   ! F.SUSSAN     ! Deleted temporary psadx files at the end of the monitoring.
::# !            !         !              ! Added a display at the beginning of the report about:
::# !            !         !              ! - statistics log for the local server
::# !            !         !              ! In option:
::# !            !         !              ! - main Windows and SQL Server performance counters (/C or FLG_PRF='1')
::# !            !         !              ! - last windows event logs collected with system and application type (/E or FLG_EVT='1')
::# !------------+---------+--------------+-----------------------------------------------------------------------------------------
::# ! 27/04/2017 !  2.04   ! F.SUSSAN     ! Compatibility ensured for the Sage X3 product V11.
::# !            !         !              ! Added the function "Info_psadx" to replace the result of the psadx command from X3 V11.
::# !            !         !              ! Added a list of all power management plans (schemes) in the current user's environment.
::# !------------+---------+--------------+-----------------------------------------------------------------------------------------
::# ! 06/06/2017 !  2.05   ! F.SUSSAN     ! Fixed empty list of "Module usage" and "Login usage" by using the CREDATTIM instead of  
::# !            !         !              ! CREDAT column from the AFCTCUR table if defined.
::# !            !         !              ! Fixed last lines returned in "the Locked symbols" item by using the correct format datetime 
::# !            !         !              ! "mm" instead of "MM".
::# !------------+---------+--------------+-----------------------------------------------------------------------------------------
::# ! 10/07/2017 !  2.06   ! F.SUSSAN     ! Added a new item "Opened cursors" to identify details for API cursor to fetch rows.
::# !            !         !              ! Added a supplemental information 'SINCE NNN SECS' in the alert message for blocking sessions.
::# !            !         !              ! Added wait type info for the "Detecting blocking" item.
::# !            !         !              ! Updated list of performance counters to collect data for analyzing (/C or FLG_PRF='1').
::# !            !         !              ! Fixes value "Elapsed Time (s)" for the "Active sessions" item in secs and not in msecs.
::# !------------+---------+--------------+-----------------------------------------------------------------------------------------
::# ! 17/10/2017 !  2.06a  ! F.SUSSAN     ! Added the compatibility for SQL Server 2016.
::# !            !         !              ! Displayed list of Module and Login usage even if no function is currently used (Menu).
::# !            !         !              ! Displayed "Lock Escalation + Waits" and "Lock Escalation disable" at the beginning and
::# !            !         !              ! the end of the report.
::# !------------+---------+--------------+-----------------------------------------------------------------------------------------
::# ! 09/11/2017 !  2.07   ! F.SUSSAN     ! Replaced the obsolete "osql" command line utility by "sqlcmd".  
::# !            !         !              ! Added the LAN variable to display text according to language specified.
::# !            !         !              ! Fixed the get of product type (type_prd).
::# !            !         !              ! Changed display for listing the result of the psadx function.
::# !            !         !              ! Displayed only NEW X3 sessions when last read occurred during the last interval.
::# !            !         !              ! Added supplemental session types such as Web page, Classic page and Eclipse from Sage X3 V11.
::# !            !         !              ! Fixed problem of translation characters during binary execution (code page used = 1252).
::# !            !         !              ! Generated an output text file (tasklist*.log) in option containing running processes with 
::# !            !         !              ! associated information: datetime, process, PID, username, mem usage and CPU time (/T or FLG_TSK='1').
::# !------------+---------+--------------+-----------------------------------------------------------------------------------------
::# ! 11/04/2018 !  2.07a  ! F.SUSSAN     ! Compatibility ensured for Windows Server 2016.
::# !            !         !              ! Compatibility with SQL version build number 14.0 where SSMS 17.x is installed on the applicative server.
::# !            !         !              ! Fixed the display of X3 sessions even if module or function is null.
::# !            !         !              ! Added count of login and session in the "Type session" item.
::# !            !         !              ! Fixed value for total sessions and logins in V11.
::# !------------+---------+--------------+-----------------------------------------------------------------------------------------
::# ! 16/05/2018 !  2.07b  ! F.SUSSAN     ! Fixed value for total sessions and logins before V11.
::# !------------+---------+--------------+-----------------------------------------------------------------------------------------
::# ! 11/09/2018 !  2.07c  ! F.SUSSAN     ! Added 'Connection' and 'Last action' in the list of X3 session from X3 V11.
::# !            !         !              ! Added backard compatibility for Sage X3 Product V5 under Windows Server 2003.
::# !            !         !              ! Added old option -o with the psadx command to display X3 function when the AFTCUR table does not exists.
::# !            !         !              ! Added only NEW Opened cursors during each interval.
::# !            !         !              ! Added the -n option with the osql utility to remove numbering and the prompt symbol (>) from input lines.
::# !            !         !              ! Added the PROG variable to identify the main program name in the "Session usage" item.
::# !            !         !              ! Replaced the RUN type by OTHERS in the "Sssion usage" item.
::# !            !         !              ! Fixed the display in list of login and module names when are empty or identical.
::# !------------+---------+--------------+-----------------------------------------------------------------------------------------
::# ! 16/09/2018 !  2.07d  ! F.SUSSAN     ! Added the LCK_TIME variable which is a threshold to alert for each detected blocking lock (30 secs by default).
::# !            !         !              ! Fixed when checking SQL version depending the default language configured on the server.
::# !            !         !              ! Added supplemental session types such as Web page, Classic page and Eclipse from Sage X3 V7+.
::# !            !         !              ! Added new option (/F or FLG_FRG='1') to display fragmentation analysis report for each volume disk.
::# !            !         !              ! Added new variable EXCL_LOGIN to exclude schema for the monitoring.
::# !------------+---------+--------------+-----------------------------------------------------------------------------------------
::# ! 03/12/2018 !  2.07e  ! F.SUSSAN     ! Displayed only new Login and Module usage during each interval.
::# !            !         !              ! Added the "Last time" item.
::# !------------+---------+--------------+-----------------------------------------------------------------------------------------
::# ! 23/01/2019 !  2.08   ! F.SUSSAN     ! Fixed when the command "diff.exe" is not used.
::# !            !         !              ! Fixed counter variables to 0 when no user connexion.
::# !------------+---------+--------------+-----------------------------------------------------------------------------------------
::# ! 01/03/2019 !  2.08a  ! F.SUSSAN     ! Added the CMD_SQL variable to choose SQL Server command used to connect database (sqlcmd or osql).
::# !            !         !              ! Replaced the PWD_SYS and USR_SYS by DB_PWD and DB_USER variables.
::# !------------+---------+--------------+-----------------------------------------------------------------------------------------
::# ! 25/04/2019 !  2.08b  ! F.SUSSAN     ! Fixed when delete older trace files.
::# !------------+---------+--------------+-----------------------------------------------------------------------------------------
::# ! 09/10/2019 !  2.08c  ! F.SUSSAN     ! Fixed when the EXCL_LOGIN variable is set.
::# !            !         !              ! Fixed bug when used the psadx.exe command with the -b option (LOGIN variable defined).
::# !------------+---------+--------------+-----------------------------------------------------------------------------------------
::# ! 04/11/2019 !  2.08d  ! F.SUSSAN     ! Fixed display "Memory usage" item too slow when max memory server in gigabytes is high (MAX_MEM>64).
::# !            !         !              ! Added the Check_db function for retrieving info and setting max length of data for display.
::# !------------+---------+--------------+-----------------------------------------------------------------------------------------
::# ! 27/11/2019 !  2.09   ! F.SUSSAN     ! Fixed display when unable to connect to database using SQL Server authentication.
::# !            !         !              ! Used %DB_NAM% for string connection instead of %DB_SRV%\%DB_SVC% due to presence of a TCP port. 
::# !            !         !              ! Fixed message "Error converting data type nvarchar to bigint" in the "Current IO and CPU Workload" item.
::# !            !         !              ! Added the new "Blocking tree" to display tree lock for each blocking session.
::# !            !         !              ! Added a summary report for each blocking session and the corresponding X3/SQL command to use for kill them.
::# !            !         !              ! Fixed display of SQL Text in the "Blocked sessions" item excluding list of compiled parameters.
::# !------------+---------+--------------+-----------------------------------------------------------------------------------------
::# ! 19/12/2019 !  2.10   ! F.SUSSAN     ! Added compatibility for SQL Server 2017 and Windows Server 2019.
::# !            !         !              ! Fixed SQL error message "Invalid column name 'CREDATTIM_0'".
::# !------------+---------+--------------+-----------------------------------------------------------------------------------------
::# ! 27/03/2020 !  2.10a  ! F.SUSSAN     ! Fixed retro compatibility for SQL Server 2005/2008.
::# !------------+---------+--------------+-----------------------------------------------------------------------------------------
::# ! 05/05/2020 !  2.10b  ! F.SUSSAN     ! Compatibility ensured for the Sage X3 product V12.
::# !            !         !              ! Fixed display content of Locked symbols.
::# !------------+---------+--------------+-----------------------------------------------------------------------------------------
::# ! 02/06/2020 !  2.11   ! F.SUSSAN     ! Added the function "Check_verapp" for checking Sage X3 application version (V5 to V12).
::# !            !         !              ! Added display of type and version for the Sage application (typeprd, apversion) in the "version" function.
::# !            !         !              ! Added supplemental infos at the beginning of the report:
::# !            !         !              ! - Paging file usage (swap)
::# !            !         !              ! - Physical disks (including SSD/HDD) available from Windows Server 2008 R2
::# !            !         !              ! - Logical volume drives locally
::# !            !         !              ! Removed unnecessary server statistics infos at the beginning of the report.
::# !            !         !              ! Fixed and enhanced display of blocking lock alert message in the "Blocking tree" item.
::# !            !         !              ! Defined the FLG_PSADX variable to indicate if result of psadx is issue from tables (ASSYM*).
::# !------------+---------+--------------+-----------------------------------------------------------------------------------------
::# ! 06/07/2020 !  2.11a  ! F.SUSSAN     ! Fixed the display of missing 'sadoss' processes in the list of X3 sessions when the LOGIN variable is defined.
::# !------------+---------+--------------+-----------------------------------------------------------------------------------------
::# ! 11/08/2020 !  2.11b  ! F.SUSSAN     ! Added list of all installed programs locally at the beginning of the report.
::# !            !         !              ! Accepted default SQL Server instance (MSSQLSERVER).
::# !------------+---------+--------------+-----------------------------------------------------------------------------------------
::# ! 24/08/2020 !  2.11c  ! F.SUSSAN     ! Added case when 'CPU (%)' and/or 'IO (%)' is a null value in the "Current IO and CPU Workload" item.
::# !------------+---------+--------------+-----------------------------------------------------------------------------------------
::# ! 03/11/2020 !  2.11d  ! F.SUSSAN     ! Changed SQL Server command used to connect database: 'sqlcmd' by default from SQL Server 2012 else 'osql.
::# !------------+---------+--------------+-----------------------------------------------------------------------------------------
::# ! 27.11.2020 !  2.11e  ! F.SUSSAN     ! Fixed finding product installation location in registry for installed 32-bit applications (HKEY_REG).
::# --------------------------------------------------------------------------------------------------------------------------------
::##################################################################################################################################

::#!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!#
::#!!!!    THE FOLLOWING VARIABLES ARE TO BE MODIFIED    !!!!#
::#!!!!    DEPENDING ON YOUR SYSTEM IMPLEMENTATION.      !!!!#
::#!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!#

:: Location of the runtime for the Sage X3 solution
set ADXDIR=D:\SageX3\X3V12\runtime

:: Password for the "sa" account (if null value, Windows authentication is used for connection)
set DB_PWD=

::#!!!!--------------------------------------------------!!!!#
::#!!!!    SPECIFIC VARIABLES USED FOR THE OPERATION     !!!!#
::#!!!!--------------------------------------------------!!!!#

:: Number of days retention before deletion older trace files (='14' by default)
set NBR_RET=

:: SQL Admin account used for SQL Server authentication (if null value ="sa" by default)
set DB_USER=

:: Login used as search criteria for the monitoring (=x3 folder else all existing)
set LOGIN=

:: Directory where X3 FOLDERS are stored (by default if null value in the same relative path specified in the ADXDIR variable)
set ADXDOS=

:: SQL instance name used (automatically detected by X3 environment if null value (e.g. <servername>\<instance>[,<port number>)
set SQL_SID=

:: Interval in seconds (10-999] before the next execution of the monitoring SQL script (if null value = 30 seconds by default)
set INTERVAL=60

:: Count to define the number of times the monitoring SQL script is executed (if null value = 960 times)
set COUNT=

:: Elapsed time threshold in seconds before making an alert when detecting blocking lock (if null value = 30 seconds by default)
set LCK_TIME=

:: 1st SQL Server format date used (='dd/MM/yy' by default if null value)
set FMT_DAT1=

:: 2nd SQL Server format date used (='dd/MM/yy HH:mm' by default if null value)
set FMT_DAT2=

:: 3rd SQL Server format date used (='dd/MM/yy HH:mm:ss' by default if null value)
set FMT_DAT3=

:: SQL Server convert date used compatible for SQL Server 2005 (='3' by default if null value equivalent to the format 'dd/MM/yy')
set CNV_DATE=

:: SQL Server convert date used compatible for SQL Server 2005 (='8' by default if null value equivalent to the format 'HH:mm:ss')
set CNV_TIME=

:: Display length used for SQL Text (='300' by default if null value)
set LEN_SQLT=

:: Number of first N rows returned (='20' by default if null value)
set TOP_NSQL=

:: Lists all and not only new elements at the beginning and the end of the monitoring (='0' by default if null value)
set FLG_ALL=

:: Location of another script to execute at the beginning of the monitoring (by default located in the SCRIPTDIR directory)
set SCRIPTEXE=

:: Login excluded as search criteria for the monitoring
set EXCL_LOGIN=

:: The command line tool used for showing differences between files (if null value, the command "diff.exe" is used by defaut located in the sub-directory "\bin".
set CMD_DIFF=

:: Flag to collect Windows and SQL Server performance counters (by default 0 else 1)
set FLG_PRF=

:: Flag to display last Windows event logs collected type system and application (by default 0 else 1)
set FLG_EVT=

:: Flag to list currently running processes with associated information (by default 0 else 1)
set FLG_TSK=

:: Flag to display fragmentation analysis report for each volume disk (by default 0 else 1)
set FLG_FRG=

:: Language used to display text from X3 tables (by default = 'FRA' else 'ENG', 'ITA', 'POR', or 'SPA')
set LAN=

:: String used to identify the main program name for session usage (='Adonix' by default)
set PROG=

:: String used to list criterias used for research all specified installed programs locally (If null value, all installed programs. Eg. 'Sage Safe Adonix Database')
set LST_FINDPRG=

:: SQL Server command used to connect database (='sqlcmd' by default from SQL Server 2012 else 'osql').
set CMD_SQL=

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

:: Checks the operating system version for Windows (2008, 2012, 2016 or 2019 required)
call :Check_versys || goto End

:: Checks the value for variables that are defined
call :Check_variables || goto End

:: Checks if the SQL Server is compatible (2005, 2008, 2012, 2014, 2016, 2017 or 2019 required)
call :Check_versql || goto End

:: Checks version for the Sage X3 application (v5 to v12)
call :Check_verapp

:: Creates non existent directories that will be used
call :Create_dir %LOGDIR% || goto End

:: Initializes files used in the program
call :Init_files

:: Checks database for retrieving info and setting max length of data for display
call :Check_db || goto End

if defined LOGIN (
	call :Display_timestamp MONITORING %type_prd% LOCK ACTIVITY IN THE %type_db% DATABASE [%SQLS7_SID%] FOR THE LOGIN [%LOGIN%] EVERY %INTERVAL% SECS %COUNT% TIMES...
) else (
	call :Display_timestamp MONITORING %type_prd% LOCK ACTIVITY IN THE %type_db% DATABASE [%SQLS7_SID%] EVERY %INTERVAL% SECS %COUNT% TIMES...
)
if "%PAUSE%"=="1" call :Pause

:: Executes the loop SQL script for checking SQL SERVER lock
call :Start_check_sqllock || goto End
set RET=%ERRORLEVEL%
call :Display
call :Display_timestamp MONITORING ENDED. 

:: Checks the result of the SQL script execution
if "%SUM_LCK%"=="0" (set RET=0) else (set RET=1)
if "%RET%"=="0" (
	call :Display STATUS : OK
) else (
	call :Display STATUS : KO
)
call :Display Trace file '%file_log%' generated.

:: Deletes older trace files
call :Display
for /F "delims=" %%i in ("%~nx0") do set progname=%%~ni
forfiles /P "%LOGDIR%" /M "%progname%_%SQLS7_SID%_*.*" /D "-%NBR_RET%" /C "cmd /C del /S/F/Q @FILE|echo Deletion of : @FILE" 2>NUL

:: End of the program
goto End

:Init_variables
::#************************************************************#
::# Initializes variables used in the program
::#

:: Standard variables
set dbversion=Microsoft SQL Server 2005, 2008, 2012, 2014, 2016, 2017 or 2019
set copyright=Copyright {C} 2011-2020
set author=Sage Group
for /F "delims=" %%i in ('hostname') do set hostname=%%i
for /F "delims=" %%i in ("%~nx0")    do set progname=%%~ni
for /F "delims=" %%i in ("%~nx0")    do set extname=%%~xi
set dirname=%~dp0
set dirname=%dirname:~,-1%
for /f "tokens=5 delims=- " %%i in ('findstr /C:"# Version" "%dirname%\%progname%%extname%" ^| findstr /v findstr ') do set version=%%i
if exist %ADXDIR%\bin\env.bat call %ADXDIR%\bin\env.bat
set dbhome=%SQL_HOME%%SQLS7_OSQL%\Binn
call set PATH=%dbhome%;%%PATH:%dbhome%=%%
call set PATH=%adxdir%\bin;%%PATH:%dbhome%=%%
set CURDIR=%CD%
call :Upper hostname
call :Info_sysdate
if not defined SCRIPTDIR set SCRIPTDIR=%dirname%
if not defined LOGDIR    set LOGDIR=%SCRIPTDIR%\logs
if not defined DISPLAY   set DISPLAY=0
if not defined PAUSE     set PAUSE=0
if not defined DELAY     set DELAY=10

:: Specific variables
set type_db=SQL SERVER
if not defined SQL_BDD if defined SQLS7_SID set SQL_BDD=%SQLS7_SID%
if not defined ADXDOS if exist "%ADXDIR%\adxvolumes" for /F "tokens=1,2,3 delims=: " %%i in ('type %ADXDIR%\adxvolumes ^| find /I "A:" ') do set ADXDOS=%%j:%%k
if defined DB_SRV for /f "tokens=1 delims=\" %%i in ('echo %DB_SRV%') do endlocal & set "DB_SRV=%%i"
if defined DB_NAM for /f "tokens=1,2 delims=\ " %%i in ('echo %DB_NAM%') do endlocal & set "SQL_SID=%%i\%%j"
if defined DB_NAM if not defined ADXDOS if exist %ADXDIR%\..\dossiers set ADXDOS=%ADXDIR:~,-8%\dossiers
if defined DB_NAM if not defined ADXDOS if exist %ADXDIR%\..\folders set ADXDOS=%ADXDIR:~,-8%\folders
if defined SQL_SID if not defined DB_SRV for /f "tokens=1 delims=\" %%i in ('echo %SQL_SID%') do set "DB_SRV=%%i"
if defined SQL_SID if not defined DB_SVC for /f "tokens=2 delims=\" %%i in ('echo %SQL_SID%') do set "DB_SVC=%%i"
if defined DB_SRV for /f "tokens=1 delims=." %%i in ('echo %DB_SRV%') do set "DB_SRV=%%i"
if defined DB_SRV if "%DB_SRV%"=="." (set DB_SRV=%hostname%)
if defined DB_SRV for /f "tokens=1 delims=."  %%i in ('echo %DB_SRV%') do set "DB_SRV=%%i"
if defined DB_SRV call :Upper DB_SRV
if defined AE_SERVICE_NAME if not defined DB_SVC for /f "tokens=2 delims=\"  %%i in ('echo %AE_SERVICE_NAME%') do endlocal & set "DB_SVC=%%i"
if exist %ADXDIR%\SERV* for /f %%i in ('dir /B %ADXDIR%\SERV*') do set DOSS_REF=%%i
if exist %ADXDOS%\SERV* for /f %%i in ('dir /B %ADXDOS%\SERV*') do set DOSS_REF=%%i
if exist %ADXDIR%\SERV* for /f %%i in ('dir /B %ADXDIR%\SERV*') do set type_prd=%%i
if exist %ADXDOS%\SERV* for /f %%i in ('dir /B %ADXDOS%\SERV*') do set type_prd=%%i
if defined type_prd set type_prd=%type_prd:~4%
if not defined type_prd if defined ADXDOS for /f delims^=^"^ tokens^=4 %%i in ('type %ADXDOS%\FOLDERS.xml ^| find "MOTH1="') do set type_prd=%%i
if exist %ADXDOS%\%type_prd%\FIL\ASYSSMPROCES.fde (set FLG_PSADX=1) else (set FLG_PSADX=0)
if not defined NBR_RET  (set NBR_RET=14)
if not defined INTERVAL (set INTERVAL=30)
if not defined COUNT    (set COUNT=960)
if not defined LCK_TIME (set LCK_TIME=30)
if not defined DB_USER  (set DB_USER=sa)
if not defined FMT_DAT1 (set FMT_DAT1=dd/MM/yy)
if not defined FMT_DAT2 (set FMT_DAT2=dd/MM/yy HH:mm)
if not defined FMT_DAT3 (set FMT_DAT3=dd/MM/yy HH:mm:ss) 
if not defined CNV_DATE (set CNV_DATE=3)
if not defined CNV_TIME (set CNV_TIME=8)
if not defined LEN_SQLT (set LEN_SQLT=300)
if not defined TOP_NSQL (set TOP_NSQL=20)
if not defined FLG_ALL  (set FLG_ALL=0)
if not defined CMD_DIFF (set CMD_DIFF=diff.exe)
if not defined FLG_PRF  (set FLG_PRF=0)
if not defined FLG_EVT  (set FLG_EVT=0)
if not defined FLG_TSK  (set FLG_TSK=0)
if not defined FLG_FRG  (set FLG_FRG=0)
if not defined LAN      (set LAN=FRA)
if not defined PROG     (set PROG=Adonix)
for /f "delims=[] tokens=2" %%i in ('ping -4 %computername% -n 1 ^| findstr "["') do (set IP_ADDRESS=%%i)
:: Defines the number of times that blocking locks  was detected during the monitoring
(set NEW_LCK=0) & (set SUM_LCK=0)
:: Defines the number of times that lock escalation was detected during the monitoring
(set NEW_ESC=0) & (set SUM_ESC=0)
:: Defines the number of distinct login and x3 session connected simultaneously during the monitoring
(set SUM_LOG=0) & (set SUM_SES=0)
:: Defines the number for each type of X3 session
(set SUM_PRM=0) & (set SUM_SEC=0) & (set SUM_BAT=0) & (set SUM_WEB=0) & (set SUM_TVT=0) & (set SUM_BAT=0) & (set SUM_WPA=0) & (set SUM_CPA=0) & (set SUM_WEB=0) & (set SUM_ECL=0)
:: Defines the code page used (West European Latin) to avoid problem of translation characters during binary execution
chcp 1252 >NUL
set TASK=adonix adxdsrv AdxSrvImp chrome eclipse ElastSch firefox iexplore httpd oracle node mongod sadora sadoss sadfsq sqlservr SyDocSrv Syracuse TNSLSNR
set CMD_PSADX=psadx
set LST_FINDPRG=Sage Safe Adonix Database Elastic cms- %LST_FINDPRG%
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
sc \\%DB_SRV% query "MSSQL$%DB_SVC%">NUL
if errorlevel 1 if "%DB_SRV%"=="%hostname%" (
	sc \\%DB_SRV% query "MSSQLSERVER%">NUL
	if errorlevel 1 (
		echo ERROR: The database service is not defined [SQL Server ^(%DB_SVC%^)] !!
		exit /B %RET%
	) else (
		set DB_SVC=
	)
)
for /F "tokens=3 delims= " %%i in ('sc \\%DB_SRV% query "MSSQL$%DB_SVC%" ^| find "STATE" ') do (
	if not "%%i"=="4" ( 
		echo ERROR: The database service is not started [SQL Server ^(%DB_SVC%^)] !!
		exit /B %RET%
	)
)
if defined ADXDOS if not exist %ADXDOS% (
	if not exist %ADXDOS%\X3_PUB (
		echo ERROR: The variable "ADXDOS" [%ADXDOS%] must match an existing X3 folder path !!
		exit /B %RET%
	)
)
if defined LOGIN (
	if not exist %ADXDOS%\%LOGIN%\FIL (
		echo ERROR: The variable "LOGIN" [%LOGIN%] must match an existing X3 folder !!
		exit /B %RET%
	)
)
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
if (%ADXDIR%)==() if exist %dirname%..\bin\env.bat (set ADXDIR=%dirname%..)
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
echo %FLG_PSADX% | findstr /r "\<[0-1]\>">NUL
if errorlevel 1 (
	echo ERROR: Invalid flag [%FLG_PSADX%] for the variable "FLG_PSADX" [0-1] !!
	exit /B %RET%
)
if exist %ADXDOS%\%DOSS_REF%\FIL\AFCTCUR.srf find "CREDATTIM" %ADXDOS%\%DOSS_REF%\FIL\AFCTCUR.srf >NUL
if errorlevel 1 (set CREDAT=CREDAT_0) else (set CREDAT=CREDATTIM_0)
if not defined CMD_SQL if not "%VER_SQL%"=="9.0" if not "%VER_SQL%"=="10.0" if not "%VER_SQL%"=="10.5" set CMD_SQL=sqlcmd
if not defined CMD_SQL set CMD_SQL=osql
if /I not "%CMD_SQL%"=="osql" if /I not "%CMD_SQL%"=="osql.exe" if /I not "%CMD_SQL%"=="sqlcmd" if /I not "%CMD_SQL%"=="sqlcmd.exe" (
	echo ERROR: Invalid value [%CMD_SQL%] for SQL Server command line tool ["sqlcmd" or "osql"] !!
	exit /B %RET%
)
where %CMD_SQL% >NUL 2>&1
if errorlevel 1 (
	echo ERROR: SQL Server command line tool [%CMD_SQL%] was not found !!
	exit /B %RET%
)
echo %PAUSE% | findstr /r "\<[0-1]\>">NUL
if errorlevel 1 (
	echo ERROR: Invalid flag [%PAUSE%] for the variable "PAUSE" [0-1] !!
	exit /B %RET%
)
if defined LAN if not "%LAN%"=="FRA" if not "%LAN%"=="ENG" if not "%LAN%"=="ITA" if not "%LAN%"=="POR" if not "%LAN%"=="SPA" (
	echo ERROR: Invalid value [%LAN%] for the variable "LAN" [FRA, ENG, ITA, POR or SPA] !!
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

if not defined LOGIN set IDENTIFIER=%SQLS7_SID%_%DAT%-%TIM%
if defined LOGIN set IDENTIFIER=%SQLS7_SID%_%DAT%-%TIM%-%LOGIN%
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

:Start_check_sqllock
::#************************************************************#
::# Start the loop SQL script for checking SQL lock
::#

set NB=0
if defined LOGIN set OPTION=-b %LOGIN%
if "%VER_SQL%"=="9.0" (set PROG=)
if "%FLG_TSK%"=="1" >>%file_tsk% echo Datetime;Process;PID;Username;Mem Usage;CPU Time
:loop
set /A NB=%NB%+1
if %NB% LEQ 2 (
	:: Generates the SQL script for listing the result of the psadx function (Only from Sage X3 product V11 and later)
	if "%FLG_PSADX%"=="1" call :Cre_info_psadx

	:: Generates the SQL script for checking SQL lock
	call :Cre_check_sqllock

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
   if "%format%"=="jj-mm-aa" (call :Display Liste les programmes Sage installés en local ...) else (call :Display Listing all locally installed Sage programs ...)
   >>%file_log% echo:
   setlocal enableDelayedExpansion
   set "key="&set "name="&set "ver="&set "dir="
   if not "%VER_SYS%" == "6.0" if not "%VER_SYS%" == "6.1" if not "%VER_SYS%" == "6.2" if not "%VER_SYS%" == "6.3" (
      set HKEY_REG=HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall
   ) else (
      set HKEY_REG=HKLM\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall
   )
   for %%h in (%computername%) do (
      for /f "delims=" %%A in ('reg query "\\%%h\!HKEY_REG!" /s 2^>nul') do (
         set "ln=%%A"
         if "!ln:~0,4!" equ "HKEY" (
         	if defined name if     defined LST_FINDPRG (echo !name! [!ver!] !dir! | findstr /I "!LST_FINDPRG!" >>%file_log%)
         	if defined name if not defined LST_FINDPRG (echo !name! [!ver!] !dir! >>%file_log%)
         	set "name="&set "ver="&set "dir="&set "key=%%A"
         ) else for /f "tokens=1,2*" %%A in ("!ln!") do (
            if "%%A" equ "DisplayName" set "name=%%C"
            if "%%A" equ "DisplayVersion" set "ver=%%C"
            rem if "%%A" equ "InstallSource" set "dir=%%C"
         )
      )
   )
   if defined name if     defined LST_FINDPRG (echo !name! [!ver!] !dir! | findstr /I "!LST_FINDPRG!" >>%file_log%)
   if defined name if not defined LST_FINDPRG (echo !name! [!ver!] !dir! >>%file_log%)
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
	:: Generates the SQL script for listing the result of the psadx function (Only from Sage X3 product V11 and later)
	if "%FLG_PSADX%"=="1" call :Cre_info_psadx

	:: Generates the SQL script for checking SQL lock
	call :Cre_check_sqllock
	
	:: Displays the content of the SQL script if asked
	call :Display_script LIST OF INSTRUCTIONS IN THE SQL SCRIPT [%file_sql%]
)
>>%file_log% echo:
>>%file_log% echo STEP %NB%/%COUNT% %TIME:~,8%
>>%file_log% echo +-----------------+
if (%NB%)==(1)       >>%file_log% echo ^| ALL X3 sessions ^|
if (%NB%)==(%COUNT%) >>%file_log% echo ^| ALL X3 sessions ^|
if not (%NB%)==(1) if not (%NB%)==(%COUNT%) if (%FLG_ALL%)==(1) >>%file_log% echo ^| ALL X3 sessions ^|
if not (%NB%)==(1) if not (%NB%)==(%COUNT%) if defined CMD_DIFF if "%FLG_ALL%"=="0" >>%file_log% echo ^| NEW X3 sessions ^|
>>%file_log% echo +-----------------+
>>%file_log% echo:
if exist %file_adx% move /Y %file_adx% %file_adx%.old>NUL
if "%FLG_PSADX%"=="0" if exist     %ADXDOS%\%DOSS_REF%\FIL\AFCTCUR.srf %CMD_PSADX% -fgxi  %OPTION% >>%file_adx%
if "%FLG_PSADX%"=="0" if not exist %ADXDOS%\%DOSS_REF%\FIL\AFCTCUR.srf %CMD_PSADX% -fogxi %OPTION% >>%file_adx%
if "%FLG_PSADX%"=="0" if not (%NB%)==(1) if not (%NB%)==(%COUNT%) if defined CMD_DIFF if exist     %ADXDOS%\%DOSS_REF%\FIL\AFCTCUR.srf (>>%file_log% echo   Uid         Client                                                       Folder           User                 App. Id       Process)
if "%FLG_PSADX%"=="0" if not (%NB%)==(1) if not (%NB%)==(%COUNT%) if defined CMD_DIFF if exist     %ADXDOS%\%DOSS_REF%\FIL\AFCTCUR.srf (>>%file_log% echo   ----------- ------------------------------------------------------------ ---------------- -------------------- ------------- ------------------------------)
if "%FLG_PSADX%"=="0" if not (%NB%)==(1) if not (%NB%)==(%COUNT%) if defined CMD_DIFF if not exist %ADXDOS%\%DOSS_REF%\FIL\AFCTCUR.srf (>>%file_log% echo   Uid         Client                     Folder            Function          User       App. Id.    Process)
if "%FLG_PSADX%"=="0" if not (%NB%)==(1) if not (%NB%)==(%COUNT%) if defined CMD_DIFF if not exist %ADXDOS%\%DOSS_REF%\FIL\AFCTCUR.srf (>>%file_log% echo   ----------- -------------------------- ----------------- ----------------- ---------- ----------- ------------------------------)
if exist %file_adx%.old if %NB% LSS %COUNT% if defined CMD_DIFF (%CMD_DIFF% %file_adx%.old %file_adx% >>%file_log%)
if not exist %file_adx%.old	if exist %file_adx% (type %file_adx% >>%file_log%)
if exist %file_adx%.old	if not defined CMD_DIFF (type %file_adx% >>%file_log%)
if exist %file_adx%.old	if (%NB%)==(%COUNT%) if defined CMD_DIFF (type %file_adx% >>%file_log%)
if defined     DB_PWD if /I "%CMD_SQL%"=="osql"   >>%file_log% %CMD_SQL% -S %DB_NAM% -U %DB_USER% -d %SQLS7_SID% -i %file_sql% -o %file_tmp%.log -P %DB_PWD% -w500
if defined     DB_PWD if /I "%CMD_SQL%"=="sqlcmd" >>%file_log% %CMD_SQL% -S %DB_NAM% -U %DB_USER% -d %SQLS7_SID% -i %file_sql% -o %file_tmp%.log -P %DB_PWD% -w500 -m 1
if not defined DB_PWD if /I "%CMD_SQL%"=="osql"   >>%file_log% %CMD_SQL% -S %DB_NAM% -E -d %SQLS7_SID% -i %file_sql% -o %file_tmp%.log -w500 -n
if not defined DB_PWD if /I "%CMD_SQL%"=="sqlcmd" >>%file_log% %CMD_SQL% -S %DB_NAM% -E -d %SQLS7_SID% -i %file_sql% -o %file_tmp%.log -w500 -m 1
if "%DISPLAY%"=="1" if defined     DB_PWD if /I "%CMD_SQL%"=="osql"   >>%file_log% echo %CMD_SQL% -S %DB_NAM% -U %DB_USER% -d %SQLS7_SID% -i %file_sql% -o %file_tmp%.log -P %DB_PWD% -w500
if "%DISPLAY%"=="1" if defined     DB_PWD if /I "%CMD_SQL%"=="sqlcmd" >>%file_log% echo %CMD_SQL% -S %DB_NAM% -U %DB_USER% -d %SQLS7_SID% -i %file_sql% -o %file_tmp%.log -P %DB_PWD% -w500 -m 1
if "%DISPLAY%"=="1" if not defined DB_PWD if /I "%CMD_SQL%"=="osql"   >>%file_log% echo %CMD_SQL% -S %DB_NAM% -E -d %SQLS7_SID% -i %file_sql% -o %file_tmp%.log -w500 -n
if "%DISPLAY%"=="1" if not defined DB_PWD if /I "%CMD_SQL%"=="sqlcmd" >>%file_log% echo %CMD_SQL% -S %DB_NAM% -E -d %SQLS7_SID% -i %file_sql% -o %file_tmp%.log -w500 -m 1
if errorlevel 1 (
	call :Display -----
	if defined DB_PWD (call :Display ERROR: UNABLE TO CONNECT TO DATABASE [%SQLS7_SID%] USING SQL SERVER AUTHENTICATION [%DB_USER%] !!) else (call :Display ERROR: UNABLE TO CONNECT TO DATABASE [%SQLS7_SID%] USING WINDOWS AUTHENTICATION [%userdomain%\%username%] !!)
	call :Display -----
	call :Display STATUS : KO
	set RET=1
	exit /B 1
)
if "%DISPLAY%"=="1" >>%file_log% echo:
for /f %%i in ('type %file_tmp%.log ^| find /c "**** BLOCKING LOCK DETECTED" ')   do set NEW_LCK=%%i
for /f %%i in ('type %file_tmp%.log ^| find /c "**** LOCK ESCALATION DETECTED" ') do set NEW_ESC=%%i
type %file_tmp%.log | find /V "1>"
type %file_tmp%.log | find /V "1>" >>%file_log%

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
set /A SUM_ESC=%SUM_ESC%+%NEW_ESC%
call :Display ------------------------------------------------------------
if not "%NEW_LCK%"=="0" (call :Display WARNING: %NEW_LCK% NEW BLOCKING LOCK RECORDED IN THE TRACE FILE !!)
if not "%NEW_ESC%"=="0" (call :Display WARNING: %NEW_ESC% NEW LOCK ESCALATION RECORDED IN THE TRACE FILE !!)
if "%NEW_LCK%"=="0" if "%NEW_ESC%"=="0" (
	call :Display INFO: NO NEW BLOCKING LOCK AND LOCK ESCALATION DETECTED.
) else (
	call :Display ------------------------------------------------------------
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
if "%FLG_PSADX%"=="0" if defined LOGIN     (for /f "skip=2 tokens=4" %%i in ('%CMD_PSADX% -g %OPTION%') do @echo %%i) | sort | find /v ")" >>%file_tmp%.log
if "%FLG_PSADX%"=="0" if not defined LOGIN (for /f "skip=2 tokens=3" %%i in ('%CMD_PSADX% -g') do @echo %%i) | sort | find /v ")" >>%file_tmp%.log
if "%FLG_PSADX%"=="0" if not defined LOGIN if exist %file_tmp% del %file_tmp%
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
if exist %file_tmp%.log del %file_tmp%.log>NUL

:: Calculates the number of distinct X3 sessions and logins
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
if !SUM_PRM! GTR 0 call :Display TOTAL PRIMARY      : !SUM_PRM!
if !SUM_SEC! GTR 0 call :Display TOTAL SECONDARY    : !SUM_SEC!
if !SUM_BAT! GTR 0 call :Display TOTAL BATCH        : !SUM_BAT!
if !SUM_WPA! GTR 0 call :Display TOTAL WEB PAGE     : !SUM_WPA!
if !SUM_CPA! GTR 0 call :Display TOTAL CLASSIC PAGE : !SUM_CPA!
if !SUM_WEB! GTR 0 call :Display TOTAL WEB-SERVICES : !SUM_WEB!
if !SUM_TVT! GTR 0 call :Display TOTAL TERMINAL VT  : !SUM_TVT!
if !SUM_ECL! GTR 0 call :Display TOTAL ECLIPSE      : !SUM_ECL!
set /A SUM_SES=!SUM_PRM! + !SUM_SEC! + !SUM_BAT! + !SUM_WPA! + !SUM_CPA! + !SUM_WEB! + !SUM_TVT!
if !SUM_SES! GTR 0 call :Display ------------------------------------------------------------
endlocal
call :Display TOTAL BLOCKING LOCKS  : %SUM_LCK%
call :Display TOTAL LOCK ESCALATION : %SUM_ESC%
call :Display ------------------------------------------------------------
echo See trace file '%file_log%' for more details...
echo:
if exist %file_tmp%.log del %file_tmp%.log>NUL
>>%file_log% echo ===============================================================================================================================================================================================================

:: Collects main Windows and SQL Server performance counters (optional)
if (%FLG_PRF%)==(1) call :Exec_typeperf

:: Lists currently running processes with associated information (optional)
if (%FLG_TSK%)==(1) call :Exec_tasklist

if not "%NB%"=="%COUNT%" (
	echo PLEASE, WAIT %INTERVAL% SECS FOR THE NEXT STEP [%HH%:%MM%:%SS% LEFT] OR PRESS ENTER TO CONTINUE OR [CTRL-C] TO STOP...
	call :Sleep %INTERVAL%
	goto :loop
)
:: Displays a summary of the total distinct number of escalation and blocking locks
if exist %SCRIPTDIR%\display_sqllock.cmd call %SCRIPTDIR%\display_sqllock.cmd %file_log%
call :Display End of report
if exist %file_sql% del %file_sql%>NUL
if exist %file_adx% del %file_adx%>NUL
if exist %file_tmp% del %file_tmp%>NUL
if exist %file_adx%.old del %file_adx%.old>NUL
if exist %file_prf%.lst del %file_prf%.lst>NUL
if exist %file_tsk%.lst del %file_tsk%.lst>NUL
if exist %file_adx_sql% del %file_adx_sql%>NUL
set RET=0
goto:EOF
::#
::# End of Start_check_sqllock
::#************************************************************#

:Cre_check_sqllock
::#************************************************************#
::# Generates the monitoring SQL script for checking SQL lock
::#
 >%file_sql% echo -- SQL Script generated automatically in SQL version [%VER_SQL%] by the program "%dirname%\%~nx0".
>>%file_sql% echo -- %copyright% by %author% - All Rights Reserved.
>>%file_sql% echo --
>>%file_sql% echo set nocount on
>>%file_sql% echo:
if "%FLG_PSADX%"=="1" >>%file_sql% type %file_adx_sql%
>>%file_sql% echo:
>>%file_sql% echo if not object_id^('tempdb..#processes'^) is null drop table #processes;
>>%file_sql% echo:
>>%file_sql% echo select p.spid, p.login_time, p.ecid, p.sid, p.cpu, p.physical_io
>>%file_sql% echo into #processes
>>%file_sql% echo from sys.sysprocesses p
>>%file_sql% echo where p.spid ^<^> @@SPID  -- Exclude own process;
if defined LOGIN >>%file_sql% echo and   p.loginame = '%LOGIN%' -- Lists only for a login
if defined EXCL_LOGIN >>%file_sql% echo and   p.loginame not in ^('%EXCL_LOGIN%'^) -- Excludes logins
>>%file_sql% echo ;
>>%file_sql% echo PRINT ''
if defined LOGIN (
	call :Info_x3folder %LOGIN%
) else (
	for /F %%i in ('DIR /B %ADXDOS% ^| find /V "-" ^| find /V "_"') do if exist %ADXDOS%\%%i\REPORT if not "%%i" == "%DOSS_REF%" call :Info_x3folder %%i
)
>>%file_sql% echo PRINT ''
>>%file_sql% echo PRINT '+--------------+'
>>%file_sql% echo PRINT '^| Memory usage ^|'
>>%file_sql% echo PRINT '+--------------+'
>>%file_sql% echo PRINT ''
>>%file_sql% echo:
if %MAX_MEM% LEQ 65536 >>%file_sql% echo select left^(case database_id 
if %MAX_MEM% LEQ 65536 >>%file_sql% echo        when 32767 then 'others'  -- resourceDb
if %MAX_MEM% LEQ 65536 >>%file_sql% echo                   else DB_NAME^(database_id^) 
if %MAX_MEM% LEQ 65536 >>%file_sql% echo        end, 12^)                             AS 'DB Name',
if %MAX_MEM% LEQ 65536 >>%file_sql% echo        cast^(count^(row_count^)*8/1024 as int^) AS '  Size ^(MB^)'
if %MAX_MEM% LEQ 65536 >>%file_sql% echo from sys.dm_os_buffer_descriptors
if %MAX_MEM% LEQ 65536 >>%file_sql% echo group by database_id
if %MAX_MEM% LEQ 65536 >>%file_sql% echo union
if %MAX_MEM% LEQ 65536 >>%file_sql% echo select left^(' TOTAL', 10^),
if %MAX_MEM% LEQ 65536 >>%file_sql% echo        cast^(count^(row_count^)*8/1024 as int^)
if %MAX_MEM% LEQ 65536 >>%file_sql% echo from sys.dm_os_buffer_descriptors
if %MAX_MEM% LEQ 65536 >>%file_sql% echo union
>>%file_sql% echo select left^('  Max SQL', 10^)     AS 'Memory',
>>%file_sql% echo        cast^(value_in_use as int^) AS '  Size ^(MB^)'
>>%file_sql% echo from  sys.configurations
>>%file_sql% echo where  name = 'max server memory ^(MB^)'
>>%file_sql% echo union 
>>%file_sql% echo select left^('  Max SYS', 10^),
if "%VER_SQL%"=="11.0" >>%file_sql% echo        cast^(physical_memory_kb/1024 as int^)
if "%VER_SQL%"=="12.0" >>%file_sql% echo        cast^(physical_memory_kb/1024 as int^)
if "%VER_SQL%"=="13.0" >>%file_sql% echo        cast^(physical_memory_kb/1024 as int^)
if "%VER_SQL%"=="14.0" >>%file_sql% echo        cast^(physical_memory_kb/1024 as int^)
if not "%VER_SQL%"=="11.0" if not "%VER_SQL%"=="12.0" if not "%VER_SQL%"=="13.0" if not "%VER_SQL%"=="14.0" >>%file_sql% echo        cast^(physical_memory_kb/1024 as int^)
>>%file_sql% echo from sys.dm_os_sys_info
if "%VER_SQL%"=="11.0" >>%file_sql% echo union 
if "%VER_SQL%"=="11.0" >>%file_sql% echo select left^('  Free SYS', 10^),
if "%VER_SQL%"=="11.0" >>%file_sql% echo        cast^(available_physical_memory_kb/1024 as int^)
if "%VER_SQL%"=="11.0" >>%file_sql% echo from sys.dm_os_sys_memory
if "%VER_SQL%"=="12.0" >>%file_sql% echo union 
if "%VER_SQL%"=="12.0" >>%file_sql% echo select left^('  Free SYS', 10^),
if "%VER_SQL%"=="12.0" >>%file_sql% echo        cast^(available_physical_memory_kb/1024 as int^)
if "%VER_SQL%"=="12.0" >>%file_sql% echo from sys.dm_os_sys_memory
if "%VER_SQL%"=="13.0" >>%file_sql% echo union 
if "%VER_SQL%"=="13.0" >>%file_sql% echo select left^('  Free SYS', 10^),
if "%VER_SQL%"=="13.0" >>%file_sql% echo        cast^(available_physical_memory_kb/1024 as int^)
if "%VER_SQL%"=="13.0" >>%file_sql% echo from sys.dm_os_sys_memory
if "%VER_SQL%"=="14.0" >>%file_sql% echo union 
if "%VER_SQL%"=="14.0" >>%file_sql% echo select left^('  Free SYS', 10^),
if "%VER_SQL%"=="14.0" >>%file_sql% echo        cast^(available_physical_memory_kb/1024 as int^)
if "%VER_SQL%"=="14.0" >>%file_sql% echo from sys.dm_os_sys_memory
>>%file_sql% echo order by 1 desc;
>>%file_sql% echo:
>>%file_sql% echo PRINT ''
>>%file_sql% echo PRINT '+----------------+'
>>%file_sql% echo PRINT '^| Memory metrics ^|'
>>%file_sql% echo PRINT '+----------------+'
>>%file_sql% echo PRINT ''
>>%file_sql% echo:
>>%file_sql% echo select case c.counter_name
>>%file_sql% echo        when 'Total Server Memory ^(KB^)'   then '  Tot SQL'
>>%file_sql% echo        when 'Target Server Memory ^(KB^)'  then '  Max SQL'
>>%file_sql% echo        when 'Free Memory ^(KB^)'           then '  Free SQL'
>>%file_sql% echo        when 'Connection Memory ^(KB^)'     then 'Logins'
>>%file_sql% echo        when 'Lock Memory ^(KB^)'           then 'Locks'
>>%file_sql% echo        when 'Database Cache Memory ^(KB^)' then 'DB Cache'
>>%file_sql% echo        when 'SQL Cache Memory ^(KB^)'      then 'SQL Cache'
>>%file_sql% echo        when 'Optimizer Memory ^(KB^)'      then 'Optimizer' end AS 'Counter',
>>%file_sql% echo        cast^(c.cntr_value/1024.0 as int^)                       AS '  Size ^(MB^)'
>>%file_sql% echo from sys.dm_os_performance_counters c
>>%file_sql% echo where counter_name in ^('Total Server Memory ^(KB^)',
>>%file_sql% echo                      'Target Server Memory ^(KB^)',
>>%file_sql% echo 					   'Free Memory ^(KB^)',
>>%file_sql% echo 					   'Connection Memory ^(KB^)',
>>%file_sql% echo 					   'Lock Memory ^(KB^)',
>>%file_sql% echo 					   'Database Cache Memory ^(KB^)',
>>%file_sql% echo 					   'SQL Cache Memory ^(KB^)',
>>%file_sql% echo 					   'Optimizer Memory ^(KB^)'^)
>>%file_sql% echo union
>>%file_sql% echo select 'Isolation',
>>%file_sql% echo        cast^(sum^(isnull^(u.version_store_reserved_page_count,0^)^)*1.0/128 as int^)
>>%file_sql% echo from sys.dm_db_file_space_usage u
>>%file_sql% echo order by 1 desc;
>>%file_sql% echo:
>>%file_sql% echo PRINT ''
>>%file_sql% echo PRINT '+------------+'
>>%file_sql% echo PRINT '^| Temp usage ^|'
>>%file_sql% echo PRINT '+------------+'
>>%file_sql% echo PRINT ''
>>%file_sql% echo:
>>%file_sql% echo select s.session_id                                                                   AS 'SID',
>>%file_sql% echo        left^(s.host_process_id,6^)                                                      AS 'PID',
>>%file_sql% echo        left^(s.login_name, %LEN_LOGIN%^)                                                         AS 'Login Name',
if "%VER_SQL%"=="11.0" >>%file_sql% echo        left^(format^(s.login_time, '%FMT_DAT3%'^),17^)                             AS 'Login Time',
if "%VER_SQL%"=="12.0" >>%file_sql% echo        left^(format^(s.login_time, '%FMT_DAT3%'^),17^)                             AS 'Login Time',
if "%VER_SQL%"=="13.0" >>%file_sql% echo        left^(format^(s.login_time, '%FMT_DAT3%'^),17^)                             AS 'Login Time',
if "%VER_SQL%"=="14.0" >>%file_sql% echo        left^(format^(s.login_time, '%FMT_DAT3%'^),17^)                             AS 'Login Time',
if not "%VER_SQL%"=="11.0" if not "%VER_SQL%"=="12.0" if not "%VER_SQL%"=="13.0" if not "%VER_SQL%"=="14.0" >>%file_sql% echo        left^(convert^(varchar, s.login_time, %CNV_DATE%^)+' '+
if not "%VER_SQL%"=="11.0" if not "%VER_SQL%"=="12.0" if not "%VER_SQL%"=="13.0" if not "%VER_SQL%"=="14.0" >>%file_sql% echo              convert^(varchar, s.login_time, %CNV_TIME%^),17^)                             AS 'Login Time',
>>%file_sql% echo        left^(s.status, 10^)                                                             AS 'Status',
if "%VER_SQL%"=="11.0" >>%file_sql% echo        left^(format^(s.last_request_end_time, '%FMT_DAT3%'^),17^)                  AS 'Last Exec',
if "%VER_SQL%"=="12.0" >>%file_sql% echo        left^(format^(s.last_request_end_time, '%FMT_DAT3%'^),17^)                  AS 'Last Exec',
if "%VER_SQL%"=="13.0" >>%file_sql% echo        left^(format^(s.last_request_end_time, '%FMT_DAT3%'^),17^)                  AS 'Last Exec',
if "%VER_SQL%"=="14.0" >>%file_sql% echo        left^(format^(s.last_request_end_time, '%FMT_DAT3%'^),17^)                  AS 'Last Exec',
if not "%VER_SQL%"=="11.0" if not "%VER_SQL%"=="12.0" if not "%VER_SQL%"=="13.0" if not "%VER_SQL%"=="14.0" >>%file_sql% echo        left^(convert^(varchar, s.last_request_end_time, %CNV_DATE%^)+' '+
if not "%VER_SQL%"=="11.0" if not "%VER_SQL%"=="12.0" if not "%VER_SQL%"=="13.0" if not "%VER_SQL%"=="14.0" >>%file_sql% echo              convert^(varchar, s.last_request_end_time, %CNV_TIME%^),17^)                  AS 'Last Exec',
>>%file_sql% echo        left^(case when s.host_name = ''
>>%file_sql% echo                   then ^(case when c.client_net_address = '%IP_ADDRESS%' then '%COMPUTERNAME%'
>>%file_sql% echo 		   	                 else c.client_net_address end^)
>>%file_sql% echo                   else s.host_name end, 15^)                                           AS 'Host Name',
>>%file_sql% echo        case when c.client_net_address = '%IP_ADDRESS%' then 'MAIN' else 'OTHERS' end AS 'Type',
>>%file_sql% echo        s.total_elapsed_time                                                           AS 'Elapsed Time ^(s^)',
>>%file_sql% echo        s.cpu_time                                                                     AS 'CPU Time',
>>%file_sql% echo        s.memory_usage * 8                                                             AS 'Mem Used ^(KB^)',
>>%file_sql% echo        right^(replicate^(' ',10-len^(s.reads^)^)+cast^(s.reads as varchar^(10^)^),10^)          AS 'Nbr Reads',
>>%file_sql% echo        right^(replicate^(' ',10-len^(s.writes ^)^)+cast^(s.writes  as varchar^(10^)^),10^)      AS 'Nbr Writes',
>>%file_sql% echo        right^(replicate^(' ',10-len^(s.row_count^)^)+cast^(s.row_count as varchar^(10^)^),10^)  AS 'Row Count',
>>%file_sql% echo        u.user_objects_alloc_page_count * 8                                            AS 'Allocated User Objects ^(KB^)',
>>%file_sql% echo        u.user_objects_dealloc_page_count * 8                                          AS 'Deallocated User Objects ^(KB^)',
>>%file_sql% echo        u.internal_objects_alloc_page_count * 8                                        AS 'Allocated Internal Objects ^(KB^)',
>>%file_sql% echo        u.internal_objects_dealloc_page_count * 8                                      AS 'Deallocated Internal Objects ^(KB^)',
>>%file_sql% echo        left^(s.program_name, 50^)                                                       AS 'Program Name'
>>%file_sql% echo from sys.dm_db_session_space_usage u      WITH ^(NOLOCK^)
>>%file_sql% echo left outer join sys.dm_exec_connections c WITH ^(NOLOCK^) on ^(u.session_id = c.session_id^)
>>%file_sql% echo inner join sys.dm_exec_sessions s         WITH ^(NOLOCK^) on u.session_id = s.session_id
>>%file_sql% echo inner join sys.sysprocesses p             WITH ^(NOLOCK^) on p.spid = s.session_id
>>%file_sql% echo where DB_NAME^(p.dbid^) = 'tempdb'
>>%file_sql% echo and s.last_request_end_time IS NOT NULL;
>>%file_sql% echo:
>>%file_sql% echo PRINT ''
>>%file_sql% echo PRINT '+---------------+'
>>%file_sql% echo PRINT '^| Session usage ^|'
>>%file_sql% echo PRINT '+---------------+'
>>%file_sql% echo PRINT ''
>>%file_sql% echo:
>>%file_sql% echo select left^(case when s.host_name = ''
>>%file_sql% echo                  then ^(case when c.client_net_address = '%IP_ADDRESS%' then '%COMPUTERNAME%'
>>%file_sql% echo 			                   else c.client_net_address end^)
>>%file_sql% echo 		            else s.host_name end, 15^)                                         AS 'Host Name',
>>%file_sql% echo        case when c.client_net_address in ^('%IP_ADDRESS%', '^<local machine^>'^)
>>%file_sql% echo             then 'MAIN' else 'OTHERS' end                                             AS 'Type',
>>%file_sql% echo 	   left^(s.login_name, %LEN_LOGIN%^)                                                         AS 'Login Name',
>>%file_sql% echo        count^(s.session_id^)                                                            AS 'Session Count',
>>%file_sql% echo        sum^(case when p.status = 'sleeping'  then 1 else 0 end)                        AS 'Sleeping',
>>%file_sql% echo        sum^(case when p.status = 'running'   then 1 else 0 end)                        AS 'Running',
>>%file_sql% echo        sum^(case when p.status = 'suspended' then 1 else 0 end)                        AS 'Suspended',
>>%file_sql% echo        sum^(s.memory_usage * 8^)                                                        AS 'Mem Used ^(KB^)'
>>%file_sql% echo from sys.dm_exec_sessions s
>>%file_sql% echo inner join sys.sysprocesses p on p.spid = s.session_id
>>%file_sql% echo left outer join sys.dm_exec_connections c on s.session_id = c.session_id
>>%file_sql% echo where s.is_user_process = 1
>>%file_sql% echo and   s.program_name = '%PROG%'
>>%file_sql% echo and   s.session_id ^<^> @@spid
>>%file_sql% echo and  (s.login_name ^<^> 'sa' and s.login_name not like 'NT%%')
if defined LOGIN >>%file_sql% echo and   s.login_name = '%LOGIN%' -- Lists only for a login
if defined EXCL_LOGIN >>%file_sql% echo and   s.login_name not in ^('%EXCL_LOGIN%'^) -- Excludes logins 
>>%file_sql% echo group by c.client_net_address, s.host_name, s.login_name
>>%file_sql% echo order by 4 desc, 1, 2, 3;
>>%file_sql% echo:
>>%file_sql% echo PRINT ''
>>%file_sql% echo select case when c.client_net_address in ^('%IP_ADDRESS%', '^<local machine^>'^)
>>%file_sql% echo             then 'MAIN' else 'OTHERS' end                                             AS 'Type',
>>%file_sql% echo        count^(s.session_id^)                                                            AS 'Session Count'
>>%file_sql% echo from sys.dm_exec_sessions s
>>%file_sql% echo left outer join sys.dm_exec_connections c on s.session_id = c.session_id
>>%file_sql% echo where s.is_user_process = 1
>>%file_sql% echo and   s.program_name ='%PROG%'
>>%file_sql% echo and   s.session_id ^<^> @@spid
>>%file_sql% echo and  (s.login_name ^<^> 'sa' and s.login_name not like 'NT%%')
if defined LOGIN >>%file_sql% echo and   s.login_name = '%LOGIN%' -- Lists only for a login
if defined EXCL_LOGIN >>%file_sql% echo and   s.login_name not in ^('%EXCL_LOGIN%'^) -- Excludes logins
>>%file_sql% echo group by case when c.client_net_address in ^('%IP_ADDRESS%', '^<local machine^>'^) then 'MAIN' else 'OTHERS' end;
>>%file_sql% echo:
>>%file_sql% echo PRINT ''
>>%file_sql% echo PRINT '+-----------------+'
>>%file_sql% echo PRINT '^| Active sessions ^|'
>>%file_sql% echo PRINT '+-----------------+'
>>%file_sql% echo PRINT ''
>>%file_sql% echo:
>>%file_sql% echo select s.session_id                                                                   AS 'SID',
>>%file_sql% echo        left^(s.host_process_id,6^)                                                      AS 'PID',
>>%file_sql% echo        left^(s.login_name, %LEN_LOGIN%^)                                                         AS 'Login Name',
if "%VER_SQL%"=="11.0" >>%file_sql% echo        left^(format^(s.login_time, '%FMT_DAT3%'^),17^)                             AS 'Login Time',
if "%VER_SQL%"=="12.0" >>%file_sql% echo        left^(format^(s.login_time, '%FMT_DAT3%'^),17^)                             AS 'Login Time',
if "%VER_SQL%"=="13.0" >>%file_sql% echo        left^(format^(s.login_time, '%FMT_DAT3%'^),17^)                             AS 'Login Time',
if "%VER_SQL%"=="14.0" >>%file_sql% echo        left^(format^(s.login_time, '%FMT_DAT3%'^),17^)                             AS 'Login Time',
if not "%VER_SQL%"=="11.0" if not "%VER_SQL%"=="12.0" if not "%VER_SQL%"=="13.0" if not "%VER_SQL%"=="14.0" >>%file_sql% echo        left^(convert^(varchar, s.login_time, %CNV_DATE%^)+' '+
if not "%VER_SQL%"=="11.0" if not "%VER_SQL%"=="12.0" if not "%VER_SQL%"=="13.0" if not "%VER_SQL%"=="14.0" >>%file_sql% echo              convert^(varchar, s.login_time, %CNV_TIME%^),17^)                             AS 'Login Time',
>>%file_sql% echo        left^(s.status, 10^)                                                             AS 'Status',
if "%VER_SQL%"=="11.0" >>%file_sql% echo        left^(format^(s.last_request_end_time, '%FMT_DAT3%'^),17^)                  AS 'Last Exec',
if "%VER_SQL%"=="12.0" >>%file_sql% echo        left^(format^(s.last_request_end_time, '%FMT_DAT3%'^),17^)                  AS 'Last Exec',
if "%VER_SQL%"=="13.0" >>%file_sql% echo        left^(format^(s.last_request_end_time, '%FMT_DAT3%'^),17^)                  AS 'Last Exec',
if "%VER_SQL%"=="14.0" >>%file_sql% echo        left^(format^(s.last_request_end_time, '%FMT_DAT3%'^),17^)                  AS 'Last Exec',
if not "%VER_SQL%"=="11.0" if not "%VER_SQL%"=="12.0" if not "%VER_SQL%"=="13.0" if not "%VER_SQL%"=="14.0" >>%file_sql% echo        left^(convert^(varchar, s.last_request_end_time, %CNV_DATE%^)+' '+
if not "%VER_SQL%"=="11.0" if not "%VER_SQL%"=="12.0" if not "%VER_SQL%"=="13.0" if not "%VER_SQL%"=="14.0" >>%file_sql% echo              convert^(varchar, s.last_request_end_time, %CNV_TIME%^),17^)                  AS 'Last Exec',
>>%file_sql% echo        left^(case when s.host_name = ''
>>%file_sql% echo                   then ^(case when c.client_net_address = '%IP_ADDRESS%' then '%COMPUTERNAME%'
>>%file_sql% echo 		   	                    else c.client_net_address end^)
>>%file_sql% echo                   else s.host_name end, 15^)                                           AS 'Host Name',
>>%file_sql% echo        case when c.client_net_address = '%IP_ADDRESS%' then 'MAIN' else 'OTHERS' end  AS 'Type',
>>%file_sql% echo        s.total_elapsed_time/1000                                                      AS 'Elapsed Time ^(s^)',
>>%file_sql% echo        s.cpu_time                                                                     AS 'CPU Time',
>>%file_sql% echo        s.memory_usage * 8                                                             AS 'Mem Used ^(KB^)',
>>%file_sql% echo        right^(replicate^(' ',9-len^(s.reads^)^)+cast^(s.reads as varchar^(9^)^),9^)             AS 'Nbr Reads',
>>%file_sql% echo        right^(replicate^(' ',10-len^(s.writes ^)^)+cast^(s.writes  as varchar^(10^)^),10^)      AS 'Nbr Writes',
>>%file_sql% echo        right^(replicate^(' ',9-len^(s.row_count^)^)+cast^(s.row_count as varchar^(9^)^),9^)     AS 'Row Count',
>>%file_sql% echo        case when s.transaction_isolation_level = 1   then 'READ UNCOMMITTED' 
>>%file_sql% echo             when s.transaction_isolation_level = 2
>>%file_sql% echo              and d.is_read_committed_snapshot_on = 1 then 'READ COMMITTED SNAPSHOT' 
>>%file_sql% echo             when s.transaction_isolation_level = 2
>>%file_sql% echo              and d.is_read_committed_snapshot_on = 0 then 'READ COMMITTED' 
>>%file_sql% echo             when s.transaction_isolation_level = 3   then 'REPEATABLE READ' 
>>%file_sql% echo             when s.transaction_isolation_level = 4   then 'SERIALIZABLE' 
>>%file_sql% echo             when s.transaction_isolation_level = 5   then 'SNAPSHOT' else null end    AS 'Isolation Level',
>>%file_sql% echo        left^(s.program_name, 50^)                                                       AS 'Program Name'
>>%file_sql% echo from sys.dm_exec_sessions s                  WITH ^(NOLOCK^) 
>>%file_sql% echo left outer join sys.dm_exec_connections c    WITH ^(NOLOCK^) on ^(s.session_id = c.session_id^)
>>%file_sql% echo inner join sys.sysprocesses p                WITH ^(NOLOCK^) on p.spid = s.session_id
>>%file_sql% echo inner join sys.databases d                   WITH ^(NOLOCK^) on ^(d.database_id = p.dbid^)   
>>%file_sql% echo where s.is_user_process= 1
>>%file_sql% echo and   s.session_id ^<^> @@spid -- Excludes owner processes
>>%file_sql% echo and   s.status ^<^> 'sleeping' -- Lists only active processes
if defined LOGIN >>%file_sql% echo and   s.login_name = '%LOGIN%' -- Lists only for a login
if defined EXCL_LOGIN >>%file_sql% echo and   s.login_name not in ^('%EXCL_LOGIN%'^) -- Excludes logins
>>%file_sql% echo order by 1;
>>%file_sql% echo:
>>%file_sql% echo PRINT ''
>>%file_sql% echo PRINT '+------------------+'
>>%file_sql% echo PRINT '^| Active processes ^|'
>>%file_sql% echo PRINT '+------------------+'
>>%file_sql% echo PRINT ''
>>%file_sql% echo:
>>%file_sql% echo select p.spid                                                                         AS 'SID',
>>%file_sql% echo        left^(p.hostprocess,6^)                                                          AS 'PID',
>>%file_sql% echo        left^(p.loginame,%LEN_LOGIN%^)                                                          AS 'Login Name',
>>%file_sql% echo        left^(d.name, %LEN_DBNAME%^)                                                                AS 'DB Name',
>>%file_sql% echo        left^(p.status, 11^)                                                             AS 'Status',
>>%file_sql% echo        left^(case when p.blocked = 0 then '' else cast^(p.blocked as varchar^) end, 8^)   AS 'Blocking',
>>%file_sql% echo        p.waittime/1000                                                                AS 'Wait Time ^(s^)',
>>%file_sql% echo        left^(case when p.cmd = 'AWAITING COMMAND' then '' else p.cmd end, 7^)           AS 'Command',
if "%VER_SQL%"=="11.0" >>%file_sql% echo        left^(format^(p.last_batch,'%FMT_DAT3%'^), 17^)                             AS 'Last Exec',
if "%VER_SQL%"=="12.0" >>%file_sql% echo        left^(format^(p.last_batch,'%FMT_DAT3%'^), 17^)                             AS 'Last Exec',
if "%VER_SQL%"=="13.0" >>%file_sql% echo        left^(format^(p.last_batch,'%FMT_DAT3%'^), 17^)                             AS 'Last Exec',
if "%VER_SQL%"=="14.0" >>%file_sql% echo        left^(format^(p.last_batch,'%FMT_DAT3%'^), 17^)                             AS 'Last Exec',
if not "%VER_SQL%"=="11.0" if not  "%VER_SQL%"=="12.0" if not "%VER_SQL%"=="13.0" if not "%VER_SQL%"=="14.0" >>%file_sql% echo        left^(convert^(varchar, p.last_batch,%CNV_DATE%^)+' '+
if not "%VER_SQL%"=="11.0" if not  "%VER_SQL%"=="12.0" if not "%VER_SQL%"=="13.0" if not "%VER_SQL%"=="14.0" >>%file_sql% echo              convert^(varchar, p.last_batch,%CNV_TIME%^), 17^)                             AS 'Last Exec',
>>%file_sql% echo        p.cpu                                                                          AS 'CPU',
>>%file_sql% echo        p.physical_io                                                                  AS 'Physical IO',
>>%file_sql% echo        p.memusage * 8                                                                 AS 'Mem Used ^(KB^)',
>>%file_sql% echo        right^(replicate^(' ',9-len^(s.row_count^)^)+cast^(s.row_count as varchar^(9^)^),9^)     AS 'Row Count'--,
>>%file_sql% echo        --char(13)+char(10)+cast^(t.text AS CHAR^(%LEN_SQLT%^)^)+char(13)+char(10)                AS 'SQL Text'
>>%file_sql% echo from sys.sysprocesses p
>>%file_sql% echo inner join  sys.databases d        on d.database_id = p.dbid
>>%file_sql% echo inner join  sys.dm_exec_sessions s on s.session_id = p.spid
>>%file_sql% echo cross apply sys.dm_exec_sql_text^(p.sql_handle^) t   
>>%file_sql% echo where s.is_user_process = 1 -- Excludes system processes
>>%file_sql% echo and   s.session_id ^<^> @@spid -- Excludes owner processes
if defined LOGIN >>%file_sql% echo and   s.login_name = '%LOGIN%' -- Lists only for a login
if defined EXCL_LOGIN >>%file_sql% echo and   s.login_name not in ^('%EXCL_LOGIN%'^) -- Excludes logins
>>%file_sql% echo and   p.status ^<^> 'sleeping' -- Lists only active processes
>>%file_sql% echo order by 1;
>>%file_sql% echo:
>>%file_sql% echo use %SQLS7_SID%
if not "%VER_SQL%"=="9.0" if (%NB%) == (1) call :List_lock_disable
if (%NB%) == (1)       call :Lock_escalation_waits
if (%NB%) == (%COUNT%) call :Lock_escalation_waits
>>%file_sql% echo:
>>%file_sql% echo PRINT ''
>>%file_sql% echo PRINT '+--------------------+'
>>%file_sql% echo PRINT '^| Detecting blocking ^|'
>>%file_sql% echo PRINT '+--------------------+'
>>%file_sql% echo PRINT ''
>>%file_sql% echo:
>>%file_sql% echo select left^(l.resource_type,15^)                                                            AS 'Lock Type',
>>%file_sql% echo        left^(l.request_mode,8^)                                                              AS 'Lock Mode',
>>%file_sql% echo        left^(DB_NAME^(l.resource_database_id^),8^)                                             AS 'DB Name',
>>%file_sql% echo        left^(o.name, 15^)                                                                    AS 'Object Name',
>>%file_sql% echo        l.request_session_id                                                                AS 'Waiter SID',
>>%file_sql% echo        w.blocking_session_id                                                               AS 'Blocker SID',
>>%file_sql% echo        w.wait_duration_ms/1000                                                             AS 'Wait time ^(s^)',
>>%file_sql% echo        left^(w.wait_type, 20^)                                                               AS 'Wait type',
>>%file_sql% echo        char^(13^)+char^(10^)+char^(13^)+char^(10^)+cast^(^(select substring^(wt.text,^(r.statement_start_offset/2^)+1,
>>%file_sql% echo                    ^(case when r.statement_end_offset = -1
>>%file_sql% echo                          then len^(CONVERT^(nvarchar^(max^), wt.text^)^) * 2
>>%file_sql% echo                          else r.statement_end_offset end - r.statement_start_offset^)^)
>>%file_sql% echo              from sys.dm_exec_requests r
>>%file_sql% echo              cross apply sys.dm_exec_sql_text^(r.sql_handle^) wt
>>%file_sql% echo              where r.session_id = l.request_session_id^) AS CHAR^(%LEN_SQLT%^)^)                      AS 'Waiter SQL',
>>%file_sql% echo        char^(13^)+char^(10^)+char^(13^)+char^(10^)+cast^(^(select substring ^(bt.text, charindex^('Select', bt.text^), %LEN_SQLT%^) from sys.sysprocesses p
>>%file_sql% echo              cross apply sys.dm_exec_sql_text^(p.sql_handle^) bt
>>%file_sql% echo              where p.spid = w.blocking_session_id^)  AS CHAR^(%LEN_SQLT%^)^)+char(13)+char(10)        AS 'Blocker SQL'
>>%file_sql% echo from sys.dm_tran_locks l
>>%file_sql% echo inner join sys.dm_os_waiting_tasks w on l.lock_owner_address = w.resource_address
>>%file_sql% echo left  join sys.objects o             on l.resource_associated_entity_id = o.object_id and l.resource_type = 'OBJECT';
>>%file_sql% echo:
>>%file_sql% echo PRINT ''
>>%file_sql% echo PRINT '+------------------+'
>>%file_sql% echo PRINT '^| Blocked sessions ^|'
>>%file_sql% echo PRINT '+------------------+'
>>%file_sql% echo PRINT ''
>>%file_sql% echo:
>>%file_sql% echo select s.session_id                                 AS 'SID',
>>%file_sql% echo        cast^(s.host_process_id as char^(6^)^)         AS 'PID',
>>%file_sql% echo        left^(s.login_name,%LEN_LOGIN%^)                        AS 'Login Name',
>>%file_sql% echo        left^(l.resource_type,15^)                     AS 'Lock Type',
>>%file_sql% echo        left^(l.request_mode,8^)                       AS 'Lock Mode',
>>%file_sql% echo        left^(DB_NAME^(l.resource_database_id^),%LEN_DBNAME%^)      AS 'DB Name',
>>%file_sql% echo        w.blocking_session_id                        AS 'Blocking SID',
>>%file_sql% echo        char^(13^)+char^(10^)+cast^(substring^(t1.text, ^(sc1.statement_start_offset/2^)+1, 
>>%file_sql% echo                ^(^(case sc1.statement_end_offset
>>%file_sql% echo   	             when -1 then datalength^(t1.text^)
>>%file_sql% echo                       else sc1.statement_end_offset end
>>%file_sql% echo                     - sc1.statement_start_offset^)/2^)+1^) as char^(%LEN_SQLT%^)^)+char^(13^)+char^(10^) AS 'SQL Text Request',
>>%file_sql% echo        char^(13^)+char^(10^)+cast^(substring^(t2.text, ^(sc2.statement_start_offset/2^)+1, 
>>%file_sql% echo                ^(^(case sc2.statement_end_offset
>>%file_sql% echo   	             when -1 then datalength^(t2.text^)
>>%file_sql% echo                       else sc2.statement_end_offset end
>>%file_sql% echo                     - sc2.statement_start_offset^)/2^)+1^) as char^(%LEN_SQLT%^)^)+char^(13^)+char^(10^) AS 'SQL Text Blocking'
::>>%file_sql% echo        case when w.blocking_session_id ^<^> ''
::>>%file_sql% echo        then '**** BLOCKING LOCK DETECTED !! ****'
::>>%file_sql% echo        else '' end                                 AS 'Diagnostic'
>>%file_sql% echo from sys.dm_tran_locks l
>>%file_sql% echo inner join  sys.dm_os_waiting_tasks w  on w.resource_address = l.lock_owner_address
>>%file_sql% echo inner join  sys.dm_exec_connections c1 on c1.session_id      = l.request_session_id
>>%file_sql% echo inner join  sys.dm_exec_connections c2 on c2.session_id      = w.blocking_session_id
>>%file_sql% echo inner join  sys.dm_exec_sessions    s  on s.session_id       = l.request_session_id
>>%file_sql% echo cross apply sys.dm_exec_sql_text^(c1.most_recent_sql_handle^) t1
>>%file_sql% echo cross apply sys.dm_exec_sql_text^(c2.most_recent_sql_handle^) t2
>>%file_sql% echo inner join sys.dm_exec_query_stats sc1 on sc1.sql_handle = c1.most_recent_sql_handle
>>%file_sql% echo inner join sys.dm_exec_query_stats sc2 on sc2.sql_handle = c2.most_recent_sql_handle;
>>%file_sql% echo:
>>%file_sql% echo PRINT ''
>>%file_sql% echo PRINT '+---------------+'
>>%file_sql% echo PRINT '^| Blocking tree ^|'
>>%file_sql% echo PRINT '+---------------+'
>>%file_sql% echo:
>>%file_sql% echo if exists^(
>>%file_sql% echo select 'SID=['+cast^(r.blocking_session_id as varchar^)+'], PID=['+
>>%file_sql% echo         left^(isnull^(^(select p1.hostprocess from sys.sysprocesses p1 where p1.spid = r.blocking_session_id^),''^), 5^)+'] ^> '+
>>%file_sql% echo 	   'SID=['+cast^(p.spid as varchar^)+'], PID=['+left^(p.hostprocess, 5^)+']'
>>%file_sql% echo from sys.dm_exec_requests r
>>%file_sql% echo join sys.dm_exec_sessions s on s.session_id = r.session_id
>>%file_sql% echo join sys.sysprocesses p     on p.spid       = s.session_id 
>>%file_sql% echo cross apply sys.dm_exec_sql_text ^(r.sql_handle^) st
>>%file_sql% echo where s.is_user_process= 1 -- Excludes system processes
>>%file_sql% echo and r.blocking_session_id ^> 0
>>%file_sql% echo and   s.session_id ^<^> @@spid -- Excludes owner processes
>>%file_sql% echo ^)
>>%file_sql% echo select 'SID=['+cast^(r.blocking_session_id as varchar^)+'], PID=['+
>>%file_sql% echo         left^(isnull^(^(select p1.hostprocess from sys.sysprocesses p1 where p1.spid = r.blocking_session_id^),''^), 5^)+'] ^> '+
>>%file_sql% echo 	   'SID=['+cast^(p.spid as varchar^)+'], PID=['+left^(p.hostprocess, 5^)+']'
>>%file_sql% echo from sys.dm_exec_requests r
>>%file_sql% echo join sys.dm_exec_sessions s on s.session_id = r.session_id
>>%file_sql% echo join sys.sysprocesses p     on p.spid       = s.session_id 
>>%file_sql% echo cross apply sys.dm_exec_sql_text ^(r.sql_handle^) st
>>%file_sql% echo where s.is_user_process= 1 -- Excludes system processes
>>%file_sql% echo and r.blocking_session_id ^> 0
>>%file_sql% echo and   s.session_id ^<^> @@spid -- Excludes owner processes;
>>%file_sql% echo:
>>%file_sql% echo if exists^(
>>%file_sql% echo select 'SID=['+cast^(r.blocking_session_id as varchar^)+'], PID=['+
>>%file_sql% echo         left^(isnull^(^(select p1.hostprocess from sys.sysprocesses p1 where p1.spid = r.blocking_session_id^),''^), 5^)+'] ^> '+
>>%file_sql% echo 	   'SID=['+cast^(p.spid as varchar^)+'], PID=['+left^(p.hostprocess, 5^)+']'
>>%file_sql% echo from sys.dm_exec_requests r
>>%file_sql% echo join sys.dm_exec_sessions s on s.session_id = r.session_id
>>%file_sql% echo join sys.sysprocesses p     on p.spid       = s.session_id 
>>%file_sql% echo cross apply sys.dm_exec_sql_text ^(r.sql_handle^) st
>>%file_sql% echo where s.is_user_process= 1 -- Excludes system processes
>>%file_sql% echo and r.blocking_session_id ^> 0
>>%file_sql% echo and   s.session_id ^<^> @@spid -- Excludes owner processes
>>%file_sql% echo ^)
>>%file_sql% echo select replicate^('-', 44^)+char^(13^)+char^(10^)+
>>%file_sql% echo        'WARNING: THE SESSION IDENTIFIED BY SID=['+cast^(r.blocking_session_id as varchar^)+'], PID=['+
>>%file_sql% echo         left^(isnull^(^(select p1.hostprocess from sys.sysprocesses p1 where p1.spid = r.blocking_session_id^),''^), 5^)+']'+char^(13^)+char^(10^)+
if "%VER_SQL%"=="11.0" >>%file_sql% echo 	      'CONNECTED SINCE ['+left^(format^(s.login_time, '%FMT_DAT3%'^), 17^)+'] TO THE X3 FOLDER=['+left^(p.loginame, 10^)+']'+char^(13^)+char^(10^)+
if "%VER_SQL%"=="12.0" >>%file_sql% echo 	      'CONNECTED SINCE ['+left^(format^(s.login_time, '%FMT_DAT3%'^), 17^)+'] TO THE X3 FOLDER=['+left^(p.loginame, 10^)+']'+char^(13^)+char^(10^)+
if "%VER_SQL%"=="13.0" >>%file_sql% echo 	      'CONNECTED SINCE ['+left^(format^(s.login_time, '%FMT_DAT3%'^), 17^)+'] TO THE X3 FOLDER=['+left^(p.loginame, 10^)+']'+char^(13^)+char^(10^)+
if "%VER_SQL%"=="14.0" >>%file_sql% echo 	      'CONNECTED SINCE ['+left^(format^(s.login_time, '%FMT_DAT3%'^), 17^)+'] TO THE X3 FOLDER=['+left^(p.loginame, 10^)+']'+char^(13^)+char^(10^)+
if not "%VER_SQL%"=="11.0" if not "%VER_SQL%"=="12.0" if not "%VER_SQL%"=="13.0" if not "%VER_SQL%"=="14.0" >>%file_sql% echo        'CONNECTED SINCE ['+left^(convert^(varchar, s.login_time, %CNV_DATE%^)+' '+
if not "%VER_SQL%"=="11.0" if not "%VER_SQL%"=="12.0" if not "%VER_SQL%"=="13.0" if not "%VER_SQL%"=="14.0" >>%file_sql% echo              convert^(varchar, s.login_time, %CNV_TIME%^), 17^)+'] TO THE X3 FOLDER=['+left^(p.loginame, 10^)+']'+char^(13^)+char^(10^)+
>>%file_sql% echo        'IS BLOCKING ANOTHER SESSION SINCE IDENTIFIED BY SID=['+cast^(p.spid as varchar^)+'], PID=['+left^(p.hostprocess, 5^)+'] DURING '+
>>%file_sql% echo 	   cast^(cast^(r.wait_time/1000 as int^) as varchar^)+' SECS.' AS 'Message'
>>%file_sql% echo from sys.dm_exec_requests r
>>%file_sql% echo join sys.dm_exec_sessions s on s.session_id = r.session_id
>>%file_sql% echo join sys.sysprocesses p     on p.spid       = s.session_id 
>>%file_sql% echo cross apply sys.dm_exec_sql_text ^(r.sql_handle^) st
>>%file_sql% echo where s.is_user_process= 1 -- Excludes system processes
>>%file_sql% echo and r.blocking_session_id ^> 0
>>%file_sql% echo and   s.session_id ^<^> @@spid -- Excludes owner processes
>>%file_sql% echo order by 1;
>>%file_sql% echo:
>>%file_sql% echo if exists^(
>>%file_sql% echo select 'SID=['+cast^(r.blocking_session_id as varchar^)+'], PID=['+
>>%file_sql% echo         left^(isnull^(^(select p1.hostprocess from sys.sysprocesses p1 where p1.spid = r.blocking_session_id^),''^), 5^)+'] ^> '+
>>%file_sql% echo 	   'SID=['+cast^(p.spid as varchar^)+'], PID=['+left^(p.hostprocess, 5^)+']'
>>%file_sql% echo from sys.dm_exec_requests r
>>%file_sql% echo join sys.dm_exec_sessions s on s.session_id = r.session_id
>>%file_sql% echo join sys.sysprocesses p     on p.spid       = s.session_id 
>>%file_sql% echo cross apply sys.dm_exec_sql_text ^(r.sql_handle^) st
>>%file_sql% echo where s.is_user_process= 1 -- Excludes system processes
>>%file_sql% echo and r.blocking_session_id ^> 0
>>%file_sql% echo and   s.session_id ^<^> @@spid -- Excludes owner processes
>>%file_sql% echo ^)
>>%file_sql% echo PRINT ' %ADXDIR%\bin\env.bat'
>>%file_sql% echo if exists^(
>>%file_sql% echo select 'SID=['+cast^(r.blocking_session_id as varchar^)+'], PID=['+
>>%file_sql% echo         left^(isnull^(^(select p1.hostprocess from sys.sysprocesses p1 where p1.spid = r.blocking_session_id^),''^), 5^)+'] ^> '+
>>%file_sql% echo 	   'SID=['+cast^(p.spid as varchar^)+'], PID=['+left^(p.hostprocess, 5^)+']'
>>%file_sql% echo from sys.dm_exec_requests r
>>%file_sql% echo join sys.dm_exec_sessions s on s.session_id = r.session_id
>>%file_sql% echo join sys.sysprocesses p     on p.spid       = s.session_id 
>>%file_sql% echo cross apply sys.dm_exec_sql_text ^(r.sql_handle^) st
>>%file_sql% echo where s.is_user_process= 1 -- Excludes system processes
>>%file_sql% echo and r.blocking_session_id ^> 0
>>%file_sql% echo and   s.session_id ^<^> @@spid -- Excludes owner processes
>>%file_sql% echo ^)
>>%file_sql% echo select distinct '%ADXDIR%\bin\killadx.exe -9 '+left^(isnull^(^(select p1.hostprocess from sys.sysprocesses p1 where p1.spid = r.blocking_session_id^),''^), 5^) AS 'X3 COMMAND TO KILL EACH BLOCKING SESSION'
>>%file_sql% echo from sys.dm_exec_requests r
>>%file_sql% echo join sys.dm_exec_sessions s on s.session_id = r.session_id
>>%file_sql% echo join sys.sysprocesses p     on p.spid       = s.session_id 
>>%file_sql% echo cross apply sys.dm_exec_sql_text ^(r.sql_handle^) st
>>%file_sql% echo where s.is_user_process= 1 -- Excludes system processes
>>%file_sql% echo and r.blocking_session_id ^> 0
>>%file_sql% echo and   s.session_id ^<^> @@spid -- Excludes owner processes
>>%file_sql% echo order by 1;
>>%file_sql% echo:
>>%file_sql% echo if exists^(
>>%file_sql% echo select 'SID=['+cast^(r.blocking_session_id as varchar^)+'], PID=['+
>>%file_sql% echo         left^(isnull^(^(select p1.hostprocess from sys.sysprocesses p1 where p1.spid = r.blocking_session_id^),''^), 5^)+'] ^> '+
>>%file_sql% echo 	   'SID=['+cast^(p.spid as varchar^)+'], PID=['+left^(p.hostprocess, 5^)+']'
>>%file_sql% echo from sys.dm_exec_requests r
>>%file_sql% echo join sys.dm_exec_sessions s on s.session_id = r.session_id
>>%file_sql% echo join sys.sysprocesses p     on p.spid       = s.session_id 
>>%file_sql% echo cross apply sys.dm_exec_sql_text ^(r.sql_handle^) st
>>%file_sql% echo where s.is_user_process= 1 -- Excludes system processes
>>%file_sql% echo and r.blocking_session_id ^> 0
>>%file_sql% echo and   s.session_id ^<^> @@spid -- Excludes owner processes
>>%file_sql% echo ^)
>>%file_sql% echo select distinct left^('kill '+cast^(r.blocking_session_id as varchar^)+';',10^) AS 'SQL COMMAND TO KILL EACH BLOCKING SESSION'
>>%file_sql% echo from sys.dm_exec_requests r
>>%file_sql% echo join sys.dm_exec_sessions s on s.session_id = r.session_id
>>%file_sql% echo join sys.sysprocesses p     on p.spid       = s.session_id 
>>%file_sql% echo cross apply sys.dm_exec_sql_text ^(r.sql_handle^) st
>>%file_sql% echo where s.is_user_process= 1 -- Excludes system processes
>>%file_sql% echo and r.blocking_session_id ^> 0
>>%file_sql% echo and   s.session_id ^<^> @@spid -- Excludes owner processes
>>%file_sql% echo order by 1;
>>%file_sql% echo:
>>%file_sql% echo PRINT ''
>>%file_sql% echo PRINT '+--------------------+'
>>%file_sql% echo PRINT '^| Blocking processes ^|'
>>%file_sql% echo PRINT '+--------------------+'
>>%file_sql% echo PRINT ''
>>%file_sql% echo:
>>%file_sql% echo select p.spid                                                                                                           AS 'SID',
>>%file_sql% echo        left^(p.hostprocess,6^)                                                                                            AS 'PID',
::>>%file_sql% echo        left^(DB_NAME^(r.database_id^),%LEN_DBNAME%^)                                                                        AS 'DB Name',
>>%file_sql% echo        left^(p.loginame,%LEN_LOGIN%^)                                                                                              AS 'Login Name',
>>%file_sql% echo        left^(case when r.blocking_session_id = 0 then '' else cast^(r.blocking_session_id as varchar^) end, 11^)            AS 'Blocking SID',
>>%file_sql% echo        isnull((select p1.hostprocess from sys.sysprocesses p1 where p1.spid = r.blocking_session_id),'')                AS 'Blocking PID',
>>%file_sql% echo        right^(replicate(' ',8^)  + case when r.cpu_time      = 0 then '' else cast^(r.cpu_time as varchar^)       end, 8^)   AS 'CPU Time',
>>%file_sql% echo        right^(replicate(' ',10^) + case when r.reads         = 0 then '' else cast^(r.reads as varchar^)         end, 10^)   AS 'Phys.Reads',
>>%file_sql% echo        right^(replicate(' ',11^) + case when r.writes        = 0 then '' else cast^(r.writes as varchar^)        end, 11^)   AS 'Phys.Writes',
>>%file_sql% echo        right^(replicate(' ',9^)  + case when r.logical_reads = 0 then '' else cast^(r.logical_reads as varchar^) end,  9^)   AS 'Log.Reads',
>>%file_sql% echo 	   cast^(r.wait_time/1000 as int^)                                                                                    AS 'Wait Time ^(s)',
>>%file_sql% echo        case when OBJECT_NAME^(st.objectid, st.dbid^) is NULL then '' else left^(OBJECT_NAME^(st.objectid, st.dbid), 15^) end AS 'Object Name',
>>%file_sql% echo        left^(case when r.blocking_session_id ^> 0 and r.wait_time/1000 ^>=%LCK_TIME%
>>%file_sql% echo                  then '**** BLOCKING LOCK DETECTED SINCE '+cast^(r.wait_time/1000 as varchar(4)^) +' SECS ('+
>>%file_sql% echo                       cast^(r.blocking_session_id as varchar^(5))+':'+
>>%file_sql% echo                       cast((select p1.hostprocess from sys.sysprocesses p1
>>%file_sql% echo                               where p1.spid = r.blocking_session_id^) as varchar^(5))+'^>'+
>>%file_sql% echo                       cast^(p.spid as varchar^(5))+':'+
>>%file_sql% echo                       cast^(p.hostprocess as varchar^(5))+') !! ****'
>>%file_sql% echo             else '' end, 70^)                                                                                            AS 'Diagnostic',
>>%file_sql% echo        left^(s.program_name, 35^)                                                                                         AS 'Program Name',
>>%file_sql% echo        char^(13)+char^(10)+cast^(substring^(st.text, ^(r.statement_start_offset/2)+1,
>>%file_sql% echo 	                  ((case r.statement_end_offset when -1
>>%file_sql% echo 	                    then DATALENGTH^(st.text^)
>>%file_sql% echo                         else r.statement_end_offset  end -
>>%file_sql% echo                              r.statement_start_offset)/2)+1^) AS CHAR^(%LEN_SQLT%^)^)+char^(13)+char^(10^)                            AS 'SQL Text'
>>%file_sql% echo from sys.dm_exec_requests r
>>%file_sql% echo join sys.dm_exec_sessions s on s.session_id = r.session_id
>>%file_sql% echo join sys.sysprocesses p     on p.spid       = s.session_id 
>>%file_sql% echo cross apply sys.dm_exec_sql_text ^(r.sql_handle^) st
>>%file_sql% echo where s.is_user_process= 1 -- Excludes system processes
if defined LOGIN >>%file_sql% echo and   s.login_name = '%LOGIN%' -- Lists only for a login
if defined EXCL_LOGIN >>%file_sql% echo and   s.login_name not in ^('%EXCL_LOGIN%'^) -- Excludes logins 
>>%file_sql% echo and   s.session_id ^<^> @@spid -- Excludes owner processes;
>>%file_sql% echo:
>>%file_sql% echo PRINT ''
>>%file_sql% echo PRINT '+----------------+'
>>%file_sql% echo PRINT '^| Locked objects ^|'
>>%file_sql% echo PRINT '+----------------+'
>>%file_sql% echo PRINT ''
>>%file_sql% echo:
>>%file_sql% echo select distinct s.session_id                                                          AS 'SID',
>>%file_sql% echo        cast^(s.host_process_id as char^(6^)^)                                             AS 'PID',
>>%file_sql% echo        left^(s.login_name,%LEN_LOGIN%^)                                                          AS 'Login Name',
>>%file_sql% echo        left^(l.resource_type,15^)                                                       AS 'Lock Type',
>>%file_sql% echo        left^(l.request_mode,8^)                                                         AS 'Lock Mode',
>>%file_sql% echo        left^(case when l.request_status = 'GRANT' then '' else l.request_status end,8^) AS 'Status',
>>%file_sql% echo        --left^(l.request_owner_type,11^)                                                AS 'Request Type',
>>%file_sql% echo        --left^(t.name,16^)                                                              AS 'Transaction Name',
if "%VER_SQL%"=="11.0" >>%file_sql% echo 	     left^(format^(t.transaction_begin_time, '%FMT_DAT3%'^), 17^)              AS 'Begin Time',
if "%VER_SQL%"=="12.0" >>%file_sql% echo 	     left^(format^(t.transaction_begin_time, '%FMT_DAT3%'^), 17^)              AS 'Begin Time',
if "%VER_SQL%"=="13.0" >>%file_sql% echo 	     left^(format^(t.transaction_begin_time, '%FMT_DAT3%'^), 17^)              AS 'Begin Time',
if "%VER_SQL%"=="14.0" >>%file_sql% echo 	     left^(format^(t.transaction_begin_time, '%FMT_DAT3%'^), 17^)              AS 'Begin Time',
if not "%VER_SQL%"=="11.0" if not "%VER_SQL%"=="12.0" if not "%VER_SQL%"=="13.0" if not "%VER_SQL%"=="14.0" >>%file_sql% echo        left^(convert^(varchar, t.transaction_begin_time, %CNV_DATE%^)+' '+
if not "%VER_SQL%"=="11.0" if not "%VER_SQL%"=="12.0" if not "%VER_SQL%"=="13.0" if not "%VER_SQL%"=="14.0" >>%file_sql% echo             convert^(varchar, t.transaction_begin_time, %CNV_TIME%^), 17^)                        AS 'Begin Time',
>>%file_sql% echo        datediff^(ss, t.transaction_begin_time, GETDATE^(^)^)                              AS 'Duration ^(s^)',
>>%file_sql% echo        left^(coalesce^(o.name, po.name^), 16^)                                            AS 'Object Name',
>>%file_sql% echo        left^(case when pi.name is NULL then '' else pi.name end, 16^)                   AS 'Index Name',
>>%file_sql% echo        left^(case when l.resource_type  = 'OBJECT'
>>%file_sql% echo                   and l.request_mode = 'X'
>>%file_sql% echo                   and l.request_status = 'GRANT'
>>%file_sql% echo             then '**** LOCK ESCALATION DETECTED ^('+
>>%file_sql% echo             cast(s.session_id as varchar^)+':'+cast(s.host_process_id as varchar^(5^))+'^>'+
>>%file_sql% echo          	  coalesce^(o.name, po.name^)+'^) !! ****' else '' end, 60^)                  AS 'Diagnostic'
>>%file_sql% echo from sys.dm_tran_locks l
>>%file_sql% echo inner join sys.dm_exec_sessions s            on l.request_session_id = s.session_id
>>%file_sql% echo left  join sys.dm_tran_active_transactions t on l.request_owner_id = t.transaction_id and l.request_owner_type = 'TRANSACTION'
>>%file_sql% echo left  join sys.objects o                     on l.resource_associated_entity_id = o.object_id and l.resource_type = 'OBJECT'
>>%file_sql% echo left  join sys.partitions p                  on l.resource_associated_entity_id = p.hobt_id   and  l.resource_type IN ^('PAGE', 'KEY', 'RID', 'HOBT'^)
>>%file_sql% echo left  join sys.objects po                    on p.object_id = po.object_id
>>%file_sql% echo left  join sys.indexes pi                    on p.object_id = pi.object_id and p.index_id = pi.index_id
>>%file_sql% echo where s.is_user_process= 1 -- Excludes system processes
>>%file_sql% echo and   s.session_id ^<^> @@spid -- Excludes owner processes
if defined LOGIN >>%file_sql% echo and   s.login_name = '%LOGIN%' -- Lists only for a login
if defined EXCL_LOGIN >>%file_sql% echo and   s.login_name not in ^('%EXCL_LOGIN%'^) -- Excludes logins
>>%file_sql% echo and   l.request_mode in ^('U', 'X'^) -- Includes only Update and Exclusive lock mode;
::>>%file_sql% echo order by s.session_id, o.name, pi.name;
>>%file_sql% echo:
>>%file_sql% echo PRINT ''
>>%file_sql% echo PRINT '+--------------+'
>>%file_sql% echo PRINT '^| Active locks ^|'
>>%file_sql% echo PRINT '+--------------+'
>>%file_sql% echo PRINT ''
>>%file_sql% echo:
>>%file_sql% echo select right^(replicate^(' ',6) + cast^(l.request_session_id as varchar^), 6^)                                  AS 'SID',
>>%file_sql% echo        cast^(max^(s.host_process_id^) as char^(6^)^)                                                             AS 'PID',
>>%file_sql% echo        left^(max^(s.login_name^), 15^)                                                                         AS 'Login Name',
>>%file_sql% echo 	   right^(replicate^(' ',14^) +
>>%file_sql% echo              case when sum^(case l.resource_type when 'RID' then 1 else 0 end^) = 0 then ''
>>%file_sql% echo                   else cast^(sum^(case l.resource_type when 'RID' then 1 else 0 end^) as varchar^) end, 14^)    AS 'Row Lock Count',
>>%file_sql% echo 	   right^(replicate^(' ',14^) +
>>%file_sql% echo              case when sum^(case l.resource_type when 'KEY' then 1 else 0 end^) = 0 then ''
>>%file_sql% echo                   else cast^(sum^(case l.resource_type when 'KEY' then 1 else 0 end^) as varchar^) end, 14^)    AS 'Key Lock Count',
>>%file_sql% echo 	   right^(replicate^(' ',15^) +
>>%file_sql% echo              case when sum^(case l.resource_type when 'PAGE' then 1 else 0 end^) = 0 then ''
>>%file_sql% echo                   else cast^(sum^(case l.resource_type when 'PAGE' then 1 else 0 end^) as varchar^) end, 15^)   AS 'Page Lock Count',
>>%file_sql% echo 	   right^(replicate^(' ',16^) +
>>%file_sql% echo              case when sum^(case l.resource_type when 'OBJECT' then 1 else 0 end^) = 0 then ''
>>%file_sql% echo                   else cast^(sum^(case l.resource_type when 'OBJECT' then 1 else 0 end^) as varchar^) end, 16^) AS 'Table Lock Count',
>>%file_sql% echo        left^(max^(isnull^(o.name,' '^)^), %LEN_TABLE%^)                                                                   AS 'Object Name',
>>%file_sql% echo        left^(max^(isnull^(i.name,' '^)^), %LEN_INDEX%^)                                                                   AS 'Index Name'
>>%file_sql% echo from sys.dm_tran_locks l
>>%file_sql% echo join sys.dm_exec_sessions s on s.session_id = l.request_session_id 
>>%file_sql% echo left join sys.partitions p on l.resource_associated_entity_id = p.hobt_id and l.resource_type IN ^('PAGE', 'KEY', 'RID', 'HOBT'^)
>>%file_sql% echo left join sys.objects o    on o.object_id = l.resource_associated_entity_id and l.resource_type = 'OBJECT'
>>%file_sql% echo left join sys.indexes i    on o.object_id = l.resource_associated_entity_id and p.index_id = p.index_id
>>%file_sql% echo where l.request_session_id ^> 50
>>%file_sql% echo and   l.resource_type IN ^('RID', 'KEY', 'PAGE', 'OBJECT'^)
>>%file_sql% echo and   l.request_mode = 'X'
if defined LOGIN >>%file_sql% echo and   s.login_name = '%LOGIN%' -- Lists only for a login 
if defined EXCL_LOGIN >>%file_sql% echo and   s.login_name not in ^('%EXCL_LOGIN%'^) -- Excludes logins
>>%file_sql% echo group by l.request_session_id;
>>%file_sql% echo:
>>%file_sql% echo PRINT ''
>>%file_sql% echo PRINT '+--------------------+'
if not (%NB%)==(1) if not (%NB%)==(%COUNT%) if (%FLG_ALL%)==(1) >>%file_sql% echo PRINT '^| ALL Opened cursors ^|'
if not (%NB%)==(1) if not (%NB%)==(%COUNT%) if (%FLG_ALL%)==(0) >>%file_sql% echo PRINT '^| NEW Opened cursors ^|'
if (%NB%)==(1)       >>%file_sql% echo PRINT '^| ALL Opened cursors ^|'
if (%NB%)==(%COUNT%) >>%file_sql% echo PRINT '^| ALL Opened cursors ^|'
>>%file_sql% echo PRINT '+--------------------+'
>>%file_sql% echo PRINT ''
>>%file_sql% echo:
>>%file_sql% echo select c.session_id                                               AS 'SID',
>>%file_sql% echo        left^(s.host_process_id,6^)                                AS 'PID',
>>%file_sql% echo        left^(s.login_name, %LEN_LOGIN%^)                                   AS 'Login Name',
if "%VER_SQL%"=="11.0" >>%file_sql% echo 	     left^(format^(c.creation_time, '%FMT_DAT3%'^), 17^) AS 'Creation',
if "%VER_SQL%"=="12.0" >>%file_sql% echo 	     left^(format^(c.creation_time, '%FMT_DAT3%'^), 17^) AS 'Creation',
if "%VER_SQL%"=="13.0" >>%file_sql% echo 	     left^(format^(c.creation_time, '%FMT_DAT3%'^), 17^) AS 'Creation',
if "%VER_SQL%"=="14.0" >>%file_sql% echo 	     left^(format^(c.creation_time, '%FMT_DAT3%'^), 17^) AS 'Creation',
if not "%VER_SQL%"=="11.0" if not "%VER_SQL%"=="12.0" if not "%VER_SQL%"=="13.0" if not "%VER_SQL%"=="14.0" >>%file_sql% echo        left^(convert^(varchar, c.creation_time, %CNV_DATE%^)+' '+
if not "%VER_SQL%"=="11.0" if not "%VER_SQL%"=="12.0" if not "%VER_SQL%"=="13.0" if not "%VER_SQL%"=="14.0" >>%file_sql% echo             convert^(varchar, c.creation_time, %CNV_TIME%^), 17^) AS 'Creation',
>>%file_sql% echo        case when c.is_open = 1 then 'Yes' else 'No' end         AS 'Is open?',
>>%file_sql% echo        cast^(c.worker_time/1000/1000.0 as dec^(5,1^)^)            AS 'Time ^(s^)',
>>%file_sql% echo        cast^(c.reads as int^)                                   AS 'Reads',
>>%file_sql% echo        cast^(c.writes as int^)                                  AS 'Writes',
>>%file_sql% echo        char^(13)+char^(10)+cast^(substring^(t.text, ^(c.statement_start_offset/2^)+1, 
>>%file_sql% echo                      ^(^(case c.statement_end_offset
>>%file_sql% echo 				             when -1 then datalength^(t.text^)
>>%file_sql% echo                             else c.statement_end_offset end
>>%file_sql% echo                         - c.statement_start_offset^)/2^)+1^) AS CHAR^(%LEN_SQLT%^)^)+char^(13)+char^(10^) AS 'SQL Text'
>>%file_sql% echo from sys.dm_exec_cursors ^(''^) c
>>%file_sql% echo left join sys.dm_exec_sessions s on s.session_id = c.session_id
>>%file_sql% echo cross apply sys.dm_exec_sql_text ^(c.sql_handle^) t
if     defined LOGIN >>%file_sql% echo where   s.login_name = '%LOGIN%' -- Lists only for a login 
if defined EXCL_LOGIN >>%file_sql% echo where s.login_name not in ^('%EXCL_LOGIN%'^) -- Excludes logins
if not defined LOGIN if not defined EXCL_LOGIN >>%file_sql% echo where s.login_name ^> ' '
if not (%NB%)==(1) if not (%NB%)==(%COUNT%) if (%FLG_ALL%)==(0) >>%file_sql% echo and datediff(ss,c.creation_time,getdate()) ^<=%INTERVAL%
>>%file_sql% echo order by c.creation_time;
>>%file_sql% echo:
>>%file_sql% echo PRINT ''
>>%file_sql% echo PRINT '+-----------------------------+'
>>%file_sql% echo PRINT '^| Current IO and CPU Workload ^|'
>>%file_sql% echo PRINT '+-----------------------------+'
>>%file_sql% echo PRINT ''
>>%file_sql% echo:
>>%file_sql% echo waitfor delay '00:00:02';  -- Wait for 2 seconds
>>%file_sql% echo declare @cpuDiff bigint, @ioDiff bigint;
>>%file_sql% echo:
>>%file_sql% echo select @cpuDiff = sum^(p.cpu - b.cpu^),
>>%file_sql% echo        @ioDiff  = sum^(p.physical_io - b.physical_io^)
>>%file_sql% echo from sys.sysprocesses p
>>%file_sql% echo inner join #processes b
>>%file_sql% echo on p.spid = b.spid and p.sid = b.sid
>>%file_sql% echo where p.spid ^<^> @@SPID -- Exclude own process
if defined LOGIN >>%file_sql% echo and  p.loginame = '%LOGIN%' -- Lists only for a login
if defined EXCL_LOGIN >>%file_sql% echo and   p.loginame not in ^('%EXCL_LOGIN%'^) -- Excludes logins
>>%file_sql% echo and b.ecid ^<= 1;
>>%file_sql% echo:
>>%file_sql% echo select p.spid                                                                                            AS 'SID',
>>%file_sql% echo        left^(p.hostprocess,6^)                                                                             AS 'PID',
>>%file_sql% echo        left^(d.name, %LEN_DBNAME%^)                                                                                   AS 'DB Name',
>>%file_sql% echo        left^(p.loginame,%LEN_LOGIN%^)                                                                               AS 'Login Name',
>>%file_sql% echo        cast^(case when isnull^(@cpuDiff, 0^) ^<= 0 then 0 
>>%file_sql% echo 	           else convert^(decimal^(12, 1^), 100.0 * ^(p.cpu - b.cpu^) / @cpuDiff^) end as int^)              AS 'CPU ^(%%^)',
>>%file_sql% echo        cast^(case when isnull^(@ioDiff, 0^) ^<= 0 then 0
>>%file_sql% echo              else convert^(decimal^(12, 1^), 100.0 * ^(p.physical_io - b.physical_io^) / @ioDiff^) end as int^) AS 'IO ^(%%^)',
>>%file_sql% echo        p.cpu - b.cpu                                                                                     AS 'CPU Diff',
>>%file_sql% echo        p.physical_io - b.physical_io                                                                     AS 'IO Diff',
>>%file_sql% echo        left^(cast^(p.waitresource as varchar^(10^)^),10^)                                                      AS 'Wait Resource',
>>%file_sql% echo        left^(isnull^(SCHEMA_NAME^(o.schema_id^),''^), %LEN_OWNER%^)                                                     AS 'Schema Name',
>>%file_sql% echo        left^(isnull^(o.name,''^), %LEN_TABLE%^)                                                                       AS 'Table Name', 
>>%file_sql% echo        left^(isnull^(i.name,''^), %LEN_INDEX%^)                                                                       AS 'Index Name',
>>%file_sql% echo 	   left^(case when p.cmd = 'AWAITING COMMAND' then '' else p.cmd end, 7^)                              AS 'Command',
>>%file_sql% echo        char^(13^)+char^(10^)+cast^(case 
>>%file_sql% echo                   when charindex^('^)S', t.text^) ^> 0 then substring^(t.text, charindex^('^)S', t.text^)+1, %LEN_SQLT%^)
>>%file_sql% echo                   when charindex^('^)U', t.text^) ^> 0 then substring^(t.text, charindex^('^)U', t.text^)+1, %LEN_SQLT%^)
>>%file_sql% echo                   when charindex^('^)D', t.text^) ^> 0 then substring^(t.text, charindex^('^)D', t.text^)+1, %LEN_SQLT%^)
>>%file_sql% echo                   when charindex^('^)I', t.text^) ^> 0 then substring^(t.text, charindex^('^)I', t.text^)+1, %LEN_SQLT%^)
>>%file_sql% echo                   when charindex^('^)E', t.text^) ^> 0 then substring^(t.text, charindex^('^)E', t.text^)+1, %LEN_SQLT%^)
>>%file_sql% echo 				  else t.text end AS CHAR^(%LEN_SQLT%^)^)+char^(13^)+char^(10^)                                        AS 'SQL Text'
>>%file_sql% echo from sys.sysprocesses p
>>%file_sql% echo inner join #processes b      on p.spid      = b.spid and p.sid = b.sid and p.login_time = b.login_time
>>%file_sql% echo left  join  sys.databases d  on p.dbid      = d.database_id
>>%file_sql% echo left  join sys.partitions pa on cast^(pa.hobt_id as varchar^) = p.waitresource
>>%file_sql% echo left  join sys.objects o     on pa.object_id = o.object_id 
>>%file_sql% echo left  join sys.indexes i     on pa.object_id = i.object_id and pa.index_id = i.index_id 
>>%file_sql% echo cross apply sys.dm_exec_sql_text^(p.sql_handle^) t
>>%file_sql% echo where p.spid ^<^> @@SPID -- Exclude own process
if defined LOGIN >>%file_sql% echo and  p.loginame = '%LOGIN%' -- Lists only for a login
if defined EXCL_LOGIN >>%file_sql% echo and   p.loginame not in ^('%EXCL_LOGIN%'^) -- Excludes logins
>>%file_sql% echo and   b.ecid ^<= 1
>>%file_sql% echo and ^(^(p.cpu - b.cpu^) ^> 0 or ^(p.physical_io - b.physical_io^) ^> 0^)
>>%file_sql% echo order by p.cpu - b.cpu + p.physical_io - b.physical_io desc;
>>%file_sql% echo:
>>%file_sql% echo drop table #processes;
>>%file_sql% echo PRINT ''
goto:EOF
::#
::# End of Cre_check_sqllock
::#************************************************************#

:Lock_escalation_waits
::#************************************************************#
::# Lists lock escalation with wait lock information
::#
>>%file_sql% echo:
>>%file_sql% echo PRINT ''
>>%file_sql% echo PRINT '+-------------------------+'
>>%file_sql% echo PRINT '^| Lock Escalation + Waits ^|'
>>%file_sql% echo PRINT '+-------------------------+'
>>%file_sql% echo PRINT ''
>>%file_sql% echo:
>>%file_sql% echo select left^(DB_NAME^(iops.database_id^), %LEN_DBNAME%^)                                                               AS 'DB Name',
>>%file_sql% echo        left^(OBJECT_SCHEMA_NAME^(iops.object_id, iops.database_id^), %LEN_OWNER%^)                                   AS 'Schema Name', 
>>%file_sql% echo        left^(OBJECT_NAME^(iops.object_id, iops.database_id^), %LEN_TABLE%^)                                          AS 'Object Name',
>>%file_sql% echo        left^(case when i.name is null then '' else i.name end, %LEN_INDEX%^)                                       AS 'Index Name',
>>%file_sql% echo        right^(replicate^(' ',24^) +														              
>>%file_sql% echo 	         case when iops.index_lock_promotion_attempt_count = 0 then ''				              
>>%file_sql% echo 			      else cast^(iops.index_lock_promotion_attempt_count as varchar^) end, 24^)                AS 'Escalation Count Attempt',
>>%file_sql% echo        right^(replicate^(' ',21^) +														              
>>%file_sql% echo 	         case when iops.index_lock_promotion_count = 0 then ''						              
>>%file_sql% echo 			      else cast^(iops.index_lock_promotion_count as varchar^) end, 21^)                        AS 'Escalation Count Done',
>>%file_sql% echo        right^(replicate^(' ',14^) +														              
>>%file_sql% echo 	         case when iops.row_lock_count = 0 then ''									              
>>%file_sql% echo 			      else cast^(iops.row_lock_count as varchar^) end, 14^)                                    AS 'Row Lock Count',
>>%file_sql% echo        right^(replicate^(' ',19^) +														              
>>%file_sql% echo 	         case when iops.row_lock_wait_count = 0 then '' 							              
>>%file_sql% echo                   else cast^(iops.row_lock_wait_count as varchar^) end, 19^)                               AS 'Row Lock Wait Count',
>>%file_sql% echo        right^(replicate^(' ',17^) +
>>%file_sql% echo 	         case when iops.row_lock_wait_in_ms = 0 then ''
>>%file_sql% echo                   else cast^(cast^(iops.row_lock_wait_in_ms/1000.0 as decimal^(8,1^)^) as varchar^) end, 17^)  AS 'Row Lock Wait ^(s^)',
>>%file_sql% echo        right^(replicate^(' ',15^) +
>>%file_sql% echo              case when iops.page_lock_count = 0 then ''
>>%file_sql% echo 			      else cast^(iops.page_lock_count as varchar^) end, 15^)                                   AS 'Page Lock Count',
>>%file_sql% echo        right^(replicate^(' ',21^) +														              
>>%file_sql% echo 	         case when iops.page_lock_wait_count = 0 then '' 							              
>>%file_sql% echo                   else cast^(iops.page_lock_wait_count as varchar^) end, 20^)                              AS 'Page Lock Wait Count',
>>%file_sql% echo        right^(replicate^(' ',18^) +
>>%file_sql% echo 	         case when iops.page_lock_wait_in_ms = 0 then ''
>>%file_sql% echo                   else cast^(cast^(iops.page_lock_wait_in_ms/1000.0 as decimal^(8,1^)^) as varchar^) end, 18^) AS 'Page Lock Wait ^(s^)'
>>%file_sql% echo from sys.dm_db_index_operational_stats ^(db_id^(^), NULL, NULL, NULL^) iops
>>%file_sql% echo inner join sys.indexes i on i.object_id = iops.object_id and i.index_id  = iops.index_id 
>>%file_sql% echo where iops.index_lock_promotion_count+iops.row_lock_wait_count+iops.page_lock_wait_count ^> 0
>>%file_sql% echo and OBJECT_SCHEMA_NAME^(iops.object_id, iops.database_id^) != 'sys' -- Excludes sys schema 
if defined LOGIN >>%file_sql% echo and OBJECT_SCHEMA_NAME^(iops.object_id, iops.database_id^) = '%LOGIN%' -- Lists only for a login
if defined EXCL_LOGIN >>%file_sql% echo and   OBJECT_SCHEMA_NAME^(iops.object_id, iops.database_id^) not in ^('%EXCL_LOGIN%'^) -- Excludes logins
>>%file_sql% echo order by 2, iops.row_lock_wait_in_ms + iops.page_lock_wait_in_ms desc, iops.index_lock_promotion_count desc;
goto:EOF
::#
::# End of Lock_escalation_waits
::#************************************************************#

:List_lock_disable
::#************************************************************#
::# Lists disabled lock escalation for tables and level page off for indexes associated
::#
>>%file_sql% echo:
>>%file_sql% echo PRINT ''
>>%file_sql% echo PRINT '+-------------------------+'
>>%file_sql% echo PRINT '^| Lock Escalation disable ^|'
>>%file_sql% echo PRINT '+-------------------------+'
>>%file_sql% echo PRINT ''
>>%file_sql% echo:
>>%file_sql% echo select left^(SCHEMA_NAME(t.schema_id), %LEN_OWNER%^) AS 'Schema Name',
>>%file_sql% echo        left^(t.name, %LEN_TABLE%^)                   AS 'Table Name',
>>%file_sql% echo        left^(t.lock_escalation_desc, 8^)    AS 'Escalation'
>>%file_sql% echo from sys.tables t
>>%file_sql% echo where t. lock_escalation ^> 0
if defined LOGIN >>%file_sql% echo and   SCHEMA_NAME^(t.schema_id^) = '%LOGIN%' -- Lists only for a login
if defined EXCL_LOGIN >>%file_sql% echo and   SCHEMA_NAME^(t.schema_id^) not in ^('%EXCL_LOGIN%'^) -- Excludes logins
>>%file_sql% echo order by 1, 2;
>>%file_sql% echo:
>>%file_sql% echo PRINT ''
>>%file_sql% echo select distinct left^(SCHEMA_NAME^(t.schema_id^), %LEN_OWNER%^)                            AS 'Schema Name',
>>%file_sql% echo        left^(t.name, %LEN_TABLE%^)                                                       AS 'Table Name',
>>%file_sql% echo        left^(i.name, %LEN_INDEX%^)                                                       AS 'Index Name',
>>%file_sql% echo        left^(case when i.allow_row_locks  = '1' then 'On' else 'Off' end, 15^)  AS 'Is Row Locks ?',
>>%file_sql% echo        left^(case when i.allow_page_locks = '1' then 'On' else 'Off' end, 15^)  AS 'Is Page Locks ?'
>>%file_sql% echo from sys.indexes i
>>%file_sql% echo inner join sys.tables t on t.object_id = i.object_id
>>%file_sql% echo and   i.index_id ^>= 3
if defined LOGIN >>%file_sql% echo and SCHEMA_NAME^(t.schema_id^) = '%LOGIN%' -- Lists only for a login
if defined EXCL_LOGIN >>%file_sql% echo and   SCHEMA_NAME^(t.schema_id^) not in ^('%EXCL_LOGIN%'^) -- Excludes logins
>>%file_sql% echo and   ^(i.allow_row_locks = '0' or i.allow_page_locks = '0'^);
goto:EOF
::#
::# End of List_lock_disable
::#************************************************************#

:Info_x3folder
::#************************************************************#
::# Lists info about sessions connected to the X3 folder
::#
::# List of arguments passed to the function:
::#  %1 = Folder name
::#
set FOLDER=%1
if not "%VER_SQL%"=="9.0" call :Info_x3folder_usage %1
>>%file_sql% echo PRINT ''
>>%file_sql% echo PRINT '+-----------------------------+'
if not (%NB%)==(1) if not (%NB%)==(%COUNT%) if (%FLG_ALL%)==(1) >>%file_sql% echo PRINT '^| ALL Locked symbols ^(%FOLDER%^)'
if not (%NB%)==(1) if not (%NB%)==(%COUNT%) if (%FLG_ALL%)==(0) >>%file_sql% echo PRINT '^| NEW Locked symbols ^(%FOLDER%^)'
if (%NB%)==(1)       >>%file_sql% echo PRINT '^| ALL Locked symbols ^(%FOLDER%^)'
if (%NB%)==(%COUNT%) >>%file_sql% echo PRINT '^| ALL Locked symbols ^(%FOLDER%^)'
>>%file_sql% echo PRINT '+-----------------------------+'
>>%file_sql% echo PRINT ''
>>%file_sql% echo:
>>%file_sql% echo select left^(l.LCKSYM_0, 30^)                                                                          AS 'Symbol',
if "%VER_SQL%"=="11.0" >>%file_sql% echo        left^(format^(l.LCKDAT_0, '%FMT_DAT1%'^) + ' ' +
if "%VER_SQL%"=="12.0" >>%file_sql% echo        left^(format^(l.LCKDAT_0, '%FMT_DAT1%'^) + ' ' +
if "%VER_SQL%"=="13.0" >>%file_sql% echo        left^(format^(l.LCKDAT_0, '%FMT_DAT1%'^) + ' ' +
if "%VER_SQL%"=="14.0" >>%file_sql% echo        left^(format^(l.LCKDAT_0, '%FMT_DAT1%'^) + ' ' +
if not "%VER_SQL%"=="11.0" if not "%VER_SQL%"=="12.0" if not "%VER_SQL%"=="13.0" if not "%VER_SQL%"=="14.0" >>%file_sql% echo        left^(convert^(varchar, l.LCKDAT_0, %CNV_DATE%^) + ' ' +
>>%file_sql% echo        convert^(char^(8^), dateadd^(second, l.LCKTIM_0, 0^), %CNV_TIME%^), 17^)                                      AS 'Date time',
>>%file_sql% echo        left^(isnull^(l.LCKPID_0,''^), 9^)                                                                AS 'App.id',
>>%file_sql% echo        left^(isnull^(e.ELTTYP_0,isnull^(b.ABRFIC_0,''^)^), 3^)                                             AS 'Type',
>>%file_sql% echo        left^(isnull^(l.LCKSYM_0, b.ABRFIC_0^), 3^)                                                       AS 'Element',
>>%file_sql% echo        left^(substring^(l.LCKSYM_0, cast^(replace^(charindex^(' ', l.LCKSYM_0^), 0, 
>>%file_sql% echo             case when charindex^('-', l.LCKSYM_0^) = 0 then 3 
>>%file_sql% echo                  else charindex^('-', l.LCKSYM_0^) end^) as int^)+1, 30^), 30^)                            AS 'Parameter',
>>%file_sql% echo        left^(case when left^(l.LCKSYM_0, 3^) = 'AUO' then isnull^(u.NOMUSR_0,'???'^)
>>%file_sql% echo                                                   else isnull^(t.TEXTE_0,''^) end, 30^)                 AS 'Description'
>>%file_sql% echo from %FOLDER%.APLLCK l
>>%file_sql% echo left join %FOLDER%.AELT e    on e.ELT_0    = replace^(left^(l.LCKSYM_0, 3^),'AUO','AU0'^)
>>%file_sql% echo left join %DOSS_REF%.AUSRSOL s     on s.USR_0    = substring^(l.LCKSYM_0, charindex^(' ', l.LCKSYM_0^) +1, 50^)
>>%file_sql% echo left join %FOLDER%.AUTILIS u on u.USR_0    = s.USR_0
>>%file_sql% echo left join %FOLDER%.AOBJET o  on o.ABREV_0  = left^(l.LCKSYM_0, 3^) and e.ELTTYP_0 = 'OBJT'
>>%file_sql% echo left join %FOLDER%.AMSK m    on m.CODMSK_0 = left^(l.LCKSYM_0, 3^) and e.ELTTYP_0 = 'SCRN'
>>%file_sql% echo left join %FOLDER%.AWINDOW w on w.WIN_0    = left^(l.LCKSYM_0, 3^) and e.ELTTYP_0 IN ^('FENW', 'FENX'^)
>>%file_sql% echo left join %FOLDER%.ATABLE b  on b.ABRFIC_0  = left^(l.LCKSYM_0, 3^)
>>%file_sql% echo left join %FOLDER%.ATEXTE t  on t.NUMERO_0  = isnull^(o.LIBEL_0, isnull^(m.INTMSK_0, isnull^(w.DES_0, b.INTITFIC_0^)^)^) and t.LAN_0 = '%LAN%'
>>%file_sql% echo where l.LCKDAT_0 ^> getdate^(^)-1
>>%file_sql% echo and   l.LCKSYM_0 not like 'PORT%%'
if "%VER_SQL%"=="11.0" if not (%NB%)==(1) if not (%NB%)==(%COUNT%) if (%FLG_ALL%)==(0) if defined CMD_DIFF >>%file_sql% echo and   l.LCKTIM_0 ^>= cast^(format^(getdate^(^), 'HH'^) as int^)*60*60 +
if "%VER_SQL%"=="11.0" if not (%NB%)==(1) if not (%NB%)==(%COUNT%) if (%FLG_ALL%)==(0) if defined CMD_DIFF >>%file_sql% echo                     cast^(format^(getdate^(^), 'mm'^) as int^)*60 +
if "%VER_SQL%"=="11.0" if not (%NB%)==(1) if not (%NB%)==(%COUNT%) if (%FLG_ALL%)==(0) if defined CMD_DIFF >>%file_sql% echo                     cast^(format^(getdate^(^), 'ss'^) as int^) - %INTERVAL%
if "%VER_SQL%"=="12.0" if not (%NB%)==(1) if not (%NB%)==(%COUNT%) if (%FLG_ALL%)==(0) if defined CMD_DIFF >>%file_sql% echo and   l.LCKTIM_0 ^>= cast^(format^(getdate^(^), 'HH'^) as int^)*60*60 +
if "%VER_SQL%"=="12.0" if not (%NB%)==(1) if not (%NB%)==(%COUNT%) if (%FLG_ALL%)==(0) if defined CMD_DIFF >>%file_sql% echo                     cast^(format^(getdate^(^), 'mm'^) as int^)*60 +
if "%VER_SQL%"=="12.0" if not (%NB%)==(1) if not (%NB%)==(%COUNT%) if (%FLG_ALL%)==(0) if defined CMD_DIFF >>%file_sql% echo                     cast^(format^(getdate^(^), 'ss'^) as int^) - %INTERVAL%
if "%VER_SQL%"=="13.0" if not (%NB%)==(1) if not (%NB%)==(%COUNT%) if (%FLG_ALL%)==(0) if defined CMD_DIFF >>%file_sql% echo and   l.LCKTIM_0 ^>= cast^(format^(getdate^(^), 'HH'^) as int^)*60*60 +
if "%VER_SQL%"=="13.0" if not (%NB%)==(1) if not (%NB%)==(%COUNT%) if (%FLG_ALL%)==(0) if defined CMD_DIFF >>%file_sql% echo                     cast^(format^(getdate^(^), 'mm'^) as int^)*60 +
if "%VER_SQL%"=="13.0" if not (%NB%)==(1) if not (%NB%)==(%COUNT%) if (%FLG_ALL%)==(0) if defined CMD_DIFF >>%file_sql% echo                     cast^(format^(getdate^(^), 'ss'^) as int^) - %INTERVAL%
if "%VER_SQL%"=="14.0" if not (%NB%)==(1) if not (%NB%)==(%COUNT%) if (%FLG_ALL%)==(0) if defined CMD_DIFF >>%file_sql% echo and   l.LCKTIM_0 ^>= cast^(format^(getdate^(^), 'HH'^) as int^)*60*60 +
if "%VER_SQL%"=="14.0" if not (%NB%)==(1) if not (%NB%)==(%COUNT%) if (%FLG_ALL%)==(0) if defined CMD_DIFF >>%file_sql% echo                     cast^(format^(getdate^(^), 'mm'^) as int^)*60 +
if "%VER_SQL%"=="14.0" if not (%NB%)==(1) if not (%NB%)==(%COUNT%) if (%FLG_ALL%)==(0) if defined CMD_DIFF >>%file_sql% echo                     cast^(format^(getdate^(^), 'ss'^) as int^) - %INTERVAL%
if not "%VER_SQL%"=="11.0" if not  "%VER_SQL%"=="12.0" if not "%VER_SQL%"=="13.0" if not "%VER_SQL%"=="14.0" if not (%NB%)==(1) if not (%NB%)==(%COUNT%) if (%FLG_ALL%)==(0) if defined CMD_DIFF >>%file_sql% echo and   l.LCKTIM_0 ^>= cast^(substring^(convert^(varchar, getdate^(^), %CNV_TIME%^),1,2^) as int^)*60*60 +
if not "%VER_SQL%"=="11.0" if not  "%VER_SQL%"=="12.0" if not "%VER_SQL%"=="13.0" if not "%VER_SQL%"=="14.0" if not (%NB%)==(1) if not (%NB%)==(%COUNT%) if (%FLG_ALL%)==(0) if defined CMD_DIFF >>%file_sql% echo                     cast^(substring^(convert^(varchar, getdate^(^), %CNV_TIME%^),4,2^) as int^)*60 +
if not "%VER_SQL%"=="11.0" if not  "%VER_SQL%"=="12.0" if not "%VER_SQL%"=="13.0" if not "%VER_SQL%"=="14.0" if not (%NB%)==(1) if not (%NB%)==(%COUNT%) if (%FLG_ALL%)==(0) if defined CMD_DIFF >>%file_sql% echo                     cast^(substring^(convert^(varchar, getdate^(^), %CNV_TIME%^),7,2^) as int^) - %INTERVAL%
>>%file_sql% echo order by l.LCKDAT_0, l.LCKTIM_0;
>>%file_sql% echo:
goto:EOF
::#
::# End of Info_x3folder
::#************************************************************#

:Info_x3folder_usage
::#************************************************************#
::# Lists info about sessions connected to the X3 folder 
::#
::# ATTENTION: Not compatible for Sage X3 V5 products with SQL Sever 2005.
::#
::# List of arguments passed to the function:
::#  %1 = Folder name
::#
set FOLDER=%1
>>%file_sql% echo PRINT ''
>>%file_sql% echo PRINT '+-----------------------+'
if not (%NB%)==(1) if not (%NB%)==(%COUNT%) if (%FLG_ALL%)==(1) >>%file_sql% echo PRINT '^| ALL Module usage ^(%FOLDER%^)'
if not (%NB%)==(1) if not (%NB%)==(%COUNT%) if (%FLG_ALL%)==(0) if defined CMD_DIFF >>%file_sql% echo PRINT '^| NEW Module usage ^(%FOLDER%^)'
if (%NB%)==(1)       >>%file_sql% echo PRINT '^| ALL Module usage ^(%FOLDER%^)'
if (%NB%)==(%COUNT%) >>%file_sql% echo PRINT '^| ALL Module usage ^(%FOLDER%^)'
>>%file_sql% echo PRINT '+-----------------------+'
>>%file_sql% echo PRINT ''
>>%file_sql% echo:
>>%file_sql% echo select left^(case when c.FCT_0 = '' then 'MENU' else FCT_0 end, %LEN_APPFCT%^)             AS 'Module',
>>%file_sql% echo        left^(isnull^(t.TEXTE_0,'Menu general'^),30^)                               AS 'Name',
>>%file_sql% echo        left^(cast^(count^(c.UID_0^) as varchar^), 5^)                                AS 'Count',
>>%file_sql% echo        left^(case count^(c.UID_0^) when 1 then min^(c.LOGIN_0^)+' ^('+min^(u.NOMUSR_0^)+'^)'
>>%file_sql% echo                            when 2 then case when min^(c.LOGIN_0^)=max^(c.LOGIN_0^) then min^(c.LOGIN_0^)+' ^('+min^(u.NOMUSR_0^)+'^)' else min^(c.LOGIN_0^)+', '+max^(c.LOGIN_0^) end
>>%file_sql% echo        			           else case when min^(c.LOGIN_0^)=max^(c.LOGIN_0^) then min^(c.LOGIN_0^)+' ^('+min^(u.NOMUSR_0^)+'^)' else min^(c.LOGIN_0^)+', '+max^(c.LOGIN_0^)+', ...' end end, 45^) AS 'Login ^(Name^)',
if "%VER_SQL%"=="11.0" >>%file_sql% echo 	     left^(format^(dateadd^(HH, datediff^(hour, getutcdate^(^), getdate^(^)^), max^(c.%CREDAT%^)^), 'HH:mm:ss'^),8^) AS 'Last Time'
if "%VER_SQL%"=="12.0" >>%file_sql% echo 	     left^(format^(dateadd^(HH, datediff^(hour, getutcdate^(^), getdate^(^)^), max^(c.%CREDAT%^)^), 'HH:mm:ss'^),8^) AS 'Last Time'
if "%VER_SQL%"=="13.0" >>%file_sql% echo 	     left^(format^(dateadd^(HH, datediff^(hour, getutcdate^(^), getdate^(^)^), max^(c.%CREDAT%^)^), 'HH:mm:ss'^),8^) AS 'Last Time'
if "%VER_SQL%"=="14.0" >>%file_sql% echo 	     left^(format^(dateadd^(HH, datediff^(hour, getutcdate^(^), getdate^(^)^), max^(c.%CREDAT%^)^), 'HH:mm:ss'^),8^) AS 'Last Time'
if not "%VER_SQL%"=="11.0" if not "%VER_SQL%"=="12.0" if not "%VER_SQL%"=="13.0" if not "%VER_SQL%"=="14.0" >>%file_sql% echo 	     left^(convert^(varchar, dateadd^(HH, datediff^(hour, getutcdate^(^), getdate^(^)^), max^(c.%CREDAT%^)^),24^),8^) AS 'Last Time'
>>%file_sql% echo from %DOSS_REF%.AFCTCUR c
>>%file_sql% echo left outer join %FOLDER%.AFONCTION f on f.CODINT_0 = c.FCT_0
>>%file_sql% echo left outer join %FOLDER%.ATEXTE t    on t.NUMERO_0 = f.NOM_0 and t.LAN_0 = '%LAN%'
>>%file_sql% echo inner join %FOLDER%.AUTILIS u        on u.USR_0 = c.USR_0
>>%file_sql% echo where c.%CREDAT% ^> getdate()-1
if not (%NB%)==(1) if not (%NB%)==(%COUNT%) if (%FLG_ALL%)==(0) if defined CMD_DIFF >>%file_sql% echo and   datediff^(ss, c.%CREDAT%, getutcdate^(^)^)^<=%INTERVAL%
>>%file_sql% echo group by c.FCT_0, t.TEXTE_0
>>%file_sql% echo order by count^(c.UID_0^) desc, c.FCT_0;
>>%file_sql% echo:
>>%file_sql% echo PRINT ''
>>%file_sql% echo PRINT '+----------------------+'
if not (%NB%)==(1) if not (%NB%)==(%COUNT%) if (%FLG_ALL%)==(1) >>%file_sql% echo PRINT '^| ALL Login usage ^(%FOLDER%^)'
if not (%NB%)==(1) if not (%NB%)==(%COUNT%) if (%FLG_ALL%)==(0) if defined CMD_DIFF >>%file_sql% echo PRINT '^| NEW Login usage ^(%FOLDER%^)'
if (%NB%)==(1)       >>%file_sql% echo PRINT '^| ALL Login usage ^(%FOLDER%^)'
if (%NB%)==(%COUNT%) >>%file_sql% echo PRINT '^| ALL Login usage ^(%FOLDER%^)'
>>%file_sql% echo PRINT '+----------------------+'
>>%file_sql% echo PRINT ''
>>%file_sql% echo:
>>%file_sql% echo select left^(c.LOGIN_0, %LEN_APPLOG%^)                                                     AS 'Login',
>>%file_sql% echo        left^(u.NOMUSR_0,30^)                                                     AS 'Name',
>>%file_sql% echo        left^(cast^(count^(c.UID_0^) as varchar^), 5^)                                AS 'Count',
>>%file_sql% echo        left^(case count^(c.UID_0^) when 1 then min^(case when c.FCT_0='' then 'MENU' else c.FCT_0 end^)+' ^('+min^(isnull^(t.TEXTE_0,'Menu general'^)^)+'^)'
>>%file_sql% echo                            when 2 then min^(c.FCT_0^)+', '+max^(c.FCT_0^)
>>%file_sql% echo        			           else case when min^(c.FCT_0^)='' then '' else min^(c.FCT_0^)+', '+max^(c.FCT_0^)+', ...' end end, 45^) AS 'Module ^(Name^)',
if "%VER_SQL%"=="11.0" >>%file_sql% echo 	     left^(format^(dateadd^(HH, datediff^(hour, getutcdate^(^), getdate^(^)^), max^(c.%CREDAT%^)^), 'HH:mm:ss'^),8^) AS 'Last Time'
if "%VER_SQL%"=="12.0" >>%file_sql% echo 	     left^(format^(dateadd^(HH, datediff^(hour, getutcdate^(^), getdate^(^)^), max^(c.%CREDAT%^)^), 'HH:mm:ss'^),8^) AS 'Last Time'
if "%VER_SQL%"=="13.0" >>%file_sql% echo 	     left^(format^(dateadd^(HH, datediff^(hour, getutcdate^(^), getdate^(^)^), max^(c.%CREDAT%^)^), 'HH:mm:ss'^),8^) AS 'Last Time'
if "%VER_SQL%"=="14.0" >>%file_sql% echo 	     left^(format^(dateadd^(HH, datediff^(hour, getutcdate^(^), getdate^(^)^), max^(c.%CREDAT%^)^), 'HH:mm:ss'^),8^) AS 'Last Time'
if not "%VER_SQL%"=="11.0" if not "%VER_SQL%"=="12.0" if not "%VER_SQL%"=="13.0" if not "%VER_SQL%"=="14.0" >>%file_sql% echo 	     left^(convert^(varchar, dateadd^(HH, datediff^(hour, getutcdate^(^), getdate^(^)^), max^(c.%CREDAT%^)^),24^),8^) AS 'Last Time'
>>%file_sql% echo from %DOSS_REF%.AFCTCUR c
>>%file_sql% echo left outer join %FOLDER%.AFONCTION f on f.CODINT_0 = c.FCT_0
>>%file_sql% echo left outer join %FOLDER%.ATEXTE t    on t.NUMERO_0 = f.NOM_0 and t.LAN_0 = '%LAN%'
>>%file_sql% echo inner join %FOLDER%.AUTILIS u        on u.USR_0 = c.USR_0
>>%file_sql% echo where c.%CREDAT% ^> getdate()-1
if not (%NB%)==(1) if not (%NB%)==(%COUNT%) if (%FLG_ALL%)==(0) if defined CMD_DIFF >>%file_sql% echo and   datediff^(ss, c.%CREDAT%, getutcdate^(^)^)^<=%INTERVAL%
::>>%file_sql% echo and c.FCT_0 ^> ' ' and NOT c.MODULE_0 = '1'
>>%file_sql% echo group by c.LOGIN_0, u.NOMUSR_0
>>%file_sql% echo order by count^(c.UID_0^) desc, c.LOGIN_0;
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
 >%file_prf%.lst echo \Memory\Available Mbytes
>>%file_prf%.lst echo \Memory\Pages/sec
>>%file_prf%.lst echo \Network Interface(*)\Bytes Total/sec
>>%file_prf%.lst echo \Network Interface(*)\Output Queue Length
>>%file_prf%.lst echo \Paging File(*)\%%Usage
>>%file_prf%.lst echo \PhysicalDisk(*)\%% Disk Time
>>%file_prf%.lst echo \PhysicalDisk(*)\Avg. Disk Queue Length
>>%file_prf%.lst echo \PhysicalDisk(*)\Avg. Disk sec/Read 
>>%file_prf%.lst echo \PhysicalDisk(*)\Avg. Disk sec/Write
>>%file_prf%.lst echo \Process(_Total)\%% Processor Time
>>%file_prf%.lst echo \System\Processor Queue Length
>>%file_prf%.lst echo \MSSQL$%DB_SVC%:Access Methods\Table Lock Escalations/sec
>>%file_prf%.lst echo \MSSQL$%DB_SVC%:Buffer Manager\Buffer cache hit ratio
>>%file_prf%.lst echo \MSSQL$%DB_SVC%:Buffer Manager\Checkpoint Pages/Sec
>>%file_prf%.lst echo \MSSQL$%DB_SVC%:Buffer Manager\Lazy Writes/sec
>>%file_prf%.lst echo \MSSQL$%DB_SVC%:Buffer Manager\Page life expectancy
>>%file_prf%.lst echo \MSSQL$%DB_SVC%:Buffer Manager\Page reads/sec
>>%file_prf%.lst echo \MSSQL$%DB_SVC%:Buffer Manager\Page writes/sec
>>%file_prf%.lst echo \MSSQL$%DB_SVC%:Databases(*)\Active Transactions
>>%file_prf%.lst echo \MSSQL$%DB_SVC%:General Statistics\Processes Blocked
>>%file_prf%.lst echo \MSSQL$%DB_SVC%:General Statistics\User Connections
>>%file_prf%.lst echo \MSSQL$%DB_SVC%:Locks(*)\Lock Wait Time
>>%file_prf%.lst echo \MSSQL$%DB_SVC%:Locks(*)\Lock Waits/sec
>>%file_prf%.lst echo \MSSQL$%DB_SVC%:Locks(*)\Number of Deadlocks/sec
>>%file_prf%.lst echo \MSSQL$%DB_SVC%:Memory Manager\Memory Grants Pending
>>%file_prf%.lst echo \MSSQL$%DB_SVC%:SQL Statistics – Batch Requests/sec
>>%file_prf%.lst echo \MSSQL$%DB_SVC%:SQL Statistics – SQL Compilations/sec
>>%file_prf%.lst echo \MSSQL$%DB_SVC%:SQL Statistics – SQL Re-Compilations/sec
goto:EOF
::#
::# End of List_typeperf_eng
::#************************************************************#

:List_typeperf_fra
::#************************************************************#
::# Creates a file list of main Windows and SQL Server performance counters in french language
::#
 >%file_prf%.lst echo \Mémoire\Mégaoctets disponibles
>>%file_prf%.lst echo \Mémoire\Pages/s
>>%file_prf%.lst echo \Interface réseau(*)\Total des octets/s
>>%file_prf%.lst echo \Interface réseau(*)\Longueur de la file d'attente de sortie
>>%file_prf%.lst echo \Fichier d'échange(*)\Pourcentage d'utilisation
>>%file_prf%.lst echo \Disque physique(*)\Pourcentage du temps disque
>>%file_prf%.lst echo \Disque physique(*)\Longueur moyenne de file d'attente du disque
>>%file_prf%.lst echo \Disque physique(*)\Moyenne disque s/lecture
>>%file_prf%.lst echo \Disque physique(*)\Moyenne disque s/écriture
>>%file_prf%.lst echo \Processus(_Total)\%% temps processeur
>>%file_prf%.lst echo \Système\Longueur de la file du processeur
>>%file_prf%.lst echo \MSSQL$%DB_SVC%:Méthodes d'accès\Escalades de verrous de tables/s
>>%file_prf%.lst echo \MSSQL$%DB_SVC%:Gestionnaire de tampons\Taux d'accès au cache des tampons
>>%file_prf%.lst echo \MSSQL$%DB_SVC%:Gestionnaire de tampons\Pages de points de contrôle/s
>>%file_prf%.lst echo \MSSQL$%DB_SVC%:Gestionnaire de tampons\Écritures différées/s
>>%file_prf%.lst echo \MSSQL$%DB_SVC%:Gestionnaire de tampons\Espérance de vie d'une page
>>%file_prf%.lst echo \MSSQL$%DB_SVC%:Gestionnaire de tampons\Lectures de pages/s
>>%file_prf%.lst echo \MSSQL$%DB_SVC%:Gestionnaire de tampons\Écritures de pages/s
>>%file_prf%.lst echo \MSSQL$%DB_SVC%:Databases(*)\Transactions actives
>>%file_prf%.lst echo \MSSQL$%DB_SVC%:General Statistics\Processus bloqués
>>%file_prf%.lst echo \MSSQL$%DB_SVC%:General Statistics\Connexions utilisateur
>>%file_prf%.lst echo \MSSQL$%DB_SVC%:Locks(*)\Temps d'attente des verrous (ms)
>>%file_prf%.lst echo \MSSQL$%DB_SVC%:Locks(*)\Attentes de verrous/s
>>%file_prf%.lst echo \MSSQL$%DB_SVC%:Locks(*)\Nombre d'interblocages/s
>>%file_prf%.lst echo \MSSQL$%DB_SVC%:Memory Manager\Demandes de mémoire en attente
>>%file_prf%.lst echo \MSSQL$%DB_SVC%:SQL Statistics\Nombre de requêtes de lots/s
>>%file_prf%.lst echo \MSSQL$%DB_SVC%:SQL Statistics\Compilations SQL/s
>>%file_prf%.lst echo \MSSQL$%DB_SVC%:SQL Statistics\Recompilations SQL/s
goto:EOF
::#
::# End of List_typeperf_fra
::#************************************************************#

:Cre_info_psadx
::#************************************************************#
::# Generates the SQL script for listing the result of the psadx function (Only from Sage X3 product V11 and later)
::#
 >%file_adx_sql% echo:
>>%file_adx_sql% echo select case when p.PROCESSNAME_0 = 'adonix' then left^(i.REMOTE_0, 40^)            else '' end AS 'Client',
>>%file_adx_sql% echo        case when p.PROCESSNAME_0 = 'adonix' then left^(i.PEER_0, 15^)              else '' end AS 'Web client',
>>%file_adx_sql% echo        case when p.PROCESSNAME_0 = 'adonix' then left^(i.ALOGIN_0, 20^)            else '' end AS 'Login',
>>%file_adx_sql% echo        case when p.PROCESSNAME_0 = 'adonix' then left^(i.FOLD_0, 10^)              else '' end AS 'Folder',
>>%file_adx_sql% echo        case when p.PROCESSNAME_0 = 'adonix' then left^(isnull^(m.LANMES_0,''^), 15^) else '' end AS 'Module',
>>%file_adx_sql% echo        case when p.PROCESSNAME_0 = 'adonix' then left^(isnull^(f.FCT_0,''^), 15^)    else '' end AS 'Function',
>>%file_adx_sql% echo        case when p.PROCESSNAME_0 = 'adonix' then left^(i.SYSTEMUSER_0, 10^)        else '' end AS 'System login',
>>%file_adx_sql% echo        case when p.PROCESSNAME_0 = 'adonix' then left^(PORT_0, 7^)                 else '' end AS 'Service',
>>%file_adx_sql% echo        case when p.PROCESSNAME_0 = 'adonix' then left^(format^(s.connect_time, '%FMT_DAT2%'^),14^) else '' end AS 'Connection',
>>%file_adx_sql% echo        case when p.PROCESSNAME_0 = 'adonix' then left^(format^(case when s.last_read ^> s.last_write then s.last_read else s.last_write end,'%FMT_DAT2%'^),14^) else '' end AS 'Last action',
>>%file_adx_sql% echo        case when p.PROCESSNAME_0 = 'adonix' then  left^(case when i.SESSIONTYPE_0 = 33 then 'Web page'
>>%file_adx_sql% echo 				 when i.SESSIONTYPE_0 = 25 then 'Classic page'
>>%file_adx_sql% echo 				 when i.SESSIONTYPE_0 = 14
>>%file_adx_sql% echo 				   or i.SESSIONTYPE_0 = 30 then 'Eclipse'
>>%file_adx_sql% echo 				 when i.SESSIONTYPE_0 = 35 then 'Batch'
>>%file_adx_sql% echo 				 when i.SESSIONTYPE_0 = 20 then 'Web services'
>>%file_adx_sql% echo 				 else convert^(varchar, i.SESSIONTYPE_0^) end, 12^) else '' end AS 'Type',
::>>%file_adx_sql% echo        case when p.PROCESSNAME_0 = 'adonix' then left^(case when i.NATURE_0 = '1' then 'Internal'
::>>%file_adx_sql% echo                                   else 'Other' end, 8^)  else '' end AS 'Nature',
>>%file_adx_sql% echo        case when p.PROCESSNAME_0 = 'adonix' then left^(i.LAN_0, 3^) else '' end AS 'Lan',
::>>%file_adx_sql% echo        case when p.PROCESSNAME_0 = 'adonix' then left^(i.SOLUTION_0, 8^)   else '' end AS 'Solution',
::>>%file_adx_sql% echo        case when p.PROCESSNAME_0 = 'adonix' then left^(i.PROCESSADX_0, 7^) else '' end AS 'Process',
>>%file_adx_sql% echo        case when p.PROCESSNAME_0 = 'adonix' then left^(i.SESSIONID_0, 7^) else '' end AS 'App.Id',
>>%file_adx_sql% echo        case when p.PROCESSNAME_0 = 'adonix' then right^(replicate^(' ',5-len^(d.DBIDENT1_0^)^)+cast^(d.DBIDENT1_0 as varchar^),5^) else '' end AS 'DB.Id',
::>>%file_adx_sql% echo        case when p.PROCESSNAME_0 = 'adonix' then left^(d.DBIDENT2_0, 10^)  else '' end AS 'DB.Id2',
>>%file_adx_sql% echo        left^(right^(replicate(' ',6-len^(convert^(varchar, p.SYSTEMID_0^)^)^)+convert^(varchar, p.SYSTEMID_0^),6^)+':'+convert^(varchar, p.PROCESSNAME_0^)+'^('+substring^(p.SERVER_0, charindex(p.SERVER_0,'.'^)-1,40^)+'^)', 50^) AS 'Process'
>>%file_adx_sql% echo from %DOSS_REF%.ASYSSMDBASSO d
>>%file_adx_sql% echo join %DOSS_REF%.ASYSSMINTERN i on i.SESSIONID_0 = d.SESSIONID_0
>>%file_adx_sql% echo join %DOSS_REF%.ASYSSMPROCES p on p.SESSIONID_0 = d.SESSIONID_0
>>%file_adx_sql% echo left outer join %DOSS_REF%.AFCTCUR f on f.UID_0 = i.SESSIONID_0
>>%file_adx_sql% echo left outer join %DOSS_REF%.APLSTD m on m.LANNUM_0 = f.MODULE_0 and m.LAN_0 = '%LAN%' and m.LANCHP_0 = 14
>>%file_adx_sql% echo join sys.dm_exec_connections s on s.session_id = convert^(integer, d.DBIDENT1_0^) and connect_time = convert^(datetime, d.DBIDENT2_0, 121^)
if not (%NB%)==(1) if not (%NB%)==(%COUNT%) >>%file_adx_sql% echo and   datediff(ss,case when s.last_read ^> s.last_write then s.last_read else s.last_write end,getdate()) ^<=%INTERVAL%
if defined LOGIN >>%file_adx_sql% echo and   i.FOLD_0 = '%LOGIN%' -- Lists only for a login
if defined EXCL_LOGIN >>%file_sql% echo and   i.FOLD_0 not in ^('%EXCL_LOGIN%^') -- Excludes logins
>>%file_adx_sql% echo order by i.FOLD_0, d.DBIDENT1_0, p.PROCESSNAME_0;
>>%file_adx_sql% echo:
>>%file_adx_sql% echo PRINT '+--------------+'
>>%file_adx_sql% echo PRINT '^| Type session ^|'
>>%file_adx_sql% echo PRINT '+--------------+'
>>%file_adx_sql% echo PRINT ''
>>%file_adx_sql% echo:
>>%file_adx_sql% echo select left^(i.FOLD_0, %LEN_OWNER%^)                                                            AS '      Folder',
>>%file_adx_sql% echo        sum^(case when i.SESSIONTYPE_0 = 35                         then 1 else 0 end^) AS '       Batch',
>>%file_adx_sql% echo        sum^(case when i.SESSIONTYPE_0 = 33                         then 1 else 0 end^) AS '    Web page',
>>%file_adx_sql% echo        sum^(case when i.SESSIONTYPE_0 = 25                         then 1 else 0 end^) AS 'Classic page',
>>%file_adx_sql% echo        sum^(case when i.SESSIONTYPE_0 = 20                         then 1 else 0 end^) AS 'Web services',
>>%file_adx_sql% echo        sum^(case when i.SESSIONTYPE_0 = 14 or i.SESSIONTYPE_0 = 30 then 1 else 0 end^) AS '     Eclipse',
>>%file_adx_sql% echo        ^(select count^(distinct l.ALOGIN_0^) from %DOSS_REF%.ASYSSMDBASSO d
>>%file_adx_sql% echo         join %DOSS_REF%.ASYSSMINTERN l on l.SESSIONID_0 = d.SESSIONID_0
>>%file_adx_sql% echo         join sys.dm_exec_connections s on s.session_id = convert^(integer, d.DBIDENT1_0^)
>>%file_adx_sql% echo         and connect_time = convert^(datetime, d.DBIDENT2_0, 121^)
>>%file_adx_sql% echo         where l.FOLD_0 = i.FOLD_0^)                                                   AS '       Login',
>>%file_adx_sql% echo        sum^(1^)                                                                        AS '      Session'
>>%file_adx_sql% echo from %DOSS_REF%.ASYSSMDBASSO d
>>%file_adx_sql% echo join %DOSS_REF%.ASYSSMINTERN i on i.SESSIONID_0 = d.SESSIONID_0
>>%file_adx_sql% echo join sys.dm_exec_connections s on s.session_id = convert^(integer, d.DBIDENT1_0^) and connect_time = convert^(datetime, d.DBIDENT2_0, 121^)
>>%file_adx_sql% echo where i.SESSIONTYPE_0 ^> 0
if defined LOGIN >>%file_adx_sql% echo and   i.FOLD_0 = '%LOGIN%' -- Lists only for a login
if defined EXCL_LOGIN >>%file_sql% echo and   i.FOLD_0 not in ^('%EXCL_LOGIN%'^) -- Excludes logins
>>%file_adx_sql% echo group by i.FOLD_0
>>%file_adx_sql% echo union all
>>%file_adx_sql% echo select 'Total',
>>%file_adx_sql% echo        isnull^(sum^(case when i.SESSIONTYPE_0 = 35                         then 1 else 0 end^), 0^),
>>%file_adx_sql% echo        isnull^(sum^(case when i.SESSIONTYPE_0 = 33                         then 1 else 0 end^), 0^),
>>%file_adx_sql% echo        isnull^(sum^(case when i.SESSIONTYPE_0 = 25                         then 1 else 0 end^), 0^),
>>%file_adx_sql% echo        isnull^(sum^(case when i.SESSIONTYPE_0 = 20                         then 1 else 0 end^), 0^),
>>%file_adx_sql% echo        isnull^(sum^(case when i.SESSIONTYPE_0 = 14 or i.SESSIONTYPE_0 = 30 then 1 else 0 end^), 0^),
>>%file_adx_sql% echo        ^(select count^(distinct l.ALOGIN_0^) from %DOSS_REF%.ASYSSMDBASSO d
>>%file_adx_sql% echo          join %DOSS_REF%.ASYSSMINTERN l on l.SESSIONID_0 = d.SESSIONID_0
>>%file_adx_sql% echo          join sys.dm_exec_connections s on s.session_id = convert^(integer, d.DBIDENT1_0^)
>>%file_adx_sql% echo          and connect_time = convert^(datetime, d.DBIDENT2_0, 121^)^),
>>%file_adx_sql% echo        isnull^(sum^(1^), 0^)
>>%file_adx_sql% echo from %DOSS_REF%.ASYSSMDBASSO d
>>%file_adx_sql% echo join %DOSS_REF%.ASYSSMINTERN i on i.SESSIONID_0 = d.SESSIONID_0
>>%file_adx_sql% echo join sys.dm_exec_connections s on s.session_id = convert^(integer, d.DBIDENT1_0^) and connect_time = convert^(datetime, d.DBIDENT2_0, 121^)
if not defined LOGIN >>%file_adx_sql% >>%file_adx_sql% echo where i.SESSIONTYPE_0 ^> 0;
if defined LOGIN >>%file_adx_sql% >>%file_adx_sql% echo where i.SESSIONTYPE_0 ^> 0
if defined LOGIN >>%file_adx_sql% echo and   i.FOLD_0 = '%LOGIN%'; -- Lists only for a login
if defined EXCL_LOGIN >>%file_sql% echo and   i.FOLD_0 not in ^('%EXCL_LOGIN%'^) -- Excludes logins
goto:EOF
::#
::# End of Cre_info_psadx
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

:Check_db
::#************************************************************#
::# Checks database for retrieving info and setting max length of data for display
::#
>%file_sql% echo set nocount on
if /I "%CMD_SQL%"=="osql" >>%file_sql% echo PRINT ''
if not "%VER_SQL%"=="11.0" if not "%VER_SQL%"=="12.0" if not "%VER_SQL%"=="13.0" if not "%VER_SQL%"=="14.0" >%file_sql% echo select '%%i='+convert(varchar, getdate(), 3)
>>%file_sql% echo select 'LEN_DBNAME='+cast^(max^(len^(d.name^)^) as varchar^(2^)^) from sys.sysdatabases d;
>>%file_sql% echo select 'VER_SQL='+cast(SERVERPROPERTY('productversion') as char(4));
>>%file_sql% echo select 'MAX_MEM='+cast^(value_in_use as varchar^) from  sys.configurations where  name = 'max server memory ^(MB^)';
if not defined SQL_BDD >>%file_sql% echo create table #len_objects ^(dbname varchar^(50^), tablen int, indlen int^)
if not defined SQL_BDD >>%file_sql% echo exec sp_MSforeachdb @command1='if db_id^(''?''^) ^<= 4 return; use [?]; insert into #len_objects
if not defined SQL_BDD >>%file_sql% echo select db_name^(db_id^(''?''^)^), max^(len^(t.name^)^), max^(len^(i.name^)^) from sys.tables t left outer join sys.indexes i on i.object_id = t.object_id where i.name ^<= ''a'';';
if not defined SQL_BDD >>%file_sql% echo select 'LEN_TABLE='+cast^(isnull^(max^(tablen^),6^) as varchar^(2^)^) from #len_objects;
if not defined SQL_BDD >>%file_sql% echo select 'LEN_INDEX='+cast^(isnull^(max^(indlen^),6^) as varchar^(2^)^) from #len_objects;
if not defined SQL_BDD >>%file_sql% echo drop table #len_objects;
if     defined SQL_BDD >>%file_sql% echo use [%SQL_BDD%]
if exist %ADXDOS%\%DOSS_REF%\FIL\AFCTCUR.srf >>%file_sql% echo select 'LEN_APPFCT='+cast^(isnull^(max^(len(c.FCT_0^)^), 12^)  as varchar^(2^)^) from %DOSS_REF%.AFCTCUR c;
if exist %ADXDOS%\%DOSS_REF%\FIL\AFCTCUR.srf >>%file_sql% echo select 'LEN_APPLOG='+cast^(isnull^(max^(len(c.LOGIN_0^)^), 12^)  as varchar^(2^)^) from %DOSS_REF%.AFCTCUR c;
if not defined LOGIN   >>%file_sql% echo select 'LEN_LOGIN='+cast^(max^(len^(s.login_name^)^) as varchar^(2^)^) from sys.dm_exec_sessions s;
if     defined LOGIN   >>%file_sql% echo select 'LEN_LOGIN='+cast^(max^(len^('%LOGIN%')) as varchar^(2^)^)    -- Lists only for a login
if not defined LOGIN   >>%file_sql% echo select 'LEN_OWNER='+cast^(isnull^(max^(len^(s.name^)^), 5^) as varchar^(2^)^) from sys.schemas s where s.schema_id between 5 and 16383;
if     defined LOGIN   >>%file_sql% echo select 'LEN_OWNER='+cast^(isnull^(max^(len^(s.name^)^), 0^) as varchar^(2^)^) from sys.schemas s where s.name = '%LOGIN%';
if not defined SQL_BDD >>%file_sql% echo select 'LEN_OBJECT='+cast^(max^(len^(o.name^)^) as varchar^(2^)^) from sys.all_objects o where o.type in ^('P','FN'^);
if     defined SQL_BDD >>%file_sql% echo select 'LEN_OBJECT='+cast^(isnull^(max^(len^(o.name^)^), 30^) as varchar^(2^)^) from sys.objects o;
if     defined SQL_BDD >>%file_sql% echo select 'LEN_TABLE='+cast^(max^(len^(t.name^)^) as varchar^(2^)^) from sys.tables t;
if     defined SQL_BDD >>%file_sql% echo select 'LEN_INDEX='+cast^(isnull^(max^(len^(i.name^)^), 30^) as varchar^(2^)^) from sys.indexes i where name ^<= 'a';
>>%file_sql% echo select 'LEN_SQLTEXT='+cast^(max^(len^(t.text^)^) as varchar^(5^)^) from sys.dm_exec_requests r cross apply sys.dm_exec_sql_text^(r.sql_handle^) t;
call :Display_script LIST OF INSTRUCTIONS IN THE SQL SCRIPT [%file_sql%]
if defined     DB_PWD %CMD_SQL% -S %DB_NAM% -U %DB_USER% -d master -i %file_sql% -o %file_tmp% -P %DB_PWD% -h-1
if not defined DB_PWD %CMD_SQL% -S %DB_NAM% -E -d master -i %file_sql% -o %file_tmp% -h-1
type %file_tmp% | findstr "Msg Error:" >NUL
if not errorlevel 1 (
	if defined     DB_PWD if "%DISPLAY%"=="1" >>%file_log% echo %CMD_SQL% -S %DB_NAM% -U %DB_USER% -d master -i %file_sql% -o %file_tmp% -P %DB_PWD%
	if not defined DB_PWD if "%DISPLAY%"=="1" >>%file_log% echo %CMD_SQL% -S %DB_NAM% -E -d master -i %file_sql% -o %file_tmp%
	echo:
	echo ------------------
	type %file_tmp% | findstr /B /V /C:" " | findstr "^[A-Z].*"
	echo ------------------
	echo:
	if defined DB_PWD (call :Display ERROR: UNABLE TO CONNECT TO DATABASE [%SQLS7_SID%] USING SQL SERVER AUTHENTICATION [%DB_USER%] !!) else (call :Display ERROR: UNABLE TO CONNECT TO DATABASE [%SQLS7_SID%] USING WINDOWS AUTHENTICATION [%userdomain%\%username%] !!)
	call :Display STATUS : KO
	del %file_tmp% %file_log%
	set RET=1
	exit /B 1
) else (
	setlocal enabledelayedexpansion
	for /f "tokens=2 delims==" %%a in ('type %file_tmp% ^| find "LEN_DBNAME"') do endlocal & set "LEN_DBNAME=%%a"
	setlocal enabledelayedexpansion
	for /f "tokens=2 delims==" %%a in ('type %file_tmp% ^| find "VER_SQL"') do endlocal & set "VER_SQL=%%a"
	setlocal enabledelayedexpansion
	for /f "tokens=2 delims==" %%a in ('type %file_tmp% ^| find "MAX_MEM"') do endlocal & set "MAX_MEM=%%a"
	setlocal enabledelayedexpansion
	for /f "tokens=2 delims==" %%a in ('type %file_tmp% ^| find "MAX_MEM"') do endlocal & set "MAX_MEM=%%a"
	setlocal enabledelayedexpansion
	for /f "tokens=2 delims==" %%a in ('type %file_tmp% ^| find "LEN_APPFCT"') do endlocal & set "LEN_APPFCT=%%a"
    endlocal
	setlocal enabledelayedexpansion
	for /f "tokens=2 delims==" %%a in ('type %file_tmp% ^| find "LEN_APPLOG"') do endlocal & set "LEN_APPLOG=%%a"
	endlocal
	setlocal enabledelayedexpansion
	for /f "tokens=2 delims==" %%a in ('type %file_tmp% ^| find "LEN_LOGIN"') do endlocal & set "LEN_LOGIN=%%a"
	setlocal enabledelayedexpansion
	for /f "tokens=2 delims==" %%a in ('type %file_tmp% ^| find "LEN_TABLE"') do endlocal & set "LEN_TABLE=%%a"
	setlocal enabledelayedexpansion
	for /f "tokens=2 delims==" %%a in ('type %file_tmp% ^| find "LEN_INDEX"') do endlocal & set "LEN_INDEX=%%a"
	setlocal enabledelayedexpansion
	for /f "tokens=2 delims==" %%a in ('type %file_tmp% ^| find "LEN_OWNER"') do endlocal & set "LEN_OWNER=%%a"
	setlocal enabledelayedexpansion
	for /f "tokens=2 delims==" %%a in ('type %file_tmp% ^| find "LEN_OBJECT"') do endlocal & set "LEN_OBJECT=%%a"
	setlocal enabledelayedexpansion
	for /f "tokens=2 delims==" %%a in ('type %file_tmp% ^| find "LEN_SQLTEXT"') do endlocal & set "LEN_SQLTEXT=%%a"
	set RET=0
)
set LEN_DBNAME=%LEN_DBNAME: =%
set VER_SQL=%VER_SQL: =%
set MAX_MEM=%MAX_MEM: =%
set LEN_LOGIN=%LEN_LOGIN: =%
set LEN_TABLE=%LEN_TABLE: =%
set LEN_INDEX=%LEN_INDEX: =%
set LEN_OWNER=%LEN_OWNER: =%
set LEN_OBJECT=%LEN_OBJECT: =%
set LEN_SQLT=%LEN_SQLT: =%
if defined LOGIN if "%LEN_OWNER%" == "0" (
   call :Display ERROR: Invalid value for the variable "LOGIN" [%LOGIN%] !!
   set RET=1
)
if defined LOGIN if "%LEN_OWNER%" LSS "5" set LEN_OWNER=5
if not defined LEN_APPFCT set LEN_APPFCT=20
if not defined LEN_APPLOG set LEN_APPLOG=20
if %LEN_SQLTEXT% LSS %LEN_SQLT%   set LEN_SQLT=%LEN_SQLTEXT%
if %LEN_APPFCT%  LSS %LEN_APPLOG% set LEN_APPFCT=%LEN_APPLOG%
if %LEN_APPLOG%  LSS %LEN_APPFCT% set LEN_APPLOG=%LEN_APPFCT%
if not "%VER_SQL:~-2,1%"=="." set VER_SQL=%VER_SQL:~,-1%
if "%DISPLAY%"=="1" echo LEN_DBNAME=[%LEN_DBNAME%] VER_SQL=[%VER_SQL%] MAX_MEM=[%MAX_MEM%] LEN_APPFCT=[%LEN_APPFCT%] LEN_APPLOG=[%LEN_APPLOG%] LEN_LOGIN=[%LEN_LOGIN%] LEN_TABLE=[%LEN_TABLE%] LEN_INDEX=[%LEN_INDEX%] LEN_OWNER=[%LEN_OWNER%] LEN_OBJECT=[%LEN_OBJECT%]
del %file_tmp%
exit /B %RET%
::# End of Check_db
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

:Check_versql
::#************************************************************#
::# Checks SQL Server version (must be 9.x, 10.x, 11.x, 12.x, 13.x, 14.x or 15.x)
::#
set RET=1
for /f "tokens=2 delims= " %%i in ('bcp -v ^| findstr "Vers"') do set VER_SQL=%%i
for /f "tokens=1,2 delims=." %%i in ('echo %VER_SQL%') do set VER_SQL=%%i.%%j
if not "%VER_SQL:~-2,1%"=="." set VER_SQL=%VER_SQL:~,-1%
if not "%VER_SQL%"=="9.0" if not "%VER_SQL%"=="10.0" if not "%VER_SQL%"=="10.5" if not "%VER_SQL%"=="11.0" if not "%VER_SQL%"=="12.0" if not "%VER_SQL%"=="13.0" if not "%VER_SQL%"=="14.0" if not "%VER_SQL%"=="15.0" (
	echo ERROR: Bad version number for SQL Server [%VER_SQL%] : 2005, 2008, 2012, 2014, 2016, 2017 or 2019 required !!
	echo:
	exit /B 1
)
set RET=0
goto:EOF
::#
::# End of Check_versql
::#************************************************************#

:Check_versys
::#************************************************************#
::# Checks operating system version for Windows (must be 2008, 2012, 2016 or 2019)
::#
set RET=1
for /f "tokens=4" %%i in ('ver') do set VER_SYS=%%i
set VER_SYS=%VER_SYS:~,3%
if "%OS%"=="Windows_NT" (
	if not "%VER_SYS%" == "6.1" if not "%VER_SYS%" == "6.2" if not "%VER_SYS%" == "6.3" if not "%VER_SYS%" == "10." (
		echo ERROR: Bad version number for Windows [%VER_SYS%] : 2008, 2012, 2016 or 2019 required !!
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
call :Display #  Monitors current lock during a period in the SQL instance [%DB_SRV%\%DB_SVC%].
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
echo              /P = Collects Windows and SQL Server performance counters in an output text file
echo              /E = Displays last Windows event logs collected type system and application
echo              /T = Lists running processes with associated information in an output text file
echo              /F = Displays fragmentation analysis report for each volume disk
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
call :Sleep %DELAY%

:: Returns the exit code
exit /B %RET%
