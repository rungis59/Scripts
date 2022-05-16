spool .\log\temporaryspaceusage.txt

SET PAGESIZE 2000
SET LINESIZE 3000
 
COL TABLESPACE_SIZE FOR 999,999,999,999
COL ALLOCATED_SPACE FOR 999,999,999,999
COL FREE_SPACE FOR 999,999,999,999
 
SELECT *
FROM   dba_temp_free_space;

SELECT 
   A.tablespace_name tablespace, 
   D.mb_total,
   SUM (A.used_blocks * D.block_size) / 1024 / 1024 mb_used,
   D.mb_total - SUM (A.used_blocks * D.block_size) / 1024 / 1024 mb_free
FROM 
   v$sort_segment A,
(
SELECT 
   B.name, 
   C.block_size, 
   SUM (C.bytes) / 1024 / 1024 mb_total
FROM 
   v$tablespace B, 
   v$tempfile C
WHERE 
   B.ts#= C.ts#
GROUP BY 
   B.name, 
   C.block_size
) D
WHERE 
   A.tablespace_name = D.name
GROUP by 
   A.tablespace_name, 
   D.mb_total;
   
   
spool off 
quit