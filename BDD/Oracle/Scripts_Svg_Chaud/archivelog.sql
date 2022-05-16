alter system set log_archive_format='&2' scope=spfile;
alter system set log_archive_dest='&1' scope=spfile;
alter system set archive_lag_target=600 scope=spfile;
exit