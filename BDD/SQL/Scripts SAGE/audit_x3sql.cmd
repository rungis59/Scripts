@echo off && mode con lines=50 cols=132 && color f1
::##################################################################################################################################
::#
::# audit_x3sql.cmd
::#
::# Description : Makes a SQL Server audit for database used with a Sage product.
::#
::# Last date   : 15/01/2021
::#
::# Version     : WINDOWS - 2.13
::#
::# Author      : F.SUSSAN / SAGE
::#
::# Syntax      : audit_x3sql [/V] [<TARGET> ...]
::#
::# Notes       : This script can be executed on the Sage X3 applicative server in v5, v6, v7+, v11 or v12 version otherwise direcly on the database server.
::#               The database in version SQL Server 2005/2008/2012/2014/2016, can be located on a different Windows server.
::#               A SQL script is generated to be executed with sqlcmd with the "sa" or windows account.
::#
::#               All SQL Server elements are checked by default else individually with the matching keyword:
::#               - Hardware information                   (HOST option)
::#               - Always On Availability Group           (AAG  option)
::#               - SQL instance info                      (DB   option)
::#               - DB info                                (DB   option)
::#               - DB activity                            (DB   option)
::#               - DB size                                (DB   option)
::#               - Services                               (DB   option)
::#               - Registry                               (DB   option)
::#               - Linked servers                         (DB   option)
::#               - Log Shipping summary & history         (DB   option)
::#               - Configuration options & trace flags    (OPT  option)
::#               - Last backup, LOG backup                (BAK  option)
::#               - DB restore and corruption              (BAK  option)
::#               - Maintenance plans                      (JOB  option)
::#               - Job history and detail                 (JOB  option)
::#               - Job operators                          (JOB  option)
::#               - Memory usage                           (MEM  option)
::#               - Buffer cache hit ratio & usage         (MEM  option)
::#               - Memory metrics                         (MEM  option)
::#               - DB files info                          (FILE option)
::#               - DB files activity                      (FILE option)
::#               - IO usage & activity                    (FILE option)
::#               - Pending disk IO                        (FILE option)
::#               - LOG usage, growth and activity         (LOG  option)
::#               - Virtual Logs summary & detail          (LOG  option)
::#               - TempDB space, usage and allocation     (TEMP option)
::#               - Object Count                           (OBJ  option)
::#               - Object Count                           (OBJ  option)
::#               - Trigger usage                          (OBJ  option)
::#               - Space used summary & detail            (OBJ  option)
::#               - Most large objects summary & detail    (OBJ  option)
::#               - Most fragmented index summary & detail (OBJ  option)
::#               - Index fill factor                      (OBJ  option)
::#               - Indexes with a non default Fill Factor (OBJ  option)
::#               - Clustered indexes                      (OBJ  option)
::#               - Partitioned tables                     (OBJ  option)
::#               - Candidates for partition keys          (OBJ  option)
::#               - Top usage objects                      (OBJ  option)
::#               - Top compression estimates              (OBJ  option)
::#               - SQL traces and log files               (ERR  option)
::#               - SQL Error logs summary & detail        (ERR  option)
::#               - SQL Agent logs summary & detail        (ERR  option)
::#               - Wait Events & waiting tasks            (WAIT option)
::#               - Latches                                (WAIT option)
::#               - CPU pressure & usage                   (CPU  option)
::#               - Latest TOP CPU                         (CPU  option)
::#               - Context switching                      (CPU  option)
::#               - Logins                                 (USER option)
::#               - DB Users                               (USER option)
::#               - Role members                           (USER option)
::#               - Grants                                 (USER option)
::#               - Logins not granted                     (USER option)
::#               - Orphaned users                         (USER option)
::#               - Session Count                          (USER option)
::#               - Session usage                          (USER option)
::#               - Session waits                          (USER option)
::#               - Blocking processes and lock escalation (LOCK option)
::#               - Most unsuccessful Lock Escalations     (LOCK option)
::#               - Indexes under row-locking pressure     (LOCK option)
::#               - Object statistics (summary)            (STAT option)
::#               - Oldest objects statistics              (STAT option)
::#               - Missing indexes (potentially)          (PERF option)
::#               - SQL Server performance counters        (PERF option)
::#               - Query store and Automatic tuning       (PERF option)
::#               - Long running SQL                       (SQL  option)
::#               - Top SQL ordered by Elapsed time        (SQL  option)
::#               - Top SQL ordered by CPU time            (SQL  option)
::#               - Top SQL ordered by Physical reads      (SQL  option)
::#               - Most common SQL                        (SQL  option)
::#
::#               ATTENTION,
::#               - The ADXDIR variable must be set otherwise variables used to connect database (SQL_HOME, SQL_SID and SQL_BDD).
::#               - Table compression and partitioning requires Enterprise Edition and is available in Standard from SQL Server 2016 SP1. 
::#
::# Examples    : audit_x3sql
::#                   Makes a SQL Server audit for all elements in the database specified in settings
::#               audit_x3sql SQL PERF
::#                   Makes a SQL Server audit for DB files in the database specified in settings
::#               audit_x3sql FILE
::#                   Makes a SQL Server audit for DB files in the database specified in settings
::#
::# Exit status : = 0 : OK
::#               = 1 : !! ERROR !!
::#               = 2 : ** WARN **
::#
::# Copyright © 2011-2021 by SAGE Professional Services - All Rights Reserved.
::#
::##################################################################################################################################
::#
::# Modifications history
::# --------------------------------------------------------------------------------------------------------------------------------
::# ! Date       ! Version ! Author       ! Description
::# !------------+---------+--------------+-----------------------------------------------------------------------------------------
::# ! 11/12/2014 !  1.07   ! F.SUSSAN     ! Official use of the script by the French IT & System Sage X3 team.
::# !------------+---------+--------------+-----------------------------------------------------------------------------------------
::# ! 22/01/2015 !  1.08   ! F.SUSSAN     ! This script is now compatible in multi-tiers when the database server
::# !            !         !              ! is separated from the applicative server.
::# !            !         !              ! Using the "format" function compatible only from SQL Sever 2012.
::# !            !         !              ! Adds the SQL version in the banner of the SQL script generated.
::# !------------+---------+--------------+-----------------------------------------------------------------------------------------
::# ! 25/02/2015 !  1.08a  ! F.SUSSAN     ! Fixed when checking the SQL Server version (VER_SQL).
::# !            !         !              ! Uses variables "DB_SRV\DB_SVC" as SQL instance in the SQL connexion.
::# !------------+---------+--------------+-----------------------------------------------------------------------
::# ! 20/03/2015 !  1.08b  ! F.SUSSAN     ! Compatibility ensured in X3 V7 version with Oracle 11g R2.
::# !            !         |              ! Displays the content of the script generated only if DISPLAY variable is set.
::# !            !         !              ! Adds the current date in the trace file name.
::# !            !         !              ! Adds the count of objects per schema.
::# !------------+---------+--------------+-----------------------------------------------------------------------------------------
::# ! 05/05/2015 !  1.08c  ! F.SUSSAN     ! Adds the case when the system format date is in Spanish : "dd-mm-aa" (Info_sysdate).
::# !            !         !              ! Adds /V option to display the version number, the last modified date of the program,
::# !            !         !              ! and the list of variables modified & functions defined.
::# !------------+---------+--------------+-----------------------------------------------------------------------------------------
::# ! 20/01/2016 !  1.08d  ! F.SUSSAN     ! Adds the "Buffer cache Hit Ratio" info in the "FILE" section.
::# !            !         !              ! Adds list of "missing indexes" in the "OBJ" section.
::# !            !         !              ! Adds the "CPU pressure" in the "WAIT" section.
::# !            !         !              ! Creates a new section: "JOB" including "Maintenance plans" and "History jobs".
::# !            !         !              ! Fixes the file size for "DB files info" in the "FILE" section.
::# !------------+---------+--------------+-----------------------------------------------------------------------------------------
::# ! 26/02/2016 !  1.09   ! F.SUSSAN     ! Compatibility ensured from X3 PU8 version with SQL Server 2014.
::# !            !         !              ! Adds a new item "IO activity" in the FILE section.
::# !            !         !              ! Adds the variable "DB_USER' to define the account for SQL Server authentication ('sa' by default).
::# !            !         !              ! Increases the display width size for the "Owner" field (10 instead of 8).
::# !------------+---------+--------------+-----------------------------------------------------------------------------------------
::# ! 03/10/2016 !  1.09a  ! F.SUSSAN     ! Adds the Windows authentication mode to connect database if the variable "DB_PWD" is not set.
::# !------------+---------+--------------+-----------------------------------------------------------------------------------------
::# ! 15/11/2016 !  2.01   ! F.SUSSAN     ! Added the function "Check_versys" to check the operating system version for Windows.
::# !            !         !              ! Fixed the timer in the function "Sleep".
::# !------------+---------+--------------+-----------------------------------------------------------------------------------------
::# ! 15/02/2017 !  2.02   ! F.SUSSAN     ! Sets the variable "TIM" in the function "Info_sysdate".
::# !            !         !              ! Changed the display format for the "Aged" column in the "Last backup" item.
::# !            !         !              ! Displayed the command line used for the SQL connection in case of error (DISPLAY=1).
::# !            !         !              ! Added paging memory usage and 'Available Physical State' in the "Hardware information" item.
::# !            !         !              ! Updated system and background process wait types to ignore in the "Wait Events" item.
::# !            !         !              ! Added a count number of session group by program name in the "Session Count" item.
::# !            !         !              ! Added lock a count number of session group by program name in the "Session Count" item.
::# !            !         !              ! Added new items lock escalation history and disable in the LOCK section.
::# !------------+---------+--------------+-----------------------------------------------------------------------------------------
::# ! 09/06/2017 !  2.03   ! F.SUSSAN     ! Fixed display for the "Wait events" item.
::# !            !         !              ! Added new item "Long running query" in the SQL section.
::# !            !         !              ! Improved content of the "TOP SQL activity" in the SQL section.
::# !            !         !              ! Added the system time in the trace file name.
::# !            !         !              ! Fixed null values for the "Missing Index (potentially)" item in the OBJ section.
::# !------------+---------+--------------+-----------------------------------------------------------------------------------------
::# ! 29/06/2017 !  2.04   ! F.SUSSAN     ! Added latency information about database files in the section "DB files activity".
::# !            !         !              ! Added new item "Objects in cache" in the OBJ section.
::# !            !         !              ! Added new item "SQL trace" in the LOG section.
::# !            !         !              ! Added new items "Top usage objects" and "Unused indexes" in the OBJ section.
::# !            !         !              ! Added "Worker time (s)" and "Is parallel query" info in the "Long running SQL" item.
::# !------------+---------+--------------+-----------------------------------------------------------------------------------------
::# ! 24/07/2017 !  2.05   ! F.SUSSAN     ! Added a new variable "language" to get OS language from the Windows registry.
::# !            !         !              ! Added "Language" in the "SQL Server info" item.
::# !            !         !              ! Added "Log Size" and "Log Used" infos in the "DB info" item.
::# !            !         !              ! Added "Compressed size (MB)" info in the "Last backup" item.
::# !            !         !              ! Added Total indexes to reorganize and rebuild in the "Most Fragmented indexes" item.
::# !------------+---------+--------------+-----------------------------------------------------------------------------------------
::# ! 09/10/2017 !  2.05a  ! F.SUSSAN     ! Added new item "Temporary tables" in the OBJ section.
::# !------------+---------+--------------+-----------------------------------------------------------------------------------------
::# ! 17/10/2017 !  2.06   ! F.SUSSAN     ! Added the compatibility for SQL Server 2016.
::# !            !         !              ! Added new item "Objects in buffer cache" in the OBJ section.
::# !------------+---------+--------------+-----------------------------------------------------------------------------------------
::# ! 06/11/2017 !  2.06a  ! F.SUSSAN     ! Replaced the obsolete "osql" command line utility by "sqlcmd".
::# !            !         !              ! Fixed SQL queries compatible for SQL Server 2016 version.
::# !            !         !              ! Changed display TOPNSQL group by segment name for "Most large objects" and "Most Fragmented indexes"
::# !            !         !              ! items in the OBJ section and schema name for "Oldest object statistics" in the STAT section.
::# !------------+---------+--------------+-----------------------------------------------------------------------------------------
::# ! 14/11/2017 !  2.06b  ! F.SUSSAN     ! Added the SQL_SID variable required if the ADXDIR variable is not set.
::# !            !         !              ! Added the SQL_BDD variable that can be used if the ADXDIR variable is not set to define
::# !            !         !              ! the SQL Server user database by default else all existing one.
::# !            !         !              ! Used the LIKE keyword with the [ ] wildcard characters from the "Temporary tables" item in the OBJ section.
::# !            !         !              ! Added supplemental object types from the "Object count" item in the OBJ section.
::# !            !         !              ! Used the sp_MSforeachdb procedure to display the name of each database for some queries.
::# !            !         !              ! Added "Last Backup" and "Is Auto Create Stats" infos in the "DB Info" item.
::# !            !         !              ! Added the start backup date in the "Last backup" item and list ordered by end backup date.
::# !            !         !              ! Added supplemental infos about temporary tables in the tempdb database.
::# !            !         !              ! Added new item "Invalid objects" in the OBJ section.
::# !            !         !              ! Changed name for missing indexes now grouped by user database and removed square brackets.
::# !            !         !              ! Added "IO load (%)" info in the "DB files activity" item.
::# !            !         !              ! Added "Description" and "Category" infos from the "Maintenance plans" item in the JOB section.
::# !            !         !              ! Added the "Processor description" info in the "Hardware information" item and improved the output.
::# !            !         !              ! Added the "Authentication mode" info in the "SQL instance info" item.
::# !            !         !              ! Added members of "Local Administrators" group and sysadmins server role in the "Logins" item.
::# !------------+---------+--------------+-----------------------------------------------------------------------------------------
::# ! 10/04/2018 !  2.07   ! F.SUSSAN     ! Added list of trace flags enabled globally for the SQL Server instance.
::# !            !         !              ! Changed the display length dynamically for info such as DB, login, table and index name.
::# !            !         !              ! Added the list of SQL services in the DB section.
::# !            !         !              ! Added the last full, diff & LOG backup and fixed aged info in the "Last backup" item.
::# !            !         !              ! Added volume disks from the "Hardware information" in the HOST section.
::# !------------+---------+--------------+-----------------------------------------------------------------------------------------
::# ! 11/04/2018 !  2.07a  ! F.SUSSAN     ! Compatibility ensured for Windows Server 2016.
::# !------------+---------+--------------+-----------------------------------------------------------------------------------------
::# ! 14/05/2018 !  2.07b  ! F.SUSSAN     ! Added system databases in the "DB files activity" item ordered by database name.
::# !            !         !              ! Added the "Latest TOP CPU" and "Context switching" items in the new CPU section.
::# !            !         !              ! Added "SQL Server performance counters" in the new PERF section.
::# !            !         !              ! Added "SQL Plan cache" in the SQL section
::# !            !         !              ! Added "Max DOP" in the "Most expensive SQL" item ordered now by Last CPU time.
::# !            !         !              ! Added log files in the "DB files info" item.
::# !            !         !              ! Added "Pending disk IO" item in the FILE section.
::# !            !         !              ! Added "Most large objects (summary)" item in the OBJ section.
::# !------------+---------+--------------+-----------------------------------------------------------------------------------------
::# ! 29/05/2018 !  2.07c  ! F.SUSSAN     ! Added "Manufacturer" and "Product name" infos in the "Hardware information" item.
::# !------------+---------+--------------+-----------------------------------------------------------------------------------------
::# ! 26/06/2018 !  2.07d  ! F.SUSSAN     ! Added "TempDB space" item in the TEMP section.
::# !------------+---------+--------------+-----------------------------------------------------------------------------------------
::# ! 18/09/2018 !  2.07e  ! F.SUSSAN     ! Added "Max Server memory" item in the MEM section.
::# !            !         !              ! Added "Clustered indexes" item in the OBJ section.
::# !            !         !              ! Added "Space used" item in the OBJ section.
::# !            !         !              ! Added Disk statistics infos in HOST section.
::# !            !         !              ! Added "Trigger usage" item in OBJ section.
::# !            !         !              ! Fixed when checking SQL version depending the default language configured on the server.
::# !            !         !              ! Added the PROG variable to identify the program name for applicative SQL session.
::# !            !         !              ! Improved display for "Object count" item in the OBJ section.
::# !            !         !              ! Fixed value for "Auto Growth" in the "DB file info" item.
::# !            !         !              ! Fixed value for last and total elapsed time reported in secs in the "Most expensive SQL".
::# !            !         !              ! Added the LEN_DBFILE to set dynamically the display length of filename in the report.
::# !------------+---------+--------------+-----------------------------------------------------------------------------------------
::# ! 10/10/2018 !  2.08   ! F.SUSSAN     ! Added the display of compatibility level for SQL Server 2016 in the "DB info" item.
::# !            !         !              ! Changed the "Most large fragmented indexes" in the OBJ section.
::# !            !         !              ! Added the "DB activity" item in the DB section.
::# !------------+---------+--------------+-----------------------------------------------------------------------------------------
::# ! 12/11/2018 !  2.08a  ! F.SUSSAN     ! Added the "Session usage (Summary)" in the USER section.
::# !------------+---------+--------------+-----------------------------------------------------------------------------------------
::# ! 12/12/2018 !  2.08b  ! F.SUSSAN     ! Changed minimum duration (>=1mn) for "Long running query" in the SQL section.
::# !            !         !              ! Improved display for "Most expensive SQL" item in the SQL section.
::# !            !         !              ! Added "Parameter compiled value" for "Most expensive SQL" item in the SQL section.
::# !            !         !              ! Fixed display of "Last backup" for each database and distinct type (Full, Transaction log, ...).
::# !            !         !              ! Changed content of "Type" info in the "DB files info" and "DB files activity" items.
::# !            !         !              ! Added the "IO Latency (%)" info in the "DB files activity" item.
::# !            !         !              ! Reduced length of each field in the "Object count" item.
::# !            !         !              ! Fixed display for "Space used" item in the OBJ section.
::# !            !         !              ! Increased alert threshold to detect CPU pressure (signal CPU waits must be < 25%).
::# !            !         !              ! Changed from OBJ to PERF section for the "Missing indexes (potentially)" item.
::# !            !         !              ! Improved display of "Missing indexes (potentially)" only for largest tables and for each database.
::# !            !         !              ! Added the "Mem Locked (GB)" info in the "Max Server memory" item.
::# !------------+---------+--------------+-----------------------------------------------------------------------------------------
::# ! 15/01/2019 !  2.09   ! F.SUSSAN     ! Added the "Uptime" info in the "Hardware information item".
::# !            !         !              ! Added the new AAG section to get infos about Always On Availability Group only if enabled.
::# !            !         !              ! Specified only one database when the SQL_BDD variable is used with the sp_MSforeachdb procedure.
::# !            !         !              ! Put the PERF and SQL sections at the end of the report.
::# !            !         !              ! Enlarged display for SQL text in the "Most expensive SQL" item.
::# !            !         !              ! Added the new variable FMT_TIME to specify the format time = 'HH:mm:ss' used by default.
::# !            !         !              ! Improved display for "TempDB usage" in the TEMP section.
::# !            !         !              ! Added detail last 48 hours in the "Job history" item.
::# !            !         !              ! Added detail per database for the "SQL Plan cache" item in the SQL section.
::# !            !         !              ! Displayed Most large fragmented indexes only with size >= 10MB in the OBJ section.
::# !            !         !              ! Fixed the max display length for table and index names in all existing user databases.
::# !            !         !              ! Fixed the "Size (%)" info in the "Most large objects (summary)" item.
::# !            !         !              ! Added the target option as prefix in the name of the trace file if one argument is passed to the script.
::# !------------+---------+--------------+-----------------------------------------------------------------------------------------
::# ! 24/01/2019 !  2.09a  ! F.SUSSAN     ! Fixed a SQL statement because of a limitation of 2000 characters with the use of the Sp_msforeachdb function.
::# !            !         !              ! Drop the temporary table "%TMPTAB%" if existing in the USER section.
::# !            !         !              ! Added "Max DOP" in the "Most expensive SQL" only from SQL Server 2016. 
::# !            !         !              ! Sets by default the variable "NBR_RET" about the number of days retention (=14).
::# !------------+---------+--------------+-----------------------------------------------------------------------------------------
::# ! 01/02/2019 !  2.09b  ! F.SUSSAN     ! Added the new variable "NBR_RET" about the number of days retention (=14 by default).
::# !            !         !              ! Displays detail per database only for the database specified if asked in the "SQL Plan cache item".
::# !            !         !              ! Added configuration at level database from SQL Server 2016 in the "Database configuration" item.
::# !            !         !              ! Fixed SQL version detected when exists multiple installation path for SQL Server.
::# !            !         !              ! Added new "DB size" item in the DB section.
::# !            !         !              ! Enlarged display for the parameter compiled value in the SQL section.
::# !            !         !              ! Added the variable "TARGET" to list each section for auditing (ALL by default).
::# !            !         !              ! Added "Install" date and "Is Always On" flag for the "SQL instance info" item in the DB section.
::# !            !         !              ! Added the "DB restore" item in the BAK section.
::# !------------+---------+--------------+-----------------------------------------------------------------------------------------
::# ! 02/04/2019 !  2.10   ! F.SUSSAN     ! Sage X3 is now called Sage EM (Sage Business Cloud Enterprise Management).
::# !            !         !              ! Added backard compatibility for Sage X3 Product V5 under Windows Server 2003.
::# !            !         !              ! Changed connection to execute SQL script from master and not user database.
::# !            !         !              ! Added the Check_db function.
::# !            !         !              ! Replaced the PWD_SYS and USR_SYS by DB_PWD and DB_USER variables.
::# !            !         !              ! Added the CMD_SQL variable to choose SQL Server command used to connect database (sqlcmd or osql).
::# !            !         !              ! Displayed list of SQL services in the DB section only from SQL Server 2008 R2.
::# !            !         !              ! Displayed the "Compressed Size (MB)" info in the "Last backup" only from SQL Server 2008 R2. 
::# !            !         !              ! Displayed the "Max Server memory" item in the MEM section only from SQL Server 2008.
::# !            !         !              ! Displayed the "Lock Escalation disable" in level table only from SQL Server 2008.
::# !            !         !              ! Added the "Job operators" item in the JOB section.
::# !            !         !              ! Added list of "DB Users" with "Role members" and "Grants" for each database.
::# !            !         !              ! Added the variable LEN_SQLTEXT to limit the max length display of running SQL statements.
::# !            !         !              ! Added the variable LEN_LINE to define the max display output line in the report.
::# !            !         !              ! Improved the "Latest TOP CPU" item to show history of values every 10 min.
::# !            !         !              ! Check value for the LOGIN variable if set.
::# !            !         !              ! Added display of SQL statements for possible MODIFY and SHRINK file operations in the "DB files info" item.
::# !            !         !              ! Fixed the value for performance counters per second in the PERF section.
::# !            !         !              ! Added the FLG_FRAG variable to check or not index fragmentation that can cause a slow running of the script.
::# !            !         !              ! Added the new item "Index fill factor" in the OBJ section.
::# !            !         !              ! Added the new item "Object statistics summary" in the STAT section.
::# !            !         !              ! Added the new item "Latches" in the WAIT section.
::# !            !         !              ! Added the new item "Space used" by schema in the OBJ section.
::# !------------+---------+--------------+-----------------------------------------------------------------------------------------
::# ! 02/08/2019 !  2.10a  ! F.SUSSAN     ! Rollback to the name of the Sage product : "Sage EM" => "Sage X3".
::# !            !         !              ! Displayed "Unknown" in the "Hardware information" item where system BIOS info is NULL.
::# !------------+---------+--------------+-----------------------------------------------------------------------------------------
::# ! 03/10/2019 !  2.10b  ! F.SUSSAN     ! Added the "Instant file initialization" info available from SQL Server 2016 in the "Services" item.
::# !            !         !              ! Used the "Audit_stat" or "Audit_stat_old" function depending of the SQL Server version.
::# !------------+---------+--------------+-----------------------------------------------------------------------------------------
::# ! 21/10/2019 !  2.10c  ! F.SUSSAN     ! Added the "Object statistics (summary)" item from SQL Server 2012+.
::# !            !         !              ! Added the STALE variable to define after how many days last statistics about objects are considered obsolete.
::# !            !         !              ! Added the total number of sample rows in the "Oldest object statistics (Detail)" item in the STAT section.
::# !            !         !              ! Fixed the compute of the "Physical CPU Count" value in the "Hardware information" item.
::# !            !         !              ! Added the following infos in the "Hardware information" in the HOST section:
::# !            !         !              ! - the "memory model" used by SQL Server to allocate memory (from SQL Server 2016)
::# !            !         !              ! - the "Affinity type" which is the type of server CPU process affinity currently in use
::# !            !         !              ! - the "Soft-NUMA" that specifies the way NUMA nodes are configured (from SQL Server 2016)
::# !            !         !              ! - the "Is compressed?" to indicate if each volume disk on which database files are stored is compressed or not.
::# !            !         !              ! Added the FLG_DBO variable to include or not the default SQL Server schema (dbo) in the database audit.
::# !------------+---------+--------------+-----------------------------------------------------------------------------------------
::# ! 27/11/2019 !  2.11   ! F.SUSSAN     ! Fixed display when unable to connect to database using SQL Server authentication.
::# !            !         !              ! Added the class wait info in the "Latches" item in the WAIT section.
::# !            !         !              ! Added the 'Session waits" item in the USER section available from SQL Server 2016.
::# !            !         !              ! Added the "Registry" item in the DB section.
::# !            !         !              ! Renamed the log file including the name of the user database.database audit.
::# !------------+---------+--------------+-----------------------------------------------------------------------------------------
::# ! 26/02/2020 !  2.12   ! F.SUSSAN     ! Added compatibility for SQL Server 2017 and Windows Server 2019.
::# !            !         !              ! Displayed only statistics about SQL user and not system sessions.
::# !            !         !              ! Added the "Linked servers" item in the DB section.
::# !            !         !              ! Added the "Logins not granted" and "Orphaned users" items in the USER section.
::# !            !         !              ! Added the "LOG usage" item in the FILE section.
::# !            !         !              ! Added "Automatic tuning" (option and recommendation) in the PERF section available from SQL Server 2017.
::# !            !         !              ! Added the "Long running Query Store" in the PERF section available from SQL Server 2017.
::# !            !         !              ! Added the "Virtual Logs" summary & detail in the FILE section.
::# !            !         !              ! Added the "LOG backup" item in the BAK section available from SQL Server 2017.
::# !            !         !              ! Added the "Auto Growth All Files" info in the "DB files info" item available from SQL Server 2016.
::# !            !         !              ! Added the "Buffer usage" in the MEM section.
::# !            !         !              ! Added the "IO usage" in the FILE section.
::# !            !         !              ! Added the "CPU usage" in the CPU section.
::# !            !         !              ! Displayed only non-default database scoped configuration for each database from SQL server 2016.
::# !            !         !              ! Added the "Database corruption" item in the BAK section available from SQL Server 2016.
::# !            !         !              ! Added "NUMA Memory usage" infos in the "Hardware information" item.
::# !            !         !              ! Added the "Job history (detail)" item in the JOB section.
::# !            !         !              ! Added the "TempDB contention" item in the TEMP section.
::# !            !         !              ! Added the "Invalid" flag in the "Logins" item for Windows users that does not exist in Active Directory.
::# !            !         !              ! Added the TMPTAB variable to define the temporary working table used in the SQL script.
::# !            !         !              ! Added the "Pages fault" info in the "Max Server memory" item.
::# !            !         !              ! Added the "Cache size free (GB)" in the "Buffer usage" item.
::# !            !         !              ! Added the "Last cached" info in the "Most expensive SQL" item.
::# !            !         !              ! Initialized default value for the FMT_TIME variable if not set.
::# !            !         !              ! Added the "Uptime" in the "SQL instance info" in the DB section.
::# !            !         !              ! Added the "LOG activity" item in the LOG section.
::# !            !         !              ! Added the LEN_FULLSQLT variable to define Display length used for Full SQL Text.
::# !            !         !              ! Added the EXCL_TARGET variable to exclude list of target section to audit.
::# !            !         !              ! Added the "Total Objects" and "Stale (%)" infos in the "Object statistics (summary)" item. 
::# !            !         !              ! Updated the database compatibility level info in the "DB info" item.
::# !            !         !              ! Added the "Cardinality Estimator" in the "DB info" item. 
::# !            !         !              ! Added a new ERR section for the SQL alert log and moved the LOG activity to the LOG section.
::# !            !         !              ! Added the "SQL Agent logs (summary)" and "SQL Agent logs (detail)" in the ERR section.
::# !            !         !              ! Added the "SQL log files" in the ERR section for listing SQL Error log files.
::# !            !         !              ! Added "HISLOG", "NUMLOG", "STRLOG1" and "STRLOG2" variables to display current, archive or all SQL Error log files.
::# !            !         !              ! Displayed only main informations in the list of "Lock Escalation + Waits" group by user database.
::# !            !         !              ! Added the "Most unsuccessful Lock Escalations" and "Indexes under row-locking pressure" in the LOCK section.
::# !            !         !              ! Added the "*** TOTAL ***" info for each "Session Count" item list in the USER section.
::# !            !         !              ! Added the "Min/Max Login Time" and  "Authentication method" infos in the "Session Count" item ordered by Login.
::# !            !         !              ! Added the "Client protocol" and "TCP port" infos in the "Session count" item ordered by Program.
::# !            !         !              ! Added the "Is NUMA Enabled?" info in the "SQL instance info" item.
::# !            !         !              ! Changed in uppercase the SQL instance name used in the DB_SVC variable.
::# !            !         !              ! Fixed size value in megabytes specified for the SQL command used to shrink logfile in the "DB files info" item.
::# !------------+---------+--------------+-----------------------------------------------------------------------------------------
::# ! 07/05/2020 !  2.12a  ! F.SUSSAN     ! Added the "Log Shipping (summary) and "Log Shipping (history)" in the DB section.
::# !            !         !              ! Fixed display for "Aged", "Last Full" and "Last log" infos in the "Last backup" item.
::# !            !         !              ! Replaced "TOP SQL Activity" and "Most expensive SQL" in the SQL section by "Top SQL ordered by Elapsed time,  
::# !            !         !              ! CPU time and Physical reads" including supplemental infos about current running sql statements.
::# !------------+---------+--------------+-----------------------------------------------------------------------------------------
::# ! 02/06/2020 !  2.12b  ! F.SUSSAN     ! Added the function "Check_verapp" for checking Sage X3 application version (V5 to V12).
::# !            !         !              ! Added display of type and version for the Sage application (typeprd, apversion) in the "version" function.
::# !            !         !              ! Improved display for the "TempDB contention" item from the TEMP section.
::# !            !         !              ! Checked if 'Optimize for ad-hoc workloads' is to use or in use in the "SQL Plan cache" item.
::# !            !         !              ! Added the SQL_TIME variable to define elapsed time threshold in seconds to display sql statements (=1 by default).
::# !------------+---------+--------------+-----------------------------------------------------------------------------------------
::# ! 10/08/2020 !  2.12c  ! F.SUSSAN     ! Improved display of the "Long running Query Store" item from the PERF section.
::# !            !         !              ! Added backard compatibility for Sage X3 Product V6 under Windows Server 2008.
::# !            !         !              ! Accepted default SQL Server instance (MSSQLSERVER).
::# !------------+---------+--------------+-----------------------------------------------------------------------------------------
::# ! 19/08/2020 !  2.12d  ! F.SUSSAN     ! Renamed the "Tempdb contention" as "Waiting tasks" item and moved to the WAIT section.
::# !            !         !              ! Fixed the return code for the program with the correct display status : OK or KO.
::# !            !         !              ! Added the number of filegroups for each schema in the "Object count" from the OBJ section.
::# !            !         !              ! Fixed "Divide by zero" error when no statistics stale in the "Object statistics (summary)" item. 
::# !------------+---------+--------------+-----------------------------------------------------------------------------------------
::# ! 19/10/2020 !  2.12e  ! F.SUSSAN     ! Fixed "Arithmetic overflow error" and added "Plan Hash" info in the "Long running Query Store" item.
::# !            !         !              ! Added the "Parameter compiled value" with the "Long running Query Store" item.
::# !            !         !              ! Added display default and actual values in the "Query Store configuration" item.
::# !            !         !              ! Classified "QDS_ASYNC_QUEUE" as a benign wait event linked to Query Store activity in the "Wait events" item.
::# !            !         !              ! Added "Compression ratio" and "Last bacxkup file" infos in the "Last backup" item.
::# !------------+---------+--------------+-----------------------------------------------------------------------------------------
::# ! 03/11/2020 !  2.12f  ! F.SUSSAN     ! Changed SQL Server command used to connect database: 'sqlcmd' by default from SQL Server 2012 else 'osql.
::# !------------+---------+--------------+-----------------------------------------------------------------------------------------
::# ! 15/01/2021 !  2.13   ! F.SUSSAN     ! Added the "Partitioned tables" in the OBJ section (FLG_PART=1)
::# !            !         !              ! Added the "Candidates for partition keys" in the OBJ section (FLG_PART=1).
::# !            !         !              ! Added the optional "Top compression estimated" item in the OBJ section (FLG_COMP=1).
::# !            !         !              ! Added continuing the execution of the script if arithmetic overflow error is occurred (arithabort off).
::# !            !         !              ! Fixed display Last backup info from the BAK section.
::# !            !         !              ! Added the EDT_SQL variable to check the SQL Server edition used (standard or enterprise).
::# --------------------------------------------------------------------------------------------------------------------------------
::##################################################################################################################################

::#!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!#
::#!!!!    THE FOLLOWING VARIABLES ARE TO BE MODIFIED    !!!!#
::#!!!!    DEPENDING ON YOUR SYSTEM IMPLEMENTATION.      !!!!#
::#!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!#

:: Location of the runtime for the Sage X3 solution (can be null value if the SQL_SID variable is set) 
set ADXDIR=D:\SageX3\X3V12\runtime

:: Password for the "sa" account (if null value, Windows authentication is used for connection)
set DB_PWD=

::#!!!!--------------------------------------------------!!!!#
::#!!!!    OTHER OPTIONAL VARIABLES THAT CAN BE USED     !!!!#
::#!!!!             DEPENDING ON THE CONTEXT             !!!!#
::#!!!!--------------------------------------------------!!!!#

:: Admin SQL account used for Authentication SQL Server (='sa' by default else windows authentication)
set DB_USER=

:: Login used as search criteria for the audit (=x3 folder, else all login existing)
set LOGIN=

:: List of target section to audit (='ALL' by default else any target option each separated by a blank: HOST, AAG, DB, OPT, BAK, JOB, MEM, FILE, LOG, TEMP, OBJ, ERR, WAIT, CPU, USER, LOCK, STAT, PERF and SQL)
set TARGET=PERF SQL

:: List of excluded target section to audit (by default if null value else any target option each separated by a blank)
set EXCL_TARGET=

:: Number of days retention before deletion older trace files (='14' by default)
set NBR_RET=

:: First SQL Server format date used (='dd/MM/yy' by default if null value)
set FMT_DAT1=

:: Second SQL Server format date used (='dd/MM/yy HH:mm' by default if null value)
set FMT_DAT2=

:: Third SQL Server format date used (='dd/MM/yy HH:mm:ss' by default if null value)
set FMT_DAT3=

:: SQL Server format time used (='HH:mm:ss' by default if null value)
set FMT_TIME=

:: SQL Server convert date used compatible for SQL Server 2005 (='3' by default if null value equivalent to the format 'dd/MM/yy')
set CNV_DATE=

:: SQL Server convert date used compatible for SQL Server 2005 (='8' by default if null value equivalent to the format 'HH:mm:ss')
set CNV_TIME=

:: Display length output line used in the report (='500' by default if null value else can be range between 100 to 3999)
set LEN_LINE=

:: Display length used for SQL Text (='400' by default if null value else can be range between 100 to 999)
set LEN_SQLT=

:: Display length used for Full SQL Text (='2000' by default if null value else can be range between 1000 to 2999)
set LEN_FULLSQLT=

:: Number of first N rows returned (='20' by default if null value)
set TOP_NSQL=

:: Elapsed time threshold in seconds to display sql statements (if null value = 1 secs by default else must be range between 0 and 999)
set SQL_TIME=

:: Name of the SQL Server instance (<ServerName>\<InstanceName> required if the ADXDIR variable is not set)
set SQL_SID=

:: Name of the SQL Server database user by default (by default all existing SQL Server database user)
set SQL_BDD=

:: String used to identify the program name for applicative SQL session (='Adonix' by default otherwise any Sage application or generic name such 'Sage Ligne 1000', '.Net', ...)
set PROG=

:: SQL Server command used to connect database (='sqlcmd' by default from SQL Server 2012 else 'osql').
set CMD_SQL=

:: Flag to check or not index fragmentation that can cause slow running during high db activity because it requires a IS lock as it scans each table (=1 by default else 0)
set FLG_FRAG=0

:: Flag to check or not compression estimates that can cause long running in large database (=0 by default else 1)
set FLG_COMP=

:: Flag to display or not partitioning infos that can cause long running in large database (=0 by default else 1)
set FLG_PART=

:: Flag to include the default SQL Server schema (dbo) in the database audit (=0 by default else 1)
set FLG_DBO=

:: Number of days from which objects statistics are considered stale (='1' days by default)
set STALE=

:: Number of days to display SQL Error log files (='365' days by default)
set HISLOG=

:: Number used to display SQL Error log files (=0 by default for the current file or can be range 1-9 for any existing archive file, otherwise NULL for all files)
set NUMLOG=

:: First search string used to display SQL Error log files (=NULL by default else any search string such as 'Error', 'Failed', 'Login', ...)
set STRLOG1=

:: Second search string used to display SQL Error log files (=NULL by default else any search string such as 'Error', 'Failed', 'Login', ...)
set STRLOG2=

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

(set FLG_HOST=0) &  (set FLG_AAG=0) & (set FLG_DB=0) & (set FLG_OPT=0) & (set FLG_BAK=0) & (set FLG_JOB=0) & (set FLG_MEM=0) & (set FLG_FILE=0) & (set FLG_LOG=0) & (set FLG_TEMP=0) & (set FLG_OBJ=0) & (set FLG_ERR=0) & (set FLG_WAIT=0) & (set FLG_CPU=0) & (set FLG_USER=0) & (set FLG_LOCK=0) & (set FLG_BAK=0) & (set FLG_STAT=0) & (set FLG_PERF=0) & (set FLG_SQL=0) & (set FLG_ALL=0)
:Option
if not "%*"=="" set TARGET=%*
if defined TARGET call :Check_target || goto End
for /d %%i in (HOST AAG DB OPT BAK JOB MEM FILE LOG TEMP OBJ ERR WAIT PERF CPU USER LOCK BAK STAT SQL) do if /I (%1)==(%%i) (set FLG_%%i=1)
if not defined TARGET if /I (%1)==() (set FLG_HOST=1) & (set FLG_AAG=1) & (set FLG_DB=1) & (set FLG_OPT=1) & (set FLG_BAK=1) & (set FLG_JOB=1) & (set FLG_MEM=1) & (set FLG_FILE=1) & (set FLG_LOG=1) & (set FLG_TEMP=1) & (set FLG_OBJ=1) & (set FLG_ERR=1) & (set FLG_WAIT=1) & (set FLG_CPU=1) & (set FLG_USER=1) & (set FLG_LOCK=1) & (set FLG_BAK=1) & (set FLG_STAT=1) & (set FLG_PERF=1) & (set FLG_SQL=1) & (set FLG_ALL=1)
if /I "%TARGET%"=="ALL" (set FLG_HOST=1) & (set FLG_AAG=1) & (set FLG_DB=1) & (set FLG_OPT=1) & (set FLG_BAK=1) & (set FLG_JOB=1) & (set FLG_MEM=1) & (set FLG_FILE=1) & (set FLG_LOG=1) & (set FLG_TEMP=1) & (set FLG_OBJ=1) & (set FLG_ERR=1) & (set FLG_WAIT=1) & (set FLG_CPU=1) & (set FLG_USER=1) & (set FLG_LOCK=1) & (set FLG_BAK=1) & (set FLG_STAT=1) & (set FLG_PERF=1) & (set FLG_SQL=1) & (set FLG_ALL=1)
if defined EXCL_TARGET for %%i in (%EXCL_TARGET%) do for /d %%j in (HOST AAG DB OPT BAK JOB MEM FILE LOG TEMP OBJ ERR WAIT PERF CPU USER LOCK BAK STAT SQL ALL) do if /I (%%i)==(%%j) (set FLG_%%i=0)
if /I not (%1)==(HOST) if /I not (%1)==(AAG) if /I not (%1)==(DB) if /I not (%1)==(OPT) if /I not (%1)==(BAK) if /I not (%1)==(JOB) if /I not (%1)==(MEM) if /I not (%1)==(FILE) if /I not (%1)==(LOG) if /I not (%1)==(TEMP) if /I not (%1)==(OBJ) if /I not (%1)==(ERR) if /I not (%1)==(WAIT) if /I not (%1)==(CPU) if /I not (%1)==(USER) if /I not (%1)==(LOCK) if /I not (%1)==(STAT) if /I not (%1)==(PERF) if /I not (%1)==(SQL) if /I not (%1)==() goto :Usage
if not (%1)==() shift
if not (%1)==() goto :Option

:: Creates non existent directories that will be used
call :Create_dir %LOGDIR% || goto End

:: Checks the operating system version for Windows (2008, 2012, 2016 or 2019 required)
call :Check_versys || goto End

:: Checks the value for variables that are defined
call :Check_variables || goto End

:: Checks if the SQL Server is compatible (2005, 2008, 2012, 2014, 2016, 2017 or 2017 required)
call :Check_versql || goto End

:: Checks version for the Sage X3 application (v5 to v12)
call :Check_verapp

:: Initializes files used in the program
call :Init_files || goto End

:: Checks database for used date formats and max length of data for display
call :Check_db || goto End

if     defined DB_SVC if not defined SQL_BDD if not defined LOGIN call :Display_timestamp STARTING SAGE %type_prd% AUDIT IN THE %type_db% INSTANCE [%DB_SRV%\%DB_SVC%]...
if     defined DB_SVC if     defined SQL_BDD if not defined LOGIN call :Display_timestamp STARTING SAGE %type_prd% AUDIT FOR THE DB [%SQL_BDD%] IN THE %type_db% INSTANCE [%DB_SRV%\%DB_SVC%]...
if     defined DB_SVC if not defined SQL_BDD if     defined LOGIN call :Display_timestamp STARTING SAGE %type_prd% AUDIT FOR THE LOGIN [%LOGIN%] IN THE %type_db% INSTANCE [%DB_SRV%\%DB_SVC%]...
if     defined DB_SVC if     defined SQL_BDD if     defined LOGIN call :Display_timestamp STARTING SAGE %type_prd% AUDIT FOR THE DB [%SQL_BDD%] AND LOGIN [%LOGIN%] IN THE %type_db% INSTANCE [%DB_SRV%\%DB_SVC%]...
if not defined DB_SVC if not defined SQL_BDD if not defined LOGIN call :Display_timestamp STARTING SAGE %type_prd% AUDIT IN THE %type_db% INSTANCE [%DB_SRV%]...
if not defined DB_SVC if     defined SQL_BDD if not defined LOGIN call :Display_timestamp STARTING SAGE %type_prd% AUDIT FOR THE DB [%SQL_BDD%] IN THE %type_db% INSTANCE [%DB_SRV%]...
if not defined DB_SVC if not defined SQL_BDD if     defined LOGIN call :Display_timestamp STARTING SAGE %type_prd% AUDIT FOR THE LOGIN [%LOGIN%] IN THE %type_db% INSTANCE [%DB_SRV%]...
if not defined DB_SVC if     defined SQL_BDD if     defined LOGIN call :Display_timestamp STARTING SAGE %type_prd% AUDIT FOR THE DB [%SQL_BDD%] AND LOGIN [%LOGIN%] IN THE %type_db% INSTANCE [%DB_SRV%]...

:: Generates the SQL script
call :Cre_audit

:: Displays the content of the SQL script if some elements are asked
if defined TARGET call :Display_script LIST OF INSTRUCTIONS IN THE SQL SCRIPT [%file_sql%]

:: Executes the loop SQL script
if defined     DB_PWD if /I "%CMD_SQL%"=="osql"   >>%file_log% %CMD_SQL% -S %DB_NAM% -U %DB_USER% -d master -i %file_sql% -o %file_tmp%.log -P %DB_PWD% -w%LEN_LINE%
if defined     DB_PWD if /I "%CMD_SQL%"=="sqlcmd" >>%file_log% %CMD_SQL% -S %DB_NAM% -U %DB_USER% -d master -i %file_sql% -o %file_tmp%.log -P %DB_PWD% -w%LEN_LINE% -m 1
if not defined DB_PWD if /I "%CMD_SQL%"=="osql"   >>%file_log% %CMD_SQL% -S %DB_NAM% -E -d master -i %file_sql% -o %file_tmp%.log -w%LEN_LINE% -n
if not defined DB_PWD if /I "%CMD_SQL%"=="sqlcmd" >>%file_log% %CMD_SQL% -S %DB_NAM% -E -d master -i %file_sql% -o %file_tmp%.log -w%LEN_LINE% -m 1
if "%DISPLAY%"=="1" if defined     DB_PWD if /I "%CMD_SQL%"=="osql"   >>%file_log% echo %CMD_SQL% -S %DB_NAM% -U %DB_USER% -d master -i %file_sql% -o %file_tmp%.log -P %DB_PWD% -w%LEN_LINE%
if "%DISPLAY%"=="1" if defined     DB_PWD if /I "%CMD_SQL%"=="sqlcmd" >>%file_log% echo %CMD_SQL% -S %DB_NAM% -U %DB_USER% -d master -i %file_sql% -o %file_tmp%.log -P %DB_PWD% -w%LEN_LINE% -m 1
if "%DISPLAY%"=="1" if not defined DB_PWD if /I "%CMD_SQL%"=="osql"   >>%file_log% echo %CMD_SQL% -S %DB_NAM% -E -d master -i %file_sql% -o %file_tmp%.log -w%LEN_LINE% -n
if "%DISPLAY%"=="1" if not defined DB_PWD if /I "%CMD_SQL%"=="sqlcmd" >>%file_log% echo %CMD_SQL% -S %DB_NAM% -E -d master -i %file_sql% -o %file_tmp%.log -w%LEN_LINE% -m 1
if errorlevel 1 (
	call :Display -----
	if defined DB_PWD (call :Display ERROR: UNABLE TO CONNECT TO DATABASE [%SQLS7_SID%] USING SQL SERVER AUTHENTICATION [%DB_USER%] !!) else (call :Display ERROR: UNABLE TO CONNECT TO DATABASE [%SQLS7_SID%] USING WINDOWS AUTHENTICATION [%userdomain%\%username%] !!)
	call :Display -----
	call :Display STATUS : KO
	set RET=1
	exit /B 1
)
type %file_tmp%.log | findstr /V "^1>" | findstr /V "RegQueryValueEx" >>%file_log%
if defined OPTS type %file_tmp%.log | findstr /V "^1>"
if exist %file_tmp%.log (
    type %file_tmp%.log | findstr "^Msg " >NUL
	if errorlevel 1 (
		type %file_tmp%.log | findstr "^Message " >NUL
		if errorlevel 1 (
			set RET=0
		) else (
			echo ------------------
			type %file_tmp%.log | findstr /B /V /C:" " | findstr "^[A-Z].*"
			echo ------------------
			set RET=1
		)
	) else (
		echo ------------------
		type %file_tmp%.log | findstr /B /V /C:" " | findstr "^[A-Z].*"
		echo ------------------
		set RET=1
	)
) else (set RET=1)
del %file_tmp%.log>NUL
call :Display
call :Display_timestamp AUDIT ENDED.

:: Checks the result of the SQL script execution
if "%RET%"=="0" (
	call :Display STATUS : OK
	if not "%DISPLAY%"=="1" del %file_sql%
) else (
	call :Display STATUS : KO
)
call :Display Trace file '%file_log%' generated.

:: Deletes older trace files
call :Display
forfiles /P "%LOGDIR%" /M "%progname%_%DB_SVC%_*.*" /D "-%NBR_RET%" /C "cmd /C del /S/F/Q @FILE|echo Deletion of : @FILE" 2>NUL

:: End of the program
goto End

:Init_variables
::#************************************************************#
::# Initializes variables used in the program
::#
set dbversion=Microsoft SQL Server 2005, 2008, 2012, 2014, 2016, 2017
set copyright=Copyright {C} 2011-2021
set author=Sage Group
for /F "delims=" %%i in ('hostname') do set hostname=%%i
for /F "delims=" %%i in ("%~nx0")    do set progname=%%~ni
for /F "delims=" %%i in ("%~nx0")    do set extname=%%~xi
for /f "tokens=3" %%i in ('reg query "hklm\system\controlset001\control\nls\language" /v Installlanguage') do set nls_lang=%%i
if "%nls_lang%"=="040C" (set language=FRA) else (set language=ENG)
set dirname=%~dp0
set dirname=%dirname:~,-1%
for /f "tokens=5 delims=- " %%i in ('findstr /C:"# Version" %dirname%\%progname%%extname% ^| findstr /v findstr ') do set version=%%i
set file_log=
if not defined TMPDIR if exist %ADXDIR%\bin\env.bat call %ADXDIR%\bin\env.bat
set dbhome=%SQL_HOME%%SQLS7_OSQL%\Binn
call :Upper hostname
call :Info_sysdate
if not defined SCRIPTDIR set SCRIPTDIR=%dirname%
if not defined LOGDIR    set LOGDIR=%SCRIPTDIR%\logs
if not defined DISPLAY   set DISPLAY=0
if not defined PAUSE     set PAUSE=0
if not defined DELAY     set DELAY=10

:: Specific variables
set type_db=MSSQL
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
call :Upper DB_SVC
if not defined DB_NAM set DB_NAM=%DB_SRV%\%DB_SVC%
if exist %ADXDIR%\SERV* for /f %%i in ('dir /B %ADXDIR%\SERV*') do set type_prd=%%i
if exist %ADXDOS%\SERV* for /f %%i in ('dir /B %ADXDOS%\SERV*') do set type_prd=%%i
if defined type_prd set type_prd=%type_prd:~4%
if "%PROG%"=="Sage Ligne 1000" (set type_prd=L1000)
if not defined type_prd if exist %ADXDOS%\FOLDERS.xml for /f delims^=^"^ tokens^=4 %%i in ('type %ADXDOS%\FOLDERS.xml ^| find "MOTH1="') do set type_prd=%%i
if not defined NBR_RET      (set NBR_RET=14)
if not defined DB_USER      (set DB_USER=sa)
if not defined FMT_DAT1     (set FMT_DAT1=dd/MM/yy)
if not defined FMT_DAT2     (set FMT_DAT2=dd/MM/yy HH:mm)
if not defined FMT_DAT3     (set FMT_DAT3=dd/MM/yy HH:mm:ss)
if not defined FMT_TIME     (set FMT_TIME=HH:mm:ss)
if not defined CNV_DATE     (set CNV_DATE=3)
if not defined CNV_TIME     (set CNV_TIME=8)
if not defined LEN_LINE     (set LEN_LINE=500)
if not defined LEN_SQLT     (set LEN_SQLT=400)
if not defined LEN_FULLSQLT (set LEN_FULLSQLT=2000)
if not defined TOP_NSQL     (set TOP_NSQL=20)
if not defined SQL_TIME     (set SQL_TIME=1)
if not defined PROG         (set PROG=Adonix)
if not defined FLG_FRAG     (set FLG_FRAG=1)
if not defined FLG_COMP     (set FLG_COMP=0)
if not defined FLG_PART     (set FLG_PART=0)
if not defined FLG_DBO      (set FLG_DBO=0)
if not defined STALE        (set STALE=1)
if not defined HISLOG       (set HISLOG=365)
if not defined NUMLOG       (set NUMLOG=0)
if /I (%NUMLOG%)==(ALL)     (set NUMLOG=NULL)
if not defined STRLOG1      (set STRLOG1=NULL)
if not defined STRLOG2      (set STRLOG2=NULL)
goto:EOF
::#
::# End of Init_variables
::#************************************************************#

:Check_variables
::#************************************************************#
::# Checks the value for variables that are defined
::#
set RET=1

if defined ADXDIR if not exist %ADXDIR%\bin\env.bat (
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
echo %LEN_LINE% | findstr /r "\<[1-9][0-9][0-9]\>">NUL
if errorlevel 1 (
	echo %LEN_LINE% | findstr /r "\<[1-3][0-9][0-9][0-9]\>">NUL
	if errorlevel 1 (
		echo ERROR: Invalid number [%LEN_LINE%] for the variable "LEN_LINE" [must be range 100-3999] !!
		exit /B %RET%
	)
)
echo %LEN_SQLT% | findstr /r "\<[1-9][0-9][0-9]\>">NUL
if errorlevel 1 (
	echo ERROR: Invalid number [%LEN_SQLT%] for the variable "LEN_SQLT" [must be range 100-999] !!
	exit /B %RET%
)
echo %LEN_FULLSQLT% | findstr /r "\<[1-2][0-9][0-9][0-9]\>">NUL
if errorlevel 1 (
	echo ERROR: Invalid number [%LEN_FULLSQLT%] for the variable "LEN_FULLSQLT" [must be range 1000-2999] !!
	exit /B %RET%
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
echo %SQL_TIME% | findstr /r "\<[0-9]\>">NUL
if errorlevel 1 (
	echo %SQL_TIME% | findstr /r "\<[1-9][0-9]\>">NUL
	if errorlevel 1 (
		echo %SQL_TIME% | findstr /r "\<[1-9][0-9][0-9]\>">NUL
		if errorlevel 1 (
			echo ERROR: Invalid number [%SQL_TIME%] for the variable "SQL_TIME" [must be range 0-999] !!
			exit /B %RET%
		)
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
echo %FLG_FRAG% | findstr /r "\<[0-1]\>">NUL
if errorlevel 1 (
	echo ERROR: Invalid flag [%FLG_FRAG%] for the variable "FLG_FRAG" [0-1] !!
	exit /B %RET%
)
echo %FLG_COMP% | findstr /r "\<[0-1]\>">NUL
if errorlevel 1 (
	echo ERROR: Invalid flag [%FLG_COMP%] for the variable "FLG_COMP" [0-1] !!
	exit /B %RET%
)
echo %FLG_PART% | findstr /r "\<[0-1]\>">NUL
if errorlevel 1 (
	echo ERROR: Invalid flag [%FLG_PART%] for the variable "FLG_PART" [0-1] !!
	exit /B %RET%
)
echo %FLG_DBO% | findstr /r "\<[0-1]\>">NUL
if errorlevel 1 (
	echo ERROR: Invalid flag [%FLG_DBO%] for the variable "FLG_DBO" [0-1] !!
	exit /B %RET%
)
echo %STALE% | findstr /r "\<[1-9]\>">NUL
if errorlevel 1 (
	echo %STALE% | findstr /r "\<[1-9][0-9]\>">NUL
	if errorlevel 1 (
		echo ERROR: Invalid number [%STALE%] for the variable "STALE" [must be range 1-99] !!
		exit /B %RET%
	)
)
echo %HISLOG% | findstr /r "\<[1-9]\>">NUL
if errorlevel 1 (
	echo %HISLOG% | findstr /r "\<[1-9][0-9]\>">NUL
	if errorlevel 1 (
		echo %HISLOG% | findstr /r "\<[1-9][0-9][0-9]\>">NUL
		if errorlevel 1 (
			echo ERROR: Invalid number [%HISLOG%] for the variable "HISLOG" [must be range 1-999] !!
			exit /B %RET%
		)
	)
)
echo %NUMLOG% | find /I "ALL">NUL
if errorlevel 1 (
	echo %NUMLOG% | findstr /r "\<[0-9]\>">NUL
	if errorlevel 1 (
		echo ERROR: Invalid value [%NUMLOG%] for the variable "NUMLOG" [can be range 0-9 or 'ALL'] !!
		exit /B %RET%
	)
)
if defined FMT_DAT1 call :Check_datefmt FMT_DAT1
if (%RET%)==(1) exit /B %RET%
if defined FMT_DAT2 call :Check_datefmt FMT_DAT2
if (%RET%)==(1) exit /B %RET%
if defined FMT_DAT3 call :Check_datefmt FMT_DAT3
if (%RET%)==(1) exit /B %RET%
set RET=0
exit /B %RET%
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
if defined SQLS7_SID (set SID=%SQLS7_SID%) else (set SID=%DB_SVC%)
if defined TARGET set IDENTIFIER=%TARGET%_
if not defined LOGIN set IDENTIFIER=%IDENTIFIER%%SID%_%DAT%-%TIM%
if defined LOGIN set IDENTIFIER=%IDENTIFIER%%SID%_%DAT%-%TIM%-%LOGIN%
set file_sql=%SCRIPTDIR%\%progname%_%IDENTIFIER%.sql
set file_log=%LOGDIR%\%progname%_%IDENTIFIER%.log
set file_tmp=%LOGDIR%\%progname%_%IDENTIFIER%.tmp

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
if /I "%FLG_ALL%"=="1" call :Display
if /I "%FLG_ALL%"=="0" echo:
echo THIS MAY TAKE A WHILE, PLEASE WAIT...

 >%file_sql% echo -- ---------------------------------------------------------------------------
>>%file_sql% echo -- SQL Script generated automatically in SQL version [%VER_SQL%] by the program "%dirname%\%~nx0".
>>%file_sql% echo -- %copyright% by %author% - All Rights Reserved.
>>%file_sql% echo -- ---------------------------------------------------------------------------
>>%file_sql% echo --
>>%file_sql% echo set nocount on
>>%file_sql% echo set dateformat dmy
>>%file_sql% echo set quoted_identifier on
>>%file_sql% echo set arithabort off
>>%file_sql% echo set transaction isolation level read uncommitted
>>%file_sql% echo:
>>%file_sql% echo use [master]
>>%file_sql% echo:
if /I "%CMD_SQL%"=="osql" >>%file_sql% echo PRINT ''
if /I "%FLG_HOST%"=="1" if not "%VER_SQL%"=="9.0" if not "%VER_SQL%"=="10.0" call :Audit_host
if /I "%FLG_HOST%"=="1" if "%VER_SQL%"=="9.0"     call :Audit_host_old
if /I "%FLG_HOST%"=="1" if "%VER_SQL%"=="10.0"    call :Audit_host_old
if /I "%FLG_HOST%"=="1" if "%VER_SQL%"=="14.0"    call :Audit_host_new
if /I "%FLG_AAG%"=="1"  if not "%VER_SQL%"=="9.0" if not "%VER_SQL%"=="10.0" if not "%VER_SQL%"=="10.5" call :Audit_aag
if /I "%FLG_DB%"=="1"   call :Audit_db
if /I "%FLG_OPT%"=="1"  call :Audit_opt
if /I "%FLG_BAK%"=="1"  call :Audit_bak
if /I "%FLG_BAK%"=="1" if "%VER_SQL%"=="13.0" call :Audit_bak_new
if /I "%FLG_BAK%"=="1" if "%VER_SQL%"=="14.0" call :Audit_bak_new
if /I "%FLG_JOB%"=="1"  call :Audit_job
if /I "%FLG_MEM%"=="1"  call :Audit_mem
if /I "%FLG_FILE%"=="1" call :Audit_file
if /I "%FLG_LOG%"=="1"  call :Audit_log
if /I "%FLG_TEMP%"=="1" call :Audit_temp
if defined SQL_BDD >>%file_sql% echo use [%SQL_BDD%]
if defined SQL_BDD >>%file_sql% echo:
if /I "%FLG_OBJ%"=="1"  call :Audit_obj
if /I "%FLG_ERR%"=="1"  call :Audit_err
if /I "%FLG_WAIT%"=="1" call :Audit_wait
if /I "%FLG_CPU%"=="1"  call :Audit_cpu
if /I "%FLG_USER%"=="1" call :Audit_user
if /I "%FLG_LOCK%"=="1" call :Audit_lock
if /I "%FLG_STAT%"=="1" if not "%VER_SQL%"=="9.0" if not "%VER_SQL%"=="10.0" call :Audit_stat
if /I "%FLG_STAT%"=="1" if "%VER_SQL%"=="9.0"  call :Audit_stat_old
if /I "%FLG_STAT%"=="1" if "%VER_SQL%"=="10.0" call :Audit_stat_old
if /I "%FLG_PERF%"=="1" call :Audit_perf
if /I "%FLG_PERF%"=="1" if "%VER_SQL%"=="13.0" call :Audit_perf_new
if /I "%FLG_PERF%"=="1" if "%VER_SQL%"=="14.0" call :Audit_perf_new
if /I "%FLG_SQL%"=="1"  call :Audit_sql
>>%file_sql% echo PRINT '=============================================================================================================='
>>%file_sql% echo PRINT 'End of report'
goto:EOF
::#
::# End of Cre_audit
::#************************************************************#

:Audit_host
::#************************************************************#
::# Audits hardware infos with memory and disk usage for SQL Server 2008 and later
::#
>>%file_sql% echo PRINT '+----------------------+'
>>%file_sql% echo PRINT '^| Hardware information ^|'
>>%file_sql% echo PRINT '+----------------------+'
>>%file_sql% echo PRINT ''
>>%file_sql% echo:
>>%file_sql% echo declare @value1 nvarchar(50)
>>%file_sql% echo declare @value2 nvarchar(50)
>>%file_sql% echo declare @value3 nvarchar(50)
>>%file_sql% echo exec sys.xp_instance_regread 'HKEY_LOCAL_MACHINE', 'HARDWARE\DESCRIPTION\System\BIOS',               'SystemManufacturer',  @value1 output;
>>%file_sql% echo exec sys.xp_instance_regread 'HKEY_LOCAL_MACHINE', 'HARDWARE\DESCRIPTION\System\BIOS',               'SystemProductName',   @value2 output;
>>%file_sql% echo exec sys.xp_instance_regread 'HKEY_LOCAL_MACHINE', 'HARDWARE\DESCRIPTION\System\CentralProcessor\0', 'ProcessorNameString', @value3 output;
>>%file_sql% echo:
>>%file_sql% echo select cast^(ServerProperty^('MachineName'^) as varchar^(15^)^)                                              AS 'Machine Name',
if "%VER_SQL%"=="11.0" >>%file_sql% echo        left^(case when i.virtual_machine_type = 0 then 'Physical' else 'Virtual' end, 12^)               AS 'Machine type',
if "%VER_SQL%"=="12.0" >>%file_sql% echo        left^(case when i.virtual_machine_type = 0 then 'Physical' else 'Virtual' end, 12^)               AS 'Machine type',
if "%VER_SQL%"=="13.0" >>%file_sql% echo        left^(case when i.virtual_machine_type = 0 then 'Physical' else 'Virtual' end, 12^)               AS 'Machine type',
if "%VER_SQL%"=="14.0" >>%file_sql% echo        left^(case when i.virtual_machine_type = 0 then 'Physical' else 'Virtual' end, 12^)               AS 'Machine type',
>>%file_sql% echo        left^(isnull(@value1, 'Unknown'), 15^)                                                            AS 'Manufacturer',
>>%file_sql% echo        left^(isnull(@value2, 'Unknown'), 25^)                                                            AS 'Product name',
>>%file_sql% echo        cast^(ServerProperty^('ComputerNamePhysicalNetBIOS'^) as varchar^(15^)^)                              AS 'Computer Name',
if "%VER_SQL%"=="11.0" >>%file_sql% echo        left^(format^(dateadd^(second, ^(i.ms_ticks/1000^)*^(-1^), getdate^(^)^), '%FMT_DAT2%'^), 14^)          AS 'Reboot Time',
if "%VER_SQL%"=="12.0" >>%file_sql% echo        left^(format^(dateadd^(second, ^(i.ms_ticks/1000^)*^(-1^), getdate^(^)^), '%FMT_DAT2%'^), 14^)          AS 'Reboot Time',
if "%VER_SQL%"=="13.0" >>%file_sql% echo        left^(format^(dateadd^(second, ^(i.ms_ticks/1000^)*^(-1^), getdate^(^)^), '%FMT_DAT2%'^), 14^)          AS 'Reboot Time',
if "%VER_SQL%"=="14.0" >>%file_sql% echo        left^(format^(dateadd^(second, ^(i.ms_ticks/1000^)*^(-1^), getdate^(^)^), '%FMT_DAT2%'^), 14^)          AS 'Reboot Time',
if not "%VER_SQL%"=="11.0" if not "%VER_SQL%"=="12.0" if not "%VER_SQL%"=="13.0" if not "%VER_SQL%"=="14.0" >>%file_sql% echo        left^(convert^(varchar, dateadd^(second, ^(i.ms_ticks/1000^)*^(-1^), getdate^(^)^), %CNV_DATE%^)+' '+
if not "%VER_SQL%"=="11.0" if not "%VER_SQL%"=="12.0" if not "%VER_SQL%"=="13.0" if not "%VER_SQL%"=="14.0" >>%file_sql% echo             convert^(varchar, dateadd^(second, ^(i.ms_ticks/1000^)*^(-1^), getdate^(^)^), %CNV_TIME%^), 14^)            AS 'Reboot Time',
if "%VER_SQL%"=="11.0" >>%file_sql% echo        cast^(datediff^(Day, convert^(datetime, format^(dateadd^(second, ^(i.ms_ticks/1000^)*^(-1^),
if "%VER_SQL%"=="11.0" >>%file_sql% echo                                      getdate^(^)^), '%FMT_DAT2%'^)^), getdate^(^)^) as varchar^(5^)^)+' days' AS 'Uptime',
if "%VER_SQL%"=="12.0" >>%file_sql% echo        cast^(datediff^(Day, convert^(datetime, format^(dateadd^(second, ^(i.ms_ticks/1000^)*^(-1^),
if "%VER_SQL%"=="12.0" >>%file_sql% echo                                      getdate^(^)^), '%FMT_DAT2%'^)^), getdate^(^)^) as varchar^(5^)^)+' days' AS 'Uptime',
if "%VER_SQL%"=="13.0" >>%file_sql% echo        cast^(datediff^(Day, convert^(datetime, format^(dateadd^(second, ^(i.ms_ticks/1000^)*^(-1^),
if "%VER_SQL%"=="13.0" >>%file_sql% echo                                      getdate^(^)^), '%FMT_DAT2%'^)^), getdate^(^)^) as varchar^(5^)^)+' days' AS 'Uptime',
if "%VER_SQL%"=="14.0" >>%file_sql% echo        cast^(datediff^(Day, convert^(datetime, format^(dateadd^(second, ^(i.ms_ticks/1000^)*^(-1^),
if "%VER_SQL%"=="14.0" >>%file_sql% echo                                      getdate^(^)^), '%FMT_DAT2%'^)^), getdate^(^)^) as varchar^(5^)^)+' days' AS 'Uptime',
if not "%VER_SQL%"=="11.0" if not "%VER_SQL%"=="12.0" if not "%VER_SQL%"=="13.0" if not "%VER_SQL%"=="14.0" >>%file_sql% echo        cast^(datediff^(Day, convert^(datetime, convert^(varchar, dateadd^(second, ^(i.ms_ticks/1000^)*^(-1^), getdate^(^)^), %CNV_DATE%^)+' '+
if not "%VER_SQL%"=="11.0" if not "%VER_SQL%"=="12.0" if not "%VER_SQL%"=="13.0" if not "%VER_SQL%"=="14.0" >>%file_sql% echo                                                convert^(varchar, dateadd^(second, ^(i.ms_ticks/1000^)*^(-1^), getdate^(^)^), %CNV_TIME%^)^), getdate^(^)^) as varchar^(5^)^)+' days' AS 'Uptime',
>>%file_sql% echo        cast^(ceiling^(cast^(i.cpu_count as float^)/i.hyperthread_ratio^) as varchar^(10^)^)                    AS 'Physical CPU Count',
>>%file_sql% echo        cast^(i.cpu_count as varchar^(10^)^)                                                                AS 'Logical CPU Count',
if not "%VER_SQL%"=="9.0"  if not "%VER_SQL%"=="10.0" >>%file_sql% echo        left^(@value3, 45^)                                                                               AS 'Processor description',
if     "%VER_SQL%"=="9.0"  >>%file_sql% echo        left^(@value3, 45^)                                                                               AS 'Processor description'
if     "%VER_SQL%"=="10.0" >>%file_sql% echo        left^(@value3, 45^)                                                                               AS 'Processor description'
if not "%VER_SQL%"=="9.0" if not "%VER_SQL%"=="10.0" if not "%VER_SQL%"=="13.0" if not "%VER_SQL%"=="14.0" >>%file_sql% echo        left^(case when i.affinity_type=1 then 'Manual' else 'Auto' end, 13^)                             AS 'Affinity type'
if "%VER_SQL%"=="13.0" >>%file_sql% echo        left^(case when i.affinity_type=1 then 'Manual' else 'Auto' end, 13^)                             AS 'Affinity type',
if "%VER_SQL%"=="13.0" >>%file_sql% echo        left^(case i.softnuma_configuration when 0 then 'Off'
if "%VER_SQL%"=="13.0" >>%file_sql% echo                                           when 1 then 'Automated'
if "%VER_SQL%"=="13.0" >>%file_sql% echo                                           when 2 then 'Manual' end, 9^)                                 AS 'Soft-NUMA'
if "%VER_SQL%"=="14.0" >>%file_sql% echo        left^(case when i.affinity_type=1 then 'Manual' else 'Auto' end, 13^)                             AS 'Affinity type',
if "%VER_SQL%"=="14.0" >>%file_sql% echo        left^(case i.softnuma_configuration when 0 then 'Off'
if "%VER_SQL%"=="14.0" >>%file_sql% echo                                           when 1 then 'Automated'
if "%VER_SQL%"=="14.0" >>%file_sql% echo                                           when 2 then 'Manual' end, 9^)                                 AS 'Soft-NUMA'
>>%file_sql% echo from sys.dm_os_sys_info   i WITH (NOLOCK)
>>%file_sql% echo OPTION (RECOMPILE);
>>%file_sql% echo:
>>%file_sql% echo PRINT ''
>>%file_sql% echo select m.total_physical_memory_kb/1024                                                                                   AS 'Total Physical Memory (MB)',
>>%file_sql% echo        m.available_physical_memory_kb/1024                                                                               AS 'Free Physical (MB)',
>>%file_sql% echo        cast(m.available_physical_memory_kb*100.0/m.total_physical_memory_kb as decimal(4,1))                             AS 'Free Physical (%%)',
>>%file_sql% echo        case when m.system_high_memory_signal_state = 1 and m.system_low_memory_signal_state = 0 then 'HIGH'
>>%file_sql% echo             when m.system_high_memory_signal_state = 0 and m.system_low_memory_signal_state = 1 then 'LOW'
>>%file_sql% echo             when m.system_high_memory_signal_state = 0 and m.system_low_memory_signal_state = 0 then 'STEADY'
if "%VER_SQL%"=="9.0"  >>%file_sql% echo             when m.system_high_memory_signal_state = 1 and m.system_low_memory_signal_state = 1 then 'TRANSITIONING' end AS 'Available Memory State'
if "%VER_SQL%"=="10.0" >>%file_sql% echo             when m.system_high_memory_signal_state = 1 and m.system_low_memory_signal_state = 1 then 'TRANSITIONING' end AS 'Available Memory State'
if "%VER_SQL%"=="10.5" >>%file_sql% echo             when m.system_high_memory_signal_state = 1 and m.system_low_memory_signal_state = 1 then 'TRANSITIONING' end AS 'Available Memory State'
if not "%VER_SQL%"=="9.0" if not "%VER_SQL%"=="10.0" if not "%VER_SQL%"=="10.5" >>%file_sql% echo             when m.system_high_memory_signal_state = 1 and m.system_low_memory_signal_state = 1 then 'TRANSITIONING' end AS 'Available Memory State',
if not "%VER_SQL%"=="9.0" if not "%VER_SQL%"=="10.0" if not "%VER_SQL%"=="10.5" >>%file_sql% echo        left^(m.system_memory_state_desc, 40^)                                                                              AS 'Status'
if "%VER_SQL%"=="13.0" >>%file_sql% echo       ,left^(case i.sql_memory_model when 1 then 'Conventional'  
if "%VER_SQL%"=="13.0" >>%file_sql% echo                                      when 2 then 'Lock Pages in Memory'
if "%VER_SQL%"=="13.0" >>%file_sql% echo                                      when 3 then 'Large Pages in Memory' end, 21^)                                        AS 'Memory model'
if "%VER_SQL%"=="14.0" >>%file_sql% echo       ,left^(case i.sql_memory_model when 1 then 'Conventional'  
if "%VER_SQL%"=="14.0" >>%file_sql% echo                                      when 2 then 'Lock Pages in Memory'
if "%VER_SQL%"=="14.0" >>%file_sql% echo                                      when 3 then 'Large Pages in Memory' end, 21^)                                        AS 'Memory model'
>>%file_sql% echo from sys.dm_os_sys_info   i WITH ^(NOLOCK^),
>>%file_sql% echo      sys.dm_os_sys_memory m WITH ^(NOLOCK^)
>>%file_sql% echo OPTION ^(RECOMPILE^);
>>%file_sql% echo:
>>%file_sql% echo PRINT ''
>>%file_sql% echo select m.total_page_file_kb/1024                                                                                         AS 'Total Virtual Memory ^(MB^)',
>>%file_sql% echo        m.available_page_file_kb/1024                                                                                     AS 'Free Virtual Memory ^(MB^)',
>>%file_sql% echo        cast^(m.available_page_file_kb*100.0/m.total_page_file_kb as decimal^(4,1^)^)                                         AS 'Free Virtual Memory ^(%%^)',
>>%file_sql% echo        ^(m.total_page_file_kb-m.total_physical_memory_kb^)/1024                                                            AS 'Total Paging Memory ^(MB^)',
>>%file_sql% echo        ^(m.available_page_file_kb-m.available_physical_memory_kb^)/1024                                                    AS 'Free Paging Memory ^(MB^)',
>>%file_sql% echo        cast^(^(m.available_page_file_kb-m.available_physical_memory_kb^)*100.0/
>>%file_sql% echo             ^(m.total_page_file_kb-m.total_physical_memory_kb^) as decimal^(4,1^)^)                                           AS 'Free Paging Memory ^(%%^)'
>>%file_sql% echo from sys.dm_os_sys_info   i WITH ^(NOLOCK^),
>>%file_sql% echo      sys.dm_os_sys_memory m WITH ^(NOLOCK^)
>>%file_sql% echo OPTION ^(RECOMPILE^);
>>%file_sql% echo:
>>%file_sql% echo PRINT ''
>>%file_sql% echo ;with tgt as ^(
>>%file_sql% echo select instance_name,     cntr_value from sys.dm_os_performance_counters where counter_name = 'Target Node Memory ^(KB^)'
>>%file_sql% echo union select 'TOTAL', cntr_value from sys.dm_os_performance_counters where counter_name = 'Target Server Memory ^(KB^)'
>>%file_sql% echo ^),
>>%file_sql% echo tot as ^(
>>%file_sql% echo select instance_name,     cntr_value from sys.dm_os_performance_counters where counter_name = 'Total Node Memory ^(KB^)'
>>%file_sql% echo union select 'TOTAL', cntr_value from sys.dm_os_performance_counters where counter_name = 'Total Server Memory ^(KB^)'
>>%file_sql% echo ^),
>>%file_sql% echo dbc as ^(
>>%file_sql% echo select instance_name,     cntr_value from sys.dm_os_performance_counters where counter_name = 'Database Node Memory ^(KB^)'
>>%file_sql% echo union select 'TOTAL', cntr_value from sys.dm_os_performance_counters where counter_name = 'Database Cache Memory ^(KB^)'
>>%file_sql% echo ^),
>>%file_sql% echo stl as ^(
>>%file_sql% echo select instance_name,     cntr_value from sys.dm_os_performance_counters where counter_name = 'Stolen Node Memory ^(KB^)'
>>%file_sql% echo union select 'TOTAL', cntr_value from sys.dm_os_performance_counters where counter_name = 'Stolen Server Memory ^(KB^)'
>>%file_sql% echo ^),
>>%file_sql% echo fre as ^(
>>%file_sql% echo select instance_name,     cntr_value from sys.dm_os_performance_counters where counter_name = 'Free Node Memory ^(KB^)'
>>%file_sql% echo union select 'TOTAL', cntr_value from sys.dm_os_performance_counters where counter_name = 'Free Memory ^(KB^)'
>>%file_sql% echo ^),
>>%file_sql% echo frn as ^(
>>%file_sql% echo select instance_name,     cntr_value from sys.dm_os_performance_counters where counter_name = 'Foreign Node Memory ^(KB^)'
>>%file_sql% echo union select 'TOTAL', sum^(cntr_value^) from sys.dm_os_performance_counters where counter_name = 'Foreign Node Memory ^(KB^)'
>>%file_sql% echo ^)
>>%file_sql% echo select left^(tgt.instance_name, 10^)             AS 'NUMA node',
>>%file_sql% echo        cast^(tgt.cntr_value/1024.0 as int^)      AS 'Target Size ^(MB^)',
>>%file_sql% echo        cast^(tot.cntr_value/1024.0 as int^)      AS 'Total Size ^(MB^)',
>>%file_sql% echo        cast^(dbc.cntr_value/1024.0 as int^)      AS 'Cache Size ^(MB^)',
>>%file_sql% echo        cast^(stl.cntr_value/1024.0 as int^)      AS 'Stolen Size ^(MB^)',
>>%file_sql% echo        cast^(fre.cntr_value/1024.0 as dec^(7,1^)^) AS 'Free Size ^(MB^)',
>>%file_sql% echo        cast^(frn.cntr_value/1024.0 as dec^(7,1^)^) AS 'Non-NUMA Size ^(MB^)'
>>%file_sql% echo from tgt 
>>%file_sql% echo inner join tot on tgt.instance_name = tot.instance_name
>>%file_sql% echo inner join frn on tgt.instance_name = frn.instance_name
>>%file_sql% echo inner join dbc on tgt.instance_name = dbc.instance_name
>>%file_sql% echo inner join stl on tgt.instance_name = stl.instance_name
>>%file_sql% echo inner join fre on tgt.instance_name = fre.instance_name;
>>%file_sql% echo:
if not "%VER_SQL%"=="9.0" if not "%VER_SQL%"=="10.0" >>%file_sql% echo PRINT ''
if not "%VER_SQL%"=="9.0" if not "%VER_SQL%"=="10.0" >>%file_sql% echo select distinct left^(v.volume_mount_point, 3^)                         AS 'Drive',
if not "%VER_SQL%"=="9.0" if not "%VER_SQL%"=="10.0" >>%file_sql% echo        left^(v.logical_volume_name, 20^)                                AS 'Logical name',
if not "%VER_SQL%"=="9.0" if not "%VER_SQL%"=="10.0" >>%file_sql% echo        left^(v.file_system_type, 4^)                                    AS 'Type',
if not "%VER_SQL%"=="9.0" if not "%VER_SQL%"=="10.0" >>%file_sql% echo        convert^(dec^(12,2^), v.total_bytes/1073741824.0^)                 AS 'Total Size ^(Gb^)',
if not "%VER_SQL%"=="9.0" if not "%VER_SQL%"=="10.0" >>%file_sql% echo        convert^(dec^(12,2^), v.available_bytes/1073741824.0^)             AS 'Free Size ^(Gb^)',
if not "%VER_SQL%"=="9.0" if not "%VER_SQL%"=="10.0" >>%file_sql% echo        convert^(dec^(12,2^), v.available_bytes * 1./v.total_bytes * 100^) AS 'Free Size (%%)',
if not "%VER_SQL%"=="9.0" if not "%VER_SQL%"=="10.0" >>%file_sql% echo        case when v.is_compressed = 1 then 'Yes' else 'No' end         AS 'Is Compressed?'
if not "%VER_SQL%"=="9.0" if not "%VER_SQL%"=="10.0" >>%file_sql% echo from sys.master_files AS f WITH ^(NOLOCK^)
if not "%VER_SQL%"=="9.0" if not "%VER_SQL%"=="10.0" >>%file_sql% echo cross apply sys.dm_os_volume_stats(f.database_id, f.file_id) v
if not "%VER_SQL%"=="9.0" if not "%VER_SQL%"=="10.0" >>%file_sql% echo order by 1 OPTION ^(RECOMPILE^);
if not "%VER_SQL%"=="9.0" if not "%VER_SQL%"=="10.0" >>%file_sql% echo:
>>%file_sql% echo PRINT ''
>>%file_sql% echo ;with iot as
>>%file_sql% echo ^(select sum^(ios.num_of_reads^) as reads,
>>%file_sql% echo         sum^(ios.num_of_bytes_read^) bytesread,
>>%file_sql% echo         sum^(ios.io_stall_read_ms^) as iostallreadms,
>>%file_sql% echo         sum^(ios.num_of_writes^) as writes,
>>%file_sql% echo         sum^(ios.num_of_bytes_written^) as byteswritten,
>>%file_sql% echo         sum^(ios.io_stall_write_ms^) as iostallwritesms,
>>%file_sql% echo         sum^(ios.io_stall^) as iostall,
>>%file_sql% echo         sum^(ios.size_on_disk_bytes^) sizeondisk
>>%file_sql% echo  from sys.dm_io_virtual_file_stats^(default, default^) as ios^),
>>%file_sql% echo       iof as ^(select dbs.name as databasename,
>>%file_sql% echo                       mf.name as filename,
>>%file_sql% echo                       mf.type_desc as filetype,
>>%file_sql% echo                       substring^(mf.physical_name, 1, 3^) as drive,
>>%file_sql% echo                       substring^(mf.physical_name, 1, charindex^('\', mf.physical_name, charindex^('\',  mf.physical_name^)+1^)-1^) as volume_point,
>>%file_sql% echo                       case when dbs.name in ^('master', 'model', 'msdb', 'tempdb'^)then 1 else 0 end as issystemdb,
>>%file_sql% echo                       ios.*
>>%file_sql% echo                from sys.dm_io_virtual_file_stats^(default, default^) as ios
>>%file_sql% echo                inner join sys.databases as dbs   on ios.database_id = dbs.database_id
>>%file_sql% echo                inner join sys.master_files as mf on ios.database_id = mf.database_id and ios.file_id = mf.file_id
>>%file_sql% echo ^)
>>%file_sql% echo select left^(iof.volume_point, 26^)                                                                AS 'Volume point',
>>%file_sql% echo        left^(convert^(numeric^(5,2^), sum^(100.0 * iof.num_of_reads / iot.reads^)^), 10^)                AS 'Reads (%%)',
>>%file_sql% echo        left^(convert^(numeric^(5,2^), sum^(100.0 * iof.num_of_bytes_read / iot.bytesread^)^), 10^)       AS 'BytesRead (%%)',
>>%file_sql% echo        left^(convert^(numeric^(5,2^), sum^(100.0 * iof.io_stall_read_ms / iot.iostallreadms^)^), 10^)    AS 'IoStallRead (%%)',
>>%file_sql% echo        left^(convert^(numeric^(5,2^), sum^(100.0 * iof.num_of_writes / iot.writes^)^), 10^)              AS 'Writes (%%)',
>>%file_sql% echo        left^(convert^(numeric^(5,2^), sum^(100.0 * iof.num_of_bytes_written / iot.byteswritten^)^), 10^) AS 'BytesWritten (%%)',
>>%file_sql% echo        left^(convert^(numeric^(5,2^), sum^(100.0 * iof.io_stall_write_ms / iot.iostallwritesms^)^), 10^) AS 'IoStallWrite (%%)',
>>%file_sql% echo        left^(convert^(numeric^(5,2^), sum^(100.0 * iof.io_stall / iot.iostall^)^), 10^)                  AS 'IoStall (%%)',
>>%file_sql% echo        left^(convert^(numeric^(5,2^), sum^(100.0 * iof.size_on_disk_bytes / iot.sizeondisk^)^), 10^)     AS 'Size on disk (%%)'
>>%file_sql% echo from iof cross apply iot
>>%file_sql% echo group by iof.volume_point
>>%file_sql% echo order by iof.volume_point;
>>%file_sql% echo:
>>%file_sql% echo PRINT ''
>>%file_sql% echo select left^(@@VERSION, %LEN_SQLT%^) AS 'SQL Server and OS Version Info';
>>%file_sql% echo:
if not "%VER_SQL%"=="14.0" >>%file_sql% echo PRINT '+----------------+'
if not "%VER_SQL%"=="14.0" >>%file_sql% echo PRINT '^| OS information ^|'
if not "%VER_SQL%"=="14.0" >>%file_sql% echo PRINT '+----------------+'
if not "%VER_SQL%"=="14.0" >>%file_sql% echo PRINT ''
if not "%VER_SQL%"=="14.0" >>%file_sql% echo:
if not "%VER_SQL%"=="14.0" >>%file_sql% echo select left^('Windows', 8^)                                                  AS 'Platform',
if not "%VER_SQL%"=="14.0" >>%file_sql% echo        left^(substring^(@@version, charindex^('Windows', @@version^),
if not "%VER_SQL%"=="14.0" >>%file_sql% echo                                  charindex^(o.windows_release, @@version^) -
if not "%VER_SQL%"=="14.0" >>%file_sql% echo                                  charindex^('Windows', @@version^)^), 20^)     AS 'Operating System',
if not "%VER_SQL%"=="14.0" >>%file_sql% echo        left^(case when o.windows_service_pack_level = '' then 'RTM'
if not "%VER_SQL%"=="14.0" >>%file_sql% echo                  else o.windows_service_pack_level end, 10^)                AS 'Service Pack',
if not "%VER_SQL%"=="14.0" >>%file_sql% echo        left^(o.windows_release, 7^)                                          AS 'Release',
if not "%VER_SQL%"=="14.0" >>%file_sql% echo        left^(case when o.windows_sku =  4    then 'Enterprise'
if not "%VER_SQL%"=="14.0" >>%file_sql% echo                   when o.windows_sku =  7    then 'Standard Server'
if not "%VER_SQL%"=="14.0" >>%file_sql% echo                   when o.windows_sku =  8    then 'Datacenter Server'
if not "%VER_SQL%"=="14.0" >>%file_sql% echo                   when o.windows_sku = 10    then 'Enterprise Server'
if not "%VER_SQL%"=="14.0" >>%file_sql% echo                   when o.windows_sku = 48    then 'Professional Server'
if not "%VER_SQL%"=="14.0" >>%file_sql% echo                   when o.windows_sku is null then 'Linux' end, 20^)         AS 'Edition',
if not "%VER_SQL%"=="14.0" >>%file_sql% echo        left^(cast^(o.os_language_version as varchar^)+' ^('+l.name+'^)', 20^)    AS 'Language'
if not "%VER_SQL%"=="14.0" >>%file_sql% echo from sys.dm_os_windows_info o WITH ^(NOLOCK^)
if not "%VER_SQL%"=="14.0" >>%file_sql% echo join sys.syslanguages l on l.lcid = o.os_language_version
if not "%VER_SQL%"=="14.0" >>%file_sql% echo option ^(RECOMPILE^);
if not "%VER_SQL%"=="14.0" >>%file_sql% echo:
goto:EOF
::#
::# End of Audit_host
::#************************************************************#

:Audit_host_old
::#************************************************************#
::# Audits hardware infos only for the SQL Server 2005
::#
>>%file_sql% echo PRINT ''
>>%file_sql% echo PRINT '+----------------------+'
>>%file_sql% echo PRINT '^| Hardware information ^|'
>>%file_sql% echo PRINT '+----------------------+'
>>%file_sql% echo PRINT ''
>>%file_sql% echo:
>>%file_sql% echo declare @value nvarchar(4000)
>>%file_sql% echo exec sys.xp_instance_regread N'HKEY_LOCAL_MACHINE', N'HARDWARE\DESCRIPTION\System\CentralProcessor\0', N'ProcessorNameString', @value output;
>>%file_sql% echo:
>>%file_sql% echo select cast^(ServerProperty^('MachineName'^) as varchar^(15^)^)                                      AS 'Machine Name',
>>%file_sql% echo        cast^(ServerProperty^('ComputerNamePhysicalNetBIOS'^) as varchar^(15^)^)                      AS 'Computer Name',
>>%file_sql% echo        left^(convert^(varchar, dateadd^(second, ^(i.ms_ticks/1000^)*^(-1^), getdate^(^)^), %CNV_DATE%^)+' '+
>>%file_sql% echo             convert^(varchar, dateadd^(second, ^(i.ms_ticks/1000^)*^(-1^), getdate^(^)^), %CNV_TIME%^), 14^)       AS 'Last reboot',
>>%file_sql% echo        cast^(i.cpu_count/i.hyperthread_ratio as varchar^(10^)^)                                    AS 'Physical CPU Count',
>>%file_sql% echo        cast^(i.cpu_count as varchar^(10^)^)                                                        AS 'Logical CPU Count',
>>%file_sql% echo        left^(@value, 50^)                                                                        AS 'Processor description',
>>%file_sql% echo        i.physical_memory_in_bytes/1024/1024                                                    AS 'Total Physical Memory ^(MB^)',
>>%file_sql% echo        i.virtual_memory_in_bytes/1024/1024/1024                                                AS 'Total Virtual Memory ^(MB^)'
>>%file_sql% echo from sys.dm_os_sys_info   i WITH ^(NOLOCK^)
>>%file_sql% echo OPTION ^(RECOMPILE^);
>>%file_sql% echo:
>>%file_sql% echo select left^(@@VERSION, %LEN_SQLT%^) AS 'SQL Server and OS Version Info'
>>%file_sql% echo:
goto:EOF
::#
::# End of Audit_host_old
::#************************************************************#

:Audit_host_new
::#************************************************************#
::# Audits OS info available from SQL Server 2017
::#
>>%file_sql% echo PRINT '+----------------+'
>>%file_sql% echo PRINT '^| OS information ^|'
>>%file_sql% echo PRINT '+----------------+'
>>%file_sql% echo PRINT ''
>>%file_sql% echo:
>>%file_sql% echo select left^(o.host_platform, 8^)                                            AS 'Platform',
>>%file_sql% echo        left^(o.host_distribution, 20^)                                       AS 'Operating System',
>>%file_sql% echo        left^(case when o.host_service_pack_level = '' then 'RTM'
>>%file_sql% echo                   else o.host_service_pack_level end, 10^)                  AS 'Service Pack',
>>%file_sql% echo        left^(o.host_release, 7^)                                             AS 'Release',
>>%file_sql% echo        left^(case when o.host_sku =  4    then 'Enterprise'
>>%file_sql% echo                   when o.host_sku =  7    then 'Standard Server'
>>%file_sql% echo                   when o.host_sku =  8    then 'Datacenter Server'
>>%file_sql% echo                   when o.host_sku = 10    then 'Enterprise Server'
>>%file_sql% echo                   when o.host_sku = 48    then 'Professional Server'
>>%file_sql% echo                   when o.host_sku is null then 'Linux' end, 20^)             AS 'Edition',
>>%file_sql% echo        left^(cast^(o.os_language_version as varchar^)+' ^('+l.name+'^)', 20^)     AS 'Language'
>>%file_sql% echo from sys.dm_os_host_info o WITH ^(NOLOCK^) 
>>%file_sql% echo join sys.syslanguages l on l.lcid = o.os_language_version
>>%file_sql% echo option ^(RECOMPILE^);
>>%file_sql% echo:
goto:EOF
::#
::# End of Audit_host_new
::#************************************************************#

:Audit_aag
::#************************************************************#
::# Audits Always On Availability Group available from SQL Server 2012 version and later (if enabled on the server instance)
::#
>>%file_sql% echo if SERVERPROPERTY ('IsHadrEnabled') = 1
>>%file_sql% echo begin
>>%file_sql% echo   PRINT ''
>>%file_sql% echo   PRINT '+------------------------------+'
>>%file_sql% echo   PRINT '^| Always On Availability Group ^|'
>>%file_sql% echo   PRINT '+------------------------------+'
>>%file_sql% echo   PRINT ''
>>%file_sql% echo:
>>%file_sql% echo   select left^(agc.name, 15^)                                   AS 'Availability Group',
>>%file_sql% echo          left^(rcs.replica_server_name, 25^)                    AS 'Server instance',
>>%file_sql% echo          left^(ars.role_desc, 10^)                              AS 'Role',
>>%file_sql% echo          left^(rcs.join_state_desc, 20^)                        AS 'Joined State',
>>%file_sql% echo          left^(isnull^(ars.operational_state_desc,''^), 16^)      AS 'Replica State',
>>%file_sql% echo          left^(ars.connected_state_desc, 12^)                   AS 'Connection',
>>%file_sql% echo          left^(ars.synchronization_health_desc, 20^)            AS 'Synchronization',
>>%file_sql% echo          left^(agl.dns_name, 15^)                               AS 'Listener Name',
>>%file_sql% echo          cast^(agl.port as varchar^(4^)^)                         AS 'Port',
>>%file_sql% echo          left^(lia.ip_address, 15^)                             AS 'IP address',
>>%file_sql% echo          left^(upper^(ag.automated_backup_preference_desc^), 10^) AS 'Backup preference',
>>%file_sql% echo          left^(dhc.cluster_name, 15^)                           AS 'Cluster Name',
>>%file_sql% echo          left^(dhc.quorum_type_desc, 30^)                       AS 'Quorum model',
>>%file_sql% echo          left^(dhc.quorum_state_desc, 30^)                      AS 'Quorum state',
>>%file_sql% echo          cast^(case agc.failure_condition_level
>>%file_sql% echo                    when 1 then 'SQL Server service is down/SQL Server AlwaysOn lease Timeout'
>>%file_sql% echo                    when 2 then 'SQL Server instance does not connect to cluster/availability replica is in failed state'
>>%file_sql% echo                    when 3 then 'Critical SQL Server internal errors by default'
>>%file_sql% echo                    when 4 then 'Moderate SQL Server internal errors'
>>%file_sql% echo                    when 5 then 'Exhaustion of SQL Engine worker-threads/Detection of an unsolvable deadlock'
>>%file_sql% echo               end as varchar^(90^)^)                             AS 'Automatic Failover Condition'
>>%file_sql% echo   from sys.availability_groups_cluster agc
>>%file_sql% echo   join sys.dm_hadr_availability_replica_cluster_states rcs on rcs.group_id    = agc.group_id
>>%file_sql% echo   join sys.dm_hadr_availability_replica_states ars         on ars.replica_id  = rcs.replica_id
>>%file_sql% echo   join sys.availability_group_listeners agl                on agl.group_id    = ars.group_id
>>%file_sql% echo   join sys.availability_group_listener_ip_addresses lia    on lia.listener_id = agl.listener_id
>>%file_sql% echo   join sys.availability_groups ag                          on ag.group_id     = agc.group_id
>>%file_sql% echo   cross apply sys.dm_hadr_cluster dhc
>>%file_sql% echo   where ars.role_desc = 'PRIMARY';
>>%file_sql% echo:
>>%file_sql% echo   PRINT ''
>>%file_sql% echo   select left^(ar.replica_server_name, 25^)                                                        AS 'Server instance',
>>%file_sql% echo          left^(ars.role_desc, 10^)                                                                 AS 'Role',
>>%file_sql% echo          left^(ar.availability_mode_desc, 20^)                                                     AS 'Availability mode',
>>%file_sql% echo          left^(ar.failover_mode_desc, 10^)                                                         AS 'Failover mode',
>>%file_sql% echo          right^(replicate^(' ',11-len^(ar.session_timeout^)^)+cast^(ar.session_timeout as varchar^),11^) AS 'Timeout ^(s^)',
>>%file_sql% echo          left^(ar.endpoint_url, 40^)                                                               AS 'Endpoint URL',
>>%file_sql% echo          left^(ar.primary_role_allow_connections_desc + ' / ' +
>>%file_sql% echo               ar.secondary_role_allow_connections_desc, 20^)                                      AS 'Connections allowed in Primary / Secondary'
>>%file_sql% echo   from sys.availability_replicas ar
>>%file_sql% echo   join sys.dm_hadr_availability_replica_states ars on ars.replica_id = ar.replica_id;
>>%file_sql% echo:
>>%file_sql% echo   PRINT ''
>>%file_sql% echo   ;with ag_stats as
>>%file_sql% echo   ^(
>>%file_sql% echo   select ar.replica_server_name, ars.role_desc, db_name^(drs.database_id^) as dbname, drs.last_commit_time
>>%file_sql% echo   from sys.dm_hadr_database_replica_states drs
>>%file_sql% echo   join sys.availability_replicas ar on drs.replica_id = ar.replica_id
>>%file_sql% echo   join sys.dm_hadr_availability_replica_states ars on ar.group_id = ars.group_id and ar.replica_id = ars.replica_id
>>%file_sql% echo   ^),
>>%file_sql% echo   waits as
>>%file_sql% echo   ^(
>>%file_sql% echo   select wait_type, waiting_tasks_count, wait_time_ms, wait_time_ms/waiting_tasks_count as sync_lag_ms
>>%file_sql% echo   from sys.dm_os_wait_stats
>>%file_sql% echo   where waiting_tasks_count ^> 0
>>%file_sql% echo   and wait_type = 'HADR_SYNC_COMMIT'
>>%file_sql% echo   ^),
>>%file_sql% echo   pri_committime as ^(select replica_server_name, dbname, last_commit_time from ag_stats where role_desc = 'PRIMARY'^),
>>%file_sql% echo   sec_committime as ^(select replica_server_name, dbname, last_commit_time from ag_stats where role_desc = 'SECONDARY'^)
>>%file_sql% echo   select left^(p.replica_server_name, 25^)                                 AS 'Primary replica',
>>%file_sql% echo          left^(s.replica_server_name, 25^)                                 AS 'Secondary replica',
>>%file_sql% echo          left^(dc.database_name, 10^)                                      AS 'DB Name',
>>%file_sql% echo          left^(dr.database_state_desc, 15^)                                AS 'DB State',
>>%file_sql% echo          left^(dr.synchronization_state_desc, 20^)                         AS 'Synchronization',
>>%file_sql% echo          left^(dr.synchronization_health_desc, 20^)                        AS 'Health',
>>%file_sql% echo          cast^(w.sync_lag_ms as int^)                                      AS 'Sync ^(ms^)',
>>%file_sql% echo          cast^(datediff^(ms,s.last_commit_time,p.last_commit_time^) as int^) AS 'Wait ^(ms^)',
>>%file_sql% echo          left^(isnull^(dr.suspend_reason_desc,''^), 25^)                     AS 'Suspend Reason'
>>%file_sql% echo   from sys.dm_hadr_database_replica_states dr
>>%file_sql% echo   join sys.availability_databases_cluster dc on dr.group_database_id=dc.group_database_id
>>%file_sql% echo   join pri_committime p on p.dbname = dc.database_name
>>%file_sql% echo   join sec_committime s on s.dbname = p.dbname
>>%file_sql% echo   cross apply waits w
>>%file_sql% echo   where is_local=1;
>>%file_sql% echo:
>>%file_sql% echo   PRINT ''
>>%file_sql% echo   select left^(db_name^(drs.database_id^), 10^)                                                         AS 'DB Name',
>>%file_sql% echo          case when len^(drs.last_received_lsn^) = 20
>>%file_sql% echo 		 then substring^(cast^(drs.last_received_lsn as varchar^), 1, 8^)+':'+
>>%file_sql% echo 		      substring^(cast^(drs.last_received_lsn as varchar^), 9, 8^)+':'+
>>%file_sql% echo 		      substring^(cast^(drs.last_received_lsn as varchar^), 17, 4^)
>>%file_sql% echo 	     else substring^(cast^(drs.last_received_lsn as varchar^), 1, 3^)+':'+
>>%file_sql% echo 		      substring^(cast^(drs.last_received_lsn as varchar^), 4, 10^)+':'+
>>%file_sql% echo 		      substring^(cast^(drs.last_received_lsn as varchar^), 14, 5^) end                          AS 'Last Received LSN',
>>%file_sql% echo          case when len^(drs.end_of_log_lsn^) = 20
>>%file_sql% echo 		 then substring^(cast^(drs.end_of_log_lsn as varchar^), 1, 8^)+':'+
>>%file_sql% echo 		      substring^(cast^(drs.end_of_log_lsn as varchar^), 9, 8^)+':'+
>>%file_sql% echo 		      substring^(cast^(drs.end_of_log_lsn as varchar^), 17, 4^)
>>%file_sql% echo 	     else substring^(cast^(drs.end_of_log_lsn as varchar^), 1, 3^)+':'+
>>%file_sql% echo 		      substring^(cast^(drs.end_of_log_lsn as varchar^), 4, 10^)+':'+
>>%file_sql% echo 		      substring^(cast^(drs.end_of_log_lsn as varchar^), 14, 5^) end                             AS 'Last Cached LSN',
>>%file_sql% echo          case when len^(drs.last_redone_lsn^) = 20
>>%file_sql% echo 		 then substring^(cast^(drs.last_redone_lsn as varchar^), 1, 8^)+':'+
>>%file_sql% echo 		      substring^(cast^(drs.last_redone_lsn as varchar^), 9, 8^)+':'+
>>%file_sql% echo 		      substring^(cast^(drs.last_redone_lsn as varchar^), 17, 4^)
>>%file_sql% echo 	     else substring^(cast^(drs.last_redone_lsn as varchar^), 1, 3^)+':'+
>>%file_sql% echo 		      substring^(cast^(drs.last_redone_lsn as varchar^), 4, 10^)+':'+
>>%file_sql% echo 		      substring^(cast^(drs.last_redone_lsn as varchar^), 14, 5^) end                            AS 'Last Redone LSN',
>>%file_sql% echo          case when len^(drs.last_hardened_lsn^) = 20
>>%file_sql% echo 		 then substring^(cast^(drs.last_hardened_lsn as varchar^), 1, 8^)+':'+
>>%file_sql% echo 		      substring^(cast^(drs.last_hardened_lsn as varchar^), 9, 8^)+':'+
>>%file_sql% echo 		      substring^(cast^(drs.last_hardened_lsn as varchar^), 17, 4^)
>>%file_sql% echo 	     else substring^(cast^(drs.last_hardened_lsn as varchar^), 1, 3^)+':'+
>>%file_sql% echo 		      substring^(cast^(drs.last_hardened_lsn as varchar^), 4, 10^)+':'+
>>%file_sql% echo 		      substring^(cast^(drs.last_hardened_lsn as varchar^), 14, 5^) end                          AS 'Last Hardened LSN',
>>%file_sql% echo          case when len^(drs.last_commit_lsn^) = 20
>>%file_sql% echo 		 then substring^(cast^(drs.last_commit_lsn as varchar^), 1, 8^)+':'+
>>%file_sql% echo 		      substring^(cast^(drs.last_commit_lsn as varchar^), 9, 8^)+':'+
>>%file_sql% echo 		      substring^(cast^(drs.last_commit_lsn as varchar^), 17, 4^)
>>%file_sql% echo 	     else substring^(cast^(drs.last_commit_lsn as varchar^), 1, 3^)+':'+
>>%file_sql% echo 		      substring^(cast^(drs.last_commit_lsn as varchar^), 4, 10^)+':'+
>>%file_sql% echo 		      substring^(cast^(drs.last_commit_lsn as varchar^), 14, 5^) end                            AS 'Last Commit LSN',
>>%file_sql% echo          left^(format^(drs.last_commit_time,   '%FMT_DAT3%'^),17^)                               AS 'Last Commit time',
>>%file_sql% echo          cast^(cast^(^(^(datediff^(s,last_commit_time,getdate^(^)^)^)/3600^) as varchar^) + ' hour^(s^) '
>>%file_sql% echo          + cast^(^(datediff^(s,last_commit_time,getdate^(^)^)%%3600^)/60 as varchar^) + ' min '
>>%file_sql% echo          + cast^(^(datediff^(s,last_commit_time,getdate^(^)^)%%60^) as varchar^) + ' sec' as varchar^(25^)^)    AS 'Elapsed Commit Time',
>>%file_sql% echo          left^(format^(drs.last_sent_time,     '%FMT_TIME%'^),13^)                               AS 'Last Sent',
>>%file_sql% echo          left^(format^(drs.last_received_time, '%FMT_TIME%'^),13^)                               AS 'Last Received',
>>%file_sql% echo          left^(format^(drs.last_redone_time,   '%FMT_TIME%'^),13^)                               AS 'Last Redone',
>>%file_sql% echo          left^(format^(drs.last_hardened_time, '%FMT_TIME%'^),13^)                               AS 'Last Hardened',
>>%file_sql% echo          right^(replicate^(' ',12-len^(datediff^(SECOND, last_redone_time, last_hardened_time^)^)^)+cast^(datediff^(SECOND, last_redone_time, last_hardened_time^) as varchar^),12^) AS 'Duration ^(s^)'
>>%file_sql% echo   from sys.dm_hadr_availability_replica_cluster_nodes n
>>%file_sql% echo   join sys.dm_hadr_availability_replica_cluster_states rcs on n.replica_server_name = rcs.replica_server_name
>>%file_sql% echo   join sys.dm_hadr_availability_replica_states ars         on ars.replica_id        = rcs.replica_id
>>%file_sql% echo   join sys.dm_hadr_database_replica_states drs             on ars.replica_id        = drs.replica_id
>>%file_sql% echo   where n.replica_server_name ^<^> @@Servername;
>>%file_sql% echo   PRINT ''
>>%file_sql% echo end
>>%file_sql% echo:
goto:EOF
::#
::# End of Audit_aag
::#************************************************************#

:Audit_db
::#************************************************************#
::# Audits info about SQL Server instance, database, services, registry, linked severs and Log Shipping summary & history (optional)
::#
>>%file_sql% echo PRINT ''
>>%file_sql% echo PRINT '+-------------------+'
>>%file_sql% echo PRINT '^| SQL instance info ^|'
>>%file_sql% echo PRINT '+-------------------+'
>>%file_sql% echo PRINT ''
>>%file_sql% echo:
>>%file_sql% echo select cast^(isnull^(ServerProperty^('InstanceName'^), ServerProperty^('MachineName'^)^) as varchar^(15^)^)                                              AS 'Instance',
>>%file_sql% echo        cast^(ServerProperty^('Edition'^)                     as varchar^(30^)^)                                                                      AS 'SQL Edition',
>>%file_sql% echo        cast^(ServerProperty^('ProductLevel'^)                as varchar^(15^)^)                                                                      AS 'Product Level',
>>%file_sql% echo        cast^(ServerProperty^('ProductVersion'^)              as varchar^(15^)^)                                                                      AS 'Product Version',
>>%file_sql% echo        cast^(ServerProperty^('Collation'^)                   as varchar^(25^)^)                                                                      AS 'Collation Name',
>>%file_sql% echo        left(case ServerProperty^('IsIntegratedSecurityOnly'^) when 1 then 'Windows'
>>%file_sql% echo                                                             when 0 then 'Windows and SQL Server' end, 22)                                      AS 'Authentication Mode',
>>%file_sql% echo        left^(@@language, 10^)                                                                                                                    AS 'Language',
>>%file_sql% echo        left^(substring^(physical_name, 1, charindex^('\master.mdf', lower^(physical_name^)^) - 1^),80^)                                                AS 'Default Home',
if "%VER_SQL%"=="11.0" >>%file_sql% echo        left^(format^(convert^(datetime, o.createdate, 120^), '%FMT_DAT1%'^), 8^)                                                                       AS 'Install',
if "%VER_SQL%"=="11.0" >>%file_sql% echo        left^(format^(s.sqlserver_start_time, '%FMT_DAT2%'^),14^)                                                                               AS 'Startup Time',
if "%VER_SQL%"=="11.0" >>%file_sql% echo        left(format^(convert(datetime, l.[Checkpoint Begin], 120), '%FMT_DAT2%'), 16)                                                            AS 'Last Log Shrink',
if "%VER_SQL%"=="12.0" >>%file_sql% echo        left^(format^(convert^(datetime, o.createdate, 120^), '%FMT_DAT1%'^), 8^)                                                                       AS 'Install',
if "%VER_SQL%"=="12.0" >>%file_sql% echo        left^(format^(s.sqlserver_start_time, '%FMT_DAT2%'^),14^)                                                                               AS 'Startup Time',
if "%VER_SQL%"=="12.0" >>%file_sql% echo        left(format^(convert(datetime, l.[Checkpoint Begin], 120), '%FMT_DAT2%'), 16)                                                            AS 'Last Log Shrink',
if "%VER_SQL%"=="13.0" >>%file_sql% echo        left^(format^(convert^(datetime, o.createdate, 120^), '%FMT_DAT1%'^), 8^)                                                                       AS 'Install',
if "%VER_SQL%"=="13.0" >>%file_sql% echo        left^(format^(s.sqlserver_start_time, '%FMT_DAT2%'^),14^)                                                                               AS 'Startup Time',
if "%VER_SQL%"=="13.0" >>%file_sql% echo        left(format^(convert(datetime, l.[Checkpoint Begin], 120), '%FMT_DAT2%'), 16)                                                            AS 'Last Log Shrink',
if "%VER_SQL%"=="14.0" >>%file_sql% echo        left^(format^(convert^(datetime, o.createdate, 120^), '%FMT_DAT1%'^), 8^)                                                                       AS 'Install',
if "%VER_SQL%"=="14.0" >>%file_sql% echo        left^(format^(s.sqlserver_start_time, '%FMT_DAT2%'^),14^)                                                                               AS 'Startup Time',
if not "%VER_SQL%"=="11.0" if not "%VER_SQL%"=="12.0" if not "%VER_SQL%"=="13.0" if not "%VER_SQL%"=="14.0" >>%file_sql% echo        ^(select left(convert(varchar, convert(datetime, s.login_time, 120), 3), 8) from master..sysprocesses s where s.spid = 1^)                AS 'Startup Time',     
>>%file_sql% echo        ^(select convert^(varchar^(3^), datediff^(mi, s.login_time, getdate^(^)^)/60/24) + ' days'
>>%file_sql% echo          from master..sysprocesses s where s.spid = 1^)                                                                                         AS 'Uptime',
if "%VER_SQL%"=="14.0" >>%file_sql% echo        left(format^(convert(datetime, l.[Checkpoint Begin], 120), '%FMT_DAT2%'), 16) AS 'Last Log Shrink',
if not "%VER_SQL%"=="11.0" if not "%VER_SQL%"=="12.0" if not "%VER_SQL%"=="13.0" if not "%VER_SQL%"=="14.0" >>%file_sql% echo        left^(convert^(varchar, convert^(datetime, l.[Checkpoint Begin], 120^), %CNV_DATE%)+' '+
if not "%VER_SQL%"=="11.0" if not "%VER_SQL%"=="12.0" if not "%VER_SQL%"=="13.0" if not "%VER_SQL%"=="14.0" >>%file_sql% echo              convert^(varchar, convert^(datetime, l.[Checkpoint Begin], 120^), %CNV_TIME%), 16) AS 'Last Log Shrink',
>>%file_sql% echo        case when ServerProperty^('IsClustered'^)   = 1 then 'Yes' else 'No' end                                                                  AS 'Is Clustered?',
>>%file_sql% echo        case when ServerProperty^('IsHadrEnabled'^) = 1 then 'Yes' else 'No' end                                                                  AS 'Is Always On?',
>>%file_sql% echo        ^(select case count^(distinct o.parent_node_id^) when 1 then 'No' else 'Yes' end from sys.dm_os_schedulers o where o.parent_node_id ^<^> 32^) AS 'Is NUMA Enabled?'
>>%file_sql% echo from sys.fn_dblog^(NULL,NULL^) l,
>>%file_sql% echo      sys.master_files f        WITH ^(NOLOCK^),
>>%file_sql% echo      sys.dm_os_sys_info s      WITH ^(NOLOCK^),
>>%file_sql% echo      sys.syslogins o           WITH ^(NOLOCK^)
>>%file_sql% echo where f.database_id = 1
>>%file_sql% echo and   f.file_id = 1
>>%file_sql% echo and   l.Operation = 'LOP_BEGIN_CKPT'
>>%file_sql% echo and   o.sid = 0x010100000000000512000000
>>%file_sql% echo OPTION ^(RECOMPILE^);
>>%file_sql% echo:
>>%file_sql% echo PRINT ''
>>%file_sql% echo PRINT '+---------+'
>>%file_sql% echo PRINT '^| DB info ^|'
>>%file_sql% echo PRINT '+---------+'
>>%file_sql% echo PRINT ''
>>%file_sql% echo:
>>%file_sql% echo select left^(d.name, %LEN_DBNAME%^)                                                                                      AS 'DB Name',
>>%file_sql% echo        right^(replicate^(' ',4-len^(cast^(d.database_id as char^)^)^)+cast^(d.database_id as varchar^),4^) AS 'DBID',
if "%VER_SQL%"=="11.0" >>%file_sql% echo        left^(format^(d.create_date, '%FMT_DAT1%'^),8^)                                                            AS 'Creation',
if "%VER_SQL%"=="12.0" >>%file_sql% echo        left^(format^(d.create_date, '%FMT_DAT1%'^),8^)                                                            AS 'Creation',
if "%VER_SQL%"=="13.0" >>%file_sql% echo        left^(format^(d.create_date, '%FMT_DAT1%'^),8^)                                                            AS 'Creation',
if "%VER_SQL%"=="14.0" >>%file_sql% echo        left^(format^(d.create_date, '%FMT_DAT1%'^),8^)                                                            AS 'Creation',
if not "%VER_SQL%"=="11.0" if not "%VER_SQL%"=="12.0" if not "%VER_SQL%"=="13.0" if not "%VER_SQL%"=="14.0" >>%file_sql% echo        left^(convert^(varchar, d.create_date, %CNV_DATE%^),10^)                                                          AS 'Creation',
if "%VER_SQL%"=="11.0" >>%file_sql% echo        (select isnull(left(format(max(b.backup_finish_date), '%FMT_DAT1%'),8),'')
if "%VER_SQL%"=="11.0" >>%file_sql% echo         from msdb.dbo.backupset b where b.database_name = d.name)                                           AS 'Last Backup',
if "%VER_SQL%"=="12.0" >>%file_sql% echo        (select isnull(left(format(max(b.backup_finish_date), '%FMT_DAT1%'),8),'')
if "%VER_SQL%"=="12.0" >>%file_sql% echo         from msdb.dbo.backupset b where b.database_name = d.name)                                           AS 'Last Backup',
if "%VER_SQL%"=="13.0" >>%file_sql% echo        (select isnull(left(format(max(b.backup_finish_date), '%FMT_DAT1%'),8),'')
if "%VER_SQL%"=="13.0" >>%file_sql% echo         from msdb.dbo.backupset b where b.database_name = d.name)                                           AS 'Last Backup',
if "%VER_SQL%"=="14.0" >>%file_sql% echo        (select isnull(left(format(max(b.backup_finish_date), '%FMT_DAT1%'),8),'')
if "%VER_SQL%"=="14.0" >>%file_sql% echo         from msdb.dbo.backupset b where b.database_name = d.name)                                           AS 'Last Backup',
if not "%VER_SQL%"=="11.0" if not "%VER_SQL%"=="12.0" if not "%VER_SQL%"=="13.0" if not "%VER_SQL%"=="14.0" >>%file_sql% echo        (select isnull(left(convert^(varchar, max^(b.backup_finish_date^), %CNV_DATE%^),10^),'')
if not "%VER_SQL%"=="11.0" if not "%VER_SQL%"=="12.0" if not "%VER_SQL%"=="13.0" if not "%VER_SQL%"=="14.0" >>%file_sql% echo         from msdb.dbo.backupset b where b.database_name = d.name)                                           AS 'Last Backup',
>>%file_sql% echo        left^(d.state_desc, 10^)                                                                               AS 'Status',
>>%file_sql% echo        cast^(c1.cntr_value/1024.0 as dec^(7,1^)^)                                                               AS 'Log Size ^(MB^)',
>>%file_sql% echo        cast^(c2.cntr_value/1024.0 as dec^(7,1^)^)                                                               AS 'Log Used ^(MB^)',
>>%file_sql% echo        cast^(cast^(c2.cntr_value as float^) / cast^(c1.cntr_value as float^) * 100.0 as dec^(4,1^)^)                AS 'Log Used %%',
>>%file_sql% echo        left^(case d.compatibility_level
>>%file_sql% echo                   when 150 then 'MSSQL 2019'
>>%file_sql% echo                   when 140 then 'MSSQL 2017'
>>%file_sql% echo                   when 130 then 'MSSQL 2016'
>>%file_sql% echo                   when 120 then 'MSSQL 2014'
>>%file_sql% echo                   when 110 then 'MSSQL 2012'
>>%file_sql% echo                   when 100 then 'MSSQL 2008'
>>%file_sql% echo                   when  90 then 'MSSQL 2005' end + ' ^(' + cast^(d.compatibility_level as varchar) + '^)', 19^) AS 'Compatibility Level',
>>%file_sql% echo        left^(case d.compatibility_level
>>%file_sql% echo                   when 150 then 'CE 150'
>>%file_sql% echo                   when 140 then 'CE 140'
>>%file_sql% echo                   when 130 then 'CE 130'
>>%file_sql% echo                            else 'CE 70' end, 21^)                                                            AS 'Cardinality Estimator',
>>%file_sql% echo        left^(d.recovery_model_desc, 15^)                                                                      AS 'Recovery Model',
>>%file_sql% echo        left^(d.collation_name, 25^)                                                                           AS 'Collation Name',
>>%file_sql% echo        left^(d.user_access_desc, 15^)                                                                         AS 'User Access',
>>%file_sql% echo        case d.is_read_only                  when 0 then 'READ-WRITE' else 'READ-ONLY' end                   AS 'Open Mode',
>>%file_sql% echo        case d.snapshot_isolation_state      when 1 then 'Yes'        else ''          end                   AS 'Is Allow Snapshot Isolation',
>>%file_sql% echo        case d.is_read_committed_snapshot_on when 1 then 'Yes'        else ''          end                   AS 'Is Read Committed Snapshot',
>>%file_sql% echo        case d.is_auto_create_stats_on       when 1 then 'Yes'        else ''          end                   AS 'Is Auto Create Stats',
>>%file_sql% echo        case d.is_auto_update_stats_on       when 1 then 'Yes'        else ''          end                   AS 'Is Auto Update Stats'
>>%file_sql% echo from sys.databases d
>>%file_sql% echo join sys.dm_os_performance_counters c1 on c1.instance_name = d.name
>>%file_sql% echo join sys.dm_os_performance_counters c2 on c2.instance_name = d.name
>>%file_sql% echo where c1.counter_name like 'Log File(s) Size (KB)%%'
>>%file_sql% echo and   c1.cntr_value ^> 0
>>%file_sql% echo and   c2.counter_name like 'Log File(s) Used Size (KB)%%'
>>%file_sql% echo order by d.database_id desc
>>%file_sql% echo OPTION ^(RECOMPILE^);
>>%file_sql% echo:
>>%file_sql% echo PRINT ''
>>%file_sql% echo PRINT '+-------------+'
>>%file_sql% echo PRINT '^| DB activity ^|'
>>%file_sql% echo PRINT '+-------------+'
>>%file_sql% echo PRINT ''
>>%file_sql% echo:
>>%file_sql% echo select left^(db_name^(convert^(smallint, p.value^)^), 13^)                                                                             AS 'DB Name',
>>%file_sql% echo        right^(replicate^(' ',4-len^(cast^(p.value as varchar^)^)^)+cast^(p.value as varchar^),4^)                                          AS 'DBID',
>>%file_sql% echo 	     right^(replicate^(' ',16-len^(sum^(qs.total_elapsed_time/1000000^)^)^)+cast^(sum^(qs.total_elapsed_time/1000000^) as varchar^),16^) AS 'Elapsed time ^(s^)',
>>%file_sql% echo 	     right^('0' + cast^(sum^(qs.total_elapsed_time/1000000^) / 3600 as varchar^),2^) + ':' +
>>%file_sql% echo 	     right^('0' + cast^(^(sum^(qs.total_elapsed_time/1000000^) / 60^) %% 60 as varchar^),2^) + ':' +
>>%file_sql% echo 	     right^('0' + cast^(sum^(qs.total_elapsed_time/1000000^) %% 60 as varchar^),2^)                                                 AS 'Duration',
>>%file_sql% echo 	     right^(replicate^(' ',12-len^(sum^(qs.total_worker_time/1000000^)^)^)+cast^(sum^(qs.total_worker_time/1000000^) as varchar^),12^)   AS 'CPU time ^(s^)',
>>%file_sql% echo        cast^(100. *sum^(qs.total_elapsed_time^) / sum^(sum^(qs.total_elapsed_time^)^) OVER^(^) as dec^(4,1^)^)                               AS 'Activity ^(%%^)'
>>%file_sql% echo from sys.dm_exec_query_stats qs
>>%file_sql% echo cross apply sys.dm_exec_plan_attributes^(qs.plan_handle^) p
>>%file_sql% echo where p.attribute = 'dbid'
>>%file_sql% echo and   p.value != 32767
>>%file_sql% echo group by p.value
>>%file_sql% echo having sum^(qs.total_elapsed_time/1000000^)+sum^(qs.total_worker_time/1000000^) ^> 0
>>%file_sql% echo order by sum^(qs.total_elapsed_time^)+sum^(qs.total_worker_time^) desc
>>%file_sql% echo OPTION ^(RECOMPILE^);
>>%file_sql% echo:
>>%file_sql% echo PRINT ''
>>%file_sql% echo PRINT '+---------+'
>>%file_sql% echo PRINT '^| DB size ^|'
>>%file_sql% echo PRINT '+---------+'
>>%file_sql% echo PRINT ''
>>%file_sql% echo:
>>%file_sql% echo select left^(db_name^(f.database_id^), %LEN_DBNAME%^)                                                                           AS 'DB Name',
>>%file_sql% echo        right^(replicate^(' ',4-len^(f.database_id^)^)+cast^(f.database_id as varchar^),4^)                               AS 'DBID',
>>%file_sql% echo        cast^(sum^(case when f.type_desc = 'ROWS' then f.size else 0 end*CONVERT^(float,8^)/1024.0/1024^) as dec^(5,1^)^) AS 'DAT Size ^(GB^)',
>>%file_sql% echo        cast^(sum^(case when f.type_desc = 'LOG'  then f.size else 0 end*CONVERT^(float,8^)/1024.0/1024^) as dec^(5,1^)^) AS 'LOG Size ^(GB^)',
>>%file_sql% echo        cast^(sum^(f.size*CONVERT^(float,8^)/1024.0/1024^) as dec^(5,1^)^)                                                AS 'TOT Size ^(GB^)',
>>%file_sql% echo        cast^(count^(f.file_id^) as tinyint^)                                                                         AS 'TOT files'
>>%file_sql% echo from sys.master_files f
>>%file_sql% echo group by f.database_id
>>%file_sql% echo union all
>>%file_sql% echo select right^('*** TOTAL ***', 50^),
>>%file_sql% echo        '',
>>%file_sql% echo        cast^(sum^(case when f.type_desc = 'ROWS' then f.size else 0 end*CONVERT^(float,8^)/1024.0/1024^) as dec^(5,1^)^) AS 'DAT Size ^(GB^)',
>>%file_sql% echo        cast^(sum^(case when f.type_desc = 'LOG'  then f.size else 0 end*CONVERT^(float,8^)/1024.0/1024^) as dec^(5,1^)^) AS 'LOG Size ^(GB^)',
>>%file_sql% echo        cast^(sum^(f.size*CONVERT^(float,8^)/1024.0/1024^) as dec^(5,1^)^)                                                AS 'TOT Size ^(GB^)',
>>%file_sql% echo        cast^(count^(f.file_id^) as tinyint^)                                                                         AS 'TOT files'
>>%file_sql% echo from sys.master_files f
>>%file_sql% echo order by 5 desc;
>>%file_sql% echo:
if not "%VER_SQL%"=="9.0" if not "%VER_SQL%"=="10.0" >>%file_sql% echo PRINT ''
if not "%VER_SQL%"=="9.0" if not "%VER_SQL%"=="10.0" >>%file_sql% echo PRINT '+----------+'
if not "%VER_SQL%"=="9.0" if not "%VER_SQL%"=="10.0" >>%file_sql% echo PRINT '^| Services ^|'
if not "%VER_SQL%"=="9.0" if not "%VER_SQL%"=="10.0" >>%file_sql% echo PRINT '+----------+'
if not "%VER_SQL%"=="9.0" if not "%VER_SQL%"=="10.0" >>%file_sql% echo PRINT ''
if not "%VER_SQL%"=="9.0" if not "%VER_SQL%"=="10.0" >>%file_sql% echo select left^(s.servicename, 50^)                                                                                       AS 'Service name',
if not "%VER_SQL%"=="9.0" if not "%VER_SQL%"=="10.0" >>%file_sql% echo        left^(case when s.process_id is null then ' ' else cast^(s.process_id as varchar^) end, 6^)                       AS 'PID',
if not "%VER_SQL%"=="9.0" if not "%VER_SQL%"=="10.0" >>%file_sql% echo        left^(s.startup_type_desc, 12^)                                                                                 AS 'Startup type',
if not "%VER_SQL%"=="9.0" if not "%VER_SQL%"=="10.0" >>%file_sql% echo        left^(s.status_desc, 7^)                                                                                        AS 'Status',
if not "%VER_SQL%"=="9.0" if not "%VER_SQL%"=="10.0" if "%VER_SQL%"=="11.0" >>%file_sql% echo        left^(case when s.last_startup_time is null then '' else format^(s.last_startup_time, '%FMT_DAT2%'^) end,14^) AS 'Last Startup Time',
if not "%VER_SQL%"=="9.0" if not "%VER_SQL%"=="10.0" if "%VER_SQL%"=="12.0" >>%file_sql% echo        left^(case when s.last_startup_time is null then '' else format^(s.last_startup_time, '%FMT_DAT2%'^) end,14^) AS 'Last Startup Time',
if not "%VER_SQL%"=="9.0" if not "%VER_SQL%"=="10.0" if "%VER_SQL%"=="13.0" >>%file_sql% echo        left^(case when s.last_startup_time is null then '' else format^(s.last_startup_time, '%FMT_DAT2%'^) end,14^) AS 'Last Startup Time',
if not "%VER_SQL%"=="9.0" if not "%VER_SQL%"=="10.0" if "%VER_SQL%"=="14.0" >>%file_sql% echo        left^(case when s.last_startup_time is null then '' else format^(s.last_startup_time, '%FMT_DAT2%'^) end,14^) AS 'Last Startup Time',
if not "%VER_SQL%"=="9.0" if not "%VER_SQL%"=="10.0" if not "%VER_SQL%"=="11.0" if not "%VER_SQL%"=="12.0" if not "%VER_SQL%"=="13.0" if not "%VER_SQL%"=="14.0" >>%file_sql% echo        left^(case when s.last_startup_time is null then '' else convert^(varchar, s.last_startup_time, %CNV_DATE%^)+' '+
if not "%VER_SQL%"=="9.0" if not "%VER_SQL%"=="10.0" if not "%VER_SQL%"=="11.0" if not "%VER_SQL%"=="12.0" if not "%VER_SQL%"=="13.0" if not "%VER_SQL%"=="14.0" >>%file_sql% echo              convert^(varchar, s.last_startup_time, %CNV_TIME%^) end,14^)     AS 'Last Startup Time',
if not "%VER_SQL%"=="9.0" if not "%VER_SQL%"=="10.0" >>%file_sql% echo        left^(s.service_account, 30^)                                                                                   AS 'Service Account',
if not "%VER_SQL%"=="9.0" if not "%VER_SQL%"=="10.0" >>%file_sql% echo        left^(s.filename,110^)                                                                                          AS 'Path to executable',
if "%VER_SQL%"=="13.0" >>%file_sql% echo        case when s.instant_file_initialization_enabled = 'Y' then 'Yes' else 'No' end                                AS 'Instant file initialization',
if "%VER_SQL%"=="14.0" >>%file_sql% echo        case when s.instant_file_initialization_enabled = 'Y' then 'Yes' else 'No' end                                AS 'Instant file initialization',
if not "%VER_SQL%"=="9.0" if not "%VER_SQL%"=="10.0" >>%file_sql% echo        case when s.is_clustered = 'Y' then 'Yes' else 'No' end                                                       AS 'Is Clustered',
if not "%VER_SQL%"=="9.0" if not "%VER_SQL%"=="10.0" >>%file_sql% echo        left^(case when s.cluster_nodename is null then '' else s.cluster_nodename end, 12^)                            AS 'Cluster Node'
if not "%VER_SQL%"=="9.0" if not "%VER_SQL%"=="10.0" >>%file_sql% echo from sys.dm_server_services s WITH (NOLOCK) OPTION (RECOMPILE);
if not "%VER_SQL%"=="9.0" if not "%VER_SQL%"=="10.0" >>%file_sql% echo:
if not "%VER_SQL%"=="9.0" if not "%VER_SQL%"=="10.0" >>%file_sql% echo PRINT ''
if not "%VER_SQL%"=="9.0" if not "%VER_SQL%"=="10.0" >>%file_sql% echo PRINT '+----------+'
if not "%VER_SQL%"=="9.0" if not "%VER_SQL%"=="10.0" >>%file_sql% echo PRINT '^| Registry ^|'
if not "%VER_SQL%"=="9.0" if not "%VER_SQL%"=="10.0" >>%file_sql% echo PRINT '+----------+'
if not "%VER_SQL%"=="9.0" if not "%VER_SQL%"=="10.0" >>%file_sql% echo PRINT ''
if not "%VER_SQL%"=="9.0" if not "%VER_SQL%"=="10.0" >>%file_sql% echo select left^(reverse^(left^(reverse^(r.registry_key^), charindex^('\', reverse^(r.registry_key^)^) -1^)^), 15^) AS 'Key',
if not "%VER_SQL%"=="9.0" if not "%VER_SQL%"=="10.0" >>%file_sql% echo        left^(r.value_name, 20^)                     AS 'Name',
if not "%VER_SQL%"=="9.0" if not "%VER_SQL%"=="10.0" >>%file_sql% echo        left^(cast^(value_data as varchar^(80^)^), 80^) AS 'Value'
if not "%VER_SQL%"=="9.0" if not "%VER_SQL%"=="10.0" >>%file_sql% echo from sys.dm_server_registry r
if not "%VER_SQL%"=="9.0" if not "%VER_SQL%"=="10.0" >>%file_sql% echo where r.registry_key not like '%%\IP%%'
if not "%VER_SQL%"=="9.0" if not "%VER_SQL%"=="10.0" >>%file_sql% echo and   r.registry_key not like '%%\Via%%'
if not "%VER_SQL%"=="9.0" if not "%VER_SQL%"=="10.0" >>%file_sql% echo and   r.registry_key not like '%%\Np%%'
if not "%VER_SQL%"=="9.0" if not "%VER_SQL%"=="10.0" >>%file_sql% echo and   r.registry_key not like '%%\Sm%%'
if not "%VER_SQL%"=="9.0" if not "%VER_SQL%"=="10.0" >>%file_sql% echo order by 1, 2;
>>%file_sql% echo:
>>%file_sql% echo PRINT ''
>>%file_sql% echo PRINT '+----------------+'
>>%file_sql% echo PRINT '^| Linked servers ^|'
>>%file_sql% echo PRINT '+----------------+'
>>%file_sql% echo PRINT ''
>>%file_sql% echo:
>>%file_sql% echo select left^(s.name, 25^)                                                                    AS 'Server Name',
>>%file_sql% echo        left^(s.product, 10^)                                                                 AS 'Product',
>>%file_sql% echo        left^(s.provider, 20^)                                                                AS 'Provider',
>>%file_sql% echo        left^(s.data_source, 30^)                                                             AS 'Data source',
>>%file_sql% echo        case when s.is_remote_login_enabled = 1 then 'Yes' else '' end                      AS 'Remote Logins',
>>%file_sql% echo        cast^(case when s.query_timeout ^> 0 then s.query_timeout else '' end as varchar^(17^)^) AS 'Query timeout ^(s^)',
if "%VER_SQL%"=="11.0" >>%file_sql% echo        left^(format^(s.modify_date, '%FMT_DAT2%'^), 14^)                                   AS 'Last Updated'
if "%VER_SQL%"=="12.0" >>%file_sql% echo        left^(format^(s.modify_date, '%FMT_DAT2%'^), 14^)                                   AS 'Last Updated'
if "%VER_SQL%"=="13.0" >>%file_sql% echo        left^(format^(s.modify_date, '%FMT_DAT2%'^), 14^)                                   AS 'Last Updated'
if "%VER_SQL%"=="14.0" >>%file_sql% echo        left^(format^(s.modify_date, '%FMT_DAT2%'^), 14^)                                   AS 'Last Updated'
if not "%VER_SQL%"=="11.0" if not "%VER_SQL%"=="12.0" if not "%VER_SQL%"=="13.0" if not "%VER_SQL%"=="14.0" >>%file_sql% echo        left^(convert^(varchar, s.modify_date, %CNV_DATE%^)+' '+convert^(varchar, s.modify_date, %CNV_TIME%^), 14^) AS 'Last Updated'
>>%file_sql% echo from sys.servers s WITH ^(NOLOCK^) 
>>%file_sql% echo where s.is_linked = 1;
>>%file_sql% echo:
>>%file_sql% echo if exists ^(select 1 from msdb.dbo.log_shipping_primary_secondaries^)
>>%file_sql% echo begin
>>%file_sql% echo   PRINT ''
>>%file_sql% echo   PRINT '+------------------------+'
>>%file_sql% echo   PRINT '^| Log Shipping ^(summary^) ^|'
>>%file_sql% echo   PRINT '+------------------------+'
>>%file_sql% echo   PRINT ''
>>%file_sql% echo:
>>%file_sql% echo   select left^(m.primary_server, 20^)                                        AS 'Primary Server',
>>%file_sql% echo          left^(p.primary_database, %LEN_DBNAME%^)                                     AS 'Primary DB',
>>%file_sql% echo          left^(s.secondary_server, 20^)                                      AS 'Secondary Server',
>>%file_sql% echo          left^(s.secondary_database, %LEN_DBNAME%^)                                   AS 'Secondary DB',
>>%file_sql% echo          left^(p.backup_directory, 50^)                                     AS 'Local Backup directory',
>>%file_sql% echo          left^(p.backup_share, 50^)                                         AS 'Shared Backup directory',
>>%file_sql% echo          left^(p.monitor_server, 20^)                                       AS 'Monitor Server',
if "%VER_SQL%"=="11.0" >>%file_sql% echo          left^(format^(p.last_backup_date, '%FMT_DAT2%'^),14^)            AS 'Last Backup',
if "%VER_SQL%"=="12.0" >>%file_sql% echo          left^(format^(p.last_backup_date, '%FMT_DAT2%'^),14^)            AS 'Last Backup',
if "%VER_SQL%"=="13.0" >>%file_sql% echo          left^(format^(p.last_backup_date, '%FMT_DAT2%'^),14^)            AS 'Last Backup',
if "%VER_SQL%"=="14.0" >>%file_sql% echo          left^(format^(p.last_backup_date, '%FMT_DAT2%'^),14^)            AS 'Last Backup',
if not "%VER_SQL%"=="11.0" if not "%VER_SQL%"=="12.0" if not "%VER_SQL%"=="13.0" if not "%VER_SQL%"=="14.0" >>%file_sql% echo          left^(convert^(varchar, p.last_backup_date, %CNV_DATE%^)+' '+
if not "%VER_SQL%"=="11.0" if not "%VER_SQL%"=="12.0" if not "%VER_SQL%"=="13.0" if not "%VER_SQL%"=="14.0" >>%file_sql% echo               convert^(varchar, p.last_backup_date, %CNV_TIME%^), 14^)                AS 'Last Backup',
>>%file_sql% echo          datediff^(mi,p.last_backup_date,getdate^(^)^)                        AS 'Last backup ^(Min^)',
>>%file_sql% echo          left^(replace^(p.last_backup_file, p.backup_directory+'\',''^), 30^) AS 'Last Backup file',
>>%file_sql% echo          cast^(p.backup_retention_period as int^)                           AS 'Backup Retention ^(Min^)',
>>%file_sql% echo          cast^(m.backup_threshold as int^)                                  AS 'Backup Threshold ^(Min^)',
>>%file_sql% echo          cast^(m.threshold_alert as int^)                                   AS 'Threshold Alert ^(Min^)',
>>%file_sql% echo          cast^(m.history_retention_period as int^)                          AS 'History Retention ^(Min)'
>>%file_sql% echo   from msdb.dbo.log_shipping_primary_databases p
>>%file_sql% echo   join msdb.dbo.log_shipping_monitor_primary m     on p.primary_id = m.primary_id
>>%file_sql% echo   join msdb.dbo.log_shipping_primary_secondaries s on s.primary_id = m.primary_id;
>>%file_sql% echo:
>>%file_sql% echo   PRINT ''
>>%file_sql% echo   PRINT '+------------------------+'
>>%file_sql% echo   PRINT '^| Log Shipping ^(history^) ^|'
>>%file_sql% echo   PRINT '+------------------------+'
>>%file_sql% echo   PRINT ''
>>%file_sql% echo:
>>%file_sql% echo   select top %TOP_NSQL%
>>%file_sql% echo          left^(isnull^(h.database_name,''^), %LEN_DBNAME%^)                        AS 'DB Name',
>>%file_sql% echo          left^(case when h.agent_type = 0 then 'Backup'
>>%file_sql% echo                    when h.agent_type = 1 then 'Copy'
>>%file_sql% echo                    when h.agent_type = 2 then 'Restore' end, 8^)     AS 'Type',
if "%VER_SQL%"=="11.0" >>%file_sql% echo          left^(format^(h.log_time, '%FMT_DAT2%'^),14^)              AS 'Datetime',
if "%VER_SQL%"=="12.0" >>%file_sql% echo          left^(format^(h.log_time, '%FMT_DAT2%'^),14^)              AS 'Datetime',
if "%VER_SQL%"=="13.0" >>%file_sql% echo          left^(format^(h.log_time, '%FMT_DAT2%'^),14^)              AS 'Datetime',
if "%VER_SQL%"=="14.0" >>%file_sql% echo          left^(format^(h.log_time, '%FMT_DAT2%'^),14^)              AS 'Datetime',
if not "%VER_SQL%"=="11.0" if not "%VER_SQL%"=="12.0" if not "%VER_SQL%"=="13.0" if not "%VER_SQL%"=="14.0" >>%file_sql% echo          left^(convert^(varchar, h.log_time, %CNV_DATE%^)+' '+
if not "%VER_SQL%"=="11.0" if not "%VER_SQL%"=="12.0" if not "%VER_SQL%"=="13.0" if not "%VER_SQL%"=="14.0" >>%file_sql% echo               convert^(varchar, h.log_time, %CNV_TIME%^), 14^)                  AS 'Datetime',
>>%file_sql% echo          left^(case when h.session_status = 0 then 'Starting'
>>%file_sql% echo                    when h.session_status = 1 then 'Running'
>>%file_sql% echo                    when h.session_status = 2 then 'Success'
>>%file_sql% echo                    when h.session_status = 3 then 'Error'
>>%file_sql% echo                    when h.session_status = 4 then 'Warning' end, 8^) AS 'Status',
>>%file_sql% echo          left^(h.message, %LEN_SQLT%^)                                       AS 'Message'
>>%file_sql% echo   from msdb.dbo.log_shipping_monitor_history_detail h
>>%file_sql% echo   order by h.log_time desc;
>>%file_sql% echo end
>>%file_sql% echo:

goto:EOF
::#
::# End of Audit_db
::#************************************************************#

:Audit_opt
::#************************************************************#
::# Audits SQL Server configuration options and trace flags enabled globally
::#
>>%file_sql% echo PRINT ''
>>%file_sql% echo PRINT '+-----------------------+'
>>%file_sql% echo PRINT '^| Configuration options ^|'
>>%file_sql% echo PRINT '+-----------------------+'
>>%file_sql% echo PRINT ''
>>%file_sql% echo:
>>%file_sql% echo declare @config_defaults table ^(
>>%file_sql% echo     name          nvarchar^(35^),
>>%file_sql% echo     default_value sql_variant
>>%file_sql% echo ^)
>>%file_sql% echo insert into @config_defaults ^(name, default_value^) values ^('access check cache bucket count',0^)
>>%file_sql% echo insert into @config_defaults ^(name, default_value^) values ^('access check cache quota',0^)
>>%file_sql% echo insert into @config_defaults ^(name, default_value^) values ^('Ad Hoc Distributed Queries',0^)
>>%file_sql% echo insert into @config_defaults ^(name, default_value^) values ^('affinity I/O mask',0^)
>>%file_sql% echo insert into @config_defaults ^(name, default_value^) values ^('affinity mask',0^)
>>%file_sql% echo insert into @config_defaults ^(name, default_value^) values ^('affinity64 I/O mask',0^)
>>%file_sql% echo insert into @config_defaults ^(name, default_value^) values ^('affinity64 mask',0^)
>>%file_sql% echo insert into @config_defaults ^(name, default_value^) values ^('Agent XPs',1^)
>>%file_sql% echo insert into @config_defaults ^(name, default_value^) values ^('allow updates',0^)
>>%file_sql% echo insert into @config_defaults ^(name, default_value^) values ^('backup checksum default',0^)
>>%file_sql% echo insert into @config_defaults ^(name, default_value^) values ^('backup compression default',0^)
>>%file_sql% echo insert into @config_defaults ^(name, default_value^) values ^('blocked process threshold ^(s^)',0^)
>>%file_sql% echo insert into @config_defaults ^(name, default_value^) values ^('c2 audit mode',0^)
>>%file_sql% echo insert into @config_defaults ^(name, default_value^) values ^('clr enabled',0^)
>>%file_sql% echo insert into @config_defaults ^(name, default_value^) values ^('contained database authentication',0^)
>>%file_sql% echo insert into @config_defaults ^(name, default_value^) values ^('cost threshold for parallelism',5^)
>>%file_sql% echo insert into @config_defaults ^(name, default_value^) values ^('cross db ownership chaining',0^)
>>%file_sql% echo insert into @config_defaults ^(name, default_value^) values ^('cursor threshold',-1^)
>>%file_sql% echo insert into @config_defaults ^(name, default_value^) values ^('Database Mail XPs',0^)
if "%language%"=="FRA" >>%file_sql% echo insert into @config_defaults ^(name, default_value^) values ^('default full-text language',1033^)
if "%language%"=="FRA" >>%file_sql% echo insert into @config_defaults ^(name, default_value^) values ^('default language',0^)
if "%language%"=="ENG" >>%file_sql% echo insert into @config_defaults ^(name, default_value^) values ^('default full-text language',1036^)
if "%language%"=="ENG" >>%file_sql% echo insert into @config_defaults ^(name, default_value^) values ^('default language',2^)
>>%file_sql% echo insert into @config_defaults ^(name, default_value^) values ^('default trace enabled',1^)
>>%file_sql% echo insert into @config_defaults ^(name, default_value^) values ^('disallow results from triggers',0^)
>>%file_sql% echo insert into @config_defaults ^(name, default_value^) values ^('filestream access level',0^)
>>%file_sql% echo insert into @config_defaults ^(name, default_value^) values ^('fill factor ^(%%^)',0^)
>>%file_sql% echo insert into @config_defaults ^(name, default_value^) values ^('ft crawl bandwidth ^(max^)',100^)
>>%file_sql% echo insert into @config_defaults ^(name, default_value^) values ^('ft crawl bandwidth ^(min^)',0^)
>>%file_sql% echo insert into @config_defaults ^(name, default_value^) values ^('ft notify bandwidth ^(max^)',100^)
>>%file_sql% echo insert into @config_defaults ^(name, default_value^) values ^('ft notify bandwidth ^(min^)',0^)
>>%file_sql% echo insert into @config_defaults ^(name, default_value^) values ^('index create memory ^(KB^)',0^)
>>%file_sql% echo insert into @config_defaults ^(name, default_value^) values ^('in-doubt xact resolution',0^)
>>%file_sql% echo insert into @config_defaults ^(name, default_value^) values ^('lightweight pooling',0^)
>>%file_sql% echo insert into @config_defaults ^(name, default_value^) values ^('locks',0^)
>>%file_sql% echo insert into @config_defaults ^(name, default_value^) values ^('max degree of parallelism',0^)
>>%file_sql% echo insert into @config_defaults ^(name, default_value^) values ^('max full-text crawl range',4^)
>>%file_sql% echo insert into @config_defaults ^(name, default_value^) values ^('max server memory ^(MB^)',2147483647^)
>>%file_sql% echo insert into @config_defaults ^(name, default_value^) values ^('max text repl size ^(B^)',65536^)
>>%file_sql% echo insert into @config_defaults ^(name, default_value^) values ^('max worker threads',0^)
>>%file_sql% echo insert into @config_defaults ^(name, default_value^) values ^('media retention',0^)
>>%file_sql% echo insert into @config_defaults ^(name, default_value^) values ^('min memory per query ^(KB^)',1024^)
>>%file_sql% echo insert into @config_defaults ^(name, default_value^) values ^('min server memory ^(MB^)',0^)
>>%file_sql% echo insert into @config_defaults ^(name, default_value^) values ^('nested triggers',1^)
>>%file_sql% echo insert into @config_defaults ^(name, default_value^) values ^('network packet size ^(B^)',4096^)
>>%file_sql% echo insert into @config_defaults ^(name, default_value^) values ^('Ole Automation Procedures',0^)
>>%file_sql% echo insert into @config_defaults ^(name, default_value^) values ^('open objects',0^)
>>%file_sql% echo insert into @config_defaults ^(name, default_value^) values ^('optimize for ad hoc workloads',0^)
>>%file_sql% echo insert into @config_defaults ^(name, default_value^) values ^('PH timeout ^(s^)',60^)
>>%file_sql% echo insert into @config_defaults ^(name, default_value^) values ^('precompute rank',0^)
>>%file_sql% echo insert into @config_defaults ^(name, default_value^) values ^('priority boost',0^)
>>%file_sql% echo insert into @config_defaults ^(name, default_value^) values ^('query governor cost limit',0^)
>>%file_sql% echo insert into @config_defaults ^(name, default_value^) values ^('query wait ^(s^)',-1^)
>>%file_sql% echo insert into @config_defaults ^(name, default_value^) values ^('recovery interval ^(min^)',0^)
>>%file_sql% echo insert into @config_defaults ^(name, default_value^) values ^('remote access',1^)
>>%file_sql% echo insert into @config_defaults ^(name, default_value^) values ^('remote admin connections',0^)
>>%file_sql% echo insert into @config_defaults ^(name, default_value^) values ^('remote login timeout ^(s^)',10^)
>>%file_sql% echo insert into @config_defaults ^(name, default_value^) values ^('remote proc trans',0^)
>>%file_sql% echo insert into @config_defaults ^(name, default_value^) values ^('remote query timeout ^(s^)',600^)
>>%file_sql% echo insert into @config_defaults ^(name, default_value^) values ^('Replication XPs',0^)
>>%file_sql% echo insert into @config_defaults ^(name, default_value^) values ^('scan for startup procs',0^)
>>%file_sql% echo insert into @config_defaults ^(name, default_value^) values ^('server trigger recursion',1^)
>>%file_sql% echo insert into @config_defaults ^(name, default_value^) values ^('set working set size',0^)
>>%file_sql% echo insert into @config_defaults ^(name, default_value^) values ^('show advanced options',0^)
>>%file_sql% echo insert into @config_defaults ^(name, default_value^) values ^('SMO and DMO XPs',1^)
>>%file_sql% echo insert into @config_defaults ^(name, default_value^) values ^('transform noise words',0^)
>>%file_sql% echo insert into @config_defaults ^(name, default_value^) values ^('two digit year cutoff',2049^)
>>%file_sql% echo insert into @config_defaults ^(name, default_value^) values ^('user connections',0^)
>>%file_sql% echo insert into @config_defaults ^(name, default_value^) values ^('user options',0^)
>>%file_sql% echo insert into @config_defaults ^(name, default_value^) values ^('xp_cmdshell',0^)
>>%file_sql% echo:
>>%file_sql% echo select c.name                                                                                             AS 'Name',
>>%file_sql% echo        cast^(case when d.default_value = 2147483647 then 'UNLIMITED' else d.default_value end as char^(10^)^) AS 'Default value',
>>%file_sql% echo        cast^(c.value         as int^)                                                                       AS 'Initial value',
>>%file_sql% echo        cast^(c.value_in_use  as int^)                                                                       AS 'Actual value'
>>%file_sql% echo from sys.configurations c
>>%file_sql% echo inner join @config_defaults d ON c.name = d.name
>>%file_sql% echo where c.value != c.value_in_use
>>%file_sql% echo or    c.value_in_use != d.default_value;
>>%file_sql% echo:
if "%VER_SQL%"=="13.0" call :Audit_opt_confdb
if "%VER_SQL%"=="14.0" call :Audit_opt_confdb
>>%file_sql% echo:
>>%file_sql% echo PRINT ''
>>%file_sql% echo PRINT '+-------------+'
>>%file_sql% echo PRINT '^| Trace flags ^|'
>>%file_sql% echo PRINT '+-------------+'
>>%file_sql% echo PRINT ''
>>%file_sql% echo:
>>%file_sql% echo declare @TraceFlags table ^(traceflag smallint, status bit, global bit, session bit^)
>>%file_sql% echo insert into @TraceFlags execute^('DBCC TRACESTATUS^(-1^) WITH NO_INFOMSGS'^)
>>%file_sql% echo select traceflag                                      AS 'Trace Flag',
>>%file_sql% echo        case when status  = '1' then 'Yes' else '' end AS 'Active',
>>%file_sql% echo        case when global  = '1' then 'Yes' else '' end AS 'Global',
>>%file_sql% echo        case when session = '1' then 'Yes' else '' end AS 'Session'
>>%file_sql% echo from @TraceFlags;
>>%file_sql% echo:
goto:EOF
::#
::# End of Audit_opt
::#************************************************************#

:Audit_opt_confdb
::#************************************************************#
::# Audits configuration at level database from SQL Server 2016
::#
>>%file_sql% echo:
>>%file_sql% echo PRINT ''
>>%file_sql% echo PRINT '+------------------------+'
>>%file_sql% echo PRINT '^| Database configuration ^|'
>>%file_sql% echo PRINT '+------------------------+'
>>%file_sql% echo PRINT ''
>>%file_sql% echo:
>>%file_sql% echo if exists ^(select * from tempdb.sys.all_objects where name like '%%%TMPTAB%%%'^) drop table %TMPTAB%
>>%file_sql% echo go
>>%file_sql% echo create table %TMPTAB%^(db_name varchar^(128^),
>>%file_sql% echo                             name    nvarchar^(35^),
>>%file_sql% echo                             value   sql_variant^);
>>%file_sql% echo:
if     defined SQL_BDD >>%file_sql% echo exec sp_MSforeachdb @command1='if db_id^(''?''^) ^<= 4 or db_name^(db_id^(''?''^)^) ^<^>''%SQL_BDD%'' return; use [?]; insert %TMPTAB%
if not defined SQL_BDD >>%file_sql% echo exec sp_MSforeachdb @command1='if db_id^(''?''^) ^<= 4 return; use [?]; insert %TMPTAB%
if "%VER_SQL%"=="13.0" >>%file_sql% echo select ''?'', dsc.name, dsc.value from sys.database_scoped_configurations dsc
if "%VER_SQL%"=="13.0" >>%file_sql% echo where ^(dsc.name != ''PARAMETER_SNIFFING'' and dsc.value = 1^) or ^(dsc.name = ''PARAMETER_SNIFFING'' and dsc.value = 0^)';
if "%VER_SQL%"=="14.0" >>%file_sql% echo select ''?'', dsc.name, dsc.value from sys.database_scoped_configurations dsc where dsc.is_value_default=0';
>>%file_sql% echo:
>>%file_sql% echo select left^(o.db_name, %LEN_DBNAME%^) AS 'DB Name',
>>%file_sql% echo        left^(o.name, 35^)   AS 'Name',
>>%file_sql% echo        cast^(case when o.name = 'MAXDOP'
>>%file_sql% echo                   then o.value
>>%file_sql% echo                   else case when o.value = 0 then 'Off'
>>%file_sql% echo                             when o.value = 1 then 'On'
>>%file_sql% echo                        else o.value end
>>%file_sql% echo              end as char^(16^)^) AS 'Value'
>>%file_sql% echo from %TMPTAB% o
>>%file_sql% echo order by 1, 2;
>>%file_sql% echo if exists ^(select * from tempdb.sys.all_objects where name like '%%%TMPTAB%%%'^) drop table %TMPTAB%
>>%file_sql% echo go
goto:EOF
::#
::# End of Audit_opt_confdb
::#************************************************************#

:Audit_bak
::#************************************************************#
::# Audits backup report and DB restore
::#
>>%file_sql% echo PRINT ''
>>%file_sql% echo PRINT '+-------------+'
>>%file_sql% echo PRINT '^| Last backup ^|'
>>%file_sql% echo PRINT '+-------------+'
>>%file_sql% echo PRINT ''
>>%file_sql% echo:
>>%file_sql% echo ;with last_backup as ^(
>>%file_sql% echo select *, row_number^(^) over^(partition by database_name, type order by backup_finish_date desc^) as rnum
>>%file_sql% echo from msdb.dbo.backupset
>>%file_sql% echo ^)
>>%file_sql% echo select left^(d.name, %LEN_DBNAME%^)                                                                                        AS 'DB Name',
>>%file_sql% echo        left^(case when b.backup_finish_date  is NULL then ''
if "%VER_SQL%"=="11.0" >>%file_sql% echo                  else format^(b.backup_finish_date, '%FMT_DAT2%'^) end, 14^)                                 AS 'Last Backup',
if "%VER_SQL%"=="12.0" >>%file_sql% echo                  else format^(b.backup_finish_date, '%FMT_DAT2%'^) end, 14^)                                 AS 'Last Backup',
if "%VER_SQL%"=="13.0" >>%file_sql% echo                  else format^(b.backup_finish_date, '%FMT_DAT2%'^) end, 14^)                                 AS 'Last Backup',
if "%VER_SQL%"=="14.0" >>%file_sql% echo                  else format^(b.backup_finish_date, '%FMT_DAT2%'^) end, 14^)                                 AS 'Last Backup',
if not "%VER_SQL%"=="11.0" if not "%VER_SQL%"=="12.0" if not "%VER_SQL%"=="13.0" if not "%VER_SQL%"=="14.0" >>%file_sql% echo                  else convert^(varchar, b.backup_finish_date, %CNV_DATE%^)+' '+
if not "%VER_SQL%"=="11.0" if not "%VER_SQL%"=="12.0" if not "%VER_SQL%"=="13.0" if not "%VER_SQL%"=="14.0" >>%file_sql% echo                       convert^(varchar, b.backup_finish_date, %CNV_TIME%^) end, 14^)                                      AS 'Last Backup',
>>%file_sql% echo        isnull^(case b.type when 'D' then 'Full'
>>%file_sql% echo                           when 'I' then 'Differential'
>>%file_sql% echo                           when 'L' then 'Transaction Log' end, ''^)                                            AS 'Type',
>>%file_sql% echo 	     cast^(isnull^(datediff^(second, b.backup_start_date, b.backup_finish_date^),0^) as int^)                   AS 'Duration ^(s^)',
>>%file_sql% echo        left^(isnull^(cast^(datediff^(hour, b.backup_finish_date, getdate^(^) ^)/24 as varchar^(12^)^) + ' day^(s^) ', ''^) +
>>%file_sql% echo        case when b.backup_finish_date is null then ''
>>%file_sql% echo             else cast ^(case when datediff^(day, b.backup_finish_date, getdate^(^)^) = 0 then datediff^(hh, b.backup_finish_date, getdate^(^)^)
>>%file_sql% echo                              else datediff^(hh, b.backup_finish_date, getdate^(^)^)+24
>>%file_sql% echo                                  -datediff^(day, b.backup_finish_date, getdate^(^)^)*24 end as varchar^(12^)^) end + ' hours', 20^)   AS 'Aged',
>>%file_sql% echo        case when b.backup_size is null then ''
>>%file_sql% echo 	          else cast^(cast^(b.backup_size / 1024.0 / 1024.0 as decimal ^(8,1^)^) as varchar^(9^)^) end             AS 'Size ^(MB^)',
if not "%VER_SQL%"=="9.0" if not "%VER_SQL%"=="10.0" >>%file_sql% echo        case when b.compressed_backup_size is null then ''
if not "%VER_SQL%"=="9.0" if not "%VER_SQL%"=="10.0" >>%file_sql% echo 	           else cast^(cast^(b.compressed_backup_size / 1024.0 / 1024.0 as decimal ^(8,1^)^) as varchar^(9^)^) end AS 'Compressed Size ^(MB^)',
if not "%VER_SQL%"=="9.0" if not "%VER_SQL%"=="10.0" >>%file_sql% echo        convert^(numeric^(6,1^), ^(convert^(float, b.backup_size^)/convert^(float, b.compressed_backup_size^)^)^)        AS 'Compression Ratio',
>>%file_sql% echo 	   ^(select left^(case when b.type != 'D' or max^(b1.backup_finish_date^) is NULL then ''
if "%VER_SQL%"=="11.0" >>%file_sql% echo                    else format^(max^(b1.backup_finish_date^), '%FMT_DAT2%'^) end, 14^)
if "%VER_SQL%"=="11.0" >>%file_sql% echo        from msdb.dbo.backupset b1 where b1.database_name = d.name and b1.type = 'D'^)                          AS 'Last Full',
if "%VER_SQL%"=="12.0" >>%file_sql% echo                    else format^(max^(b1.backup_finish_date^), '%FMT_DAT2%'^) end, 14^)
if "%VER_SQL%"=="12.0" >>%file_sql% echo        from msdb.dbo.backupset b1 where b1.database_name = d.name and b1.type = 'D'^)                          AS 'Last Full',
if "%VER_SQL%"=="13.0" >>%file_sql% echo                    else format^(max^(b1.backup_finish_date^), '%FMT_DAT2%'^) end, 14^)
if "%VER_SQL%"=="13.0" >>%file_sql% echo        from msdb.dbo.backupset b1 where b1.database_name = d.name and b1.type = 'D'^)                          AS 'Last Full',
if "%VER_SQL%"=="14.0" >>%file_sql% echo                    else format^(max^(b1.backup_finish_date^), '%FMT_DAT2%'^) end, 14^)
if "%VER_SQL%"=="14.0" >>%file_sql% echo        from msdb.dbo.backupset b1 where b1.database_name = d.name and b1.type = 'D'^)                          AS 'Last Full',
if not "%VER_SQL%"=="11.0" if not "%VER_SQL%"=="12.0" if not "%VER_SQL%"=="13.0" if not "%VER_SQL%"=="14.0" >>%file_sql% echo                   else convert^(varchar, max^(b1.backup_finish_date^), %CNV_DATE%^)+' '+
if not "%VER_SQL%"=="11.0" if not "%VER_SQL%"=="12.0" if not "%VER_SQL%"=="13.0" if not "%VER_SQL%"=="14.0" >>%file_sql% echo                        convert^(varchar, max^(b1.backup_finish_date^), %CNV_TIME%^) end, 14^)
if not "%VER_SQL%"=="11.0" if not "%VER_SQL%"=="12.0" if not "%VER_SQL%"=="13.0" if not "%VER_SQL%"=="14.0" >>%file_sql% echo                        from msdb.dbo.backupset b1 where b1.database_name = d.name and b1.type = 'D'^) AS 'Last Full',
>>%file_sql% echo 	   ^(select left^(case when max^(b1.backup_finish_date^) IS NULL then ''
if "%VER_SQL%"=="11.0" >>%file_sql% echo                    else format^(max^(b1.backup_finish_date^), '%FMT_DAT2%'^) end, 14^)
if "%VER_SQL%"=="11.0" >>%file_sql% echo        from msdb.dbo.backupset b1 where b1.database_name = d.name and b1.type = 'I'^)                          AS 'Last Diff',
if "%VER_SQL%"=="12.0" >>%file_sql% echo                    else format^(max^(b1.backup_finish_date^), '%FMT_DAT2%'^) end, 14^)
if "%VER_SQL%"=="12.0" >>%file_sql% echo        from msdb.dbo.backupset b1 where b1.database_name = d.name and b1.type = 'I'^)                          AS 'Last Diff',
if "%VER_SQL%"=="13.0" >>%file_sql% echo                    else format^(max^(b1.backup_finish_date^), '%FMT_DAT2%'^) end, 14^)
if "%VER_SQL%"=="13.0" >>%file_sql% echo        from msdb.dbo.backupset b1 where b1.database_name = d.name and b1.type = 'I'^)                          AS 'Last Diff',
if "%VER_SQL%"=="14.0" >>%file_sql% echo                    else format^(max^(b1.backup_finish_date^), '%FMT_DAT2%'^) end, 14^)
if "%VER_SQL%"=="14.0" >>%file_sql% echo        from msdb.dbo.backupset b1 where b1.database_name = d.name and b1.type = 'I'^)                          AS 'Last Diff',
if not "%VER_SQL%"=="11.0" if not "%VER_SQL%"=="12.0" if not "%VER_SQL%"=="13.0" if not "%VER_SQL%"=="14.0" >>%file_sql% echo                   else convert^(varchar, max^(b1.backup_finish_date^), %CNV_DATE%^)+' '+
if not "%VER_SQL%"=="11.0" if not "%VER_SQL%"=="12.0" if not "%VER_SQL%"=="13.0" if not "%VER_SQL%"=="14.0" >>%file_sql% echo                        convert^(varchar, max^(b1.backup_finish_date^), %CNV_TIME%^) end, 14^)
if not "%VER_SQL%"=="11.0" if not "%VER_SQL%"=="12.0" if not "%VER_SQL%"=="13.0" if not "%VER_SQL%"=="14.0" >>%file_sql% echo                        from msdb.dbo.backupset b1 where b1.database_name = d.name and b1.type = 'I'^) AS 'Last Diff',
>>%file_sql% echo 	   ^(select left^(case when b.type != 'L' or max^(b1.backup_finish_date^) is NULL then ''
if "%VER_SQL%"=="11.0" >>%file_sql% echo                    else format^(max^(b1.backup_finish_date^), '%FMT_DAT2%'^) end, 14^)
if "%VER_SQL%"=="11.0" >>%file_sql% echo        from msdb.dbo.backupset b1 where b1.database_name = d.name and b1.type = 'L'^)                          AS 'Last Log',
if "%VER_SQL%"=="12.0" >>%file_sql% echo                    else format^(max^(b1.backup_finish_date^), '%FMT_DAT2%'^) end, 14^)
if "%VER_SQL%"=="12.0" >>%file_sql% echo        from msdb.dbo.backupset b1 where b1.database_name = d.name and b1.type = 'L'^)                          AS 'Last Log',
if "%VER_SQL%"=="13.0" >>%file_sql% echo                    else format^(max^(b1.backup_finish_date^), '%FMT_DAT2%'^) end, 14^)
if "%VER_SQL%"=="13.0" >>%file_sql% echo        from msdb.dbo.backupset b1 where b1.database_name = d.name and b1.type = 'L'^)                          AS 'Last Log',
if "%VER_SQL%"=="14.0" >>%file_sql% echo                    else format^(max^(b1.backup_finish_date^), '%FMT_DAT2%'^) end, 14^)
if "%VER_SQL%"=="14.0" >>%file_sql% echo        from msdb.dbo.backupset b1 where b1.database_name = d.name and b1.type = 'L'^)                          AS 'Last Log',
if not "%VER_SQL%"=="11.0" if not "%VER_SQL%"=="12.0" if not "%VER_SQL%"=="13.0" if not "%VER_SQL%"=="14.0" >>%file_sql% echo                   else convert^(varchar, max^(b1.backup_finish_date^), %CNV_DATE%^)+' '+
if not "%VER_SQL%"=="11.0" if not "%VER_SQL%"=="12.0" if not "%VER_SQL%"=="13.0" if not "%VER_SQL%"=="14.0" >>%file_sql% echo                        convert^(varchar, max^(b1.backup_finish_date^), %CNV_TIME%^) end, 14^)
if not "%VER_SQL%"=="11.0" if not "%VER_SQL%"=="12.0" if not "%VER_SQL%"=="13.0" if not "%VER_SQL%"=="14.0" >>%file_sql% echo                        from msdb.dbo.backupset b1 where b1.database_name = d.name and b1.type = 'L'^) AS 'Last Log',
>>%file_sql% echo        left^(m.physical_device_name, %LEN_BKPFILE%^)                                                                      AS 'Last Backup file',
>>%file_sql% echo        case when ^(datediff^(hour, b.backup_start_date,  getdate^(^) ^)  ^<24^) then 'Success'
>>%file_sql% echo             when ^(datediff^(hour, b.backup_start_date,  getdate^(^) ^) ^>=24^) then 'Failed'
>>%file_sql% echo             else '*** NEVER ***' end                                                                          AS 'Status'
>>%file_sql% echo from sys.sysdatabases d
>>%file_sql% echo left outer join last_backup b on b.database_name = d.name and rnum = 1
>>%file_sql% echo join msdb.dbo.backupmediafamily m on m.media_set_id = b.media_set_id
>>%file_sql% echo where d.dbid ^<^> 2
>>%file_sql% echo order by b.backup_finish_date desc;
>>%file_sql% echo:
if "%VER_SQL%"=="14.0" >>%file_sql% echo PRINT ''
if "%VER_SQL%"=="14.0" >>%file_sql% echo PRINT '+------------+'
if "%VER_SQL%"=="14.0" >>%file_sql% echo PRINT '^| LOG backup ^|'
if "%VER_SQL%"=="14.0" >>%file_sql% echo PRINT '+------------+'
if "%VER_SQL%"=="14.0" >>%file_sql% echo PRINT ''
if "%VER_SQL%"=="14.0" >>%file_sql% echo:
if "%VER_SQL%"=="14.0" >>%file_sql% echo if exists ^(select * from tempdb.sys.all_objects where name like '%%%TMPTAB%%%'^) drop table %TMPTAB%;
if "%VER_SQL%"=="14.0" >>%file_sql% echo go
if "%VER_SQL%"=="14.0" >>%file_sql% echo create table %TMPTAB%^(db_name          varchar^(128^),
if "%VER_SQL%"=="14.0" >>%file_sql% echo                             fseqno           int,
if "%VER_SQL%"=="14.0" >>%file_sql% echo                             total_vlf        int,
if "%VER_SQL%"=="14.0" >>%file_sql% echo                             active_vlf       int,
if "%VER_SQL%"=="14.0" >>%file_sql% echo                             total_size       dec^(7,1^),
if "%VER_SQL%"=="14.0" >>%file_sql% echo                             active_size      dec^(7,1^),
if "%VER_SQL%"=="14.0" >>%file_sql% echo                             reason           varchar^(25^),
if "%VER_SQL%"=="14.0" >>%file_sql% echo                             last_backup_time datetime,
if "%VER_SQL%"=="14.0" >>%file_sql% echo                             last_backup_size varchar^(17^)^);
if "%VER_SQL%"=="14.0" >>%file_sql% echo:
if "%VER_SQL%"=="14.0" if     defined SQL_BDD >>%file_sql% echo exec sp_MSforeachdb @command1='if db_id^(''?''^) ^<= 4 or db_name^(db_id^(''?''^)^) ^<^>''%SQL_BDD%'' return; use [?]; insert %TMPTAB%
if "%VER_SQL%"=="14.0" if not defined SQL_BDD >>%file_sql% echo exec sp_MSforeachdb @command1='if db_id^(''?''^) ^<= 4 return; use [?]; insert %TMPTAB%
if "%VER_SQL%"=="14.0" >>%file_sql% echo select ''?'',
if "%VER_SQL%"=="14.0" >>%file_sql% echo        l.current_vlf_sequence_number,
if "%VER_SQL%"=="14.0" >>%file_sql% echo        l.total_vlf_count,
if "%VER_SQL%"=="14.0" >>%file_sql% echo        l.active_vlf_count,
if "%VER_SQL%"=="14.0" >>%file_sql% echo        l.total_log_size_mb,
if "%VER_SQL%"=="14.0" >>%file_sql% echo        l.active_log_size_mb,
if "%VER_SQL%"=="14.0" >>%file_sql% echo        l.log_truncation_holdup_reason,
if "%VER_SQL%"=="14.0" >>%file_sql% echo        l.log_backup_time,
if "%VER_SQL%"=="14.0" >>%file_sql% echo        l.log_since_last_log_backup_mb
if "%VER_SQL%"=="14.0" >>%file_sql% echo from sys.dm_db_log_stats^(db_id^(^)^) l
if "%VER_SQL%"=="14.0" >>%file_sql% echo inner join sys.databases d on l.database_id = d.database_id;';
if "%VER_SQL%"=="14.0" >>%file_sql% echo:
if "%VER_SQL%"=="14.0" >>%file_sql% echo select left^(o.db_name, %LEN_DBNAME%^)                                                              AS 'DB Name',
if "%VER_SQL%"=="14.0" >>%file_sql% echo        cast^(o.fseqno as int^)                                                           AS 'Current FSeqNo',
if "%VER_SQL%"=="14.0" >>%file_sql% echo        cast^(o.total_vlf as int^)                                                        AS 'Total VLogs',
if "%VER_SQL%"=="14.0" >>%file_sql% echo        cast^(o.active_vlf as int^)                                                       AS 'Active VLogs',
if "%VER_SQL%"=="14.0" >>%file_sql% echo        cast^(o.total_size as dec^(7,1^)^)                                                  AS 'Total size ^(MB^)',
if "%VER_SQL%"=="14.0" >>%file_sql% echo        cast^(o.active_size as dec^(7,1^)^)                                                 AS 'Active size ^(MB^)',
if "%VER_SQL%"=="14.0" >>%file_sql% echo        left^(case when o.reason = 'NOTHING' then ' '								      
if "%VER_SQL%"=="14.0" >>%file_sql% echo 	             else replace^(o.reason,'_',' '^) end, 25^)                               AS 'Log truncation reason',
if "%VER_SQL%"=="14.0" >>%file_sql% echo        left^(case when o.last_backup_size is not null 
if "%VER_SQL%"=="14.0" >>%file_sql% echo 	             then format^(o.last_backup_time, '%FMT_DAT3%'^) else '' end, 17^) AS 'Last backup time',
if "%VER_SQL%"=="14.0" >>%file_sql% echo        right^(replicate^(' ',17-len^(isnull^(o.last_backup_size, 0^)^)^) +
if "%VER_SQL%"=="14.0" >>%file_sql% echo 	         case when o.last_backup_size is null then ''
if "%VER_SQL%"=="14.0" >>%file_sql% echo 			 else cast^(cast^(o.last_backup_size as dec^(4,1^)^) as varchar^) end, 17^)       AS 'Last backup size'
if "%VER_SQL%"=="14.0" >>%file_sql% echo from %TMPTAB% o;
if "%VER_SQL%"=="14.0" >>%file_sql% echo:
if "%VER_SQL%"=="14.0" >>%file_sql% echo if exists ^(select * from tempdb.sys.all_objects where name like '%%%TMPTAB%%%'^) drop table %TMPTAB%;
if "%VER_SQL%"=="14.0" >>%file_sql% echo:
>>%file_sql% echo PRINT ''
>>%file_sql% echo PRINT '+------------+'
>>%file_sql% echo PRINT '^| DB restore ^|'
>>%file_sql% echo PRINT '+------------+'
>>%file_sql% echo PRINT ''
>>%file_sql% echo:
>>%file_sql% echo select TOP %TOP_NSQL% 
>>%file_sql% echo        left^(rh.destination_database_name, %LEN_DBNAME%^)                AS 'DB Name',
>>%file_sql% echo        left^(case when bs.database_name ^<^>rh.destination_database_name
>>%file_sql% echo                   then bs.database_name else '' end, %LEN_DBNAME%^)     AS 'DB Name Source if ^<^>',
>>%file_sql% echo        case rh.restore_type when 'D' then 'Database'
>>%file_sql% echo                             when 'F' then 
>>%file_sql% echo             case when rf.destination_phys_name like '%%.ldf' then 'LOG File'
>>%file_sql% echo                  when rf.destination_phys_name like '%%.mdf' then 'DAT File'
>>%file_sql% echo                  when rf.destination_phys_name like '%%.ndf' then 'DAT File'
>>%file_sql% echo                                                             else 'File' end
>>%file_sql% echo                             when 'G' then 'Filegroup'
>>%file_sql% echo                             when 'I' then 'Differential'
>>%file_sql% echo                             when 'L' then 'Log'
>>%file_sql% echo                             when 'V' then 'Verify Only'
>>%file_sql% echo                             when 'R' then 'Revert' end      AS 'Restore Type', 
>>%file_sql% echo         case rh.recovery when 0 then 'NORECOVERY'
>>%file_sql% echo                          when 1 then 'RECOVERY' end         AS 'Recovery Type', 
if "%VER_SQL%"=="11.0" >>%file_sql% echo         left^(format^(rh.restore_date, '%FMT_DAT2%'^), 14^) AS 'Restore Date',
if "%VER_SQL%"=="12.0" >>%file_sql% echo         left^(format^(rh.restore_date, '%FMT_DAT2%'^), 14^) AS 'Restore Date',
if "%VER_SQL%"=="13.0" >>%file_sql% echo         left^(format^(rh.restore_date, '%FMT_DAT2%'^), 14^) AS 'Restore Date',
if "%VER_SQL%"=="14.0" >>%file_sql% echo         left^(format^(rh.restore_date, '%FMT_DAT2%'^), 14^) AS 'Restore Date',
if not "%VER_SQL%"=="11.0" if not "%VER_SQL%"=="12.0" if not "%VER_SQL%"=="13.0" if not "%VER_SQL%"=="14.0" >>%file_sql% echo 	      left^(convert^(varchar, rh.restore_date, %CNV_DATE%^)+' '+
if not "%VER_SQL%"=="11.0" if not "%VER_SQL%"=="12.0" if not "%VER_SQL%"=="13.0" if not "%VER_SQL%"=="14.0" >>%file_sql% echo 	           convert^(varchar, rh.restore_date, %CNV_TIME%^), 14^)    AS 'Restore Date',     
>>%file_sql% echo         left^(bf.physical_device_name, %LEN_BKPFILE%^)                   AS 'Source', 
>>%file_sql% echo         left^(rf.destination_phys_name, %LEN_DBFILE%^)                  AS 'Destination',
>>%file_sql% echo         left^(bs.server_name, 30^)                            AS 'Original server name', 
>>%file_sql% echo         left^(rh.user_name, 30^)                              AS 'Username' 
>>%file_sql% echo from msdb.dbo.restorehistory rh 
>>%file_sql% echo join msdb.dbo.backupset bs         on bs.backup_set_id      = rh.backup_set_id 
>>%file_sql% echo join msdb.dbo.backupmediafamily bf on bf.media_set_id       = bs.media_set_id
>>%file_sql% echo join msdb.dbo.restorefile rf       on rf.restore_history_id = rh.restore_history_id  
>>%file_sql% echo order by rh.destination_database_name, rh.restore_history_id desc;
>>%file_sql% echo:
goto:EOF
::#
::# End of Audit_bak
::#************************************************************#

:Audit_bak_new
::#************************************************************#
::# Audits database corruption available from SQL Server 2016
::#
>>%file_sql% echo PRINT ''
>>%file_sql% echo PRINT '+---------------------+'
>>%file_sql% echo PRINT '^| Database corruption ^|'
>>%file_sql% echo PRINT '+---------------------+'
>>%file_sql% echo PRINT ''
>>%file_sql% echo:
>>%file_sql% echo select left^(db_name^(sp.database_id^), %LEN_DBNAME%^)                             AS 'DB Name',
>>%file_sql% echo        left^(case when sp.event_type = 1 then 'IO Error'
>>%file_sql% echo                  when sp.event_type = 2 then 'Bad Checksum'
>>%file_sql% echo                  when sp.event_type = 3 then 'Torn page'
>>%file_sql% echo                  when sp.event_type = 4 then 'Restored'
>>%file_sql% echo                  when sp.event_type = 5 then 'Repaired'
>>%file_sql% echo                  when sp.event_type = 7 then 'Deallocated' end, 12^) AS 'Error type',
>>%file_sql% echo        cast^(sp.error_count as int^)                                  AS 'Count',
>>%file_sql% echo        left^(format^(sp.last_update_date, '%FMT_DAT3%'^),17^)    AS 'Last update'
>>%file_sql% echo from msdb.dbo.suspect_pages sp WITH ^(NOLOCK^)
>>%file_sql% echo order by sp.database_id
>>%file_sql% echo option ^(RECOMPILE^);
>>%file_sql% echo:
goto:EOF
::#
::# End of Audit_bak_new
::#************************************************************#

:Audit_job
::#************************************************************#
::# Audits maintenance plans, job history and operators
::#
>>%file_sql% echo PRINT ''
>>%file_sql% echo PRINT '+-------------------+'
>>%file_sql% echo PRINT '^| Maintenance plans ^|'
>>%file_sql% echo PRINT '+-------------------+'
>>%file_sql% echo PRINT ''
>>%file_sql% echo:
>>%file_sql% echo select left^(j.name, 50^)                                                                                  AS 'Name',
>>%file_sql% echo        left^(j.description, 60^)                                                                           AS 'Description',
>>%file_sql% echo        left^(replace^(c.name, '[Uncategorized (Local)]', ''), 30^)                                          AS 'Category',
if "%VER_SQL%"=="11.0" >>%file_sql% echo        left^(format^(j.date_created, '%FMT_DAT2%'^), 14^)                                                AS 'Create',
if "%VER_SQL%"=="11.0" >>%file_sql% echo        left^(case when format^(j.date_modified,'%FMT_DAT2%'^) = format^(j.date_created,'%FMT_DAT2%'^)
if "%VER_SQL%"=="11.0" >>%file_sql% echo 	             then '' else format^(j.date_modified,'%FMT_DAT2%'^) end, 14^)                          AS 'Update',
if "%VER_SQL%"=="12.0" >>%file_sql% echo        left^(format^(j.date_created, '%FMT_DAT2%'^), 14^)                                                AS 'Create',
if "%VER_SQL%"=="12.0" >>%file_sql% echo        left^(case when format^(j.date_modified,'%FMT_DAT2%'^) = format^(j.date_created,'%FMT_DAT2%'^)
if "%VER_SQL%"=="12.0" >>%file_sql% echo 	             then '' else format^(j.date_modified,'%FMT_DAT2%'^) end, 14^)                          AS 'Update',
if "%VER_SQL%"=="13.0" >>%file_sql% echo        left^(format^(j.date_created, '%FMT_DAT2%'^), 14^)                                                AS 'Create',
if "%VER_SQL%"=="13.0" >>%file_sql% echo        left^(case when format^(j.date_modified,'%FMT_DAT2%'^) = format^(j.date_created,'%FMT_DAT2%'^)
if "%VER_SQL%"=="13.0" >>%file_sql% echo 	             then '' else format^(j.date_modified,'%FMT_DAT2%'^) end, 14^)                          AS 'Update',
if "%VER_SQL%"=="14.0" >>%file_sql% echo        left^(format^(j.date_created, '%FMT_DAT2%'^), 14^)                                                AS 'Create',
if "%VER_SQL%"=="14.0" >>%file_sql% echo        left^(case when format^(j.date_modified,'%FMT_DAT2%'^) = format^(j.date_created,'%FMT_DAT2%'^)
if "%VER_SQL%"=="14.0" >>%file_sql% echo 	             then '' else format^(j.date_modified,'%FMT_DAT2%'^) end, 14^)                          AS 'Update',
if not "%VER_SQL%"=="11.0" if not "%VER_SQL%"=="12.0" if not "%VER_SQL%"=="13.0" if not "%VER_SQL%"=="14.0" >>%file_sql% echo        left^(convert^(varchar, j.date_created, %CNV_DATE%^)+' '+
if not "%VER_SQL%"=="11.0" if not "%VER_SQL%"=="12.0" if not "%VER_SQL%"=="13.0" if not "%VER_SQL%"=="14.0" >>%file_sql% echo              convert^(varchar, j.date_created, %CNV_TIME%^), 14^)                                                    AS 'Create',
if not "%VER_SQL%"=="11.0" if not "%VER_SQL%"=="12.0" if not "%VER_SQL%"=="13.0" if not "%VER_SQL%"=="14.0" >>%file_sql% echo        left^(case when convert^(varchar, j.date_modified, %CNV_DATE%^) = convert^(varchar, j.date_created, %CNV_DATE%^)
if not "%VER_SQL%"=="11.0" if not "%VER_SQL%"=="12.0" if not "%VER_SQL%"=="13.0" if not "%VER_SQL%"=="14.0" >>%file_sql% echo 	             then '' else convert^(varchar, j.date_modified, %CNV_DATE%^)+' '+
if not "%VER_SQL%"=="11.0" if not "%VER_SQL%"=="12.0" if not "%VER_SQL%"=="13.0" if not "%VER_SQL%"=="14.0" >>%file_sql% echo 	                          convert^(varchar, j.date_modified, %CNV_TIME%^) end, 14^)                              AS 'Update',
>>%file_sql% echo        case when j.enabled            = 1 then 'Yes' else '' end                                         AS 'Enabled',
>>%file_sql% echo        case when j.notify_level_email = 1 then 'Yes' else '' end                                         AS 'Email Notify',
>>%file_sql% echo        left^(case when o.name is NULL then '' else cast^(o.name as varchar^(25^)^) end, 20^)                   AS 'Email Operator',
>>%file_sql% echo        left^(isnull^(o.email_address,''^), 50^)                                                              AS 'Email Address'
>>%file_sql% echo from msdb.dbo.sysjobs_view j
>>%file_sql% echo inner join msdb.dbo.syscategories c WITH (NOLOCK) on j.category_id = c.category_id
>>%file_sql% echo left join msdb..sysoperators o      WITH (NOLOCK) on j.notify_email_operator_id = o.id
>>%file_sql% echo order by j.name;
>>%file_sql% echo:
>>%file_sql% echo PRINT ''
>>%file_sql% echo PRINT '+------+'
>>%file_sql% echo PRINT '^| Jobs ^|'
>>%file_sql% echo PRINT '+------+'
>>%file_sql% echo PRINT ''
>>%file_sql% echo:
>>%file_sql% echo ;with jobhist as ^(
>>%file_sql% echo select j.job_id,
>>%file_sql% echo        max^(j.run_date^)   as rundate,
>>%file_sql% echo        max^(j.run_time^)   as runtime,
>>%file_sql% echo        max^(j.run_status^) as status,
>>%file_sql% echo        sum^(case when j.run_status = 0 then 1 else 0 end^) as tot_failed
>>%file_sql% echo from msdb.dbo.sysjobhistory j
>>%file_sql% echo where j.step_id = 0
>>%file_sql% echo group by j.job_id, j.run_status
>>%file_sql% echo ^)
>>%file_sql% echo select left^(sj.name, 50^)                                                           AS 'Job Name',
>>%file_sql% echo        left^(case when sj.name ^<^> js.step_name then js.step_name else '' end, 60^)   AS 'Step Name',
>>%file_sql% echo        cast^(js.step_id as tinyint^)                                                 AS 'Step',
>>%file_sql% echo        left^(js.subsystem, 10^)                                                      AS 'Type',
>>%file_sql% echo        left^(case when sc.name like '%%Uncategorized%%' then '' else sc.name end, 25^) AS 'Category',
if "%VER_SQL%"=="11.0" >>%file_sql% echo        left^(format^(sj.date_created, '%FMT_DAT1%'^),8^)                                 AS 'Creation',
if "%VER_SQL%"=="12.0" >>%file_sql% echo        left^(format^(sj.date_created, '%FMT_DAT1%'^),8^)                                 AS 'Creation',
if "%VER_SQL%"=="13.0" >>%file_sql% echo        left^(format^(sj.date_created, '%FMT_DAT1%'^),8^)                                 AS 'Creation',
if "%VER_SQL%"=="14.0" >>%file_sql% echo        left^(format^(sj.date_created, '%FMT_DAT1%'^),8^)                                 AS 'Creation',
if not "%VER_SQL%"=="11.0" if not "%VER_SQL%"=="12.0" if not "%VER_SQL%"=="13.0" if not "%VER_SQL%"=="14.0" >>%file_sql% echo        left^(convert^(varchar, sj.date_created, %CNV_DATE%^),10^)                               AS 'Creation',
>>%file_sql% echo        case when sj.enabled = 1 then 'Yes' else '' end                             AS 'Enabled',
>>%file_sql% echo        left^(isnull^(convert^(char^(9^), cast^(str^(jh.rundate,8, 0^) as datetime^), 3^) +
>>%file_sql% echo        left^(stuff^(stuff^(right^('000000' +
>>%file_sql% echo        cast ^(jh.runtime as varchar^(6^)^), 6^), 5, 0,':'^), 3, 0,':'^), 14^),''), 14^)     AS 'Last Exec',
>>%file_sql% echo        left^(isnull^(case jh.status when 0 then 'failed'
>>%file_sql% echo                            when 1 then 'Succeeded'
>>%file_sql% echo                            when 2 then 'Retry'
>>%file_sql% echo                            when 3 then 'Canceled'
>>%file_sql% echo                            when 4 then 'In Progress' end, ''), 11^)                 AS 'Last Status',
>>%file_sql% echo        cast^(isnull^(jh.tot_failed, '') as char^(6^)^)                                  AS 'Failed',
>>%file_sql% echo        left^(char^(10^)+char^(10^)+js.command, 200^)+char^(10^)+replicate^('-', 96^)         AS 'Command'
>>%file_sql% echo from msdb.dbo.sysjobs sj
>>%file_sql% echo left join jobhist jh                 on jh.job_id      = sj.job_id
>>%file_sql% echo inner join sys.server_principals sp  on sj.owner_sid   = sp.sid
>>%file_sql% echo inner join msdb.dbo.syscategories sc on sj.category_id = sc.category_id
>>%file_sql% echo inner join msdb.dbo.sysjobsteps js   on js.job_id      = sj.job_id
>>%file_sql% echo left  join msdb.dbo.sysproxies spr   on js.proxy_id    = spr.proxy_id
>>%file_sql% echo order by 1;
>>%file_sql% echo:
>>%file_sql% echo PRINT ''
>>%file_sql% echo PRINT '+-----------------------+'
>>%file_sql% echo PRINT '^| Job history ^(summary^) ^|'
>>%file_sql% echo PRINT '+-----------------------+'
>>%file_sql% echo PRINT ''
>>%file_sql% echo select left^(j.name, 50^)                                                                                  AS 'Job Name',
>>%file_sql% echo        convert^(char^(9^), cast^(str^(h.run_date,8, 0^) AS DATETIME^), 3^) +
>>%file_sql% echo        left^(stuff^(stuff^(right^('000000' + cast ^(h.run_time AS VARCHAR^(6^)^), 6^), 5, 0,':'^), 3, 0,':'^), 17^)  AS 'Begin Datetime',
>>%file_sql% echo        convert^(char^(9^), dateadd^(SECOND, ^(^(h.run_duration/1000000^)*86400^)
>>%file_sql% echo 	            + ^(^(^(h.run_duration - ^(^(h.run_duration/1000000^)*1000000^)^)/10000^)*3600^)
>>%file_sql% echo               + ^(^(^(h.run_duration - ^(^(h.run_duration/10000^)*10000^)^)/100^)*60^)
>>%file_sql% echo 		        + ^(h.run_duration - ^(h.run_duration/100^)*100^),
>>%file_sql% echo    	          cast^(str^(h.run_date, 8, 0^) AS DATETIME^)
>>%file_sql% echo               + cast^(stuff^(stuff^(right^('000000'
>>%file_sql% echo 				+ cast ^(h.run_time AS VARCHAR^(6^)^), 6^), 5, 0, ':'^), 3, 0, ':'^) AS DATETIME^)^), %CNV_DATE%^) +
>>%file_sql% echo        convert^(char^(9^), dateadd^(SECOND, ^(^(h.run_duration/1000000^)*86400^)
>>%file_sql% echo 	            + ^(^(^(h.run_duration - ^(^(h.run_duration/1000000^)*1000000^)^)/10000^)*3600^)
>>%file_sql% echo               + ^(^(^(h.run_duration - ^(^(h.run_duration/10000^)*10000^)^)/100^)*60^)
>>%file_sql% echo 				+ ^(h.run_duration - ^(h.run_duration/100^)*100^),
>>%file_sql% echo                 cast^(str^(h.run_date, 8, 0^) AS DATETIME^)
>>%file_sql% echo               + cast^(stuff^(stuff^(right^('000000'
>>%file_sql% echo 				+ cast ^(h.run_time AS VARCHAR^(6^)^), 6^), 5, 0, ':'^), 3, 0, ':'^) AS DATETIME^)^), %CNV_TIME%^)          AS 'End Datetime',
>>%file_sql% echo        --left^(h.step_name, 50^)                                                                           AS 'Step Name',
>>%file_sql% echo        left^(stuff^(stuff^(replace^(str^(run_duration, 6, 0^), ' ', '0'^), 3, 0, ':'^), 6, 0, ':'^), 8^)           AS 'Time',
>>%file_sql% echo                  ^(^(h.run_duration/1000000^)* 86400^)
>>%file_sql% echo 				+ ^(^(^(h.run_duration - ^(^(h.run_duration/1000000^)*1000000^)^)/10000^)*3600 ^)
>>%file_sql% echo               + ^(^(^(h.run_duration - ^(^(h.run_duration/10000^)*10000^)^)/100^)*60^)
>>%file_sql% echo 				+ ^(h.run_duration - ^(h.run_duration/100^)*100^)                                            AS 'Duration ^(s^)',
>>%file_sql% echo        case h.run_status
>>%file_sql% echo            when 0 then 'failed'
>>%file_sql% echo            when 1 then 'Succeded'
>>%file_sql% echo            when 2 then 'Retry'
>>%file_sql% echo            when 3 then 'Cancelled'
>>%file_sql% echo            when 4 then 'In Progress' end                                                                 AS 'Status',
>>%file_sql% echo        left^(h.message, 300^)                                                                              AS 'Message'
>>%file_sql% echo from  msdb.dbo.sysjobhistory h
>>%file_sql% echo inner join msdb.dbo.sysjobs j on j.job_id = h.job_id
>>%file_sql% echo where h.step_id = 0
>>%file_sql% echo and   h.run_duration ^> 0
>>%file_sql% echo order by j.name, h.run_date desc, h.run_time desc;
>>%file_sql% echo:
>>%file_sql% echo PRINT ''
>>%file_sql% echo PRINT '+----------------------+'
>>%file_sql% echo PRINT '^| Job history ^(detail^) ^|'
>>%file_sql% echo PRINT '+----------------------+'
>>%file_sql% echo PRINT ''
>>%file_sql% echo select replicate^('-',96^)+char^(13^)+char^(10^)+left^(isnull^(p.name, j.name^), 50^)                              AS 'Plan Name',
>>%file_sql% echo        left^(case when h.step_name ^<^> isnull^(p.name, j.name^) then h.step_name else '' end, 50^)            AS 'Job Name',
>>%file_sql% echo        cast^(s.step_id as tinyint^)                                                                        AS 'Step',
>>%file_sql% echo        convert^(char^(9^), cast^(str^(h.run_date,8, 0^) AS DATETIME^), 3^) +
>>%file_sql% echo        left^(stuff^(stuff^(right^('000000' + cast ^(h.run_time AS VARCHAR^(6^)^), 6^), 5, 0,':'^), 3, 0,':'^), 17^)  AS 'Begin Datetime',
>>%file_sql% echo        convert^(char^(9^), dateadd^(SECOND, ^(^(h.run_duration/1000000^)*86400^)
>>%file_sql% echo 	            + ^(^(^(h.run_duration - ^(^(h.run_duration/1000000^)*1000000^)^)/10000^)*3600^)
>>%file_sql% echo               + ^(^(^(h.run_duration - ^(^(h.run_duration/10000^)*10000^)^)/100^)*60^)
>>%file_sql% echo 		        + ^(h.run_duration - ^(h.run_duration/100^)*100^),
>>%file_sql% echo    	          cast^(str^(h.run_date, 8, 0^) AS DATETIME^)
>>%file_sql% echo               + cast^(stuff^(stuff^(right^('000000'
>>%file_sql% echo 				+ cast ^(h.run_time AS VARCHAR^(6^)^), 6^), 5, 0, ':'^), 3, 0, ':'^) AS DATETIME^)^), %CNV_DATE%^) +
>>%file_sql% echo        convert^(char^(9^), dateadd^(SECOND, ^(^(h.run_duration/1000000^)*86400^)
>>%file_sql% echo 	            + ^(^(^(h.run_duration - ^(^(h.run_duration/1000000^)*1000000^)^)/10000^)*3600^)
>>%file_sql% echo               + ^(^(^(h.run_duration - ^(^(h.run_duration/10000^)*10000^)^)/100^)*60^)
>>%file_sql% echo 				+ ^(h.run_duration - ^(h.run_duration/100^)*100^),
>>%file_sql% echo                 cast^(str^(h.run_date, 8, 0^) AS DATETIME^)
>>%file_sql% echo               + cast^(stuff^(stuff^(right^('000000'
>>%file_sql% echo 				+ cast ^(h.run_time AS VARCHAR^(6^)^), 6^), 5, 0, ':'^), 3, 0, ':'^) AS DATETIME^)^), %CNV_TIME%^)          AS 'End Datetime',
>>%file_sql% echo        left^(stuff^(stuff^(replace^(str^(run_duration, 6, 0^), ' ', '0'^), 3, 0, ':'^), 6, 0, ':'^), 8^)           AS 'Time',
>>%file_sql% echo                  ^(^(h.run_duration/1000000^)* 86400^)
>>%file_sql% echo 				+ ^(^(^(h.run_duration - ^(^(h.run_duration/1000000^)*1000000^)^)/10000^)*3600 ^)
>>%file_sql% echo               + ^(^(^(h.run_duration - ^(^(h.run_duration/10000^)*10000^)^)/100^)*60^)
>>%file_sql% echo 				+ ^(h.run_duration - ^(h.run_duration/100^)*100^)                                            AS 'Duration ^(s^)',
>>%file_sql% echo        case h.run_status
>>%file_sql% echo            when 0 then 'Failed'
>>%file_sql% echo            when 1 then 'Succeeded'
>>%file_sql% echo            when 2 then 'Retry'
>>%file_sql% echo            when 3 then 'Canceled'
>>%file_sql% echo            when 4 then 'In Progress' end                                                                 AS 'Status',
>>%file_sql% echo        +char^(13^)+char^(10^)+char^(13^)+char^(10^)+replace^(h.message, '. ', '.'+char^(13^)+char^(10^)^) AS 'Message'
>>%file_sql% echo from  msdb.dbo.sysjobhistory h
>>%file_sql% echo join msdb.dbo.sysjobsteps s on s.job_id = h.job_id and s.step_id = h.step_id
>>%file_sql% echo join msdb.dbo.sysjobs j on j.job_id = h.job_id
>>%file_sql% echo left outer join msdb.dbo.sysmaintplan_subplans sp on sp.job_id = s.job_id
>>%file_sql% echo left outer join msdb.dbo.sysmaintplan_plans p on p.id     = sp.plan_id
>>%file_sql% echo where h.run_duration ^>= 0
>>%file_sql% echo and  convert^(datetime, convert^(char^(8^), h.run_date, 112^) + ' ' + stuff^(stuff^(right^('000000' +
>>%file_sql% echo      convert^(varchar^(8^), h.run_time^), 6^), 5, 0, ':'^), 3, 0, ':'^), 121^) ^> dateadd^(day, -8, getdate^(^)^)
>>%file_sql% echo order by h.run_date, h.run_time, s.step_id;
>>%file_sql% echo:
>>%file_sql% echo PRINT ''
>>%file_sql% echo PRINT '+---------------+'
>>%file_sql% echo PRINT '^| Job operators ^|'
>>%file_sql% echo PRINT '+---------------+'
>>%file_sql% echo PRINT ''
>>%file_sql% echo:
>>%file_sql% echo select left(name, 10)       AS 'Name',
>>%file_sql% echo        left(email_address, 30) AS 'Email Address',
>>%file_sql% echo        case when enabled = 1 then 'Yes' else '' end AS 'IsActive?'
>>%file_sql% echo from msdb..sysoperators;
goto:EOF
::#
::# End of Audit_job
::#************************************************************#

:Audit_mem
::#************************************************************#
::# Audits the SQL Server memory usage and Buffer cache infos
::#
>>%file_sql% echo PRINT ''
>>%file_sql% echo PRINT '+--------------+'
>>%file_sql% echo PRINT '^| Memory usage ^|'
>>%file_sql% echo PRINT '+--------------+'
>>%file_sql% echo PRINT ''
>>%file_sql% echo:
>>%file_sql% echo ;with Alloc_db as
>>%file_sql% echo ^(select TOP 100 left^(case database_id
>>%file_sql% echo             when 32767 then 'others'  -- resourceDb
>>%file_sql% echo             else DB_NAME^(database_id^) end, %LEN_DBNAME%^)  as db_name,
>>%file_sql% echo             cast^(count^(row_count^)*8/1024 as int^) as size_in_mb
>>%file_sql% echo       from sys.dm_os_buffer_descriptors
>>%file_sql% echo       group by database_id
>>%file_sql% echo       having count^(row_count^)*8/1024 ^> 0
>>%file_sql% echo       order by 2 desc^)
>>%file_sql% echo select left^(db_name, %LEN_DBNAME%^)        AS 'DB Name',
>>%file_sql% echo        cast^(size_in_mb as int^) AS '  Size ^(MB^)',
>>%file_sql% echo        cast^(100.0 * size_in_mb / sum^(size_in_mb^) OVER^(^) as decimal^(4,1^)^) AS 'Size ^(%%^)'
>>%file_sql% echo from Alloc_db
>>%file_sql% echo union all
>>%file_sql% echo select left^(' TOTAL', 10^),
>>%file_sql% echo        cast^(count^(row_count^)*8/1024 as int^), 100
>>%file_sql% echo from sys.dm_os_buffer_descriptors
>>%file_sql% echo union all
>>%file_sql% echo select left^('  Max SQL', 10^),
>>%file_sql% echo        cast^(value_in_use as int^), 100
>>%file_sql% echo from  sys.configurations
>>%file_sql% echo where  name = 'max server memory ^(MB^)'
>>%file_sql% echo union all
>>%file_sql% echo select left^('  Max SYS', 10^),
if "%VER_SQL%"=="11.0" >>%file_sql% echo        cast^(physical_memory_kb/1024 as int^), 100
if "%VER_SQL%"=="12.0" >>%file_sql% echo        cast^(physical_memory_kb/1024 as int^), 100
if "%VER_SQL%"=="13.0" >>%file_sql% echo        cast^(physical_memory_kb/1024 as int^), 100
if "%VER_SQL%"=="14.0" >>%file_sql% echo        cast^(physical_memory_kb/1024 as int^), 100
if not "%VER_SQL%"=="11.0" if not "%VER_SQL%"=="12.0" if not "%VER_SQL%"=="13.0" if not "%VER_SQL%"=="14.0" >>%file_sql% echo        cast^(physical_memory_in_bytes/1024/1024 as int^), 100
>>%file_sql% echo from sys.dm_os_sys_info
if not "%VER_SQL%"=="11.0" if not "%VER_SQL%"=="12.0" if not "%VER_SQL%"=="13.0" if not "%VER_SQL%"=="14.0" >>%file_sql% echo ; 
if "%VER_SQL%"=="11.0" >>%file_sql% echo union all
if "%VER_SQL%"=="11.0" >>%file_sql% echo select left^('  Free SYS', 10^),
if "%VER_SQL%"=="11.0" >>%file_sql% echo        cast^(available_physical_memory_kb/1024 as int^), 100
if "%VER_SQL%"=="11.0" >>%file_sql% echo from sys.dm_os_sys_memory;
if "%VER_SQL%"=="12.0" >>%file_sql% echo union all
if "%VER_SQL%"=="12.0" >>%file_sql% echo select left^('  Free SYS', 10^),
if "%VER_SQL%"=="12.0" >>%file_sql% echo        cast^(available_physical_memory_kb/1024 as int^), 100
if "%VER_SQL%"=="12.0" >>%file_sql% echo from sys.dm_os_sys_memory;
if "%VER_SQL%"=="13.0" >>%file_sql% echo union all
if "%VER_SQL%"=="13.0" >>%file_sql% echo select left^('  Free SYS', 10^),
if "%VER_SQL%"=="13.0" >>%file_sql% echo        cast^(available_physical_memory_kb/1024 as int^), 100
if "%VER_SQL%"=="13.0" >>%file_sql% echo from sys.dm_os_sys_memory;
if "%VER_SQL%"=="14.0" >>%file_sql% echo union all
if "%VER_SQL%"=="14.0" >>%file_sql% echo select left^('  Free SYS', 10^),
if "%VER_SQL%"=="14.0" >>%file_sql% echo        cast^(available_physical_memory_kb/1024 as int^), 100
if "%VER_SQL%"=="14.0" >>%file_sql% echo from sys.dm_os_sys_memory;
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
if not "%VER_SQL%"=="9.0"  >>%file_sql% echo PRINT ''
if not "%VER_SQL%"=="9.0"  >>%file_sql% echo PRINT '+-------------------+'
if not "%VER_SQL%"=="9.0"  >>%file_sql% echo PRINT '^| Max Server memory ^|'
if not "%VER_SQL%"=="9.0"  >>%file_sql% echo PRINT '+-------------------+'
if not "%VER_SQL%"=="9.0"  >>%file_sql% echo PRINT ''
if not "%VER_SQL%"=="9.0"  >>%file_sql% echo:
if     "%VER_SQL%"=="11.0" >>%file_sql% echo select cast^(cast^(max^(o.physical_memory_kb^)/1024/1024.0 as dec^(3,0^)^) as varchar^(3^)^)    AS 'Physical Mem ^(GB^)',
if     "%VER_SQL%"=="12.0" >>%file_sql% echo select cast^(cast^(max^(o.physical_memory_kb^)/1024/1024.0 as dec^(3,0^)^) as varchar^(3^)^)    AS 'Physical Mem ^(GB^)',
if     "%VER_SQL%"=="13.0" >>%file_sql% echo select cast^(cast^(max^(o.physical_memory_kb^)/1024/1024.0 as dec^(3,0^)^) as varchar^(3^)^)    AS 'Physical Mem ^(GB^)',
if     "%VER_SQL%"=="14.0" >>%file_sql% echo select cast^(cast^(max^(o.physical_memory_kb^)/1024/1024.0 as dec^(3,0^)^) as varchar^(3^)^)    AS 'Physical Mem ^(GB^)',
if not "%VER_SQL%"=="11.0" if not "%VER_SQL%"=="12.0" if not "%VER_SQL%"=="13.0" if not "%VER_SQL%"=="14.0" >>%file_sql% echo select cast^(cast^(max^(o.physical_memory_in_bytes^)/1024/1024/1024.0 as dec^(3,0^)^) as varchar^(3^)^)               AS 'Physical Mem ^(GB^)',
if not "%VER_SQL%"=="9.0"  >>%file_sql% echo        cast^(max^(o.max_workers_count^) as int^)                                                     AS '    Workers',
if not "%VER_SQL%"=="9.0"  >>%file_sql% echo        right^(cast^(max^(pm.page_fault_count^) as bigint^), 12^)                                       AS 'Pages fault',
if not "%VER_SQL%"=="9.0"  >>%file_sql% echo        cast^(count^(s.session_id^) as int^)                                                          AS '   Sessions',
if     "%VER_SQL%"=="11.0" >>%file_sql% echo        case when cast^(max^(o.physical_memory_kb^)/1024/1024.0 as dec^(5,0^)^) ^<= 16 then 2 else 4 end AS 'SYS Used Mem ^(GB^)',
if     "%VER_SQL%"=="12.0" >>%file_sql% echo        case when cast^(max^(o.physical_memory_kb^)/1024/1024.0 as dec^(5,0^)^) ^<= 16 then 2 else 4 end AS 'SYS Used Mem ^(GB^)',
if     "%VER_SQL%"=="13.0" >>%file_sql% echo        case when cast^(max^(o.physical_memory_kb^)/1024/1024.0 as dec^(5,0^)^) ^<= 16 then 2 else 4 end AS 'SYS Used Mem ^(GB^)',
if     "%VER_SQL%"=="14.0" >>%file_sql% echo        case when cast^(max^(o.physical_memory_kb^)/1024/1024.0 as dec^(5,0^)^) ^<= 16 then 2 else 4 end AS 'SYS Used Mem ^(GB^)',
if not "%VER_SQL%"=="9.0" if not "%VER_SQL%"=="11.0" if not "%VER_SQL%"=="12.0" if not "%VER_SQL%"=="13.0" if not "%VER_SQL%"=="14.0" >>%file_sql% echo        case when cast^(max^(o.physical_memory_in_bytes^)/1024/1024/1024.0 as dec^(5,0^)^) ^<= 16 then 2 else 4 end AS 'SYS Used Mem ^(GB^)',
if not "%VER_SQL%"=="9.0"  >>%file_sql% echo        cast^(sum^(s.memory_usage^)*8/1024.0 as dec^(4,1^)^)                                            AS 'SQL Used Mem ^(GB^)',
if not "%VER_SQL%"=="9.0"  >>%file_sql% echo        cast^(sum^(s.memory_usage^)*8/1024.0+count^(s.session_id^)*120/1024.0 as dec^(4,1^)^)             AS 'USR Used Mem ^(GB^)',
if not "%VER_SQL%"=="9.0"  >>%file_sql% echo        cast^(round^(max^(pm.locked_page_allocations_kb^)/1024.0/1024.0,1^) as dec^(4,1^)^)               AS 'Mem Locked (GB)',
if not "%VER_SQL%"=="9.0"  >>%file_sql% echo        2                                                                                         AS 'Mem Reserved ^(GB^)',
if not "%VER_SQL%"=="9.0"  >>%file_sql% echo        cast^(max^(c.value^) as int^)/1024                                                            AS 'Actual Max Server memory ^(GB^)',
if     "%VER_SQL%"=="11.0" >>%file_sql% echo        cast^(max^(o.physical_memory_kb^)/1024/1024 as dec^(5,0^)^)
if     "%VER_SQL%"=="12.0" >>%file_sql% echo        cast^(max^(o.physical_memory_kb^)/1024/1024 as dec^(5,0^)^)
if     "%VER_SQL%"=="13.0" >>%file_sql% echo        cast^(max^(o.physical_memory_kb^)/1024/1024 as dec^(5,0^)^)
if     "%VER_SQL%"=="14.0" >>%file_sql% echo        cast^(max^(o.physical_memory_kb^)/1024/1024 as dec^(5,0^)^)
if not "%VER_SQL%"=="9.0" if not "%VER_SQL%"=="11.0" if not "%VER_SQL%"=="12.0" if not "%VER_SQL%"=="13.0" if not "%VER_SQL%"=="14.0" >>%file_sql% echo        cast^(max^(o.physical_memory_in_bytes^)/1024/1024/1024.0 as dec^(5,0^)^)
if     "%VER_SQL%"=="11.0" >>%file_sql% echo        - case when cast^(max^(o.physical_memory_kb^)/1024/1024 as dec^(5,0^)^) ^<= 16 then 2 else 4 end
if     "%VER_SQL%"=="12.0" >>%file_sql% echo        - case when cast^(max^(o.physical_memory_kb^)/1024/1024 as dec^(5,0^)^) ^<= 16 then 2 else 4 end
if     "%VER_SQL%"=="13.0" >>%file_sql% echo        - case when cast^(max^(o.physical_memory_kb^)/1024/1024 as dec^(5,0^)^) ^<= 16 then 2 else 4 end
if     "%VER_SQL%"=="14.0" >>%file_sql% echo        - case when cast^(max^(o.physical_memory_kb^)/1024/1024 as dec^(5,0^)^) ^<= 16 then 2 else 4 end
if not "%VER_SQL%"=="9.0" if not "%VER_SQL%"=="11.0" if not "%VER_SQL%"=="12.0" if not "%VER_SQL%"=="13.0" if not "%VER_SQL%"=="14.0" >>%file_sql% echo        - case when cast^(max^(o.physical_memory_in_bytes^)/1024/1024/1024 as dec^(5,0^)^) ^<= 16 then 2 else 4 end
if not "%VER_SQL%"=="9.0"  >>%file_sql% echo        - cast^(2 * max^(o.max_workers_count^) as int^)/1024
if not "%VER_SQL%"=="9.0"  >>%file_sql% echo        - sum^(s.memory_usage^)*8/1024
if not "%VER_SQL%"=="9.0"  >>%file_sql% echo        - count^(s.session_id^)*120/1024
if not "%VER_SQL%"=="9.0"  >>%file_sql% echo        - 2                                                                                       AS 'Actual Max possible ^(GB^)'
if not "%VER_SQL%"=="9.0"  >>%file_sql% echo from sys.dm_exec_sessions s WITH ^(NOLOCK^)
if not "%VER_SQL%"=="9.0"  >>%file_sql% echo inner join sys.sysprocesses p WITH ^(NOLOCK^) on p.spid = s.session_id
if not "%VER_SQL%"=="9.0"  >>%file_sql% echo left outer join sys.sysdatabases d on ^(d.dbid = p.dbid^)
if not "%VER_SQL%"=="9.0"  >>%file_sql% echo cross join sys.dm_os_sys_info o
if not "%VER_SQL%"=="9.0"  >>%file_sql% echo cross join sys.configurations c
if not "%VER_SQL%"=="9.0"  >>%file_sql% echo cross join sys.dm_os_process_memory pm
if not "%VER_SQL%"=="9.0"  >>%file_sql% echo where s.is_user_process = 1
if not "%VER_SQL%"=="9.0"  >>%file_sql% echo and c.name = 'max server memory ^(MB^)';
if not "%VER_SQL%"=="9.0"  >>%file_sql% echo:
>>%file_sql% echo:
>>%file_sql% echo PRINT ''
>>%file_sql% echo PRINT '+--------------+'
>>%file_sql% echo PRINT '^| Buffer usage ^|'
>>%file_sql% echo PRINT '+--------------+'
>>%file_sql% echo PRINT ''
>>%file_sql% echo:
>>%file_sql% echo ;with usage as ^(
>>%file_sql% echo select db_name^(b.database_id^)    as dbname,
>>%file_sql% echo        count^(b.page_id^)*8/1024.0/1024 as cachedsize_used,
>>%file_sql% echo        sum^(b.free_space_in_bytes/1024.0^)/1024/1024 as cachedsize_free
>>%file_sql% echo from sys.dm_os_buffer_descriptors b WITH ^(NOLOCK^)
>>%file_sql% echo where b.database_id ^<^> 32767 -- resourcedb
>>%file_sql% echo group by db_name^(b.database_id^)
>>%file_sql% echo ^)
>>%file_sql% echo select cast^(row_number^(^) over^(order by u.cachedsize_used desc^) as tinyint^)         AS 'Rank',
>>%file_sql% echo        left^(u.dbname, %LEN_DBNAME%^)                                                           AS 'DB Name',
>>%file_sql% echo        cast^(u.cachedsize_free as dec^(5,1^)^)                                         AS 'Cache size free ^(GB^)',
>>%file_sql% echo        cast^(u.cachedsize_used as dec^(5,1^)^)                                         AS 'Cache size used ^(GB^)',
>>%file_sql% echo        cast^(u.cachedsize_used / sum^(u.cachedsize_used^) over^(^) * 100.0 as dec^(4,1^)^) AS 'Cache size used ^(%%^)'
>>%file_sql% echo from usage u
>>%file_sql% echo order by 1 option ^(RECOMPILE^);
>>%file_sql% echo:
>>%file_sql% echo PRINT ''
>>%file_sql% echo PRINT '+------------------------+'
>>%file_sql% echo PRINT '^| Buffer cache hit ratio ^|'
>>%file_sql% echo PRINT '+------------------------+'
>>%file_sql% echo PRINT ''
>>%file_sql% echo:
>>%file_sql% echo select cast((select cast (cntr_value as bigint)
>>%file_sql% echo              from sys.dm_os_performance_counters
>>%file_sql% echo              where counter_name = 'Buffer cache hit ratio'
>>%file_sql% echo             )* 100.00
>>%file_sql% echo        /
>>%file_sql% echo             (
>>%file_sql% echo              select cast (cntr_value as bigint)
>>%file_sql% echo              from sys.dm_os_performance_counters
>>%file_sql% echo              where counter_name = 'Buffer cache hit ratio base'
>>%file_sql% echo             ) as numeric(5,2)) AS '  Ratio';
>>%file_sql% echo:
goto:EOF
::#
::# End of Audit_mem
::#************************************************************#

:Audit_file
::#************************************************************#
::# Audits DB files info & activity
::#
>>%file_sql% echo PRINT ''
>>%file_sql% echo PRINT '+---------------+'
>>%file_sql% echo PRINT '^| DB files info ^|'
>>%file_sql% echo PRINT '+---------------+'
>>%file_sql% echo:
>>%file_sql% echo if exists ^(select * from tempdb.sys.all_objects where name like '%%%TMPTAB%%%'^) drop table %TMPTAB%
>>%file_sql% echo go
>>%file_sql% echo create table %TMPTAB%^(dbid           int,
>>%file_sql% echo                             db_name        varchar^(128^),
>>%file_sql% echo                             fg_name        varchar^(128^),
>>%file_sql% echo                             name           varchar^(128^),
>>%file_sql% echo                             type_desc      varchar^(4^),
>>%file_sql% echo                             filename       varchar^(128^),
>>%file_sql% echo                             create_date    datetime,
>>%file_sql% echo                             size_mb        int,
>>%file_sql% echo                             free_mb        int,
>>%file_sql% echo                             sizegrowth     varchar^(10^),
if "%VER_SQL%"=="13.0" >>%file_sql% echo                             autofilegrowth int,
if "%VER_SQL%"=="14.0" >>%file_sql% echo                             autofilegrowth int,
>>%file_sql% echo                             max_mb         varchar^(10^),
>>%file_sql% echo                             newgrowth      int^);
>>%file_sql% echo:
>>%file_sql% echo exec sp_MSforeachdb @command1='use [?]; insert %TMPTAB%
>>%file_sql% echo select database_id,
>>%file_sql% echo        ''?'',
>>%file_sql% echo        isnull^(fg.name,''''^),
>>%file_sql% echo        f.name,
>>%file_sql% echo        f.type_desc,
>>%file_sql% echo        f.physical_name,
>>%file_sql% echo        d.create_date,
>>%file_sql% echo        cast^(f.size*CONVERT^(float,8^)/1024.0 AS int^) AS ''size_mb'',
>>%file_sql% echo        cast^(^(size-FILEPROPERTY^(f.name,''SpaceUsed''^)^)*8.0/1024.0 as int^) AS ''free_mb'',
>>%file_sql% echo 	   case when f.is_percent_growth = 1
>>%file_sql% echo 	        then cast^(f.growth as varchar^)+''%%''
>>%file_sql% echo 	        else cast^(cast^(f.growth*8/1024.0 as int^) as varchar^)+''Mb'' end AS ''sizegrowth'',
if "%VER_SQL%"=="13.0" >>%file_sql% echo 	   fg.is_autogrow_all_files AS autofilegrowth,
if "%VER_SQL%"=="14.0" >>%file_sql% echo 	   fg.is_autogrow_all_files AS autofilegrowth,
>>%file_sql% echo 	   case when f.max_size = -1        then ''UNLIMITED''
>>%file_sql% echo 	        when f.max_size ^>= 10485760 then ''UNLIMITED''
>>%file_sql% echo 			else cast^(f.max_size as VARCHAR^(10^)^) end AS ''max_mb'',
>>%file_sql% echo 	   case when f.size*8/1024 ^< 10    then 1
>>%file_sql% echo 	        when f.size*8/1024 ^< 100   then round^(f.size*8/1024, -1^)/10
>>%file_sql% echo 	        when f.size*8/1024 ^< 1000  then round^(f.size*8/1024, -2^)/10
>>%file_sql% echo 	        when f.size*8/1024 ^< 10000 then round^(f.size*8/1024, -3^)/10
>>%file_sql% echo 			else round^(f.size*8/1024, -4^)/100 end AS ''newgrowth''
>>%file_sql% echo from sys.database_files f
>>%file_sql% echo left join sys.filegroups fg on fg.data_space_id = f.data_space_id
>>%file_sql% echo join sys.databases d on d.database_id = db_id^(^)';
>>%file_sql% echo:
>>%file_sql% echo PRINT ''
>>%file_sql% echo select left^(o.db_name, %LEN_DBNAME%^)                                            AS 'DB Name',
>>%file_sql% echo        left^(o.fg_name, %LEN_FGNAME%^)                                           AS 'Filegroup',
>>%file_sql% echo        left^(o.name, %LEN_FNAME%^)                                              AS 'Logical name',
>>%file_sql% echo        case when o.db_name in ^('master', 'msdb', 'model'^) then 'SYS'
>>%file_sql% echo             when o.db_name = 'tempdb'  then 'TMP'
>>%file_sql% echo             when o.type_desc = 'ROWS' then 'DAT'
>>%file_sql% echo             when o.type_desc = 'LOG'  then 'LOG' end                 AS 'Type',
>>%file_sql% echo        left^(o.filename, %LEN_DBFILE%^)                                          AS 'File Name',
if "%VER_SQL%"=="11.0" >>%file_sql% echo        left^(format^(o.create_date, '%FMT_DAT1%'^),8^)                     AS 'Creation',
if "%VER_SQL%"=="12.0" >>%file_sql% echo        left^(format^(o.create_date, '%FMT_DAT1%'^),8^)                     AS 'Creation',
if "%VER_SQL%"=="13.0" >>%file_sql% echo        left^(format^(o.create_date, '%FMT_DAT1%'^),8^)                     AS 'Creation',
if "%VER_SQL%"=="14.0" >>%file_sql% echo        left^(format^(o.create_date, '%FMT_DAT1%'^),8^)                     AS 'Creation',
if not "%VER_SQL%"=="11.0" if not "%VER_SQL%"=="12.0" if not "%VER_SQL%"=="13.0" if not "%VER_SQL%"=="14.0" >>%file_sql% echo        left^(convert^(varchar, o.create_date, %CNV_DATE%^),10^)                   AS 'Creation',
>>%file_sql% echo        o.size_mb                                                     AS '  Size ^(MB^)',
>>%file_sql% echo        o.size_mb - o.free_mb                                         AS '  Used ^(MB^)',
>>%file_sql% echo        o.free_mb                                                     AS '  Free ^(MB^)',
>>%file_sql% echo        cast^(case when o.size_mb ^> 0 then o.free_mb*100.0/o.size_mb
>>%file_sql% echo                                     else 0 end as decimal^(4,1^)^)      AS 'Free ^(%%^)',
>>%file_sql% echo        case when o.sizegrowth = '0' then '' else o.sizegrowth end    AS 'Size Growth',
if "%VER_SQL%"=="13.0" >>%file_sql% echo        case when o.autofilegrowth = '0' then '' else 'Yes' end       AS 'Auto Growth All Files',
if "%VER_SQL%"=="14.0" >>%file_sql% echo        case when o.autofilegrowth = '0' then '' else 'Yes' end       AS 'Auto Growth All Files',
>>%file_sql% echo        o.max_mb                                                      AS 'Max Size ^(MB^)'
>>%file_sql% echo from %TMPTAB% o
>>%file_sql% echo order by 4, 3;
>>%file_sql% echo:
>>%file_sql% echo PRINT ''
>>%file_sql% echo select left^('ALTER DATABASE ' + left^(cast^(f.db_name as varchar^)+replicate^(' ',%LEN_DBNAME%-len^(f.db_name^)^),%LEN_DBNAME%^) +
>>%file_sql% echo             ' MODIFY FILE ^(NAME = ''' + left^(f.name+''''+
>>%file_sql% echo               isnull^(replicate^(' ',%LEN_FNAME%+1-len^(f.name^)^),' '^),%LEN_FNAME%+1^) + ',' +
>>%file_sql% echo             ' FILEGROWTH = '+ left^(cast^(case when f.dbid ^<^> 2 then f.newgrowth else 128 end as varchar^)+'MB,'+
>>%file_sql% echo               isnull^(replicate^(' ',8-len^(cast^(case when f.dbid ^<^> 2 then f.newgrowth else 128 end as varchar^)+'MB,'^)^),' '^),8^) +
>>%file_sql% echo             ' MAXSIZE = '+ left^(f.max_mb+case when f.max_mb = 'UNLIMITED' then '^);' else 'MB^);' end +  
>>%file_sql% echo               isnull^(replicate^(' ',11-len^(f.max_mb+case when f.max_mb = 'UNLIMITED^);' then '' else 'MB^);' end^)^),' '^),11^) +
>>%file_sql% echo             ' -- SIZE = '+ left^(cast^(f.size_mb-f.free_mb as varchar^)+'MB'+
>>%file_sql% echo               isnull^(replicate^(' ',10-len^(cast^(f.size_mb-f.free_mb as varchar^)+'MB,'^)^),' '^),10^) +
>>%file_sql% echo             ' FILENAME=''' + f.filename, 234^) AS 'SQL statements for MODIFY file operation'
>>%file_sql% echo from %TMPTAB% f
>>%file_sql% echo order by case when f.db_name in ('master', 'msdb', 'model') then 'SYS'
>>%file_sql% echo               when f.db_name = 'tempdb'  then 'TMP'
>>%file_sql% echo               when f.type_desc = 'ROWS' then 'DAT'
>>%file_sql% echo               when f.type_desc = 'LOG'  then 'LOG' end, 1;
>>%file_sql% echo >>%file_sql% echo:
>>%file_sql% echo PRINT ''
>>%file_sql% echo select left^(' USE ['+d.name+']'+char^(10^)+
>>%file_sql% echo             case when d.recovery_model = 1
>>%file_sql% echo             then ' ALTER DATABASE '+ d.name + ' SET RECOVERY SIMPLE;'+char^(10^)+' GO'+char^(10^)+
>>%file_sql% echo                  ' DBCC SHRINKFILE^('''+f.name+''', '+cast^(^(f.size_mb-f.free_mb^) as varchar^)+'^);'+char^(10^)+' GO'+char^(10^)+
>>%file_sql% echo                  ' ALTER DATABASE '+ d.name + ' SET RECOVERY FULL;'+char^(10^)+' GO'
>>%file_sql% echo             else ' DBCC SHRINKFILE^('''+f.name+''', '+cast^(^(f.size_mb-f.free_mb^) as varchar^)+'^);' end, %LEN_SQLT%^)+char^(10^) AS 'SQL statements for SHRINK file operation'
>>%file_sql% echo from %TMPTAB% f
>>%file_sql% echo join sys.databases d on d.database_id = f.dbid
>>%file_sql% echo where f.type_desc = 'LOG'
>>%file_sql% echo and f.dbid ^> 4
>>%file_sql% echo order by 1;
>>%file_sql% echo:
>>%file_sql% echo if exists ^(select * from tempdb.sys.all_objects where name like '%%%TMPTAB%%%'^) drop table %TMPTAB%
>>%file_sql% echo go
>>%file_sql% echo:
>>%file_sql% echo PRINT ''
>>%file_sql% echo PRINT '+-------------------+'
>>%file_sql% echo PRINT '^| DB files activity ^|'
>>%file_sql% echo PRINT '+-------------------+'
>>%file_sql% echo PRINT ''
>>%file_sql% echo:
>>%file_sql% echo ;with files AS ^(
>>%file_sql% echo select left^(DB_NAME^(mf.database_id^), %LEN_DBNAME%^)                                            AS 'DB Name',
>>%file_sql% echo        left^(mf.name, %LEN_FNAME%^)                                                           AS 'Logical name',
>>%file_sql% echo        case when mf.database_id in ^(1,3,4^) then 'SYS'
>>%file_sql% echo             when mf.database_id = 2 then 'TMP'
>>%file_sql% echo             when mf.type_desc = 'ROWS' then 'DAT'
>>%file_sql% echo             when mf.type_desc = 'LOG'  then 'LOG' end                              AS 'Type',
>>%file_sql% echo        left^(mf.physical_name, %LEN_DBFILE%^)                                                  AS 'File Name',
>>%file_sql% echo        cast^(^(^(fs.size_on_disk_bytes/1024^)/1024^)/1024.0 as decimal^(5,1^)^)            AS 'File Size ^(GB^)',
>>%file_sql% echo        cast^(^(fs.num_of_bytes_read/1024^)/1024.0                             as int^) AS '  Read ^(MB^)',
>>%file_sql% echo        cast^(^(fs.num_of_bytes_written /1024^)/1024.0                         as int^) AS 'Written ^(MB^)',
>>%file_sql% echo        cast^(fs.Num_of_reads                                                as int^) AS '      Reads',
>>%file_sql% echo        cast^(fs.Num_of_writes                                               as int^) AS '     Writes',
>>%file_sql% echo        cast^(fs.Num_of_reads + fs.Num_of_writes                             as int^) AS '   Total IO',
>>%file_sql% echo        cast^(100. * ^(fs.Num_of_reads + fs.Num_of_writes^) /
>>%file_sql% echo 	        sum^(fs.Num_of_reads + fs.Num_of_writes^) OVER^(^) as decimal^(5,1^)^)        AS 'IO load ^(%%^)',
>>%file_sql% echo        cast^(case when fs.num_of_reads = 0								
>>%file_sql% echo             then 0 else fs.io_stall_read_ms/fs.num_of_reads end            as int^) AS 'Read Latency ^(ms^)',
>>%file_sql% echo        cast^(case when fs.num_of_writes = 0										
>>%file_sql% echo             then 0 else fs.io_stall_write_ms/fs.num_of_writes end          as int^) AS 'Write Latency ^(ms^)',
>>%file_sql% echo        cast^(case when fs.num_of_reads = 0 and fs.num_of_writes = 0
>>%file_sql% echo             then 0 else fs.io_stall/^(fs.num_of_reads+fs.num_of_writes^) end as int^) AS 'IO Latency ^(ms^)',
>>%file_sql% echo        cast^(100.0 * ^(fs.io_stall/(fs.num_of_reads+fs.num_of_writes^)^) / replace^(sum^(fs.io_stall/(fs.num_of_reads+fs.num_of_writes^)^) OVER^(^),0,1^) as decimal^(4,1^)^) AS 'IO Latency (%%)'
>>%file_sql% echo from sys.dm_io_virtual_file_stats^(null,null^) fs
>>%file_sql% echo join sys.master_files AS mf
>>%file_sql% echo on   fs.database_id = mf.database_id
>>%file_sql% echo and  fs.file_id     = mf.file_id
>>%file_sql% echo and  fs.num_of_reads + fs.num_of_writes ^> 0.0
>>%file_sql% echo ^)
>>%file_sql% echo select * from files
>>%file_sql% echo order by 3, 1;
>>%file_sql% echo:
goto:EOF
::#
::# End of Audit_file
::#************************************************************#

:Audit_log
::#************************************************************#
::# Audits LOG usage, growth & activity and Virtual Logs summary & detail
if not "%VER_SQL%"=="9.0" if not "%VER_SQL%"=="10.0" if not "%VER_SQL%"=="10.5" >>%file_sql% echo PRINT ''
if not "%VER_SQL%"=="9.0" if not "%VER_SQL%"=="10.0" if not "%VER_SQL%"=="10.5" >>%file_sql% echo PRINT '+-----------+'
if not "%VER_SQL%"=="9.0" if not "%VER_SQL%"=="10.0" if not "%VER_SQL%"=="10.5" >>%file_sql% echo PRINT '^| LOG usage ^|'
if not "%VER_SQL%"=="9.0" if not "%VER_SQL%"=="10.0" if not "%VER_SQL%"=="10.5" >>%file_sql% echo PRINT '+-----------+'
if not "%VER_SQL%"=="9.0" if not "%VER_SQL%"=="10.0" if not "%VER_SQL%"=="10.5" >>%file_sql% echo PRINT ''
if not "%VER_SQL%"=="9.0" if not "%VER_SQL%"=="10.0" if not "%VER_SQL%"=="10.5" >>%file_sql% echo:
if not "%VER_SQL%"=="9.0" if not "%VER_SQL%"=="10.0" if not "%VER_SQL%"=="10.5" >>%file_sql% echo if exists ^(select * from tempdb.sys.all_objects where name like '%%%TMPTAB%%%'^) drop table %TMPTAB%
if not "%VER_SQL%"=="9.0" if not "%VER_SQL%"=="10.0" if not "%VER_SQL%"=="10.5" >>%file_sql% echo go
if not "%VER_SQL%"=="9.0" if not "%VER_SQL%"=="10.0" if not "%VER_SQL%"=="10.5" >>%file_sql% echo create table %TMPTAB%^(db_name        varchar^(128^),
if not "%VER_SQL%"=="9.0" if not "%VER_SQL%"=="10.0" if not "%VER_SQL%"=="10.5" >>%file_sql% echo                             total_log_size decimal^(8,1^),
if not "%VER_SQL%"=="9.0" if not "%VER_SQL%"=="10.0" if not "%VER_SQL%"=="10.5" >>%file_sql% echo                             used_log_size  decimal^(8,1^),
if not "%VER_SQL%"=="9.0" if not "%VER_SQL%"=="10.0" if not "%VER_SQL%"=="10.5" >>%file_sql% echo                             used_log_pct   decimal^(4,1^),
if not "%VER_SQL%"=="9.0" if not "%VER_SQL%"=="10.0" if not "%VER_SQL%"=="10.5" >>%file_sql% echo                             free_log_size  decimal^(8,1^)
if not "%VER_SQL%"=="9.0" if not "%VER_SQL%"=="10.0" if not "%VER_SQL%"=="10.5" if not "%VER_SQL%"=="11.0" >>%file_sql% echo                            ,last_log_size  decimal^(8,1^)
if not "%VER_SQL%"=="9.0" if not "%VER_SQL%"=="10.0" if not "%VER_SQL%"=="10.5" >>%file_sql% echo                     ^);
if not "%VER_SQL%"=="9.0" if not "%VER_SQL%"=="10.0" if not "%VER_SQL%"=="10.5" >>%file_sql% echo:
if not "%VER_SQL%"=="9.0" if not "%VER_SQL%"=="10.0" if not "%VER_SQL%"=="10.5" >>%file_sql% echo exec sp_MSforeachdb @command1='use [?]; insert %TMPTAB%
if not "%VER_SQL%"=="9.0" if not "%VER_SQL%"=="10.0" if not "%VER_SQL%"=="10.5" >>%file_sql% echo select ''?'',
if not "%VER_SQL%"=="9.0" if not "%VER_SQL%"=="10.0" if not "%VER_SQL%"=="10.5" >>%file_sql% echo        u.total_log_size_in_bytes/1024.0/1024,
if not "%VER_SQL%"=="9.0" if not "%VER_SQL%"=="10.0" if not "%VER_SQL%"=="10.5" >>%file_sql% echo        u.used_log_space_in_bytes/1024.0/1024,
if not "%VER_SQL%"=="9.0" if not "%VER_SQL%"=="10.0" if not "%VER_SQL%"=="10.5" >>%file_sql% echo        u.used_log_space_in_percent,
if not "%VER_SQL%"=="9.0" if not "%VER_SQL%"=="10.0" if not "%VER_SQL%"=="10.5" >>%file_sql% echo        u.total_log_size_in_bytes/1024.0/1024 -
if not "%VER_SQL%"=="9.0" if not "%VER_SQL%"=="10.0" if not "%VER_SQL%"=="10.5" >>%file_sql% echo        u.used_log_space_in_bytes/1024.0/1024
if not "%VER_SQL%"=="9.0" if not "%VER_SQL%"=="10.0" if not "%VER_SQL%"=="10.5" if not "%VER_SQL%"=="11.0" >>%file_sql% echo       ,u.log_space_in_bytes_since_last_backup/1024.0/1024/1024
if not "%VER_SQL%"=="9.0" if not "%VER_SQL%"=="10.0" if not "%VER_SQL%"=="10.5" >>%file_sql% echo from sys.dm_db_log_space_usage u;';
if not "%VER_SQL%"=="9.0" if not "%VER_SQL%"=="10.0" if not "%VER_SQL%"=="10.5" >>%file_sql% echo:
if not "%VER_SQL%"=="9.0" if not "%VER_SQL%"=="10.0" if not "%VER_SQL%"=="10.5" >>%file_sql% echo select left^(o.db_name, %LEN_DBNAME%^)                 AS 'DB Name',
if not "%VER_SQL%"=="9.0" if not "%VER_SQL%"=="10.0" if not "%VER_SQL%"=="10.5" >>%file_sql% echo        cast^(o.total_log_size as dec^(7,1^)^) AS 'Log size ^(GB^)',
if not "%VER_SQL%"=="9.0" if not "%VER_SQL%"=="10.0" if not "%VER_SQL%"=="10.5" >>%file_sql% echo        cast^(o.used_log_size  as dec^(7,1^)^) AS 'Total used ^(MB^)',
if not "%VER_SQL%"=="9.0" if not "%VER_SQL%"=="10.0" if not "%VER_SQL%"=="10.5" >>%file_sql% echo        cast^(o.used_log_pct   as dec^(4,1^)^) AS 'Space used ^(%%^)',
if not "%VER_SQL%"=="9.0" if not "%VER_SQL%"=="10.0" if not "%VER_SQL%"=="10.5" >>%file_sql% echo        cast^(o.free_log_size  as dec^(7,1^)^) AS 'Free used ^(MB^)'
if not "%VER_SQL%"=="9.0" if not "%VER_SQL%"=="10.0" if not "%VER_SQL%"=="10.5" if not "%VER_SQL%"=="11.0" >>%file_sql% echo       ,cast^(o.last_log_size  as dec^(4,1^)^) AS 'Last Space used ^(MB^)'
if not "%VER_SQL%"=="9.0" if not "%VER_SQL%"=="10.0" if not "%VER_SQL%"=="10.5" >>%file_sql% echo from %TMPTAB% o;
if not "%VER_SQL%"=="9.0" if not "%VER_SQL%"=="10.0" if not "%VER_SQL%"=="10.5" >>%file_sql% echo:
if not "%VER_SQL%"=="9.0" if not "%VER_SQL%"=="10.0" if not "%VER_SQL%"=="10.5" >>%file_sql% echo if exists ^(select * from tempdb.sys.all_objects where name like '%%%TMPTAB%%%'^) drop table %TMPTAB%
if not "%VER_SQL%"=="9.0" if not "%VER_SQL%"=="10.0" if not "%VER_SQL%"=="10.5" >>%file_sql% echo go
if not "%VER_SQL%"=="9.0" if not "%VER_SQL%"=="10.0" if not "%VER_SQL%"=="10.5" >>%file_sql% echo:
>>%file_sql% echo PRINT ''
>>%file_sql% echo PRINT '+------------+'
>>%file_sql% echo PRINT '^| LOG growth ^|'
>>%file_sql% echo PRINT '+------------+'
>>%file_sql% echo PRINT ''
>>%file_sql% echo:
>>%file_sql% echo ;with logs AS
>>%file_sql% echo    ^(select left^(DB.name, %LEN_DBNAME%^)                                           AS DatabaseName,
>>%file_sql% echo            max^(DB.recovery_model_desc^)                                AS RecoveryModel,
>>%file_sql% echo            sum^(size * 8^)                                              AS TotalSizeKB,
>>%file_sql% echo            sum^(case when MF.is_percent_growth = 0
>>%file_sql% echo                     then MF.growth
>>%file_sql% echo                     else MF.size * MF.growth / 100.0 end * 8^)         AS TotalGrowthKB
>>%file_sql% echo     from sys.master_files MF
>>%file_sql% echo     inner join sys.databases DB on MF.database_id = DB.database_id
>>%file_sql% echo     where MF.[type] = 1
>>%file_sql% echo     group by DB.name^),
>>%file_sql% echo total AS
>>%file_sql% echo    ^(select OPC.[cntr_value]                                           AS TotalCounter
>>%file_sql% echo     from sys.dm_os_performance_counters OPC
>>%file_sql% echo     where OPC.[object_name] like '%%SQL%%:Databases%%'
>>%file_sql% echo     and   OPC.[counter_name]  = 'Log Growths'
>>%file_sql% echo     and   OPC.[instance_name] = '_Total'^),
>>%file_sql% echo growth AS
>>%file_sql% echo    ^(select OPC.[instance_name]                                        AS DatabaseName,
>>%file_sql% echo            OPC.[cntr_value]                                           AS Value
>>%file_sql% echo     from sys.dm_os_performance_counters OPC
>>%file_sql% echo     where OPC.[object_name] LIKE '%%SQL%%:Databases%%'
>>%file_sql% echo     and   OPC.[counter_name] = 'Log Growths'
>>%file_sql% echo     and   OPC.[instance_name] ^<^> '_Total'^),
>>%file_sql% echo shrinks AS
>>%file_sql% echo    ^(select OPC.[instance_name]                                        AS DatabaseName,
>>%file_sql% echo            OPC.[cntr_value]                                           AS Value
>>%file_sql% echo     from sys.dm_os_performance_counters OPC
>>%file_sql% echo     where OPC.[object_name] LIKE '%%SQL%%:Databases%%'
>>%file_sql% echo     and   OPC.[counter_name] = 'Log Shrinks'
>>%file_sql% echo     and   OPC.[instance_name] ^<^> '_Total'^)
>>%file_sql% echo select left^(logs.DatabaseName, %LEN_DBNAME%^)                                     AS 'DB Name',
>>%file_sql% echo        left^(logs.RecoveryModel, 15^)                                   AS 'Recovery Model',
>>%file_sql% echo        cast^(logs.TotalSizeKB / 1024.0 as decimal^(8,1^)^)                AS 'Total Log Size ^(MB^)',
>>%file_sql% echo        cast^(logs.TotalGrowthKB / 1024.0 as decimal^(8,1^)^)              AS 'Total Growth ^(MB^)',
>>%file_sql% echo        cast^(shrinks.Value as int^)                                     AS 'Shrink Count',
>>%file_sql% echo        cast^(growth.Value as int^)                                      AS 'Growth Count',
>>%file_sql% echo        convert^(decimal^(8, 1^),
>>%file_sql% echo 	           case when total.TotalCounter = 0 then 0.0
>>%file_sql% echo                   else 100.0 * growth.Value / total.TotalCounter end^) AS 'Growth Rate ^(%%^)'
>>%file_sql% echo from logs
>>%file_sql% echo inner join growth  on logs.DatabaseName = growth.DatabaseName
>>%file_sql% echo inner join shrinks on logs.DatabaseName = shrinks.DatabaseName
>>%file_sql% echo cross join total
>>%file_sql% echo order by 7 desc, 1;
>>%file_sql% echo:
>>%file_sql% echo PRINT ''
>>%file_sql% echo PRINT '+--------------+'
>>%file_sql% echo PRINT '^| LOG activity ^|'
>>%file_sql% echo PRINT '+--------------+'
>>%file_sql% echo PRINT ''
>>%file_sql% echo:
>>%file_sql% echo select cast^(fn.SPID as int^)                                                                                      AS 'SID',
>>%file_sql% echo        left^(isnull^(^(select max^(p.hostprocess^) from sys.sysprocesses p where p.spid = fn.SPID^),' '^), 6^)           AS 'PID',
>>%file_sql% echo        left^(fn.Operation, 20^)                                                                                    AS 'Operation', 
>>%file_sql% echo        left^(min^(isnull^(isnull^(fn.[Begin Time],fn.[Checkpoint Begin]^),''^)^), 19^)                                   AS 'Begin time',
>>%file_sql% echo        left^(max^(isnull^(isnull^(fn.[End Time],  fn.[Checkpoint Begin]^),''^)^), 19^)                                   AS 'End time',
>>%file_sql% echo        cast^(sum^([Log Record Length]/1024.0/1024^) as dec^(7,2^)^)                                                    AS 'Size ^(MB^)',
>>%file_sql% echo        left^(max^(SUSER_SNAME^(fn.[Transaction SID]^)^), 30^)                                                          AS 'Login',
>>%file_sql% echo        cast^(count^(fn.Operation^) as int^)                                                                          AS 'Records',
>>%file_sql% echo        cast^(replace^(sum^(case when fn.[Transaction Name] = 'ALTER TABLE'         then 1 else 0 end^),0,''^) as int^) AS 'Alter Table',
>>%file_sql% echo        cast^(replace^(sum^(case when fn.[Transaction Name] = 'CREATE INDEX'        then 1 else 0 end^),0,''^) as int^) AS 'Create Index',
>>%file_sql% echo        cast^(replace^(sum^(case when fn.[Transaction Name] = 'CREATE TABLE'        then 1 else 0 end^),0,''^) as int^) AS 'Create Table',
>>%file_sql% echo        cast^(replace^(sum^(case when fn.[Transaction Name] = 'DELETE'              then 1 else 0 end^),0,''^) as int^) AS '     Delete',
>>%file_sql% echo        cast^(replace^(sum^(case when fn.[Transaction Name] like 'INSERT%%'          then 1 else 0 end^),0,''^) as int^) AS '     Insert',
>>%file_sql% echo        cast^(replace^(sum^(case when fn.[Transaction Name] = 'UPDATE'              then 1 else 0 end^),0,''^) as int^) AS '     Update',
>>%file_sql% echo        cast^(replace^(sum^(case when fn.[Transaction Name] = 'DROPOBJ'             then 1 else 0 end^),0,''^) as int^) AS 'Drop Object',
>>%file_sql% echo        cast^(replace^(sum^(case when fn.[Transaction Name] = 'offline index build' then 1 else 0 end^),0,''^) as int^) AS 'Rebuild Index',
>>%file_sql% echo        cast^(replace^(sum^(case when fn.[Transaction Name] = 'SELECT INTO'         then 1 else 0 end^),0,''^) as int^) AS 'Select Into',
>>%file_sql% echo        cast^(replace^(sum^(case when fn.[Transaction Name] = 'AutoCreateQPStats'   then 1 else 0 end^),0,''^) as int^) AS 'Create Stats',
>>%file_sql% echo        cast^(replace^(sum^(case when fn.[Transaction Name] = 'UpdateQPStats'       then 1 else 0 end^),0,''^) as int^) AS 'Update Stats',
>>%file_sql% echo        cast^(replace^(sum^(case when fn.[Transaction Name] = 'user_transaction'    then 1 else 0 end^),0,''^) as int^) AS 'User transaction',
>>%file_sql% echo        cast^(replace^(sum^(case when fn.[Transaction Name] = 'SplitPage'           then 1 else 0 end^),0,''^) as int^) AS 'Split page',
>>%file_sql% echo        cast^(replace^(sum^(case when fn.[Transaction Name] not in ^(
>>%file_sql% echo 	                                  'ALTER TABLE','CREATE INDEX','CREATE TABLE','DELETE','UPDATE','DROPOBJ',
>>%file_sql% echo 	                                  'offline index build','SELECT INTO','AutoCreateQPStat','UpdateQPStats','user_transaction','SplitPage'^) and 
>>%file_sql% echo 	                                  fn.[Transaction Name] not like 'INSERT%%' then 1 else 0 end^),0,''^) as int^)      AS '     Others'
>>%file_sql% echo from fn_dblog^(null,null^) fn
>>%file_sql% echo where isnull^(fn.SPID, 0^) ^> 50
>>%file_sql% echo group by fn.SPID, fn.Operation
>>%file_sql% echo having sum^([Log Record Length]/1024.0/1024^) ^> 0
>>%file_sql% echo order by 6 desc, 1, 2;
>>%file_sql% echo:
if "%VER_SQL%"=="14.0" >>%file_sql% echo PRINT ''
if "%VER_SQL%"=="14.0" >>%file_sql% echo PRINT '+------------------------+'
if "%VER_SQL%"=="14.0" >>%file_sql% echo PRINT '^| Virtual Logs (Summary) ^|'
if "%VER_SQL%"=="14.0" >>%file_sql% echo PRINT '+------------------------+'
if "%VER_SQL%"=="14.0" >>%file_sql% echo PRINT ''
if "%VER_SQL%"=="14.0" >>%file_sql% echo:
if "%VER_SQL%"=="14.0" >>%file_sql% echo ;with vlogfiles as (
if "%VER_SQL%"=="14.0" >>%file_sql% echo select name,
if "%VER_SQL%"=="14.0" >>%file_sql% echo        file_id,
if "%VER_SQL%"=="14.0" >>%file_sql% echo        tot_vlogs
if "%VER_SQL%"=="14.0" >>%file_sql% echo from sys.databases d
if "%VER_SQL%"=="14.0" >>%file_sql% echo cross apply
if "%VER_SQL%"=="14.0" >>%file_sql% echo:
if "%VER_SQL%"=="14.0" >>%file_sql% echo   (select file_id,
if "%VER_SQL%"=="14.0" >>%file_sql% echo           count(*^) tot_vlogs
if "%VER_SQL%"=="14.0" >>%file_sql% echo    from sys.dm_db_log_info(db_id(d.name^)^)
if "%VER_SQL%"=="14.0" >>%file_sql% echo    group by file_id^) log
if "%VER_SQL%"=="14.0" >>%file_sql% echo ^)
if "%VER_SQL%"=="14.0" >>%file_sql% echo select left(vlf.name, %LEN_DBNAME%^)                                               AS 'DB Name',
if "%VER_SQL%"=="14.0" >>%file_sql% echo 	   cast(f.size*8.0/1024 as dec(7,1^)^)                               AS 'VL size (MB^)',
if "%VER_SQL%"=="14.0" >>%file_sql% echo        cast(vlf.tot_vlogs as int^)                                      AS 'Total VLogs',
if "%VER_SQL%"=="14.0" >>%file_sql% echo        cast(case when f.size*8.0/1024 ^< 1   then 3
if "%VER_SQL%"=="14.0" >>%file_sql% echo                  when f.size*8.0/1024 ^< 64  then 4
if "%VER_SQL%"=="14.0" >>%file_sql% echo                  when f.size*8.0/1024 ^< 100 then 8 else 16 end as int^) AS 'Recommended VLogs'
if "%VER_SQL%"=="14.0" >>%file_sql% echo from vlogfiles vlf
if "%VER_SQL%"=="14.0" >>%file_sql% echo join sys.master_files f on db_name(f.database_id^) = vlf.name and f.file_id = vlf.file_id
if "%VER_SQL%"=="14.0" >>%file_sql% echo where f.type_desc = 'LOG';
if "%VER_SQL%"=="14.0" >>%file_sql% echo:
if "%VER_SQL%"=="14.0" >>%file_sql% echo PRINT ''
if "%VER_SQL%"=="14.0" >>%file_sql% echo PRINT '+-----------------------+'
if "%VER_SQL%"=="14.0" >>%file_sql% echo PRINT '^| Virtual Logs (Detail) ^|'
if "%VER_SQL%"=="14.0" >>%file_sql% echo PRINT '+-----------------------+'
if "%VER_SQL%"=="14.0" >>%file_sql% echo PRINT ''
if not "%VER_SQL%"=="14.0" >>%file_sql% echo:
if not "%VER_SQL%"=="14.0" >>%file_sql% echo PRINT ''
if not "%VER_SQL%"=="14.0" >>%file_sql% echo PRINT '+--------------+'
if not "%VER_SQL%"=="14.0" >>%file_sql% echo PRINT '^| Virtual Logs ^|'
if not "%VER_SQL%"=="14.0" >>%file_sql% echo PRINT '+--------------+'
if not "%VER_SQL%"=="14.0" >>%file_sql% echo PRINT ''
if not "%VER_SQL%"=="14.0" >>%file_sql% echo:
if not "%VER_SQL%"=="14.0" >>%file_sql% echo dbcc loginfo;
if not "%VER_SQL%"=="14.0" >>%file_sql% echo:
if "%VER_SQL%"=="14.0" >>%file_sql% echo:
if "%VER_SQL%"=="14.0" >>%file_sql% echo if exists ^(select * from tempdb.sys.all_objects where name like '%%%TMPTAB%%%'^) drop table %TMPTAB%
if "%VER_SQL%"=="14.0" >>%file_sql% echo go
if "%VER_SQL%"=="14.0" >>%file_sql% echo create table %TMPTAB%^(db_name varchar^(128^),
if "%VER_SQL%"=="14.0" >>%file_sql% echo                             model   varchar^(6^),
if "%VER_SQL%"=="14.0" >>%file_sql% echo                             file_id int,
if "%VER_SQL%"=="14.0" >>%file_sql% echo                             offset  bigint,
if "%VER_SQL%"=="14.0" >>%file_sql% echo                             fseqno  bigint,
if "%VER_SQL%"=="14.0" >>%file_sql% echo                             size    decimal^(8,1^),
if "%VER_SQL%"=="14.0" >>%file_sql% echo                             status  varchar^(8^)^);
if "%VER_SQL%"=="14.0" >>%file_sql% echo:
if "%VER_SQL%"=="14.0" if     defined SQL_BDD >>%file_sql% echo exec sp_MSforeachdb @command1='if db_id^(''?''^) ^<= 4 or db_name^(db_id^(''?''^)^) ^<^>''%SQL_BDD%'' return; use [?]; insert %TMPTAB%
if "%VER_SQL%"=="14.0" if not defined SQL_BDD >>%file_sql% echo exec sp_MSforeachdb @command1='if db_id^(''?''^) ^<= 4 return; use [?]; insert %TMPTAB%
if "%VER_SQL%"=="14.0" >>%file_sql% echo select ''?'',
if "%VER_SQL%"=="14.0" >>%file_sql% echo        d.recovery_model_desc,
if "%VER_SQL%"=="14.0" >>%file_sql% echo        l.file_id,
if "%VER_SQL%"=="14.0" >>%file_sql% echo        l.vlf_begin_offset,
if "%VER_SQL%"=="14.0" >>%file_sql% echo        l.vlf_sequence_number,
if "%VER_SQL%"=="14.0" >>%file_sql% echo        l.vlf_size_mb,
if "%VER_SQL%"=="14.0" >>%file_sql% echo        l.vlf_status			
if "%VER_SQL%"=="14.0" >>%file_sql% echo from sys.dm_db_log_info^(db_id^(^)^) l	
if "%VER_SQL%"=="14.0" >>%file_sql% echo inner join sys.databases d on l.database_id = d.database_id;';
if "%VER_SQL%"=="14.0" >>%file_sql% echo:
if "%VER_SQL%"=="14.0" >>%file_sql% echo select left^(o.db_name, %LEN_DBNAME%^)                       AS 'DB Name',
if "%VER_SQL%"=="14.0" >>%file_sql% echo        left^(o.model, 6^)                         AS 'Recovery Model',
if "%VER_SQL%"=="14.0" >>%file_sql% echo        cast^(o.file_id as tinyint^)               AS 'File Id.',
if "%VER_SQL%"=="14.0" >>%file_sql% echo        cast^(o.offset as bigint^)                 AS 'StartOffset',
if "%VER_SQL%"=="14.0" >>%file_sql% echo        cast^(o.fseqno as bigint^)                 AS '     FSeqNo',
if "%VER_SQL%"=="14.0" >>%file_sql% echo        cast^(round^(o.size, 0^) as int^)            AS '  Size ^(MB^)',
if "%VER_SQL%"=="14.0" >>%file_sql% echo        case when o.status = 0 then 'INACTIVE'
if "%VER_SQL%"=="14.0" >>%file_sql% echo             when o.status = 1 then 'INITIAL'
if "%VER_SQL%"=="14.0" >>%file_sql% echo             when o.status = 2 then 'ACTIVE' end AS 'Status'			
if "%VER_SQL%"=="14.0" >>%file_sql% echo from %TMPTAB% o;
if "%VER_SQL%"=="14.0" >>%file_sql% echo:
if "%VER_SQL%"=="14.0" >>%file_sql% echo if exists ^(select * from tempdb.sys.all_objects where name like '%%%TMPTAB%%%'^) drop table %TMPTAB%
if "%VER_SQL%"=="14.0" >>%file_sql% echo go
if "%VER_SQL%"=="14.0" >>%file_sql% echo:
>>%file_sql% echo PRINT ''
>>%file_sql% echo PRINT '+----------+'
>>%file_sql% echo PRINT '^| IO usage ^|'
>>%file_sql% echo PRINT '+----------+'
>>%file_sql% echo PRINT ''
>>%file_sql% echo:
>>%file_sql% echo ;with usage as ^(
>>%file_sql% echo select db_name^(f.database_id^) as dbname,
>>%file_sql% echo        sum^(f.num_of_bytes_read + num_of_bytes_written^)/1024.0/1024.0 io_in_mb
>>%file_sql% echo from sys.dm_io_virtual_file_stats^(null, null^) f
>>%file_sql% echo group by f.database_id
>>%file_sql% echo ^)
>>%file_sql% echo select cast^(row_number^(^) over^(order by u.io_in_mb desc^) as tinyint^)  AS 'Rank',
>>%file_sql% echo        left^(u.dbname, %LEN_DBNAME%^)                                             AS 'DB Name',
>>%file_sql% echo        cast^(u.io_in_mb / 1024.0 as dec^(7,1^)^)                         AS 'Total IO ^(GB^)',
>>%file_sql% echo        cast^(u.io_in_mb / sum^(u.io_in_mb^) over^(^) * 100.0 as dec^(4,1^)^) AS 'Total IO ^(%%^)'
>>%file_sql% echo from usage u
>>%file_sql% echo order by 1 option ^(RECOMPILE^);
>>%file_sql% echo:
>>%file_sql% echo PRINT ''
>>%file_sql% echo PRINT '+-------------+'
>>%file_sql% echo PRINT '^| IO activity ^|'
>>%file_sql% echo PRINT '+-------------+'
>>%file_sql% echo PRINT ''
>>%file_sql% echo:
>>%file_sql% echo declare @tot_sess int
>>%file_sql% echo select @tot_sess = count^(s.session_id^) from sys.dm_exec_sessions s
>>%file_sql% echo where s.session_id^>50
>>%file_sql% echo and s.is_user_process = 1
>>%file_sql% echo:
>>%file_sql% echo PRINT 'Total sessions: ' + cast^(@tot_sess as varchar^)
>>%file_sql% echo PRINT ''
>>%file_sql% echo:
>>%file_sql% echo select cast^(sum^(num_of_reads^)/max^(abs^(sample_ms^)/1000.0^)                                                   as decimal^(5,1^)^) AS "Read IOPS",
>>%file_sql% echo        cast^(sum^(num_of_writes^)/max^(abs^(sample_ms^)/1000.0^)                                                  as decimal^(5,1^)^) AS "Write IOPS",
>>%file_sql% echo        cast^(^(sum^(num_of_reads + num_of_writes^)^)/max^(abs^(sample_ms^)/1000.0^)                                 as decimal^(5,1^)^) AS "Total IOPS",
>>%file_sql% echo        cast^(sum^(num_of_bytes_read/1024/1024^)/max^(abs^(sample_ms^)/1000.0^)                                    as decimal^(5,1^)^) AS "Read MBPS",
>>%file_sql% echo        cast^(sum^(num_of_bytes_written/1024/1024^)/max^(abs^(sample_ms^)/1000.0^)                                 as decimal^(5,1^)^) AS "Write MBPS",
>>%file_sql% echo        cast^(^(sum^(num_of_bytes_read + num_of_bytes_written^)/1024/1024^)/max^(abs^(sample_ms^)/1000.0^)           as decimal^(5,1^)^) AS "Total MBPS",
>>%file_sql% echo 	   cast^(^(sum^(num_of_reads + num_of_writes^)^)/max^(abs^(sample_ms^)/1000.0^)/@tot_sess                       as decimal^(5,1^)^) AS "IOPS/Session",
>>%file_sql% echo        cast^(^(sum^(num_of_bytes_read + num_of_bytes_written^)/1024/1024^)/max^(abs^(sample_ms^)/1000.0^)/@tot_sess as decimal^(5,1^)^) AS "MBPS/Session"
>>%file_sql% echo from sys.dm_io_virtual_file_stats^(null,null^);
>>%file_sql% echo:
>>%file_sql% echo PRINT ''
>>%file_sql% echo PRINT '+-----------------+'
>>%file_sql% echo PRINT '^| Pending disk IO ^|'
>>%file_sql% echo PRINT '+-----------------+'
>>%file_sql% echo PRINT ''
>>%file_sql% echo:
>>%file_sql% echo select left^(db_name^(mf.database_id^), %LEN_DBNAME%^)         AS 'DB Name',
>>%file_sql% echo        left^(mf.physical_name, %LEN_DBFILE%^)               AS 'Filename',
>>%file_sql% echo        left^(p.io_type, 4^)                       AS 'Type',
>>%file_sql% echo        cast^(sum^(vfs.num_of_reads^)       as int^) AS 'Total Reads',
>>%file_sql% echo        cast^(sum^(vfs.num_of_writes^)      as int^) AS 'Total Writes',
>>%file_sql% echo        cast^(sum^(p.io_pending^)           as int^) AS 'Total Pending IO',
>>%file_sql% echo        cast^(sum^(p.io_pending_ms_ticks^) as int^)  AS 'Total_Pending IO (ms)'
>>%file_sql% echo from sys.dm_io_pending_io_requests p
>>%file_sql% echo inner join sys.dm_io_virtual_file_stats^(null,null^) vfs on p.io_handle = vfs.file_handle
>>%file_sql% echo inner join sys.master_files mf on vfs.database_id = mf.database_id and vfs.file_id = mf.file_id
>>%file_sql% echo group by mf.database_id, mf.physical_name, p.io_type
>>%file_sql% echo order by sum^(p.io_pending^);
>>%file_sql% echo:
goto:EOF
::#
::# End of Audit_log
::#************************************************************#

:Audit_temp
::#************************************************************#
::# Audits space and activity for the TempDB database
::#
>>%file_sql% echo PRINT ''
>>%file_sql% echo PRINT '+--------------+'
>>%file_sql% echo PRINT '^| TempDB space ^|'
>>%file_sql% echo PRINT '+--------------+'
>>%file_sql% echo PRINT ''
>>%file_sql% echo:
>>%file_sql% echo select cast^(isnull^(sum^(user_object_reserved_page_count^),0^)*1.0/128 as decimal^(5,1^)^)     AS 'Reserved ^(MB^)',
>>%file_sql% echo        cast^(isnull^(sum^(internal_object_reserved_page_count^),0^)*1.0/128 as decimal^(5,1^)^) AS 'Internal ^(MB^)',
>>%file_sql% echo        cast^(isnull^(sum^(version_store_reserved_page_count^),0^)*1.0/128 as decimal^(5,1^)^)   AS 'Version store ^(MB^)',
>>%file_sql% echo        cast^(isnull^(sum^(unallocated_extent_page_count^),0^)*1.0/128 as decimal^(6,1^)^)       AS 'Free space ^(MB^)'
>>%file_sql% echo from sys.dm_db_file_space_usage
>>%file_sql% echo where database_id = 2;
>>%file_sql% echo:
>>%file_sql% echo PRINT ''
>>%file_sql% echo PRINT '+--------------+'
>>%file_sql% echo PRINT '^| TempDB usage ^|'
>>%file_sql% echo PRINT '+--------------+'
>>%file_sql% echo PRINT ''
>>%file_sql% echo:
>>%file_sql% echo ;with task_space_usage as ^(
>>%file_sql% echo     select session_id,
>>%file_sql% echo            request_id,
>>%file_sql% echo            sum^(internal_objects_alloc_page_count^) AS alloc_pages,
>>%file_sql% echo            sum^(internal_objects_dealloc_page_count^) AS dealloc_pages
>>%file_sql% echo     from sys.dm_db_task_space_usage WITH ^(NOLOCK^)
>>%file_sql% echo     where session_id ^<^> @@SPID
>>%file_sql% echo     group by session_id, request_id
>>%file_sql% echo ^)
>>%file_sql% echo select u.session_id                                                             AS 'SID',
>>%file_sql% echo        left^(DB_NAME^(r.database_id^), %LEN_DBNAME%^)                                          AS 'DB Name',
>>%file_sql% echo        cast^(u.alloc_pages   / 128.0 as decimal^(5,1^)^)                            AS 'Internal Object ^(MB^)',
>>%file_sql% echo        cast^(u.dealloc_pages / 128.0 as decimal^(5,1^)^)                            AS 'Internal Object Dealloc ^(MB^)',
>>%file_sql% echo        char^(13^)+char^(10^)+char^(13^)+char^(10^)+cast^(substring^(t.text, ^(r.statement_start_offset/2^)+1,
>>%file_sql% echo 	     ^(^(case r.statement_end_offset when -1
>>%file_sql% echo 	       then datalength^(t.text^)
>>%file_sql% echo            else r.statement_end_offset  end -
>>%file_sql% echo                 r.statement_start_offset^)/2^)+1^) as char^(%LEN_FULLSQLT%^)^)+char^(13^)+char^(10^) AS 'SQL Text'--,
>>%file_sql% echo      --left(cast^(p.query_plan as varchar^(max^)^), %LEN_SQLT%^)                            AS 'Query Plan'
>>%file_sql% echo from task_space_usage u
>>%file_sql% echo inner join sys.dm_exec_requests r WITH ^(NOLOCK^)
>>%file_sql% echo on u.session_id = r.session_id and u.request_id = r.request_id
>>%file_sql% echo outer apply sys.dm_exec_sql_text^(r.sql_handle^) t
>>%file_sql% echo outer apply sys.dm_exec_query_plan^(r.plan_handle^) p
>>%file_sql% echo where t.text not like '%%sys.dm%%'
>>%file_sql% echo order by 4 desc, 5 desc;
>>%file_sql% echo:
>>%file_sql% echo PRINT ''
>>%file_sql% echo PRINT '+-------------------+'
>>%file_sql% echo PRINT '^| TempDB allocation ^|'
>>%file_sql% echo PRINT '+-------------------+'
>>%file_sql% echo PRINT ''
>>%file_sql% echo:
>>%file_sql% echo select  TOP %TOP_NSQL%
>>%file_sql% echo         coalesce^(t1.session_id, t2.session_id^)                                                                          AS 'SID',
>>%file_sql% echo         left^(DB_NAME^(coalesce^(t1.database_id, t2.database_id^)^), %LEN_DBNAME%^)                                                      AS 'DB Name',
>>%file_sql% echo         left^(coalesce^(t1.tot_alloc_usr_obj_in_mb, 0^)  + t2.tot_alloc_usr_obj_in_mb, 25^)                                 AS 'Tot User Object ^(MB^)',
>>%file_sql% echo         left^(coalesce^(t1.net_alloc_user_obj_in_mb, 0^) + t2.net_alloc_user_obj_in_mb, 25^)                                AS 'Net User Object ^(MB^)',
>>%file_sql% echo         left^(coalesce^(t1.tot_alloc_int_obj_in_mb, 0^)  + t2.tot_alloc_int_obj_in_mb, 25^)                                 AS 'Tot Internal Object ^(MB^)',
>>%file_sql% echo         left^(coalesce^(t1.net_alloc_int_obj_in_mb, 0^)  + t2.net_alloc_int_obj_in_mb, 25^)                                 AS 'Net Internal Object ^(MB^)',
>>%file_sql% echo         left^(coalesce^(t1.tot_alloc_in_mb, 0^) + t2.tot_alloc_in_mb, 25^)                                                  AS 'Total Allocation ^(MB^)',
>>%file_sql% echo         left^(coalesce^(t1.net_alloc_in_mb, 0^) + t2.net_alloc_in_mb, 25^)                                                  AS 'Net Allocation ^(MB^)',
>>%file_sql% echo         char^(13^)+char^(10^)+char^(13^)+char^(10^)+coalesce^(t1.query_text, t2.query_text^)+char^(13^)+char^(10^)+replicate^('-',%LEN_FULLSQLT%^) AS 'SQL Text'
>>%file_sql% echo from ^(select ts.session_id,
>>%file_sql% echo              ts.database_id,
>>%file_sql% echo              cast^(ts.user_objects_alloc_page_count / 128.0 as dec^(6,1^)^) tot_alloc_usr_obj_in_mb,
>>%file_sql% echo              cast^(^(ts.user_objects_alloc_page_count - ts.user_objects_dealloc_page_count^) / 128.0 as dec^(6,1^)^) net_alloc_user_obj_in_mb,
>>%file_sql% echo              cast^(ts.internal_objects_alloc_page_count / 128.0 as dec^(6,1^)^) tot_alloc_int_obj_in_mb ,
>>%file_sql% echo              cast^(^(ts.internal_objects_alloc_page_count - ts.internal_objects_dealloc_page_count^) / 128.0 as dec^(6,1^)^) net_alloc_int_obj_in_mb,
>>%file_sql% echo              cast^(^( ts.user_objects_alloc_page_count + internal_objects_alloc_page_count^) / 128.0 as dec^(6,1^)^) tot_alloc_in_mb,
>>%file_sql% echo              cast^(^(ts.user_objects_alloc_page_count + ts.internal_objects_alloc_page_count -
>>%file_sql% echo                    ts.internal_objects_dealloc_page_count - ts.user_objects_dealloc_page_count^) / 128.0 as dec^(6,1^)^) net_alloc_in_mb,
>>%file_sql% echo              substring^(t.text, ^(er.statement_start_offset/2^)+1,
>>%file_sql% echo 	                           ^(^(case er.statement_end_offset
>>%file_sql% echo 							     when -1 then datalength^(t.text^)
>>%file_sql% echo 								 else er.statement_end_offset  end - er.statement_start_offset^)/2^)+1^) query_text
>>%file_sql% echo       from sys.dm_db_task_space_usage ts
>>%file_sql% echo       join sys.dm_exec_requests er on er.request_id = ts.request_id and er.session_id = ts.session_id
>>%file_sql% echo       outer apply sys.dm_exec_sql_text^(er.sql_handle^) t
>>%file_sql% echo       where ts.session_id ^> 50
>>%file_sql% echo       and ts.session_id ^<^> @@SPID
>>%file_sql% echo       and t.text not like '%%sys.dm%%'^) t1
>>%file_sql% echo right join ^(select ss.session_id,
>>%file_sql% echo                    ss.database_id ,
>>%file_sql% echo                    cast^(ss.user_objects_alloc_page_count / 128.0 as dec^(6,1^)^) tot_alloc_usr_obj_in_mb,
>>%file_sql% echo                    cast^(^(ss.user_objects_alloc_page_count - ss.user_objects_dealloc_page_count^) / 128.0 as dec^(6,1^)^) net_alloc_user_obj_in_mb,
>>%file_sql% echo                    cast^(ss.internal_objects_alloc_page_count / 128.0 as dec^(6,1^)^) tot_alloc_int_obj_in_mb,
>>%file_sql% echo                    cast^(^(ss.internal_objects_alloc_page_count - ss.internal_objects_dealloc_page_count^) / 128.0 as dec^(6,1^)^) net_alloc_int_obj_in_mb,
>>%file_sql% echo                    cast^(^(ss.user_objects_alloc_page_count + internal_objects_alloc_page_count^) / 128.0 as dec^(6,1^)^) tot_alloc_in_mb,
>>%file_sql% echo                    cast^(^(ss.user_objects_alloc_page_count + ss.internal_objects_alloc_page_count -
>>%file_sql% echo                          ss.internal_objects_dealloc_page_count - ss.user_objects_dealloc_page_count^) / 128.0 as dec^(6,1^)^) net_alloc_in_mb,
>>%file_sql% echo                    case when charindex^('^)S', t.text^) ^>0 then substring^(t.text, charindex^('^)S', t.text^)+1, 3000^) else t.text end query_text
>>%file_sql% echo             from sys.dm_db_session_space_usage ss
>>%file_sql% echo             left join sys.dm_exec_connections cn on cn.session_id = ss.session_id
>>%file_sql% echo             outer apply sys.dm_exec_sql_text^(cn.most_recent_sql_handle^) t
>>%file_sql% echo             where ss.session_id ^> 50
>>%file_sql% echo             and ss.session_id ^<^> @@SPID
>>%file_sql% echo             and t.text not like '%%sys.dm%%'^) t2 on t1.session_id = t2.session_id
>>%file_sql% echo where coalesce^(t1.net_alloc_in_mb, 0^) + t2.net_alloc_in_mb ^> 0
>>%file_sql% echo order by 8 desc;
>>%file_sql% echo:
goto:EOF
::#
::# End of Audit_temp
::#************************************************************#

:Audit_obj
::#************************************************************#
::# Audits Object count, most large objects and fragmented, space used, top usage and index properties plus partitioned tables and indexes
::#
>>%file_sql% echo PRINT ''
>>%file_sql% echo PRINT '+--------------+'
>>%file_sql% echo PRINT '^| Object count ^|'
>>%file_sql% echo PRINT '+--------------+'
>>%file_sql% echo PRINT ''
>>%file_sql% echo:
if     defined SQL_BDD >>%file_sql% echo exec sp_MSforeachdb @command1='if db_id^(''?''^) ^<= 4 or db_name^(db_id^(''?''^)^) ^<^>''%SQL_BDD%'' return; use [?]; print ''*** ? ***''; print ''''
if not defined SQL_BDD >>%file_sql% echo exec sp_MSforeachdb @command1='if db_id^(''?''^) ^<= 4 return; use [?]; print ''*** ? ***''; print ''''
>>%file_sql% echo ;with indexes as
>>%file_sql% echo ^(select s.name,
>>%file_sql% echo sum^(case when i.index_id ^>= 3 then 1 else 0 end^) as nbr_ind,
>>%file_sql% echo count^(distinct i.data_space_id^)-1 as nbr_fgr
>>%file_sql% echo from sys.indexes i
>>%file_sql% echo join sys.tables t  on t.object_id = i.object_id
>>%file_sql% echo join sys.schemas s on s.schema_id = t.schema_id
>>%file_sql% echo group by s.name^)
>>%file_sql% echo select left^(s.name, %LEN_OWNER%^) AS ''Schema Name'',
>>%file_sql% echo cast^(max(i.nbr_fgr^) as tinyint^) AS ''Filegrp'',
>>%file_sql% echo right^(replicate^('' '',6-len^(sum^(case when o.type = ''U''  then 1 else 0 end^)^)^)+cast^(sum^(case when o.type = ''U''  then 1 else 0 end^) as varchar^),6^) AS '' Table'',
>>%file_sql% echo right^(replicate^('' '',6-len^(cast^(max^(i.nbr_ind^) as varchar^)^)^)+ cast^(max^(i.nbr_ind^) as varchar^),6^) AS '' Index'',
>>%file_sql% echo right^(replicate^('' '',6-len^(sum^(case when o.type = ''P''  then 1 else 0 end^)^)^)+cast^(sum^(case when o.type = ''P''  then 1 else 0 end^) as varchar^),6^) AS ''  Proc'',
>>%file_sql% echo right^(replicate^('' '',6-len^(sum^(case when o.type in ^(''TF'',''FN''^) then 1 else 0 end^)^)^)+cast^(sum^(case when o.type in ^(''TF'',''FN''^) then 1 else 0 end^) as varchar^),6^) AS ''   Fnc'',
>>%file_sql% echo right^(replicate^('' '',6-len^(sum^(case when o.type = ''TR'' then 1 else 0 end^)^)^)+cast^(sum^(case when o.type = ''TR'' then 1 else 0 end^) as varchar^),6^) AS ''   Trg'',
>>%file_sql% echo right^(replicate^('' '',6-len^(sum^(case when o.type = ''SO'' then 1 else 0 end^)^)^)+cast^(sum^(case when o.type = ''SO'' then 1 else 0 end^) as varchar^),6^) AS ''   Seq'',
>>%file_sql% echo right^(replicate^('' '',6-len^(sum^(case when o.type = ''V''  then 1 else 0 end^)^)^)+cast^(sum^(case when o.type = ''V''  then 1 else 0 end^) as varchar^),6^) AS ''  View'',
>>%file_sql% echo right^(replicate^('' '',6-len^(sum^(case when o.type = ''PK'' then 1 else 0 end^)^)^)+cast^(sum^(case when o.type = ''PK'' then 1 else 0 end^) as varchar^),6^) AS ''    PK'',
>>%file_sql% echo right^(replicate^('' '',6-len^(sum^(case when o.type = ''D''  then 1 else 0 end^)^)^)+cast^(sum^(case when o.type = ''D''  then 1 else 0 end^) as varchar^),6^) AS ''    CK''
>>%file_sql% echo from sys.objects o
>>%file_sql% echo join sys.schemas s on s.schema_id = o.schema_id
>>%file_sql% echo join indexes i on i.name = s.name
if not defined LOGIN if (%FLG_DBO%)==(0) >>%file_sql% echo and s.name ^<^> ''dbo''
if     defined LOGIN >>%file_sql% echo where  s.name = ''%LOGIN%''
>>%file_sql% echo group by s.name; print ''''';
>>%file_sql% echo:
>>%file_sql% echo PRINT '+---------------+'
>>%file_sql% echo PRINT '^| Trigger usage ^|'
>>%file_sql% echo PRINT '+---------------+'
>>%file_sql% echo PRINT ''
>>%file_sql% echo:
if     defined SQL_BDD >>%file_sql% echo exec sp_MSforeachdb @command1='if db_id^(''?''^) ^<= 4 or db_name^(db_id^(''?''^)^) ^<^>''%SQL_BDD%'' return; use [?]; print ''*** ? ***''; print ''''
if not defined SQL_BDD >>%file_sql% echo exec sp_MSforeachdb @command1='if db_id^(''?''^) ^<= 4 return; use [?]; print ''*** ? ***''; print ''''
>>%file_sql% echo select left^(s.name, %LEN_OWNER%^)                                                            AS ''Schema Name'',
>>%file_sql% echo        cast^(sum^(case when t.name like ^(''%%_INS''^)         then 1 else 0 end^) as int^) AS ''        INS'',
>>%file_sql% echo        cast^(sum^(case when t.name like ^(''%%_UPD''^)         then 1 else 0 end^) as int^) AS ''        UPD'',
>>%file_sql% echo        cast^(sum^(case when t.name like ^(''%%_DEL''^)         then 1 else 0 end^) as int^) AS ''        DEL'',
>>%file_sql% echo        cast^(sum^(case when t.name like ^(''%%_INS_BI''^)      then 1 else 0 end^) as int^) AS ''     INS_BI'',
>>%file_sql% echo        cast^(sum^(case when t.name like ^(''%%_UPD_BI''^)      then 1 else 0 end^) as int^) AS ''     UPD_BI'',
>>%file_sql% echo        cast^(sum^(case when t.name like ^(''%%_DEL_BI''^)      then 1 else 0 end^) as int^) AS ''D     EL_BI'',
>>%file_sql% echo        cast^(sum^(case when t.name like ^(''%%_UPDTICK''^)     then 1 else 0 end^) as int^) AS ''INS_UPDTICK'',
>>%file_sql% echo        cast^(sum^(case when t.name not like ^(''%%_INS''^)     and
>>%file_sql% echo 	                      t.name not like ^(''%%_UPD''^)     and
>>%file_sql% echo 	                      t.name not like ^(''%%_DEL''^)     and
>>%file_sql% echo 	                      t.name not like ^(''%%_INS_BI''^)  and
>>%file_sql% echo 	                      t.name not like ^(''%%_UPD_BI''^)  and
>>%file_sql% echo 	                      t.name not like ^(''%%_DEL_BI''^)  and
>>%file_sql% echo 	                      t.name not like ^(''%%_UPDTICK''^) then 1 else 0 end^) as int^) AS ''OTHERS'',
>>%file_sql% echo        case when t.is_disabled = 0 then ''Yes'' else ''No'' end                      AS ''Enabled''
>>%file_sql% echo from sys.triggers t
>>%file_sql% echo left join sys.objects      p on t.parent_id = p.object_id
>>%file_sql% echo left join sys.schemas      s on p.schema_id = s.schema_id
>>%file_sql% echo left join sys.sql_modules sm on t.object_id = sm.object_id
if defined LOGIN >>%file_sql% echo where s.name = ''%LOGIN%''    -- Lists only for a login
>>%file_sql% echo group by s.name, t.is_disabled
>>%file_sql% echo order by s.name; print ''''';
>>%file_sql% echo:
>>%file_sql% echo PRINT '+-------------------------+'
>>%file_sql% echo PRINT '^| Objects in buffer cache ^|'
>>%file_sql% echo PRINT '+-------------------------+'
>>%file_sql% echo PRINT ''
>>%file_sql% echo:
>>%file_sql% echo if exists ^(select * from tempdb.sys.all_objects where name like '%%%TMPTAB%%%'^) drop table %TMPTAB%
>>%file_sql% echo go
>>%file_sql% echo PRINT ''
>>%file_sql% echo create table %TMPTAB%^(db_name     varchar^(128^),
>>%file_sql% echo                             object_type varchar^(30^),
>>%file_sql% echo                             object_name varchar^(128^),
>>%file_sql% echo                             used_in_mb  decimal^(8,1^)^);
>>%file_sql% echo:
if     defined SQL_BDD >>%file_sql% echo exec sp_MSforeachdb @command1='if db_id^(''?''^) ^<= 4 or db_name^(db_id^(''?''^)^) ^<^>''%SQL_BDD%'' return; use [?]; insert %TMPTAB%
if not defined SQL_BDD >>%file_sql% echo exec sp_MSforeachdb @command1='if db_id^(''?''^) ^<= 4 return; use [?]; insert %TMPTAB%
>>%file_sql% echo select ''?'',
>>%file_sql% echo        case o.type when ''PK'' then ''INDEX''
>>%file_sql% echo                    when ''P''  then ''PROCEDURE''
>>%file_sql% echo                    when ''TF'' then ''FUNCTION''
>>%file_sql% echo                    when ''TR'' then ''TRIGGER''
>>%file_sql% echo                    when ''U''  then ''TABLE''
>>%file_sql% echo                    when ''SO'' then ''SEQUENCE''
>>%file_sql% echo                    when ''V''  then ''VIEW''
>>%file_sql% echo                    when ''D''  then ''DEFAULT CONSTRAINT''
>>%file_sql% echo                    when ''D''  then ''DEFAULT CONSTRAINT''
>>%file_sql% echo                    when ''C''  then ''CHECK CONSTRAINT''
>>%file_sql% echo                    when ''D''  then ''DEFAULT CONSTRAINT''
>>%file_sql% echo                    when ''F''  then ''FOREIGN KEY''
>>%file_sql% echo                    when ''UQ'' then ''UNIQUE CONSTRAINT''
>>%file_sql% echo                    when ''FN'' then ''FUNCTION''
>>%file_sql% echo                    else o.type end,
>>%file_sql% echo        o.name,
>>%file_sql% echo        count^(*^) * 8 / 1024.0
>>%file_sql% echo from sys.dm_os_buffer_descriptors b
>>%file_sql% echo join sys.allocation_units a on a.allocation_unit_id = b.allocation_unit_id
>>%file_sql% echo join sys.partitions p       on ^(a.container_id = p.hobt_id and type in ^(1,2,3^)^)
>>%file_sql% echo join sys.objects o          on p.object_id = o.object_id
>>%file_sql% echo where a.type in ^(1, 2, 3^)
>>%file_sql% echo and o.is_ms_shipped = 0
>>%file_sql% echo and DB_NAME^(b.database_id^) = ''?''
>>%file_sql% echo group by o.name, o.type
>>%file_sql% echo having count^(*^) * 8 / 1024 ^>= 1;';
>>%file_sql% echo:
>>%file_sql% echo select left^(o.db_name, %LEN_DBNAME%^)             AS 'DB Name',
>>%file_sql% echo        left^(o.object_type, 20^)        AS 'Object type',
>>%file_sql% echo        left^(o.object_name, %LEN_TABLE%^)        AS 'Object name',
>>%file_sql% echo        cast^(o.used_in_mb as dec^(8,1^)^) AS 'Used ^(^>=1Mb^)'
>>%file_sql% echo from %TMPTAB% o
>>%file_sql% echo order by 1, 4 desc;
>>%file_sql% echo if exists ^(select * from tempdb.sys.all_objects where name like '%%%TMPTAB%%%'^) drop table %TMPTAB%
>>%file_sql% echo go
>>%file_sql% echo:
>>%file_sql% echo PRINT ''
>>%file_sql% echo PRINT '+------------------+'
>>%file_sql% echo PRINT '^| Temporary tables ^|'
>>%file_sql% echo PRINT '+------------------+'
>>%file_sql% echo PRINT ''
>>%file_sql% echo:
if defined SQL_BDD >>%file_sql% echo select TOP %TOP_NSQL%
if defined SQL_BDD >>%file_sql% echo        left^(s.name, %LEN_OWNER%^)                                                                    AS 'Owner',
if defined SQL_BDD >>%file_sql% echo        left^(o.name, %LEN_TABLE%^)                                                                    AS 'Table Name',
if defined SQL_BDD >>%file_sql% echo        cast^(sum^(ps.used_page_count^) * 8 /1024.0 as dec^(7,1^)^)                               AS 'Size ^(MB^)',
if defined SQL_BDD >>%file_sql% echo        right^(replicate^(' ',9-len^(sum^(ps.row_count^)^)^)+cast^(sum^(ps.row_count^) as varchar^),9^) AS 'Row Count'
if defined SQL_BDD >>%file_sql% echo from sys.partitions p
if defined SQL_BDD >>%file_sql% echo inner join sys.dm_db_partition_stats ps on p.partition_id = ps.partition_id and p.partition_number = ps.partition_number
if defined SQL_BDD >>%file_sql% echo inner join sys.objects o                on ps.object_id   = o.object_id
if defined SQL_BDD >>%file_sql% echo inner join sys.schemas s                on o.schema_id    = s.schema_id
if defined SQL_BDD >>%file_sql% echo where o.name like '#%%' or o.name like 'F[_]%%'
if defined SQL_BDD >>%file_sql% echo and s.name not like 'DW%%'
if defined SQL_BDD if defined LOGIN >>%file_sql% echo and s.name = '%LOGIN%'    -- Lists only for a login
if defined SQL_BDD >>%file_sql% echo group by s.name, o.name
if defined SQL_BDD >>%file_sql% echo order by 3 desc;
if defined SQL_BDD >>%file_sql% echo:
if defined SQL_BDD >>%file_sql% echo PRINT ''
>>%file_sql% echo select left^(s.name, %LEN_OWNER%^)                                                          AS 'Owner',
>>%file_sql% echo        left^(t.name, %LEN_TABLE%^)                                                          AS 'Table name',
if "%VER_SQL%"=="11.0" >>%file_sql% echo        left^(format^(t.create_date, '%FMT_DAT2%'^),14^)                          AS 'Datetime'
if "%VER_SQL%"=="12.0" >>%file_sql% echo        left^(format^(t.create_date, '%FMT_DAT2%'^),14^)                          AS 'Datetime'
if "%VER_SQL%"=="13.0" >>%file_sql% echo        left^(format^(t.create_date, '%FMT_DAT2%'^),14^)                          AS 'Datetime'
if "%VER_SQL%"=="14.0" >>%file_sql% echo        left^(format^(t.create_date, '%FMT_DAT2%'^),14^)                          AS 'Datetime'
if not "%VER_SQL%"=="11.0" if not "%VER_SQL%"=="12.0" if not "%VER_SQL%"=="13.0" if not "%VER_SQL%"=="14.0" >>%file_sql% echo        left^(convert^(varchar, convert^(datetime, t.create_date, 120^), %CNV_DATE%^)+' '+
if not "%VER_SQL%"=="11.0" if not "%VER_SQL%"=="12.0" if not "%VER_SQL%"=="13.0" if not "%VER_SQL%"=="14.0" >>%file_sql% echo              convert^(varchar, convert^(datetime, t.create_date, 120^), %CNV_DATE%^), 16) AS 'Datetime'
>>%file_sql% echo from tempdb.sys.tables t
>>%file_sql% echo join sys.schemas s on s.schema_id = t.schema_id
>>%file_sql% echo where t.type = 'U'
if (%FLG_DBO%)==(0) >>%file_sql% echo and s.name ^<^> 'dbo'
>>%file_sql% echo order by s.name, t.create_date;
>>%file_sql% echo PRINT ''
>>%file_sql% echo:
if not "%VER_SQL%"=="9.0" >>%file_sql% echo PRINT '+-----------------+'
if not "%VER_SQL%"=="9.0" >>%file_sql% echo PRINT '^| Invalid objects ^|'
if not "%VER_SQL%"=="9.0" >>%file_sql% echo PRINT '+-----------------+'
if not "%VER_SQL%"=="9.0" >>%file_sql% echo PRINT ''
if not "%VER_SQL%"=="9.0" >>%file_sql% echo:
if not "%VER_SQL%"=="9.0" >>%file_sql% echo if exists ^(select * from tempdb.sys.all_objects where name like '%%%TMPTAB%%%'^) drop table %TMPTAB%
if not "%VER_SQL%"=="9.0" >>%file_sql% echo go
if not "%VER_SQL%"=="9.0" >>%file_sql% echo PRINT ''
if not "%VER_SQL%"=="9.0" >>%file_sql% echo create table %TMPTAB%^(db_name            varchar^(128^),
if not "%VER_SQL%"=="9.0" >>%file_sql% echo                             object_name_in_ref varchar^(128^),
if not "%VER_SQL%"=="9.0" >>%file_sql% echo                             object_type_in_ref varchar^(128^),
if not "%VER_SQL%"=="9.0" >>%file_sql% echo                             schema_name_in_ref varchar^(128^),
if not "%VER_SQL%"=="9.0" >>%file_sql% echo                             object_not_found   varchar^(128^)^);
if not "%VER_SQL%"=="9.0" >>%file_sql% echo:
if not "%VER_SQL%"=="9.0" if     defined SQL_BDD >>%file_sql% echo exec sp_MSforeachdb @command1='if db_id^(''?''^) ^<= 4 and db_name^(db_id^(''?''^)^) ^<^>''%SQL_BDD%'' return; use [?]; insert %TMPTAB%
if not "%VER_SQL%"=="9.0" if not defined SQL_BDD >>%file_sql% echo exec sp_MSforeachdb @command1='if db_id^(''?''^) ^<= 4 return; use [?]; insert %TMPTAB%
if not "%VER_SQL%"=="9.0" >>%file_sql% echo select ''?'',
if not "%VER_SQL%"=="9.0" >>%file_sql% echo        object_name^(e.referencing_id^)          AS object_name_in_ref,
if not "%VER_SQL%"=="9.0" >>%file_sql% echo        e.referenced_class_desc                AS object_type_in_ref,
if not "%VER_SQL%"=="9.0" >>%file_sql% echo        isnull(e.referenced_schema_name, '''') AS schema_name_in_ref,
if not "%VER_SQL%"=="9.0" >>%file_sql% echo        e.referenced_entity_name               AS object_not_found
if not "%VER_SQL%"=="9.0" >>%file_sql% echo from sys.sql_expression_dependencies e
if not "%VER_SQL%"=="9.0" >>%file_sql% echo left join sys.tables t on e.referenced_entity_name = t.name
if not "%VER_SQL%"=="9.0" >>%file_sql% echo where object_name^(referencing_id^) not like ''sys''
if not "%VER_SQL%"=="9.0" >>%file_sql% echo and   e.referenced_class_desc != ''TYPE''
if not "%VER_SQL%"=="9.0" >>%file_sql% echo and   e.is_ambiguous = 0
if not "%VER_SQL%"=="9.0" >>%file_sql% echo and not exists ^(select object_id from sys.objects where name = e.referenced_entity_name^);';
if not "%VER_SQL%"=="9.0" >>%file_sql% echo:
if not "%VER_SQL%"=="9.0" >>%file_sql% echo select left^(o.db_name, %LEN_DBNAME%^)             AS 'DB Name',
if not "%VER_SQL%"=="9.0" >>%file_sql% echo        left^(o.object_name_in_ref, %LEN_OBJECT%^) AS 'Object in Ref.',
if not "%VER_SQL%"=="9.0" >>%file_sql% echo        left^(o.object_type_in_ref, 30^) AS 'Object type in Ref.',
if not "%VER_SQL%"=="9.0" >>%file_sql% echo        left^(o.schema_name_in_ref, %LEN_LOGIN%^) AS 'Schema name in Ref.',
if not "%VER_SQL%"=="9.0" >>%file_sql% echo        left^(o.object_not_found, %LEN_OBJECT%^)   AS 'Object Not Found'
if not "%VER_SQL%"=="9.0" >>%file_sql% echo from %TMPTAB% o
if not "%VER_SQL%"=="9.0" >>%file_sql% echo where o.schema_name_in_ref ^> ''
if not "%VER_SQL%"=="9.0" if defined SQL_BDD >>%file_sql% echo and   o.db_name = '%SQL_BDD%'
if not "%VER_SQL%"=="9.0" >>%file_sql% echo order by 1, 2;
if not "%VER_SQL%"=="9.0" >>%file_sql% echo if exists ^(select * from tempdb.sys.all_objects where name like '%%%TMPTAB%%%'^) drop table %TMPTAB%
if not "%VER_SQL%"=="9.0" >>%file_sql% echo go
if not "%VER_SQL%"=="9.0" >>%file_sql% echo:
>>%file_sql% echo:
>>%file_sql% echo PRINT ''
>>%file_sql% echo PRINT '+----------------------+'
>>%file_sql% echo PRINT '^| Space used (summary) ^|'
>>%file_sql% echo PRINT '+----------------------+'
>>%file_sql% echo PRINT ''
>>%file_sql% echo:
if     defined SQL_BDD >>%file_sql% echo exec sp_MSforeachdb @command1='if db_id^(''?''^) ^<= 4 or db_name^(db_id^(''?''^)^) ^<^>''%SQL_BDD%'' return; use [?]; print ''*** ? ***''; print ''''
if not defined SQL_BDD >>%file_sql% echo exec sp_MSforeachdb @command1='if db_id^(''?''^) ^<= 4 return; use [?]; print ''*** ? ***''; print ''''
>>%file_sql% echo select left^(schema_name^(so.schema_id^), %LEN_OWNER%^)               AS ''Owner'',
>>%file_sql% echo        cast^(sum^(ps.reserved_page_count^)*8.0/1024 as int^) AS ''  Size ^(MB^)''
>>%file_sql% echo from sys.dm_db_partition_stats ps
>>%file_sql% echo join sys.indexes i  on i.object_id = ps.object_id and i.index_id = ps.index_id
>>%file_sql% echo join sys.objects so on i.object_id = so.object_id
>>%file_sql% echo where so.type = ''U''
if (%FLG_DBO%)==(0) >>%file_sql% echo and schema_id ^> 1
if defined LOGIN >>%file_sql% echo and schema_name^(so.schema_id^) = ''%LOGIN%''    -- Lists only for a login
>>%file_sql% echo group by so.schema_id
>>%file_sql% echo union
>>%file_sql% echo select ''** TOTAL **'', cast^(sum^(ps.reserved_page_count^)*8.0/1024 as int^)
>>%file_sql% echo from sys.dm_db_partition_stats ps
>>%file_sql% echo join sys.indexes i  on i.object_id = ps.object_id and i.index_id = ps.index_id
>>%file_sql% echo join sys.objects so on i.object_id = so.object_id
>>%file_sql% echo where so.type = ''U''
if (%FLG_DBO%)==(0) >>%file_sql% echo and schema_id ^> 1
if defined LOGIN >>%file_sql% echo and schema_name^(so.schema_id^) = ''%LOGIN%''    -- Lists only for a login
>>%file_sql% echo order by 2; print ''''';
>>%file_sql% echo:
>>%file_sql% echo PRINT ''
>>%file_sql% echo PRINT '+---------------------+'
>>%file_sql% echo PRINT '^| Space used (detail) ^|'
>>%file_sql% echo PRINT '+---------------------+'
>>%file_sql% echo PRINT ''
>>%file_sql% echo:
if defined SQL_BDD >>%file_sql% echo PRINT '*** %SQL_BDD% ***'
if defined SQL_BDD >>%file_sql% echo PRINT ''
>>%file_sql% echo select 'Schema Name'=left^(owner, %LEN_OWNER%^),
>>%file_sql% echo 	   'Table Name'=left^(table_name, %LEN_TABLE%^),
>>%file_sql% echo 	   '       Rows'=rows,
>>%file_sql% echo 	   ' Total ^(MB^)'=cast^(total_in_mb as int^),
>>%file_sql% echo 	   '  Total ^(%%^)'=cast^(total_pct as int^),
>>%file_sql% echo 	   ' Table ^(MB^)'=cast^(table_in_mb as int^),
>>%file_sql% echo 	   ' Index ^(MB^)'=cast^(index_in_mb as int^),
>>%file_sql% echo 	   'Unused ^(MB^)'=cast^(unused_in_mb as int^)
>>%file_sql% echo from ^(select owner=schema_name^(so.schema_id^),
>>%file_sql% echo       table_name=so.name,
>>%file_sql% echo       rows=cast^(max^(partition_stats.row_count^) as int^),
>>%file_sql% echo       total_in_mb=cast^(^(max^(calc.reserved_page_count^) * 8^)/1024.0   as dec^(8,1^)^),
>>%file_sql% echo       table_in_mb=cast^(^(max^(partition_stats.page_count^) * 8^)/1024.0 as dec^(8,1^)^),
>>%file_sql% echo       index_in_mb=cast^(^(case when ^(max^(calc.used_page_count^)      ^> max^(partition_stats.page_count^)^) then ^(max^(calc.used_page_count^)     - max^(partition_stats.page_count^)^) else 0 end * 8^)/1024.0 as dec^(8,1^)^),
>>%file_sql% echo       unused_in_mb=cast^(^(case when ^(max^(calc.reserved_page_count^) ^> max^(calc.used_page_count^)^)       then ^(max^(calc.reserved_page_count^) - max^(calc.used_page_count^)^)       else 0 end * 8^)/1024.0 as dec^(8,1^)^),
>>%file_sql% echo       rank^(^) over ^(partition by so.schema_id order by max^(calc.reserved_page_count^) desc^) AS rank,
>>%file_sql% echo       cast^(100. * max^(calc.reserved_page_count^) / sum^(max^(calc.reserved_page_count^)^) over ^(partition by so.schema_id^) as dec^(7,1^)^) AS total_pct
>>%file_sql% echo from sys.objects so
>>%file_sql% echo inner join
>>%file_sql% echo   ^(select 'object_id'           = sddps.object_id,
>>%file_sql% echo           'row_count'           = sum^(case when ^(sddps.index_id ^< 2^) then sddps.row_count else 0 end^),
>>%file_sql% echo           'page_count'          = sum^(case when ^(sddps.index_id ^< 2^) then ^(sddps.in_row_data_page_count + sddps.lob_used_page_count + sddps.row_overflow_used_page_count^) else sddps.lob_used_page_count + sddps.row_overflow_used_page_count end^),
>>%file_sql% echo           'used_page_count'     = sum^(sddps.used_page_count^),
>>%file_sql% echo           'reserved_page_count' = sum^(sddps.reserved_page_count^)
>>%file_sql% echo    from sys.dm_db_partition_stats sddps
>>%file_sql% echo    group by sddps.object_id
>>%file_sql% echo   ^) partition_stats on ^(so.object_id = partition_stats.object_id^)
>>%file_sql% echo left outer join
>>%file_sql% echo   ^(select sit.parent_object_id,
>>%file_sql% echo           'used_page_count' = sum^(sddps2.used_page_count^),
>>%file_sql% echo           'reserved_page_count' = sum^(sddps2.reserved_page_count^)
>>%file_sql% echo    from sys.internal_tables sit
>>%file_sql% echo    inner join	sys.dm_db_partition_stats sddps2 on ^(sit.object_id = sddps2.object_id^)
>>%file_sql% echo    group by sit.parent_object_id
>>%file_sql% echo   ^) summary_data on ^(so.object_id = summary_data.parent_object_id^)
>>%file_sql% echo cross apply
>>%file_sql% echo   ^(select 'reserved_page_count' = ^(partition_stats.reserved_page_count + isnull^(summary_data.reserved_page_count, 0^)^),
>>%file_sql% echo           'used_page_count'     = ^(partition_stats.used_page_count + isnull^(summary_data.used_page_count, 0^)^)
>>%file_sql% echo   ^) calc
>>%file_sql% echo where so.type = 'U'
if defined LOGIN >>%file_sql% echo       and   schema_name^(so.schema_id^) = '%LOGIN%'    -- Lists only for a login
>>%file_sql% echo group by so.schema_id, so.name
>>%file_sql% echo ^) list
>>%file_sql% echo where rank ^< %TOP_NSQL%
if (%FLG_DBO%)==(0) >>%file_sql% echo and   owner ^<^> 'dbo'
>>%file_sql% echo and   total_in_mb ^> 0
>>%file_sql% echo order by owner, total_in_mb desc;
>>%file_sql% echo:
>>%file_sql% echo PRINT ''
>>%file_sql% echo PRINT '+------------------------------+'
>>%file_sql% echo PRINT '^| Most large objects (summary) ^|'
>>%file_sql% echo PRINT '+------------------------------+'
>>%file_sql% echo PRINT ''
>>%file_sql% echo:
if     defined SQL_BDD >>%file_sql% echo exec sp_MSforeachdb @command1='if db_id^(''?''^) ^<= 4 or db_name^(db_id^(''?''^)^) ^<^>''%SQL_BDD%'' return; use [?]; print ''*** ? ***''; print ''''
if not defined SQL_BDD >>%file_sql% echo exec sp_MSforeachdb @command1='if db_id^(''?''^) ^<= 4 return; use [?]; print ''*** ? ***''; print ''''
>>%file_sql% echo select left^(owner, %LEN_OWNER%^)                                                               AS ''Owner'',
>>%file_sql% echo 	   left^(table_name, %LEN_TABLE%^)                                                          AS ''Object Name'',
>>%file_sql% echo 	   right^(replicate^('' '',9-len^(size_mb^)^)+cast^(size_mb as varchar^),9^)             AS ''Size ^(MB^)'',
>>%file_sql% echo 	   cast^(100. * size_mb / sum^(size_mb^) OVER^(partition by owner^) as dec^(4,1^)^)      AS ''Size ^(%%^)'',
>>%file_sql% echo 	   right^(replicate^('' '',9-len^(row_count^)^)+cast^(row_count as varchar^),9^)         AS ''Row Count''
>>%file_sql% echo from ^(select s.name                                                                  AS owner,
>>%file_sql% echo              o.name                                                                  AS table_name,
>>%file_sql% echo              cast^(sum^(ps.used_page_count^) * 8 /1024.0 as dec^(7,1^)^)                   AS size_mb,
>>%file_sql% echo              max^(row_count^)                                                          AS row_count,
>>%file_sql% echo 	         rank^(^) over ^(partition by s.name order by sum^(ps.used_page_count^) desc^) AS rank
>>%file_sql% echo       from sys.partitions p
>>%file_sql% echo       inner join sys.dm_db_partition_stats ps on p.partition_id = ps.partition_id and p.partition_number = ps.partition_number
>>%file_sql% echo       inner join sys.objects o                on ps.object_id   = o.object_id
>>%file_sql% echo       inner join sys.schemas s                on o.schema_id    = s.schema_id
>>%file_sql% echo       inner join sys.indexes i                on i.object_id    = ps.object_id    and i.index_id = ps.index_id
if     defined LOGIN >>%file_sql% echo       where s.name = ''%LOGIN%''    -- Lists only for a login
if not defined LOGIN >>%file_sql% echo       where s.name != ''sys''
>>%file_sql% echo 	  group by s.name, o.name
>>%file_sql% echo 	  having sum^(ps.used_page_count^) * 8 /1024 ^> 0
>>%file_sql% echo      ^) mlo
>>%file_sql% echo where rank ^<= %TOP_NSQL%
>>%file_sql% echo order by 1, 4 desc; print ''''';
>>%file_sql% echo:
>>%file_sql% echo PRINT '+-----------------------------+'
>>%file_sql% echo PRINT '^| Most large objects (detail) ^|'
>>%file_sql% echo PRINT '+-----------------------------+'
>>%file_sql% echo PRINT ''
>>%file_sql% echo:
if     defined SQL_BDD >>%file_sql% echo exec sp_MSforeachdb @command1='if db_id^(''?''^) ^<= 4 or db_name^(db_id^(''?''^)^) ^<^>''%SQL_BDD%'' return; use [?]; print ''*** ? ***''; print ''''
if not defined SQL_BDD >>%file_sql% echo exec sp_MSforeachdb @command1='if db_id^(''?''^) ^<= 4 return; use [?]; print ''*** ? ***''; print ''''
>>%file_sql% echo select left^(owner, %LEN_OWNER%^)      AS ''Owner'',
>>%file_sql% echo 	   left^(table_name, %LEN_TABLE%^) AS ''Table Name'',
>>%file_sql% echo 	   left^(index_name, %LEN_INDEX%^) AS ''Index Name'',
>>%file_sql% echo 	   right^(replicate^('' '',9-len^(size_mb^)^)+cast^(size_mb as varchar^),9^) AS ''Size ^(MB^)'',
>>%file_sql% echo 	   right^(replicate^('' '',9-len^(row_count^)^)+cast^(row_count as varchar^),9^)    AS ''Row Count''
>>%file_sql% echo from ^(select s.name                                                             AS owner,
>>%file_sql% echo              case when i.name is NOT NULL then '''' else o.name end             AS table_name,
>>%file_sql% echo              case when i.name is NULL then '''' else i.name end                 AS index_name,
>>%file_sql% echo              cast^(ps.used_page_count * 8 /1024.0 as dec^(7,1^)^)                   AS size_mb,
>>%file_sql% echo              row_count                                                          AS row_count,
>>%file_sql% echo 	         rank^(^) over ^(partition by s.name order by ps.used_page_count desc^) AS rank
>>%file_sql% echo       from sys.partitions p
>>%file_sql% echo       inner join sys.dm_db_partition_stats ps on p.partition_id = ps.partition_id and p.partition_number = ps.partition_number
>>%file_sql% echo       inner join sys.objects o                on ps.object_id   = o.object_id
>>%file_sql% echo       inner join sys.schemas s                on o.schema_id    = s.schema_id
>>%file_sql% echo       inner join sys.indexes i                on i.object_id    = ps.object_id    and i.index_id = ps.index_id
if     defined LOGIN >>%file_sql% echo       where s.name = ''%LOGIN%''    -- Lists only for a login
if not defined LOGIN >>%file_sql% echo       where s.name != ''sys''
>>%file_sql% echo      ^) mlo
>>%file_sql% echo where rank ^<= %TOP_NSQL%*2
>>%file_sql% echo order by 1, 4 desc; print ''''';
>>%file_sql% echo:
if "%FLG_FRAG%"=="1" >>%file_sql% echo PRINT '+-----------------------------------+'
if "%FLG_FRAG%"=="1" >>%file_sql% echo PRINT '^| Most fragmented indexes (summary) ^|'
if "%FLG_FRAG%"=="1" >>%file_sql% echo PRINT '+-----------------------------------+'
if "%FLG_FRAG%"=="1" >>%file_sql% echo PRINT ''
if "%FLG_FRAG%"=="1" >>%file_sql% echo:
if "%FLG_FRAG%"=="1" if     defined SQL_BDD >>%file_sql% echo exec sp_MSforeachdb @command1='if db_id^(''?''^) ^<= 4 or db_name^(db_id^(''?''^)^) ^<^>''%SQL_BDD%'' return; use [?]; print ''*** ? ***''; print ''''
if "%FLG_FRAG%"=="1" if not defined SQL_BDD >>%file_sql% echo exec sp_MSforeachdb @command1='if db_id^(''?''^) ^<= 4 return; use [?]; print ''*** ? ***''; print ''''
if "%FLG_FRAG%"=="1" >>%file_sql% echo ;with frag as ^(
if "%FLG_FRAG%"=="1" >>%file_sql% echo select s.name, ips.avg_fragmentation_in_percent pct
if "%FLG_FRAG%"=="1" >>%file_sql% echo from sys.dm_db_index_physical_stats^(DB_ID^(^), NULL, NULL, NULL, ''LIMITED''^) ips
if "%FLG_FRAG%"=="1" >>%file_sql% echo join sys.indexes i on i.object_id = ips.object_id and i.index_id  = ips.index_id
if "%FLG_FRAG%"=="1" >>%file_sql% echo join sys.dm_db_partition_stats ps on ps.object_id = i.object_id and ps.index_id = i.index_id
if "%FLG_FRAG%"=="1" >>%file_sql% echo join sys.objects o on o.object_id = ips.object_id
if "%FLG_FRAG%"=="1" >>%file_sql% echo join sys.schemas s on s.schema_id = o.schema_id
if "%FLG_FRAG%"=="1" >>%file_sql% echo and   ips.avg_fragmentation_in_percent ^>= 1
if "%FLG_FRAG%"=="1" >>%file_sql% echo and   ps.used_page_count * 8 /1024 ^>= 10
if "%FLG_FRAG%"=="1" >>%file_sql% echo and   i.name not like ''%%_ROWID''
if "%FLG_FRAG%"=="1" if defined LOGIN >>%file_sql% echo and   s.name = ''%LOGIN%''    -- Lists only for a login
if "%FLG_FRAG%"=="1" >>%file_sql% echo ^)
if "%FLG_FRAG%"=="1" >>%file_sql% echo select left^(name, %LEN_OWNER%^) AS ''Owner'',
if "%FLG_FRAG%"=="1" >>%file_sql% echo cast^(sum^(case when pct ^>=90 then 1 else 0 end^) as tinyint^) AS ''  ^>90%%'',
if "%FLG_FRAG%"=="1" >>%file_sql% echo cast^(sum^(case when pct ^>=80 and pct ^<= 90  then 1 else 0 end^) as tinyint^) AS ''80-90%%'',
if "%FLG_FRAG%"=="1" >>%file_sql% echo cast^(sum^(case when pct ^>=70 and pct ^<= 80  then 1 else 0 end^) as tinyint^) AS ''70-80%%'',
if "%FLG_FRAG%"=="1" >>%file_sql% echo cast^(sum^(case when pct ^>=60 and pct ^<= 70  then 1 else 0 end^) as tinyint^) AS ''60-70%%'',
if "%FLG_FRAG%"=="1" >>%file_sql% echo cast^(sum^(case when pct ^>=50 and pct ^<= 60  then 1 else 0 end^) as tinyint^) AS ''50-60%%'',
if "%FLG_FRAG%"=="1" >>%file_sql% echo cast^(sum^(case when pct ^>=40 and pct ^<= 50  then 1 else 0 end^) as tinyint^) AS ''40-50%%'',
if "%FLG_FRAG%"=="1" >>%file_sql% echo cast^(sum^(case when pct ^>=30 and pct ^<= 40  then 1 else 0 end^) as tinyint^) AS ''30-40%%'',
if "%FLG_FRAG%"=="1" >>%file_sql% echo cast^(sum^(case when pct ^>=20 and pct ^<= 30  then 1 else 0 end^) as tinyint^) AS ''20-30%%'',
if "%FLG_FRAG%"=="1" >>%file_sql% echo cast^(sum^(case when pct ^>=10 and pct ^<= 20  then 1 else 0 end^) as tinyint^) AS ''10-20%%'',
if "%FLG_FRAG%"=="1" >>%file_sql% echo cast^(sum^(case when pct ^< 10 then 1 else 0 end^) as int^) AS ''Low fragmented ^(^<10%%^)'',
if "%FLG_FRAG%"=="1" >>%file_sql% echo cast^(sum^(case when pct ^>=10 and pct ^<= 30  then 1 else 0 end^) as int^) AS ''Total to Reorg ^(10-30%%^)'',
if "%FLG_FRAG%"=="1" >>%file_sql% echo cast^(sum^(case when pct ^>=30 then 1 else 0 end^) as int^) AS ''Total to Rebuild ^(^>30%%^)'',
if "%FLG_FRAG%"=="1" >>%file_sql% echo cast^(sum^(case when pct ^>= 0 then 1 else 0 end^) as int^) AS ''Total index (Size^>=10MB)''
if "%FLG_FRAG%"=="1" >>%file_sql% echo from frag
if "%FLG_FRAG%"=="1" >>%file_sql% echo group by name
if "%FLG_FRAG%"=="1" >>%file_sql% echo order by name; print ''''';
if "%FLG_FRAG%"=="1" >>%file_sql% echo:
if "%FLG_FRAG%"=="1" >>%file_sql% echo PRINT '+----------------------------------+'
if "%FLG_FRAG%"=="1" >>%file_sql% echo PRINT '^| Most fragmented indexes (detail) ^|'
if "%FLG_FRAG%"=="1" >>%file_sql% echo PRINT '+----------------------------------+'
if "%FLG_FRAG%"=="1" >>%file_sql% echo PRINT ''
if "%FLG_FRAG%"=="1" >>%file_sql% echo:
if "%FLG_FRAG%"=="1" if     defined SQL_BDD >>%file_sql% echo exec sp_MSforeachdb @command1='if db_id^(''?''^) ^<= 4 or db_name^(db_id^(''?''^)^) ^<^>''%SQL_BDD%'' return; use [?]; print ''*** ? ***''; print ''''
if "%FLG_FRAG%"=="1" if not defined SQL_BDD >>%file_sql% echo exec sp_MSforeachdb @command1='if db_id^(''?''^) ^<= 4 return; use [?]; print ''*** ? ***''; print ''''
if "%FLG_FRAG%"=="1" >>%file_sql% echo select left^(owner, %LEN_OWNER%^)      AS ''Owner'',
if "%FLG_FRAG%"=="1" >>%file_sql% echo        left^(table_name, %LEN_TABLE%^) AS ''Table Name'',
if "%FLG_FRAG%"=="1" >>%file_sql% echo        left^(index_name, %LEN_INDEX%^) AS ''Index Name'',
if "%FLG_FRAG%"=="1" >>%file_sql% echo        right(replicate('' '',13-len(size_mb))+cast(size_mb as varchar),13)               AS ''Size (^>=10MB)'',
if "%FLG_FRAG%"=="1" >>%file_sql% echo        right^(replicate^('' '',14-len^(fragment_count^)^)+cast^(fragment_count as varchar^),14^) AS ''Fragment Count'',
if "%FLG_FRAG%"=="1" >>%file_sql% echo        cast^(avg_frag as decimal^(4,1^)^)                                                    AS ''Avg ^(%%^)'',
if "%FLG_FRAG%"=="1" >>%file_sql% echo 	   case when avg_frag ^>30 then ''**** INDEX TO REBUILD !! ****''
if "%FLG_FRAG%"=="1" >>%file_sql% echo 		    when avg_frag ^>5  then ''**** INDEX TO REORGANIZE !! ****'' else '''' end    AS ''Diagnostic''
if "%FLG_FRAG%"=="1" >>%file_sql% echo from ^(
if "%FLG_FRAG%"=="1" >>%file_sql% echo select left^(s.name, 10^)                 AS owner,
if "%FLG_FRAG%"=="1" >>%file_sql% echo        left^(object_name^(i.object_id^), 30^) AS table_name,
if "%FLG_FRAG%"=="1" >>%file_sql% echo        left^(i.name, 30^)                   AS index_name,
if "%FLG_FRAG%"=="1" >>%file_sql% echo        ps.used_page_count * 8 /1024       AS size_mb,
if "%FLG_FRAG%"=="1" >>%file_sql% echo        right^(replicate^('' '',14-len^(ips.fragment_count^)^)+cast^(ips.fragment_count as varchar^),14^) AS fragment_count,
if "%FLG_FRAG%"=="1" >>%file_sql% echo        cast^(ips.avg_fragmentation_in_percent as decimal^(4,1^)^)                                    AS avg_frag,
if "%FLG_FRAG%"=="1" >>%file_sql% echo        rank^(^) over ^(partition by s.name order by ips.avg_fragmentation_in_percent desc^)          AS rank
if "%FLG_FRAG%"=="1" >>%file_sql% echo from sys.dm_db_index_physical_stats^(DB_ID^(^), NULL, NULL, NULL, ''LIMITED''^) ips
if "%FLG_FRAG%"=="1" >>%file_sql% echo join sys.indexes i                on i.object_id  = ips.object_id and i.index_id  = ips.index_id
if "%FLG_FRAG%"=="1" >>%file_sql% echo join sys.dm_db_partition_stats ps on ps.object_id = i.object_id and ps.index_id = i.index_id
if "%FLG_FRAG%"=="1" >>%file_sql% echo join sys.objects o                on o.object_id  = ips.object_id
if "%FLG_FRAG%"=="1" >>%file_sql% echo join sys.schemas s                on s.schema_id  = o.schema_id
if "%FLG_FRAG%"=="1" >>%file_sql% echo where ips.index_id ^> 0
if "%FLG_FRAG%"=="1" >>%file_sql% echo and   ips.avg_fragmentation_in_percent ^>= 1
if "%FLG_FRAG%"=="1" >>%file_sql% echo and   ps.used_page_count * 8 /1024 ^>= 10
if "%FLG_FRAG%"=="1" >>%file_sql% echo and   ips.object_id ^> 5
if "%FLG_FRAG%"=="1" >>%file_sql% echo and   i.name not like ''%%_ROWID''
if "%FLG_FRAG%"=="1" if defined LOGIN >>%file_sql% echo       and   s.name = ''%LOGIN%''    -- Lists only for a login
if "%FLG_FRAG%"=="1" >>%file_sql% echo ^) mfi
if "%FLG_FRAG%"=="1" >>%file_sql% echo where rank ^<= %TOP_NSQL%*2
if "%FLG_FRAG%"=="1" >>%file_sql% echo order by 1, 6 desc; print ''''';
if "%FLG_FRAG%"=="1" >>%file_sql% echo:
>>%file_sql% echo PRINT '+-------------------+'
>>%file_sql% echo PRINT '^| Index Fill Factor ^|'
>>%file_sql% echo PRINT '+-------------------+'
>>%file_sql% echo PRINT ''
>>%file_sql% echo:
if     defined SQL_BDD >>%file_sql% echo exec sp_MSforeachdb @command1='if db_id^(''?''^) ^<= 4 or db_name^(db_id^(''?''^)^) ^<^>''%SQL_BDD%'' return; use [?]; print ''*** ? ***''; print ''''
if not defined SQL_BDD >>%file_sql% echo exec sp_MSforeachdb @command1='if db_id^(''?''^) ^<= 4 return; use [?]; print ''*** ? ***''; print ''''
>>%file_sql% echo select left^(s.name, %LEN_OWNER%^)                                                         AS ''Owner'',
>>%file_sql% echo        cast^(case when i.fill_factor = 0 then 100 else i.fill_factor end as int^) AS ''Fill Factor ^(%%^)'',
>>%file_sql% echo        cast^(count^(*^) as int^)                                                    AS ''      Count'' 
>>%file_sql% echo from  sys.indexes i
>>%file_sql% echo join sys.objects o on i.object_id = o.object_id
>>%file_sql% echo join sys.schemas s on o.schema_id = s.schema_id
>>%file_sql% echo where i.name IS NOT NULL
>>%file_sql% echo and   i.name not like ''%%_ROWID''
>>%file_sql% echo and   o.type = ''U''
>>%file_sql% echo and   s.name != ''sys''
if defined LOGIN >>%file_sql% echo       and   s.name = ''%LOGIN%''    -- Lists only for a login
>>%file_sql% echo group by s.name, i.fill_factor
>>%file_sql% echo order by 1, 2 desc; print ''''';
>>%file_sql% echo:
>>%file_sql% echo PRINT '+----------------------------------------+'
>>%file_sql% echo PRINT '^| Indexes with a non default Fill Factor ^|'
>>%file_sql% echo PRINT '+----------------------------------------+'
>>%file_sql% echo PRINT ''
>>%file_sql% echo:
if     defined SQL_BDD >>%file_sql% echo exec sp_MSforeachdb @command1='if db_id^(''?''^) ^<= 4 or db_name^(db_id^(''?''^)^) ^<^>''%SQL_BDD%'' return; use [?]; print ''*** ? ***''; print ''''
if not defined SQL_BDD >>%file_sql% echo exec sp_MSforeachdb @command1='if db_id^(''?''^) ^<= 4 return; use [?]; print ''*** ? ***''; print ''''
>>%file_sql% echo select TOP 100
>>%file_sql% echo        left^(s.name, %LEN_OWNER%^)                                 AS ''Owner'',
>>%file_sql% echo        left^(o.name, %LEN_TABLE%^)                                 AS ''Table name'',
>>%file_sql% echo        left^(i.name, %LEN_INDEX%^)                                 AS ''Index name'',
>>%file_sql% echo        cast^(ps.used_page_count * 8 /1024.0 as dec^(7,1^)^) AS ''  Size ^(MB^)'',
>>%file_sql% echo        cast^(row_count as int^)                           AS ''   Nbr Rows'',
>>%file_sql% echo 	   cast^(i.fill_factor as int^)                       AS ''Fill Factor ^(^<100%%^)'' 
>>%file_sql% echo from  sys.indexes i
>>%file_sql% echo join sys.objects o on i.object_id = o.object_id
>>%file_sql% echo join sys.schemas s on o.schema_id = s.schema_id
>>%file_sql% echo join sys.dm_db_partition_stats ps on ps.object_id = i.object_id and ps.index_id = i.index_id
>>%file_sql% echo where i.name IS NOT NULL
>>%file_sql% echo and   i.name not like ''%%_ROWID''
>>%file_sql% echo and   o.type = ''U''
>>%file_sql% echo and   i.fill_factor not in ^(0, 100^)
>>%file_sql% echo and   s.name != ''sys''
if defined LOGIN >>%file_sql% echo       and   s.name = ''%LOGIN%''    -- Lists only for a login
>>%file_sql% echo order by 1, i.fill_factor desc, ps.used_page_count desc, o.name; print ''''';
>>%file_sql% echo:
>>%file_sql% echo PRINT '+-------------------+'
>>%file_sql% echo PRINT '^| Clustered indexes ^|'
>>%file_sql% echo PRINT '+-------------------+'
>>%file_sql% echo PRINT ''
>>%file_sql% echo:
if     defined SQL_BDD >>%file_sql% echo exec sp_MSforeachdb @command1='if db_id^(''?''^) ^<= 4 or db_name^(db_id^(''?''^)^) ^<^>''%SQL_BDD%'' return; use [?]; print ''*** ? ***''; print ''''
if not defined SQL_BDD >>%file_sql% echo exec sp_MSforeachdb @command1='if db_id^(''?''^) ^<= 4 return; use [?]; print ''*** ? ***''; print ''''
>>%file_sql% echo select left^(s.name, %LEN_OWNER%^) AS ''Schema Name'',
>>%file_sql% echo        left^(o.name, %LEN_TABLE%^) AS ''Table Name'',
>>%file_sql% echo 	     left^(i.name, %LEN_INDEX%^) AS ''Index Name''
>>%file_sql% echo from sys.indexes i
>>%file_sql% echo join sys.objects o on i.object_id = o.object_id
>>%file_sql% echo join sys.schemas s on o.schema_id = s.schema_id
>>%file_sql% echo where i.type = 1 -- Clustered index
>>%file_sql% echo and   o.is_ms_shipped = 0
>>%file_sql% echo and   not exists ^(select * from sys.index_columns ic
>>%file_sql% echo                   inner join sys.columns c on c.object_id = ic.object_id and c.column_id = ic.column_id
>>%file_sql% echo                   where ic.object_id  = i.object_id                      and ic.index_id = i.index_id
>>%file_sql% echo                   and   c.is_identity = 1^)
>>%file_sql% echo order by 1, 2, 3; print ''''';
>>%file_sql% echo:
if "%FLG_PART%"=="1" >>%file_sql% echo Print '+-------------------------------+'
if "%FLG_PART%"=="1" >>%file_sql% echo Print '^| Candidates for partition keys ^|'
if "%FLG_PART%"=="1" >>%file_sql% echo Print '+-------------------------------+'
if "%FLG_PART%"=="1" >>%file_sql% echo Print ''
if "%FLG_PART%"=="1" >>%file_sql% echo:
if "%FLG_PART%"=="1" >>%file_sql% echo declare @SQL1 nvarchar^(max^);
if "%FLG_PART%"=="1" >>%file_sql% echo declare @SQL2 nvarchar^(max^);
if "%FLG_PART%"=="1" >>%file_sql% echo:
if "%FLG_PART%"=="1" >>%file_sql% echo ; with tab as ^(
if "%FLG_PART%"=="1" >>%file_sql% echo select object_schema_name^(p.object_id^) as schema_name,
if "%FLG_PART%"=="1" >>%file_sql% echo        o.name, 
if "%FLG_PART%"=="1" >>%file_sql% echo        o.object_id,
if "%FLG_PART%"=="1" >>%file_sql% echo        cast^(sum^(ps.used_page_count^) * 8 /1024.0 as dec^(7,1^)^) as size_mb,
if "%FLG_PART%"=="1" >>%file_sql% echo        max^(row_count^) as row_count,
if "%FLG_PART%"=="1" >>%file_sql% echo        rank^(^) over ^(partition by object_schema_name^(p.object_id^) order by sum^(ps.used_page_count^) desc^) AS rank
if "%FLG_PART%"=="1" >>%file_sql% echo from sys.partitions p
if "%FLG_PART%"=="1" >>%file_sql% echo inner join sys.dm_db_partition_stats ps on p.partition_id = ps.partition_id and p.partition_number = ps.partition_number
if "%FLG_PART%"=="1" >>%file_sql% echo inner join sys.objects o on ps.object_id = o.object_id
if "%FLG_PART%"=="1" >>%file_sql% echo inner join sys.indexes i on i.object_id = ps.object_id and i.index_id = ps.index_id
if "%FLG_PART%"=="1" >>%file_sql% echo where object_schema_name^(p.object_id^) != 'sys'
if "%FLG_PART%"=="1" if defined LOGIN >>%file_sql% echo and   object_schema_name^(p.object_id^) = ''%LOGIN%''    -- Lists only for a login
if "%FLG_PART%"=="1" >>%file_sql% echo and   row_count ^>= 1000000
if "%FLG_PART%"=="1" >>%file_sql% echo group by object_schema_name^(p.object_id^), o.name, o.object_id^)
if "%FLG_PART%"=="1" >>%file_sql% echo select @SQL1='select usr as ''Schema name'', tab as ''Table name'', col as ''Column name'', num as ''Num distinct'', nbr_idx as ''Indexes'' from ^(' + char^(13^) + char^(10^) +
if "%FLG_PART%"=="1" >>%file_sql% echo        replace^(replace^(stuff^(^(select case when rank^(^) over ^(order by object_schema_name^(c.object_id^), t.name, c.name^) ^<= %TOP_NSQL% then 'select ''' + object_schema_name^(c.object_id^) + ''' AS usr, ''' + t.name + ''' AS tab, ''' + c.name
if "%FLG_PART%"=="1" >>%file_sql% echo                                      + ''' AS col, ''' + cast^(count^(ic.index_id^) as varchar^) + ''' AS nbr_idx, count^(distinct^(' + c.name + '^)^) AS num from '
if "%FLG_PART%"=="1" >>%file_sql% echo                                      + object_schema_name^(c.object_id^) + '.' + t.name + char^(13^) + char^(10^) + 'union ' else '' end 
if "%FLG_PART%"=="1" >>%file_sql% echo                             from tab t
if "%FLG_PART%"=="1" >>%file_sql% echo                             join sys.columns c on c.object_id = t.object_id
if "%FLG_PART%"=="1" >>%file_sql% echo 							join sys.index_columns ic on ic.object_id = c.object_id and ic.column_id = c.column_id 
if "%FLG_PART%"=="1" >>%file_sql% echo                             where  c.name not in ^('ROWID', 'CREDAT_0', 'CREDATTIM_0', 'CREUSR_0', 'UPDDAT_0', 'UPDUSR_0', 'UPDDATTIM_0', 'UPDTICK_0'^)
if "%FLG_PART%"=="1" >>%file_sql% echo 							and c.name not like '%%FLG%%'
if "%FLG_PART%"=="1" >>%file_sql% echo 							and not exists ^(select c1.name from sys.columns c1
if "%FLG_PART%"=="1" >>%file_sql% echo                                             where object_schema_name^(c1.object_id^) = object_schema_name^(c.object_id^)
if "%FLG_PART%"=="1" >>%file_sql% echo 			                                and   object_name^(c1.object_id^) = object_name^(c.object_id^)
if "%FLG_PART%"=="1" >>%file_sql% echo 		                                    and   c1.name != c.name
if "%FLG_PART%"=="1" >>%file_sql% echo 			                                and c1.name like '%%' + left^(c.name, len^(c.name^)-2^) + '%%'^)
if "%FLG_PART%"=="1" >>%file_sql% echo 							and exists ^(select c2.name, 100*count^(i.name^)/max^(ni.qte^) pct
if "%FLG_PART%"=="1" >>%file_sql% echo                                         from sys.columns c2
if "%FLG_PART%"=="1" >>%file_sql% echo                                         join sys.index_columns ic on ic.object_id = c2.object_id and ic.column_id = c2.column_id
if "%FLG_PART%"=="1" >>%file_sql% echo                                         join sys.indexes i on i.object_id = ic.object_id and i.index_id = ic.index_id
if "%FLG_PART%"=="1" >>%file_sql% echo                                         join ^(select i.object_id, count^(i.index_id^) qte
if "%FLG_PART%"=="1" >>%file_sql% echo                                               from sys.indexes i
if "%FLG_PART%"=="1" >>%file_sql% echo                                               where i.index_id ^>= 3
if "%FLG_PART%"=="1" >>%file_sql% echo                                               group by i.object_id^) ni on ni.object_id = i.object_id
if "%FLG_PART%"=="1" >>%file_sql% echo                                         where c2.object_id = c.object_id
if "%FLG_PART%"=="1" >>%file_sql% echo 										and   c2.column_id = c.column_id
if "%FLG_PART%"=="1" >>%file_sql% echo                                         and i.index_id ^>= 3
if "%FLG_PART%"=="1" >>%file_sql% echo                                         group by c2.object_id, c2.name
if "%FLG_PART%"=="1" >>%file_sql% echo 										having 100*count^(i.name^)/max^(ni.qte^) ^>= 50^)
if "%FLG_PART%"=="1" >>%file_sql% echo 							group by c.object_id, c.name, t.name
if "%FLG_PART%"=="1" >>%file_sql% echo 							for xml path^(''^)^), 1, 0, ''^) + '^)', '^&#x0D;', ''^), 'union ^)', '^)'^)
if "%FLG_PART%"=="1" >>%file_sql% echo 							+ ' list where num between 5 and 50;'
if "%FLG_PART%"=="1" >>%file_sql% echo:
if "%FLG_PART%"=="1" >>%file_sql% echo ; with tab as ^(
if "%FLG_PART%"=="1" >>%file_sql% echo select object_schema_name^(p.object_id^) as schema_name,
if "%FLG_PART%"=="1" >>%file_sql% echo        o.name, 
if "%FLG_PART%"=="1" >>%file_sql% echo        o.object_id,
if "%FLG_PART%"=="1" >>%file_sql% echo        cast^(sum^(ps.used_page_count^) * 8 /1024.0 as dec^(7,1^)^) as size_mb,
if "%FLG_PART%"=="1" >>%file_sql% echo        max^(row_count^) as row_count,
if "%FLG_PART%"=="1" >>%file_sql% echo        rank^(^) over ^(partition by object_schema_name^(p.object_id^) order by sum^(ps.used_page_count^) desc^) AS rank
if "%FLG_PART%"=="1" >>%file_sql% echo from sys.partitions p
if "%FLG_PART%"=="1" >>%file_sql% echo inner join sys.dm_db_partition_stats ps on p.partition_id = ps.partition_id and p.partition_number = ps.partition_number
if "%FLG_PART%"=="1" >>%file_sql% echo inner join sys.objects o on ps.object_id = o.object_id
if "%FLG_PART%"=="1" >>%file_sql% echo inner join sys.indexes i on i.object_id = ps.object_id and i.index_id = ps.index_id
if "%FLG_PART%"=="1" >>%file_sql% echo where object_schema_name^(p.object_id^) != 'sys'
if "%FLG_PART%"=="1" if defined LOGIN >>%file_sql% echo and   object_schema_name^(p.object_id^) = ''%LOGIN%''    -- Lists only for a login
if "%FLG_PART%"=="1" >>%file_sql% echo and   row_count ^>= 1000000
if "%FLG_PART%"=="1" >>%file_sql% echo group by object_schema_name^(p.object_id^), o.name, o.object_id^)
if "%FLG_PART%"=="1" >>%file_sql% echo select @SQL2='select usr as ''Schema name'', tab as ''Table name'', col as ''Column name'', num as ''Num distinct'', nbr_idx as ''Indexes'' from ^(' + char^(13^) + char^(10^) +
if "%FLG_PART%"=="1" >>%file_sql% echo        replace^(replace^(stuff^(^(select case when rank^(^) over ^(order by object_schema_name^(c.object_id^), t.name, c.name^) ^> %TOP_NSQL% then 'select ''' + object_schema_name^(c.object_id^) + ''' AS usr, ''' + t.name + ''' AS tab, ''' + c.name
if "%FLG_PART%"=="1" >>%file_sql% echo                                      + ''' AS col, ''' + cast^(count^(ic.index_id^) as varchar^) + ''' AS nbr_idx, count^(distinct^(' + c.name + '^)^) AS num from '
if "%FLG_PART%"=="1" >>%file_sql% echo                                      + object_schema_name^(c.object_id^) + '.' + t.name + char^(13^) + char^(10^) + 'union ' else '' end 
if "%FLG_PART%"=="1" >>%file_sql% echo                             from tab t
if "%FLG_PART%"=="1" >>%file_sql% echo                             join sys.columns c on c.object_id = t.object_id
if "%FLG_PART%"=="1" >>%file_sql% echo 							join sys.index_columns ic on ic.object_id = c.object_id and ic.column_id = c.column_id 
if "%FLG_PART%"=="1" >>%file_sql% echo                             where  c.name not in ^('ROWID', 'CREDAT_0', 'CREDATTIM_0', 'CREUSR_0', 'UPDDAT_0', 'UPDUSR_0', 'UPDDATTIM_0', 'UPDTICK_0'^)
if "%FLG_PART%"=="1" >>%file_sql% echo 							and c.name not like '%%FLG%%'
if "%FLG_PART%"=="1" >>%file_sql% echo 							and not exists ^(select c1.name from sys.columns c1
if "%FLG_PART%"=="1" >>%file_sql% echo                                             where object_schema_name^(c1.object_id^) = object_schema_name^(c.object_id^)
if "%FLG_PART%"=="1" >>%file_sql% echo 			                                and   object_name^(c1.object_id^) = object_name^(c.object_id^)
if "%FLG_PART%"=="1" >>%file_sql% echo 		                                    and   c1.name != c.name
if "%FLG_PART%"=="1" >>%file_sql% echo 			                                and c1.name like '%%' + left^(c.name, len^(c.name^)-2^) + '%%'^)
if "%FLG_PART%"=="1" >>%file_sql% echo 							and exists ^(select c2.name, 100*count^(i.name^)/max^(ni.qte^) pct
if "%FLG_PART%"=="1" >>%file_sql% echo                                         from sys.columns c2
if "%FLG_PART%"=="1" >>%file_sql% echo                                         join sys.index_columns ic on ic.object_id = c2.object_id and ic.column_id = c2.column_id
if "%FLG_PART%"=="1" >>%file_sql% echo                                         join sys.indexes i on i.object_id = ic.object_id and i.index_id = ic.index_id
if "%FLG_PART%"=="1" >>%file_sql% echo                                         join ^(select i.object_id, count^(i.index_id^) qte
if "%FLG_PART%"=="1" >>%file_sql% echo                                               from sys.indexes i
if "%FLG_PART%"=="1" >>%file_sql% echo                                               where i.index_id ^>= 3
if "%FLG_PART%"=="1" >>%file_sql% echo                                               group by i.object_id^) ni on ni.object_id = i.object_id
if "%FLG_PART%"=="1" >>%file_sql% echo                                         where c2.object_id = c.object_id
if "%FLG_PART%"=="1" >>%file_sql% echo 										and   c2.column_id = c.column_id
if "%FLG_PART%"=="1" >>%file_sql% echo                                         and i.index_id ^>= 3
if "%FLG_PART%"=="1" >>%file_sql% echo                                         group by c2.object_id, c2.name
if "%FLG_PART%"=="1" >>%file_sql% echo 										having 100*count^(i.name^)/max^(ni.qte^) ^>= 50^)
if "%FLG_PART%"=="1" >>%file_sql% echo 							group by c.object_id, c.name, t.name
if "%FLG_PART%"=="1" >>%file_sql% echo 							for xml path^(''^)^), 1, 0, ''^) + '^)', '^&#x0D;', ''^), 'union ^)', '^)'^)
if "%FLG_PART%"=="1" >>%file_sql% echo 							+ ' list where num between 5 and 50;'
if "%FLG_PART%"=="1" >>%file_sql% echo:
if "%FLG_PART%"=="1" >>%file_sql% echo exec sp_executesql @SQL1
if "%FLG_PART%"=="1" >>%file_sql% echo exec sp_executesql @SQL2
if "%FLG_PART%"=="1" >>%file_sql% echo:
>>%file_sql% echo PRINT ''
>>%file_sql% echo PRINT '+--------------------------------+'
>>%file_sql% echo PRINT '^| Partitioned tables and indexes ^|'
>>%file_sql% echo PRINT '+--------------------------------+'
>>%file_sql% echo PRINT ''
>>%file_sql% echo:
>>%file_sql% echo select left^(case when p.partition_number = 1 then s.name else '' end, %LEN_OWNER%^)                     AS 'Schema',
>>%file_sql% echo        left^(case when p.partition_number = 1 then t.name else '' end, %LEN_TABLE%^)                    AS 'Table name',
>>%file_sql% echo        left^(case when p.partition_number = 1 then i.name else '' end, %LEN_INDEX%^)                    AS 'Index name',
>>%file_sql% echo        case when p.partition_number = 1 then case when pf.name is null
>>%file_sql% echo 	                                         then 'No' else 'Yes' end else '' end            AS 'Is partitioned',
>>%file_sql% echo        left^(case when p.partition_number = 1 then ps.name else '' end, 20^)                   AS 'Partition schema',
>>%file_sql% echo        left^(case when p.partition_number = 1 then pf.name else '' end, 20^)                   AS 'Partition function',
>>%file_sql% echo        left^(case when p.partition_number = 1 then                          
>>%file_sql% echo             case when pf.boundary_value_on_right = 1                       
>>%file_sql% echo                  then 'Right' else 'Left' end else '' end, 11^)                               AS 'Range',
>>%file_sql% echo        left^(case when p.partition_number = 1 then replace^(c.name, '_0', ''^) else '' end, 15^) AS 'Partition Key',      
>>%file_sql% echo        left^(case when max^(tp.name^) = 'datetime'
>>%file_sql% echo 	        then isnull^(convert^(varchar, convert^(datetime, r.value, 120^), 3^), ' '^)
>>%file_sql% echo 	        else cast^(isnull^(r.value, ' '^) as varchar^) end, 10^)                              AS 'Value',
>>%file_sql% echo        cast^(p.rows as int^)                                                                   AS '       Rows',
>>%file_sql% echo        cast^(max^(st.in_row_reserved_page_count^) * 8/1024. as dec^(7,1^)^)                        AS 'Size ^(MB^)',
>>%file_sql% echo        left^(case when data_compression_desc = 'NONE' 
>>%file_sql% echo 	             then '' else p.data_compression_desc end, 4^) AS 'Compression type',
>>%file_sql% echo        left^(max^(fg.name^), %LEN_FGNAME%^)                                                                AS 'Filegroup',
>>%file_sql% echo        left^(max^(f.physical_name^), %LEN_DBFILE%^)                                                        AS 'File name'                               
>>%file_sql% echo from sys.tables t                          
>>%file_sql% echo join sys.schemas s                           on s.schema_id         = t.schema_id
>>%file_sql% echo join sys.partitions p                        on p.object_id         = t.object_id
>>%file_sql% echo join sys.indexes i                           on i.object_id         = p.object_id and
>>%file_sql% echo                                                 i.index_id          = p.index_id
>>%file_sql% echo join sys.index_columns ic                    on ic.index_id         = i.index_id and 
>>%file_sql% echo                                                 ic.object_id        = i.object_id and ic.partition_ordinal ^> 0
>>%file_sql% echo join sys.data_spaces ds                      on ds.data_space_id    = i.data_space_id
>>%file_sql% echo join sys.dm_db_partition_stats st            on st.object_id        = p.object_id and
>>%file_sql% echo                                                 st.index_id         = p.index_id  and
>>%file_sql% echo                                                 st.index_id         = p.index_id  and
>>%file_sql% echo                                                 st.partition_id     = p.partition_id and
>>%file_sql% echo                                                 st.partition_number = p.partition_number
>>%file_sql% echo join sys.columns c                           on c.object_id         = st.object_id and
>>%file_sql% echo                                                 c.column_id         = ic.column_id
>>%file_sql% echo join sys.types tp                            on tp.user_type_id     = c.user_type_id
>>%file_sql% echo join sys.allocation_units au                 on au.container_id     = p.hobt_id and au.type_desc = 'IN_ROW_DATA'
>>%file_sql% echo join sys.filegroups fg                       on fg.data_space_id    = au.data_space_id
>>%file_sql% echo join sys.database_files f                    on f.data_space_id     = au.data_space_id
>>%file_sql% echo left outer join sys.partition_schemes ps     on ds.data_space_id    = ps.data_space_id
>>%file_sql% echo left outer join sys.partition_functions pf   on ps.function_id      = pf.function_id
>>%file_sql% echo left outer join sys.partition_range_values r on r.function_id       = pf.function_id and
>>%file_sql% echo                                                 r.boundary_id       = p.partition_number
>>%file_sql% echo where i.name ^> ' '
if defined LOGIN >>%file_sql% echo where s.name = '%LOGIN%'
>>%file_sql% echo group by s.name, t.name, i.name, p.partition_number, i.type_desc, ps.name, pf.name,
>>%file_sql% echo          c.name, pf.boundary_value_on_right, r.value, p.rows, p.data_compression_desc
>>%file_sql% echo order by s.name, t.name, i.name, p.partition_number;
>>%file_sql% echo:
>>%file_sql% echo PRINT ''
>>%file_sql% echo PRINT '+-------------------+'
>>%file_sql% echo PRINT '^| Top usage objects ^|'
>>%file_sql% echo PRINT '+-------------------+'
>>%file_sql% echo PRINT ''
>>%file_sql% echo:
>>%file_sql% echo if exists ^(select * from tempdb.sys.all_objects where name like '%%%TMPTAB%%%'^) drop table %TMPTAB%
>>%file_sql% echo go
>>%file_sql% echo create table %TMPTAB%^(db_name      varchar^(128^),
>>%file_sql% echo                             owner        varchar^(128^),
>>%file_sql% echo                             table_name   varchar^(128^),
>>%file_sql% echo                             index_name   varchar^(128^),
>>%file_sql% echo                             is_clustered varchar^(3^),
>>%file_sql% echo                             is_uk        varchar^(3^),
>>%file_sql% echo                             is_pk        varchar^(3^),
>>%file_sql% echo                             seeks        int,
>>%file_sql% echo                             scans        int,
>>%file_sql% echo                             lookups      int,
>>%file_sql% echo                             updates      int^);
>>%file_sql% echo:
if     defined SQL_BDD >>%file_sql% echo exec sp_MSforeachdb @command1='if db_id^(''?''^) ^<= 4 or db_name^(db_id^(''?''^)^) ^<^>''%SQL_BDD%'' return; use [?]; insert %TMPTAB%
if not defined SQL_BDD >>%file_sql% echo exec sp_MSforeachdb @command1='if db_id^(''?''^) ^<= 4 return; use [?]; insert %TMPTAB%
>>%file_sql% echo select TOP %TOP_NSQL% ''?''                                                               AS dbname,
>>%file_sql% echo        schema_name^(t.schema_id^)                                                   AS owner,
>>%file_sql% echo        object_name^(s.object_id^)                                                   AS table_name,
>>%file_sql% echo        case when i.name is NULL              then ''''    else i.name         end AS index_name,
>>%file_sql% echo        case when i.type_desc = ''CLUSTERED'' then ''yes'' else ''''           end AS is_cluster,
>>%file_sql% echo        case when i.is_unique = 1             then ''Yes'' else ''''           end AS is_uk,
>>%file_sql% echo        case when i.is_primary_key = 1        then ''Yes'' else ''''           end AS is_pk,
>>%file_sql% echo        case when s.user_seeks   = 0          then ''''    else s.user_seeks   end AS seeks,
>>%file_sql% echo        case when s.user_scans   = 0          then ''''    else s.user_scans   end AS scans,
>>%file_sql% echo        case when s.user_lookups = 0          then ''''    else s.user_lookups end AS lookups,
>>%file_sql% echo        case when s.user_updates = 0          then ''''    else s.user_updates end AS updates
>>%file_sql% echo from sys.dm_db_index_usage_stats s
>>%file_sql% echo join sys.indexes i on s.object_id = i.object_id and s.index_id = i.index_id
>>%file_sql% echo join sys.tables t  on i.object_id = t.object_id
>>%file_sql% echo where database_id = db_id^(^)';
>>%file_sql% echo:
>>%file_sql% echo PRINT ''
>>%file_sql% echo PRINT '*** Ordered by Seeks ***'
>>%file_sql% echo PRINT ''
>>%file_sql% echo select TOP %TOP_NSQL% left^(o.db_name, %LEN_DBNAME%^)                                           AS 'DB Name',
>>%file_sql% echo        left^(o.owner, %LEN_OWNER%^)                                                   AS 'Owner',
>>%file_sql% echo        left^(o.table_name, %LEN_TABLE%^)                                              AS 'Table name',
>>%file_sql% echo        left^(o.index_name, %LEN_INDEX%^)                                              AS 'Index name',
>>%file_sql% echo        left^(o.is_clustered, 12^)                                            AS 'Is Clustered Index',
>>%file_sql% echo        left^(o.is_uk, 10^)                                                   AS 'Is Unique key',
>>%file_sql% echo        left^(o.is_pk, 10^)                                                   AS 'Is Primary key',
>>%file_sql% echo        right^(replicate^(' ',9-len^(o.seeks^)^)+cast^(o.seeks as varchar^),8^)     AS '   Seeks',
>>%file_sql% echo        right^(replicate^(' ',9-len^(o.scans^)^)+cast^(o.scans as varchar^),8^)     AS '   Scans',
>>%file_sql% echo        right^(replicate^(' ',9-len^(o.lookups^)^)+cast^(o.lookups as varchar^),8^) AS ' Lookups',
>>%file_sql% echo        right^(replicate^(' ',9-len^(o.updates^)^)+cast^(o.updates as varchar^),8^) AS ' Updates'
>>%file_sql% echo from %TMPTAB% o
>>%file_sql% echo where o.seeks ^>0
>>%file_sql% echo order by o.seeks desc, 1, 2;
>>%file_sql% echo:
>>%file_sql% echo PRINT ''
>>%file_sql% echo PRINT '*** Ordered by Scans ***'
>>%file_sql% echo PRINT ''
>>%file_sql% echo select TOP %TOP_NSQL% left^(o.db_name, %LEN_DBNAME%^)                                           AS 'DB Name',
>>%file_sql% echo        left^(o.owner, %LEN_OWNER%^)                                                   AS 'Owner',
>>%file_sql% echo        left^(o.table_name, %LEN_TABLE%^)                                              AS 'Table name',
>>%file_sql% echo        left^(o.index_name, %LEN_INDEX%^)                                              AS 'Index name',
>>%file_sql% echo        left^(o.is_clustered, 12^)                                            AS 'Is Clustered Index',
>>%file_sql% echo        left^(o.is_uk, 10^)                                                   AS 'Is Unique key',
>>%file_sql% echo        left^(o.is_pk, 10^)                                                   AS 'Is Primary key',
>>%file_sql% echo        right^(replicate^(' ',9-len^(o.seeks^)^)+cast^(o.seeks as varchar^),8^)     AS '  Seeks',
>>%file_sql% echo        right^(replicate^(' ',9-len^(o.scans^)^)+cast^(o.scans as varchar^),8^)     AS '  Scans',
>>%file_sql% echo        right^(replicate^(' ',9-len^(o.lookups^)^)+cast^(o.lookups as varchar^),8^) AS 'Lookups',
>>%file_sql% echo        right^(replicate^(' ',9-len^(o.updates^)^)+cast^(o.updates as varchar^),8^) AS 'Updates'
>>%file_sql% echo from %TMPTAB% o
>>%file_sql% echo where o.scans ^>0
>>%file_sql% echo order by o.scans desc, 1, 2;
>>%file_sql% echo:
>>%file_sql% echo PRINT ''
>>%file_sql% echo PRINT '*** Ordered by Lookup ***'
>>%file_sql% echo PRINT ''
>>%file_sql% echo select TOP %TOP_NSQL% left^(o.db_name, %LEN_DBNAME%^)                                           AS 'DB Name',
>>%file_sql% echo        left^(o.owner, %LEN_OWNER%^)                                                   AS 'Owner',
>>%file_sql% echo        left^(o.table_name, %LEN_TABLE%^)                                              AS 'Table name',
>>%file_sql% echo        left^(o.index_name, %LEN_INDEX%^)                                              AS 'Index name',
>>%file_sql% echo        left^(o.is_clustered, 12^)                                            AS 'Is Clustered Index',
>>%file_sql% echo        left^(o.is_uk, 10^)                                                   AS 'Is Unique key',
>>%file_sql% echo        left^(o.is_pk, 10^)                                                   AS 'Is Primary key',
>>%file_sql% echo        right^(replicate^(' ',9-len^(o.seeks^)^)+cast^(o.seeks as varchar^),8^)     AS '  Seeks',
>>%file_sql% echo        right^(replicate^(' ',9-len^(o.scans^)^)+cast^(o.scans as varchar^),8^)     AS '  Scans',
>>%file_sql% echo        right^(replicate^(' ',9-len^(o.lookups^)^)+cast^(o.lookups as varchar^),8^) AS 'Lookups',
>>%file_sql% echo        right^(replicate^(' ',9-len^(o.updates^)^)+cast^(o.updates as varchar^),8^) AS 'Updates'
>>%file_sql% echo from %TMPTAB% o
>>%file_sql% echo where o.lookups ^>0
>>%file_sql% echo order by o.lookups desc, 1, 2;
>>%file_sql% echo:
>>%file_sql% echo PRINT ''
>>%file_sql% echo PRINT '*** Ordered by Updates ***'
>>%file_sql% echo PRINT ''
>>%file_sql% echo select TOP %TOP_NSQL% left^(o.db_name, %LEN_DBNAME%^)                                           AS 'DB Name',
>>%file_sql% echo        left^(o.owner, %LEN_OWNER%^)                                                   AS 'Owner',
>>%file_sql% echo        left^(o.table_name, %LEN_TABLE%^)                                              AS 'Table name',
>>%file_sql% echo        left^(o.index_name, %LEN_INDEX%^)                                              AS 'Index name',
>>%file_sql% echo        left^(o.is_clustered, 12^)                                            AS 'Is Clustered Index',
>>%file_sql% echo        left^(o.is_uk, 10^)                                                   AS 'Is Unique key',
>>%file_sql% echo        left^(o.is_pk, 10^)                                                   AS 'Is Primary key',
>>%file_sql% echo        right^(replicate^(' ',9-len^(o.seeks^)^)+cast^(o.seeks as varchar^),8^)     AS '  Seeks',
>>%file_sql% echo        right^(replicate^(' ',9-len^(o.scans^)^)+cast^(o.scans as varchar^),8^)     AS '  Scans',
>>%file_sql% echo        right^(replicate^(' ',9-len^(o.lookups^)^)+cast^(o.lookups as varchar^),8^) AS 'Lookups',
>>%file_sql% echo        right^(replicate^(' ',9-len^(o.updates^)^)+cast^(o.updates as varchar^),8^) AS 'Updates'
>>%file_sql% echo from %TMPTAB% o
>>%file_sql% echo where o.updates ^>0
>>%file_sql% echo order by o.updates desc, 1, 2;
>>%file_sql% echo:
>>%file_sql% echo if exists ^(select * from tempdb.sys.all_objects where name like '%%%TMPTAB%%%'^) drop table %TMPTAB%
>>%file_sql% echo go
>>%file_sql% echo:
>>%file_sql% echo PRINT ''
>>%file_sql% echo PRINT '+----------------+'
>>%file_sql% echo PRINT '^| Unused indexes ^|'
>>%file_sql% echo PRINT '+----------------+'
>>%file_sql% echo PRINT ''
>>%file_sql% echo:
if "%VER_SQL%"=="9.0"  >>%file_sql% echo select left(convert(varchar, convert(datetime, s.login_time, 120), 3), 8) from master..sysprocesses s where s.spid = 1;
if "%VER_SQL%"=="10.0" >>%file_sql% echo select 'Last SQL startup'=left^(convert^(varchar, sqlserver_start_time, %CNV_DATE%^)+' '+
if "%VER_SQL%"=="10.0" >>%file_sql% echo        convert^(varchar, sqlserver_start_time, %CNV_TIME%^),14^) from sys.dm_os_sys_info;
if "%VER_SQL%"=="10.5" >>%file_sql% echo select 'Last SQL startup'=left^(convert^(varchar, sqlserver_start_time, %CNV_DATE%^)+' '+
if "%VER_SQL%"=="10.5" >>%file_sql% echo        convert^(varchar, sqlserver_start_time, %CNV_TIME%^),14^) from sys.dm_os_sys_info;
if "%VER_SQL%"=="11.0" >>%file_sql% echo select 'Last SQL startup'=left(format(sqlserver_start_time, '%FMT_DAT2%'),14) from sys.dm_os_sys_info;
if "%VER_SQL%"=="12.0" >>%file_sql% echo select 'Last SQL startup'=left(format(sqlserver_start_time, '%FMT_DAT2%'),14) from sys.dm_os_sys_info;
if "%VER_SQL%"=="13.0" >>%file_sql% echo select 'Last SQL startup'=left(format(sqlserver_start_time, '%FMT_DAT2%'),14) from sys.dm_os_sys_info;
if "%VER_SQL%"=="14.0" >>%file_sql% echo select 'Last SQL startup'=left(format(sqlserver_start_time, '%FMT_DAT2%'),14) from sys.dm_os_sys_info;
>>%file_sql% echo if exists ^(select * from tempdb.sys.all_objects where name like '%%%TMPTAB%%%'^) drop table %TMPTAB%
>>%file_sql% echo go
>>%file_sql% echo create table %TMPTAB%^(db_name      varchar^(128^),
>>%file_sql% echo                             owner        varchar^(128^),
>>%file_sql% echo                             table_name   varchar^(128^),
>>%file_sql% echo                             index_name   varchar^(128^),
>>%file_sql% echo                             is_clustered varchar^(3^),
>>%file_sql% echo                             is_uk        varchar^(3^),
>>%file_sql% echo                             is_pk        varchar^(3^),
>>%file_sql% echo                             size_in_mb   decimal^(7,1^)^);
if     defined SQL_BDD >>%file_sql% echo exec sp_MSforeachdb @command1='if db_id^(''?''^) ^<= 4 or db_name^(db_id^(''?''^)^) ^<^>''%SQL_BDD%'' return; use [?]; insert %TMPTAB%
if not defined SQL_BDD >>%file_sql% echo exec sp_MSforeachdb @command1='if db_id^(''?''^) ^<= 4 return; use [?]; insert %TMPTAB%
>>%file_sql% echo select max^(''?''^)                                                       as db_name,
>>%file_sql% echo        schema_name^(t.schema_id^)                                         as owner,
>>%file_sql% echo        object_name^(s.object_id^)                                         as table_name,
>>%file_sql% echo        i.name                                                           as index_name,
>>%file_sql% echo        case when i.type_desc = ''CLUSTERED'' then ''Yes'' else '''' end as is_clustered,
>>%file_sql% echo        case when i.is_unique = 1 then ''Yes'' else '''' end             as is_uk,
>>%file_sql% echo        case when i.is_primary_key = 1 then ''Yes'' else '''' end        as is_pk,
>>%file_sql% echo        sum^(st.used_page_count^)*8/1024.0                                 as size_in_mb
>>%file_sql% echo from sys.dm_db_index_usage_stats s
>>%file_sql% echo join sys.indexes i                on  i.object_id = s.object_id and  i.index_id = s.index_id
>>%file_sql% echo join sys.dm_db_partition_stats st on st.object_id = i.object_id and st.index_id = i.index_id
>>%file_sql% echo join sys.tables t                 on  t.object_id = i.object_id
>>%file_sql% echo --and object_name^(s.object_id^) ^>= ''X''
>>%file_sql% echo and i.name not like ''%%_ROWID''
>>%file_sql% echo and s.user_seeks   = 0
>>%file_sql% echo and s.user_scans   = 0
>>%file_sql% echo and s.user_lookups = 0
>>%file_sql% echo group by t.schema_id, s.object_id, i.name, i.type_desc, i.is_unique, i.is_primary_key
>>%file_sql% echo having sum^(st.used_page_count^)*8/1024.0 ^>= 10
>>%file_sql% echo order by 6 desc, 1, 2;';
>>%file_sql% echo:
>>%file_sql% echo PRINT ''
>>%file_sql% echo select left^(o.db_name, %LEN_DBNAME%^)                 AS 'DB Name',
>>%file_sql% echo        left^(o.owner, %LEN_OWNER%^)                  AS 'Owner',
>>%file_sql% echo        left^(o.table_name, %LEN_TABLE%^)             AS 'Table name',
>>%file_sql% echo        left^(o.index_name, %LEN_INDEX%^)             AS 'Index name',
>>%file_sql% echo        left^(o.is_clustered, 12^)           AS 'Is Clustered',
>>%file_sql% echo        left^(o.is_uk, 13^)                  AS 'Is Unique key',
>>%file_sql% echo        left^(o.is_pk, 14^)                  AS 'Is Primary key',
>>%file_sql% echo        cast^(o.size_in_mb as decimal^(7,1^)^) AS 'Size ^(^>=10MB^)'
>>%file_sql% echo from %TMPTAB% o
>>%file_sql% echo order by 1, 2, 8 desc, 3;
>>%file_sql% echo if exists ^(select * from tempdb.sys.all_objects where name like '%%%TMPTAB%%%'^) drop table %TMPTAB%
>>%file_sql% echo go
if "%VER_SQL%"=="14.0" >>%file_sql% echo:
if "%VER_SQL%"=="14.0" >>%file_sql% echo PRINT ''
if "%VER_SQL%"=="14.0" >>%file_sql% echo PRINT '+--------------------------+'
if "%VER_SQL%"=="14.0" >>%file_sql% echo PRINT '^| Resumable online indexes ^|'
if "%VER_SQL%"=="14.0" >>%file_sql% echo PRINT '+--------------------------+'
if "%VER_SQL%"=="14.0" >>%file_sql% echo PRINT ''
if "%VER_SQL%"=="14.0" >>%file_sql% echo:
if "%VER_SQL%"=="14.0" >>%file_sql% echo select left^(r.name, %LEN_INDEX%^)                                                    AS 'Index name',
if "%VER_SQL%"=="14.0" >>%file_sql% echo 	cast^(r.percent_complete as dec^(4,1^)^)                                   AS 'Completed ^(%%^)' , 
if "%VER_SQL%"=="14.0" >>%file_sql% echo 	left^(r.state_desc, 7^)                                                  AS 'Status', 
if "%VER_SQL%"=="14.0" >>%file_sql% echo 	left^(format^(r.start_time, '%FMT_DAT3%'^),17^)                     AS 'Start time',
if "%VER_SQL%"=="14.0" >>%file_sql% echo 	left^(format^(r.last_pause_time, '%FMT_DAT3%'^),17^)                AS 'Last pause time',
if "%VER_SQL%"=="14.0" >>%file_sql% echo 	cast^(r.total_execution_time as int^)                                    AS 'Execs',
if "%VER_SQL%"=="14.0" >>%file_sql% echo 	cast^(r.percent_complete as dec^(4,1^)^)                                   AS 'Progress ^(%%^)',
if "%VER_SQL%"=="14.0" >>%file_sql% echo 	cast^(r.total_execution_time as int^)                                    AS 'Duration ^(Min^)',
if "%VER_SQL%"=="14.0" >>%file_sql% echo 	r.total_execution_time * ^(100.0-r.percent_complete^)/r.percent_complete AS 'Left Duration ^(Min^)',
if "%VER_SQL%"=="14.0" >>%file_sql% echo 	cast^(r.last_max_dop_used as int^)                                       AS 'Last MAXDOP',
if "%VER_SQL%"=="14.0" >>%file_sql% echo 	left^(r.sql_text, %LEN_SQLT%^)                                                  AS 'SQL Text'
if "%VER_SQL%"=="14.0" >>%file_sql% echo from sys.index_resumable_operations r;
if "%FLG_COMP%"=="1" >>%file_sql% echo:
if "%FLG_COMP%"=="1" >>%file_sql% echo PRINT '+---------------------------+'
if "%FLG_COMP%"=="1" >>%file_sql% echo PRINT '^| Top Compression estimates ^|'
if "%FLG_COMP%"=="1" >>%file_sql% echo PRINT '+---------------------------+'
if "%FLG_COMP%"=="1" >>%file_sql% echo PRINT ''
if "%FLG_COMP%"=="1" >>%file_sql% echo:
if "%FLG_COMP%"=="1" >>%file_sql% echo declare @schema sysname;
if "%FLG_COMP%"=="1" >>%file_sql% echo declare @rank int;
if "%FLG_COMP%"=="1" >>%file_sql% echo declare @table sysname;
if "%FLG_COMP%"=="1" >>%file_sql% echo declare @partition int
if "%FLG_COMP%"=="1" >>%file_sql% echo declare @index_id int;
if "%FLG_COMP%"=="1" >>%file_sql% echo:
if "%FLG_COMP%"=="1" >>%file_sql% echo if exists ^(select * from tempdb.sys.objects where [object_id] = OBJECT_ID^('tempdb..%TMPTAB%'^)^)
if "%FLG_COMP%"=="1" >>%file_sql% echo drop table %TMPTAB%;
if "%FLG_COMP%"=="1" >>%file_sql% echo:
if "%FLG_COMP%"=="1" >>%file_sql% echo create table %TMPTAB% ^(
if "%FLG_COMP%"=="1" >>%file_sql% echo     schema_name sysname,
if "%FLG_COMP%"=="1" >>%file_sql% echo     rank int,
if "%FLG_COMP%"=="1" >>%file_sql% echo     object_name sysname,
if "%FLG_COMP%"=="1" >>%file_sql% echo     index_id int,
if "%FLG_COMP%"=="1" >>%file_sql% echo     partition_number int,
if "%FLG_COMP%"=="1" >>%file_sql% echo     compression_type int,
if "%FLG_COMP%"=="1" >>%file_sql% echo     size_with_current_compression_setting bigint,
if "%FLG_COMP%"=="1" >>%file_sql% echo     size_with_requested_compression_setting bigint,
if "%FLG_COMP%"=="1" >>%file_sql% echo     sample_size_with_current_compression_setting bigint,
if "%FLG_COMP%"=="1" >>%file_sql% echo     sample_size_with_requested_compression_setting bigint
if "%FLG_COMP%"=="1" >>%file_sql% echo ^)
if "%FLG_COMP%"=="1" >>%file_sql% echo:
if "%FLG_COMP%"=="1" >>%file_sql% echo declare cur cursor fast_forward for
if "%FLG_COMP%"=="1" >>%file_sql% echo with tables as ^(
if "%FLG_COMP%"=="1" >>%file_sql% echo  select TOP %TOP_NSQL%
if "%FLG_COMP%"=="1" >>%file_sql% echo         cast^(row_number^(^) over^(order by sum^(au.used_pages^) desc^) as tinyint^) as rank,
if "%FLG_COMP%"=="1" >>%file_sql% echo         s.name schema_name, t.name table_name, max^(t.object_id^) object_id
if "%FLG_COMP%"=="1" >>%file_sql% echo  from sys.tables t
if "%FLG_COMP%"=="1" >>%file_sql% echo  join sys.indexes i           on t.object_id    = i.object_id
if "%FLG_COMP%"=="1" >>%file_sql% echo  join sys.partitions p        on i.object_id    = p.object_id and i.index_id = p.index_id
if "%FLG_COMP%"=="1" >>%file_sql% echo  join sys.allocation_units au on p.partition_id = au.container_id
if "%FLG_COMP%"=="1" >>%file_sql% echo  join sys.schemas s           on s.schema_id    = t.schema_id
if "%FLG_COMP%"=="1" if     defined LOGIN >>%file_sql% echo  where s.name = '%LOGIN%'
if "%FLG_COMP%"=="1" if not defined LOGIN >>%file_sql% echo  where s.schema_id ^> 4 and s.schema_id ^< 16384
if "%FLG_COMP%"=="1" >>%file_sql% echo  and t.type_desc = 'USER_TABLE'
if "%FLG_COMP%"=="1" >>%file_sql% echo  group by s.name, t.name
if "%FLG_COMP%"=="1" >>%file_sql% echo  order by sum^(au.used_pages^) desc
if "%FLG_COMP%"=="1" >>%file_sql% echo ^)
if "%FLG_COMP%"=="1" >>%file_sql% echo select t.schema_name, t.rank, t.table_name, p.partition_number, i.index_id
if "%FLG_COMP%"=="1" >>%file_sql% echo from tables t
if "%FLG_COMP%"=="1" >>%file_sql% echo join sys.indexes i on i.object_id = t.object_id
if "%FLG_COMP%"=="1" >>%file_sql% echo join sys.partitions p on p.object_id = t.object_id and p.index_id = i.index_id
if "%FLG_COMP%"=="1" >>%file_sql% echo where i.index_id ^> 2;
if "%FLG_COMP%"=="1" >>%file_sql% echo:
if "%FLG_COMP%"=="1" >>%file_sql% echo open cur;
if "%FLG_COMP%"=="1" >>%file_sql% echo fetch next from cur into @schema, @rank, @table, @partition, @index_id;
if "%FLG_COMP%"=="1" >>%file_sql% echo while @@fetch_status = 0
if "%FLG_COMP%"=="1" >>%file_sql% echo begin
if "%FLG_COMP%"=="1" >>%file_sql% echo   insert %TMPTAB% ^([object_name], [schema_name], index_id, partition_number, size_with_current_compression_setting,
if "%FLG_COMP%"=="1" >>%file_sql% echo                                size_with_requested_compression_setting, sample_size_with_current_compression_setting,
if "%FLG_COMP%"=="1" >>%file_sql% echo                                sample_size_with_requested_compression_setting^)
if "%FLG_COMP%"=="1" >>%file_sql% echo   exec sp_estimate_data_compression_savings @schema, @table, @index_id, @partition, 'ROW';
if "%FLG_COMP%"=="1" >>%file_sql% echo   update %TMPTAB% set rank = @rank, compression_type = 1 where compression_type is null;
if "%FLG_COMP%"=="1" >>%file_sql% echo:
if "%FLG_COMP%"=="1" >>%file_sql% echo   insert %TMPTAB% ^([object_name], [schema_name], index_id, partition_number, size_with_current_compression_setting,
if "%FLG_COMP%"=="1" >>%file_sql% echo                                size_with_requested_compression_setting, sample_size_with_current_compression_setting,
if "%FLG_COMP%"=="1" >>%file_sql% echo                                sample_size_with_requested_compression_setting^)
if "%FLG_COMP%"=="1" >>%file_sql% echo   exec sp_estimate_data_compression_savings @schema, @table, @index_id, @partition, 'PAGE';
if "%FLG_COMP%"=="1" >>%file_sql% echo   update %TMPTAB% set rank = @rank, compression_type = 2 where compression_type is null;
if "%FLG_COMP%"=="1" >>%file_sql% echo:
if "%FLG_COMP%"=="1" >>%file_sql% echo   fetch next from cur into @schema, @rank, @table, @partition, @index_id;
if "%FLG_COMP%"=="1" >>%file_sql% echo end
if "%FLG_COMP%"=="1" >>%file_sql% echo close cur;
if "%FLG_COMP%"=="1" >>%file_sql% echo deallocate cur;
if "%FLG_COMP%"=="1" >>%file_sql% echo:
if "%FLG_COMP%"=="1" >>%file_sql% echo ;with compression as ^(
if "%FLG_COMP%"=="1" >>%file_sql% echo select schema_name,
if "%FLG_COMP%"=="1" >>%file_sql% echo        rank,
if "%FLG_COMP%"=="1" >>%file_sql% echo        object_name as table_name,
if "%FLG_COMP%"=="1" >>%file_sql% echo        i.name as index_name,
if "%FLG_COMP%"=="1" >>%file_sql% echo        case compression_type when 0 then 'NONE'
if "%FLG_COMP%"=="1" >>%file_sql% echo                              when 1 then 'ROW'
if "%FLG_COMP%"=="1" >>%file_sql% echo                              when 2 then 'PAGE' collate DATABASE_DEFAULT end as compression_type,
if "%FLG_COMP%"=="1" >>%file_sql% echo        100 - cast^(^(100.0 * size_with_requested_compression_setting^) / nullif^(size_with_current_compression_setting, 0^) as dec^(5,2^)^) as pct_compress,
if "%FLG_COMP%"=="1" >>%file_sql% echo        size_with_current_compression_setting / 1024.0 as size_mb,
if "%FLG_COMP%"=="1" >>%file_sql% echo        size_with_requested_compression_setting / 1024.0 as compressed_size_mb
if "%FLG_COMP%"=="1" >>%file_sql% echo from %TMPTAB% cs
if "%FLG_COMP%"=="1" >>%file_sql% echo join sys.indexes i ON cs.index_id = i.index_id and i.object_id = object_id^(quotename^(schema_name^) + '.' + quotename^(object_name^)^)
if "%FLG_COMP%"=="1" >>%file_sql% echo ^)
if "%FLG_COMP%"=="1" >>%file_sql% echo select left^(schema_name, %LEN_OWNER%^)                                                              AS 'Owner',
if "%FLG_COMP%"=="1" >>%file_sql% echo        left^(table_name, %LEN_TABLE%^)                                                              AS 'Table Name',
if "%FLG_COMP%"=="1" >>%file_sql% echo        left^(index_name, %LEN_INDEX%^)                                                              AS 'Index_name',
if "%FLG_COMP%"=="1" >>%file_sql% echo        cast^(size_mb as dec ^(7,1^)^)                                                        AS 'Actual size ^(MB^)',
if "%FLG_COMP%"=="1" >>%file_sql% echo        compression_type                                                                  AS 'Type',
if "%FLG_COMP%"=="1" >>%file_sql% echo        cast^(compressed_size_mb as dec ^(7,1^)^)                                             AS 'Compressed size ^(MB^)',
if "%FLG_COMP%"=="1" >>%file_sql% echo        cast^(isnull(pct_compress, 0) as int^)                                              AS 'Compressed size ^(%%^)',
if "%FLG_COMP%"=="1" >>%file_sql% echo        cast^(size_mb - compressed_size_mb as dec^(7,1^)^)                                    AS 'Saved size ^(MB^)',
if "%FLG_COMP%"=="1" >>%file_sql% echo        cast^(sum^(size_mb - compressed_size_mb^) 
if "%FLG_COMP%"=="1" >>%file_sql% echo        over ^(partition by schema_name, table_name, compression_type^)/1024.0 as dec^(4,1^)^) AS 'Total saved ^(GB^)',
if "%FLG_COMP%"=="1" >>%file_sql% echo        left^('ALTER INDEX ' + index_name + ' ON ' + schema_name + '.' + table_name +
if "%FLG_COMP%"=="1" >>%file_sql% echo              ' REBUILD PARTITION = ALL WITH ^(SORT_IN_TEMP = ON, DATA_COMPRESSION = ' +
if "%FLG_COMP%"=="1" >>%file_sql% echo        compression_type + '^);', 130^)                                                     AS 'SQL Command'
if "%FLG_COMP%"=="1" >>%file_sql% echo from compression
if "%FLG_COMP%"=="1" >>%file_sql% echo order by schema_name, rank, table_name, index_name, compression_type desc;
if "%FLG_COMP%"=="1" >>%file_sql% echo:
if "%FLG_COMP%"=="1" >>%file_sql% echo if exists ^(select * from tempdb.sys.objects where [object_id] = OBJECT_ID^('tempdb..%TMPTAB%'^)^)
if "%FLG_COMP%"=="1" >>%file_sql% echo drop table %TMPTAB%;
if "%FLG_COMP%"=="1" >>%file_sql% echo:
goto:EOF
::#
::# End of Audit_obj
::#************************************************************#

:Audit_err
::#************************************************************#
::# Audits current SQL traces and last SQL Server Error & Agent logs
::#
>>%file_sql% echo PRINT ''
>>%file_sql% echo PRINT '+------------+'
>>%file_sql% echo PRINT '^| SQL traces ^|'
>>%file_sql% echo PRINT '+------------+'
>>%file_sql% echo PRINT ''
>>%file_sql% echo:
>>%file_sql% echo select cast(t.id as tinyint^)                                                     AS 'Id.',
>>%file_sql% echo        reverse^(substring^(reverse^(t.path^), charindex^('\', reverse^(t.path^)^)+1,70^)^) AS 'Default path',
>>%file_sql% echo        cast^(t.max_size  as int^)                                                  AS 'Max Size ^(MB^)',
>>%file_sql% echo        cast^(t.max_files as int^)                                                  AS '  Max Files',
if "%VER_SQL%"=="11.0" >>%file_sql% echo        left^(format^(t.start_time, '%FMT_DAT2%'^),14^)                           AS 'Startup Time',
if "%VER_SQL%"=="12.0" >>%file_sql% echo        left^(format^(t.start_time, '%FMT_DAT2%'^),14^)                           AS 'Startup Time',
if "%VER_SQL%"=="13.0" >>%file_sql% echo        left^(format^(t.start_time, '%FMT_DAT2%'^),14^)                           AS 'Startup Time',
if "%VER_SQL%"=="14.0" >>%file_sql% echo        left^(format^(t.start_time, '%FMT_DAT2%'^),14^)                           AS 'Startup Time',
if not "%VER_SQL%"=="11.0" if not "%VER_SQL%"=="12.0" if not "%VER_SQL%"=="13.0" if not "%VER_SQL%"=="14.0" >>%file_sql% echo        left^(convert^(varchar, t.start_time, %CNV_DATE%^)+' '+
if not "%VER_SQL%"=="11.0" if not "%VER_SQL%"=="12.0" if not "%VER_SQL%"=="13.0" if not "%VER_SQL%"=="14.0" >>%file_sql% echo             convert^(varchar, t.start_time, %CNV_TIME%^),14^)                                AS 'Startup Time',
if "%VER_SQL%"=="11.0" >>%file_sql% echo        left^(format^(t.last_event_time, '%FMT_DAT2%'^),14^)                      AS 'Last Time'
if "%VER_SQL%"=="12.0" >>%file_sql% echo        left^(format^(t.last_event_time, '%FMT_DAT2%'^),14^)                      AS 'Last Time'
if "%VER_SQL%"=="13.0" >>%file_sql% echo        left^(format^(t.last_event_time, '%FMT_DAT2%'^),14^)                      AS 'Last Time'
if "%VER_SQL%"=="14.0" >>%file_sql% echo        left^(format^(t.last_event_time, '%FMT_DAT2%'^),14^)                      AS 'Last Time'
if not "%VER_SQL%"=="11.0" if not "%VER_SQL%"=="12.0" if not "%VER_SQL%"=="13.0" if not "%VER_SQL%"=="14.0" >>%file_sql% echo        left^(convert^(varchar, t.last_event_time, %CNV_DATE%^)+' '+
if not "%VER_SQL%"=="11.0" if not "%VER_SQL%"=="12.0" if not "%VER_SQL%"=="13.0" if not "%VER_SQL%"=="14.0" >>%file_sql% echo             convert^(varchar, t.last_event_time, %CNV_TIME%^),14^)                           AS 'Last Time'
>>%file_sql% echo from sys.traces t;
>>%file_sql% echo:
>>%file_sql% echo PRINT ''
>>%file_sql% echo PRINT '+---------------+'
>>%file_sql% echo PRINT '^| SQL log files ^|'
>>%file_sql% echo PRINT '+---------------+'
>>%file_sql% echo PRINT ''
>>%file_sql% echo:
>>%file_sql% echo if object_id^('tempdb.dbo.%TMPTAB%'^) is not null drop table %TMPTAB%;
>>%file_sql% echo go
>>%file_sql% echo create table %TMPTAB% ^(LogID int, LogDate varchar^(20^), LogSize bigint^);
>>%file_sql% echo insert into %TMPTAB% exec sys.sp_enumerrorlogs;
>>%file_sql% echo select cast^(l.LogID as tinyint^)                AS 'Archive',
>>%file_sql% echo        left^(l.LogDate, 17^)                     AS 'Last Datetime',
>>%file_sql% echo        cast^(l.LogSize/1024.0/1024 as dec^(5,1^)^) AS 'Log Size ^(MB^)'
>>%file_sql% echo from %TMPTAB% l;
>>%file_sql% echo:
>>%file_sql% echo PRINT ''
>>%file_sql% echo PRINT '+--------------------------+'
>>%file_sql% echo PRINT '^| SQL Error logs ^(summary^) ^|'
>>%file_sql% echo PRINT '+--------------------------+'
>>%file_sql% echo PRINT ''
>>%file_sql% echo:
>>%file_sql% echo if object_id^('tempdb.dbo.%TMPTAB%'^) is not null drop table %TMPTAB%;
>>%file_sql% echo go
>>%file_sql% echo create table %TMPTAB% ^(LogDate datetime, ProcessInfo varchar^(20^), Text varchar^(max^)^);
>>%file_sql% echo declare @begin_date datetime
>>%file_sql% echo declare @end_date   datetime
>>%file_sql% echo set @begin_date=getdate^(^)-%HISLOG%
>>%file_sql% echo set @end_date=getdate^(^)
>>%file_sql% echo insert into %TMPTAB% ^(LogDate, ProcessInfo, Text^) exec xp_readerrorlog %NUMLOG%, 1, %STRLOG1%, %STRLOG2%, @begin_date, @end_date;
>>%file_sql% echo:
>>%file_sql% echo select count^(*^)                                     AS '   Count^>=2',
if "%VER_SQL%"=="11.0" >>%file_sql% echo        left^(format^(Min^(LogDate^), '%FMT_DAT3%'^),17^)                                                         AS 'First time',
if "%VER_SQL%"=="12.0" >>%file_sql% echo        left^(format^(Min^(LogDate^), '%FMT_DAT3%'^),17^)                                                         AS 'First time',
if "%VER_SQL%"=="13.0" >>%file_sql% echo        left^(format^(Min^(LogDate^), '%FMT_DAT3%'^),17^)                                                         AS 'First time',
if "%VER_SQL%"=="14.0" >>%file_sql% echo        left^(format^(Min^(LogDate^), '%FMT_DAT3%'^),17^)                                                         AS 'First time',
if not "%VER_SQL%"=="11.0" if not "%VER_SQL%"=="12.0" if not "%VER_SQL%"=="13.0" if not "%VER_SQL%"=="14.0" >>%file_sql% echo        left^(convert^(varchar, Min^(LogDate^), %CNV_DATE%^)+' '+
if not "%VER_SQL%"=="11.0" if not "%VER_SQL%"=="12.0" if not "%VER_SQL%"=="13.0" if not "%VER_SQL%"=="14.0" >>%file_sql% echo             convert^(varchar, Min^(LogDate^), %CNV_TIME%^),17^)   AS 'First time',
if "%VER_SQL%"=="11.0" >>%file_sql% echo        case when Min^(LogDate^) ^<^> Max^(LogDate^) then left^(format^(Max^(LogDate^), '%FMT_DAT3%'^),17^) else '' end AS 'Last time',
if "%VER_SQL%"=="12.0" >>%file_sql% echo        case when Min^(LogDate^) ^<^> Max^(LogDate^) then left^(format^(Max^(LogDate^), '%FMT_DAT3%'^),17^) else '' end AS 'Last time',
if "%VER_SQL%"=="13.0" >>%file_sql% echo        case when Min^(LogDate^) ^<^> Max^(LogDate^) then left^(format^(Max^(LogDate^), '%FMT_DAT3%'^),17^) else '' end AS 'Last time',
if "%VER_SQL%"=="14.0" >>%file_sql% echo        case when Min^(LogDate^) ^<^> Max^(LogDate^) then left^(format^(Max^(LogDate^), '%FMT_DAT3%'^),17^) else '' end AS 'Last time',
if not "%VER_SQL%"=="11.0" if not "%VER_SQL%"=="12.0" if not "%VER_SQL%"=="13.0" if not "%VER_SQL%"=="14.0" >>%file_sql% echo        left^(convert^(varchar, Max^(LogDate^), %CNV_DATE%^)+' '+
if not "%VER_SQL%"=="11.0" if not "%VER_SQL%"=="12.0" if not "%VER_SQL%"=="13.0" if not "%VER_SQL%"=="14.0" >>%file_sql% echo             convert^(varchar, Max^(LogDate^), %CNV_TIME%^),17^)   AS 'Last time',
::>>%file_sql% echo        substring(Text, 1, %LEN_SQLT%)                                                                                    AS 'Log Text'
>>%file_sql% echo        left^(case when patindex^('%%[0-9][0-9][0-9]/%%',Text^) = 0 then substring^(Text, 1, %LEN_SQLT%^) else substring^(Text, 1, patindex('%%[0-9][0-9][0-9]/%%',Text^)-4^) end, %LEN_SQLT%^) AS 'Log Text'
>>%file_sql% echo from %TMPTAB%
>>%file_sql% echo group by case when patindex^('%%[0-9][0-9][0-9]/%%',Text^) = 0 then substring^(Text, 1, %LEN_SQLT%^) else substring^(Text, 1, patindex^('%%[0-9][0-9][0-9]/%%',Text^)-4^) end
>>%file_sql% echo having count(*) ^> 1
>>%file_sql% echo order by 1 desc, 3 desc;
>>%file_sql% echo:
>>%file_sql% echo PRINT ''
>>%file_sql% echo PRINT '+-------------------------+'
>>%file_sql% echo PRINT '^| SQL Error logs ^(detail^) ^|'
>>%file_sql% echo PRINT '+-------------------------+'
>>%file_sql% echo PRINT ''
>>%file_sql% echo:
if "%VER_SQL%"=="11.0" >>%file_sql% echo select left^(format^(LogDate, '%FMT_DAT3%'^),17^) AS 'Log Datetime',
if "%VER_SQL%"=="12.0" >>%file_sql% echo select left^(format^(LogDate, '%FMT_DAT3%'^),17^) AS 'Log Datetime',
if "%VER_SQL%"=="13.0" >>%file_sql% echo select left^(format^(LogDate, '%FMT_DAT3%'^),17^) AS 'Log Datetime',
if "%VER_SQL%"=="14.0" >>%file_sql% echo select left^(format^(LogDate, '%FMT_DAT3%'^),17^) AS 'Log Datetime',
if not "%VER_SQL%"=="11.0" if not "%VER_SQL%"=="12.0" if not "%VER_SQL%"=="13.0" if not "%VER_SQL%"=="14.0" >>%file_sql% echo select left^(convert^(varchar, LogDate, %CNV_DATE%^)+' '+
if not "%VER_SQL%"=="11.0" if not "%VER_SQL%"=="12.0" if not "%VER_SQL%"=="13.0" if not "%VER_SQL%"=="14.0" >>%file_sql% echo              convert^(varchar, LogDate, %CNV_TIME%^),17^)        AS 'Log Datetime',
>>%file_sql% echo        left^(isnull^(ProcessInfo,''^), 8^)               AS 'Info',
>>%file_sql% echo        left^(Text, %LEN_SQLT%^)                               AS 'Log Text'
>>%file_sql% echo from %TMPTAB%
>>%file_sql% echo where ProcessInfo != 'Logon'
>>%file_sql% echo order by LogDate desc;
>>%file_sql% echo:
>>%file_sql% echo PRINT ''
>>%file_sql% echo PRINT '+--------------------------+'
>>%file_sql% echo PRINT '^| SQL Agent logs ^(summary^) ^|'
>>%file_sql% echo PRINT '+--------------------------+'
>>%file_sql% echo PRINT ''
>>%file_sql% echo:
>>%file_sql% echo if object_id^('tempdb.dbo.%TMPTAB%'^) is not null drop table %TMPTAB%;
>>%file_sql% echo go
>>%file_sql% echo create table %TMPTAB% ^(LogDate datetime, ProcessInfo varchar^(20^), Text varchar^(max^)^);
>>%file_sql% echo declare @begin_date datetime
>>%file_sql% echo set @begin_date=getdate^(^)-%HISLOG%
>>%file_sql% echo declare @end_date   datetime
>>%file_sql% echo set @end_date=getdate^(^)
>>%file_sql% echo insert into %TMPTAB% ^(LogDate, ProcessInfo, Text^) exec xp_readerrorlog %NUMLOG%, 2, %STRLOG1%, %STRLOG2%, @begin_date, @end_date;
>>%file_sql% echo:
>>%file_sql% echo select count(*)                                                                                                   AS '   Count^>=2',
>>%file_sql% echo        substring(Text, 1, %LEN_SQLT%)                                                                                    AS 'Log Text',
if "%VER_SQL%"=="11.0" >>%file_sql% echo        left^(format^(Min^(LogDate^), '%FMT_DAT3%'^),17^)                                                         AS 'First time',
if "%VER_SQL%"=="12.0" >>%file_sql% echo        left^(format^(Min^(LogDate^), '%FMT_DAT3%'^),17^)                                                         AS 'First time',
if "%VER_SQL%"=="13.0" >>%file_sql% echo        left^(format^(Min^(LogDate^), '%FMT_DAT3%'^),17^)                                                         AS 'First time',
if "%VER_SQL%"=="14.0" >>%file_sql% echo        left^(format^(Min^(LogDate^), '%FMT_DAT3%'^),17^)                                                         AS 'First time',
if not "%VER_SQL%"=="11.0" if not "%VER_SQL%"=="12.0" if not "%VER_SQL%"=="13.0" if not "%VER_SQL%"=="14.0" >>%file_sql% echo        left^(convert^(varchar, Min^(LogDate^), %CNV_DATE%^)+' '+
if not "%VER_SQL%"=="11.0" if not "%VER_SQL%"=="12.0" if not "%VER_SQL%"=="13.0" if not "%VER_SQL%"=="14.0" >>%file_sql% echo              convert^(varchar, Min^(LogDate^), %CNV_TIME%^),17^) AS 'First time',
if "%VER_SQL%"=="11.0" >>%file_sql% echo        case when Min^(LogDate^) ^<^> Max^(LogDate^) then left^(format^(Max^(LogDate^), '%FMT_DAT3%'^),17^) else '' end AS 'Last time'
if "%VER_SQL%"=="12.0" >>%file_sql% echo        case when Min^(LogDate^) ^<^> Max^(LogDate^) then left^(format^(Max^(LogDate^), '%FMT_DAT3%'^),17^) else '' end AS 'Last time'
if "%VER_SQL%"=="13.0" >>%file_sql% echo        case when Min^(LogDate^) ^<^> Max^(LogDate^) then left^(format^(Max^(LogDate^), '%FMT_DAT3%'^),17^) else '' end AS 'Last time'
if "%VER_SQL%"=="14.0" >>%file_sql% echo        case when Min^(LogDate^) ^<^> Max^(LogDate^) then left^(format^(Max^(LogDate^), '%FMT_DAT3%'^),17^) else '' end AS 'Last time'
if not "%VER_SQL%"=="11.0" if not "%VER_SQL%"=="12.0" if not "%VER_SQL%"=="13.0" if not "%VER_SQL%"=="14.0" >>%file_sql% echo        left^(convert^(varchar, Max^(LogDate^), %CNV_DATE%^)+' '+
if not "%VER_SQL%"=="11.0" if not "%VER_SQL%"=="12.0" if not "%VER_SQL%"=="13.0" if not "%VER_SQL%"=="14.0" >>%file_sql% echo              convert^(varchar, Max^(LogDate^), %CNV_TIME%^),17^) AS 'Last time'
>>%file_sql% echo from %TMPTAB%
>>%file_sql% echo group by substring(Text, 1, %LEN_SQLT%)
>>%file_sql% echo having count(*) ^> 1
>>%file_sql% echo order by 1 desc, 4 desc;
>>%file_sql% echo:
>>%file_sql% echo PRINT ''
>>%file_sql% echo PRINT '+-------------------------+'
>>%file_sql% echo PRINT '^| SQL Agent logs ^(detail^) ^|'
>>%file_sql% echo PRINT '+-------------------------+'
>>%file_sql% echo PRINT ''
>>%file_sql% echo:
if "%VER_SQL%"=="11.0" >>%file_sql% echo select left^(format^(LogDate, '%FMT_DAT3%'^),17^) AS 'Log Datetime',
if "%VER_SQL%"=="12.0" >>%file_sql% echo select left^(format^(LogDate, '%FMT_DAT3%'^),17^) AS 'Log Datetime',
if "%VER_SQL%"=="13.0" >>%file_sql% echo select left^(format^(LogDate, '%FMT_DAT3%'^),17^) AS 'Log Datetime',
if "%VER_SQL%"=="14.0" >>%file_sql% echo select left^(format^(LogDate, '%FMT_DAT3%'^),17^) AS 'Log Datetime',
if not "%VER_SQL%"=="11.0" if not "%VER_SQL%"=="12.0" if not "%VER_SQL%"=="13.0" if not "%VER_SQL%"=="14.0" >>%file_sql% echo select left^(convert^(varchar, LogDate, %CNV_DATE%^)+' '+
if not "%VER_SQL%"=="11.0" if not "%VER_SQL%"=="12.0" if not "%VER_SQL%"=="13.0" if not "%VER_SQL%"=="14.0" >>%file_sql% echo              convert^(varchar, LogDate, %CNV_TIME%^),17^)        AS 'Log Datetime',
>>%file_sql% echo        left^(Text, %LEN_SQLT%^)                               AS 'Log Text'
>>%file_sql% echo from %TMPTAB%
>>%file_sql% echo order by LogDate desc;
>>%file_sql% echo:
>>%file_sql% echo if object_id^('tempdb.dbo.%TMPTAB%'^) is not null drop table %TMPTAB%;
>>%file_sql% echo go
>>%file_sql% echo:
goto:EOF
::#
::# End of Audit_err
::#************************************************************#

:Audit_wait
::#************************************************************#
::# Audits wait events in the database
::#
>>%file_sql% echo PRINT ''
>>%file_sql% echo PRINT '+-------------+'
>>%file_sql% echo PRINT '^| Wait events ^|'
>>%file_sql% echo PRINT '+-------------+'
>>%file_sql% echo PRINT ''
>>%file_sql% echo ;with Waits AS
>>%file_sql% echo       ^(select wait_type,
>>%file_sql% echo               wait_time_ms / 1000.0                          AS waits,
>>%file_sql% echo              ^(wait_time_ms-signal_wait_time_ms^)/1000.0       AS Resource_Wait_Time_S,
>>%file_sql% echo               signal_wait_time_ms /1000.0                    AS signals_wait_time_s,
>>%file_sql% echo               waiting_tasks_count as WaitCount,
>>%file_sql% echo               100. * wait_time_ms / sum^(wait_time_ms^) OVER^(^) AS Percentage,
>>%file_sql% echo               ROW_NUMBER^(^) OVER^(order by wait_time_ms desc^)  AS RowNumber
>>%file_sql% echo       from sys.dm_os_wait_stats
>>%file_sql% echo       where wait_type NOT IN ^('BROKER_EVENTHANDLER', 'BROKER_RECEIVE_WAITFOR', 'BROKER_TASK_STOP', 'BROKER_TO_FLUSH', 'BROKER_TRANSMITTER',
>>%file_sql% echo                                'CHECKPOINT_QUEUE',
>>%file_sql% echo                                'CLR_AUTO_EVENT', 'CLR_MANUAL_EVENT', 'CLR_SEMAPHORE',
>>%file_sql% echo                                'DIRTY_PAGE_POLL',
>>%file_sql% echo                                'DISPATCHER_QUEUE_SEMAPHORE',
>>%file_sql% echo                                'FT_IFTS_SCHEDULER_IDLE_WAIT', 'FT_IFTSHC_MUTEX',
>>%file_sql% echo                                'HADR_FILESTREAM_IOMGR_IOCOMPLETION',
>>%file_sql% echo                                'LAZYWRITER_SLEEP','LOGMGR_QUEUE',
>>%file_sql% echo                                'ONDEMAND_TASK_QUEUE',
>>%file_sql% echo                                'QDS_ASYNC_QUEUE', 'QDS_CLEANUP_STALE_QUERIES_TASK_MAIN_LOOP_SLEEP', 'QDS_PERSIST_TASK_MAIN_LOOP_SLEEP',
>>%file_sql% echo                                'REQUEST_FOR_DEADLOCK_SEARCH',
>>%file_sql% echo                                'RESOURCE_QUEUE',
>>%file_sql% echo                                'SLEEP_BPOOL_FLUSH', 'SLEEP_SYSTEMTASK', 'SLEEP_TASK',
>>%file_sql% echo                                'SP_SERVER_DIAGNOSTICS_SLEEP',
>>%file_sql% echo                                'SQLTRACE_BUFFER_FLUSH', 'SQLTRACE_INCREMENTAL_FLUSH_SLEEP', 'SQLTRACE_LOCK', 'SQLTRACE_WAIT_ENTRIES',
>>%file_sql% echo                                'TRACEWRITE',
>>%file_sql% echo                                'WAITFOR',
>>%file_sql% echo                                'XE_DISPATCHER_JOIN', 'XE_DISPATCHER_WAIT', 'XE_TIMER_EVENT'^)
>>%file_sql% echo 	  and wait_type not like 'HADR_%%'
>>%file_sql% echo 	  and wait_type not like 'PREEMPTIVE_%%'
>>%file_sql% echo       ^)
>>%file_sql% echo select left^(w1.wait_type, 35^)                    AS 'Wait Type',
>>%file_sql% echo   cast^(w1.waits                as decimal^(10,1^)^) AS '    Wait ^(s^)',
>>%file_sql% echo   cast^(w1.Resource_Wait_Time_S as decimal^(10,1^)^) AS 'Resource ^(s^)',
>>%file_sql% echo   cast^(w1.signals_wait_time_s  as decimal^(10,1^)^) AS '  Signal ^(s^)',
>>%file_sql% echo   right^(replicate^(' ',12-len^(max^(w1.WaitCount^)^)^)
>>%file_sql% echo         + cast^(max^(w1.WaitCount^) as varchar^),12^) AS '  Wait Count',
>>%file_sql% echo   cast^(w1.Percentage           as decimal^(5,1^)^)  AS 'Wait ^(%%^)',
>>%file_sql% echo   cast^(sum^(w2.Percentage^)      as decimal^(5,1^)^)  AS 'Total ^(%%^)'
>>%file_sql% echo from Waits w1
>>%file_sql% echo inner join Waits w2 on w2.RowNumber ^<= w1.RowNumber
>>%file_sql% echo where w1.Percentage ^> 0.1
>>%file_sql% echo group by w1.wait_type, w1.waits, w1.Percentage, w1.Resource_Wait_Time_S, w1.signals_wait_time_s
>>%file_sql% echo having sum^(w2.Percentage^) - w1.Percentage ^< 99.99
>>%file_sql% echo order by 6 desc;
>>%file_sql% echo:
>>%file_sql% echo PRINT ''
>>%file_sql% echo PRINT '+---------------+'
>>%file_sql% echo PRINT '^| Waiting tasks ^|'
>>%file_sql% echo PRINT '+---------------+'
>>%file_sql% echo PRINT ''
>>%file_sql% echo:
>>%file_sql% echo select w.session_id                                                                                                    AS 'SID',
>>%file_sql% echo        left^(p.hostprocess,6^)                                                                                           AS 'PID',
>>%file_sql% echo        left^(db_name^(p.dbid^), %LEN_DBNAME%^)                                                                                        AS 'DB Name',
>>%file_sql% echo        left^(p.loginame,%LEN_LOGIN%^)                                                                                             AS 'Login Name',
>>%file_sql% echo        left^(case when isnull^(w.blocking_session_id,0^) = 0 then '' else cast^(w.blocking_session_id as varchar^) end, 11^) AS 'Blocking SID',
>>%file_sql% echo        isnull^(^(select p1.hostprocess from sys.sysprocesses p1 where p1.spid = r.blocking_session_id^),''^)               AS 'Blocking PID',
>>%file_sql% echo        cast^(w.exec_context_id as int^)                                                                                  AS 'Thread',
>>%file_sql% echo        cast^(t.scheduler_id as int^)                                                                                     AS 'Scheduler',
>>%file_sql% echo        left^(case w.wait_type when 'CXPACKET'
>>%file_sql% echo             then right^(w.resource_description, charindex ^('=', reverse ^(w.resource_description^)^) - 1^) else '' end, 8^)  AS 'Node Id.',
>>%file_sql% echo        cast^(w.wait_duration_ms/1000.0 as dec^(8,1^)^)                                                                     AS 'Wait Time ^(s^)',
>>%file_sql% echo        cast^(r.cpu_time/1000.0 as dec^(8,1^)^)                                                                             AS 'CPU Time ^(s^)',
>>%file_sql% echo        cast^(g.dop as int^)                                                                                              AS 'Dop',
>>%file_sql% echo        left^(w.wait_type, 15^)                                                                                           AS 'Wait type',
>>%file_sql% echo        left^(isnull^(w.resource_description,''^), 30^)                                                                     AS 'Description',
>>%file_sql% echo        left^(s.program_name, 35^)                                                                                        AS 'Program Name',
>>%file_sql% echo        char^(13^)+char^(10^)+cast^(substring^(st.text, ^(r.statement_start_offset/2^)+1,
>>%file_sql% echo        ^(^(case r.statement_end_offset when -1
>>%file_sql% echo          then datalength^(st.text^)
>>%file_sql% echo          else r.statement_end_offset  end -
>>%file_sql% echo               r.statement_start_offset^)/2^)+1^) as char^(%LEN_SQLT%^)^)+char^(13^)+char^(10^)                                          AS 'SQL Text'
>>%file_sql% echo from sys.dm_os_waiting_tasks w
>>%file_sql% echo inner join sys.dm_os_tasks t                 on t.task_address = w.waiting_task_address
>>%file_sql% echo inner join sys.dm_exec_sessions s            on s.session_id   = w.session_id
>>%file_sql% echo inner join sys.dm_exec_query_memory_grants g on g.session_id   = w.session_id
>>%file_sql% echo inner join sys.dm_exec_requests r            on r.session_id   = s.session_id
>>%file_sql% echo inner join sys.sysprocesses p                on p.spid         = s.session_id
>>%file_sql% echo outer apply sys.dm_exec_sql_text^(r.sql_handle^) st
>>%file_sql% echo where s.is_user_process = 1
>>%file_sql% echo and p.loginame ^> ''
>>%file_sql% echo order by w.session_id, cast^(w.exec_context_id as int^), cast^(t.scheduler_id as int^), cast^(w.wait_duration_ms/1000.0 as dec^(8,1^)^)
>>%file_sql% echo:
>>%file_sql% echo PRINT ''
>>%file_sql% echo PRINT '+---------+'
>>%file_sql% echo PRINT '^| Latches ^|'
>>%file_sql% echo PRINT '+---------+'
>>%file_sql% echo PRINT ''
>>%file_sql% echo:
>>%file_sql% echo ;with latches as
>>%file_sql% echo ^(select latch_class as latch_name,
>>%file_sql% echo         case when latch_class = 'BUFFER'                               then 'Buffer Pool'
>>%file_sql% echo              when latch_class = 'ACCESS_METHODS_HOBT_COUNT'
>>%file_sql% echo                or latch_class = 'ACCESS_METHODS_HOBT_VIRTUAL_ROOT'     then 'HoBT - Metadata'
>>%file_sql% echo              when latch_class = 'ACCESS_METHODS_DATASET_PARENT'
>>%file_sql% echo                or latch_class = 'ACCESS_METHODS_SCAN_RANGE_GENERATOR' 
>>%file_sql% echo                or latch_class = 'NESTING_TRANSACTION_FULL'             then 'Parallelism'
>>%file_sql% echo              when latch_class = 'LOG_MANAGER'                          then 'IO - Log'
>>%file_sql% echo              when latch_class = 'TRACE_CONTROLLER'                     then 'Trace'
>>%file_sql% echo              when latch_class = 'DBCC_MULTIOBJECT_SCANNER'             then 'Parallelism - DBCC CHECK_'
>>%file_sql% echo              when latch_class = 'FGCB_ADD_REMOVE'                      then 'IO Operations'
>>%file_sql% echo              when latch_class = 'DATABASE_MIRRORING_CONNECTION'        then 'Mirroring - Busy'
>>%file_sql% echo                           else 'Other' end as class,
>>%file_sql% echo         wait_time_ms/1000.0 as wait_in_sec,
>>%file_sql% echo         waiting_requests_count wait_count,
>>%file_sql% echo         100.0 * wait_time_ms/sum^(wait_time_ms^) over^(^) as wait_pct,
>>%file_sql% echo         row_number^(^) over^(order by wait_time_ms desc^) as rownum
>>%file_sql% echo  from sys.dm_os_latch_stats^)
>>%file_sql% echo select left^(max^(l1.latch_name^), 35^)                 AS 'Latch name',
>>%file_sql% echo        left^(max^(l1.class^), 25^)                      AS 'Class',
>>%file_sql% echo        cast^(max^(l1.wait_in_sec^) as int^)             AS '   Wait ^(s^)',
>>%file_sql% echo        right^(cast^(max^(l1.wait_count^) as bigint^), 10^) AS '    Waits',
>>%file_sql% echo        cast^(max^(l1.wait_pct^) as dec^(4,1^)^)           AS 'Wait ^(%%^)'
>>%file_sql% echo from latches l1
>>%file_sql% echo join latches l2 on l2.rownum ^<= l1.rownum
>>%file_sql% echo where l1.wait_pct ^>= 0.1
>>%file_sql% echo group by l1.rownum;
::>>%file_sql% echo having sum^(l2.wait_pct^) - max^(l1.wait_pct^) ^< 95; -- percentage threshold
>>%file_sql% echo:
goto:EOF
::#
::# End of Audit_wait
::#************************************************************#

:Audit_cpu
::#************************************************************#
::# Audits CPU pressure & usage, latest TOP CPU and context switching
::#
>>%file_sql% echo PRINT ''
>>%file_sql% echo PRINT '+--------------+'
>>%file_sql% echo PRINT '^| CPU pressure ^|'
>>%file_sql% echo PRINT '+--------------+'
>>%file_sql% echo PRINT ''
>>%file_sql% echo select left^(cast(100.0 * sum(wait_time_ms - signal_wait_time_ms) / sum (wait_time_ms) as numeric(18,2)), 18^)          AS 'Resource waits ^(%%^)',
>>%file_sql% echo        left^(cast(100.0 * sum(signal_wait_time_ms) / sum (wait_time_ms) as numeric(18,2)), 18^)                         AS 'Signal CPU waits ^(%%^)',
>>%file_sql% echo        case when 100.0 * sum(signal_wait_time_ms) / sum (wait_time_ms) ^>= 25 then '### Must be ^< 25%% ###' else '' end AS 'Diagnostic'
>>%file_sql% echo from sys.dm_os_wait_stats;
>>%file_sql% echo:
>>%file_sql% echo PRINT ''
>>%file_sql% echo PRINT '+-----------+'
>>%file_sql% echo PRINT '^| CPU usage ^|'
>>%file_sql% echo PRINT '+-----------+'
>>%file_sql% echo PRINT ''
>>%file_sql% echo:
>>%file_sql% echo ;with usage as ^(
>>%file_sql% echo select db_name^(p.dbid^) as dbname,
>>%file_sql% echo        sum^(s.total_worker_time/1000^) as cpu_time_ms
>>%file_sql% echo from sys.dm_exec_query_stats s WITH ^(NOLOCK^)
>>%file_sql% echo cross apply ^(select convert^(int, value^) as dbid
>>%file_sql% echo              from sys.dm_exec_plan_attributes^(s.plan_handle^)
>>%file_sql% echo              where attribute = 'dbid'^) p
>>%file_sql% echo where p.dbid ^<^> 32767 
>>%file_sql% echo group by p.dbid
>>%file_sql% echo ^)
>>%file_sql% echo select cast^(row_number^(^) over^(order by u.cpu_time_ms desc^) as tinyint^)           AS 'Rank',
>>%file_sql% echo        left^(u.dbname, %LEN_DBNAME%^)                                                         AS 'DB Name',
>>%file_sql% echo        cast^(u.cpu_time_ms/1000.0 as dec^(7,1^)^)                                    AS 'CPU Time ^(s^)',
>>%file_sql% echo        cast^(u.cpu_time_ms * 1.0 / sum^(u.cpu_time_ms^) over^(^) * 100.0 as dec^(4,1^)^) AS 'CPU Time ^(%%^)'
>>%file_sql% echo from usage u
>>%file_sql% echo order by 1 option ^(RECOMPILE^);
>>%file_sql% echo:
>>%file_sql% echo PRINT ''
>>%file_sql% echo PRINT '+----------------+'
>>%file_sql% echo PRINT '^| Latest TOP CPU ^|'
>>%file_sql% echo PRINT '+----------------+'
>>%file_sql% echo PRINT ''
>>%file_sql% echo:
>>%file_sql% echo declare @ts_now bigint;
>>%file_sql% echo select @ts_now=cpu_ticks/^(cpu_ticks/ms_ticks^) from sys.dm_os_sys_info WITH ^(NOLOCK^);
>>%file_sql% echo:
>>%file_sql% echo select left^(convert^(varchar, date_time, %CNV_DATE%^)+' '+
>>%file_sql% echo        substring^(convert^(varchar, date_time, %CNV_TIME%^), 1, 5^), 14^) AS 'Date time',
>>%file_sql% echo        pct_sql_cpu_used                                     AS 'SQL CPU Used ^(%%^)',
>>%file_sql% echo        pct_other_cpu_used                                   AS 'Other CPU Used ^(%%^)',
>>%file_sql% echo        pct_sys_cpu_idle                                     AS 'SYS CPU Idle ^(%%^)'
>>%file_sql% echo from ^(
if "%VER_SQL%"=="11.0" >>%file_sql% echo select datediff(minute, 0, convert^(datetime, format^(dateadd^(ms, -1 * ^(@ts_now - min^(timestamp^)^), getdate^(^)^), '%FMT_DAT2%'^),3^)^)/10  AS min_time,
if "%VER_SQL%"=="11.0" >>%file_sql% echo                            convert^(datetime, format^(dateadd^(ms, -1 * ^(@ts_now - min^(timestamp^)^), getdate^(^)^), '%FMT_DAT2%'^),3^)      AS date_time,
if "%VER_SQL%"=="12.0" >>%file_sql% echo select datediff(minute, 0, convert^(datetime, format^(dateadd^(ms, -1 * ^(@ts_now - min^(timestamp^)^), getdate^(^)^), '%FMT_DAT2%'^),3^)^)/10  AS min_time,
if "%VER_SQL%"=="12.0" >>%file_sql% echo                            convert^(datetime, format^(dateadd^(ms, -1 * ^(@ts_now - min^(timestamp^)^), getdate^(^)^), '%FMT_DAT2%'^),3^)      AS date_time,
if "%VER_SQL%"=="13.0" >>%file_sql% echo select datediff(minute, 0, convert^(datetime, format^(dateadd^(ms, -1 * ^(@ts_now - min^(timestamp^)^), getdate^(^)^), '%FMT_DAT2%'^),3^)^)/10  AS min_time,
if "%VER_SQL%"=="13.0" >>%file_sql% echo                            convert^(datetime, format^(dateadd^(ms, -1 * ^(@ts_now - min^(timestamp^)^), getdate^(^)^), '%FMT_DAT2%'^),3^)      AS date_time,
if "%VER_SQL%"=="14.0" >>%file_sql% echo select datediff(minute, 0, convert^(datetime, format^(dateadd^(ms, -1 * ^(@ts_now - min^(timestamp^)^), getdate^(^)^), '%FMT_DAT2%'^),3^)^)/10  AS min_time,
if "%VER_SQL%"=="14.0" >>%file_sql% echo                            convert^(datetime, format^(dateadd^(ms, -1 * ^(@ts_now - min^(timestamp^)^), getdate^(^)^), '%FMT_DAT2%'^),3^)      AS date_time,
if not "%VER_SQL%"=="11.0" if not "%VER_SQL%"=="12.0" if not "%VER_SQL%"=="13.0" if not "%VER_SQL%"=="14.0" >>%file_sql% echo select datediff^(minute, 0, convert^(datetime, left^(convert^(varchar, dateadd^(ms, -1 * ^(@ts_now - min^(timestamp^)^), getdate^(^)^), %CNV_DATE%^)+' '+
if not "%VER_SQL%"=="11.0" if not "%VER_SQL%"=="12.0" if not "%VER_SQL%"=="13.0" if not "%VER_SQL%"=="14.0" >>%file_sql% echo                         convert^(varchar, dateadd^(ms, -1 * ^(@ts_now - min^(timestamp^)^), getdate^(^)^), %CNV_TIME%^), 14^)^)^)/10 AS 'min_time',
if not "%VER_SQL%"=="11.0" if not "%VER_SQL%"=="12.0" if not "%VER_SQL%"=="13.0" if not "%VER_SQL%"=="14.0" >>%file_sql% echo        convert^(datetime, left^(convert^(varchar, dateadd^(ms, -1 * ^(@ts_now - min^(timestamp^)^), getdate^(^)^), %CNV_DATE%^)+' '+
if not "%VER_SQL%"=="11.0" if not "%VER_SQL%"=="12.0" if not "%VER_SQL%"=="13.0" if not "%VER_SQL%"=="14.0" >>%file_sql% echo        convert^(varchar, dateadd^(ms, -1 * ^(@ts_now - min^(timestamp^)^), getdate^(^)^), %CNV_TIME%^), 14^)^) AS 'date_time',
>>%file_sql% echo        avg^(sqlcpu^)                                                                                                                     AS pct_sql_cpu_used,
>>%file_sql% echo        avg^(100 - idlecpu - sqlcpu^)                                                                                                     AS pct_other_cpu_used,
>>%file_sql% echo        avg^(idlecpu^)                                                                                                                    AS pct_sys_cpu_idle
>>%file_sql% echo from ^(select timestamp,
>>%file_sql% echo              record.value^('^(./Record/@id)[1]', 'int') record_id,
>>%file_sql% echo              record.value^('^(./Record/SchedulerMonitorEvent/SystemHealth/SystemIdle)[1]',         'int'^) idlecpu,
>>%file_sql% echo              record.value^('^(./Record/SchedulerMonitorEvent/SystemHealth/ProcessUtilization)[1]', 'int'^) sqlcpu
>>%file_sql% echo 	  from ^(select timestamp, convert^(xml, record^) record
>>%file_sql% echo             from sys.dm_os_ring_buffers WITH ^(NOLOCK^)
>>%file_sql% echo             where ring_buffer_type = 'RING_BUFFER_SCHEDULER_MONITOR'
>>%file_sql% echo             and record like '%%^<SystemHealth^>%%'^) AS x^) AS y
if "%VER_SQL%"=="11.0" >>%file_sql% echo group by datediff(minute, 0, convert^(datetime, format^(dateadd^(ms, -1 * ^(@ts_now - timestamp^), getdate^(^)^), '%FMT_DAT2%'^),3^)^)/10
if "%VER_SQL%"=="12.0" >>%file_sql% echo group by datediff(minute, 0, convert^(datetime, format^(dateadd^(ms, -1 * ^(@ts_now - timestamp^), getdate^(^)^), '%FMT_DAT2%'^),3^)^)/10
if "%VER_SQL%"=="13.0" >>%file_sql% echo group by datediff(minute, 0, convert^(datetime, format^(dateadd^(ms, -1 * ^(@ts_now - timestamp^), getdate^(^)^), '%FMT_DAT2%'^),3^)^)/10
if "%VER_SQL%"=="14.0" >>%file_sql% echo group by datediff(minute, 0, convert^(datetime, format^(dateadd^(ms, -1 * ^(@ts_now - timestamp^), getdate^(^)^), '%FMT_DAT2%'^),3^)^)/10
if not "%VER_SQL%"=="11.0" if not "%VER_SQL%"=="12.0" if not "%VER_SQL%"=="13.0" if not "%VER_SQL%"=="14.0" >>%file_sql% echo     group by datediff(minute, 0, convert(datetime, left(convert(varchar, dateadd(ms, -1 * (@ts_now - timestamp), getdate()), 3)+' '+
if not "%VER_SQL%"=="11.0" if not "%VER_SQL%"=="12.0" if not "%VER_SQL%"=="13.0" if not "%VER_SQL%"=="14.0" >>%file_sql% echo                                  convert^(varchar, dateadd^(ms, -1 * ^(@ts_now - timestamp), getdate()), 8), 14)))/10
>>%file_sql% echo ) AS z;
>>%file_sql% echo:
>>%file_sql% echo PRINT ''
>>%file_sql% echo select '   *** Avg ***'                                     AS ' ',
>>%file_sql% echo        pct_sql_cpu_used                                     AS 'SQL CPU Used ^(%%^)',
>>%file_sql% echo        pct_other_cpu_used                                   AS 'Other CPU Used ^(%%^)',
>>%file_sql% echo        pct_sys_cpu_idle                                     AS 'SYS CPU Idle ^(%%^)'
>>%file_sql% echo from ^(
if "%VER_SQL%"=="11.0" >>%file_sql% echo select datediff(minute, 0, convert^(datetime, format^(dateadd^(ms, -1 * ^(@ts_now - min^(timestamp^)^), getdate^(^)^), '%FMT_DAT2%'^),3^)^)/10  AS min_time,
if "%VER_SQL%"=="11.0" >>%file_sql% echo                            convert^(datetime, format^(dateadd^(ms, -1 * ^(@ts_now - min^(timestamp^)^), getdate^(^)^), '%FMT_DAT2%'^),3^)      AS date_time,
if "%VER_SQL%"=="12.0" >>%file_sql% echo select datediff(minute, 0, convert^(datetime, format^(dateadd^(ms, -1 * ^(@ts_now - min^(timestamp^)^), getdate^(^)^), '%FMT_DAT2%'^),3^)^)/10  AS min_time,
if "%VER_SQL%"=="12.0" >>%file_sql% echo                            convert^(datetime, format^(dateadd^(ms, -1 * ^(@ts_now - min^(timestamp^)^), getdate^(^)^), '%FMT_DAT2%'^),3^)      AS date_time,
if "%VER_SQL%"=="13.0" >>%file_sql% echo select datediff(minute, 0, convert^(datetime, format^(dateadd^(ms, -1 * ^(@ts_now - min^(timestamp^)^), getdate^(^)^), '%FMT_DAT2%'^),3^)^)/10  AS min_time,
if "%VER_SQL%"=="13.0" >>%file_sql% echo                            convert^(datetime, format^(dateadd^(ms, -1 * ^(@ts_now - min^(timestamp^)^), getdate^(^)^), '%FMT_DAT2%'^),3^)      AS date_time,
if "%VER_SQL%"=="14.0" >>%file_sql% echo select datediff(minute, 0, convert^(datetime, format^(dateadd^(ms, -1 * ^(@ts_now - min^(timestamp^)^), getdate^(^)^), '%FMT_DAT2%'^),3^)^)/10  AS min_time,
if "%VER_SQL%"=="14.0" >>%file_sql% echo                            convert^(datetime, format^(dateadd^(ms, -1 * ^(@ts_now - min^(timestamp^)^), getdate^(^)^), '%FMT_DAT2%'^),3^)      AS date_time,
if not "%VER_SQL%"=="11.0" if not "%VER_SQL%"=="12.0" if not "%VER_SQL%"=="13.0" if not "%VER_SQL%"=="14.0" >>%file_sql% echo select datediff^(minute, 0, convert^(datetime, left^(convert^(varchar, dateadd^(ms, -1 * ^(@ts_now - min^(timestamp^)^), getdate^(^)^), %CNV_DATE%^)+' '+
if not "%VER_SQL%"=="11.0" if not "%VER_SQL%"=="12.0" if not "%VER_SQL%"=="13.0" if not "%VER_SQL%"=="14.0" >>%file_sql% echo                         convert^(varchar, dateadd^(ms, -1 * ^(@ts_now - min^(timestamp^)^), getdate^(^)^), %CNV_TIME%^), 14^)^)^)/10 AS 'min_time',
if not "%VER_SQL%"=="11.0" if not "%VER_SQL%"=="12.0" if not "%VER_SQL%"=="13.0" if not "%VER_SQL%"=="14.0" >>%file_sql% echo        convert^(datetime, left^(convert^(varchar, dateadd^(ms, -1 * ^(@ts_now - min^(timestamp^)^), getdate^(^)^), %CNV_DATE%^)+' '+
if not "%VER_SQL%"=="11.0" if not "%VER_SQL%"=="12.0" if not "%VER_SQL%"=="13.0" if not "%VER_SQL%"=="14.0" >>%file_sql% echo        convert^(varchar, dateadd^(ms, -1 * ^(@ts_now - min^(timestamp^)^), getdate^(^)^), %CNV_TIME%^), 14^)^) AS 'date_time',
>>%file_sql% echo        avg^(sqlcpu^)                                                                                                                     AS pct_sql_cpu_used,
>>%file_sql% echo        avg^(100 - idlecpu - sqlcpu^)                                                                                                     AS pct_other_cpu_used,
>>%file_sql% echo        avg^(idlecpu^)                                                                                                                    AS pct_sys_cpu_idle
>>%file_sql% echo from ^(select timestamp,
>>%file_sql% echo              record.value^('^(./Record/@id)[1]', 'int') record_id,
>>%file_sql% echo              record.value^('^(./Record/SchedulerMonitorEvent/SystemHealth/SystemIdle)[1]',         'int'^) idlecpu,
>>%file_sql% echo              record.value^('^(./Record/SchedulerMonitorEvent/SystemHealth/ProcessUtilization)[1]', 'int'^) sqlcpu
>>%file_sql% echo 	  from ^(select timestamp, convert^(xml, record^) record
>>%file_sql% echo             from sys.dm_os_ring_buffers WITH ^(NOLOCK^)
>>%file_sql% echo             where ring_buffer_type = 'RING_BUFFER_SCHEDULER_MONITOR'
>>%file_sql% echo             and record like '%%^<SystemHealth^>%%'^) AS x^) AS y
>>%file_sql% echo ) AS z;
>>%file_sql% echo:
>>%file_sql% echo PRINT ''
>>%file_sql% echo PRINT '+-------------------+'
>>%file_sql% echo PRINT '^| Context switching ^|'
>>%file_sql% echo PRINT '+-------------------+'
>>%file_sql% echo PRINT ''
>>%file_sql% echo:
>>%file_sql% echo select s.scheduler_id                                                                                                                     AS 'Scheduler ID',
>>%file_sql% echo        s.cpu_id                                                                                                                           AS 'CPU ID',
>>%file_sql% echo        s.preemptive_switches_count                                                                                                        AS 'Preemptive switches',
>>%file_sql% echo        s.context_switches_count                                                                                                           AS 'Context switches',
>>%file_sql% echo        right^(replicate^(' ',13-len^(case when s.current_tasks_count ^> 0 then cast^(s.current_tasks_count as varchar^) else '' end^)^) + 
>>%file_sql% echo              cast^(case when s.current_tasks_count ^> 0 then cast^(s.current_tasks_count  as varchar^)  else '' end as varchar^),13^)           AS 'Current tasks',
>>%file_sql% echo        right^(replicate^(' ',13-len^(case when s.runnable_tasks_count ^> 0 then cast^(s.runnable_tasks_count as varchar^) else '' end^)^) + 
>>%file_sql% echo              cast^(case when s.runnable_tasks_count ^> 0 then cast^(s.runnable_tasks_count as varchar^) else '' end as varchar^),13^)           AS 'Waiting tasks',
>>%file_sql% echo        right^(replicate^(' ',13-len^(case when s.failed_to_create_worker ^> 0 then cast^(s.failed_to_create_worker as varchar^) else '' end^)^) +
>>%file_sql% echo              cast^(case when s.failed_to_create_worker ^> 0 then cast^(s.failed_to_create_worker as varchar^) else '' end as varchar^),13^)     AS ' Failed tasks',
>>%file_sql% echo        right^(replicate^(' ',13-len^(case when s.work_queue_count ^> 0 then cast^(s.work_queue_count as varchar^) else '' end^)^) + 
>>%file_sql% echo              cast^(case when s.work_queue_count ^> 0 then cast^(s.work_queue_count as varchar^) else '' end as varchar^),13^)                   AS 'Pending tasks',
>>%file_sql% echo        right^(replicate^(' ',13-len^(case when s.pending_disk_io_count ^> 0 then cast^(s.pending_disk_io_count as varchar^) else '' end^)^) + 
>>%file_sql% echo              cast^(case when s.pending_disk_io_count ^> 0 then cast^(s.pending_disk_io_count as varchar^) else '' end as varchar^),13^)         AS '   Pending IO'
>>%file_sql% echo from sys.dm_os_schedulers s WITH ^(NOLOCK^)
>>%file_sql% echo where s.scheduler_id ^< 255
>>%file_sql% echo and s.status = 'VISIBLE ONLINE'
>>%file_sql% echo option ^(RECOMPILE^);
>>%file_sql% echo:
goto:EOF
::#
::# End of Audit_cpu
::#************************************************************#

:Audit_user
::#************************************************************#
::# Audits SQL Server logins and Database users with associated sessions
::#
>>%file_sql% echo PRINT ''
>>%file_sql% echo PRINT '+--------+'
>>%file_sql% echo PRINT '^| Logins ^|'
>>%file_sql% echo PRINT '+--------+'
>>%file_sql% echo PRINT ''
>>%file_sql% echo:
>>%file_sql% echo if exists ^(select * from tempdb.sys.all_objects where name like '%%%TMPTAB%%%'^) drop table %TMPTAB%
>>%file_sql% echo go
>>%file_sql% echo create table %TMPTAB%(sid varbinary(85), ntlogin sysname);
>>%file_sql% echo insert into  %TMPTAB% exec sys.sp_validatelogins;
>>%file_sql% echo:
>>%file_sql% echo select left^(l.name, 30^)                                                                   AS 'Login_Name',
>>%file_sql% echo        left^(isnull^(l.default_database_name, ''^), 8^)                                       AS 'Default DB',
>>%file_sql% echo        case l.type when 'S' then 'SQL'
>>%file_sql% echo                    when 'U' then 'WINDOWS' end                                            AS 'Account Type',
>>%file_sql% echo        left^(isnull^(l.default_language_name, ''^), 10^)                                      AS 'Language',
if "%VER_SQL%"=="11.0" >>%file_sql% echo        left^(format^(l.create_date, '%FMT_DAT1%'^),8^)                                          AS 'Create',
if "%VER_SQL%"=="11.0" >>%file_sql% >>%file_sql% echo        case when format^(l.create_date, '%FMT_DAT1%'^) ^<^> format^(l.modify_date, '%FMT_DAT1%'^)
if "%VER_SQL%"=="11.0" >>%file_sql% >>%file_sql% echo             then left^(format^(l.modify_date, '%FMT_DAT2%'^),14^) else '' end             AS 'Modify',
if "%VER_SQL%"=="12.0" >>%file_sql% echo        left^(format^(l.create_date, '%FMT_DAT1%'^),8^)                                          AS 'Create',
if "%VER_SQL%"=="12.0" >>%file_sql% >>%file_sql% echo        case when format^(l.create_date, '%FMT_DAT1%'^) ^<^> format^(l.modify_date, '%FMT_DAT1%'^)
if "%VER_SQL%"=="12.0" >>%file_sql% >>%file_sql% echo             then left^(format^(l.modify_date, '%FMT_DAT2%'^),14^) else '' end             AS 'Modify',
if "%VER_SQL%"=="13.0" >>%file_sql% echo        left^(format^(l.create_date, '%FMT_DAT1%'^),8^)                                          AS 'Create',
if "%VER_SQL%"=="13.0" >>%file_sql% >>%file_sql% echo        case when format^(l.create_date, '%FMT_DAT1%'^) ^<^> format^(l.modify_date, '%FMT_DAT1%'^)
if "%VER_SQL%"=="13.0" >>%file_sql% >>%file_sql% echo             then left^(format^(l.modify_date, '%FMT_DAT2%'^),14^) else '' end             AS 'Modify',
if "%VER_SQL%"=="14.0" >>%file_sql% echo        left^(format^(l.create_date, '%FMT_DAT1%'^),8^)                                          AS 'Create',
if "%VER_SQL%"=="14.0" >>%file_sql% >>%file_sql% echo        case when format^(l.create_date, '%FMT_DAT1%'^) ^<^> format^(l.modify_date, '%FMT_DAT1%'^)
if "%VER_SQL%"=="14.0" >>%file_sql% >>%file_sql% echo             then left^(format^(l.modify_date, '%FMT_DAT2%'^),14^) else '' end             AS 'Modify',
if not "%VER_SQL%"=="11.0" if not "%VER_SQL%"=="12.0" if not "%VER_SQL%"=="13.0" if not "%VER_SQL%"=="14.0" >>%file_sql% echo        left^(convert^(varchar, l.create_date, %CNV_DATE%^),10^)                                        AS 'Create',
if not "%VER_SQL%"=="11.0" if not "%VER_SQL%"=="12.0" if not "%VER_SQL%"=="13.0" if not "%VER_SQL%"=="14.0" >>%file_sql% >>%file_sql% echo        case when convert^(varchar, l.create_date, %CNV_DATE%^) ^<^> convert^(varchar, l.modify_date, %CNV_DATE%^)
if not "%VER_SQL%"=="11.0" if not "%VER_SQL%"=="12.0" if not "%VER_SQL%"=="13.0" if not "%VER_SQL%"=="14.0" >>%file_sql% >>%file_sql% echo             then left^(convert^(varchar, l.modify_date, %CNV_DATE%^)+' '+
if not "%VER_SQL%"=="11.0" if not "%VER_SQL%"=="12.0" if not "%VER_SQL%"=="13.0" if not "%VER_SQL%"=="14.0" >>%file_sql% >>%file_sql% echo                        convert^(varchar, l.modify_date, %CNV_TIME%^),14^) else '' end                 AS 'Modify',
>>%file_sql% echo        case l.is_disabled when '1' then 'Yes' else '' end                                 AS 'Disable',
>>%file_sql% echo        case when i.ntlogin is not null then 'Yes' else '' end                             AS 'Invalid'
>>%file_sql% echo from sys.server_principals l
>>%file_sql% echo left outer join %TMPTAB% i on i.ntlogin = l.name
>>%file_sql% echo where l.type IN ^('U', 'S'^)
>>%file_sql% echo and l.name not like '%%##%%'
if defined LOGIN >>%file_sql% echo and l.name = '%LOGIN%'    -- Lists only for a login
>>%file_sql% echo order by l.name;
>>%file_sql% echo:
>>%file_sql% echo PRINT ''
>>%file_sql% echo PRINT '** Members of the "Local Administrators" group on SQL Server **'
>>%file_sql% echo PRINT ''
>>%file_sql% echo:
>>%file_sql% echo if exists (select * from tempdb.sys.all_objects where name like '%%%TMPTAB%%%') drop table %TMPTAB%
>>%file_sql% echo go
>>%file_sql% echo create table %TMPTAB% ^(AccountName varchar^(60^), Type varchar^(5^), Privilege varchar^(5^), LoginName varchar^(60^), Permission varchar^(100^)^);
>>%file_sql% echo begin
>>%file_sql% echo    declare cur_Loginfetch cursor for select name from master.sys.server_principals where type = 'G'
>>%file_sql% echo    declare @LoginName sysname
>>%file_sql% echo    open cur_Loginfetch
>>%file_sql% echo    fetch next from cur_Loginfetch into @LoginName
>>%file_sql% echo    while @@FETCH_STATUS = 0
>>%file_sql% echo    begin
>>%file_sql% echo       insert into  %TMPTAB% ^(AccountName, Type, Privilege, LoginName, Permission^) EXEC xp_logininfo @LoginName, 'members'
>>%file_sql% echo       fetch next from cur_Loginfetch into @LoginName
>>%file_sql% echo    end
>>%file_sql% echo    close cur_Loginfetch
>>%file_sql% echo    deallocate cur_Loginfetch
>>%file_sql% echo    return
>>%file_sql% echo end;
>>%file_sql% echo go
>>%file_sql% echo:
>>%file_sql% echo select left^(r.AccountName, 60^) AS 'Account Name',
>>%file_sql% echo 	   left^(r.Permission, 30^)  AS 'Permission',
>>%file_sql% echo        r.Type                  AS 'Type',
>>%file_sql% echo 	   left^(r.Privilege, 30^)   AS 'Privilege'
>>%file_sql% echo from %TMPTAB% r
>>%file_sql% echo order by 1, 2;
>>%file_sql% echo:
>>%file_sql% echo PRINT ''
>>%file_sql% echo PRINT '** Sysadmins server role''s members **'
>>%file_sql% echo PRINT ''
>>%file_sql% echo:
>>%file_sql% echo if exists (select * from tempdb.sys.all_objects where name like '%%%TMPTAB%%%') drop table %TMPTAB%
>>%file_sql% echo go
>>%file_sql% echo create table %TMPTAB% ^(ServerRole varchar(^20^), MemberName sysname, sid VARBINARY^(85^)^);
>>%file_sql% echo insert into  %TMPTAB% ^(ServerRole, MemberName, sid^) EXEC sp_helpsrvrolemember;
>>%file_sql% echo select left^(l.name, 30^)       AS 'Member Name',
>>%file_sql% echo        left^(r.ServerRole, 10^) AS 'Server role'
>>%file_sql% echo from sys.syslogins l
>>%file_sql% echo join %TMPTAB% r on r.sid = l.sid
>>%file_sql% echo order by 1, 2;
>>%file_sql% echo if exists ^(select * from tempdb.sys.all_objects where name like '%%%TMPTAB%%%'^) drop table %TMPTAB%
>>%file_sql% echo go
>>%file_sql% echo:
>>%file_sql% echo PRINT ''
>>%file_sql% echo PRINT '+----------+'
>>%file_sql% echo PRINT '^| DB Users ^|'
>>%file_sql% echo PRINT '+----------+'
>>%file_sql% echo PRINT ''
>>%file_sql% echo:
if     defined SQL_BDD >>%file_sql% echo exec sp_MSforeachdb @command1='if db_id^(''?''^) ^<= 4 or db_name^(db_id^(''?''^)^) ^<^>''%SQL_BDD%'' return; use [?]; print ''*** ? ***''; print ''''
if not defined SQL_BDD >>%file_sql% echo exec sp_MSforeachdb @command1='if db_id^(''?''^) ^<= 4 return; use [?]; print ''*** ? ***''; print ''''
>>%file_sql% echo select left^(u.name, 30^)                                                                     AS ''DB User'',
>>%file_sql% echo        left^(isnull^(u.default_schema_name,''''^), 10^)                                         AS ''Default schema'',
if "%VER_SQL%"=="11.0" >>%file_sql% echo        left^(format^(u.create_date, ''%FMT_DAT1%''^),8^)                                          AS ''Create'',
if "%VER_SQL%"=="11.0" >>%file_sql% echo        case when format^(u.create_date, ''%FMT_DAT1%''^) ^<^> format^(u.modify_date, ''%FMT_DAT1%''^)
if "%VER_SQL%"=="11.0" >>%file_sql% echo        then left^(format^(u.modify_date, ''%FMT_DAT2%''^),14^) else '''' end                AS ''Modify''
if "%VER_SQL%"=="12.0" >>%file_sql% echo        left^(format^(u.create_date, ''%FMT_DAT1%''^),8^)                                          AS ''Create'',
if "%VER_SQL%"=="12.0" >>%file_sql% echo        case when format^(u.create_date, ''%FMT_DAT1%''^) ^<^> format^(u.modify_date, ''%FMT_DAT1%''^)
if "%VER_SQL%"=="12.0" >>%file_sql% echo        then left^(format^(u.modify_date, ''%FMT_DAT2%''^),14^) else '''' end                AS ''Modify''
if "%VER_SQL%"=="13.0" >>%file_sql% echo        left^(format^(u.create_date, ''%FMT_DAT1%''^),8^)                                          AS ''Create'',
if "%VER_SQL%"=="13.0" >>%file_sql% echo        case when format^(u.create_date, ''%FMT_DAT1%''^) ^<^> format^(u.modify_date, ''%FMT_DAT1%''^)
if "%VER_SQL%"=="13.0" >>%file_sql% echo        then left^(format^(u.modify_date, ''%FMT_DAT2%''^),14^) else '''' end                AS ''Modify''
if "%VER_SQL%"=="14.0" >>%file_sql% echo        left^(format^(u.create_date, ''%FMT_DAT1%''^),8^)                                          AS ''Create'',
if "%VER_SQL%"=="14.0" >>%file_sql% echo        case when format^(u.create_date, ''%FMT_DAT1%''^) ^<^> format^(u.modify_date, ''%FMT_DAT1%''^)
if "%VER_SQL%"=="14.0" >>%file_sql% echo        then left^(format^(u.modify_date, ''%FMT_DAT2%''^),14^) else '''' end                AS ''Modify''
if not "%VER_SQL%"=="11.0" if not "%VER_SQL%"=="12.0" if not "%VER_SQL%"=="13.0" if not "%VER_SQL%"=="14.0" >>%file_sql% echo        left^(convert^(varchar, u.create_date, %CNV_DATE%^),10^)                                          AS ''Create'',
if not "%VER_SQL%"=="11.0" if not "%VER_SQL%"=="12.0" if not "%VER_SQL%"=="13.0" if not "%VER_SQL%"=="14.0" >>%file_sql% echo        case when convert^(varchar, u.create_date, 3^) ^<^> convert^(varchar, u.modify_date, 3^)
if not "%VER_SQL%"=="11.0" if not "%VER_SQL%"=="12.0" if not "%VER_SQL%"=="13.0" if not "%VER_SQL%"=="14.0" >>%file_sql% echo             then left^(convert^(varchar, u.modify_date, 3^)+'' ''+
if not "%VER_SQL%"=="11.0" if not "%VER_SQL%"=="12.0" if not "%VER_SQL%"=="13.0" if not "%VER_SQL%"=="14.0" >>%file_sql% echo                        convert^(varchar, u.modify_date, 8^),14^) else '''' end                 AS ''Modify''
>>%file_sql% echo from sys.database_principals u
>>%file_sql% echo where u.type = ''S''
>>%file_sql% echo order by 1; print ''''';
>>%file_sql% echo:
>>%file_sql% echo PRINT '+--------------+'
>>%file_sql% echo PRINT '^| Role members ^|'
>>%file_sql% echo PRINT '+--------------+'
>>%file_sql% echo PRINT ''
>>%file_sql% echo:
if     defined SQL_BDD >>%file_sql% echo exec sp_MSforeachdb @command1='if db_id^(''?''^) ^<= 4 or db_name^(db_id^(''?''^)^) ^<^>''%SQL_BDD%'' return; use [?]; print ''*** ? ***''; print ''''
if not defined SQL_BDD >>%file_sql% echo exec sp_MSforeachdb @command1='if db_id^(''?''^) ^<= 4 return; use [?]; print ''*** ? ***''; print ''''
>>%file_sql% echo select left^(m.name, 30^) AS ''Member'',
>>%file_sql% echo        left^(r.name, 30^) AS ''Role''
>>%file_sql% echo from sys.database_role_members rm
>>%file_sql% echo join sys.database_principals r on r.principal_id = rm.role_principal_id 
>>%file_sql% echo join sys.database_principals m on m.principal_id = rm.member_principal_id
>>%file_sql% echo order by 1, 2; print ''''';
>>%file_sql% echo:
>>%file_sql% echo PRINT '+--------+'
>>%file_sql% echo PRINT '^| Grants ^|'
>>%file_sql% echo PRINT '+--------+'
>>%file_sql% echo PRINT ''
>>%file_sql% echo: 
if     defined SQL_BDD >>%file_sql% echo exec sp_MSforeachdb @command1='if db_id^(''?''^) ^<= 4 or db_name^(db_id^(''?''^)^) ^<^>''%SQL_BDD%'' return; use [?]; print ''*** ? ***''; print ''''
if not defined SQL_BDD >>%file_sql% echo exec sp_MSforeachdb @command1='if db_id^(''?''^) ^<= 4 return; use [?]; print ''*** ? ***''; print ''''
>>%file_sql% echo select left^(pr.name, 30^)                                                                    AS ''Granted'',
>>%file_sql% echo        left^(pr.type_desc, 15^)                                                               AS ''Type'', 
if not "%VER_SQL%"=="9.0" if not "%VER_SQL%"=="10.0" if not "%VER_SQL%"=="10.5" >>%file_sql% echo        left^(case pr.authentication_type when 0 then ''''
if not "%VER_SQL%"=="9.0" if not "%VER_SQL%"=="10.0" if not "%VER_SQL%"=="10.5" >>%file_sql% echo                                         when 1 then ''INSTANCE''
if not "%VER_SQL%"=="9.0" if not "%VER_SQL%"=="10.0" if not "%VER_SQL%"=="10.5" >>%file_sql% echo                                         when 2 then ''DATABASE''
if not "%VER_SQL%"=="9.0" if not "%VER_SQL%"=="10.0" if not "%VER_SQL%"=="10.5" >>%file_sql% echo                                         when 3 then ''WINDOWS'' end, 14^)                    AS ''Authentication'',
>>%file_sql% echo        left^(pe.state_desc, 6^)                                                               AS ''Status'',
>>%file_sql% echo        left^(pe.permission_name, 20^)                                                         AS ''Permission'',
>>%file_sql% echo        left^(pe.class_desc, 15^)                                                              AS ''Class'',
>>%file_sql% echo        case when count(isnull^(o.name,0^))=0 then '''' else right(replicate('' '',12) + 
>>%file_sql% echo        case when count(isnull^(o.name,0^))=0 then '''' else cast(count(isnull^(o.name,0^)) as varchar) end, 12) end AS ''Object count''
>>%file_sql% echo from sys.database_principals pr
>>%file_sql% echo join sys.database_permissions pe on pe.grantee_principal_id = pr.principal_id
>>%file_sql% echo left join sys.objects o on o.object_id = pe.major_id
if "%VER_SQL%"=="9.0"  >>%file_sql% echo group by pr.name, pr.type_desc, pe.state_desc, pe.permission_name, pe.class_desc
if "%VER_SQL%"=="10.0" >>%file_sql% echo group by pr.name, pr.type_desc, pe.state_desc, pe.permission_name, pe.class_desc
if "%VER_SQL%"=="10.5" >>%file_sql% echo group by pr.name, pr.type_desc, pe.state_desc, pe.permission_name, pe.class_desc
if not "%VER_SQL%"=="9.0" if not "%VER_SQL%"=="10.0" if not "%VER_SQL%"=="10.5" >>%file_sql% echo group by pr.name, pr.type_desc, pr.authentication_type, pe.state_desc, pe.permission_name, pe.class_desc
if "%VER_SQL%"=="9.0"   >>%file_sql% echo order by 1, 6 desc, 4; print ''''';
if "%VER_SQL%"=="10.0"  >>%file_sql% echo order by 1, 6 desc, 4; print ''''';
if "%VER_SQL%"=="10.5"  >>%file_sql% echo order by 1, 6 desc, 4; print ''''';
if not "%VER_SQL%"=="9.0" if not "%VER_SQL%"=="10.0" if not "%VER_SQL%"=="10.5" >>%file_sql% echo order by 1, 7 desc, 4; print ''''';
>>%file_sql% echo:
>>%file_sql% echo PRINT '+--------------------+'
>>%file_sql% echo PRINT '^| Logins not granted ^|'
>>%file_sql% echo PRINT '+--------------------+'
>>%file_sql% echo PRINT ''
>>%file_sql% echo:
>>%file_sql% echo if exists ^(select * from tempdb.sys.all_objects where name like '%%%TMPTAB%%%'^) drop table %TMPTAB%
>>%file_sql% echo go
>>%file_sql% echo create table %TMPTAB%^(db varchar^(70^), sid varbinary^(85^), stat varchar^(50^)^);
>>%file_sql% echo:
if     defined SQL_BDD >>%file_sql% echo exec sp_MSforeachdb @command1='if db_id^(''?''^) ^<= 4 or db_name^(db_id^(''?''^)^) ^<^>''%SQL_BDD%'' return; use [?]; insert %TMPTAB%
if not defined SQL_BDD >>%file_sql% echo exec sp_MSforeachdb @command1='if db_id^(''?''^) ^<= 4 return; use [?]; insert %TMPTAB%
>>%file_sql% echo select ''?'',
>>%file_sql% echo        convert^(varbinary^(85^), sid^), 
>>%file_sql% echo        case when r.role_principal_id is null and p.major_id is null then ''NO_DB_PERM'' else ''DB_USER'' end
>>%file_sql% echo from sys.database_principals u
>>%file_sql% echo left join sys.database_permissions  p on u.principal_id = p.grantee_principal_id and p.permission_name ^<^> ''CONNECT''
>>%file_sql% echo left join sys.database_role_members r on u.principal_id = r.member_principal_id
>>%file_sql% echo where u.sid is not null
>>%file_sql% echo and   u.type_desc ^<^> ''DATABASE_ROLE''';
>>%file_sql% echo:
>>%file_sql% echo if exists ^(select l.name
>>%file_sql% echo            from sys.server_principals l
>>%file_sql% echo            left join sys.server_permissions  p on l.principal_id = p.grantee_principal_id  and p.permission_name ^<^> 'CONNECT SQL'
>>%file_sql% echo            left join sys.server_role_members r on l.principal_id = r.member_principal_id
>>%file_sql% echo            left join %TMPTAB% o          on l.sid = o.sid
>>%file_sql% echo            where r.role_principal_id is null
>>%file_sql% echo            and l.type_desc ^<^> 'SERVER_ROLE' 
>>%file_sql% echo            and   l.name not like '##%%'
>>%file_sql% echo            and   p.major_id is null^)
>>%file_sql% echo begin
>>%file_sql% echo   select distinct
>>%file_sql% echo          left^(l.name, %LEN_LOGIN%^)                                                                                         AS 'Login Name',
>>%file_sql% echo          left^(replace^(l.type_desc,'_',' '^), 25^)                                                                   AS 'Type',
>>%file_sql% echo          left^(case when l.is_disabled = 1 then 'Yes' else ' ' end, 8^)                                             AS 'Disabled', 
>>%file_sql% echo          left^(isnull^(o.stat + ', DB_USER IN ' + o.db  + ' DB', 'NO_DB_USER'^) +  
>>%file_sql% echo          case when p.major_id is null and r.role_principal_id is null then ', NO_SRV_PERMISSION' else '' end, 35) AS 'Permissions'
>>%file_sql% echo   from sys.server_principals l
>>%file_sql% echo   left join sys.server_permissions  p on l.principal_id = p.grantee_principal_id and p.permission_name ^<^> 'CONNECT SQL'
>>%file_sql% echo   left join sys.server_role_members r on l.principal_id = r.member_principal_id
>>%file_sql% echo   left join %TMPTAB% o          on l.sid = o.sid
>>%file_sql% echo   where l.type_desc ^<^> 'SERVER_ROLE' 
>>%file_sql% echo   and   l.name not like '##%%'
>>%file_sql% echo   and ^(^(o.db  is null and p.major_id is null and r.role_principal_id is null^) or
>>%file_sql% echo        ^(o.stat = 'no_db_permissions' and p.major_id is null and r.role_principal_id is null^)^) 
>>%file_sql% echo   order by 1, 4
>>%file_sql% echo end
>>%file_sql% echo go
>>%file_sql% echo:
>>%file_sql% echo PRINT ''
>>%file_sql% echo PRINT '+----------------+'
>>%file_sql% echo PRINT '^| Orphaned users ^|'
>>%file_sql% echo PRINT '+----------------+'
>>%file_sql% echo PRINT ''
>>%file_sql% echo:
if not "%VER_SQL%"=="9.0" if not "%VER_SQL%"=="10.0" if not "%VER_SQL%"=="10.5" >>%file_sql% echo if exists ^(select * from tempdb.sys.all_objects where name like '%%%TMPTAB%%%'^) drop table %TMPTAB%
if not "%VER_SQL%"=="9.0" if not "%VER_SQL%"=="10.0" if not "%VER_SQL%"=="10.5" >>%file_sql% echo go
if not "%VER_SQL%"=="9.0" if not "%VER_SQL%"=="10.0" if not "%VER_SQL%"=="10.5" >>%file_sql% echo create table %TMPTAB%^(dbname sysname, username sysname, schemaname varchar^(30^)^);
if not "%VER_SQL%"=="9.0" if not "%VER_SQL%"=="10.0" if not "%VER_SQL%"=="10.5" >>%file_sql% echo:
if not "%VER_SQL%"=="9.0" if not "%VER_SQL%"=="10.0" if not "%VER_SQL%"=="10.5" if     defined SQL_BDD >>%file_sql% echo exec sp_MSforeachdb @command1='if db_id^(''?''^) ^<= 4 or db_name^(db_id^(''?''^)^) ^<^>''%SQL_BDD%'' return; use [?]; insert %TMPTAB%
if not "%VER_SQL%"=="9.0" if not "%VER_SQL%"=="10.0" if not "%VER_SQL%"=="10.5" if not defined SQL_BDD >>%file_sql% echo exec sp_MSforeachdb @command1='if db_id^(''?''^) ^<= 4 return; use [?]; insert %TMPTAB%
if not "%VER_SQL%"=="9.0" if not "%VER_SQL%"=="10.0" if not "%VER_SQL%"=="10.5" >>%file_sql% echo select ''?'', d.name, d.default_schema_name
if not "%VER_SQL%"=="9.0" if not "%VER_SQL%"=="10.0" if not "%VER_SQL%"=="10.5" >>%file_sql% echo from sys.database_principals d  
if not "%VER_SQL%"=="9.0" if not "%VER_SQL%"=="10.0" if not "%VER_SQL%"=="10.5" >>%file_sql% echo left join sys.server_principals s on d.sid = s.sid  
if not "%VER_SQL%"=="9.0" if not "%VER_SQL%"=="10.0" if not "%VER_SQL%"=="10.5" >>%file_sql% echo where d.authentication_type_desc = ''INSTANCE''
if not "%VER_SQL%"=="9.0" if not "%VER_SQL%"=="10.0" if not "%VER_SQL%"=="10.5" >>%file_sql% echo and   s.sid is null;';
if not "%VER_SQL%"=="9.0" if not "%VER_SQL%"=="10.0" if not "%VER_SQL%"=="10.5" >>%file_sql% echo:
if not "%VER_SQL%"=="9.0" if not "%VER_SQL%"=="10.0" if not "%VER_SQL%"=="10.5" >>%file_sql% echo select left^(o.dbname , %LEN_DBNAME%^)     AS 'DB Name',
if not "%VER_SQL%"=="9.0" if not "%VER_SQL%"=="10.0" if not "%VER_SQL%"=="10.5" >>%file_sql% echo        left^(o.username, %LEN_LOGIN%^)   AS 'Username',
if not "%VER_SQL%"=="9.0" if not "%VER_SQL%"=="10.0" if not "%VER_SQL%"=="10.5" >>%file_sql% echo        left^(o.schemaname, %LEN_LOGIN%^) AS 'Schema Name'
if not "%VER_SQL%"=="9.0" if not "%VER_SQL%"=="10.0" if not "%VER_SQL%"=="10.5" >>%file_sql% echo from %TMPTAB% o;
if not "%VER_SQL%"=="9.0" if not "%VER_SQL%"=="10.0" if not "%VER_SQL%"=="10.5" >>%file_sql% echo:
if not "%VER_SQL%"=="9.0" if not "%VER_SQL%"=="10.0" if not "%VER_SQL%"=="10.5" >>%file_sql% echo if exists ^(select * from tempdb.sys.all_objects where name like '%%%TMPTAB%%%'^) drop table %TMPTAB%
if not "%VER_SQL%"=="9.0" if not "%VER_SQL%"=="10.0" if not "%VER_SQL%"=="10.5" >>%file_sql% echo go
if "%VER_SQL%"=="9.0"  >>%file_sql% echo exec sp_change_users_login @Action='Report'
if "%VER_SQL%"=="10.0" >>%file_sql% echo exec sp_change_users_login @Action='Report'
if "%VER_SQL%"=="10.5" >>%file_sql% echo exec sp_change_users_login @Action='Report'
>>%file_sql% echo:
>>%file_sql% echo PRINT ''
>>%file_sql% echo PRINT '+---------------+'
>>%file_sql% echo PRINT '^| Session Count ^|'
>>%file_sql% echo PRINT '+---------------+'
>>%file_sql% echo:
>>%file_sql% echo PRINT ''
>>%file_sql% echo PRINT '*** Ordered by Database ***'
>>%file_sql% echo PRINT ''
>>%file_sql% echo select left^(isnull^(d.name, 'master'^), %LEN_DBNAME%^) AS 'DB Name',
>>%file_sql% echo        left^(s.login_name,%LEN_LOGIN%^)             AS 'Login Name',
>>%file_sql% echo        count^(s.session_id^)               AS '      Count'
>>%file_sql% echo from sys.dm_exec_sessions s WITH ^(NOLOCK^)
>>%file_sql% echo inner join sys.sysprocesses p WITH ^(NOLOCK^) on p.spid = s.session_id
>>%file_sql% echo left outer join sys.sysdatabases d on ^(d.dbid = p.dbid^)
if defined LOGIN >>%file_sql% echo where s.login_name = '%LOGIN%'    -- Lists only for a login
if defined SQL_BDD >>%file_sql% echo and isnull^(d.name, 'master'^) = '%SQL_BDD%'
>>%file_sql% echo group by isnull^(d.name, 'master'^), s.login_name
>>%file_sql% echo union
>>%file_sql% echo select '*** TOTAL ***', '', count^(s.session_id^)
>>%file_sql% echo from sys.dm_exec_sessions s WITH ^(NOLOCK^)
>>%file_sql% echo inner join sys.sysprocesses p WITH ^(NOLOCK^) on p.spid = s.session_id
>>%file_sql% echo left outer join sys.sysdatabases d on ^(d.dbid = p.dbid^)
if defined LOGIN >>%file_sql% echo where s.login_name = '%LOGIN%'    -- Lists only for a login
if defined SQL_BDD >>%file_sql% echo and isnull^(d.name, 'master'^) = '%SQL_BDD%' 
>>%file_sql% echo OPTION (RECOMPILE);
>>%file_sql% echo:
>>%file_sql% echo PRINT ''
>>%file_sql% echo PRINT '*** Ordered by Login ***'
>>%file_sql% echo PRINT ''
>>%file_sql% echo select left^(s.login_name,%LEN_LOGIN%^)                                                 AS 'Login Name',
if "%VER_SQL%"=="11.0" >>%file_sql% echo        left^(format^(min^(s.login_time^), '%FMT_DAT3%'^),17^)               AS 'Min Login Time',
if "%VER_SQL%"=="12.0" >>%file_sql% echo        left^(format^(min^(s.login_time^), '%FMT_DAT3%'^),17^)               AS 'Min Login Time',
if "%VER_SQL%"=="13.0" >>%file_sql% echo        left^(format^(min^(s.login_time^), '%FMT_DAT3%'^),17^)               AS 'Min Login Time',
if "%VER_SQL%"=="14.0" >>%file_sql% echo        left^(format^(min^(s.login_time^), '%FMT_DAT3%'^),17^)               AS 'Min Login Time',
if not "%VER_SQL%"=="11.0" if not "%VER_SQL%"=="12.0" if not "%VER_SQL%"=="13.0" if not "%VER_SQL%"=="14.0" >>%file_sql% echo        left^(convert^(varchar, min^(s.login_time^), %CNV_DATE%^)+' '+
if not "%VER_SQL%"=="11.0" if not "%VER_SQL%"=="12.0" if not "%VER_SQL%"=="13.0" if not "%VER_SQL%"=="14.0" >>%file_sql% echo             convert^(varchar, min^(s.login_time^), %CNV_TIME%^),17^)                       AS 'Min Login Time',
if not "%VER_SQL%"=="11.0" if not "%VER_SQL%"=="12.0" if not "%VER_SQL%"=="13.0" if not "%VER_SQL%"=="14.0" >>%file_sql% echo        left^(convert^(varchar, max^(s.login_time^), %CNV_DATE%^)+' '+
if not "%VER_SQL%"=="11.0" if not "%VER_SQL%"=="12.0" if not "%VER_SQL%"=="13.0" if not "%VER_SQL%"=="14.0" >>%file_sql% echo             convert^(varchar, max^(s.login_time^), %CNV_TIME%^),17^)                       AS 'Max Login Time',
if "%VER_SQL%"=="11.0" >>%file_sql% echo        left^(format^(max^(s.login_time^), '%FMT_DAT3%'^),17^)               AS 'Max Login Time',
if "%VER_SQL%"=="12.0" >>%file_sql% echo        left^(format^(max^(s.login_time^), '%FMT_DAT3%'^),17^)               AS 'Max Login Time',
if "%VER_SQL%"=="13.0" >>%file_sql% echo        left^(format^(max^(s.login_time^), '%FMT_DAT3%'^),17^)               AS 'Max Login Time',
if "%VER_SQL%"=="14.0" >>%file_sql% echo        left^(format^(max^(s.login_time^), '%FMT_DAT3%'^),17^)               AS 'Max Login Time',
>>%file_sql% echo 	   left^(case when s.nt_user_name ^> '' then 'Windows Authentication'
>>%file_sql% echo 	                                      else 'SQL Authentication' end, 22^) AS 'Authentication method',
>>%file_sql% echo        count^(s.session_id^)                                                   AS '      Count'
>>%file_sql% echo from sys.dm_exec_sessions s WITH ^(NOLOCK^)
>>%file_sql% echo inner join sys.dm_exec_connections c on s.session_id = c.session_id
if defined LOGIN >>%file_sql% echo where s.login_name = '%LOGIN%'    -- Lists only for a login
>>%file_sql% echo group by s.login_name, s.nt_user_name
>>%file_sql% echo union
>>%file_sql% echo select '*** TOTAL ***',
if "%VER_SQL%"=="11.0" >>%file_sql% echo        left^(format^(min^(s.login_time^), '%FMT_DAT3%'^),17^),
if "%VER_SQL%"=="11.0" >>%file_sql% echo        left^(format^(max^(s.login_time^), '%FMT_DAT3%'^),17^),
if "%VER_SQL%"=="12.0" >>%file_sql% echo        left^(format^(min^(s.login_time^), '%FMT_DAT3%'^),17^),
if "%VER_SQL%"=="12.0" >>%file_sql% echo        left^(format^(max^(s.login_time^), '%FMT_DAT3%'^),17^),
if "%VER_SQL%"=="13.0" >>%file_sql% echo        left^(format^(min^(s.login_time^), '%FMT_DAT3%'^),17^),
if "%VER_SQL%"=="13.0" >>%file_sql% echo        left^(format^(max^(s.login_time^), '%FMT_DAT3%'^),17^),
if "%VER_SQL%"=="14.0" >>%file_sql% echo        left^(format^(min^(s.login_time^), '%FMT_DAT3%'^),17^),
if "%VER_SQL%"=="14.0" >>%file_sql% echo        left^(format^(max^(s.login_time^), '%FMT_DAT3%'^),17^),
if not "%VER_SQL%"=="11.0" if not "%VER_SQL%"=="12.0" if not "%VER_SQL%"=="13.0" if not "%VER_SQL%"=="14.0" >>%file_sql% echo        left^(convert^(varchar, min^(s.login_time^), %CNV_DATE%^)+' '+
if not "%VER_SQL%"=="11.0" if not "%VER_SQL%"=="12.0" if not "%VER_SQL%"=="13.0" if not "%VER_SQL%"=="14.0" >>%file_sql% echo             convert^(varchar, min^(s.login_time^), %CNV_TIME%^),17^),
if not "%VER_SQL%"=="11.0" if not "%VER_SQL%"=="12.0" if not "%VER_SQL%"=="13.0" if not "%VER_SQL%"=="14.0" >>%file_sql% echo        left^(convert^(varchar, max^(s.login_time^), %CNV_DATE%^)+' '+
if not "%VER_SQL%"=="11.0" if not "%VER_SQL%"=="12.0" if not "%VER_SQL%"=="13.0" if not "%VER_SQL%"=="14.0" >>%file_sql% echo             convert^(varchar, max^(s.login_time^), %CNV_TIME%^),17^),
>>%file_sql% echo 	   left^(case when min^(s.nt_user_name^) = max^(s.nt_user_name^)
>>%file_sql% echo 	             then max^(s.nt_user_name^) else 'Mixed Authentication' end, 22^),
>>%file_sql% echo        count^(s.session_id^)
>>%file_sql% echo from sys.dm_exec_sessions s WITH ^(NOLOCK^)
>>%file_sql% echo inner join sys.dm_exec_connections c on s.session_id = c.session_id
if defined LOGIN >>%file_sql% echo where s.login_name = '%LOGIN%'    -- Lists only for a login
>>%file_sql% echo order by 1 OPTION ^(RECOMPILE^);
>>%file_sql% echo:
>>%file_sql% echo PRINT ''
>>%file_sql% echo PRINT '*** Ordered by Program ***'
>>%file_sql% echo PRINT ''
>>%file_sql% echo select left^(case when s.program_name ^> '' then s.program_name else 'N/A' end, 60^) AS 'Program Name',
>>%file_sql% echo        left^(c.client_net_address, 15^)                                             AS 'IP Adress Client',
>>%file_sql% echo        left^(s.host_name, 12^)                                                      AS 'Host Name',
>>%file_sql% echo        left^(c.net_transport, 15^)                                                  AS 'Client Protocol',
>>%file_sql% echo        left^(isnull^(cast^(c.local_tcp_port as varchar^),''^), 8^)                      AS 'TCP port',
>>%file_sql% echo        count^(c.session_id^)                                                        AS '      Count'
>>%file_sql% echo from sys.dm_exec_sessions s WITH ^(NOLOCK^)
>>%file_sql% echo inner join sys.dm_exec_connections c on s.session_id = c.session_id
if defined LOGIN >>%file_sql% echo where ^(s.program_name like '%PROG%%%' and s.login_name = '%LOGIN%'^) or ^(s.program_name not like '%PROG%%%'^)
>>%file_sql% echo group by s.program_name, c.client_net_address, s.host_name, c.net_transport, c.local_tcp_port
>>%file_sql% echo union
>>%file_sql% echo select '*** TOTAL ***', '', '', '', '', count^(c.session_id^)
>>%file_sql% echo from sys.dm_exec_sessions s WITH ^(NOLOCK^)
>>%file_sql% echo inner join sys.dm_exec_connections c on s.session_id = c.session_id
if defined LOGIN >>%file_sql% echo where ^(s.program_name like '%PROG%%%' and s.login_name = '%LOGIN%'^) or ^(s.program_name not like '%PROG%%%'^)
>>%file_sql% echo order by 1, 5 desc OPTION ^(RECOMPILE^);
>>%file_sql% echo:
>>%file_sql% echo PRINT ''
>>%file_sql% echo PRINT '+-------------------------+'
>>%file_sql% echo PRINT '^| Session usage ^(summary^) ^|'
>>%file_sql% echo PRINT '+-------------------------+'
>>%file_sql% echo PRINT ''
>>%file_sql% echo:
>>%file_sql% echo select left^(d.name, %LEN_DBNAME%^)                                                                AS 'DB Name',
>>%file_sql% echo 	     cast^(count^(s.session_id^) as int^)                                                        AS 'Sessions',
>>%file_sql% echo        left^(s.login_name, 26^)                                                         AS 'Login Name',
if "%VER_SQL%"=="11.0" >>%file_sql% echo        left^(format^(min^(s.login_time^), '%FMT_DAT3%'^),17^)                        AS 'Min Login Time',
if "%VER_SQL%"=="12.0" >>%file_sql% echo        left^(format^(min^(s.login_time^), '%FMT_DAT3%'^),17^)                        AS 'Min Login Time',
if "%VER_SQL%"=="13.0" >>%file_sql% echo        left^(format^(min^(s.login_time^), '%FMT_DAT3%'^),17^)                        AS 'Min Login Time',
if "%VER_SQL%"=="14.0" >>%file_sql% echo        left^(format^(min^(s.login_time^), '%FMT_DAT3%'^),17^)                        AS 'Min Login Time',
if not "%VER_SQL%"=="11.0" if not "%VER_SQL%"=="12.0" if not "%VER_SQL%"=="13.0" if not "%VER_SQL%"=="14.0" >>%file_sql% echo        left^(convert^(varchar, min^(s.login_time^), %CNV_DATE%^)+' '+
if not "%VER_SQL%"=="11.0" if not "%VER_SQL%"=="12.0" if not "%VER_SQL%"=="13.0" if not "%VER_SQL%"=="14.0" >>%file_sql% echo              convert^(varchar, min^(s.login_time^), %CNV_TIME%^),17^)                               AS 'Min Login Time',
if "%VER_SQL%"=="11.0" >>%file_sql% echo        left^(format^(max^(s.login_time^), '%FMT_DAT3%'^),17^)                        AS 'Max Login Time',
if "%VER_SQL%"=="12.0" >>%file_sql% echo        left^(format^(max^(s.login_time^), '%FMT_DAT3%'^),17^)                        AS 'Max Login Time',
if "%VER_SQL%"=="13.0" >>%file_sql% echo        left^(format^(max^(s.login_time^), '%FMT_DAT3%'^),17^)                        AS 'Max Login Time',
if "%VER_SQL%"=="14.0" >>%file_sql% echo        left^(format^(max^(s.login_time^), '%FMT_DAT3%'^),17^)                        AS 'Max Login Time',
if not "%VER_SQL%"=="11.0" if not "%VER_SQL%"=="12.0" if not "%VER_SQL%"=="13.0" if not "%VER_SQL%"=="14.0" >>%file_sql% echo        left^(convert^(varchar, max^(s.login_time^), %CNV_DATE%^)+' '+
if not "%VER_SQL%"=="11.0" if not "%VER_SQL%"=="12.0" if not "%VER_SQL%"=="13.0" if not "%VER_SQL%"=="14.0" >>%file_sql% echo              convert^(varchar, max^(s.login_time^), %CNV_TIME%^),17^)                               AS 'Max Login Time',
if "%VER_SQL%"=="11.0" >>%file_sql% echo        left^(format^(max^(s.last_request_end_time^), '%FMT_DAT3%'^),17^)             AS 'Last Exec',
if "%VER_SQL%"=="12.0" >>%file_sql% echo        left^(format^(max^(s.last_request_end_time^), '%FMT_DAT3%'^),17^)             AS 'Last Exec',
if "%VER_SQL%"=="13.0" >>%file_sql% echo        left^(format^(max^(s.last_request_end_time^), '%FMT_DAT3%'^),17^)             AS 'Last Exec',
if "%VER_SQL%"=="14.0" >>%file_sql% echo        left^(format^(max^(s.last_request_end_time^), '%FMT_DAT3%'^),17^)             AS 'Last Exec',
if not "%VER_SQL%"=="11.0" if not "%VER_SQL%"=="12.0" if not "%VER_SQL%"=="13.0" if not "%VER_SQL%"=="14.0" >>%file_sql% echo        left^(convert^(varchar, max^(s.last_request_end_time^), %CNV_DATE%^)+' '+
if not "%VER_SQL%"=="11.0" if not "%VER_SQL%"=="12.0" if not "%VER_SQL%"=="13.0" if not "%VER_SQL%"=="14.0" >>%file_sql% echo              convert^(varchar, max^(s.last_request_end_time^), %CNV_TIME%^),17^)                    AS 'Last Exec',
>>%file_sql% echo        sum^(s.total_elapsed_time^)                                                      AS 'Total Elapsed Time ^(s^)',
>>%file_sql% echo        sum^(s.cpu_time^)                                                                AS 'Total CPU Time',
>>%file_sql% echo        sum^(s.memory_usage * 8^)                                                        AS 'Mem Used ^(KB^)',
>>%file_sql% echo        right^(replicate^(' ',9-len^(sum^(s.reads^)^)^)+cast^(sum^(s.reads^) as varchar^),9^)      AS 'Total Reads',
>>%file_sql% echo        right^(replicate^(' ',10-len^(sum^(s.writes^)^)^)+cast^(sum^(s.writes^)  as varchar^),10^) AS 'Total Writes',
>>%file_sql% echo        left^(s.program_name, 60^)                                                       AS 'Program Name'
>>%file_sql% echo from sys.dm_exec_sessions s   WITH ^(NOLOCK^)
>>%file_sql% echo inner join sys.sysprocesses p WITH ^(NOLOCK^) on p.spid = s.session_id
>>%file_sql% echo left outer join sys.dm_exec_connections c on ^(s.session_id = c.session_id^)
>>%file_sql% echo inner join sys.databases d    WITH ^(NOLOCK^) on ^(d.database_id = p.dbid^)
>>%file_sql% echo where s.is_user_process= 1
>>%file_sql% echo and   s.session_id ^<^> @@spid  -- Excludes owner  processes
if defined LOGIN >>%file_sql% echo and   s.login_name = '%LOGIN%'    -- Lists only for a login
if defined SQL_BDD >>%file_sql% echo and d.name = '%SQL_BDD%'
>>%file_sql% echo group by d.name, s.login_name, s.program_name
>>%file_sql% echo order by 2 desc, 6 desc;
>>%file_sql% echo:
>>%file_sql% echo PRINT ''
>>%file_sql% echo PRINT '+------------------------+'
>>%file_sql% echo PRINT '^| Session usage ^(detail^) ^|'
>>%file_sql% echo PRINT '+------------------------+'
>>%file_sql% echo PRINT ''
>>%file_sql% echo:
>>%file_sql% echo select left^(d.name, %LEN_DBNAME%^)                                                             AS 'DB Name',
>>%file_sql% echo        s.session_id                                                                AS '   SID',
>>%file_sql% echo        left^(s.host_process_id,6^)                                                   AS 'PID',
>>%file_sql% echo        left^(s.login_name, %LEN_LOGIN%^)                                                      AS 'Login Name',
if "%VER_SQL%"=="11.0" >>%file_sql% echo        left^(format^(s.login_time, '%FMT_DAT3%'^),17^)                          AS 'Login Time',
if "%VER_SQL%"=="12.0" >>%file_sql% echo        left^(format^(s.login_time, '%FMT_DAT3%'^),17^)                          AS 'Login Time',
if "%VER_SQL%"=="13.0" >>%file_sql% echo        left^(format^(s.login_time, '%FMT_DAT3%'^),17^)                          AS 'Login Time',
if "%VER_SQL%"=="14.0" >>%file_sql% echo        left^(format^(s.login_time, '%FMT_DAT3%'^),17^)                          AS 'Login Time',
if not "%VER_SQL%"=="11.0" if not "%VER_SQL%"=="12.0" if not "%VER_SQL%"=="13.0" if not "%VER_SQL%"=="14.0" >>%file_sql% echo        left^(convert^(varchar, s.login_time, %CNV_DATE%^)+' '+
if not "%VER_SQL%"=="11.0" if not "%VER_SQL%"=="12.0" if not "%VER_SQL%"=="13.0" if not "%VER_SQL%"=="14.0" >>%file_sql% echo              convert^(varchar, s.login_time, %CNV_TIME%^),17^)                                 AS 'Login Time',
>>%file_sql% echo        left^(s.status, 10^)                                                          AS 'Status',
if "%VER_SQL%"=="11.0" >>%file_sql% echo        left^(format^(s.last_request_end_time, '%FMT_DAT3%'^),17^)               AS 'Last Exec',
if "%VER_SQL%"=="12.0" >>%file_sql% echo        left^(format^(s.last_request_end_time, '%FMT_DAT3%'^),17^)               AS 'Last Exec',
if "%VER_SQL%"=="13.0" >>%file_sql% echo        left^(format^(s.last_request_end_time, '%FMT_DAT3%'^),17^)               AS 'Last Exec',
if "%VER_SQL%"=="14.0" >>%file_sql% echo        left^(format^(s.last_request_end_time, '%FMT_DAT3%'^),17^)               AS 'Last Exec',
if not "%VER_SQL%"=="11.0" if not "%VER_SQL%"=="12.0" if not "%VER_SQL%"=="13.0" if not "%VER_SQL%"=="14.0" >>%file_sql% echo        left^(convert^(varchar, s.last_request_end_time, %CNV_DATE%^)+' '+
if not "%VER_SQL%"=="11.0" if not "%VER_SQL%"=="12.0" if not "%VER_SQL%"=="13.0" if not "%VER_SQL%"=="14.0" >>%file_sql% echo              convert^(varchar, s.last_request_end_time, %CNV_TIME%^),17^)                      AS 'Last Exec',
>>%file_sql% echo        s.total_elapsed_time                                                        AS 'Elapsed Time ^(s^)',
>>%file_sql% echo        s.cpu_time                                                                  AS '   CPU Time',
>>%file_sql% echo        s.memory_usage * 8                                                          AS 'Mem Used ^(KB^)',
>>%file_sql% echo        right^(replicate^(' ',9-len^(s.reads^)^)+cast^(s.reads as varchar^),9^)             AS 'Nbr Reads',
>>%file_sql% echo        right^(replicate^(' ',10-len^(s.writes ^)^)+cast^(s.writes  as varchar^),10^)       AS 'Nbr Writes',
>>%file_sql% echo        right^(replicate^(' ',9-len^(s.row_count^)^)+cast^(s.row_count as varchar^),9^)     AS 'Row Count',
>>%file_sql% echo        case when s.transaction_isolation_level = 1   then 'READ UNCOMMITTED'
>>%file_sql% echo             when s.transaction_isolation_level = 2
>>%file_sql% echo              and d.is_read_committed_snapshot_on = 1 then 'READ COMMITTED SNAPSHOT'
>>%file_sql% echo             when s.transaction_isolation_level = 2
>>%file_sql% echo              and d.is_read_committed_snapshot_on = 0 then 'READ COMMITTED'
>>%file_sql% echo             when s.transaction_isolation_level = 3   then 'REPEATABLE READ'
>>%file_sql% echo             when s.transaction_isolation_level = 4   then 'SERIALIZABLE'
>>%file_sql% echo             when s.transaction_isolation_level = 5   then 'SNAPSHOT' else null end AS 'Isolation Level',
>>%file_sql% echo        left^(s.program_name, 60^)                                                    AS 'Program Name'
>>%file_sql% echo from sys.dm_exec_sessions s   WITH ^(NOLOCK^)
>>%file_sql% echo inner join sys.sysprocesses p WITH ^(NOLOCK^) on p.spid = s.session_id
>>%file_sql% echo left outer join sys.dm_exec_connections c on ^(s.session_id = c.session_id^)
>>%file_sql% echo inner join sys.databases d    WITH ^(NOLOCK^) on ^(d.database_id = p.dbid^)
>>%file_sql% echo where s.is_user_process= 1
>>%file_sql% echo and   s.session_id ^<^> @@spid  -- Excludes owner  processes
if defined LOGIN >>%file_sql% echo and   s.login_name = '%LOGIN%'    -- Lists only for a login
if defined SQL_BDD >>%file_sql% echo and d.name = '%SQL_BDD%'
>>%file_sql% echo order by s.status, d.name, s.last_request_end_time desc, s.login_name;
>>%file_sql% echo:
if not "%VER_SQL%"=="9.0" if not "%VER_SQL%"=="10.0" if not "%VER_SQL%"=="10.5" if not "%VER_SQL%"=="11.0" if not "%VER_SQL%"=="12.0" >>%file_sql% echo PRINT ''
if not "%VER_SQL%"=="9.0" if not "%VER_SQL%"=="10.0" if not "%VER_SQL%"=="10.5" if not "%VER_SQL%"=="11.0" if not "%VER_SQL%"=="12.0" >>%file_sql% echo PRINT '+---------------+'
if not "%VER_SQL%"=="9.0" if not "%VER_SQL%"=="10.0" if not "%VER_SQL%"=="10.5" if not "%VER_SQL%"=="11.0" if not "%VER_SQL%"=="12.0" >>%file_sql% echo PRINT '^| Session waits ^|'
if not "%VER_SQL%"=="9.0" if not "%VER_SQL%"=="10.0" if not "%VER_SQL%"=="10.5" if not "%VER_SQL%"=="11.0" if not "%VER_SQL%"=="12.0" >>%file_sql% echo PRINT '+---------------+'
if not "%VER_SQL%"=="9.0" if not "%VER_SQL%"=="10.0" if not "%VER_SQL%"=="10.5" if not "%VER_SQL%"=="11.0" if not "%VER_SQL%"=="12.0" >>%file_sql% echo PRINT ''
if not "%VER_SQL%"=="9.0" if not "%VER_SQL%"=="10.0" if not "%VER_SQL%"=="10.5" if not "%VER_SQL%"=="11.0" if not "%VER_SQL%"=="12.0" >>%file_sql% echo:
if not "%VER_SQL%"=="9.0" if not "%VER_SQL%"=="10.0" if not "%VER_SQL%"=="10.5" if not "%VER_SQL%"=="11.0" if not "%VER_SQL%"=="12.0" >>%file_sql% echo ;with sess_waits as
if not "%VER_SQL%"=="9.0" if not "%VER_SQL%"=="10.0" if not "%VER_SQL%"=="10.5" if not "%VER_SQL%"=="11.0" if not "%VER_SQL%"=="12.0" >>%file_sql% echo  ^(select  s.wait_type,
if not "%VER_SQL%"=="9.0" if not "%VER_SQL%"=="10.0" if not "%VER_SQL%"=="10.5" if not "%VER_SQL%"=="11.0" if not "%VER_SQL%"=="12.0" >>%file_sql% echo           s.session_id,
if not "%VER_SQL%"=="9.0" if not "%VER_SQL%"=="10.0" if not "%VER_SQL%"=="10.5" if not "%VER_SQL%"=="11.0" if not "%VER_SQL%"=="12.0" >>%file_sql% echo           rank^(^) over ^(partition by s.session_id order by max^(s.wait_time_ms^) desc^) as rank,
if not "%VER_SQL%"=="9.0" if not "%VER_SQL%"=="10.0" if not "%VER_SQL%"=="10.5" if not "%VER_SQL%"=="11.0" if not "%VER_SQL%"=="12.0" >>%file_sql% echo           max^(s.waiting_tasks_count^) as waits,
if not "%VER_SQL%"=="9.0" if not "%VER_SQL%"=="10.0" if not "%VER_SQL%"=="10.5" if not "%VER_SQL%"=="11.0" if not "%VER_SQL%"=="12.0" >>%file_sql% echo           cast^(max^(s.waiting_tasks_count^)*100.0/max^(o.waiting_tasks_count^) as dec ^(4,1^)^) as pct_waits,
if not "%VER_SQL%"=="9.0" if not "%VER_SQL%"=="10.0" if not "%VER_SQL%"=="10.5" if not "%VER_SQL%"=="11.0" if not "%VER_SQL%"=="12.0" >>%file_sql% echo           max^(s.wait_time_ms^)/1000 as wait_time_s,
if not "%VER_SQL%"=="9.0" if not "%VER_SQL%"=="10.0" if not "%VER_SQL%"=="10.5" if not "%VER_SQL%"=="11.0" if not "%VER_SQL%"=="12.0" >>%file_sql% echo           cast^(max^(s.wait_time_ms^)*100.0/max^(o.wait_time_ms^) as dec ^(4,1^)^) as pct_wait_time,
if not "%VER_SQL%"=="9.0" if not "%VER_SQL%"=="10.0" if not "%VER_SQL%"=="10.5" if not "%VER_SQL%"=="11.0" if not "%VER_SQL%"=="12.0" >>%file_sql% echo           max^(s.signal_wait_time_ms^)/1000 as signal_wait_time_s
if not "%VER_SQL%"=="9.0" if not "%VER_SQL%"=="10.0" if not "%VER_SQL%"=="10.5" if not "%VER_SQL%"=="11.0" if not "%VER_SQL%"=="12.0" >>%file_sql% echo   from sys.dm_os_wait_stats o
if not "%VER_SQL%"=="9.0" if not "%VER_SQL%"=="10.0" if not "%VER_SQL%"=="10.5" if not "%VER_SQL%"=="11.0" if not "%VER_SQL%"=="12.0" >>%file_sql% echo   inner join sys.dm_exec_session_wait_stats s on s.wait_type = o.wait_type
if not "%VER_SQL%"=="9.0" if not "%VER_SQL%"=="10.0" if not "%VER_SQL%"=="10.5" if not "%VER_SQL%"=="11.0" if not "%VER_SQL%"=="12.0" >>%file_sql% echo   where s.wait_type not in ^('ASYNC_NETWORK_IO'^)
if not "%VER_SQL%"=="9.0" if not "%VER_SQL%"=="10.0" if not "%VER_SQL%"=="10.5" if not "%VER_SQL%"=="11.0" if not "%VER_SQL%"=="12.0" >>%file_sql% echo   and s.wait_time_ms/1000 ^> 0
if not "%VER_SQL%"=="9.0" if not "%VER_SQL%"=="10.0" if not "%VER_SQL%"=="10.5" if not "%VER_SQL%"=="11.0" if not "%VER_SQL%"=="12.0" >>%file_sql% echo   and s.signal_wait_time_ms/1000 ^> 0
if not "%VER_SQL%"=="9.0" if not "%VER_SQL%"=="10.0" if not "%VER_SQL%"=="10.5" if not "%VER_SQL%"=="11.0" if not "%VER_SQL%"=="12.0" >>%file_sql% echo   group by s.session_id, s.wait_type
if not "%VER_SQL%"=="9.0" if not "%VER_SQL%"=="10.0" if not "%VER_SQL%"=="10.5" if not "%VER_SQL%"=="11.0" if not "%VER_SQL%"=="12.0" >>%file_sql% echo   having ^(max^(s.wait_time_ms^)*100/max^(o.wait_time_ms^) ^>0 and
if not "%VER_SQL%"=="9.0" if not "%VER_SQL%"=="10.0" if not "%VER_SQL%"=="10.5" if not "%VER_SQL%"=="11.0" if not "%VER_SQL%"=="12.0" >>%file_sql% echo           max^(s.waiting_tasks_count^)*100/max^(o.waiting_tasks_count^) ^>0^)^)
if not "%VER_SQL%"=="9.0" if not "%VER_SQL%"=="10.0" if not "%VER_SQL%"=="10.5" if not "%VER_SQL%"=="11.0" if not "%VER_SQL%"=="12.0" >>%file_sql% echo select left^(d.name, %LEN_DBNAME%^)                      AS 'DB Name',
if not "%VER_SQL%"=="9.0" if not "%VER_SQL%"=="10.0" if not "%VER_SQL%"=="10.5" if not "%VER_SQL%"=="11.0" if not "%VER_SQL%"=="12.0" >>%file_sql% echo        s.session_id                         AS '   SID',
if not "%VER_SQL%"=="9.0" if not "%VER_SQL%"=="10.0" if not "%VER_SQL%"=="10.5" if not "%VER_SQL%"=="11.0" if not "%VER_SQL%"=="12.0" >>%file_sql% echo        left^(s.host_process_id, 6^)           AS 'PID',
if not "%VER_SQL%"=="9.0" if not "%VER_SQL%"=="10.0" if not "%VER_SQL%"=="10.5" if not "%VER_SQL%"=="11.0" if not "%VER_SQL%"=="12.0" >>%file_sql% echo        left^(s.login_name, %LEN_LOGIN%^)               AS 'Login Name',
if not "%VER_SQL%"=="9.0" if not "%VER_SQL%"=="10.0" if not "%VER_SQL%"=="10.5" if not "%VER_SQL%"=="11.0" if not "%VER_SQL%"=="12.0" >>%file_sql% echo        left^(s.program_name, 60^)             AS 'Program Name',
if not "%VER_SQL%"=="9.0" if not "%VER_SQL%"=="10.0" if not "%VER_SQL%"=="10.5" if not "%VER_SQL%"=="11.0" if not "%VER_SQL%"=="12.0" >>%file_sql% echo        left^(w.wait_type, 30^)                AS 'Wait type',
if not "%VER_SQL%"=="9.0" if not "%VER_SQL%"=="10.0" if not "%VER_SQL%"=="10.5" if not "%VER_SQL%"=="11.0" if not "%VER_SQL%"=="12.0" >>%file_sql% echo        cast^(w.waits as int^)                 AS '      Waits',
if not "%VER_SQL%"=="9.0" if not "%VER_SQL%"=="10.0" if not "%VER_SQL%"=="10.5" if not "%VER_SQL%"=="11.0" if not "%VER_SQL%"=="12.0" >>%file_sql% echo        w.pct_waits                          AS 'Waits ^(%%^)',
if not "%VER_SQL%"=="9.0" if not "%VER_SQL%"=="10.0" if not "%VER_SQL%"=="10.5" if not "%VER_SQL%"=="11.0" if not "%VER_SQL%"=="12.0" >>%file_sql% echo        cast^(w.wait_time_s as int^)           AS 'Wait time ^(s^)',
if not "%VER_SQL%"=="9.0" if not "%VER_SQL%"=="10.0" if not "%VER_SQL%"=="10.5" if not "%VER_SQL%"=="11.0" if not "%VER_SQL%"=="12.0" >>%file_sql% echo        cast^(w.signal_wait_time_s as bigint^) AS  'Signal Wait time ^(s^)',
if not "%VER_SQL%"=="9.0" if not "%VER_SQL%"=="10.0" if not "%VER_SQL%"=="10.5" if not "%VER_SQL%"=="11.0" if not "%VER_SQL%"=="12.0" >>%file_sql% echo        w.pct_wait_time                      AS 'Wait time ^(%%^)'
if not "%VER_SQL%"=="9.0" if not "%VER_SQL%"=="10.0" if not "%VER_SQL%"=="10.5" if not "%VER_SQL%"=="11.0" if not "%VER_SQL%"=="12.0" >>%file_sql% echo from sys.dm_exec_sessions s   WITH ^(NOLOCK^)
if not "%VER_SQL%"=="9.0" if not "%VER_SQL%"=="10.0" if not "%VER_SQL%"=="10.5" if not "%VER_SQL%"=="11.0" if not "%VER_SQL%"=="12.0" >>%file_sql% echo inner join sess_waits w    on w.session_id  = s.session_id
if not "%VER_SQL%"=="9.0" if not "%VER_SQL%"=="10.0" if not "%VER_SQL%"=="10.5" if not "%VER_SQL%"=="11.0" if not "%VER_SQL%"=="12.0" >>%file_sql% echo inner join sys.databases d on d.database_id = s.database_id
if not "%VER_SQL%"=="9.0" if not "%VER_SQL%"=="10.0" if not "%VER_SQL%"=="10.5" if not "%VER_SQL%"=="11.0" if not "%VER_SQL%"=="12.0" if defined SQL_BDD >>%file_sql% echo where d.name = '%SQL_BDD%'
if not "%VER_SQL%"=="9.0" if not "%VER_SQL%"=="10.0" if not "%VER_SQL%"=="10.5" if not "%VER_SQL%"=="11.0" if not "%VER_SQL%"=="12.0" if defined LOGIN >>%file_sql% echo and   s.login_name = '%LOGIN%'    -- Lists only for a login
if not "%VER_SQL%"=="9.0" if not "%VER_SQL%"=="10.0" if not "%VER_SQL%"=="10.5" if not "%VER_SQL%"=="11.0" if not "%VER_SQL%"=="12.0" >>%file_sql% echo order by s.database_id, s.session_id, w.wait_type;
if not "%VER_SQL%"=="9.0" if not "%VER_SQL%"=="10.0" if not "%VER_SQL%"=="10.5" if not "%VER_SQL%"=="11.0" if not "%VER_SQL%"=="12.0" >>%file_sql% echo:
goto:EOF
::#
::# End of Audit_user
::#************************************************************#

:Audit_lock
::#************************************************************#
::# Audits blocking processes and lock escalation + wait history & disable for each user database
::#
>>%file_sql% echo PRINT ''
>>%file_sql% echo PRINT '+--------------------+'
>>%file_sql% echo PRINT '^| Blocking processes ^|'
>>%file_sql% echo PRINT '+--------------------+'
>>%file_sql% echo PRINT ''
>>%file_sql% echo:
>>%file_sql% echo select p.spid                                                                                                           AS 'SID',
>>%file_sql% echo        left^(p.hostprocess,6^)                                                                                            AS 'PID',
>>%file_sql% echo        left^(d.name, %LEN_DBNAME%^)                                                                                                  AS 'DB Name',
>>%file_sql% echo        left^(p.loginame,15^)                                                                                              AS 'Login Name',
>>%file_sql% echo        left^(case when r.blocking_session_id = 0 then '' else cast^(r.blocking_session_id as varchar^) end, 11^)            AS 'Blocking SID',
>>%file_sql% echo        isnull^(^(select p1.hostprocess from sys.sysprocesses p1 where p1.spid = r.blocking_session_id^),''^)                AS 'Blocking PID',
>>%file_sql% echo        right^(replicate^(' ',8^)  + case when r.cpu_time      = 0 then '' else cast^(r.cpu_time as varchar^)       end, 8^)   AS 'CPU Time',
>>%file_sql% echo        right^(replicate^(' ',10^) + case when r.reads         = 0 then '' else cast^(r.reads as varchar^)         end, 10^)   AS 'Phys.Reads',
>>%file_sql% echo        right^(replicate^(' ',11^) + case when r.writes        = 0 then '' else cast^(r.writes as varchar^)        end, 11^)   AS 'Phys.Writes',
>>%file_sql% echo        right^(replicate^(' ',9^)  + case when r.logical_reads = 0 then '' else cast^(r.logical_reads as varchar^) end,  9^)   AS 'Log.Reads',
>>%file_sql% echo        cast^(r.wait_time/1000 as int^)                                                                                    AS 'Wait Time ^(s^)',
>>%file_sql% echo        case when OBJECT_NAME^(st.objectid, st.dbid^) is NULL then '' else left^(OBJECT_NAME^(st.objectid, st.dbid^), 15^) end AS 'Object Name',
>>%file_sql% echo        left^(case when r.blocking_session_id ^> 0
>>%file_sql% echo                  then '**** BLOCKING LOCK DETECTED SINCE '+cast^(r.wait_time/1000 as varchar(4)^) +' SECS ('+
>>%file_sql% echo                       cast^(r.blocking_session_id as varchar^(5))+':'+
>>%file_sql% echo                       cast((select p1.hostprocess from sys.sysprocesses p1
>>%file_sql% echo                               where p1.spid = r.blocking_session_id^) as varchar^(5))+'^>'+
>>%file_sql% echo                       cast^(p.spid as varchar^(5))+':'+
>>%file_sql% echo                       cast^(p.hostprocess as varchar^(5))+') !! ****'
>>%file_sql% echo             else '' end, 70^)                                                                                            AS 'Diagnostic',
>>%file_sql% echo        left^(s.program_name, 35^)                                                                                         AS 'Program Name',
>>%file_sql% echo        char^(13^)+char^(10^)+char^(13^)+char^(10^)+cast^(substring^(st.text, ^(r.statement_start_offset/2^)+1,
>>%file_sql% echo 	                  ^(^(case r.statement_end_offset when -1
>>%file_sql% echo 	                    then datalength^(st.text^)
>>%file_sql% echo                         else r.statement_end_offset  end -
>>%file_sql% echo                              r.statement_start_offset^)/2^)+1^) as char^(%LEN_SQLT%^)^)+char^(13^)+char^(10^)                            AS 'SQL Text'
>>%file_sql% echo from sys.dm_exec_requests r
>>%file_sql% echo inner join sys.dm_exec_sessions s on s.session_id = r.session_id
>>%file_sql% echo inner join sys.sysprocesses p     on p.spid       = s.session_id
>>%file_sql% echo inner join sys.databases d    WITH ^(NOLOCK^) on ^(d.database_id = p.dbid^)
>>%file_sql% echo cross apply sys.dm_exec_sql_text ^(r.sql_handle^) st
>>%file_sql% echo where r.wait_time ^> 0
>>%file_sql% echo and   s.is_user_process = 1   -- Excludes system processes
if defined LOGIN >>%file_sql% echo and   s.login_name = '%LOGIN%'    -- Lists only for a login
>>%file_sql% echo and   s.session_id ^<^> @@spid -- Excludes owner  processes
if defined SQL_BDD >>%file_sql% echo and d.name = '%SQL_BDD%'
>>%file_sql% echo order by 3, 4, 1;
>>%file_sql% echo:
>>%file_sql% echo PRINT ''
>>%file_sql% echo PRINT '+-------------------------+'
>>%file_sql% echo PRINT '^| Lock Escalation + Waits ^|'
>>%file_sql% echo PRINT '+-------------------------+'
>>%file_sql% echo PRINT ''
>>%file_sql% echo:
if     defined SQL_BDD >>%file_sql% echo exec sp_MSforeachdb @command1='if db_id^(''?''^) ^<= 4 or db_name^(db_id^(''?''^)^) ^<^>''%SQL_BDD%'' return; use [?]; print ''*** ? ***''; print ''''
if not defined SQL_BDD >>%file_sql% echo exec sp_MSforeachdb @command1='if db_id^(''?''^) ^<= 4 return; use [?]; print ''*** ? ***''; print ''''
>>%file_sql% echo select left^(OBJECT_SCHEMA_NAME^(iops.object_id, iops.database_id^), %LEN_OWNER%^) AS ''Schema Name'',
>>%file_sql% echo        left^(OBJECT_NAME^(iops.object_id, iops.database_id^), %LEN_TABLE%^) AS ''Table Name'',
>>%file_sql% echo        left^(case when i.name is null then '''' else i.name end, %LEN_INDEX%^) AS ''Index Name'',
::>>%file_sql% echo        right^(replicate^('' '',24^) +
::>>%file_sql% echo              case when iops.index_lock_promotion_attempt_count = 0 then ''''
::>>%file_sql% echo                   else cast^(iops.index_lock_promotion_attempt_count as varchar^) end, 24^) AS ''Escalation Count Attempt'',
>>%file_sql% echo        right^(replicate^('' '',21^) +
>>%file_sql% echo              case when iops.index_lock_promotion_count = 0 then ''''
>>%file_sql% echo                   else cast^(iops.index_lock_promotion_count as varchar^) end, 21^) AS ''Escalation Count Done'',
::>>%file_sql% echo        right^(replicate^('' '',14^) +
::>>%file_sql% echo              case when iops.row_lock_count = 0 then ''''
::>>%file_sql% echo                   else cast^(iops.row_lock_count as varchar^) end, 14^) AS ''Row Lock Count'',
>>%file_sql% echo        right^(replicate^('' '',19^) +
>>%file_sql% echo              case when iops.row_lock_wait_count = 0 then ''''
>>%file_sql% echo                   else cast^(iops.row_lock_wait_count as varchar^) end, 19^) AS ''Row Lock Wait Count'',
>>%file_sql% echo        right^(replicate^('' '',17^) +
>>%file_sql% echo              case when iops.row_lock_wait_in_ms = 0 then ''''
>>%file_sql% echo                   else cast^(cast^(iops.row_lock_wait_in_ms/1000.0 as dec^(8,1^)^) as varchar^) end, 17^)  AS ''Row Lock Wait ^(s^)'',
::>>%file_sql% echo        right^(replicate^('' '',15^) +
::>>%file_sql% echo              case when iops.page_lock_count = 0 then ''''
::>>%file_sql% echo        	        else cast^(iops.page_lock_count as varchar^) end, 15^) AS ''Page Lock Count'',
>>%file_sql% echo        right^(replicate^('' '',21^) +
>>%file_sql% echo              case when iops.page_lock_wait_count = 0 then ''''
>>%file_sql% echo                   else cast^(iops.page_lock_wait_count as varchar^) end, 20^) AS ''Page Lock Wait Count'',
>>%file_sql% echo        right^(replicate^('' '',18^) +
>>%file_sql% echo              case when iops.page_lock_wait_in_ms = 0 then ''''
>>%file_sql% echo                   else cast^(cast^(iops.page_lock_wait_in_ms/1000.0 as dec^(8,1^)^) as varchar^) end, 18^) AS ''Page Lock Wait ^(s^)''
>>%file_sql% echo from sys.dm_db_index_operational_stats ^(db_id^(^), NULL, NULL, NULL^) iops
>>%file_sql% echo inner join sys.indexes i on i.object_id = iops.object_id and i.index_id  = iops.index_id
>>%file_sql% echo where iops.index_lock_promotion_count+iops.row_lock_wait_count+iops.page_lock_wait_count ^> 0
>>%file_sql% echo and   OBJECT_SCHEMA_NAME^(iops.object_id, iops.database_id^) != ''sys''   -- excludes sys schema
if defined LOGIN >>%file_sql% echo and OBJECT_SCHEMA_NAME^(iops.object_id, iops.database_id^) = ''%LOGIN%''    -- Lists only for a login
>>%file_sql% echo order by 2, iops.row_lock_wait_in_ms + iops.page_lock_wait_in_ms desc, iops.index_lock_promotion_count desc; print ''''';
>>%file_sql% echo:
>>%file_sql% echo PRINT ''
>>%file_sql% echo PRINT '+-------------------------+'
>>%file_sql% echo PRINT '^| Lock Escalation disable ^|'
>>%file_sql% echo PRINT '+-------------------------+'
>>%file_sql% echo PRINT ''
>>%file_sql% echo:
if     defined SQL_BDD >>%file_sql% echo exec sp_MSforeachdb @command1='if db_id^(''?''^) ^<= 4 or db_name^(db_id^(''?''^)^) ^<^>''%SQL_BDD%'' return; use [?]; print ''*** ? ***''; print ''''
if not defined SQL_BDD >>%file_sql% echo exec sp_MSforeachdb @command1='if db_id^(''?''^) ^<= 4 return; use [?]; print ''*** ? ***''; print ''''
if not "%VER_SQL%"=="9.0" >>%file_sql% echo select left^(SCHEMA_NAME(t.schema_id), %LEN_OWNER%^) AS ''Schema Name'',
if not "%VER_SQL%"=="9.0" >>%file_sql% echo        left^(t.name, %LEN_TABLE%^)                   AS ''Table Name'',
if not "%VER_SQL%"=="9.0" >>%file_sql% echo        left^(t.lock_escalation_desc, 8^)    AS ''Escalation''
if not "%VER_SQL%"=="9.0" >>%file_sql% echo from sys.tables t
if not "%VER_SQL%"=="9.0" >>%file_sql% echo where t. lock_escalation ^> 0
if not "%VER_SQL%"=="9.0" if defined LOGIN >>%file_sql% echo and SCHEMA_NAME^(t.schema_id^) = ''%LOGIN%''  -- Lists only for a login
if not "%VER_SQL%"=="9.0" >>%file_sql% echo order by 1, 2;
if not "%VER_SQL%"=="9.0" >>%file_sql% echo:
>>%file_sql% echo PRINT ''''
>>%file_sql% echo select distinct left^(SCHEMA_NAME^(t.schema_id^), %LEN_OWNER%^)                           AS ''Schema Name'',
>>%file_sql% echo        left^(t.name, %LEN_TABLE%^)                                                      AS ''Table Name'',
>>%file_sql% echo        left^(i.name, %LEN_INDEX%^)                                                      AS ''Index Name'',
>>%file_sql% echo        left^(case when i.allow_row_locks  = ''1'' then ''On'' else ''Off'' end, 15^) AS ''Is Row Locks ?'',
>>%file_sql% echo        left^(case when i.allow_page_locks = ''1'' then ''On'' else ''Off'' end, 15^) AS ''Is Page Locks ?''
>>%file_sql% echo from sys.indexes i
>>%file_sql% echo inner join sys.tables t on t.object_id = i.object_id
>>%file_sql% echo and   i.index_id ^>= 3
if defined LOGIN >>%file_sql% echo and SCHEMA_NAME^(t.schema_id^) = ''%LOGIN%''  -- Lists only for a login
>>%file_sql% echo and   ^(i.allow_row_locks = ''0'' or i.allow_page_locks = ''0''^); print ''''';
>>%file_sql% echo:
>>%file_sql% echo PRINT ''
>>%file_sql% echo PRINT '+------------------------------------+'
>>%file_sql% echo PRINT '^| Most unsuccessful Lock Escalations ^|'
>>%file_sql% echo PRINT '+------------------------------------+'
>>%file_sql% echo PRINT ''
>>%file_sql% echo:
if     defined SQL_BDD >>%file_sql% echo exec sp_MSforeachdb @command1='if db_id^(''?''^) ^<= 4 or db_name^(db_id^(''?''^)^) ^<^>''%SQL_BDD%'' return; use [?]; print ''*** ? ***''; print ''''
if not defined SQL_BDD >>%file_sql% echo exec sp_MSforeachdb @command1='if db_id^(''?''^) ^<= 4 return; use [?]; print ''*** ? ***''; print ''''
>>%file_sql% echo select TOP %TOP_NSQL%
>>%file_sql% echo        left^(OBJECT_SCHEMA_NAME^(iops.object_id, iops.database_id^), %LEN_OWNER%^) AS ''Schema Name'',
>>%file_sql% echo        left^(OBJECT_NAME^(iops.object_id, iops.database_id^), %LEN_TABLE%^) AS ''Table Name'',
>>%file_sql% echo        left^(case when i.name is null then '''' else i.name end, %LEN_INDEX%^) AS ''Index Name'',
>>%file_sql% echo        iops.index_lock_promotion_attempt_count - iops.index_lock_promotion_count AS ''Unsuccessful Index Lock Promotions''
>>%file_sql% echo from sys.dm_db_index_operational_stats ^(db_id^(^), NULL, NULL, NULL^) iops
>>%file_sql% echo inner join sys.objects o on o.object_id = iops.object_id
>>%file_sql% echo inner join sys.indexes i on i.object_id = iops.object_id and i.index_id  = iops.index_id
>>%file_sql% echo where iops.index_lock_promotion_attempt_count - iops.index_lock_promotion_count ^> 0
>>%file_sql% echo and   o.is_ms_shipped = 0
>>%file_sql% echo and   OBJECT_SCHEMA_NAME^(iops.object_id, iops.database_id^) != ''sys''   -- excludes sys schema
if defined LOGIN >>%file_sql% echo and OBJECT_SCHEMA_NAME^(iops.object_id, iops.database_id^) = ''%LOGIN%''    -- Lists only for a login
>>%file_sql% echo order by 4 desc; print ''''';
>>%file_sql% echo:
>>%file_sql% echo PRINT ''
>>%file_sql% echo PRINT '+------------------------------------+'
>>%file_sql% echo PRINT '^| Indexes under row-locking pressure ^|'
>>%file_sql% echo PRINT '+------------------------------------+'
>>%file_sql% echo PRINT ''
>>%file_sql% echo:
if     defined SQL_BDD >>%file_sql% echo exec sp_MSforeachdb @command1='if db_id^(''?''^) ^<= 4 or db_name^(db_id^(''?''^)^) ^<^>''%SQL_BDD%'' return; use [?]; print ''*** ? ***''; print ''''
if not defined SQL_BDD >>%file_sql% echo exec sp_MSforeachdb @command1='if db_id^(''?''^) ^<= 4 return; use [?]; print ''*** ? ***''; print ''''
>>%file_sql% echo select TOP %TOP_NSQL%
>>%file_sql% echo        left^(OBJECT_SCHEMA_NAME^(iops.object_id, iops.database_id^), %LEN_OWNER%^) AS ''Schema Name'',
>>%file_sql% echo        left^(OBJECT_NAME^(iops.object_id, iops.database_id^), %LEN_TABLE%^) AS ''Table Name'',
>>%file_sql% echo        left^(case when i.name is null then '''' else i.name end, %LEN_INDEX%^) AS ''Index Name'',
>>%file_sql% echo        cast^(iops.row_lock_wait_count as int) AS ''Row Lock Wait Count'',
>>%file_sql% echo        cast^(iops.row_lock_wait_in_ms/1000.0 as dec^(8,1^)^) AS ''Row Lock Wait ^(s^)''
>>%file_sql% echo from sys.dm_db_index_operational_stats ^(db_id^(^), NULL, NULL, NULL^) iops
>>%file_sql% echo inner join sys.objects o on o.object_id = iops.object_id
>>%file_sql% echo inner join sys.indexes i on i.object_id = iops.object_id and i.index_id  = iops.index_id
>>%file_sql% echo where iops.row_lock_wait_in_ms ^> 0
>>%file_sql% echo and   o.is_ms_shipped = 0
>>%file_sql% echo and   OBJECT_SCHEMA_NAME^(iops.object_id, iops.database_id^) != ''sys''   -- excludes sys schema
if defined LOGIN >>%file_sql% echo and OBJECT_SCHEMA_NAME^(iops.object_id, iops.database_id^) = ''%LOGIN%''    -- Lists only for a login
>>%file_sql% echo order by 5 desc; print ''''';
>>%file_sql% echo:
goto:EOF
::#
::# End of Audit_lock
::#************************************************************#

:Audit_stat_old
::#************************************************************#
::# Audits Object statistics summary and list only for SQL Server 2005/2008
::#
>>%file_sql% echo PRINT ''
>>%file_sql% echo PRINT '+-----------------------------+'
>>%file_sql% echo PRINT '^| Object statistics ^(summary^) ^|'
>>%file_sql% echo PRINT '+-----------------------------+'
>>%file_sql% echo PRINT ''
>>%file_sql% echo:
if     defined SQL_BDD >>%file_sql% echo exec sp_MSforeachdb @command1='if db_id^(''?''^) ^<= 4 or db_name^(db_id^(''?''^)^) ^<^>''%SQL_BDD%'' return; use [?]; print ''*** ? ***''; print ''''
if not defined SQL_BDD >>%file_sql% echo exec sp_MSforeachdb @command1='if db_id^(''?''^) ^<= 4 return; use [?]; print ''*** ? ***''; print ''''
>>%file_sql% echo ;with stats as 
>>%file_sql% echo   ^(select sch.name as owner,
>>%file_sql% echo            so.name ''table name'',
>>%file_sql% echo            case when ss.name like ''_WA_Sys_%%'' then ''Column'' else ''Index'' end as type,
>>%file_sql% echo            i.name index_name,
>>%file_sql% echo            convert^(datetime, convert^(varchar, stats_date^(i.id, i.indid^), %CNV_DATE%^), %CNV_DATE%^) as last_updated,
>>%file_sql% echo            max^(i.rowmodctr^) upd_count,
>>%file_sql% echo            max^(i.rowcnt^) rows
>>%file_sql% echo    from sys.stats ss
>>%file_sql% echo    join sys.objects so on ss.object_id = so.object_id
>>%file_sql% echo    join sys.schemas sch on so.schema_id = sch.schema_id
>>%file_sql% echo    join sysindexes i on i.id = so.object_id and i.name = ss.name
>>%file_sql% echo    join sys.stats_columns st on st.stats_id  = ss.stats_id and st.object_id = ss.object_id
>>%file_sql% echo    where so.type = ''U''
if defined LOGIN >>%file_sql% echo     and   sch.name = ''%LOGIN%''    -- Lists only for a login
if (%FLG_DBO%)==(0) >>%file_sql% echo     and   sch.name ^<^> ''dbo''
>>%file_sql% echo     and   i.name not like ''%%_ROWID''
>>%file_sql% echo     and stats_date^(i.id, i.indid^) IS NOT NULL
>>%file_sql% echo group by sch.name, so.name, case when ss.name like ''_WA_Sys_%%'' then ''Column'' else ''Index'' end, i.name, stats_date^(i.id, i.indid^)^)
>>%file_sql% echo select left^(s.owner, %LEN_OWNER%^) AS ''Owner'',
>>%file_sql% echo        s.type AS ''Type'',
>>%file_sql% echo        sum^(case when datediff^(day, s.last_updated, getdate^(^)^) ^>= 0  then 1 else 0 end^) AS ''Total Objects'',
>>%file_sql% echo        sum^(case when datediff^(day, s.last_updated, getdate^(^)^) ^> %STALE%  then 1 else 0 end^) AS ''Stale ^>=%STALE% days'',
>>%file_sql% echo        cast^(sum^(case when datediff^(day, s.last_updated, getdate^(^)^) ^> %STALE%  then 1 else 0 end^)*100.0/
>>%file_sql% echo             replace^(sum^(case when datediff^(day, s.last_updated, getdate^(^)^) ^> 0  then 1 else 0 end^),0,1^) as dec^(4,1^)^) AS ''Stale (%%)'',
>>%file_sql% echo        sum^(case when datediff^(day, s.last_updated, getdate^(^)^) ^<= %STALE% then 1 else 0 end^) AS ''Up to date'',
>>%file_sql% echo        left^(isnull^(convert^(varchar, min^(s.last_updated^), %CNV_DATE%^), ''''^), 12^) AS ''First Updated'',
>>%file_sql% echo        left^(isnull^(convert^(varchar, max^(s.last_updated^), %CNV_DATE%^), ''''^), 12^) AS ''Last Updated''
>>%file_sql% echo from stats s
>>%file_sql% echo where s.last_updated IS NOT NULL
>>%file_sql% echo group by s.owner, s.type
>>%file_sql% echo order by s.owner, s.type desc; print ''''';
>>%file_sql% echo:
>>%file_sql% echo PRINT '+-----------------------------------+'
>>%file_sql% echo PRINT '^| Oldest object statistics ^(detail^) ^|'
>>%file_sql% echo PRINT '+-----------------------------------+'
>>%file_sql% echo PRINT ''
>>%file_sql% echo:
if     defined SQL_BDD >>%file_sql% echo exec sp_MSforeachdb @command1='if db_id^(''?''^) ^<= 4 or db_name^(db_id^(''?''^)^) ^<^>''%SQL_BDD%'' return; use [?]; print ''*** ? ***''; print ''''
if not defined SQL_BDD >>%file_sql% echo exec sp_MSforeachdb @command1='if db_id^(''?''^) ^<= 4 return; use [?]; print ''*** ? ***''; print ''''
>>%file_sql% echo select left^(s.name, %LEN_OWNER%^)                                            AS ''Owner'',
>>%file_sql% echo        left^(OBJECT_NAME^(i.id^), %LEN_TABLE%^)                                AS ''Table Name'',
>>%file_sql% echo        left^(i.name, %LEN_INDEX%^)                                           AS ''Index Name'',
>>%file_sql% echo        left^(convert^(varchar, stats_date^(i.id, i.indid^), %CNV_DATE%^)+'' ''+
>>%file_sql% echo              convert^(varchar, stats_date^(i.id, i.indid^), %CNV_TIME%^), 14^)  AS ''Last Updated'',
>>%file_sql% echo        cast^(i.rowmodctr as int^)                                   AS ''  Upd Count''
>>%file_sql% echo from sys.sysindexes i    WITH ^(NOLOCK^)
>>%file_sql% echo inner join sys.objects o WITH ^(NOLOCK^) on o.object_id = i.id
>>%file_sql% echo inner join sys.schemas s WITH ^(NOLOCK^) on s.schema_id = o.schema_id
>>%file_sql% echo where STATS_DATE(id, indid) ^<= dateadd(day, -1, getdate^(^)^)
if defined LOGIN >>%file_sql% echo and s.name = ''%LOGIN%''    -- Lists only for a login
if (%FLG_DBO%)==(0) >>%file_sql% echo and s.name ^<^> ''dbo''
>>%file_sql% echo and   i.name not like ^(''%%_ROWID''^)
>>%file_sql% echo and   i.name not like ^(''_WA_Sys_%%''^)
>>%file_sql% echo and   i.rowmodctr ^> 0
>>%file_sql% echo and   ^(OBJECTPROPERTY^(i.id,''IsUserTable''^)^) = 1
>>%file_sql% echo order by 1, 5 desc; print ''''';
>>%file_sql% echo:
goto:EOF
::#
::# End of Audit_stat_old
::#************************************************************#

:Audit_stat
::#************************************************************#
::# Audits Object statistics summary and list from SQL Server 2008 R2 and later
::#
>>%file_sql% echo PRINT ''
>>%file_sql% echo PRINT '+-----------------------------+'
>>%file_sql% echo PRINT '^| Object statistics ^(summary^) ^|'
>>%file_sql% echo PRINT '+-----------------------------+'
>>%file_sql% echo PRINT ''
>>%file_sql% echo:
if     defined SQL_BDD >>%file_sql% echo exec sp_MSforeachdb @command1='if db_id^(''?''^) ^<= 4 or db_name^(db_id^(''?''^)^) ^<^>''%SQL_BDD%'' return; use [?]; print ''*** ? ***''; print ''''
if not defined SQL_BDD >>%file_sql% echo exec sp_MSforeachdb @command1='if db_id^(''?''^) ^<= 4 return; use [?]; print ''*** ? ***''; print ''''
>>%file_sql% echo ;with stats as ^( 
>>%file_sql% echo select sch.name as owner,
>>%file_sql% echo        so.name ''table name'',
>>%file_sql% echo        case when ss.name like ''_WA_Sys_%%'' then ''Column'' else ''Index'' end as type,
>>%file_sql% echo        i.name index_name,
>>%file_sql% echo        convert^(datetime, convert^(varchar, stats_date^(i.id, i.indid^), 3^), 3^) as last_updated,
>>%file_sql% echo        max^(i.rowmodctr^) upd_count,
>>%file_sql% echo        max^(i.rowcnt^) rows
>>%file_sql% echo from sys.stats ss
>>%file_sql% echo join sys.objects so on ss.object_id = so.object_id
>>%file_sql% echo join sys.schemas sch on so.schema_id = sch.schema_id
>>%file_sql% echo outer apply sys.dm_db_stats_properties^(so.object_id, ss.stats_id^) sp
>>%file_sql% echo join sysindexes i on i.id = so.object_id and i.name = ss.name
>>%file_sql% echo join sys.stats_columns st on st.stats_id = ss.stats_id and st.object_id = ss.object_id
>>%file_sql% echo where so.type = ''U''
if defined LOGIN >>%file_sql% echo and   sch.name = ''%LOGIN%''    -- Lists only for a login
if (%FLG_DBO%)==(0) >>%file_sql% echo and   sch.name ^<^> ''dbo''
>>%file_sql% echo and   ss.name not like ^(''%%_ROWID''^)
>>%file_sql% echo and   sp.rows is not NULL
>>%file_sql% echo group by sch.name, so.name, case when ss.name like ''_WA_Sys_%%'' then ''Column'' else ''Index'' end, i.name, stats_date^(i.id, i.indid^)^)
>>%file_sql% echo select left^(s.owner, %LEN_OWNER%^) AS ''Owner'',
>>%file_sql% echo        s.type AS ''Type'',
>>%file_sql% echo        sum^(case when datediff^(day, s.last_updated, getdate^(^)^) ^>= 0  then 1 else 0 end^) AS ''Total Objects'',
>>%file_sql% echo        sum^(case when datediff^(day, s.last_updated, getdate^(^)^) ^> %STALE%  then 1 else 0 end^) AS ''Stale ^>=%STALE% days'',
>>%file_sql% echo        cast^(sum^(case when datediff^(day, s.last_updated, getdate^(^)^) ^> %STALE%  then 1 else 0 end^)*100.0/
>>%file_sql% echo             replace^(sum^(case when datediff^(day, s.last_updated, getdate^(^)^) ^> 0  then 1 else 0 end^),0,1) as dec^(4,1^)^) AS ''Stale (%%)'',
>>%file_sql% echo        sum^(case when datediff^(day, s.last_updated, getdate^(^)^) ^<= %STALE% then 1 else 0 end^) AS ''Up to date'',
>>%file_sql% echo        left^(isnull^(convert^(varchar, min^(s.last_updated^), 3^), ''''^), 12^) AS ''First Updated'',
>>%file_sql% echo        left^(isnull^(convert^(varchar, max^(s.last_updated^), 3^), ''''^), 12^) AS ''Last Updated''
>>%file_sql% echo from stats s
>>%file_sql% echo where s.last_updated IS NOT NULL
>>%file_sql% echo group by s.owner, s.type
>>%file_sql% echo order by s.owner, s.type desc; print ''''';
>>%file_sql% echo:
>>%file_sql% echo PRINT ''
>>%file_sql% echo PRINT '+-----------------------------------+'
>>%file_sql% echo PRINT '^| Oldest object statistics ^(Detail^) ^|'
>>%file_sql% echo PRINT '+-----------------------------------+'
>>%file_sql% echo PRINT ''
>>%file_sql% echo:
if     defined SQL_BDD >>%file_sql% echo exec sp_MSforeachdb @command1='if db_id^(''?''^) ^<= 4 or db_name^(db_id^(''?''^)^) ^<^>''%SQL_BDD%'' return; use [?]; print ''*** ? ***''; print ''''
if not defined SQL_BDD >>%file_sql% echo exec sp_MSforeachdb @command1='if db_id^(''?''^) ^<= 4 return; use [?]; print ''*** ? ***''; print ''''
>>%file_sql% echo select left^(oos.owner, %LEN_OWNER%^)                                         AS ''Owner'',
>>%file_sql% echo        left^(oos.table_name, %LEN_TABLE%^)                                    AS ''Table Name'',
>>%file_sql% echo        left^(oos.index_name, %LEN_INDEX%^)                                    AS ''Index Name'',
if "%VER_SQL%"=="11.0" >>%file_sql% echo        left^(format^(oos.last_updated, ''%FMT_DAT2%''^),14^)         AS ''Last Updated'',
if "%VER_SQL%"=="12.0" >>%file_sql% echo        left^(format^(oos.last_updated, ''%FMT_DAT2%''^),14^)         AS ''Last Updated'',
if "%VER_SQL%"=="13.0" >>%file_sql% echo        left^(format^(oos.last_updated, ''%FMT_DAT2%''^),14^)         AS ''Last Updated'',
if "%VER_SQL%"=="14.0" >>%file_sql% echo        left^(format^(oos.last_updated, ''%FMT_DAT2%''^),14^)         AS ''Last Updated'',
if not "%VER_SQL%"=="11.0" if not "%VER_SQL%"=="12.0" if not "%VER_SQL%"=="13.0" if not "%VER_SQL%"=="14.0" >>%file_sql% echo        left^(convert^(varchar, oos.last_updated, %CNV_DATE%^)+'' ''+
if not "%VER_SQL%"=="11.0" if not "%VER_SQL%"=="12.0" if not "%VER_SQL%"=="13.0" if not "%VER_SQL%"=="14.0" >>%file_sql% echo              convert^(varchar, oos.last_updated, %CNV_TIME%^), 14^) AS ''Last Updated'',
>>%file_sql% echo        cast^(oos.upd_count as int^)                                  AS ''  Upd Count'',
>>%file_sql% echo        cast^(oos.row_count as int^)                                  AS ''  Row Count'',
>>%file_sql% echo 	   case when oos.upd_count ^> oos.row_count then ''^>100''
>>%file_sql% echo 	        else cast^(cast^(100.0 * oos.upd_count /
>>%file_sql% echo                  oos.row_count as decimal^(6,1^)^) as varchar^(7^)^) end AS ''Upd ^(%%^)'',
>>%file_sql% echo 	   cast^(datediff^(dd, oos.last_updated, getdate^(^)^) as int^)      AS      ''Age days'',
>>%file_sql% echo        cast^(oos.sample as int^)                                     AS ''    Sampled''
>>%file_sql% echo from ^(select sch.name                AS owner,
>>%file_sql% echo               so.name                 AS table_name,
>>%file_sql% echo               ss.name                 AS index_name,
>>%file_sql% echo               sp.last_updated         AS last_updated,
>>%file_sql% echo               sp.rows                 AS row_count,
>>%file_sql% echo               sp.rows_sampled         AS sample,
>>%file_sql% echo               sp.modification_counter AS upd_count,
>>%file_sql% echo               rank^(^) over ^(partition by sch.name order by sp.modification_counter desc^) AS rank
>>%file_sql% echo        from sys.stats ss
>>%file_sql% echo        join sys.objects so  on ss.object_id = so.object_id
>>%file_sql% echo        join sys.schemas sch on so.schema_id = sch.schema_id
>>%file_sql% echo        outer apply sys.dm_db_stats_properties^(so.object_id, ss.stats_id^) sp
>>%file_sql% echo        where so.type = ''U''
if defined LOGIN >>%file_sql% echo        and sch.name = ''%LOGIN%''    -- Lists only for a login
>>%file_sql% echo        and ss.name not like ^(''%%_ROWID''^)
>>%file_sql% echo        and ss.name not like ^(''_WA_Sys_%%''^)
>>%file_sql% echo        and sp.rows is not NULL
>>%file_sql% echo        and 100.0 * sp.modification_counter/ sp.rows ^> 0.1
>>%file_sql% echo      ^) oos
>>%file_sql% echo where rank ^<= %TOP_NSQL%
>>%file_sql% echo order by oos.owner, oos.rank; print ''''';
>>%file_sql% echo:
goto:EOF
::#
::# End of Audit_stat
::#************************************************************#

:Audit_perf
::#************************************************************#
::# Audits missing indexes and SQL Server performance counters
::#
>>%file_sql% echo PRINT ''
>>%file_sql% echo PRINT '+-------------------------------+'
>>%file_sql% echo PRINT '^| Missing indexes (potentially) ^|'
>>%file_sql% echo PRINT '+-------------------------------+'
>>%file_sql% echo PRINT ''
>>%file_sql% echo:
if     defined SQL_BDD >>%file_sql% echo exec sp_MSforeachdb @command1='if db_id^(''?''^) ^<= 4 or db_name^(db_id^(''?''^)^) ^<^>''%SQL_BDD%'' return; use [?]; print ''*** ? ***''; print ''''
if not defined SQL_BDD >>%file_sql% echo exec sp_MSforeachdb @command1='if db_id^(''?''^) ^<= 4 return; use [?]; print ''*** ? ***''; print ''''
>>%file_sql% echo select cast^(convert ^(decimal ^(10,0^), migs.user_seeks * migs.avg_total_user_cost * migs.avg_user_impact * 0.00001^) as int^) AS ''     Impact'',
>>%file_sql% echo 	   cast^(migs.user_seeks + migs.user_scans as int^) AS ''       Used'',
>>%file_sql% echo        cast^(avg_total_user_cost as int^)               AS ''       Cost'',
>>%file_sql% echo        left^(''CREATE INDEX SPE_'' + object_name^(mid.object_id, mid.database_id^)
>>%file_sql% echo 			+ '' ON '' + replace^(replace^(mid.statement,''['',''''^),'']'',''''^)
>>%file_sql% echo 			+ ''^('' + isnull^(replace^(replace^(mid.equality_columns,''['',''''^),'']'',''''^),''''^)
>>%file_sql% echo 			+ case when mid.equality_columns is not null and mid.inequality_columns is not null then '', '' else '''' end + isnull ^(replace^(replace^(mid.inequality_columns,''['',''''^),'']'',''''^), ''''^)
>>%file_sql% echo 			+ ''^)'' + isnull ^('' INCLUDE ^('' + replace^(replace^(mid.included_columns,''['',''''^),'']'',''''^) + ''^)'', ''''^), %LEN_SQLT%^) AS ''SQL Statement''
>>%file_sql% echo from sys.dm_db_missing_index_groups mig
>>%file_sql% echo inner join sys.dm_db_missing_index_group_stats migs on migs.group_handle = mig.index_group_handle
>>%file_sql% echo inner join sys.dm_db_missing_index_details mid on mig.index_handle = mid.index_handle
>>%file_sql% echo where migs.user_seeks * migs.avg_total_user_cost * migs.avg_user_impact * 0.00001 ^>= 1
>>%file_sql% echo and mid.database_id ^> 4
>>%file_sql% echo and mid.statement in ^(select TOP %TOP_NSQL% ''[''+DB_NAME^(^)+''].[''+s.name+''].[''+o.name+'']'' COLLATE DATABASE_DEFAULT
>>%file_sql% echo from sys.partitions p
>>%file_sql% echo inner join sys.dm_db_partition_stats ps on p.partition_id = ps.partition_id and p.partition_number = ps.partition_number
>>%file_sql% echo inner join sys.objects o on ps.object_id = o.object_id
>>%file_sql% echo inner join sys.schemas s on o.schema_id  = s.schema_id
>>%file_sql% echo inner join sys.indexes i on i.object_id  = ps.object_id    and i.index_id = ps.index_id
>>%file_sql% echo where s.name != ''sys''
>>%file_sql% echo group by s.name, o.name
>>%file_sql% echo having sum^(ps.used_page_count^) * 8 /1024/1024 ^>= 1
>>%file_sql% echo order by sum^(ps.used_page_count^) desc
>>%file_sql% echo ^)
>>%file_sql% echo and len^(isnull^(mid.included_columns,0^)^) ^< 30
>>%file_sql% echo order by 4; print ''''';
>>%file_sql% echo:
>>%file_sql% echo PRINT '+---------------------------------+'
>>%file_sql% echo PRINT '^| SQL Server Performance counters ^|'
>>%file_sql% echo PRINT '+---------------------------------+'
>>%file_sql% echo PRINT ''
>>%file_sql% echo:
>>%file_sql% echo if not object_id('tempdb..%TMPTAB%') is null drop table %TMPTAB%;
>>%file_sql% echo go
>>%file_sql% echo select c.object_name, c.counter_name, c.cntr_value
>>%file_sql% echo into %TMPTAB%
>>%file_sql% echo from  sys.dm_os_performance_counters c
>>%file_sql% echo where ^(c.object_name='MSSQL$%DB_SVC%:Buffer Manager'          and c.counter_name = 'Checkpoint pages/sec'^) or
>>%file_sql% echo       ^(c.object_name='MSSQL$%DB_SVC%:Buffer Manager'          and c.counter_name = 'Lazy writes/sec'^) or
>>%file_sql% echo       ^(c.object_name='MSSQL$%DB_SVC%:Buffer Manager'          and c.counter_name = 'Page reads/sec'^) or
>>%file_sql% echo       ^(c.object_name='MSSQL$%DB_SVC%:Buffer Manager'          and c.counter_name = 'Page writes/sec'^) or
>>%file_sql% echo       ^(c.object_name='MSSQL$%DB_SVC%:SQL Statistics'          and c.counter_name = 'Batch Requests/sec'^) or
>>%file_sql% echo       ^(c.object_name='MSSQL$%DB_SVC%:SQL Statistics'          and c.counter_name = 'SQL Compilations/sec'^) or
>>%file_sql% echo       ^(c.object_name='MSSQL$%DB_SVC%:SQL Statistics'          and c.counter_name = 'SQL Re-Compilations/sec'^) or
>>%file_sql% echo       ^(c.object_name='MSSQL$%DB_SVC%:Gestionnaire de tampons' and c.counter_name = 'Pages de points de contrôle/s'^) or
>>%file_sql% echo       ^(c.object_name='MSSQL$%DB_SVC%:Gestionnaire de tampons' and c.counter_name = 'Écritures différées/s'^) or
>>%file_sql% echo       ^(c.object_name='MSSQL$%DB_SVC%:Gestionnaire de tampons' and c.counter_name = 'Lectures de pages/s'^) or
>>%file_sql% echo       ^(c.object_name='MSSQL$%DB_SVC%:Gestionnaire de tampons' and c.counter_name = 'Écritures de pages/s'^) or
>>%file_sql% echo       ^(c.object_name='MSSQL$%DB_SVC%:SQL Statistics'          and c.counter_name = 'Nombre de requêtes de lots/s'^) or
>>%file_sql% echo       ^(c.object_name='MSSQL$%DB_SVC%:SQL Statistics'          and c.counter_name = 'Compilations SQL/s'^) or
>>%file_sql% echo       ^(c.object_name='MSSQL$%DB_SVC%:SQL Statistics'          and c.counter_name = 'Recompilations SQL/s'^);
>>%file_sql% echo:
>>%file_sql% echo waitfor delay '00:00:02';  -- Wait for 2 seconds
>>%file_sql% echo declare @cpuDiff bigint, @ioDiff bigint;
>>%file_sql% echo:
>>%file_sql% echo select left^(c.object_name, 35^)  AS 'Object name',
>>%file_sql% echo        left^(c.counter_name, 30^) AS 'Counter name',
>>%file_sql% echo        left^(c.cntr_value, 10^)   AS 'Value'
>>%file_sql% echo from  sys.dm_os_performance_counters c
>>%file_sql% echo where ^(c.object_name='MSSQL$%DB_SVC%:Access Methods'          and c.counter_name = 'Table Lock Escalations/sec'^) or
>>%file_sql% echo       ^(c.object_name='MSSQL$%DB_SVC%:Buffer Manager'          and c.counter_name = 'Page life expectancy'^) or
>>%file_sql% echo       ^(c.object_name='MSSQL$%DB_SVC%:Databases'               and c.counter_name = 'Active Transactions'               and instance_name = '_Total'^) or
>>%file_sql% echo       ^(c.object_name='MSSQL$%DB_SVC%:General Statistics'      and c.counter_name = 'Processes blocked'^) or
>>%file_sql% echo       ^(c.object_name='MSSQL$%DB_SVC%:General Statistics'      and c.counter_name = 'User Connections'^) or
>>%file_sql% echo       ^(c.object_name='MSSQL$%DB_SVC%:Locks'                   and c.counter_name = 'Lock Wait Time ^(ms^)'               and instance_name = '_Total'^) or
>>%file_sql% echo       ^(c.object_name='MSSQL$%DB_SVC%:Locks'                   and c.counter_name = 'Lock Waits/sec'                    and instance_name = '_Total'^) or
>>%file_sql% echo       ^(c.object_name='MSSQL$%DB_SVC%:Locks'                   and c.counter_name = 'Number of Deadlocks/sec'           and instance_name = '_Total'^) or
>>%file_sql% echo       ^(c.object_name='MSSQL$%DB_SVC%:Memory Manager'          and c.counter_name = 'Memory Grants Pending'^) or
>>%file_sql% echo       ^(c.object_name='MSSQL$%DB_SVC%:Méthodes d''accès'       and c.counter_name = 'Escalades de verrous de tables/s'^) or
>>%file_sql% echo       ^(c.object_name='MSSQL$%DB_SVC%:Gestionnaire de tampons' and c.counter_name = 'Espérance de vie d''une page'^) or
>>%file_sql% echo       ^(c.object_name='MSSQL$%DB_SVC%:Databases'               and c.counter_name = 'Transactions actives'              and instance_name = '_Total'^) or
>>%file_sql% echo       ^(c.object_name='MSSQL$%DB_SVC%:General Statistics'      and c.counter_name = 'Processus bloqués'^) or
>>%file_sql% echo       ^(c.object_name='MSSQL$%DB_SVC%:General Statistics'      and c.counter_name = 'Connexions utilisateur'^) or
>>%file_sql% echo       ^(c.object_name='MSSQL$%DB_SVC%:Locks'                   and c.counter_name = 'Temps d''attente des verrous ^(ms^)' and instance_name = '_Total'^) or
>>%file_sql% echo       ^(c.object_name='MSSQL$%DB_SVC%:Locks'                   and c.counter_name = 'Attentes de verrous/s'             and instance_name = '_Total'^) or
>>%file_sql% echo       ^(c.object_name='MSSQL$%DB_SVC%:Locks'                   and c.counter_name = 'Nombre d''interblocages/s'         and instance_name = '_Total'^) or
>>%file_sql% echo       ^(c.object_name='MSSQL$%DB_SVC%:Memory Manager'          and c.counter_name = 'Demandes de mémoire en attente'^)
>>%file_sql% echo union
>>%file_sql% echo select left^(c.object_name, 35^)                             AS 'Object name',
>>%file_sql% echo        left^(c.counter_name, 30^)                            AS 'Counter name',
>>%file_sql% echo        cast^(cast^(c.cntr_value*100.0/c2.cntr_value as dec^(5,2^)^) as varchar^) AS 'Value'
>>%file_sql% echo from  sys.dm_os_performance_counters c
>>%file_sql% echo join  sys.dm_os_performance_counters c2 on c2.object_name = c.object_name
>>%file_sql% echo where c.object_name   in ^('MSSQL$%DB_SVC%:Buffer Manager', 'MSSQL$%DB_SVC%:Gestionnaire de tampons'^)
>>%file_sql% echo and   c.counter_name  in ^('Buffer cache hit ratio',      'Taux d''accès au cache des tampons'^)
>>%file_sql% echo and   c2.counter_name in ^('Buffer cache hit ratio base', 'Base du taux d''accès au cache des tampons'^)
>>%file_sql% echo union
>>%file_sql% echo select left^(c.object_name, 35^)                    AS 'Object name',
>>%file_sql% echo        left^(c.counter_name, 30^)                   AS 'Counter name',
>>%file_sql% echo        left^(^(c.cntr_value - c2.cntr_value^)/2, 10^) AS 'Value'
>>%file_sql% echo from  sys.dm_os_performance_counters c
>>%file_sql% echo join %TMPTAB% c2 on c2.object_name = c.object_name and c2.counter_name = c.counter_name
>>%file_sql% echo where ^(c.object_name='MSSQL$%DB_SVC%:Buffer Manager'          and c.counter_name = 'Checkpoint pages/sec'^) or
>>%file_sql% echo       ^(c.object_name='MSSQL$%DB_SVC%:Buffer Manager'          and c.counter_name = 'Lazy writes/sec'^) or
>>%file_sql% echo       ^(c.object_name='MSSQL$%DB_SVC%:Buffer Manager'          and c.counter_name = 'Page reads/sec'^) or
>>%file_sql% echo       ^(c.object_name='MSSQL$%DB_SVC%:Buffer Manager'          and c.counter_name = 'Page writes/sec'^) or
>>%file_sql% echo       ^(c.object_name='MSSQL$%DB_SVC%:SQL Statistics'          and c.counter_name = 'Batch Requests/sec'^) or
>>%file_sql% echo       ^(c.object_name='MSSQL$%DB_SVC%:SQL Statistics'          and c.counter_name = 'SQL Compilations/sec'^) or
>>%file_sql% echo       ^(c.object_name='MSSQL$%DB_SVC%:SQL Statistics'          and c.counter_name = 'SQL Re-Compilations/sec'^) or
>>%file_sql% echo       ^(c.object_name='MSSQL$%DB_SVC%:Gestionnaire de tampons' and c.counter_name = 'Pages de points de contrôle/s'^) or
>>%file_sql% echo       ^(c.object_name='MSSQL$%DB_SVC%:Gestionnaire de tampons' and c.counter_name = 'Écritures différées/s'^) or
>>%file_sql% echo       ^(c.object_name='MSSQL$%DB_SVC%:Gestionnaire de tampons' and c.counter_name = 'Lectures de pages/s'^) or
>>%file_sql% echo       ^(c.object_name='MSSQL$%DB_SVC%:Gestionnaire de tampons' and c.counter_name = 'Écritures de pages/s'^) or
>>%file_sql% echo       ^(c.object_name='MSSQL$%DB_SVC%:SQL Statistics'          and c.counter_name = 'Nombre de requêtes de lots/s'^) or
>>%file_sql% echo       ^(c.object_name='MSSQL$%DB_SVC%:SQL Statistics'          and c.counter_name = 'Compilations SQL/s'^) or
>>%file_sql% echo       ^(c.object_name='MSSQL$%DB_SVC%:SQL Statistics'          and c.counter_name = 'Recompilations SQL/s'^)
>>%file_sql% echo order by 1, 2;
>>%file_sql% echo:
>>%file_sql% echo drop table %TMPTAB%;
>>%file_sql% echo:
goto:EOF
::#
::# End of Audit_perf
::#************************************************************#

:Audit_perf_new
::#************************************************************#
::# Audits Query store and Automatic tuning available from MSSQL 2016 and later
::#
if not "%VER_SQL%"=="13.0" >>%file_sql% echo PRINT ''
if not "%VER_SQL%"=="13.0" >>%file_sql% echo PRINT '+-------------------------+'
if not "%VER_SQL%"=="13.0" >>%file_sql% echo PRINT '^| Automatic tuning option ^|'
if not "%VER_SQL%"=="13.0" >>%file_sql% echo PRINT '+-------------------------+'
if not "%VER_SQL%"=="13.0" >>%file_sql% echo PRINT ''
if not "%VER_SQL%"=="13.0" >>%file_sql% echo:
if not "%VER_SQL%"=="13.0" >>%file_sql% echo select left^(t.name, 30^)                                                                AS 'Name',
if not "%VER_SQL%"=="13.0" >>%file_sql% echo        case when t.desired_state = 1 then 'USER'   else
if not "%VER_SQL%"=="13.0" >>%file_sql% echo 	   case when t.actual_state  = 1 then 'CONFIG' else '' end end                     AS 'Status',
if not "%VER_SQL%"=="13.0" >>%file_sql% echo 	   left^(iif^(t.desired_state_desc ^<^> t.actual_state_desc, t.reason_desc, 'OK'^), 20^) AS 'Reason'
if not "%VER_SQL%"=="13.0" >>%file_sql% echo from sys.database_automatic_tuning_options t;
if not "%VER_SQL%"=="13.0" >>%file_sql% echo:
if not "%VER_SQL%"=="13.0" >>%file_sql% echo PRINT ''
if not "%VER_SQL%"=="13.0" >>%file_sql% echo PRINT '+----------------------------------+'
if not "%VER_SQL%"=="13.0" >>%file_sql% echo PRINT '^| Automatic tuning recommendations ^|'
if not "%VER_SQL%"=="13.0" >>%file_sql% echo PRINT '+----------------------------------+'
if not "%VER_SQL%"=="13.0" >>%file_sql% echo PRINT ''
if not "%VER_SQL%"=="13.0" >>%file_sql% echo:
if not "%VER_SQL%"=="13.0" >>%file_sql% echo select left^(json_value^(r.state, '$.reason'^), 20^)                                                 AS 'Reason',
if not "%VER_SQL%"=="13.0" >>%file_sql% echo        left^(r.reason, 100^)                                                                       AS 'Description',
if not "%VER_SQL%"=="13.0" >>%file_sql% echo        cast^(r.score as int^)                                                                      AS 'Score ^(%%^)',
if not "%VER_SQL%"=="13.0" >>%file_sql% echo        left^(json_value^(r.state, '$.currentValue'^), 10^)                                           AS 'Status',
if not "%VER_SQL%"=="13.0" >>%file_sql% echo        left^(json_value^(r.details, '$.implementationDetails.script'^), 50^)                         AS 'SQL command',
if not "%VER_SQL%"=="13.0" >>%file_sql% echo        cast^([current plan_id] as int^)                                                            AS 'Plan Id.',
if not "%VER_SQL%"=="13.0" >>%file_sql% echo        case when [recommended plan_id] = 1 then 'Yes' else '' end                                AS 'Recommended',
if not "%VER_SQL%"=="13.0" >>%file_sql% echo        case when r.is_revertable_action = 1  then 'Yes' else '' end                              AS 'Revertable',
if not "%VER_SQL%"=="13.0" >>%file_sql% echo        cast^(^(^(regressedPlanExecutionCount + recommendedPlanExecutionCount^) *
if not "%VER_SQL%"=="13.0" >>%file_sql% echo              ^(regressedPlanCpuTimeAverage - recommendedPlanCpuTimeAverage^)/1000000^) as dec^(4,1^)^) AS 'Score'
if not "%VER_SQL%"=="13.0" >>%file_sql% echo from sys.dm_db_tuning_recommendations r
if not "%VER_SQL%"=="13.0" >>%file_sql% echo cross apply openjson ^(Details, '$.planForceDetails'^)
if not "%VER_SQL%"=="13.0" >>%file_sql% echo with ^([query_id] int '$.queryId',
if not "%VER_SQL%"=="13.0" >>%file_sql% echo       [current plan_id] int '$.regressedPlanId',
if not "%VER_SQL%"=="13.0" >>%file_sql% echo       [recommended plan_id] int '$.recommendedPlanId',
if not "%VER_SQL%"=="13.0" >>%file_sql% echo       regressedPlanExecutionCount int,
if not "%VER_SQL%"=="13.0" >>%file_sql% echo       regressedPlanCpuTimeAverage float,
if not "%VER_SQL%"=="13.0" >>%file_sql% echo       recommendedPlanExecutionCount int,
if not "%VER_SQL%"=="13.0" >>%file_sql% echo       recommendedPlanCpuTimeAverage float
if not "%VER_SQL%"=="13.0" >>%file_sql% echo      ^) as planForceDetails;
if not "%VER_SQL%"=="13.0" >>%file_sql% echo:
>>%file_sql% echo PRINT ''
>>%file_sql% echo PRINT '+---------------------------+'
>>%file_sql% echo PRINT '^| Query Store configuration ^|'
>>%file_sql% echo PRINT '+---------------------------+'
>>%file_sql% echo PRINT ''
>>%file_sql% echo:
if     defined SQL_BDD >>%file_sql% echo exec sp_MSforeachdb @command1='if db_id^(''?''^) ^<= 4 or db_name^(db_id^(''?''^)^) ^<^>''%SQL_BDD%'' return; use [?]; print ''*** ? ***''; print ''''
if not defined SQL_BDD >>%file_sql% echo exec sp_MSforeachdb @command1='if db_id^(''?''^) ^<= 4 return; use [?]; print ''*** ? ***''; print ''''
>>%file_sql% echo select ''OFF''+ case when q.actual_state  ^<^> 0 then '' ^> ''+left^(q.actual_state_desc, 12^)  else '''' end  AS ''Actual mode'',
>>%file_sql% echo  ''OFF''+ case when q.desired_state ^<^> 0 then '' ^> ''+left^(q.desired_state_desc, 12^) else '''' end  AS ''Requested mode'',
>>%file_sql% echo  left^(isnull^(case when q.readonly_reason = 1 then ''DB IN READ-ONLY MODE''
>>%file_sql% echo   when q.readonly_reason = 2 then ''DB IN SINGLE-USER MODE''
>>%file_sql% echo   when q.readonly_reason = 4 then ''DB IN EMERGENCY MODE''
>>%file_sql% echo   when q.readonly_reason = 8 then ''DB IN REPLICA SET MODE''
>>%file_sql% echo   when q.readonly_reason = 65536  then ''STORAGE SIZE LIMIT''
>>%file_sql% echo   when q.readonly_reason = 131072 then ''INTERNAL MEMORY LIMIT''
>>%file_sql% echo   when q.readonly_reason = 262144 then ''TEMPORARY MEMORY LIMIT''
>>%file_sql% echo   when q.readonly_reason = 524288 then ''DISK SIZE LIMIT'' else ''NONE'' end,''''^), 22^) AS ''Read-Only reason'',
>>%file_sql% echo  ''ALL'' + case when q.query_capture_mode ^<^> 1 then '' ^> ''+left^(q.query_capture_mode_desc, 12^) else '''' end AS ''Capture mode'',
>>%file_sql% echo  left^(''60'' + case when q.interval_length_minutes ^<^> 60 then '' ^> ''+cast^(q.interval_length_minutes as varchar^) else '''' end, 16^)+'' min'' AS ''Capture interval'',
>>%file_sql% echo  left^(''15'' + case when q.flush_interval_seconds ^<^> 900 then '' ^> ''+cast^(q.flush_interval_seconds/60 as varchar^) else '''' end, 16^)+'' min'' AS ''Flush interval'',
>>%file_sql% echo  cast^(q.current_storage_size_mb as char^(10^)^) AS ''Size	^(MB^)'',
>>%file_sql% echo  cast^(q.current_storage_size_mb*100.0/q.max_storage_size_mb as dec^(4,1^)^) AS ''Used ^(%%^)'',
>>%file_sql% echo  ''100'' + case when q.max_storage_size_mb ^<^> 100 then '' ^> ''+cast^(q.max_storage_size_mb as char^(4^)^) else '''' end AS ''Max size ^(MB^)'',
>>%file_sql% echo  ''200'' + case when q.max_plans_per_query ^<^> 200 then '' ^> ''+cast^(q.max_plans_per_query as char^(4^)^) else '''' end AS ''Max plans'',
>>%file_sql% echo  left^(q.size_based_cleanup_mode_desc, 12^) AS ''Cleanup mode'',
>>%file_sql% echo  ''30'' + case when stale_query_threshold_days ^<^> 30 then '' ^> ''+cast^(stale_query_threshold_days as char^(3^)^) else '''' end AS ''Cleanup days''
>>%file_sql% echo from sys.database_query_store_options q; print ''''';
>>%file_sql% echo:
>>%file_sql% echo PRINT '+--------------------------+'
>>%file_sql% echo PRINT '^| Long running Query Store ^|'
>>%file_sql% echo PRINT '+--------------------------+'
>>%file_sql% echo PRINT ''
>>%file_sql% echo:
>>%file_sql% echo ;with query_store as ^(
>>%file_sql% echo select max^(rs.avg_duration^)/1000.0/1000                                       AS ela_per_exec, 
>>%file_sql% echo        max^(rs.avg_cpu_time^)/1000.0/1000                                       AS cpu_per_exec,
>>%file_sql% echo        max^(rs.avg_physical_io_reads^)*8.0/1024                                 AS pior_per_exec,
>>%file_sql% echo        max^(rs.avg_logical_io_reads^) *8.0/1024                                 AS lior_per_exec,
>>%file_sql% echo        max^(rs.avg_logical_io_writes^)*8.0/1024                                 AS liow_per_exec,
if not "%VER_SQL%"=="13.0" >>%file_sql% echo        max^(s.avg_query_wait_time_ms^)/1000.0                                   AS wait_per_exec,
>>%file_sql% echo        max^(rs.last_execution_time^)                                            AS last_exec,
>>%file_sql% echo        sum^(rs.count_executions^)                                               AS tot_exec,
>>%file_sql% echo        max^(rs.avg_rowcount^)                                                   AS rows,
>>%file_sql% echo        max^(rs.avg_dop^)                                                        AS max_dop,
if not "%VER_SQL%"=="13.0" >>%file_sql% echo        max^(rs.avg_tempdb_space_used^)*8.0/1024                                   AS max_temp,
if not "%VER_SQL%"=="13.0" >>%file_sql% echo 	   max^(s.avg_query_wait_time_ms*rs.count_executions^)/1000.0                 AS tot_wait,
>>%file_sql% echo      count^(distinct p.plan_id^)                                                AS tot_plan,
>>%file_sql% echo      count^(distinct p.query_id^)                                               AS tot_query,
>>%file_sql% echo      sum^(case when rs.execution_type = 0 then rs.count_executions else 0 end^) AS tot_regular,
>>%file_sql% echo      sum^(case when rs.execution_type = 3 then rs.count_executions else 0 end^) AS tot_abort,
>>%file_sql% echo      sum^(case when rs.execution_type = 4 then rs.count_executions else 0 end^) AS tot_except,
if not "%VER_SQL%"=="13.0" >>%file_sql% echo 	   max^(s.wait_category_desc^)                                                AS category,                                                                    
>>%file_sql% echo      q.query_hash                                                             AS query_hash,                                                                                 
>>%file_sql% echo      p.query_plan_hash                                                        AS query_plan_hash,                                                                                 
>>%file_sql% echo      cast^(isnull^(nullif^(replace(substring^(max^(qt.query_sql_text^), ^(q.last_compile_batch_offset_start/2^),
>>%file_sql% echo              case when q.last_compile_batch_offset_end ^< q.last_compile_batch_offset_start
>>%file_sql% echo 			        then 0 else ^(^(q.last_compile_batch_offset_end-q.last_compile_batch_offset_start^)/2^) end
>>%file_sql% echo             ^),')S','S'),''^), max^(qt.query_sql_text^)^) as varchar^(%LEN_FULLSQLT%^)^)                  AS sql_text,
>>%file_sql% echo      max^(p.query_plan^)                                                        AS query_plan
>>%file_sql% echo from sys.query_store_query_text qt
>>%file_sql% echo join sys.query_store_query q                    on qt.query_text_id = q.query_text_id
>>%file_sql% echo join sys.query_store_plan  p                    on q.query_id = p.query_id
>>%file_sql% echo join sys.query_store_runtime_stats rs           on rs.plan_id = p.plan_id
>>%file_sql% echo join sys.query_store_runtime_stats_interval rsi on rsi.runtime_stats_interval_id = rs.runtime_stats_interval_id
if not "%VER_SQL%"=="13.0" >>%file_sql% echo join sys.query_store_wait_stats s               on s.plan_id = p.plan_id 
>>%file_sql% echo where qt.query_sql_text not like '%%sys.%%'
>>%file_sql% echo and   rsi.start_time ^>= dateadd^(HOUR, -2, GETUTCDATE^(^)^)
>>%file_sql% echo group by q.query_hash, p.query_plan_hash, q.last_compile_batch_offset_start, q.last_compile_batch_offset_end
>>%file_sql% echo ^),
>>%file_sql% echo qslist as ^(
>>%file_sql% echo select ela_per_exec, 
>>%file_sql% echo        cpu_per_exec,
>>%file_sql% echo        pior_per_exec,
>>%file_sql% echo        lior_per_exec,
>>%file_sql% echo        liow_per_exec,
if not "%VER_SQL%"=="13.0" >>%file_sql% echo        wait_per_exec,
>>%file_sql% echo        last_exec,
>>%file_sql% echo        tot_exec,
>>%file_sql% echo        rows,
>>%file_sql% echo        max_dop,
if not "%VER_SQL%"=="13.0" >>%file_sql% echo        max_temp,
if not "%VER_SQL%"=="13.0" >>%file_sql% echo        tot_wait,
>>%file_sql% echo        tot_plan,
>>%file_sql% echo        tot_query,
>>%file_sql% echo        tot_regular,
>>%file_sql% echo        tot_abort,
>>%file_sql% echo        tot_except,
if not "%VER_SQL%"=="13.0" >>%file_sql% echo        category,
>>%file_sql% echo        sql_text,
>>%file_sql% echo        query_hash,
>>%file_sql% echo        query_plan_hash,
>>%file_sql% echo        query_plan,
>>%file_sql% echo 	   row_number^(^) over ^(order by ela_per_exec  desc, query_hash^) rn
>>%file_sql% echo --	   row_number^(^) over ^(order by cpu_per_exec  desc, query_hash^) rn
>>%file_sql% echo --	   row_number^(^) over ^(order by pior_per_exec desc, query_hash^) rn
>>%file_sql% echo --	   row_number^(^) over ^(order by lior_per_exec desc, query_hash^) rn
>>%file_sql% echo --	   row_number^(^) over ^(order by liow_per_exec desc, query_hash^) rn
if not "%VER_SQL%"=="13.0" >>%file_sql% echo --	   row_number^(^) over ^(order by wait_per_exec desc, query_hash^) rn
>>%file_sql% echo from query_store
>>%file_sql% echo where ela_per_exec ^>= 1
>>%file_sql% echo ^)
>>%file_sql% echo select cast^(qs.rn as tinyint^)                                          AS 'Rank',
>>%file_sql% echo        cast^(qs.ela_per_exec  as dec^(8,1^)^)                              AS 'ELA/Exec', 
>>%file_sql% echo        cast^(qs.cpu_per_exec  as dec^(8,1^)^)                              AS 'CPU/Exec',
>>%file_sql% echo        cast^(qs.pior_per_exec as dec^(8,1^)^)                              AS 'PIOR/Exec',
>>%file_sql% echo        cast^(qs.lior_per_exec as dec^(8,1^)^)                              AS 'LIOR/Exec',
>>%file_sql% echo        case when qs.liow_per_exec = 0 then ''
>>%file_sql% echo             else right^(replicate^(' ',9-len^(qs.liow_per_exec^)^)+
>>%file_sql% echo             cast^(cast^(qs.liow_per_exec as dec^(7,1^)^) as varchar^),9^) end AS 'LIOW/Exec',
if not "%VER_SQL%"=="13.0" >>%file_sql% echo        cast^(qs.wait_per_exec as dec^(5,1^)^)                              AS 'Wait/Exec',
>>%file_sql% echo        left^(format^(qs.last_exec, '%FMT_DAT3%'^),17^)              AS 'Last Exec',
>>%file_sql% echo        cast^(qs.tot_exec    as int^)                                     AS 'Execs',
>>%file_sql% echo        cast^(qs.rows        as int^)                                     AS 'Rows',
>>%file_sql% echo        cast^(qs.max_dop     as tinyint^)                                 AS 'Max DOP',
if not "%VER_SQL%"=="13.0" >>%file_sql% echo        cast^(qs.max_temp    as tinyint^)                                 AS 'Max TMP',
if not "%VER_SQL%"=="13.0" >>%file_sql% echo        cast^(qs.tot_wait    as tinyint^)                                 AS 'Tot WAIT',
>>%file_sql% echo        cast^(qs.tot_plan    as tinyint^)                                 AS 'Tot Plans',
>>%file_sql% echo        cast^(qs.tot_query   as tinyint^)                                 AS 'Tot Query',
>>%file_sql% echo        cast^(qs.tot_regular as int^)                                     AS 'Tot Regular',
>>%file_sql% echo        cast^(qs.tot_abort   as tinyint^)                                 AS 'Tot Abort',
>>%file_sql% echo        cast^(qs.tot_except  as tinyint^)                                 AS 'Tot Except',
if not "%VER_SQL%"=="13.0" >>%file_sql% echo        left^(qs.category, 10^)                                           AS 'Category',
>>%file_sql% echo        ^(select substring^(max^(qst.plan_handle^), 1, 17^)
>>%file_sql% echo          from sys.dm_exec_query_stats qst
>>%file_sql% echo          where qst.query_plan_hash = qs.query_plan_hash^)               AS 'Plan Hash',
>>%file_sql% echo        char^(13^)+char^(10^)+char^(13^)+char^(10^)+left^(qs.sql_text, %LEN_FULLSQLT%^)+char^(13^)+char^(10^) AS 'SQL Text'
>>%file_sql% echo --	  ,cast^(qs.query_plan as xml^)                                      AS 'Show Plan'
>>%file_sql% echo from qslist qs
>>%file_sql% echo where qs.rn ^<= %TOP_NSQL%
>>%file_sql% echo order by qs.rn;
>>%file_sql% echo:
>>%file_sql% echo PRINT ''
>>%file_sql% echo PRINT '--- Parameter compiled value ---'
>>%file_sql% echo PRINT ''
>>%file_sql% echo:
>>%file_sql% echo ;with xmlnamespaces ^(DEFAULT 'http://schemas.microsoft.com/sqlserver/2004/07/showplan'^), PlanParameters AS ^(
>>%file_sql% echo select cp.plan_handle, qp.query_plan, qp.dbid, qp.objectid
>>%file_sql% echo from sys.dm_exec_cached_plans cp ^(NOLOCK^)
>>%file_sql% echo cross apply sys.dm_exec_query_plan^(cp.plan_handle^) qp
>>%file_sql% echo where qp.query_plan.exist^('//ParameterList'^)=1
>>%file_sql% echo and   cp.cacheobjtype = 'Compiled Plan'
>>%file_sql% echo ^),
>>%file_sql% echo query_store as ^(
>>%file_sql% echo select max^(rs.avg_duration^)/1000.0/1000                                       AS ela_per_exec, 
>>%file_sql% echo        max^(rs.avg_cpu_time^)/1000.0/1000                                       AS cpu_per_exec,
>>%file_sql% echo        max^(rs.avg_physical_io_reads^)*8.0/1024                                 AS pior_per_exec,
>>%file_sql% echo        max^(rs.avg_logical_io_reads^) *8.0/1024                                 AS lior_per_exec,
>>%file_sql% echo        max^(rs.avg_logical_io_writes^)*8.0/1024                                 AS liow_per_exec,
>>%file_sql% echo        q.query_hash                                                           AS query_hash,
>>%file_sql% echo        p.query_plan_hash                                                      AS query_plan_hash
>>%file_sql% echo from sys.query_store_query_text qt
>>%file_sql% echo join sys.query_store_query q                    on qt.query_text_id = q.query_text_id
>>%file_sql% echo join sys.query_store_plan  p                    on q.query_id = p.query_id
>>%file_sql% echo join sys.query_store_runtime_stats rs           on rs.plan_id = p.plan_id
>>%file_sql% echo join sys.query_store_runtime_stats_interval rsi on rsi.runtime_stats_interval_id = rs.runtime_stats_interval_id
>>%file_sql% echo where qt.query_sql_text not like '%sys.%'
>>%file_sql% echo and   rsi.start_time ^>= dateadd^(HOUR, -2, GETUTCDATE^(^)^)
>>%file_sql% echo group by q.query_hash, p.query_plan_hash
>>%file_sql% echo ^),
>>%file_sql% echo qslist as ^(
>>%file_sql% echo select ela_per_exec, 
>>%file_sql% echo        cpu_per_exec,
>>%file_sql% echo        pior_per_exec,
>>%file_sql% echo        lior_per_exec,
>>%file_sql% echo        liow_per_exec,
>>%file_sql% echo        query_plan_hash,
>>%file_sql% echo        row_number^(^) over ^(order by ela_per_exec  desc, query_hash^) rn
>>%file_sql% echo --	   row_number^(^) over ^(order by cpu_per_exec  desc, query_hash^) rn
>>%file_sql% echo --	   row_number^(^) over ^(order by pior_per_exec desc, query_hash^) rn
>>%file_sql% echo --	   row_number^(^) over ^(order by lior_per_exec desc, query_hash^) rn
>>%file_sql% echo --	   row_number^(^) over ^(order by liow_per_exec desc, query_hash^) rn
>>%file_sql% echo from query_store
>>%file_sql% echo where ela_per_exec ^>= 1
>>%file_sql% echo ^),
>>%file_sql% echo PlanHash AS ^(
>>%file_sql% echo select TOP %TOP_NSQL%
>>%file_sql% echo        qs.rn,
>>%file_sql% echo        qst.plan_handle
>>%file_sql% echo from qslist qs
>>%file_sql% echo join sys.dm_exec_query_stats qst on qst.query_plan_hash = qs.query_plan_hash
>>%file_sql% echo where qs.rn ^<= %TOP_NSQL%
>>%file_sql% echo order by qs.rn
>>%file_sql% echo ^)
>>%file_sql% echo select substring^(pp.plan_handle, 1, 17^)                        AS 'Plan Hash',
>>%file_sql% echo        left^(c2.value^('^(@Column^)[1]','sysname'^), 9^)             AS 'Parameter',
>>%file_sql% echo        substring^(replace^(replace^(replace^(c2.value^('^(@ParameterCompiledValue^)[1]','varchar^(80^)'^),'N''',''''^),'^(',''^),'^)',''^), 1, 80^) AS 'Value'--,
>>%file_sql% echo      --pp.query_plan,
>>%file_sql% echo from PlanParameters pp
>>%file_sql% echo cross apply query_plan.nodes^('//ParameterList'^) AS q1^(c1^)
>>%file_sql% echo cross apply c1.nodes^('ColumnReference'^) as q2^(c2^)
>>%file_sql% echo join PlanHash ph on ^(ph.plan_handle = pp.plan_handle^)
>>%file_sql% echo where pp.dbid ^> 4 AND pp.dbid ^< 32767
>>%file_sql% echo --and pp.plan_handle=0x06000500E4805E04800769C90100000001000000000000000000000000000000000000000000000000000000
>>%file_sql% echo order by ph.rn, 2
>>%file_sql% echo OPTION^(RECOMPILE, MAXDOP 1^);
>>%file_sql% echo:
goto:EOF
::#
::# End of Audit_perf_new
::#************************************************************#

:Audit_sql
::#************************************************************#
::# Audits SQL Plan cache, Long running SQL and Top SQL ordered by Elapsed time, CPU time and Physical reads.
::#
>>%file_sql% echo PRINT ''
>>%file_sql% echo PRINT '+----------------+'
>>%file_sql% echo PRINT '^| SQL Plan cache ^|'
>>%file_sql% echo PRINT '+----------------+'
>>%file_sql% echo PRINT ''
>>%file_sql% echo select left^(cp.objtype, 10^)                                                                                                        AS 'Object type',
>>%file_sql% echo        left^(cp.cacheobjtype, 18^)                                                                                                   AS 'Cache type',
>>%file_sql% echo        cast^(count_big^(cp.objtype^) as int^)                                                                                          AS 'Total plans',
>>%file_sql% echo        cast^(sum^(case when cp.usecounts = 1 then 1 else 0 end^) as int^)                                                              AS 'Use count 1',
>>%file_sql% echo        cast^(sum^(cast^(cp.size_in_bytes as dec^(18,2^)^)^)/1024/1024 as dec^(9,2^)^)                                                        AS 'Total ^(Mb^)',
>>%file_sql% echo        cast^(sum^(cast^(^(case when cp.usecounts = 1 then cp.size_in_bytes else 0 end^) as dec^(18,2^)^)^)/1024/1024 as dec^(9,2^)^)           AS 'Use count 1 ^(Mb^)',
>>%file_sql% echo        cast^(sum^(case when usecounts = 1 then 1 else 0 end^)*100.0/count_big^(cp.objtype^) as dec^(5,2^)^)                                AS 'Use count 1 ^(%%^)',
>>%file_sql% echo        cast^(count_big^(objtype^)*1.0/sum^(count_big^(cp.objtype^)^) OVER^(^) * 100.0 as dec^(5,2^)^)                                          AS 'Cache Alloc ^(%%^)',
>>%file_sql% echo        case when cp.objtype = 'Adhoc' and ^(sum^(case when cp.usecounts = 1 then 1 else 0 end^)*100.0/count_big^(cp.objtype^) ^>= 50 or
>>%file_sql% echo             sum^(cast^(cp.size_in_bytes as dec^(18,2^)^)^)/1024/1024 ^>= 2048^) then 
>>%file_sql% echo 			'=^> Optimize for ad-hoc workloads ' + case when max^(c.value_in_use^) = '0' then 'to use' else 'in use' end else '' end  AS 'Diagnostic'
>>%file_sql% echo from sys.dm_exec_cached_plans cp
>>%file_sql% echo cross join sys.configurations c
>>%file_sql% echo where c.name = 'optimize for ad hoc workloads'
>>%file_sql% echo group by cp.objtype, cp.cacheobjtype
>>%file_sql% echo order by 3 desc;
>>%file_sql% echo:
>>%file_sql% echo PRINT ''
>>%file_sql% echo PRINT '*** Detail per database ***'
>>%file_sql% echo PRINT ''
>>%file_sql% echo:
>>%file_sql% echo select left^(cp.objtype, 10^)                                                                                                        AS 'Object type',
>>%file_sql% echo        left^(cp.cacheobjtype, 18^)                                                                                                   AS 'Cache type',
>>%file_sql% echo        left^(isnull^(db_name^(st.dbid^), 'resourcedb'^), %LEN_DBNAME%^)                                                                             AS 'DB Name',
>>%file_sql% echo        cast^(count_big^(cp.objtype^) as int^)                                                                                          AS 'Total plans',
>>%file_sql% echo        cast^(sum^(case when cp.usecounts = 1 then 1 else 0 end^) as int^)                                                              AS 'Use count 1',
>>%file_sql% echo        cast^(sum^(cast^(cp.size_in_bytes as dec^(18,2^)^)^)/1024/1024 as dec^(9,2^)^)                                                        AS 'Total ^(Mb^)',
>>%file_sql% echo        cast^(sum^(cast^(^(case when cp.usecounts = 1 then cp.size_in_bytes else 0 end^) as dec^(18,2^)^)^)/1024/1024 as dec^(9,2^)^)           AS 'Use count 1 ^(Mb^)',
>>%file_sql% echo        cast^(sum^(case when cp.usecounts = 1 then 1 else 0 end^)*100.0/count_big^(cp.objtype^) as dec^(5,2^)^)                             AS 'Use count 1 ^(%%^)',
>>%file_sql% echo        cast^(count_big^(cp.objtype^)*1.0/sum^(count_big^(cp.objtype^)^) OVER^(^) * 100.0 as dec^(5,2^)^)                                       AS 'Cache Alloc ^(%%^)',
>>%file_sql% echo        case when cp.objtype = 'Adhoc' and ^(sum^(case when cp.usecounts = 1 then 1 else 0 end^)*100.0/count_big^(cp.objtype^) ^>= 50 or
>>%file_sql% echo             sum^(cast^(cp.size_in_bytes as dec^(18,2^)^)^)/1024/1024 ^>= 2048^) then 
>>%file_sql% echo 			'=^> Optimize for ad-hoc workloads ' + case when max^(c.value_in_use^) = '0' then 'to use' else 'in use' end else '' end  AS 'Diagnostic'
>>%file_sql% echo from sys.dm_exec_cached_plans cp
>>%file_sql% echo outer apply sys.dm_exec_sql_text^(cp.plan_handle^) st
>>%file_sql% echo cross join sys.configurations c
if defined     SQL_BDD >>%file_sql% echo where db_name^(st.dbid^) = '%SQL_BDD%'
if defined     SQL_BDD >>%file_sql% echo and c.name = 'optimize for ad hoc workloads'
if not defined SQL_BDD >>%file_sql% echo where c.name = 'optimize for ad hoc workloads'
>>%file_sql% echo group by st.dbid, objtype, cacheobjtype
>>%file_sql% echo order by 1, 10 desc, 9 desc;
>>%file_sql% echo:
>>%file_sql% echo PRINT ''
>>%file_sql% echo PRINT '+------------------+'
>>%file_sql% echo PRINT '^| Long running SQL ^|'
>>%file_sql% echo PRINT '+------------------+'
>>%file_sql% echo PRINT ''
>>%file_sql% echo:
>>%file_sql% echo declare @MIN smallint;
>>%file_sql% echo set @MIN = 1;  -- minimum duration from the beginning of the transaction;
>>%file_sql% echo:
>>%file_sql% echo ;with long_query as
>>%file_sql% echo ^(
>>%file_sql% echo select distinct tr.transaction_begin_time,
>>%file_sql% echo        datediff^(second, tr.transaction_begin_time, getdate^(^)^) AS duration_in_secs,
>>%file_sql% echo        login_time,
>>%file_sql% echo        host_name,
>>%file_sql% echo        program_name,
>>%file_sql% echo        login_name,
>>%file_sql% echo        transaction_state,
>>%file_sql% echo        s.cpu_time,
>>%file_sql% echo        st.total_elapsed_time/1000 total_elapsed_time,
>>%file_sql% echo        st.total_worker_time/1000 total_worker_time,
>>%file_sql% echo        case when st.total_worker_time ^> st.total_elapsed_time then 'Yes' else 'No' end AS is_parallel,
>>%file_sql% echo        s.reads,
>>%file_sql% echo        s.writes,
>>%file_sql% echo        c.client_net_address,
>>%file_sql% echo        DB_NAME^(dbid^) as dbname,
>>%file_sql% echo        char^(13^)+char^(10^)+cast^(isnull^(nullif^(substring^(t.text, ^(st.statement_start_offset/2^)+1,
>>%file_sql% echo              case when st.statement_end_offset ^< st.statement_start_offset
>>%file_sql% echo 			        then 0 else ^(^(st.statement_end_offset-st.statement_start_offset^)/2^)+1 end
>>%file_sql% echo             ^), ''^), t.text^) as varchar^(%LEN_SQLT%^)^) as sqlquery
>>%file_sql% echo from sys.dm_tran_active_transactions  AS tr
>>%file_sql% echo      join sys.dm_tran_session_transactions AS ts on tr.transaction_id = ts.transaction_id
>>%file_sql% echo      join sys.dm_exec_sessions             AS s  on ts.session_id     = s.session_id
>>%file_sql% echo      join sys.dm_exec_connections          AS c  on ts.session_id     = c.session_id
>>%file_sql% echo      left outer join sys.dm_exec_requests  AS r  on ts.session_id     = r.session_id
>>%file_sql% echo      join sys.dm_exec_query_stats          AS st on st.sql_handle     = most_recent_sql_handle
>>%file_sql% echo      cross apply sys.dm_exec_sql_text^(st.sql_handle^) t
>>%file_sql% echo where tr.transaction_type = 1        -- read/write mode
>>%file_sql% echo and   tr.transaction_state in ^(2, 7^) -- active transaction
>>%file_sql% echo and   tr.transaction_begin_time ^< dateadd^(s, -@MIN, getdate^(^)^)
>>%file_sql% echo ^)
if "%VER_SQL%"=="11.0" >>%file_sql% echo select left^(format^(l.transaction_begin_time, '%FMT_DAT3%'^), 17^)               AS 'Begin time',
if "%VER_SQL%"=="12.0" >>%file_sql% echo select left^(format^(l.transaction_begin_time, '%FMT_DAT3%'^), 17^)               AS 'Begin time',
if "%VER_SQL%"=="13.0" >>%file_sql% echo select left^(format^(l.transaction_begin_time, '%FMT_DAT3%'^), 17^)               AS 'Begin time',
if "%VER_SQL%"=="14.0" >>%file_sql% echo select left^(format^(l.transaction_begin_time, '%FMT_DAT3%'^), 17^)               AS 'Begin time',
if not "%VER_SQL%"=="11.0" if not "%VER_SQL%"=="12.0" if not "%VER_SQL%"=="13.0" if not "%VER_SQL%"=="14.0" >>%file_sql% echo select left^(convert^(varchar, l.transaction_begin_time, %CNV_DATE%^)+' '+
if not "%VER_SQL%"=="11.0" if not "%VER_SQL%"=="12.0" if not "%VER_SQL%"=="13.0" if not "%VER_SQL%"=="14.0" >>%file_sql% echo              convert^(varchar, l.transaction_begin_time, %CNV_TIME%^), 17^)                      AS 'Begin time',
>>%file_sql% echo        cast^(datediff^(second, l.transaction_begin_time, getdate^(^)^) as int^)            AS 'Duration ^(s^)',
if "%VER_SQL%"=="11.0" >>%file_sql% echo        left^(format^(l.login_time, '%FMT_DAT3%'^), 17^)                           AS 'Login time',
if "%VER_SQL%"=="12.0" >>%file_sql% echo        left^(format^(l.login_time, '%FMT_DAT3%'^), 17^)                           AS 'Login time',
if "%VER_SQL%"=="13.0" >>%file_sql% echo        left^(format^(l.login_time, '%FMT_DAT3%'^), 17^)                           AS 'Login time',
if "%VER_SQL%"=="14.0" >>%file_sql% echo        left^(format^(l.login_time, '%FMT_DAT3%'^), 17^)                           AS 'Login time',
if not "%VER_SQL%"=="11.0" if not "%VER_SQL%"=="12.0" if not "%VER_SQL%"=="13.0" if not "%VER_SQL%"=="14.0" >>%file_sql% echo        left^(convert^(varchar, l.login_time, %CNV_DATE%^)+' '+
if not "%VER_SQL%"=="11.0" if not "%VER_SQL%"=="12.0" if not "%VER_SQL%"=="13.0" if not "%VER_SQL%"=="14.0" >>%file_sql% echo              convert^(varchar, l.login_time, %CNV_TIME%^), 17^) AS 'Login time',
>>%file_sql% echo 	   left^(l.host_name, 12^)                                                         AS 'Machine',
>>%file_sql% echo 	   left^(l.program_name, 10^)                                                      AS 'Program',
>>%file_sql% echo 	   left^(l.login_name,15^)                                                         AS 'Login',
>>%file_sql% echo 	   left^(case l.transaction_state									
>>%file_sql% echo 	             when 2 then 'active'									
>>%file_sql% echo                  when 7 then 'being rolled back' end,17^)                             AS 'Status',
>>%file_sql% echo        cast^(l.cpu_time as varchar^(8^)^)                                                AS 'CPU time',
>>%file_sql% echo 	   cast^(l.total_elapsed_time as varchar^(8^)^)                                      AS 'Elapsed time ^(s^)',
>>%file_sql% echo 	   cast^(l.total_worker_time as varchar^(8^)^)                                       AS 'Worker time ^(s^)',
>>%file_sql% echo 	   l.is_parallel                                                                 AS 'Is parallel query',
>>%file_sql% echo        cast^(cast^(cast^(duration_in_secs/86400 as datetime^) as int^) as varchar^(10^)^) + ' days ' +
>>%file_sql% echo 	   right^(convert^(char^(24^), cast^(duration_in_secs/86400.0 as datetime^), 120^), 13^) AS 'Duration ^(hh:mm:ss^)',
>>%file_sql% echo 	   cast^(l.reads  as int^)                                                         AS 'Reads',
>>%file_sql% echo 	   cast^(l.writes as int^)                                                         AS 'Writes',
>>%file_sql% echo        left^(l.client_net_address, 15^)                                                AS 'IP Address',
>>%file_sql% echo 	   left(l.sqlquery, %LEN_SQLT%^)+char^(13^)+char^(10^)                                       AS 'SQL text'
>>%file_sql% echo from long_query l
>>%file_sql% echo order by duration_in_secs desc;
>>%file_sql% echo:
>>%file_sql% echo PRINT ''
>>%file_sql% echo PRINT '+---------------------------------+'
>>%file_sql% echo PRINT '^| Top SQL ordered by Elapsed time ^|'
>>%file_sql% echo PRINT '+---------------------------------+'
>>%file_sql% echo PRINT ''
>>%file_sql% echo:
>>%file_sql% echo select TOP %TOP_NSQL%
>>%file_sql% echo        cast^(qs.total_elapsed_time/qs.execution_count/1000000.0 as dec^(6,1^)^)                        AS 'Elapsed Time ^(s^)',
>>%file_sql% echo        cast^(qs.total_worker_time/qs.execution_count/1000000.0 as dec^(6,1^)^)                         AS 'CPU time ^(s^)',
>>%file_sql% echo        qs.execution_count                                                                          AS 'Nbr Execs',
if "%VER_SQL%"=="11.0" >>%file_sql% echo        left^(format^(qs.last_execution_time, '%FMT_DAT2%'^), 14^)                                  AS 'Last Exec Date',
if "%VER_SQL%"=="12.0" >>%file_sql% echo        left^(format^(qs.last_execution_time, '%FMT_DAT2%'^), 14^)                                  AS 'Last Exec Date',
if "%VER_SQL%"=="13.0" >>%file_sql% echo        left^(format^(qs.last_execution_time, '%FMT_DAT2%'^), 14^)                                  AS 'Last Exec Date',
if "%VER_SQL%"=="14.0" >>%file_sql% echo        left^(format^(qs.last_execution_time, '%FMT_DAT2%'^), 14^)                                  AS 'Last Exec Date',
if not "%VER_SQL%"=="11.0" if not "%VER_SQL%"=="12.0" if not "%VER_SQL%"=="13.0" if not "%VER_SQL%"=="14.0" >>%file_sql% echo        left^(convert^(varchar, qs.last_execution_time, %CNV_DATE%^)+' '+
if not "%VER_SQL%"=="11.0" if not "%VER_SQL%"=="12.0" if not "%VER_SQL%"=="13.0" if not "%VER_SQL%"=="14.0" >>%file_sql% echo              convert^(varchar, qs.last_execution_time, %CNV_TIME%^), 17^)                  AS 'Last Exec Date',
if not "%VER_SQL%"=="11.0" if not "%VER_SQL%"=="12.0" if not "%VER_SQL%"=="13.0" if not "%VER_SQL%"=="14.0" >>%file_sql% echo        left^(convert^(varchar, qs.creation_time, %CNV_DATE%^)+' '+
if not "%VER_SQL%"=="11.0" if not "%VER_SQL%"=="12.0" if not "%VER_SQL%"=="13.0" if not "%VER_SQL%"=="14.0" >>%file_sql% echo              convert^(varchar, qs.creation_time, %CNV_TIME%^), 17^)                  AS 'Last Cached',
if "%VER_SQL%"=="11.0" >>%file_sql% echo        left^(format^(qs.creation_time, '%FMT_DAT2%'^), 14^)                                        AS 'Last Cached',
if "%VER_SQL%"=="12.0" >>%file_sql% echo        left^(format^(qs.creation_time, '%FMT_DAT2%'^), 14^)                                        AS 'Last Cached',
if "%VER_SQL%"=="13.0" >>%file_sql% echo        left^(format^(qs.creation_time, '%FMT_DAT2%'^), 14^)                                        AS 'Last Cached',
if "%VER_SQL%"=="14.0" >>%file_sql% echo        left^(format^(qs.creation_time, '%FMT_DAT2%'^), 14^)                                        AS 'Last Cached',
if not "%VER_SQL%"=="9.0" if not "%VER_SQL%"=="10.0" >>%file_sql% echo        cast^(qs.total_rows/qs.execution_count as int^)                                               AS '       Rows',
>>%file_sql% echo        cast^(qs.total_physical_reads/qs.execution_count as int^)                                     AS 'Physical Reads',
>>%file_sql% echo        left^(cast^(qs.total_logical_reads/qs.execution_count as bigint^),14^)                          AS 'Logical Reads',
>>%file_sql% echo        cast^(qs.total_logical_writes/qs.execution_count as int^)                                     AS 'Logical Writes',
if "%VER_SQL%"=="12.0" >>%file_sql% echo        cast^(qs.last_dop as int^)                                                                    AS 'Last DOP',
if "%VER_SQL%"=="13.0" >>%file_sql% echo        cast^(qs.last_dop as int^)                                                                    AS 'Last DOP',
if "%VER_SQL%"=="14.0" >>%file_sql% echo        cast^(qs.last_dop as int^)                                                                    AS 'Last DOP',
>>%file_sql% echo        substring^(qs.plan_handle, 1, 17^)                                                            AS 'Plan Hash',
>>%file_sql% echo        left^(isnull^(r.wait_type, ' '^), 30^)                                                          AS 'Current Wait Type',
>>%file_sql% echo        left^(isnull^(r.wait_resource,''^), 30^)                                                        AS 'Current Wait Resource',
>>%file_sql% echo        cast^(replace^(isnull^(r.wait_time,''^),'0',''^) as varchar^(7^)^)                                  AS 'Current Wait time (s)',
>>%file_sql% echo        cast^(replace^(isnull^(r.row_count,''^),'0',''^) as varchar^(7^)^)                                  AS 'Current Rows',
>>%file_sql% echo        cast^(replace^(isnull^(r.granted_query_memory*8,''^),'0',''^) as varchar^(7^)^)                     AS 'Current Mem Used (KB)',
>>%file_sql% echo 	      char^(13^)+char^(10^)+char^(13^)+char^(10^)+cast^(substring^(qt.text, ^(qs.statement_start_offset/2^)+1,
>>%file_sql% echo           ^(^(case qs.statement_end_offset
>>%file_sql% echo              when -1 then datalength^(qt.text^)
>>%file_sql% echo                      else qs.statement_end_offset end
>>%file_sql% echo                         - qs.statement_start_offset^)/2^)+1^) as varchar^(%LEN_FULLSQLT%^)^)+
>>%file_sql% echo           char^(13^)+char^(10^)+replicate^('-',%LEN_FULLSQLT%^)                                                    AS 'SQL Text'--,
>>%file_sql% echo --        isnull^(qp.query_plan,''^)                                                                 AS 'Query Plan'
>>%file_sql% echo from sys.dm_exec_query_stats qs WITH ^(NOLOCK^)
>>%file_sql% echo left outer join  sys.dm_exec_requests r on qs.plan_handle = r.plan_handle and qs.sql_handle = r.sql_handle
>>%file_sql% echo cross apply sys.dm_exec_sql_text^(qs.sql_handle^) qt
>>%file_sql% echo --cross apply sys.dm_exec_query_plan^(qs.plan_handle^) qp
>>%file_sql% echo where qt.text not like '%%sys.%%'
>>%file_sql% echo and   qt.text not like '%%FETCH%%'
>>%file_sql% echo and   qs.total_elapsed_time/qs.execution_count/1000000.0 ^>= %SQL_TIME%
>>%file_sql% echo order by 1 desc
>>%file_sql% echo OPTION ^(RECOMPILE^);
>>%file_sql% echo:
>>%file_sql% echo ;with xmlnamespaces ^(DEFAULT 'http://schemas.microsoft.com/sqlserver/2004/07/showplan'^), PlanParameters AS ^(
>>%file_sql% echo select cp.plan_handle, qp.query_plan, qp.dbid, qp.objectid
>>%file_sql% echo from sys.dm_exec_cached_plans cp ^(NOLOCK^)
>>%file_sql% echo cross apply sys.dm_exec_query_plan^(cp.plan_handle^) qp
>>%file_sql% echo where qp.query_plan.exist^('//ParameterList'^)=1
>>%file_sql% echo and   cp.cacheobjtype = 'Compiled Plan'
>>%file_sql% echo ^),
>>%file_sql% echo PlanHash AS ^(
>>%file_sql% echo select TOP %TOP_NSQL%
>>%file_sql% echo        cast^(qs.total_elapsed_time/qs.execution_count/1000000.0 as dec^(6,1^)^) as elapsed_time,
>>%file_sql% echo        qs.plan_handle
>>%file_sql% echo from sys.dm_exec_query_stats qs WITH ^(NOLOCK^)
>>%file_sql% echo cross apply sys.dm_exec_sql_text^(qs.sql_handle^) qt
>>%file_sql% echo where qt.text not like '%%sys.%%'
>>%file_sql% echo and   qs.total_elapsed_time/qs.execution_count/1000000.0 ^>= %SQL_TIME%
>>%file_sql% echo order by 1 desc^)
>>%file_sql% echo select substring^(pp.plan_handle, 1, 17^)                        AS 'Plan Hash',
>>%file_sql% echo        left^(c2.value^('^(@Column^)[1]','sysname'^), 9^)             AS 'Parameter',
>>%file_sql% echo        substring^(replace^(replace^(replace^(c2.value^('^(@ParameterCompiledValue^)[1]','varchar^(80)'^),'N''',''''^),'^(',''^),'^)',''^), 1, 80^) AS 'Value'--,
>>%file_sql% echo      --pp.query_plan,
>>%file_sql% echo from PlanParameters pp
>>%file_sql% echo cross apply query_plan.nodes^('//ParameterList'^) AS q1^(c1^)
>>%file_sql% echo cross apply c1.nodes^('ColumnReference'^) as q2^(c2^)
>>%file_sql% echo join PlanHash ph on ^(ph.plan_handle = pp.plan_handle^)
>>%file_sql% echo where pp.dbid ^> 4 AND pp.dbid ^< 32767
>>%file_sql% echo --and pp.plan_handle=0x06000500E4805E04800769C90100000001000000000000000000000000000000000000000000000000000000
>>%file_sql% echo order by ph.elapsed_time desc, 2
>>%file_sql% echo OPTION^(RECOMPILE, MAXDOP 1^);
>>%file_sql% echo:
>>%file_sql% echo PRINT ''
>>%file_sql% echo PRINT '+-----------------------------+'
>>%file_sql% echo PRINT '^| Top SQL ordered by CPU time ^|'
>>%file_sql% echo PRINT '+-----------------------------+'
>>%file_sql% echo PRINT ''
>>%file_sql% echo:
>>%file_sql% echo select TOP %TOP_NSQL%
>>%file_sql% echo        cast^(qs.total_elapsed_time/qs.execution_count/1000000.0 as dec^(6,1^)^)                        AS 'Elapsed Time ^(s^)',
>>%file_sql% echo        cast^(qs.total_worker_time/qs.execution_count/1000000.0 as dec^(6,1^)^)                         AS 'CPU time ^(s^)',
>>%file_sql% echo        qs.execution_count                                                                          AS 'Nbr Execs',
if "%VER_SQL%"=="11.0" >>%file_sql% echo        left^(format^(qs.last_execution_time, '%FMT_DAT2%'^), 14^)                                  AS 'Last Exec Date',
if "%VER_SQL%"=="12.0" >>%file_sql% echo        left^(format^(qs.last_execution_time, '%FMT_DAT2%'^), 14^)                                  AS 'Last Exec Date',
if "%VER_SQL%"=="13.0" >>%file_sql% echo        left^(format^(qs.last_execution_time, '%FMT_DAT2%'^), 14^)                                  AS 'Last Exec Date',
if "%VER_SQL%"=="14.0" >>%file_sql% echo        left^(format^(qs.last_execution_time, '%FMT_DAT2%'^), 14^)                                  AS 'Last Exec Date',
if not "%VER_SQL%"=="11.0" if not "%VER_SQL%"=="12.0" if not "%VER_SQL%"=="13.0" if not "%VER_SQL%"=="14.0" >>%file_sql% echo        left^(convert^(varchar, qs.last_execution_time, %CNV_DATE%^)+' '+
if not "%VER_SQL%"=="11.0" if not "%VER_SQL%"=="12.0" if not "%VER_SQL%"=="13.0" if not "%VER_SQL%"=="14.0" >>%file_sql% echo              convert^(varchar, qs.last_execution_time, %CNV_TIME%^), 17^)                  AS 'Last Exec Date',
if not "%VER_SQL%"=="11.0" if not "%VER_SQL%"=="12.0" if not "%VER_SQL%"=="13.0" if not "%VER_SQL%"=="14.0" >>%file_sql% echo        left^(convert^(varchar, qs.creation_time, %CNV_DATE%^)+' '+
if not "%VER_SQL%"=="11.0" if not "%VER_SQL%"=="12.0" if not "%VER_SQL%"=="13.0" if not "%VER_SQL%"=="14.0" >>%file_sql% echo              convert^(varchar, qs.creation_time, %CNV_TIME%^), 17^)                  AS 'Last Cached',
if "%VER_SQL%"=="11.0" >>%file_sql% echo        left^(format^(qs.creation_time, '%FMT_DAT2%'^), 14^)                                        AS 'Last Cached',
if "%VER_SQL%"=="12.0" >>%file_sql% echo        left^(format^(qs.creation_time, '%FMT_DAT2%'^), 14^)                                        AS 'Last Cached',
if "%VER_SQL%"=="13.0" >>%file_sql% echo        left^(format^(qs.creation_time, '%FMT_DAT2%'^), 14^)                                        AS 'Last Cached',
if "%VER_SQL%"=="14.0" >>%file_sql% echo        left^(format^(qs.creation_time, '%FMT_DAT2%'^), 14^)                                        AS 'Last Cached',
if not "%VER_SQL%"=="9.0" if not "%VER_SQL%"=="10.0" >>%file_sql% echo        cast^(qs.total_rows/qs.execution_count as int^)                                               AS '       Rows',
>>%file_sql% echo        cast^(qs.total_physical_reads/qs.execution_count as int^)                                     AS 'Physical Reads',
>>%file_sql% echo        left^(cast^(qs.total_logical_reads/qs.execution_count as bigint^),14^)                          AS 'Logical Reads',
>>%file_sql% echo        cast^(qs.total_logical_writes/qs.execution_count as int^)                                     AS 'Logical Writes',
if "%VER_SQL%"=="12.0" >>%file_sql% echo        cast^(qs.last_dop as int^)                                                                    AS 'Last DOP',
if "%VER_SQL%"=="13.0" >>%file_sql% echo        cast^(qs.last_dop as int^)                                                                    AS 'Last DOP',
if "%VER_SQL%"=="14.0" >>%file_sql% echo        cast^(qs.last_dop as int^)                                                                    AS 'Last DOP',
>>%file_sql% echo        substring^(qs.plan_handle, 1, 17^)                                                            AS 'Plan Hash',
>>%file_sql% echo        left^(isnull^(r.wait_type, ' '^), 30^)                                                          AS 'Current Wait Type',
>>%file_sql% echo        left^(isnull^(r.wait_resource,''^), 30^)                                                        AS 'Current Wait Resource',
>>%file_sql% echo        cast^(replace^(isnull^(r.wait_time,''^),'0',''^) as varchar^(7^)^)                                  AS 'Current Wait time (s)',
>>%file_sql% echo        cast^(replace^(isnull^(r.row_count,''^),'0',''^) as varchar^(7^)^)                                  AS 'Current Rows',
>>%file_sql% echo        cast^(replace^(isnull^(r.granted_query_memory*8,''^),'0',''^) as varchar^(7^)^)                     AS 'Current Mem Used (KB)',
>>%file_sql% echo 	      char^(13^)+char^(10^)+char^(13^)+char^(10^)+cast^(substring^(qt.text, ^(qs.statement_start_offset/2^)+1,
>>%file_sql% echo           ^(^(case qs.statement_end_offset
>>%file_sql% echo              when -1 then datalength^(qt.text^)
>>%file_sql% echo                      else qs.statement_end_offset end
>>%file_sql% echo                         - qs.statement_start_offset^)/2^)+1^) as varchar^(%LEN_FULLSQLT%^)^)+
>>%file_sql% echo           char^(13^)+char^(10^)+replicate^('-',%LEN_FULLSQLT%^)                                                    AS 'SQL Text'--,
>>%file_sql% echo --        isnull^(qp.query_plan,''^)                                                                 AS 'Query Plan'
>>%file_sql% echo from sys.dm_exec_query_stats qs WITH ^(NOLOCK^)
>>%file_sql% echo left outer join  sys.dm_exec_requests r on qs.plan_handle = r.plan_handle and qs.sql_handle = r.sql_handle
>>%file_sql% echo cross apply sys.dm_exec_sql_text^(qs.sql_handle^) qt
>>%file_sql% echo --cross apply sys.dm_exec_query_plan^(qs.plan_handle^) qp
>>%file_sql% echo where qt.text not like '%%sys.%%'
>>%file_sql% echo and   qt.text not like '%%FETCH%%'
>>%file_sql% echo and   qs.total_elapsed_time/qs.execution_count/1000000.0 ^>= %SQL_TIME%
>>%file_sql% echo order by 2 desc
>>%file_sql% echo OPTION ^(RECOMPILE^);
>>%file_sql% echo:
>>%file_sql% echo PRINT ''
>>%file_sql% echo PRINT '--- Parameter compiled value ---'
>>%file_sql% echo PRINT ''
>>%file_sql% echo:
>>%file_sql% echo ;with xmlnamespaces ^(DEFAULT 'http://schemas.microsoft.com/sqlserver/2004/07/showplan'^), PlanParameters AS ^(
>>%file_sql% echo select cp.plan_handle, qp.query_plan, qp.dbid, qp.objectid
>>%file_sql% echo from sys.dm_exec_cached_plans cp ^(NOLOCK^)
>>%file_sql% echo cross apply sys.dm_exec_query_plan^(cp.plan_handle^) qp
>>%file_sql% echo where qp.query_plan.exist^('//ParameterList'^)=1
>>%file_sql% echo and   cp.cacheobjtype = 'Compiled Plan'
>>%file_sql% echo ^),
>>%file_sql% echo PlanHash AS ^(
>>%file_sql% echo select TOP %TOP_NSQL%
>>%file_sql% echo        cast^(qs.total_worker_time/qs.execution_count/1000000.0 as dec^(6,1^)^)  as cpu_time,
>>%file_sql% echo        qs.plan_handle
>>%file_sql% echo from sys.dm_exec_query_stats qs WITH ^(NOLOCK^)
>>%file_sql% echo cross apply sys.dm_exec_sql_text^(qs.sql_handle^) qt
>>%file_sql% echo where qt.text not like '%%sys.%%'
>>%file_sql% echo and   qs.total_elapsed_time/qs.execution_count/1000000.0 ^>= %SQL_TIME%
>>%file_sql% echo order by 1 desc^)
>>%file_sql% echo select substring^(pp.plan_handle, 1, 17^)                        AS 'Plan Hash',
>>%file_sql% echo        left^(c2.value^('^(@Column^)[1]','sysname'^), 9^)             AS 'Parameter',
>>%file_sql% echo        substring^(replace^(replace^(replace^(c2.value^('^(@ParameterCompiledValue^)[1]','varchar^(80)'^),'N''',''''^),'^(',''^),'^)',''^), 1, 80^) AS 'Value'--,
>>%file_sql% echo      --pp.query_plan,
>>%file_sql% echo from PlanParameters pp
>>%file_sql% echo cross apply query_plan.nodes^('//ParameterList'^) AS q1^(c1^)
>>%file_sql% echo cross apply c1.nodes^('ColumnReference'^) as q2^(c2^)
>>%file_sql% echo join PlanHash ph on ^(ph.plan_handle = pp.plan_handle^)
>>%file_sql% echo where pp.dbid ^> 4 AND pp.dbid ^< 32767
>>%file_sql% echo --and pp.plan_handle=0x06000500E4805E04800769C90100000001000000000000000000000000000000000000000000000000000000
>>%file_sql% echo order by ph.cpu_time desc, 2
>>%file_sql% echo OPTION^(RECOMPILE, MAXDOP 1^);
>>%file_sql% echo:
>>%file_sql% echo PRINT ''
>>%file_sql% echo PRINT '+-----------------------------------+'
>>%file_sql% echo PRINT '^| Top SQL ordered by Physical reads ^|'
>>%file_sql% echo PRINT '+-----------------------------------+'
>>%file_sql% echo PRINT ''
>>%file_sql% echo:
>>%file_sql% echo select TOP %TOP_NSQL%
>>%file_sql% echo        cast^(qs.total_elapsed_time/qs.execution_count/1000000.0 as dec^(6,1^)^)                        AS 'Elapsed Time ^(s^)',
>>%file_sql% echo        cast^(qs.total_worker_time/qs.execution_count/1000000.0 as dec^(6,1^)^)                         AS 'CPU time ^(s^)',
>>%file_sql% echo        qs.execution_count                                                                          AS 'Nbr Execs',
if "%VER_SQL%"=="11.0" >>%file_sql% echo        left^(format^(qs.last_execution_time, '%FMT_DAT2%'^), 14^)                                  AS 'Last Exec Date',
if "%VER_SQL%"=="12.0" >>%file_sql% echo        left^(format^(qs.last_execution_time, '%FMT_DAT2%'^), 14^)                                  AS 'Last Exec Date',
if "%VER_SQL%"=="13.0" >>%file_sql% echo        left^(format^(qs.last_execution_time, '%FMT_DAT2%'^), 14^)                                  AS 'Last Exec Date',
if "%VER_SQL%"=="14.0" >>%file_sql% echo        left^(format^(qs.last_execution_time, '%FMT_DAT2%'^), 14^)                                  AS 'Last Exec Date',
if not "%VER_SQL%"=="11.0" if not "%VER_SQL%"=="12.0" if not "%VER_SQL%"=="13.0" if not "%VER_SQL%"=="14.0" >>%file_sql% echo        left^(convert^(varchar, qs.last_execution_time, %CNV_DATE%^)+' '+
if not "%VER_SQL%"=="11.0" if not "%VER_SQL%"=="12.0" if not "%VER_SQL%"=="13.0" if not "%VER_SQL%"=="14.0" >>%file_sql% echo              convert^(varchar, qs.last_execution_time, %CNV_TIME%^), 17^)                  AS 'Last Exec Date',
if not "%VER_SQL%"=="11.0" if not "%VER_SQL%"=="12.0" if not "%VER_SQL%"=="13.0" if not "%VER_SQL%"=="14.0" >>%file_sql% echo        left^(convert^(varchar, qs.creation_time, %CNV_DATE%^)+' '+
if not "%VER_SQL%"=="11.0" if not "%VER_SQL%"=="12.0" if not "%VER_SQL%"=="13.0" if not "%VER_SQL%"=="14.0" >>%file_sql% echo              convert^(varchar, qs.creation_time, %CNV_TIME%^), 17^)                  AS 'Last Cached',
if "%VER_SQL%"=="11.0" >>%file_sql% echo        left^(format^(qs.creation_time, '%FMT_DAT2%'^), 14^)                                        AS 'Last Cached',
if "%VER_SQL%"=="12.0" >>%file_sql% echo        left^(format^(qs.creation_time, '%FMT_DAT2%'^), 14^)                                        AS 'Last Cached',
if "%VER_SQL%"=="13.0" >>%file_sql% echo        left^(format^(qs.creation_time, '%FMT_DAT2%'^), 14^)                                        AS 'Last Cached',
if "%VER_SQL%"=="14.0" >>%file_sql% echo        left^(format^(qs.creation_time, '%FMT_DAT2%'^), 14^)                                        AS 'Last Cached',
if not "%VER_SQL%"=="9.0" if not "%VER_SQL%"=="10.0" >>%file_sql% echo        cast^(qs.total_rows/qs.execution_count as int^)                                               AS '       Rows',
>>%file_sql% echo        cast^(qs.total_physical_reads/qs.execution_count as int^)                                     AS 'Physical Reads',
>>%file_sql% echo        left^(cast^(qs.total_logical_reads/qs.execution_count as bigint^),14^)                          AS 'Logical Reads',
>>%file_sql% echo        cast^(qs.total_logical_writes/qs.execution_count as int^)                                     AS 'Logical Writes',
if "%VER_SQL%"=="12.0" >>%file_sql% echo        cast^(qs.last_dop as int^)                                                                    AS 'Last DOP',
if "%VER_SQL%"=="13.0" >>%file_sql% echo        cast^(qs.last_dop as int^)                                                                    AS 'Last DOP',
if "%VER_SQL%"=="14.0" >>%file_sql% echo        cast^(qs.last_dop as int^)                                                                    AS 'Last DOP',
>>%file_sql% echo        substring^(qs.plan_handle, 1, 17^)                                                            AS 'Plan Hash',
>>%file_sql% echo        left^(isnull^(r.wait_type, ' '^), 30^)                                                          AS 'Current Wait Type',
>>%file_sql% echo        left^(isnull^(r.wait_resource,''^), 30^)                                                        AS 'Current Wait Resource',
>>%file_sql% echo        cast^(replace^(isnull^(r.wait_time,''^),'0',''^) as varchar^(7^)^)                                  AS 'Current Wait time (s)',
>>%file_sql% echo        cast^(replace^(isnull^(r.row_count,''^),'0',''^) as varchar^(7^)^)                                  AS 'Current Rows',
>>%file_sql% echo        cast^(replace^(isnull^(r.granted_query_memory*8,''^),'0',''^) as varchar^(7^)^)                     AS 'Current Mem Used (KB)',
>>%file_sql% echo 	      char^(13^)+char^(10^)+char^(13^)+char^(10^)+cast^(substring^(qt.text, ^(qs.statement_start_offset/2^)+1,
>>%file_sql% echo           ^(^(case qs.statement_end_offset
>>%file_sql% echo              when -1 then datalength^(qt.text^)
>>%file_sql% echo                      else qs.statement_end_offset end
>>%file_sql% echo                         - qs.statement_start_offset^)/2^)+1^) as varchar^(%LEN_FULLSQLT%^)^)+
>>%file_sql% echo           char^(13^)+char^(10^)+replicate^('-',%LEN_FULLSQLT%^)                                                    AS 'SQL Text'--,
>>%file_sql% echo --        isnull^(qp.query_plan,''^)                                                                 AS 'Query Plan'
>>%file_sql% echo from sys.dm_exec_query_stats qs WITH ^(NOLOCK^)
>>%file_sql% echo left outer join  sys.dm_exec_requests r on qs.plan_handle = r.plan_handle and qs.sql_handle = r.sql_handle
>>%file_sql% echo cross apply sys.dm_exec_sql_text^(qs.sql_handle^) qt
>>%file_sql% echo --cross apply sys.dm_exec_query_plan^(qs.plan_handle^) qp
>>%file_sql% echo where qt.text not like '%%sys.%%'
>>%file_sql% echo and   qt.text not like '%%FETCH%%'
>>%file_sql% echo and   qs.total_elapsed_time/qs.execution_count/1000000.0 ^>= %SQL_TIME%
>>%file_sql% echo order by 7 desc
>>%file_sql% echo OPTION ^(RECOMPILE^);
>>%file_sql% echo:
>>%file_sql% echo PRINT ''
>>%file_sql% echo PRINT '--- Parameter compiled value ---'
>>%file_sql% echo PRINT ''
>>%file_sql% echo:
>>%file_sql% echo ;with xmlnamespaces ^(DEFAULT 'http://schemas.microsoft.com/sqlserver/2004/07/showplan'^), PlanParameters AS ^(
>>%file_sql% echo select cp.plan_handle, qp.query_plan, qp.dbid, qp.objectid
>>%file_sql% echo from sys.dm_exec_cached_plans cp ^(NOLOCK^)
>>%file_sql% echo cross apply sys.dm_exec_query_plan^(cp.plan_handle^) qp
>>%file_sql% echo where qp.query_plan.exist^('//ParameterList'^)=1
>>%file_sql% echo and   cp.cacheobjtype = 'Compiled Plan'
>>%file_sql% echo ^),
>>%file_sql% echo PlanHash AS ^(
>>%file_sql% echo select TOP %TOP_NSQL%
>>%file_sql% echo        cast^(qs.total_physical_reads/qs.execution_count as int^) as physical_reads,
>>%file_sql% echo        qs.plan_handle
>>%file_sql% echo from sys.dm_exec_query_stats qs WITH ^(NOLOCK^)
>>%file_sql% echo cross apply sys.dm_exec_sql_text^(qs.sql_handle^) qt
>>%file_sql% echo where qt.text not like '%%sys.%%'
>>%file_sql% echo and   qs.total_elapsed_time/qs.execution_count/1000000.0 ^>= %SQL_TIME%
>>%file_sql% echo order by 1 desc^)
>>%file_sql% echo select substring^(pp.plan_handle, 1, 17^)                        AS 'Plan Hash',
>>%file_sql% echo        left^(c2.value^('^(@Column^)[1]','sysname'^), 9^)             AS 'Parameter',
>>%file_sql% echo        substring^(replace^(replace^(replace^(c2.value^('^(@ParameterCompiledValue^)[1]','varchar^(80)'^),'N''',''''^),'^(',''^),'^)',''^), 1, 80^) AS 'Value'--,
>>%file_sql% echo      --pp.query_plan,
>>%file_sql% echo from PlanParameters pp
>>%file_sql% echo cross apply query_plan.nodes^('//ParameterList'^) AS q1^(c1^)
>>%file_sql% echo cross apply c1.nodes^('ColumnReference'^) as q2^(c2^)
>>%file_sql% echo join PlanHash ph on ^(ph.plan_handle = pp.plan_handle^)
>>%file_sql% echo where pp.dbid ^> 4 AND pp.dbid ^< 32767
>>%file_sql% echo --and pp.plan_handle=0x06000500E4805E04800769C90100000001000000000000000000000000000000000000000000000000000000
>>%file_sql% echo order by ph.physical_reads desc, 2
>>%file_sql% echo OPTION^(RECOMPILE, MAXDOP 1^);
>>%file_sql% echo:
>>%file_sql% echo PRINT ''
>>%file_sql% echo PRINT '+-----------------+'
>>%file_sql% echo PRINT '^| Most common SQL ^|'
>>%file_sql% echo PRINT '+-----------------+'
>>%file_sql% echo PRINT ''
>>%file_sql% echo select count^(c.session_id^)                                                                                 AS 'Exec Count',
>>%file_sql% echo        char^(13^)+char^(10^)+
>>%file_sql% echo        cast^(case when charindex^('^)S', t.text^) ^> 0 then substring^(t.text, charindex^('^)S', t.text^)+1, %LEN_SQLT%^)
>>%file_sql% echo                  when charindex^('^)U', t.text^) ^> 0 then substring^(t.text, charindex^('^)U', t.text^)+1, %LEN_SQLT%^)
>>%file_sql% echo                  when charindex^('^)D', t.text^) ^> 0 then substring^(t.text, charindex^('^)D', t.text^)+1, %LEN_SQLT%^)
>>%file_sql% echo                  when charindex^('^)E', t.text^) ^> 0 then substring^(t.text, charindex^('^)E', t.text^)+1, %LEN_SQLT%^)
>>%file_sql% echo                                                   else t.text end AS CHAR^(%LEN_SQLT%^)^)
>>%file_sql% echo                  +char^(13^)+char^(10^)+replicate^('-',110^)                                                     AS 'SQL Text'--,
>>%file_sql% echo from sys.dm_exec_connections c
>>%file_sql% echo cross apply sys.dm_exec_sql_text^(most_recent_sql_handle^) t
>>%file_sql% echo where c.session_id ^> 50
>>%file_sql% echo and c.session_id ^<^> @@SPID
>>%file_sql% echo and t.text not like '%%sys.dm%%'
>>%file_sql% echo group by t.text
>>%file_sql% echo having count^(*^) ^> 1
>>%file_sql% echo order by 1 desc;
>>%file_sql% echo:
goto:EOF
::#
::# End of Audit_sql
::#************************************************************#

:Check_db
::#************************************************************#
::# Checks database for used date formats and max length of data for display
::#
>%file_sql% echo set nocount on
if /I "%CMD_SQL%"=="osql" >>%file_sql% echo PRINT ''
>>%file_sql% echo select 'LEN_DBNAME='+cast^(max^(len^(d.name^)^) as varchar^(2^)^) from sys.sysdatabases d;
>>%file_sql% echo select 'VER_SQL='+cast^(SERVERPROPERTY^('productversion'^) as char^(4^)^);
>>%file_sql% echo select 'EDT_SQL='+cast^(substring^(lower^(cast^(SERVERPROPERTY^('Edition'^) as varchar^)^), 1, charindex^(' ', cast^(SERVERPROPERTY^('Edition'^) as varchar^), 1^) - 1^) as char^(10^)^);
if not defined SQL_BDD >>%file_sql% echo create table #len_objects ^(dbname varchar^(50^), tablen int, indlen int^)
if not defined SQL_BDD >>%file_sql% echo exec sp_MSforeachdb @command1='if db_id^(''?''^) ^<= 4 return; use [?]; insert into #len_objects
if not defined SQL_BDD >>%file_sql% echo select db_name^(db_id^(''?''^)^), max^(len^(t.name^)^), max^(len^(i.name^)^) from sys.tables t left outer join sys.indexes i on i.object_id = t.object_id where lower^(i.name^) like ''[a-z]%%'';';
if not defined SQL_BDD >>%file_sql% echo select 'LEN_TABLE='+cast^(isnull^(max^(tablen^),6^) as varchar^(2^)^) from #len_objects;
if not defined SQL_BDD >>%file_sql% echo select 'LEN_INDEX='+cast^(isnull^(max^(indlen^),6^) as varchar^(3^)^) from #len_objects;
if not defined SQL_BDD >>%file_sql% echo drop table #len_objects;
if     defined SQL_BDD >>%file_sql% echo use [%SQL_BDD%]
if not defined LOGIN   >>%file_sql% echo select 'LEN_LOGIN='+cast^(max^(len^(s.login_name^)^) as varchar^(2^)^) from sys.dm_exec_sessions s;
if     defined LOGIN   >>%file_sql% echo select 'LEN_LOGIN='+cast^(max^(len^('%LOGIN%')) as varchar^(2^)^)    -- Lists only for a login
if not defined LOGIN   >>%file_sql% echo select 'LEN_OWNER='+cast^(isnull^(max^(len^(s.name^)^), 5^) as varchar^(2^)^) from sys.schemas s where s.schema_id between 5 and 16383;
if     defined LOGIN   >>%file_sql% echo select 'LEN_OWNER='+cast^(isnull^(max^(len^(s.name^)^), 0^) as varchar^(2^)^) from sys.schemas s where s.name = '%LOGIN%';
if not defined SQL_BDD >>%file_sql% echo select 'LEN_OBJECT='+cast^(max^(len^(o.name^)^) as varchar^(2^)^) from sys.all_objects o where o.type in ^('P','FN'^);
if     defined SQL_BDD >>%file_sql% echo select 'LEN_OBJECT='+cast^(isnull^(max^(len^(o.name^)^), 30^) as varchar^(2^)^) from sys.objects o;
if     defined SQL_BDD >>%file_sql% echo select 'LEN_TABLE='+cast^(max^(len^(t.name^)^) as varchar^(2^)^) from sys.tables t;
if     defined SQL_BDD >>%file_sql% echo select 'LEN_INDEX='+cast^(isnull^(max^(len^(i.name^)^), 30^) as varchar^(2^)^) from sys.indexes i where ObjectProperty^(i.object_id,'IsUserTable'^) = 1 and lower^(name^) like '[a-z]%%';
>>%file_sql% echo select 'LEN_SQLTEXT='+cast^(max^(len^(t.text^)^) as varchar^(6^)^) from sys.dm_exec_requests r cross apply sys.dm_exec_sql_text^(r.sql_handle^) t;
>>%file_sql% echo select 'LEN_DBFILE='+cast^(max^(len^(f.physical_name^)^) as varchar^(3^)^) from sys.master_files f;
>>%file_sql% echo select 'LEN_BKPFILE='+cast^(max^(len^(b.physical_device_name^)^) as varchar^(3^)^) from msdb.dbo.backupmediafamily b;
>>%file_sql% echo select 'LEN_FNAME='+cast^(max^(len^(f.name^)^) as varchar^(3^)^) from sys.master_files f;
>>%file_sql% echo select 'LEN_FGNAME='+cast^(max^(len^(fg.name^)^) as varchar^(3^)^) from sys.filegroups fg;
>>%file_sql% echo select 'TMPTAB=#%progname%'+cast^(@@SPID as varchar^);
call :Display_script LIST OF INSTRUCTIONS IN THE SQL SCRIPT [%file_sql%]
if defined     DB_PWD if "%DISPLAY%"=="1" >>%file_log% echo %CMD_SQL% -S %DB_NAM% -U %DB_USER% -d master -i %file_sql% -o %file_tmp% -P %DB_PWD% -h-1
if not defined DB_PWD if "%DISPLAY%"=="1" >>%file_log% echo %CMD_SQL% -S %DB_NAM% -E -d master -i %file_sql% -o %file_tmp% -h-1
if defined     DB_PWD %CMD_SQL% -S %DB_NAM% -U %DB_USER% -d master -i %file_sql% -o %file_tmp% -P %DB_PWD% -h-1
if not defined DB_PWD %CMD_SQL% -S %DB_NAM% -E -d master -i %file_sql% -o %file_tmp% -h-1
type %file_tmp% | findstr "LEN" >NUL
if errorlevel 1 (
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
	for /f "tokens=2 delims==" %%a in ('type %file_tmp% ^| find "EDT_SQL"') do endlocal & set "EDT_SQL=%%a"
	setlocal enabledelayedexpansion
	for /f "tokens=2 delims==" %%a in ('type %file_tmp% ^| find "LEN_FNAME"') do endlocal & set "LEN_FNAME=%%a"
	setlocal enabledelayedexpansion
	for /f "tokens=2 delims==" %%a in ('type %file_tmp% ^| find "LEN_FGNAME"') do endlocal & set "LEN_FGNAME=%%a"
	setlocal enabledelayedexpansion
	for /f "tokens=2 delims==" %%a in ('type %file_tmp% ^| find "LEN_DBFILE"') do endlocal & set "LEN_DBFILE=%%a"
	setlocal enabledelayedexpansion
	for /f "tokens=2 delims==" %%a in ('type %file_tmp% ^| find "LEN_BKPFILE"') do endlocal & set "LEN_BKPFILE=%%a"
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
	setlocal enabledelayedexpansion
	for /f "tokens=2 delims==" %%a in ('type %file_tmp% ^| find "TMPTAB"') do endlocal & set "TMPTAB=%%a"
	set RET=0
)
set LEN_DBNAME=%LEN_DBNAME: =%
set VER_SQL=%VER_SQL: =%
set EDT_SQL=%EDT_SQL: =%
set LEN_FNAME=%LEN_FNAME: =%
set LEN_FGNAME=%LEN_FGNAME: =%
set LEN_DBFILE=%LEN_DBFILE: =%
set LEN_BKPFILE=%LEN_BKPFILE: =%
set LEN_LOGIN=%LEN_LOGIN: =%
set LEN_TABLE=%LEN_TABLE: =%
set LEN_INDEX=%LEN_INDEX: =%
set LEN_OWNER=%LEN_OWNER: =%
set LEN_OBJECT=%LEN_OBJECT: =%
set LEN_SQLT=%LEN_SQLT: =%
set TMPTAB=%TMPTAB: =%
if %LEN_INDEX% GTR 50 set LEN_INDEX=50
if defined LOGIN if "%LEN_OWNER%" == "0" (
   call :Display ERROR: Invalid value for the variable "LOGIN" [%LOGIN%] !!
   set RET=1
)
if defined LOGIN if "%LEN_OWNER%" LSS "5" set LEN_OWNER=5
if %LEN_SQLTEXT% LSS %LEN_SQLT% set LEN_SQLT=%LEN_SQLTEXT%
if not "%VER_SQL:~-2,1%"=="." set VER_SQL=%VER_SQL:~,-1%
if "%DISPLAY%"=="1" echo LEN_DBNAME=[%LEN_DBNAME%] VER_SQL=[%VER_SQL%] EDT_SQL=[%EDT_SQL%] LEN_FNAME=[%LEN_FNAME%] LEN_FGNAME=[%LEN_FGNAME%] LEN_DBFILE=[%LEN_DBFILE%] LEN_BKPFILE=[%LEN_DBFILE%] LEN_LOGIN=[%LEN_LOGIN%] LEN_TABLE=[%LEN_TABLE%] LEN_INDEX=[%LEN_INDEX%] LEN_OWNER=[%LEN_OWNER%] LEN_OBJECT=[%LEN_OBJECT%]
del %file_tmp%
if "%FLG_COMP%"=="1" if not "%VER_SQL%"=="13.0" if not "%VER_SQL%"=="14.0" if not "%EDT_SQL%"=="enterprise" (
	call :Display WARNING: The SQL Server edition [%EDT_SQL%] does not support compression [The "FLG_COMP" variable must be 0] !!
	call :Display
	set FLG_COMP=0
)
if "%FLG_COMP%"=="1" if not "%VER_SQL%"=="13.0" if not "%VER_SQL%"=="14.0" if not "%EDT_SQL%"=="enterprise" (
	call :Display WARNING: The SQL Server edition [%EDT_SQL%] does not support partitioning [The "FLG_PART" variable must be 0] !!
	call :Display
	set FLG_PART=0
)
exit /B %RET%
::# End of Check_db
::#************************************************************#

:Check_datefmt
::#************************************************************#
::# Checks if the SQL Server date format is valid
::#
::# List of arguments passed to the function:
::#  %1 = format date variable
::#
if not defined %~1 endlocal & exit /B
set RET=0
setlocal enabledelayedexpansion
set FMT=!%1!
for /f "tokens=1-6 delims=/: " %%i in ("!FMT!") do (
if not "%%i"=="" if not "%%i"=="dd" if not "%%i"=="dddd" if not "%%i"=="MM" if not "%%i"=="MMM" if not "%%i"=="MMMM" if not "%%i"=="yy"  if not "%%i"=="yyyy" if not "%%i"=="hh" if not "%%i"=="HH" if not "%%i"=="mm" if not "%%i"=="ss" if not "%%i"=="tt" set RET=1
if not "%%j"=="" if not "%%j"=="dd" if not "%%j"=="dddd" if not "%%j"=="MM" if not "%%j"=="MMM" if not "%%j"=="MMMM" if not "%%j"=="yy"  if not "%%j"=="yyyy" if not "%%j"=="hh" if not "%%j"=="HH" if not "%%j"=="mm" if not "%%j"=="ss" if not "%%j"=="tt" set RET=1
if not "%%k"=="" if not "%%k"=="dd" if not "%%k"=="dddd" if not "%%k"=="MM" if not "%%k"=="MMM" if not "%%k"=="MMMM" if not "%%k"=="yy"  if not "%%k"=="yyyy" if not "%%k"=="hh" if not "%%k"=="HH" if not "%%k"=="mm" if not "%%k"=="ss" if not "%%k"=="tt" set RET=1
if not "%%l"=="" if not "%%l"=="dd" if not "%%l"=="dddd" if not "%%l"=="MM" if not "%%l"=="MMM" if not "%%l"=="MMMM" if not "%%l"=="yy"  if not "%%l"=="yyyy" if not "%%l"=="hh" if not "%%l"=="HH" if not "%%l"=="mm" if not "%%l"=="ss" if not "%%l"=="tt" set RET=1
if not "%%m"=="" if not "%%m"=="dd" if not "%%m"=="dddd" if not "%%m"=="MM" if not "%%m"=="MMM" if not "%%m"=="MMMM" if not "%%m"=="yy"  if not "%%m"=="yyyy" if not "%%m"=="hh" if not "%%m"=="HH" if not "%%m"=="mm" if not "%%m"=="ss" if not "%%m"=="tt" set RET=1
if not "%%n"=="" if not "%%n"=="dd" if not "%%n"=="dddd" if not "%%n"=="MM" if not "%%n"=="MMM" if not "%%n"=="MMMM" if not "%%n"=="yy"  if not "%%n"=="yyyy" if not "%%n"=="hh" if not "%%n"=="HH" if not "%%n"=="mm" if not "%%n"=="ss" if not "%%n"=="tt" set RET=1
)
if "!RET!"=="1" (
	for /f "delims=" %%a in ("!FMT!") do endlocal & set "FMT=%%a"
	echo ERROR: Invalid format date [%FMT%] for the variable "%1" !!
	set RET=1
)
endlocal
exit /B %RET%
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
for %%i in (%TARGET%) do for /d %%j in (HOST AAG DB OPT BAK JOB MEM FILE LOG TEMP OBJ ERR WAIT PERF CPU USER LOCK BAK STAT SQL ALL) do if /I (%%i)==(%%j) (set FLG_%%i=1)
if (%FLG_HOST%)==(0) if (%FLG_AAG%)==(0) if (%FLG_DB%)==(0) if (%FLG_OPT%)==(0) if (%FLG_BAK%)==(0) if (%FLG_JOB%)==(0) if (%FLG_MEM%)==(0) if (%FLG_FILE%)==(0) if (%FLG_LOG%)==(0) if (%FLG_TEMP%)==(0) if (%FLG_OBJ%)==(0) if (%FLG_ERR%)==(0) if (%FLG_WAIT%)==(0) if (%FLG_CPU%)==(0) if (%FLG_USER%)==(0) if (%FLG_LOCK%)==(0) if (%FLG_STAT%)==(0) if (%FLG_PERF%)==(0) if (%FLG_SQL%)==(0) if (%FLG_ALL%)==(0) set RET=1
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
call :Display #  Makes a SQL Server audit for the Sage %type_prd% database [%DB_SRV%\%DB_SVC%].
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
echo        By default, all SQL Server elements are checked in the database specified in settings
echo        else individually with the following options:
echo            HOST = Audits host computer for the database
echo             AAG = Audits Always On Availability Group
echo              DB = Audits info about SQL Server instance and database
echo             OPT = Audits SQL Server configuration options and trace flags
echo             BAK = Audits backup report
echo             JOB = Audits job activity
echo             MEM = Audits the SQL Server memory usage and Buffer cache infos
echo            FILE = Audits DB files info & activity
echo             LOG = Audits LOG usage, growth & activity and Virtual Logs summary & detail
echo            TEMP = Audits usage for the TempDB database
echo             OBJ = Audits most large objects, fragmented & missing indexes, compression & partitioning infos
echo             ERR = Audits current SQL traces and last SQL Server Error & Agent logs
echo            WAIT = Audits wait events in the database
echo             CPU = Audits CPU pressure, latest TOP CPU and context switching
echo            USER = Audits SQL Server logins and Database users with associated sessions
echo            LOCK = Audits blocking processes
echo            STAT = Audits statistics computed for objects in the database
echo            PERF = Audits missing indexes, SQL perf counters and Automatic tuning & Query store
echo             SQL = Audits SQL Plan cache and various TOP SQL activity
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
