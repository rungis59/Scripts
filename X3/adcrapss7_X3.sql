use master 
go         
create login X3 with password="285FBnzXa",DEFAULT_DATABASE = x112t , CHECK_POLICY = OFF 
go								
create login X3_REPORT with password="285FBnzXa",DEFAULT_DATABASE = x112t , CHECK_POLICY = OFF 
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
create role X3_ADX 										
GO 																
grant create table, create view, execute to X3_ADX 		
GO 																
create role X3_ADX_R 									
GO 																
grant create table, create view, execute to X3_ADX_R 	
GO 																
create role X3_ADX_H 									
GO 																
grant execute to X3_ADX_H 								
GO 																
create role X3_ADX_RH							 		
GO 																
grant execute to X3_ADX_RH 								
GO 																
create schema X3							 			
go																	
grant alter, control on schema::X3 to X3_ADX 
go																	
grant select on schema::X3 to X3_ADX_R 		
go																	
grant alter, control on schema::X3 to X3_ADX_H	
go																		
grant select on schema::X3 to X3_ADX_RH 			
go																		
create user X3 for login X3 with default_schema=X3 
go								
create user X3_REPORT for login X3_REPORT with default_schema=X3 
go								
exec sp_addrolemember 'X3_ADX_SYS', 'X3'			
go																		
exec sp_addrolemember 'X3_ADX', 'X3'				
go																		
exec sp_addrolemember 'X3_ADX_R', 'X3_REPORT'	
go																		
use master									
go											
grant view server state to X3 	
go											
