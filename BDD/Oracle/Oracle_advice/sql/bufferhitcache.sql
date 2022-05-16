spool .\log\bufferhitcache.txt
SET PAGESIZE 3000
SET LINESIZE 6000

PROMPT  HIT RATIO SECTION
PROMPT **********************************************************
PROMPT
PROMPT         =========================
PROMPT         BUFFER HIT RATIO
PROMPT         =========================
PROMPT (should be > 70, else increase db_block_buffers in init.ora) (should be > 70, else increase db_block_buffers in init.ora)

 SELECT TRUNC((1-(sum(decode(name,'physical reads',value,0))/
                 (sum(decode(name,'db block gets',value,0))+
                  (sum(decode(name,'consistent gets',value,0)))))
               )* 100) "Buffer Hit Ratio"
  FROM v$SYSSTAT;


PROMPT  ETAT DU BUFFER HIT RATIO
PROMPT **********************************************************
PROMPT
PROMPT         =========================
PROMPT         ETAT du BUFFER HIT RATIO
PROMPT         =========================

   
COLUMN "logical_reads" FORMAT 99,999,999,999
COLUMN "phys_reads"    FORMAT 999,999,999
COLUMN "phy_writes"    FORMAT 999,999,999
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


PROMPT **********************************************************
PROMPT          Busy Waits and CPU time
PROMPT         =========================
PROMPT        Relevant relationship between Busy Waits and CPU time for all user processes can be easily determined from V$SYS_TIME_MODEL
PROMPT         should be 40 60  if over the database need to be optimise
PROMPT         =========================

SELECT
      ROUND((STM1.VALUE - STM2.VALUE) / 1000000) "BUSY WAIT TIME (S)",
      ROUND(STM2.VALUE / 1000000) "CPU TIME (S)",
      ROUND((STM1.VALUE - STM2.VALUE) / STM1.VALUE * 100) || ' : ' ||
        ROUND(STM2.VALUE / STM1.VALUE * 100) RATIO
    FROM V$SYS_TIME_MODEL STM1, V$SYS_TIME_MODEL STM2
    WHERE STM1.STAT_NAME = 'DB time' AND STM2.STAT_NAME = 'DB CPU';


spool off 
quit
