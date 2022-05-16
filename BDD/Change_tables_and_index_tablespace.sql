set pagesize 0

select 'ALTER TABLE ' || user_tables.table_name || ' MOVE TABLESPACE ' || 'ARC ;' 
  from user_tables 
 where user_tables.temporary = 'N' 
 order by user_tables.table_name ;

set pagesize 0

select 'ALTER INDEX ' || user_indexes.index_name || ' REBUILD TABLESPACE ' || 'ARC ;'
from user_indexes
   , user_tables
where user_tables.table_name = user_indexes.table_name 
  and user_tables.temporary = 'N'
order by index_name ;
