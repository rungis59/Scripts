SELECT distinct year(CREDATTIM_0)
FROM [x112test].[SEED].[ATEXTE] 
where (CONVERT(datetime,CREDATTIM_0 , 103) >= '01/01/2021' and CONVERT(datetime,CREDATTIM_0 , 103) <= '31/12/2021')
