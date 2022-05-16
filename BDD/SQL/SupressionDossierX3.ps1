# **********************************************************************************
# *            			SCRIPT DE SUPRESSION DE DOSSIER SQL 	       		       *
# **********************************************************************************
# ----------------------------------------------------------------------------------
# Création par RCA 17/01/2020 		- Création du script
# ----------------------------------------------------------------------------------
# OBJECTIF - Supprime l'arborescence fichiers + tous les élements SQL lié au dossier X3

# PRE REQUIS - Supprimer le point d'accès dans Syracuse et supprimer le dossier dans les paramètres généraux X3 

# Variable Dossier : Dossier qu'on souhaite supprimer
# Variable ArboDossier : Chemin du répertoire Dossier X3
# Variable X3_PUB : Chemin du répertoire X3_PUB
# Variable instance : Nom de l'instance SQL
# Variable sqlinternalpwd : Mot de passe du compte sa SQL
# Variable sqlbase : Nom de la base de données SQL
# Variable REP : Chemin ou sera stocké les scripts et fichiers temporaires

$Dossier = "PGKARD1217"
$ArboDossier = "E:\Sage\X3U12TEST\dossiers\$Dossier"
$X3_PUB = "E:\Sage\X3U12TEST\dossiers\X3_PUB\$Dossier"
$instance  = "X3U12TEST"
$sqlinternallogin = "sa"
$sqlinternalpwd  = "Adm1n2019"
$sqlbase = "x112test"
$REP = "E:\Kardol_Scripts"

$servername = hostname


#drop X3 folders

Remove-Item $ArboDossier, $X3_PUB -Recurse -Force

#drop tables

bcp "Select 'Drop Table [' + TABLE_SCHEMA + '].[' + TABLE_NAME + '];' From   $sqlbase.INFORMATION_SCHEMA.TABLES Where  TABLE_TYPE = 'BASE TABLE' And TABLE_SCHEMA = '$Dossier'" queryout $REP\bcpTable.sql -c -U $sqlinternallogin -P $sqlinternalpwd -S $servername\$instance 

$valueBCPt ="USE [$sqlbase]
GO"

Set-Content -Path "$REP\bcpTable2.sql" -value $valueBCPt
Get-Content -Path "$REP\bcpTable.sql" | Add-content "$REP\bcpTable2.sql"

Invoke-Sqlcmd -ServerInstance $servername\$instance -Username $sqlinternallogin -Password $sqlinternalpwd -Database $sqlbase -InputFile "$REP\bcpTable2.sql" -Querytimeout 0 -Verbose


#drop views

bcp "select 'drop view ' + QUOTENAME(sc.name) + '.' + QUOTENAME(obj.name) + ';'
from $sqlbase.sys.objects obj
INNER JOIN $sqlbase.sys.schemas sc
ON sc.schema_id = obj.schema_id
where obj.type='V' and sc.name = '$Dossier';" queryout $REP\bcpViews.sql -c  -U $sqlinternallogin -P $sqlinternalpwd -S $servername\$instance 

$valueBCPv ="USE [$sqlbase]
GO"

Set-Content -Path "$REP\bcpViews2.sql" -value $valueBCPv
Get-Content -Path "$REP\bcpViews.sql" | Add-content "$REP\bcpViews2.sql"

Invoke-Sqlcmd -ServerInstance $servername\$instance -Username $sqlinternallogin -Password $sqlinternalpwd -Database $sqlbase -InputFile "$REP\bcpViews2.sql" -Querytimeout 0 -Verbose


#drop users

$Query = @"
USE [$sqlbase]
GO
DROP USER [$Dossier]
GO
USE [$sqlbase]
GO
DROP USER [$Dossier`_REPORT]
GO

USE [master]
GO
DROP LOGIN [$Dossier]
GO
USE [master]
GO
DROP LOGIN [$Dossier`_REPORT]
GO
"@

Invoke-Sqlcmd -ServerInstance $servername\$instance -Username $sqlinternallogin -Password $sqlinternalpwd -Database $sqlbase -Query $Query -Querytimeout 0 -Verbose


#drop roles

$Query2 = @"
USE [$sqlbase]
GO

DECLARE @RoleName sysname
set @RoleName = N'$Dossier`_ADX'

IF @RoleName <> N'public' and (select is_fixed_role from sys.database_principals where name = @RoleName) = 0
BEGIN
    DECLARE @RoleMemberName sysname
    DECLARE Member_Cursor CURSOR FOR
    select [name]
    from sys.database_principals 
    where principal_id in ( 
        select member_principal_id
        from sys.database_role_members
        where role_principal_id in (
            select principal_id
            FROM sys.database_principals where [name] = @RoleName AND type = 'R'))

    OPEN Member_Cursor;

    FETCH NEXT FROM Member_Cursor
    into @RoleMemberName
    
    DECLARE @SQL NVARCHAR(4000)

    WHILE @@FETCH_STATUS = 0
    BEGIN
        
        SET @SQL = 'ALTER ROLE '+ QUOTENAME(@RoleName,'[') +' DROP MEMBER '+ QUOTENAME(@RoleMemberName,'[')
        EXEC(@SQL)
        
        FETCH NEXT FROM Member_Cursor
        into @RoleMemberName
    END;

    CLOSE Member_Cursor;
    DEALLOCATE Member_Cursor;
END
/****** Object:  DatabaseRole [$Dossier`_ADX]    Script Date: 15/01/2020 16:54:31 ******/
DROP ROLE [$Dossier`_ADX]
GO
USE [$sqlbase]
GO

DECLARE @RoleName sysname
set @RoleName = N'$Dossier`_ADX_H'

IF @RoleName <> N'public' and (select is_fixed_role from sys.database_principals where name = @RoleName) = 0
BEGIN
    DECLARE @RoleMemberName sysname
    DECLARE Member_Cursor CURSOR FOR
    select [name]
    from sys.database_principals 
    where principal_id in ( 
        select member_principal_id
        from sys.database_role_members
        where role_principal_id in (
            select principal_id
            FROM sys.database_principals where [name] = @RoleName AND type = 'R'))

    OPEN Member_Cursor;

    FETCH NEXT FROM Member_Cursor
    into @RoleMemberName
    
    DECLARE @SQL NVARCHAR(4000)

    WHILE @@FETCH_STATUS = 0
    BEGIN
        
        SET @SQL = 'ALTER ROLE '+ QUOTENAME(@RoleName,'[') +' DROP MEMBER '+ QUOTENAME(@RoleMemberName,'[')
        EXEC(@SQL)
        
        FETCH NEXT FROM Member_Cursor
        into @RoleMemberName
    END;

    CLOSE Member_Cursor;
    DEALLOCATE Member_Cursor;
END
/****** Object:  DatabaseRole [$Dossier`_ADX_H]    Script Date: 15/01/2020 16:54:31 ******/
DROP ROLE [$Dossier`_ADX_H]
GO
USE [$sqlbase]
GO

DECLARE @RoleName sysname
set @RoleName = N'$Dossier`_ADX_R'

IF @RoleName <> N'public' and (select is_fixed_role from sys.database_principals where name = @RoleName) = 0
BEGIN
    DECLARE @RoleMemberName sysname
    DECLARE Member_Cursor CURSOR FOR
    select [name]
    from sys.database_principals 
    where principal_id in ( 
        select member_principal_id
        from sys.database_role_members
        where role_principal_id in (
            select principal_id
            FROM sys.database_principals where [name] = @RoleName AND type = 'R'))

    OPEN Member_Cursor;

    FETCH NEXT FROM Member_Cursor
    into @RoleMemberName
    
    DECLARE @SQL NVARCHAR(4000)

    WHILE @@FETCH_STATUS = 0
    BEGIN
        
        SET @SQL = 'ALTER ROLE '+ QUOTENAME(@RoleName,'[') +' DROP MEMBER '+ QUOTENAME(@RoleMemberName,'[')
        EXEC(@SQL)
        
        FETCH NEXT FROM Member_Cursor
        into @RoleMemberName
    END;

    CLOSE Member_Cursor;
    DEALLOCATE Member_Cursor;
END
/****** Object:  DatabaseRole [$Dossier`_ADX_R]    Script Date: 15/01/2020 16:54:31 ******/
DROP ROLE [$Dossier`_ADX_R]
GO
USE [$sqlbase]
GO

DECLARE @RoleName sysname
set @RoleName = N'$Dossier`_ADX_RH'

IF @RoleName <> N'public' and (select is_fixed_role from sys.database_principals where name = @RoleName) = 0
BEGIN
    DECLARE @RoleMemberName sysname
    DECLARE Member_Cursor CURSOR FOR
    select [name]
    from sys.database_principals 
    where principal_id in ( 
        select member_principal_id
        from sys.database_role_members
        where role_principal_id in (
            select principal_id
            FROM sys.database_principals where [name] = @RoleName AND type = 'R'))

    OPEN Member_Cursor;

    FETCH NEXT FROM Member_Cursor
    into @RoleMemberName
    
    DECLARE @SQL NVARCHAR(4000)

    WHILE @@FETCH_STATUS = 0
    BEGIN
        
        SET @SQL = 'ALTER ROLE '+ QUOTENAME(@RoleName,'[') +' DROP MEMBER '+ QUOTENAME(@RoleMemberName,'[')
        EXEC(@SQL)
        
        FETCH NEXT FROM Member_Cursor
        into @RoleMemberName
    END;

    CLOSE Member_Cursor;
    DEALLOCATE Member_Cursor;
END
/****** Object:  DatabaseRole [$Dossier`_ADX_RH]    Script Date: 15/01/2020 16:54:31 ******/
DROP ROLE [$Dossier`_ADX_RH]
GO
"@

Invoke-Sqlcmd -ServerInstance $servername\$instance -Username $sqlinternallogin -Password $sqlinternalpwd -Database $sqlbase -Query $Query2 -Querytimeout 0 -Verbose


#drop sequences


bcp "Select 'DROP SEQUENCE [' + s.SEQUENCE_SCHEMA + '].[' + s.SEQUENCE_NAME + '];' From   $sqlbase.INFORMATION_SCHEMA.SEQUENCES s Where  SEQUENCE_SCHEMA = '$Dossier'" queryout $REP\bcpSequences.sql -c  -U $sqlinternallogin -P $sqlinternalpwd -S $servername\$instance 

$valueBCPs ="USE [$sqlbase]
GO"

Set-Content -Path "$REP\bcpSequences2.sql" -value $valueBCPs
Get-Content -Path "$REP\bcpSequences.sql" | Add-content "$REP\bcpSequences2.sql"

Invoke-Sqlcmd -ServerInstance $servername\$instance -Username $sqlinternallogin -Password $sqlinternalpwd -Database $sqlbase -InputFile "$REP\bcpSequences2.sql" -Querytimeout 0 -Verbose


#drop schema

$Query4 = @"
USE [$sqlbase]
GO
DROP SCHEMA [$Dossier]
GO
"@

Invoke-Sqlcmd -ServerInstance $servername\$instance -Username $sqlinternallogin -Password $sqlinternalpwd -Database $sqlbase -Query $Query4 -Querytimeout 0 -Verbose

#drop group files

$Query5 = @"
USE [$sqlbase]
GO
ALTER DATABASE [$sqlbase]  REMOVE FILE [$Dossier`_DAT]
GO
ALTER DATABASE [$sqlbase] REMOVE FILEGROUP [$Dossier`_DAT]
GO
USE [$sqlbase]
GO
ALTER DATABASE [$sqlbase]  REMOVE FILE [$Dossier`_IDX]
GO
ALTER DATABASE [$sqlbase] REMOVE FILEGROUP [$Dossier`_IDX]
GO
"@

Invoke-Sqlcmd -ServerInstance $servername\$instance -Username $sqlinternallogin -Password $sqlinternalpwd -Database $sqlbase -Query $Query5 -Querytimeout 0 -Verbose

