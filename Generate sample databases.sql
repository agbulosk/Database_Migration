/***Script to generate sample databases, tables, and data.***/

USE master;
GO

--Create new destination database.
CREATE DATABASE new_db;
GO

--Create sample source database1.
CREATE DATABASE db1;
GO

USE db1;
GO

CREATE TABLE dbo.Table1 (
    ID INT PRIMARY KEY,
    [Name] VARCHAR(50)
);


INSERT INTO dbo.Table1 (ID, Name) VALUES (1, 'John');
INSERT INTO dbo.Table1 (ID, Name) VALUES (2, 'Alice');

--Create sample source database2.
CREATE DATABASE db2;
GO

USE db2;
GO

CREATE TABLE dbo.Table2 (
    ID INT PRIMARY KEY,
    City NVARCHAR(50)
);

INSERT INTO dbo.Table2 (ID, City) VALUES (1, 'New York');
INSERT INTO dbo.Table2 (ID, City) VALUES (2, 'Los Angeles');

--Create sample source database3.
CREATE DATABASE db3;
GO

USE db3;
GO

CREATE TABLE dbo.Table3 (
    ID INT PRIMARY KEY,
    Age INT
);

INSERT INTO dbo.Table3 (ID, Age) VALUES (1, 30);
INSERT INTO dbo.Table3 (ID, Age) VALUES (2, 25);
