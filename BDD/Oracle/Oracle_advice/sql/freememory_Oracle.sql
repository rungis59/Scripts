spool .\log\freememspaceOracle.txt
SET PAGESIZE 3000
SET LINESIZE 6000


PROMPT **********************************************************
PROMPT
PROMPT         =========================
PROMPT         FREE ORACLE RUNNING SPACE
PROMPT         =========================

SELECT BYTES FROM V$SGASTAT WHERE POOL = 'shared pool' AND NAME = 'free memory';

spool off 
quit