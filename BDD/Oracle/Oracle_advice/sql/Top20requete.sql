Spool .\log\top20requete.txt
SET PAGESIZE 2000
SET LINESIZE 3000


PROMPT  TOP 20 REQUETES SQL DEPUIS LE DEMARRAGE DU SERVEUR ORACLE
PROMPT **********************************************************
PROMPT
PROMPT         =========================
PROMPT              ROWS_PROCESSED
PROMPT         =========================
PROMPT
PROMPT **********************************************************
PROMPT
 select * from (select CPU_TIME, EXECUTIONS, BUFFER_GETS, DISK_READS, FIRST_LOAD_TIME, PARSE_CALLS, ROWS_PROCESSED, SQL_TEXT from v$sqlarea order by ROWS_PROCESSED desc) where rownum <= 20;

PROMPT **********************************************************
PROMPT
PROMPT         =========================
PROMPT               BUFFER_GETS
PROMPT         =========================
PROMPT
PROMPT **********************************************************
PROMPT

 select * from (select CPU_TIME, EXECUTIONS, BUFFER_GETS, DISK_READS, FIRST_LOAD_TIME, PARSE_CALLS, ROWS_PROCESSED, SQL_TEXT from v$sqlarea order by BUFFER_GETS desc) where rownum <= 20;

PROMPT **********************************************************
PROMPT
PROMPT         =========================
PROMPT                DISK_READS
PROMPT         =========================
PROMPT
PROMPT **********************************************************
PROMPT
 select * from (select CPU_TIME, EXECUTIONS, BUFFER_GETS, DISK_READS, FIRST_LOAD_TIME, PARSE_CALLS, ROWS_PROCESSED, SQL_TEXT from v$sqlarea order by DISK_READS desc) where rownum <= 20;
 
 spool off 
 exit
 