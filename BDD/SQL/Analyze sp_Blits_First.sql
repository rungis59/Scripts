SELECT *  FROM [DBAtools].[dbo].[BlitzFirst_FileStats] 
order by CheckDate desc;

SELECT *  FROM [DBAtools].[dbo].[BlitzFirst_FileStats_Deltas] 
where DatabaseName = 'tempdb' and SizeOnDiskMBgrowth > 0
order by CheckDate desc;

SELECT *  FROM [DBAtools].[dbo].[BlitzFirst] 
where CheckDate >= '2021-04-23 14:00:00.8979808 +02:00' and CheckDate <= '2021-04-23 14:30:00.1565784 +02:00'
order by Priority asc;

SELECT *  FROM [DBAtools].[dbo].[BlitzFirst_PerfmonStats_Actuals]
where CheckDate >= '2021-04-23 14:00:00.8979808 +02:00' and CheckDate <= '2021-04-23 14:30:00.1565784 +02:00'
order by CheckDate desc;

SELECT *  FROM [DBAtools].[dbo].[BlitzFirst_PerfmonStats_Deltas] 
where CheckDate >= '2021-04-23 14:00:00.8979808 +02:00' and CheckDate <= '2021-04-23 14:30:00.1565784 +02:00'
order by CheckDate desc;

SELECT *  FROM [DBAtools].[dbo].[BlitzCache] 
where CheckDate >= '2021-04-23 14:00:00.8979808 +02:00' and CheckDate <= '2021-04-23 14:30:00.1565784 +02:00'
order by TotalDuration desc;

SELECT *  FROM [DBAtools].[dbo].[BlitzWho_Results]
where CheckDate >= '2021-04-23 14:00:00.8979808 +02:00' and CheckDate <= '2021-04-23 14:30:00.1565784 +02:00'
order by CheckDate desc;

SELECT *  FROM [DBAtools].[dbo].[BlitzFirst_WaitStats]
where CheckDate >= '2021-04-23 14:00:00.8979808 +02:00' and CheckDate <= '2021-04-23 14:30:00.1565784 +02:00'
order by wait_time_ms desc;