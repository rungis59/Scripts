--  Extended events

CREATE EVENT SESSION [LiveCapture] ON SERVER 
ADD EVENT sqlserver.query_post_execution_plan_profile(
    ACTION(sqlos.scheduler_id,sqlserver.database_id,sqlserver.is_system,sqlserver.plan_handle,sqlserver.query_hash_signed,sqlserver.query_plan_hash_signed,sqlserver.server_instance_name,sqlserver.session_id,sqlserver.session_nt_username,sqlserver.sql_text)
    WHERE ([sqlserver].[database_id]=(5)))
ADD TARGET package0.event_file(SET filename=N'LiveCapture',max_file_size=(50),max_rollover_files=(2))
WITH (MAX_MEMORY=4096 KB,EVENT_RETENTION_MODE=ALLOW_SINGLE_EVENT_LOSS,MAX_DISPATCH_LATENCY=30 SECONDS,MAX_EVENT_SIZE=0 KB,MEMORY_PARTITION_MODE=NONE,TRACK_CAUSALITY=OFF,STARTUP_STATE=OFF)
GO

-- SELECT DB_ID(N'x112test') AS [Database ID]; 


--Analyse with SQL Server Profiler

with source (textdata, reads, duration, RowCounts) as
(select		case charindex('SELECT', TextData)
		when 0 then replace(replace(replace(convert(varchar(2000), TextData),char(13),''),char(10),''),char(9),' ')  else 
		substring(convert(varchar(2000), TextData), charindex('SELECT', convert(varchar(2000), TextData)), 300 ) end TextData,
		Reads, Duration, RowCounts
--Table dbo.optim a modifier si necessaire
From dbo.optim with (nolock)
where TextData is not null
And TextData not like '%select substring(textdata,1,%' 
and TextData not like '%select%from%trace1%'
and TextData not like '%SELECT StatMan%'
and TextData not like 'FETCH%')
select textdata, somme, nb, cout_unit,maxireads, pct, duration, 
sum(duration) over (order by duration desc ) duration_cumul,
		pct_duration,
		sum(pct_duration) over (order by duration desc )pct_duration_cumul, 
		 bloc_par_lig, nblig 
from (
select  textdata , sum(reads) somme, count(*) nb,max(reads) maxireads,
	avg(reads) cout_unit ,sum(reads)*100.0 /(select sum(reads) 
					from  source  ) pct,	
					sum(duration) duration,
					sum(duration)*100.0/(select sum(duration) from source 
					) pct_duration,
				sum(RowCounts) nb_lig ,case sum(RowCounts) when 0 then 9999999 else sum(reads)/sum(RowCounts) end bloc_par_lig,sum(RowCounts) nblig
From source  
group by textdata
having sum(reads)>0
 ) as a
 order by 2  desc
