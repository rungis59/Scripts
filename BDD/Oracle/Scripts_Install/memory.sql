alter system set pga_aggregate_target=&1 scope=spfile;
alter system set db_cache_size=&2 scope=spfile;
alter system set sga_target=&3 scope=spfile; 
alter system set shared_pool_size=&4 scope=spfile; 
alter system set sga_max_size=&5 scope=spfile; 
ALTER SYSTEM SET FILESYSTEMIO_OPTIONS=SETALL SCOPE=SPFILE;
alter system set memory_target=0M scope=spfile; 
exit