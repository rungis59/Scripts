select df.tablespace_name,
       df.mo_all,
       fs.mo_libre,
       df.mo_max ,
       df.mo_max -  df.mo_all + fs.mo_libre mo_max_libre,
       round( ( 1 - ( ( df.mo_max -  df.mo_all + fs.mo_libre) / df.mo_max ) ) * 100 )  pct
from 
    ( select fs.tablespace_name ,
        round(sum(fs.bytes)/1024/1024) MO_Libre
       from dba_free_space  fs
       group by fs.tablespace_name
    ) fs,
    ( select df.tablespace_name,
             round(sum(df.bytes)/1024/1024) MO_all,
             round(sum(decode( AUTOEXTENSIBLE,'YES',maxbytes, bytes))/1024/1024) MO_MAX     
        from dba_data_files df
        group by df.tablespace_name
    ) df
  where df.tablespace_name = fs.tablespace_name (+)
order by 2 desc;
