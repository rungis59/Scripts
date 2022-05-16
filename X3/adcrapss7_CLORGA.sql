use master 
go         
create login CLORGA with password="285FBnzXa",DEFAULT_DATABASE = x112t , CHECK_POLICY = OFF 
go								
create login CLORGA_REPORT with password="285FBnzXa",DEFAULT_DATABASE = x112t , CHECK_POLICY = OFF 
go								
ALTER DATABASE x112t              
ADD FILEGROUP CLORGA_DAT         
go								
ALTER DATABASE x112t              
ADD FILE                                
 ( NAME = CLORGA_DAT,            
   FILENAME= 'd:\Sage\X3V12TEST\database\data\x112t_CLORGA_DAT.ndf', 
   SIZE= 1100MB,                 
   MAXSIZE=UNLIMITED,                   
   FILEGROWTH=10% )                    
TO FILEGROUP CLORGA_DAT          
go								
ALTER DATABASE x112t              
ADD FILEGROUP CLORGA_IDX         
go								
ALTER DATABASE x112t              
ADD FILE                                
 ( NAME = CLORGA_IDX,            
   FILENAME= 'd:\Sage\X3V12TEST\database\data\x112t_CLORGA_IDX.ndf', 
   SIZE = 500MB,               
   MAXSIZE=UNLIMITED,                   
   FILEGROWTH=10% )                    
TO FILEGROUP CLORGA_IDX          
go								
use x112t 						 
go								
IF NOT EXISTS (SELECT name FROM sysusers 					    
         WHERE name = 'X3_ADX_SYS' AND hasdbaccess=0 	
		 AND islogin=0 AND issqluser=0)							
BEGIN															
create role X3_ADX_SYS									
grant create table, create view, execute to X3_ADX_SYS 
exec sp_addrolemember  'db_ddladmin' , 'X3_ADX_SYS'  	
END															
GO																
create role CLORGA_ADX 										
GO 																
grant create table, create view, execute to CLORGA_ADX 		
GO 																
create role CLORGA_ADX_R 									
GO 																
grant create table, create view, execute to CLORGA_ADX_R 	
GO 																
create role CLORGA_ADX_H 									
GO 																
grant execute to CLORGA_ADX_H 								
GO 																
create role CLORGA_ADX_RH							 		
GO 																
grant execute to CLORGA_ADX_RH 								
GO 																
create schema CLORGA							 			
go																	
grant alter, control on schema::CLORGA to CLORGA_ADX 
go																	
grant select on schema::CLORGA to CLORGA_ADX_R 		
go																	
grant alter, control on schema::CLORGA to CLORGA_ADX_H	
go																		
grant select on schema::CLORGA to CLORGA_ADX_RH 			
go																		
create user CLORGA for login CLORGA with default_schema=CLORGA 
go								
create user CLORGA_REPORT for login CLORGA_REPORT with default_schema=CLORGA 
go								
exec sp_addrolemember 'X3_ADX_SYS', 'CLORGA'			
go																		
exec sp_addrolemember 'CLORGA_ADX', 'CLORGA'				
go																		
exec sp_addrolemember 'CLORGA_ADX_R', 'CLORGA_REPORT'	
go																		
use master									
go											
grant view server state to CLORGA 	
go											
