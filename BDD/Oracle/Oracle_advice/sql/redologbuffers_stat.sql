spool .\log\redoLogBuffers_stat.txt
SET PAGESIZE 2000
SET LINESIZE 3000
SELECT NAME, VALUE
  FROM V$SYSSTAT
 WHERE NAME = 'redo buffer allocation retries';

Spool off
quit