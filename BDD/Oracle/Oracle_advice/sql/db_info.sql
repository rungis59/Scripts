spool .\log\db_info.txt

set linesize 300;
set pagesize 1000;
set wrap off;
set numwidth 20
set echo off;
break on today
break on report
column today noprint new_value xdate
select TRUNC(sysdate) today from dual;
column instance_name noprint new_value instancename
select instance_name from v$instance;
column startup_time heading 'Ran|Since'
column instance heading 'Instance|Name'
column host_name heading 'Host|Name'
column platform_name heading 'Platform'
column created heading 'Created|Since'
column log_mode heading 'Log|Mode'
column 'index partion' heading 'Index|Partion'
column 'table partition' heading 'Table|Partition'
column 'materialized view' heading 'Materialize|View'
column platform_name format a20
column version format a10
column username format a20
column object_type format a20
column num_of_objects format 999,999
column owner format a20
column host_name format a20
column tablespace_name format a30
column object_name format a30
column owner format a20
column '#line Procedure' heading '#Line|Procedure'
column '#line function' heading '#Line|Function'
column '#line trigger' heading '#Line|trigger'
column '#line package body' heading '#Line Package|Body'
column db_link format a20
column host format a30
column what format a30
column interval format a20
column segment_name format a30

break on owner

select instance_name instance,host_name,version,created, startup_time,log_mode from v$database,v$instance;


prompt "---Display Total Database Size in Megs.---"
select sum(bytes)/1024/1024 "DATABASE SIZE in M" from dba_data_files;

Prompt "---Database Link---"
select owner,db_link,username,host from all_db_links;

Prompt "---Job Information---"
select job,schema_user,broken,next_date,interval,what from dba_jobs;

prompt "--- Tablespace: Size Information  ---" skip 1
break on report
compute sum of "total MB" on report
col "total MB" format 999,999,999,999,990
compute sum of "Free MB" on report
col "Free MB" format 999,999,999,999,990
compute sum of "Used MB" on report
col "Used MB" format 999,999,999,999,990


select
d.tablespace_name, 
SUBSTR(d.file_name,1,50) "Datafile name",
ROUND(MAX(d.bytes)/1024/1024,2) as "total MB", 
DECODE(SUM(f.bytes), null, 0, ROUND(SUM(f.Bytes)/1024/1024,2)) as "Free MB" , 
DECODE( SUM(f.Bytes), null, ROUND(SUM(f.Bytes)/1024/1024,2) , ROUND((MAX(d.bytes)/1024/1024) - SUM(f.bytes)/1024/1024,2)) as "Used MB" 
from 
DBA_FREE_SPACE f , DBA_DATA_FILES d 
where f.tablespace_name (+) = d.tablespace_name 
and f.file_id (+)= d.file_id 
group by d.tablespace_name,d.file_name
order by 1;

set numwidth 7
prompt "---Display Object Type owned by Users---" skip 1
-- Detect # materialized view export will not export materialized views built from remote hosts
-- More preparation when perform import for materialized view used Rowid in old version
-- and Materialized view after import become tables
-- From here
break on report
compute sum of table on report;
compute sum of function on report;
compute sum of "package body" on report;
compute sum of trigger on report;
compute sum of index on report;

select owner,count(DECODE(OBJECT_TYPE,'TABLE',0)) AS "TABLE",
count(DECODE(OBJECT_TYPE,'TABLE PARTITION',0)) AS "TABLE PARTITION",
count(DECODE(OBJECT_TYPE,'PROCEDURE',0)) AS "PROCEDURE",
COUNT(DECODE(OBJECT_TYPE,'FUNCTION',0)) AS "FUNCTION",
COUNT (DECODE(OBJECT_TYPE,'PACKAGE BODY',0)) AS "PACKAGE BODY" ,
COUNT(DECODE(OBJECT_TYPE,'TRIGGER',0)) AS "TRIGGER",
COUNT(DECODE(OBJECT_TYPE,'LOB',0)) AS "LOB",
COUNT(DECODE(OBJECT_TYPE,'INDEX',0)) AS "INDEX" ,
COUNT(DECODE(OBJECT_TYPE,'INDEX PARTITION',0)) AS "INDEX PARTITION" ,
COUNT(DECODE(OBJECT_TYPE,'MATERIALIZED VIEW',0)) AS "MATERIALIZED VIEW" from all_objects
WHERE OWNER NOT IN ('SYS','SYSTEM')
group by owner;

set numwidth 20
Prompt '---Display total objects in the Database---'
select object_type,count(*) num_of_objects from dba_objects where owner not in ('SYS','SYSTEM') group by object_type;

Prompt '---Display the total lines of 20 largest Package body---'
select C.owner,object_name, "#LINE PACKAGE BODY" FROM
(SELECT A.OWNER, OBJECT_NAME,COUNT(DECODE(OBJECT_TYPE,'PACKAGE BODY',0)) AS "#LINE PACKAGE BODY" from all_objects A, all_source B
    where object_name=name
    and a.OWNER NOT IN ('SYS','SYSTEM')
    group by A.owner,OBJECT_NAME
    order by 3 desc) C
where rownum < 21;

--Prompt '---Display the total lines of 20 largest Procedure---'
--select C.owner,object_name, "#LINE PROCEDURE" FROM
--(SELECT A.OWNER, OBJECT_NAME,COUNT(DECODE(OBJECT_TYPE,'PROCEDURE',0)) AS "#LINE PROCEDURE" from --all_objects A, all_source B
--    where object_name=name
--    and a.OWNER NOT IN ('SYS','SYSTEM')
--    group by A.owner,OBJECT_NAME
--    order by 3 desc) C
--where rownum < 21;

Prompt '---Display the total lines of 20 largest TRIGGER---'
select C.owner,object_name, "#LINE TRIGGER" FROM
(SELECT A.OWNER, OBJECT_NAME,COUNT(DECODE(OBJECT_TYPE,'TRIGGER',0)) AS "#LINE TRIGGER" from all_objects A, all_source B
    where object_name=name
    and a.OWNER NOT IN ('SYS','SYSTEM')
    group by A.owner,OBJECT_NAME
    order by 3 desc) C
where rownum < 21;



col "MEGS" format 999,999,999,999,990.00
break on report
compute sum of MEGS on report;


Prompt '---Display Size of 20 Largest Tables---"
select OWNER,SEGMENT_NAME "TABLE", "MEGS"  from 
(select OWNER,SEGMENT_NAME,BYTES/1024/1024 AS "MEGS" from dba_segments where segment_type='TABLE' 
and owner not in ('SYS','SYSTEM') order by 3 desc) 
where rownum<21;

Prompt '---Display Size of 20 Largest Indexes---"
select OWNER,SEGMENT_NAME "INDEX", "MEGS"  from 
(select OWNER,SEGMENT_NAME,BYTES/1024/1024 AS "MEGS" from dba_segments where segment_type='INDEX' 
and owner not in ('SYS','SYSTEM') order by 3 desc) 
where rownum<21;

Prompt '---Display tablespaces that have equal or larger than 30 extents---'
SELECT   tablespace_name, segment_name, extents, max_extents, bytes,
         owner , segment_type
    FROM dba_segments
   WHERE extents >= 30 
ORDER BY tablespace_name, owner, segment_type, segment_name;

Prompt '---Display tables that have more than 200 chain rows---'
select owner,table_name,num_rows,chain_cnt, avg_row_len, row_movement
from dba_tables where chain_cnt > 200
and owner not in ('SYS','SYSTEM','OUTLN');

Prompt '---How many CPU, Default DOP, Default = parallel_thread_per_cpu * cpu_cnt---'
select substr(name,1,30) name, substr(value,1,5) from v$parameter
where name in  ('parallel_threads_per_cpu' , 'cpu_count' ); 
Prompt '---How many tables a user have with different DOP's---' 

select * from 
 ( select  substr(owner,1,15)  Owner  , ltrim(degree) Degree, ltrim(instances)  Instances, count(*)   "Num Tables"  , 'Parallel'  
 from all_tables 
 where ( trim(degree) != '1' and trim(degree) != '0' ) or         
( trim(instances) != '1' and trim(instances) != '0' ) 
 group by  owner, degree , instances 
union 
 select  substr(owner,1,15) owner  ,  '1' , '1' , count(*)  , 'Serial'  
 from all_tables where ( trim(degree) = '1' or trim(degree) != '0' ) 
  and  ( trim(instances) != '1' or trim(instances) != '0' ) 
 group by  owner ) 
order by owner; 

Prompt '--- How many indexes a user have with different DOP's ---'

select * from 
( select  substr(owner,1,15) Owner  , substr(trim(degree),1,7) Degree , substr(trim(instances),1,9) Instances ,count(*) "Num Indexes",         'Parallel'  
from all_indexes 
where ( trim(degree) != '1' and trim(degree) != '0' ) 
or         ( trim(instances) != '1' and trim(instances) != '0' ) 
group by  owner, degree , instances 
union 
 select  substr(owner,1,15) owner  ,  '1' , '1' ,count(*)  , 'Serial'  
 from all_indexes where ( trim(degree) = '1' or trim(degree) != '0' ) 
 and         ( trim(instances) != '1' or trim(instances) != '0' ) 
group by  owner ) order by owner; 

Prompt '---Detect obsolete parameters (Obsolete parameter might cause performance problems---'
select * from v$obsolete_parameter
where ISSPECIFIED != 'FALSE';

Prompt '---Display What options Current Database has---'
select substr(parameter,1,30) parameter, substr(value,1,30) value from v$option;

Prompt '---Display character Set---'
select substr(parameter,1,30) parameter, substr(value,1,30) value from v_$nls_parameters;

Prompt '---Display tables that has special data type which need more preparation during migration---'
select owner,table_name,data_type from all_tab_columns
where data_type in('BLOB','CLOB','CLOB','NCLOB','LONG','LONG RAW')
AND OWNER NOT IN('SYS','SYSTEM');

CLEAR COLUMNS
CLEAR BREAKS
SET TERMOUT ON FEEDBACK ON VERIFY ON 
UNDEF today
TTITLE OFF
UNDEF OUTPUT

spool off;
quit