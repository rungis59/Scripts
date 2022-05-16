spool .\log\maxprocess.txt

SET PAGESIZE 600
SET LINESIZE 3000
 
 
select * from v$resource_limit where resource_name='processes';
   
   
spool off 
quit