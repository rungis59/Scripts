set newpage 0
set space 0
set linesize 80
set pagesize 0
set echo off
set feedback off
set heading off
spool &1 ;
select value from v$parameter where lower(name) like '%spfile%';
spool off;
exit