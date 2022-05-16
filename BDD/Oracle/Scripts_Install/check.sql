set lines 200
select component, current_size/(1024*1024) "Current Mb", min_size/(1024*1024) "Min Mb" from  v$memory_dynamic_components;
exit