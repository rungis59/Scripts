select distinct table_name 
from all_tab_columns 
where owner='CLIKAR' and column_name like '%EXTWST%' 
order by table_name asc;