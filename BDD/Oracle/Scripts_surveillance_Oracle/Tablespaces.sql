set newpage 0
set space 0
set linesize 80
set pagesize 0
set echo off
set feedback off
set heading off
spool &1 ;
select distinct tablespace_name from all_indexes where owner = '&2';
spool off;
exit
