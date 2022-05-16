-- Creates a partition function called myRangePF1 that will partition a table into 2 partitions  
CREATE PARTITION FUNCTION [myRangePF1](nvarchar(8)) AS RANGE RIGHT FOR VALUES (N'N')

-- Creates a partition scheme called myRangePS1 that applies myRangePF1 to the filegroups created   
CREATE PARTITION SCHEME [myRangePS1] AS PARTITION [myRangePF1] TO ([CPTANALIN1], [CPTANALIN2])


-- Check 

DECLARE @TABLE_NAME VARCHAR(30); 
DECLARE @SCHEMA VARCHAR(30);  
SET @TABLE_NAME = 'CPTANALIN';
SET @SCHEMA = 'SEED';

SELECT t.name AS TableName, i.name AS IndexName, p.partition_number, p.partition_id, i.data_space_id, f.function_id, f.type_desc, r.boundary_id, r.value AS BoundaryValue   
FROM sys.tables AS t  
JOIN sys.indexes AS i  
    ON t.object_id = i.object_id  
JOIN sys.partitions AS p  
    ON i.object_id = p.object_id AND i.index_id = p.index_id   
JOIN  sys.partition_schemes AS s   
    ON i.data_space_id = s.data_space_id  
JOIN sys.partition_functions AS f   
    ON s.function_id = f.function_id  
LEFT JOIN sys.partition_range_values AS r   
    ON f.function_id = r.function_id and r.boundary_id = p.partition_number  
WHERE t.name = @TABLE_NAME AND i.type <= 1  
ORDER BY p.partition_number;


SELECT   
    t.[object_id] AS ObjectID   
    , t.name AS TableName   
    , ic.column_id AS PartitioningColumnID   
    , c.name AS PartitioningColumnName   
FROM sys.tables AS t   
JOIN sys.indexes AS i   
    ON t.[object_id] = i.[object_id]   
    AND i.[type] <= 1 -- clustered index or a heap   
JOIN sys.partition_schemes AS ps   
    ON ps.data_space_id = i.data_space_id   
JOIN sys.index_columns AS ic   
    ON ic.[object_id] = i.[object_id]   
    AND ic.index_id = i.index_id   
    AND ic.partition_ordinal >= 1 -- because 0 = non-partitioning column   
JOIN sys.columns AS c   
    ON t.[object_id] = c.[object_id]   
    AND ic.column_id = c.column_id   
WHERE t.name = @TABLE_NAME ;   


SELECT t.name AS TableName, i.name AS IndexName , p.partition_number, f.name, f.type_desc, p.rows, rv.value, 
CASE WHEN ISNULL(rv.value, rv2.value) IS NULL THEN 'N/A' 
ELSE
    CASE WHEN boundary_value_on_right = 0 AND rv2.value IS NULL THEN '>=' 
        WHEN boundary_value_on_right = 0 THEN '>' 
        ELSE '>=' 
    END + ' ' + ISNULL(CONVERT(varchar(15), rv2.value), 'Min Value') + ' ' + 
        CASE boundary_value_on_right WHEN 1 THEN 'and <' 
                ELSE 'and <=' END 
        + ' ' + ISNULL(CONVERT(varchar(15), rv.value), 'Max Value') 
END AS TextComparison
FROM sys.tables AS t  
JOIN sys.indexes AS i  
    ON t.object_id = i.object_id  
JOIN sys.partitions AS p  
    ON i.object_id = p.object_id AND i.index_id = p.index_id   
JOIN  sys.partition_schemes AS s   
    ON i.data_space_id = s.data_space_id  
JOIN sys.partition_functions AS f   
    ON s.function_id = f.function_id  
LEFT JOIN sys.partition_range_values AS r   
    ON f.function_id = r.function_id and r.boundary_id = p.partition_number  
LEFT JOIN sys.partition_range_values AS rv
    ON f.function_id = rv.function_id
    AND p.partition_number = rv.boundary_id     
LEFT JOIN sys.partition_range_values AS rv2
    ON f.function_id = rv2.function_id
    AND p.partition_number - 1= rv2.boundary_id
WHERE i.type <= 1 AND t.name = @TABLE_NAME
ORDER BY t.name, p.partition_number;



SELECT
    sc.name + N'.' + so.name as [Schema.Table],
	si.index_id as [Index ID],
	si.type_desc as [Structure],
    si.name as [Index],
    stat.row_count AS [Rows],
    stat.in_row_reserved_page_count * 8./1024./1024. as [In-Row GB],
	stat.lob_reserved_page_count * 8./1024./1024. as [LOB GB],
    p.partition_number AS [Partition #],
    pf.name as [Partition Function],
    CASE pf.boundary_value_on_right
		WHEN 1 then 'Right / Lower'
		ELSE 'Left / Upper'
	END as [Boundary Type],
    prv.value as [Boundary Point],
	fg.name as [Filegroup]
FROM sys.partition_functions AS pf
JOIN sys.partition_schemes as ps on ps.function_id=pf.function_id
JOIN sys.indexes as si on si.data_space_id=ps.data_space_id
JOIN sys.objects as so on si.object_id = so.object_id
JOIN sys.schemas as sc on so.schema_id = sc.schema_id
JOIN sys.partitions as p on 
    si.object_id=p.object_id 
    and si.index_id=p.index_id
LEFT JOIN sys.partition_range_values as prv on prv.function_id=pf.function_id
    and p.partition_number= 
		CASE pf.boundary_value_on_right WHEN 1
			THEN prv.boundary_id + 1
		ELSE prv.boundary_id
		END
		/* For left-based functions, partition_number = boundary_id, 
		   for right-based functions we need to add 1 */
JOIN sys.dm_db_partition_stats as stat on stat.object_id=p.object_id
    and stat.index_id=p.index_id
    and stat.index_id=p.index_id and stat.partition_id=p.partition_id
    and stat.partition_number=p.partition_number
JOIN sys.allocation_units as au on au.container_id = p.hobt_id
	and au.type_desc ='IN_ROW_DATA' 
		/* Avoiding double rows for columnstore indexes. */
		/* We can pick up LOB page count from partition_stats */
JOIN sys.filegroups as fg on fg.data_space_id = au.data_space_id
WHERE so.object_id = OBJECT_ID(@SCHEMA+'.'+@TABLE_NAME)
ORDER BY [Schema.Table], [Index ID], [Partition Function], [Partition #];


SELECT DISTINCT o.name as table_name, rv.value as partition_range, fg.name as file_groupName, p.partition_number, p.rows as number_of_rows
FROM sys.partitions p
INNER JOIN sys.indexes i ON p.object_id = i.object_id AND p.index_id = i.index_id
INNER JOIN sys.objects o ON p.object_id = o.object_id
INNER JOIN sys.system_internals_allocation_units au ON p.partition_id = au.container_id
INNER JOIN sys.partition_schemes ps ON ps.data_space_id = i.data_space_id
INNER JOIN sys.partition_functions f ON f.function_id = ps.function_id
INNER JOIN sys.destination_data_spaces dds ON dds.partition_scheme_id = ps.data_space_id AND dds.destination_id = p.partition_number
INNER JOIN sys.filegroups fg ON dds.data_space_id = fg.data_space_id 
LEFT OUTER JOIN sys.partition_range_values rv ON f.function_id = rv.function_id AND p.partition_number = rv.boundary_id
WHERE o.object_id = OBJECT_ID(@SCHEMA+'.'+@TABLE_NAME);