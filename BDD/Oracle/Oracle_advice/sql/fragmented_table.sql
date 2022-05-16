spool .\log\fragmented_table.txt

rem ------------------------------------------------------------- 
rem Fragmentation Need 
rem ------------------------------------------------------------- 

set heading on 
set termout on 
set pagesize 66 
set line 132 

ttitle left " ***** Database: "db", DEFRAGMENTATION NEED *****" 

select substr(de.owner,1,8) "Owner", 
substr(de.segment_type,1,8) "Seg Type", 
substr(de.segment_name,1,35) "Table Name (Segment)", 
substr(de.tablespace_name,1,20) "Tablespace Name", 
count(*) "Frag NEED", 
substr(df.name,1,40) "DataFile Name" 
from sys.dba_extents de, v$datafile df 
where de.owner <> 'SYS' 
and de.file_id = df.file# 
and de.segment_type = 'TABLE' 
group by de.owner, de.segment_name, de.segment_type, de.tablespace_name, 
df.name 
having count(*) > 1 
order by count(*) desc; 

ttitle off 

spool off
quit