SELECT to_number(decode(SID, 65535, NULL, SID)) sid,
       operation_type OPERATION,
	   trunc(EXPECTED_SIZE/1024) E_SIZE,
       trunc(ACTUAL_MEM_USED/1024) PGA_ACTUAL_MEM_USED, 
	   trunc(MAX_MEM_USED/1024) "MAX MEM",
       NUMBER_PASSES PASS, 
	   trunc(TEMPSEG_SIZE/1024) TSIZE
FROM V$SQL_WORKAREA_ACTIVE
ORDER BY 1,2;