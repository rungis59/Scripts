call "D:\Sage\FILLMEDU11P\runtime\bin\env.bat"
set ORACLE_SID=X111
impdp system/manager schemas=CLPROD directory=EXPORA dumpfile=CLPROD.dmp logfile=impdp_CLPROD.log EXCLUDE=GRANT TABLE_EXISTS_ACTION=TRUNCATE