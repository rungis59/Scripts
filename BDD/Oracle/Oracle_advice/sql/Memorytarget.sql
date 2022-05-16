spool .\log\memory_target.txt

Show SGA



column c1   heading 'Cache Size (m)'        format 999,999,999,999
column c2   heading 'Buffers'               format 999,999,999
column c3   heading 'Estd Phys|Read Factor' format 999.90
column c4   heading 'Estd Phys| Reads'      format 999,999,999
 
select size_for_estimate c1, buffers_for_estimate c2, estd_physical_read_factor c3, estd_physical_reads c4 from v$db_cache_advice where name = 'DEFAULT' and block_size=(SELECT value FROM V$PARAMETER WHERE name = 'db_block_size') and advice_status = 'ON';


SELECT SIZE_FOR_ESTIMATE, BUFFERS_FOR_ESTIMATE, ESTD_PHYSICAL_READ_FACTOR, ESTD_PHYSICAL_READS
  FROM V$DB_CACHE_ADVICE
    WHERE NAME          = 'KEEP'
     AND BLOCK_SIZE    = (SELECT VALUE FROM V$PARAMETER WHERE NAME = 'db_block_size')
     AND ADVICE_STATUS = 'ON';


select * from v$memory_target_advice;

select pga_target_for_estimate, pga_target_factor, estd_time from v$pga_target_advice;

SELECT * FROM V$SGASTAT 
 WHERE NAME = 'free memory'
   AND POOL = 'shared pool';

spool off
quit