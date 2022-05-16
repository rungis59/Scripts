spool .\log\oraclesession.txt

SET PAGESIZE 600
SET LINESIZE 3000
 

select a.value, s.username, s.sid, s.serial# from v$sesstat a, v$statname b, v$session s where a.statistic# = b.statistic#  and s.sid=a.sid and b.name = 'opened cursors current' and s.username is not null;

   
   
spool off 
quit