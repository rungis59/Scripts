USE [x112]
GO

SELECT
	Indx.name AS Index_Name,
	Indx.type_desc,
	Indx.is_disabled,
	Indx.allow_page_locks,
	Indx .allow_row_locks ,
    OBJECT_NAME(Indx.object_id) as Table_Name
FROM
    sys.indexes AS Indx  

WHERE
    Indx.is_hypothetical = 0 AND
    Indx.object_id = OBJECT_ID('CLC2S.GACCENTRYD'); 