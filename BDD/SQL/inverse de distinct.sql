select  [ABRFIC_0], [CCE_0] from [x112test].[SEED].[CPTANALIN] 
group by [ABRFIC_0], [CCE_0]
having count(*) > 1