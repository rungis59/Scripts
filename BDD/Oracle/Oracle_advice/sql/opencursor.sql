spool .\log\opencursor.txt

SET PAGESIZE 3000
SET LINESIZE 6000


COLUMN "max_open_cur" FORMAT A50
 
SELECT  max(a.value) as highest_open_cur, p.value as max_open_cur FROM v$sesstat a, v$statname b, v$parameter p WHERE  a.statistic# = b.statistic#  and b.name = 'opened cursors current' and p.name= 'open_cursors' group by p.value;
   
   
spool off 
quit