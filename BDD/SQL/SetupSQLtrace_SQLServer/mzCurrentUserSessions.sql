--##################################################################
--######             START OF SCRIPT                          ######
--##################################################################
--##   Filename:  mzCurrentUserSessions.sql
--##   Updated:   22 March 2022
--##   Author:    Mike Shaw (Sage UK, X3 Support)
--##   Purpose:   Show SQL session information for X3 users 
--##              Will only show X3 usernames for folder users 
--##                 i.e. after user has launched a classic function
--##              Should return one row per sadoss.exe process 
--##################################################################
--##   IMPORTANT
--##     Change [$(mzschema)] as appropriate for your folder name
--##################################################################
---
SELECT 
	S.session_id as "Session Id", 
	db.name as "DB Name", 
	S.program_name as "Program",
	S.login_name as "Login Name",
	alog.ADOUSR_0 as "EM User",
	alog.ADRCLI_0 as "Web Host",
	afunc.MODULE_0 as "Module",
	afunc.FCT_0 as "Function",
	FORMAT(S.login_time,'dd/MM/yyyy HH:mm:ss') as "Login", 
	S.status as "Status",
	S.host_process_id as "Process Id", 
	S.cpu_time/1000 as "CPU (secs)", 
	S.memory_usage*8192 as "Memory (Kb)", 
	S.total_scheduled_time/1000 as "Scheduled time (secs)", 
	S.total_elapsed_time/1000 as "Session elapsed time (secs)", 
	FORMAT(S.last_request_start_time,'dd/MM/yyyy HH:mm:ss') as "Last Request Start Time", 
	FORMAT(S.last_request_end_time,'dd/MM/yyyy HH:mm:ss') as "Last Request End Time",
	S.reads as "Session Reads", 
	S.writes as "Session Writes", 
	S.logical_reads as "Session Logical Reads",
	p.blocked as "Blocking Session Id",
	p.waittime as "Wait (ms)"
FROM sys.dm_exec_sessions AS S WITH (NOLOCK)
	INNER JOIN sys.sysprocesses AS p WITH (NOLOCK)
		ON S.session_id = p.spid
	LEFT OUTER JOIN [$(mzschema)].[ALOGIN] AS alog WITH (NOLOCK)
		ON S.session_id = alog.BDDID_0
		and FLG_0 = 2
	LEFT OUTER JOIN [X3].[AFCTCUR] as afunc WITH (NOLOCK)
		ON alog.ADOID_0 = afunc.UID_0
	INNER JOIN sys.databases AS db
		ON S.database_id = db.database_id
WHERE S.is_user_process = 1
	and db.name != 'master'
	and S.program_name in ('Adonix','sadoss.exe')
ORDER BY db.name, S.program_name, S.login_name;
---
--##################################################################
--######               END OF SCRIPT                          ######
--##################################################################