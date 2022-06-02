--##################################################################
--######             START OF SCRIPT                          ######
--##################################################################
--##   Filename:  mzExtendedEvent_X3_trace_user_session.sql
--##   Updated:   22 March 2022
--##   Author:    Mike Shaw (Sage UK, X3 Support)
--##   Purpose:   Script to create SQL trace using Extended Events
--##################################################################
---
DROP EVENT SESSION X3_trace_user_session ON SERVER;
DECLARE @mzTraceName as NVARCHAR(40) = 'X3_trace_user_session', @mzSessionID as INT = 63;
EXECUTE(N'CREATE EVENT SESSION ['+@mzTraceName+'] ON SERVER 
ADD EVENT sqlserver.error_reported(
    ACTION(package0.event_sequence,package0.last_error,sqlserver.client_hostname,sqlserver.database_name,sqlserver.session_id,sqlserver.sql_text)
    WHERE ((([package0].[greater_than_uint64]([sqlserver].[database_id],(4))) AND ([package0].[equal_boolean]([sqlserver].[is_system],(0)))) AND ([sqlserver].[session_id]=('+@mzSessionID+')))),
ADD EVENT sqlserver.module_end(SET collect_statement=(1)
    ACTION(package0.event_sequence,package0.last_error,sqlserver.client_hostname,sqlserver.database_name,sqlserver.session_id,sqlserver.sql_text)
    WHERE ((([package0].[greater_than_uint64]([sqlserver].[database_id],(4))) AND ([package0].[equal_boolean]([sqlserver].[is_system],(0)))) AND ([sqlserver].[session_id]=('+@mzSessionID+')))),
ADD EVENT sqlserver.query_post_execution_showplan(
    ACTION(package0.event_sequence,package0.last_error,sqlserver.client_hostname,sqlserver.database_name,sqlserver.sql_text)
    WHERE ([sqlserver].[session_id]=('+@mzSessionID+'))),
ADD EVENT sqlserver.rpc_completed(
    ACTION(package0.event_sequence,package0.last_error,sqlserver.client_hostname,sqlserver.database_name,sqlserver.session_id,sqlserver.sql_text)
    WHERE ((([package0].[greater_than_uint64]([sqlserver].[database_id],(4))) AND ([package0].[equal_boolean]([sqlserver].[is_system],(0)))) AND ([sqlserver].[session_id]=('+@mzSessionID+')))),
ADD EVENT sqlserver.sp_statement_completed(SET collect_object_name=(1)
    ACTION(package0.event_sequence,package0.last_error,sqlserver.client_hostname,sqlserver.database_name,sqlserver.session_id,sqlserver.sql_text)
    WHERE ((([package0].[greater_than_uint64]([sqlserver].[database_id],(4))) AND ([package0].[equal_boolean]([sqlserver].[is_system],(0)))) AND ([sqlserver].[session_id]=('+@mzSessionID+')))),
ADD EVENT sqlserver.sql_batch_completed(
    ACTION(package0.event_sequence,package0.last_error,sqlserver.client_hostname,sqlserver.database_name,sqlserver.session_id,sqlserver.sql_text)
    WHERE ((([package0].[greater_than_uint64]([sqlserver].[database_id],(4))) AND ([package0].[equal_boolean]([sqlserver].[is_system],(0)))) AND ([sqlserver].[session_id]=('+@mzSessionID+')))),
ADD EVENT sqlserver.sql_statement_completed(
    ACTION(package0.event_sequence,package0.last_error,sqlserver.client_hostname,sqlserver.database_name,sqlserver.session_id,sqlserver.sql_text)
    WHERE ((([package0].[greater_than_uint64]([sqlserver].[database_id],(4))) AND ([package0].[equal_boolean]([sqlserver].[is_system],(0)))) AND ([sqlserver].[session_id]=('+@mzSessionID+'))))
ADD TARGET package0.event_file(SET filename=N'''+@mzTraceName+''',max_file_size=(1024),max_rollover_files=(10))
WITH (MAX_MEMORY=4096 KB,EVENT_RETENTION_MODE=ALLOW_SINGLE_EVENT_LOSS,MAX_DISPATCH_LATENCY=30 SECONDS,MAX_EVENT_SIZE=0 KB,MEMORY_PARTITION_MODE=NONE,TRACK_CAUSALITY=ON,STARTUP_STATE=OFF)
');
---
--##################################################################
--######               END OF SCRIPT                          ######
--##################################################################