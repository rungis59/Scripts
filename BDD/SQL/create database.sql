CREATE DATABASE [x112]  
ON
( NAME = [x112_data],
  FILENAME='F:\Sage\FORMTEST\database\data\x112_data.mdf',
  SIZE=2000MB,
  MAXSIZE=UNLIMITED,
  FILEGROWTH=10% )
LOG ON
( NAME = [x112_log],
  FILENAME='F:\Sage\FORMTEST\database\log\x112_log.ldf',
  SIZE=1000MB,
  MAXSIZE=UNLIMITED,
  FILEGROWTH=10% )

COLLATE Latin1_general_BIN2

GO

alter database [x112] set read_committed_snapshot on
