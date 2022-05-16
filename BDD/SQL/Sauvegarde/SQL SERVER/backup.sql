BACKUP DATABASE [rossel] FILEGROUP = N'PGKARD115_DAT',  FILEGROUP = N'PGKARD115_IDX' 
TO  DISK = N'F:\Program Files\Microsoft SQL Server\MSSQL12.SAGEX3\MSSQL\Backup\PGKARDOL.bck' WITH NOFORMAT, INIT,  
NAME = N'SAUVEGARDE DES GROUPES DE FICHIERS', SKIP, NOREWIND, NOUNLOAD,  STATS = 20
GO
declare @backupSetId as int
select @backupSetId = position from msdb..backupset where database_name=N'rossel' and backup_set_id=(select max(backup_set_id) from msdb..backupset where database_name=N'rossel' )
if @backupSetId is null begin raiserror(N'Échec de la vérification. Les informations de sauvegarde pour la base de données « rossel » sont introuvables.', 16, 1) end
RESTORE VERIFYONLY FROM  DISK = N'F:\Program Files\Microsoft SQL Server\MSSQL12.SAGEX3\MSSQL\Backup\PGKARDOL.bck' WITH  FILE = @backupSetId,  NOUNLOAD,  NOREWIND
GO


