set Disk=D:
set REP=%disk%\Kardol_Scripts\BackupSQL
set REPLOG=%REP%\logs
if not exist %REPLOG% md %REPLOG%
if not exist %disk%\SQLBackups\BILicense md %disk%\SQLBackups\BILicense
if not exist %disk%\SQLBackups\SEI md %disk%\SQLBackups\SEI

set LOG=K_SqlExpress_backup.log

date /t > %LOG% > %REPLOG%\%LOG% 2>&1
time /t > %LOG% >> %REPLOG%\%LOG% 2>&1
echo "Rapport de sauvegarde SQLEXPRESS SEI" >> %REPLOG%\%LOG% 2>&1
echo . >> %REPLOG%\%LOG% 2>&1
echo "Sauvegarde instance SQLEXPRESS Base BILicense" >> %REPLOG%\%LOG% 2>&1
sqlcmd -S .\SQLEXPRESS -E -Q "BACKUP DATABASE [BILicense] TO  DISK = N'D:\Kardol_Scripts\BackupSQL\Backup-BILicense.bak' WITH NOFORMAT, NOINIT,  NAME = N'BILicense-Complète Base de données Sauvegarde', SKIP, NOREWIND, NOUNLOAD,  STATS = 10" >> %REPLOG%\%LOG% 2>&1
echo . >> %REPLOG%\%LOG% 2>&1
echo "Sauvegarde instance SQLEXPRESS Base SEI" >> %REPLOG%\%LOG% 2>&1
sqlcmd -S .\SQLEXPRESS -E -Q "BACKUP DATABASE [SEI] TO  DISK = N'D:\Kardol_Scripts\BackupSQL\Backup-SEI.bak' WITH NOFORMAT, NOINIT,  NAME = N'SEI-Complète Base de données Sauvegarde', SKIP, NOREWIND, NOUNLOAD,  STATS = 10" >> %REPLOG%\%LOG% 2>&1
echo . >> %REPLOG%\%LOG% 2>&1
echo . >> %REPLOG%\%LOG% 2>&1
echo "FIN de la sauvegarde de SQLEXPRESS SEI" >> %REPLOG%\%LOG% 2>&1
time /t > %LOG% >> %REPLOG%\%LOG% 2>&1


timeout 5