USE tempdb;  
GO 

SELECT (SUM(unallocated_extent_page_count)*1.0/128) AS TempDB_FreeSpaceAmount_InMB
FROM sys.dm_db_file_space_usage;
    
SELECT (SUM(internal_object_reserved_page_count)*1.0/128) AS TempDB_InternalObjSpaceAmount_InMB
FROM sys.dm_db_file_space_usage;
    
SELECT (SUM(user_object_reserved_page_count)*1.0/128) AS TempDB_UserObjSpaceAmount_InMB
FROM sys.dm_db_file_space_usage;

SELECT (SUM(version_store_reserved_page_count)*1.0/128) AS TempDB_VersionStoreSpaceAmount_InMB
FROM sys.dm_db_file_space_usage;

SELECT SpacePerTask.session_id, 
    SpacePerSession.internal_objects_alloc_page_count + SUM(SpacePerTask.internal_objects_alloc_page_count) AS NumOfPagesAllocatedInTempDBforInternalTask,
      SpacePerSession.internal_objects_dealloc_page_count + SUM(SpacePerTask.internal_objects_dealloc_page_count) AS NumOfPagesDellocatedInTempDBforInternalTask,
    SpacePerSession.user_objects_alloc_page_count + SUM(SpacePerTask.user_objects_alloc_page_count) AS NumOfPagesAllocatedInTempDBforUserTask,
      SpacePerSession.user_objects_dealloc_page_count + SUM(SpacePerTask.user_objects_dealloc_page_count) AS NumOfPagesDellocatedInTempDBforUserTask
FROM sys.dm_db_session_space_usage AS SpacePerSession
INNER JOIN sys.dm_db_task_space_usage AS SpacePerTask ON SpacePerSession.session_id = SpacePerTask.session_id
GROUP BY SpacePerTask.session_id, SpacePerSession.internal_objects_alloc_page_count,  SpacePerSession.internal_objects_dealloc_page_count, SpacePerSession.user_objects_alloc_page_count,SpacePerSession.user_objects_dealloc_page_count
ORDER BY NumOfPagesAllocatedInTempDBforInternalTask DESC, NumOfPagesAllocatedInTempDBforUserTask DESC

USE master;  
GO 

select  TOP 20
        coalesce(t1.session_id, t2.session_id)                                                                          AS 'SID',
        left(DB_NAME(coalesce(t1.database_id, t2.database_id)), 7)                                                      AS 'DB Name',
        left(coalesce(t1.tot_alloc_usr_obj_in_mb, 0)  + t2.tot_alloc_usr_obj_in_mb, 25)                                 AS 'Tot User Object (MB)',
        left(coalesce(t1.net_alloc_user_obj_in_mb, 0) + t2.net_alloc_user_obj_in_mb, 25)                                AS 'Net User Object (MB)',
        left(coalesce(t1.tot_alloc_int_obj_in_mb, 0)  + t2.tot_alloc_int_obj_in_mb, 25)                                 AS 'Tot Internal Object (MB)',
        left(coalesce(t1.net_alloc_int_obj_in_mb, 0)  + t2.net_alloc_int_obj_in_mb, 25)                                 AS 'Net Internal Object (MB)',
        left(coalesce(t1.tot_alloc_in_mb, 0) + t2.tot_alloc_in_mb, 25)                                                  AS 'Total Allocation (MB)',
        left(coalesce(t1.net_alloc_in_mb, 0) + t2.net_alloc_in_mb, 25)                                                  AS 'Net Allocation (MB)',
        char(13)+char(10)+char(13)+char(10)+coalesce(t1.query_text, t2.query_text)+char(13)+char(10)+replicate('-',2000) AS 'SQL Text'
from (select ts.session_id,
             ts.database_id,
             cast(ts.user_objects_alloc_page_count / 128.0 as dec(6,1)) tot_alloc_usr_obj_in_mb,
             cast((ts.user_objects_alloc_page_count - ts.user_objects_dealloc_page_count) / 128.0 as dec(6,1)) net_alloc_user_obj_in_mb,
             cast(ts.internal_objects_alloc_page_count / 128.0 as dec(6,1)) tot_alloc_int_obj_in_mb ,
             cast((ts.internal_objects_alloc_page_count - ts.internal_objects_dealloc_page_count) / 128.0 as dec(6,1)) net_alloc_int_obj_in_mb,
             cast(( ts.user_objects_alloc_page_count + internal_objects_alloc_page_count) / 128.0 as dec(6,1)) tot_alloc_in_mb,
             cast((ts.user_objects_alloc_page_count + ts.internal_objects_alloc_page_count -
                   ts.internal_objects_dealloc_page_count - ts.user_objects_dealloc_page_count) / 128.0 as dec(6,1)) net_alloc_in_mb,
             substring(t.text, (er.statement_start_offset/2)+1,
	                           ((case er.statement_end_offset
							     when -1 then datalength(t.text)
								 else er.statement_end_offset  end - er.statement_start_offset)/2)+1) query_text
      from sys.dm_db_task_space_usage ts
      join sys.dm_exec_requests er on er.request_id = ts.request_id and er.session_id = ts.session_id
      outer apply sys.dm_exec_sql_text(er.sql_handle) t
      where ts.session_id > 50
      and ts.session_id <> @@SPID
      and t.text not like '%sys.dm%') t1
right join (select ss.session_id,
                   ss.database_id ,
                   cast(ss.user_objects_alloc_page_count / 128.0 as dec(6,1)) tot_alloc_usr_obj_in_mb,
                   cast((ss.user_objects_alloc_page_count - ss.user_objects_dealloc_page_count) / 128.0 as dec(6,1)) net_alloc_user_obj_in_mb,
                   cast(ss.internal_objects_alloc_page_count / 128.0 as dec(6,1)) tot_alloc_int_obj_in_mb,
                   cast((ss.internal_objects_alloc_page_count - ss.internal_objects_dealloc_page_count) / 128.0 as dec(6,1)) net_alloc_int_obj_in_mb,
                   cast((ss.user_objects_alloc_page_count + internal_objects_alloc_page_count) / 128.0 as dec(6,1)) tot_alloc_in_mb,
                   cast((ss.user_objects_alloc_page_count + ss.internal_objects_alloc_page_count -
                         ss.internal_objects_dealloc_page_count - ss.user_objects_dealloc_page_count) / 128.0 as dec(6,1)) net_alloc_in_mb,
                   case when charindex(')S', t.text) >0 then substring(t.text, charindex(')S', t.text)+1, 3000) else t.text end query_text
            from sys.dm_db_session_space_usage ss
            left join sys.dm_exec_connections cn on cn.session_id = ss.session_id
            outer apply sys.dm_exec_sql_text(cn.most_recent_sql_handle) t
            where ss.session_id > 50
            and ss.session_id <> @@SPID
            and t.text not like '%sys.dm%') t2 on t1.session_id = t2.session_id
where coalesce(t1.net_alloc_in_mb, 0) + t2.net_alloc_in_mb > 0
order by 8 desc;