SET KARDOLSCRIPTS=E:\Kardol_Scripts\Scripts_Standby_Database
SET ORACLE_SID=X160
SET ORADATA=F:\Oradata\%ORACLE_SID%
SET ADXDIR=E:\SAGE\SAGEX3V6
SET ADXSOLUTION=X3PEV6
SET ADXDATABASE=%ADXDIR%\%ADXSOLUTION%\database

mkdir %KARDOLSCRIPTS%
mkdir %KARDOLSCRIPTS%\Log
mkdir %KARDOLSCRIPTS%\TMP

mkdir %ORADATA%\archivelogs\TMP
mkdir %ORADATA%\archivelogs\ZIP

REM ---------EN SUPPLEMENTUNIQUEMENT SUR LE SERVEUR DE STANDBY DATABASE------------
mkdir %ADXDATABASE%\data
mkdir %ADXDATABASE%\index
mkdir %ADXDATABASE%\log
rem mkdir %ADXDATABASE%\log1
rem mkdir %ORADATA%\log2
mkdir %ADXDATABASE%\scripts
mkdir %ADXDATABASE%\systeme
mkdir %ADXDATABASE%\tmp
mkdir %ADXDATABASE%\trace
mkdir %ADXDATABASE%\dump