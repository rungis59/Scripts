### Logging sp_BlitzFirst to Tables

EXEC sp_BlitzFirst 
  @OutputDatabaseName = 'DBAtools', 
  @OutputSchemaName = 'dbo', 
  @OutputTableName = 'BlitzFirst',
  @OutputTableNameFileStats = 'BlitzFirst_FileStats',
  @OutputTableNamePerfmonStats = 'BlitzFirst_PerfmonStats',
  @OutputTableNameWaitStats = 'BlitzFirst_WaitStats',
  @OutputTableNameBlitzCache = 'BlitzCache',
  @OutputTableNameBlitzWho = 'BlitzWho',
  @OutputType = 'none'
 