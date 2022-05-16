ALTER DATABASE [rossel] SET SINGLE_USER WITH ROLLBACK IMMEDIATE
GO

BACKUP LOG [rossel] TO  DISK = N'F:\Program Files\Microsoft SQL Server\MSSQL12.SAGEX3\MSSQL\Backup\PGKARDOL_Log.bck' WITH NOFORMAT, NOINIT,  
NAME = N'SAUVEGARDE DES JOURNAUX DE TRANSACTIONS', SKIP, NOREWIND, NOUNLOAD,  STATS = 20, NORECOVERY
GO

declare @backupSetId as int
select @backupSetId = position from msdb..backupset where database_name=N'rossel' and backup_set_id=(select max(backup_set_id) from msdb..backupset where database_name=N'rossel' )
if @backupSetId is null begin raiserror(N'Échec de la vérification. Les informations de sauvegarde pour la base de données « rossel » sont introuvables.', 16, 1) end
RESTORE VERIFYONLY FROM  DISK = N'F:\Program Files\Microsoft SQL Server\MSSQL12.SAGEX3\MSSQL\Backup\PGKARDOL_Log.bck' WITH  FILE = @backupSetId,  NOUNLOAD,  NOREWIND
GO

RESTORE DATABASE [rossel] FILEGROUP = N'PGKARD115_DAT', FILEGROUP = N'PGKARD115_IDX' 
FROM  DISK = N'F:\Program Files\Microsoft SQL Server\MSSQL12.SAGEX3\MSSQL\Backup\PGKARDOL.bck' WITH NORECOVERY, NOUNLOAD, STATS = 20
GO
--  RESTORE HEADERONLY FROM DISK = N'F:\Program Files\Microsoft SQL Server\MSSQL12.SAGEX3\MSSQL\Backup\PGKARDOL_Log.bck'

RESTORE LOG [rossel] FROM DISK = N'F:\Program Files\Microsoft SQL Server\MSSQL12.SAGEX3\MSSQL\Backup\PGKARDOL_Log.bck' WITH FILE = 1, RECOVERY,  NOUNLOAD,  STATS = 20
GO
ALTER DATABASE [rossel] SET MULTI_USER 
GO