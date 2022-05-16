spool .\log\sharepool_advice.txt
SET PAGESIZE 2000
SET LINESIZE 3000
 SELECT * FROM v$sgastat WHERE name = 'free memory';
 
 
SELECT namespace, pins, pinhits, reloads, invalidations
  FROM V$LIBRARYCACHE
 ORDER BY namespace;


 SELECT *
  FROM V$SGASTAT
 WHERE name = 'free memory'
   AND pool = 'shared pool';
   
column parameter format a21
column pct_succ_gets format 999.9
column updates format 999,999,999

SELECT parameter,
       sum(gets),
       sum(getmisses),
       100*sum(gets - getmisses) / sum(gets) pct_succ_gets,
       sum(modifications) updates
  FROM V$ROWCACHE
 WHERE gets > 0
 GROUP BY parameter;
 
 SELECT (SUM(gets - getmisses - fixed)) / SUM(gets) "row cache"
  FROM V$ROWCACHE;
  
 
 
  
 
 SELECT SUM(value) || ' bytes' "total memory for all sessions"
  FROM V$SESSTAT, V$STATNAME
 WHERE name = 'session uga memory'
   AND V$SESSTAT.STATISTIC# = V$STATNAME.STATISTIC#;
   
   
SELECT SUM(value) || ' bytes' "total max mem for all sessions"
  FROM V$SESSTAT, V$STATNAME
 WHERE name = 'session uga memory max'
   AND V$SESSTAT.STATISTIC# = V$STATNAME.STATISTIC#;


spool off
quit