spool .\log\PGA_target_advice.txt
SET PAGESIZE 2000
SET LINESIZE 3000
SELECT * FROM V$PGASTAT;

-- ************************************************
-- Display pga target advice
-- ************************************************
 
column c1     heading 'Target(M)'
column c2     heading 'Estimated|Cache Hit %'
column c3     heading 'Estimated|Over-Alloc.'
 
SELECT
   ROUND(pga_target_for_estimate /(1024*1024)) c1,
   estd_pga_cache_hit_percentage         c2,
   estd_overalloc_count                  c3
FROM
   v$pga_target_advice;

 -- ************************************************
-- Display pga target advice histogram
-- ************************************************
 
 
SELECT
   low_optimal_size/1024 "Low(K)",
   (high_optimal_size+1)/1024 "High(K)",
   estd_optimal_executions "Optimal",
   estd_onepass_executions "One Pass",
   estd_multipasses_executions "Multi-Pass"
FROM
   v$pga_target_advice_histogram
WHERE
   pga_target_factor = 2
AND
   estd_total_executions != 0
ORDER BY
   1;

spool off
quit