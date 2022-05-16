spool .\log\db_cache_size.txt
SET PAGESIZE 2000
SET LINESIZE 3000


SELECT A.value + B.value  "logical_reads",
           C.value            "phys_reads",
           D.value            "phy_writes",
           ROUND(100 * ((A.value+B.value)-C.value) / (A.value+B.value))
             "BUFFER HIT RATIO"
    FROM V$SYSSTAT A, V$SYSSTAT B, V$SYSSTAT C, V$SYSSTAT D
    WHERE
       A.statistic# = 37
    AND
     B.statistic# = 38
  AND
     C.statistic# = 39
  AND
     D.statistic# = 40;



COLUMN size_for_estimate          FORMAT 999,999,999,999 heading 'Cache Size (MB)'
COLUMN buffers_for_estimate       FORMAT 999,999,999 heading 'Buffers'
COLUMN estd_physical_read_factor  FORMAT 999.90 heading 'Estd Phys|Read Factor'
COLUMN estd_physical_reads        FORMAT 99999,999,999 heading 'Estd Phys| Reads'

SELECT size_for_estimate, buffers_for_estimate, estd_physical_read_factor,
       estd_physical_reads
  FROM V$DB_CACHE_ADVICE
 WHERE name = 'DEFAULT'
   AND block_size = (SELECT value FROM V$PARAMETER WHERE name = 'db_block_size')
   AND advice_status = 'ON';

spool off
quit