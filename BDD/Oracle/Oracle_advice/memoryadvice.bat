
SET ORACLE_HOME=F:\Oracle\product\12.1.0\dbhome_1
SET ORACLE_SID=X111
SET USER=SYS
SET PWD=change_on_install
set REP=e:\Kardol_scripts\Oracle_advice
SET Alias=X111
rem Renomage fichier txt
if not exist %REP%\log md %REP%\log

cd /d %rep%\log


if exist memory_target.txt ren memory_target.txt %date:~6,4%%date:~3,2%%date:~0,2%-%time:~0,2%%time:~3,2%%time:~6,2%-memory_target.txt
if exist top20requete.txt ren top20requete.txt %date:~6,4%%date:~3,2%%date:~0,2%-%time:~0,2%%time:~3,2%%time:~6,2%-top20requete.txt
if exist PGA_target_advice.txt ren PGA_target_advice.txt %date:~6,4%%date:~3,2%%date:~0,2%-%time:~0,2%%time:~3,2%%time:~6,2%-PGA_target_advice.txt
if exist PGA_target_advice_histogramme.txt ren PGA_target_advice_histogramme.txt %date:~6,4%%date:~3,2%%date:~0,2%-%time:~0,2%%time:~3,2%%time:~6,2%-PGA_target_advice_histogramme.txt
if exist dictionary_cache.txt ren dictionary_cache.txt %date:~6,4%%date:~3,2%%date:~0,2%-%time:~0,2%%time:~3,2%%time:~6,2%-dictionary_cache.txt
if exist redoLogBuffers_stat.txt ren redoLogBuffers_stat.txt %date:~6,4%%date:~3,2%%date:~0,2%-%time:~0,2%%time:~3,2%%time:~6,2%-redoLogBuffers_stat.txt
if exist spaceondatafile.txt ren spaceondatafile.txt %date:~6,4%%date:~3,2%%date:~0,2%-%time:~0,2%%time:~3,2%%time:~6,2%-spaceondatafile.txt
if exist temporaryspaceusage.txt ren temporaryspaceusage.txt %date:~6,4%%date:~3,2%%date:~0,2%-%time:~0,2%%time:~3,2%%time:~6,2%-temporaryspaceusage.txt
if exist oraclesession.txt ren  oraclesession.txt %date:~6,4%%date:~3,2%%date:~0,2%-%time:~0,2%%time:~3,2%%time:~6,2%-oraclesession.txt
if exist sharepool_advice.txt ren sharepool_advice.txt %date:~6,4%%date:~3,2%%date:~0,2%-%time:~0,2%%time:~3,2%%time:~6,2%-sharepool_advice.txt
if exist db_cache_size.txt ren db_cache_size.txt %date:~6,4%%date:~3,2%%date:~0,2%-%time:~0,2%%time:~3,2%%time:~6,2%-db_cache_size.txt
if exist opencursor.txt ren opencursor.txt %date:~6,4%%date:~3,2%%date:~0,2%-%time:~0,2%%time:~3,2%%time:~6,2%-opencursor.txt
if exist maxprocess.txt ren maxprocess.txt %date:~6,4%%date:~3,2%%date:~0,2%-%time:~0,2%%time:~3,2%%time:~6,2%-maxprocess.txt 
if exist bufferhitcache.txt ren bufferhitcache.txt %date:~6,4%%date:~3,2%%date:~0,2%-%time:~0,2%%time:~3,2%%time:~6,2%-bufferhitcache.txt 
if exist freememspaceOracle.txt ren freememspaceOracle.txt %date:~6,4%%date:~3,2%%date:~0,2%-%time:~0,2%%time:~3,2%%time:~6,2%-freememspaceOracle.txt
if exist db_info.txt ren db_info.txt %date:~6,4%%date:~3,2%%date:~0,2%-%time:~0,2%%time:~3,2%%time:~6,2%-db_info.txt
if exist fragmented_table.txt ren fragmented_table.txt %date:~6,4%%date:~3,2%%date:~0,2%-%time:~0,2%%time:~3,2%%time:~6,2%-fragmented_table.txt
if exist lock.txt ren lock.txt %date:~6,4%%date:~3,2%%date:~0,2%-%time:~0,2%%time:~3,2%%time:~6,2%-lock.txt

cd /d %rep%

%ORACLE_HOME%\bin\sqlplus.exe %USER%/%PWD%@%Alias% as sysdba @ .\sql\Memorytarget.sql
%ORACLE_HOME%\bin\sqlplus.exe %USER%/%PWD%@%Alias% as sysdba @ .\sql\Top20requete.sql
%ORACLE_HOME%\bin\sqlplus.exe %USER%/%PWD%@%Alias% as sysdba @ .\sql\pga_advice.sql
%ORACLE_HOME%\bin\sqlplus.exe %USER%/%PWD%@%Alias% as sysdba @ .\sql\pga_advice-histogramme.sql
%ORACLE_HOME%\bin\sqlplus.exe %USER%/%PWD%@%Alias% as sysdba @ .\sql\dictionary_cache.sql
%ORACLE_HOME%\bin\sqlplus.exe %USER%/%PWD%@%Alias% as sysdba @ .\sql\redoLogBuffers_stat.sql
%ORACLE_HOME%\bin\sqlplus.exe %USER%/%PWD%@%Alias% as sysdba @ .\sql\spaceondatafile.sql
%ORACLE_HOME%\bin\sqlplus.exe %USER%/%PWD%@%Alias% as sysdba @ .\sql\temporaryspaceusage.sql
%ORACLE_HOME%\bin\sqlplus.exe %USER%/%PWD%@%Alias% as sysdba @ .\sql\oraclesession.sql
%ORACLE_HOME%\bin\sqlplus.exe %USER%/%PWD%@%Alias% as sysdba @ .\sql\sharepool.sql
%ORACLE_HOME%\bin\sqlplus.exe %USER%/%PWD%@%Alias% as sysdba @ .\sql\dbcachesize_advice.sql
%ORACLE_HOME%\bin\sqlplus.exe %USER%/%PWD%@%Alias% as sysdba @ .\sql\opencursor.sql
%ORACLE_HOME%\bin\sqlplus.exe %USER%/%PWD%@%Alias% as sysdba @ .\sql\maxprocess.sql
%ORACLE_HOME%\bin\sqlplus.exe %USER%/%PWD%@%Alias% as sysdba @ .\sql\bufferhitcache.sql
%ORACLE_HOME%\bin\sqlplus.exe %USER%/%PWD%@%Alias% as sysdba @ .\sql\freememory_Oracle.sql
%ORACLE_HOME%\bin\sqlplus.exe %USER%/%PWD%@%Alias% as sysdba @ .\sql\db_info.sql
%ORACLE_HOME%\bin\sqlplus.exe %USER%/%PWD%@%Alias% as sysdba @ .\sql\fragmented_table.sql
%ORACLE_HOME%\bin\sqlplus.exe %USER%/%PWD%@%Alias% as sysdba @ .\sql\lock.sql
timeout 3