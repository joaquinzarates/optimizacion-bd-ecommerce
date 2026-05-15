USE master;
GO
 
IF EXISTS (SELECT name FROM sys.databases WHERE name = 'bd_ecommerce')
BEGIN
    ALTER DATABASE bd_ecommerce SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE bd_ecommerce;
END
GO
 

CREATE DATABASE bd_ecommerce
    COLLATE SQL_Latin1_General_CP1_CI_AS;
GO
 
USE bd_ecommerce;
GO