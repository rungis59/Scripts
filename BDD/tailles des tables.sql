SELECT segment_name "Nom Table", BYTES / 1024 / 1024 "Taille en Mo" 
  FROM dba_segments
  where tablespace_name='PTD'