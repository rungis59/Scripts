SELECT SCHEMA_NAME(t.schema_id) as SchemaName, OBJECT_NAME(i.object_id) AS TableName, p.rows, i.type_desc

FROM sys.indexes i

INNER JOIN sys.partitions p ON p.object_id = i.object_id AND p.index_id = i.index_id

INNER JOIN sys.tables t ON t.object_id = i.object_id

WHERE i.index_id = 1    -- 0 pour heap tables 

ORDER BY p.rows DESC