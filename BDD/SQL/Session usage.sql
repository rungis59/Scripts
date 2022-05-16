select left(d.name, 6)                                                             AS 'DB Name',
       s.session_id                                                                AS '   SID',
       left(s.host_process_id,6)                                                   AS 'PID',
       left(s.login_name, 33)                                                      AS 'Login Name',
       left(convert(varchar, s.login_time, 3)+' '+
             convert(varchar, s.login_time, 8),17)                                 AS 'Login Time',
       left(s.status, 10)                                                          AS 'Status',
       left(convert(varchar, s.last_request_end_time, 3)+' '+
             convert(varchar, s.last_request_end_time, 8),17)                      AS 'Last Exec',
       s.total_elapsed_time                                                        AS 'Elapsed Time (s)',
       s.cpu_time                                                                  AS '   CPU Time',
       s.memory_usage * 8                                                          AS 'Mem Used (KB)',
       right(replicate(' ',9-len(s.reads))+cast(s.reads as varchar),9)             AS 'Nbr Reads',
       right(replicate(' ',10-len(s.writes ))+cast(s.writes  as varchar),10)       AS 'Nbr Writes',
       right(replicate(' ',9-len(s.row_count))+cast(s.row_count as varchar),9)     AS 'Row Count',
       case when s.transaction_isolation_level = 1   then 'READ UNCOMMITTED'
            when s.transaction_isolation_level = 2
             and d.is_read_committed_snapshot_on = 1 then 'READ COMMITTED SNAPSHOT'
            when s.transaction_isolation_level = 2
             and d.is_read_committed_snapshot_on = 0 then 'READ COMMITTED'
            when s.transaction_isolation_level = 3   then 'REPEATABLE READ'
            when s.transaction_isolation_level = 4   then 'SERIALIZABLE'
            when s.transaction_isolation_level = 5   then 'SNAPSHOT' else null end AS 'Isolation Level',
       left(s.program_name, 60)                                                    AS 'Program Name'
from sys.dm_exec_sessions s   WITH (NOLOCK)
inner join sys.sysprocesses p WITH (NOLOCK) on p.spid = s.session_id
left outer join sys.dm_exec_connections c on (s.session_id = c.session_id)
inner join sys.databases d    WITH (NOLOCK) on (d.database_id = p.dbid)
where s.is_user_process= 1
and   s.session_id <> @@spid  -- Excludes owner  processes
and d.name = 'x112'
order by s.status, d.name, s.last_request_end_time desc, s.login_name;