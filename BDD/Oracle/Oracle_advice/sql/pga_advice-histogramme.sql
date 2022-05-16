spool .\log\PGA_target_advice_histogramme.txt
SET PAGESIZE 2000
SET LINESIZE 3000
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