set newpage 0
set space 0
set linesize 80
set pagesize 0
set echo off
set feedback off
set heading off
spool &1
select destination from v$archive_dest where dest_name='LOG_ARCHIVE_DEST_1';
spool off
exit