/****** Selectionne un abonnement actif qui tourne le samedi entre 02h et 04h du matin  ******/
SELECT * FROM [x112test].[X3].[ABATABT] where ENAFLG_0 ='2' and JOUR_5='2' and (HEURE_0 >= 0200 and HEURE_0 <= 0400)

SELECT * FROM [x112test].[X3].[ABATABT] where ENAFLG_0 ='2' and JOUR_5='2' and (HDEB_0 >= 0200 and HDEB_0 <= 0400)