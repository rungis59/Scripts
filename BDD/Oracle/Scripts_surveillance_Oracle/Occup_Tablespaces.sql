SET ECHO OFF
SET PAGESIZE 60 ARRAYSIZE 5
SET FEEDBACK OFF
SET LINESIZE 130
COLUMN Tablespace FORMAT           A15 HEADING 'Nom Tablespace'
COLUMN Total_Size FORMAT         999,999 HEADING 'Total(M)'
COLUMN Free_Space FORMAT         999,999 HEADING 'Libre(M)'
COLUMN Percentage FORMAT          90.0 HEADING '%|Util.'
COLUMN decode     FORMAT           A14 HEADING '(Utilisation)'
COLUMN fragdec    FORMAT           A14 HEADING '(Libre)'
COLUMN percfrag   FORMAT          90.0 HEADING '% Frag.'
COLUMN frags      FORMAT         99,999 HEADING 'Nbre|Frag.'
COLUMN bigchunk   FORMAT         99,999 HEADING '+Grand|Dispo.'
COLUMN gap                             HEADING ' '
COLUMN data_files FORMAT            99 HEADING 'Nbre|Fich.'
COLUMN occuped 	FORMAT         999,999 HEADING 'Occup.(M)'
TTITLE 'TABLESPACE - Espace libre et fragmentation'

set pagesize 0

-- spool E:\Kardol_Scripts\Scripts_surveillance_Oracle\logs\K_Occup_Tablespaces.log

set heading off
select 'Script exécuté le ' || to_char(SYSDATE,'dd/mm/yyyy') || ' à ' || to_char(SYSDATE,'hh24') ||
 ' heures ' || to_char(SYSDATE,'mi') || ' minutes sur le schéma ' || USER from DUAL;
set heading ON

select 'Analyse de la base de données '||upper(value)
  from v$parameter
 where name = 'db_name'
/

set pagesize 60 
select tot.tablespace_name Tablespace, data_files, tot.total Total_Size,
		 tot.total - NVL(free.free,0) occuped,
		100 - ((NVL(free.free,0) / tot.total) * 100) Percentage,
		decode ((ceil(10-(NVL(free.free,0) / tot.total) * 10)),
				0,'| .......... |',
				1,'| *......... |',
				2,'| **........ |',
				3,'| ***....... |',
				4,'| ****...... |',
				5,'| *****..... |',
				6,'| ******.... |',
				7,'| *******... |',
				8,'| ********.. |',
				9,'| *********. |',
				10,'| ********** |') decode,
		NVL(free.free,0) Free_Space, bigchunk, '|' gap, frags, percfrag,
		decode ((ceil(percfrag / 10)) ,
				0,'| .......... |',
				1,'| *......... |',
				2,'| **........ |',
				3,'| ***....... |',
				4,'| ****...... |',
				5,'| *****..... |',
				6,'| ******.... |',
				7,'| *******... |',
				8,'| ********.. |',
				9,'| *********. |',
				10,'| ********** |') fragdec
from (select tablespace_name, ceil(sum(bytes) / 1048576) TOTAL, count(*) data_files
	     from sys.dba_data_files
		 group by tablespace_name) tot, 
     (select tablespace_name, ceil(sum(bytes) / 1048576) free,
				 ceil(max(bytes) / 1048576) bigchunk, count(*) frags,
				 100 - (max(bytes) / sum(bytes)) * 100 percfrag
        from sys.dba_free_space 
       group by tablespace_name) free
where free.tablespace_name(+) = tot.tablespace_name
order by Tablespace
/* order by Percentage, percfrag */
/

CLEAR COLUMNS
TTITLE OFF
BTITLE OFF
SET FEEDBACK ON
SET PAGES 24
CLEAR BREAKS

-- spool off

EXIT
