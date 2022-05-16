rem Le lancer manuellement

call "D:\Sage\FILLMEDU11P\runtime\bin\env.bat"
sqlplus /nolog
conn CLPROD/tiger
set pagesize 10000
spool D:\Kardol_Scripts\TEMP\drop.sql
select 'drop sequence ' || sequence_name || ';' from user_sequences order by 1;
spool off 
