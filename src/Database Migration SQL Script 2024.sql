/* 
 -- ================================================================================================================================================
 -- Script Name: Database Migration
 -- Description:	Create stored procedure that copies data from multiple databases into a destination database.
 -- ================================================================================================================================================
 -- ================================================================================================================================================
 -- Author: Kevin Agbulos
 -- Creation Date: 02/09/2024
 -- ================================================================================================================================================
 */
USE MASTER;

GO
	--Drop stored procedure in case of adjustments and you need to re-create the procedure.
	IF EXISTS (
		SELECT
			[name],
			[type_desc],
			create_date,
			modify_date
		FROM
			sys.objects
		WHERE
			TYPE = 'P'
			AND OBJECT_ID = OBJECT_ID('dbo.copy_data_to_new_database')
	) DROP PROCEDURE dbo.copy_data_to_new_database;

GO
	--Create stored procedure to loop through databases and insert tables into destination database.
	CREATE PROCEDURE dbo.copy_data_to_new_database @new_db VARCHAR(MAX),
	@dbs_list VARCHAR(MAX) AS BEGIN
SET
	NOCOUNT ON;

DECLARE @table_name VARCHAR(MAX);

DECLARE @sql_create_new_db VARCHAR(MAX);

DECLARE @sql_db_cursor VARCHAR(MAX);

DECLARE @sql_table_cursor VARCHAR(MAX);

DECLARE @sql_insert VARCHAR(MAX);

DECLARE @sql_create_schema VARCHAR(MAX);

DECLARE @list_of_dbs_strings VARCHAR(MAX);

DECLARE @database_name VARCHAR(MAX);

DECLARE @msg VARCHAR(MAX);

/*
 Breakdown of the below variable assignment:
 1. @list_of_dbs_strings is initially NULL.
 2. STRING_SPLIT will split the list of strings into a table of values.
 3. SELECT will loop through each value from STRING_SPLIT and COALESCE will return the first non-NULL value, which is an empty string.
 4. The first value from the list of dbs is concatenated with single quotes and appended to @list_of_dbs_strings.
 5. In the second iteration of the loop, the second value is not NULL so a comma will be concatenated followed by the 2nd value surrounded by single quotes.
 6. This keeps repating until we have a single string with all the database names surrounded by single quotes for use in the cursor.
 */
SELECT
	@list_of_dbs_strings = COALESCE(@list_of_dbs_strings + ',', '') + QUOTENAME(value, '''')
FROM
	STRING_SPLIT(@dbs_list, ',');

--Declare static cursor to loop through all databases. 
SET
	@sql_db_cursor = '
	DECLARE db_cursor CURSOR STATIC FOR
		SELECT 
			name
		FROM
			sys.databases
		WHERE
			name in (' + @list_of_dbs_strings + ');
	OPEN db_cursor;
	';

EXEC (@sql_db_cursor);

FETCH NEXT
FROM
	db_cursor INTO @database_name;

--Loop through each source database and copy data to target database.
WHILE @ @FETCH_STATUS = 0 BEGIN --Create a schema in the target database using the names of the source databases as the schema names.
SET
	@sql_create_schema = 'USE ' + QUOTENAME(@new_db) + '; IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = ' + QUOTENAME(@database_name, '''') + ')' + ' BEGIN EXEC(''CREATE SCHEMA ' + QUOTENAME(@database_name) + ';' + ''') END;';

EXEC (@sql_create_schema);

--Declare static cursor to loop through all tables in the current database.
SET
	@sql_table_cursor = 'USE ' + QUOTENAME(@database_name) + ' 
			DECLARE table_cursor CURSOR STATIC FOR
				SELECT
					name
				FROM
					sys.tables;
			OPEN table_cursor;
			';

EXEC (@sql_table_cursor);

FETCH NEXT
FROM
	table_cursor INTO @table_name;

--Nested cursor to loop through each table in each source database and insert data into target database.
WHILE @ @FETCH_STATUS = 0 BEGIN --Copy each table from the source database into the target database with the new schema.
SET
	@sql_insert = 'SELECT * INTO ' + QUOTENAME(@new_db) + '.' + QUOTENAME(@database_name) + '.' + QUOTENAME(@table_name) + ' FROM ' + QUOTENAME(@database_name) + '.dbo.' + QUOTENAME(@table_name);

EXEC (@sql_insert);

SET
	@msg = 'New table created in database: ' + QUOTENAME(@new_db) + ' Table Name: ' + QUOTENAME(@new_db) + '.' + QUOTENAME(@database_name) + '.' + QUOTENAME(@table_name);

RAISERROR(@msg, 0, 1) WITH NOWAIT;

FETCH NEXT
FROM
	table_cursor INTO @table_name;

END CLOSE table_cursor;

DEALLOCATE table_cursor;

FETCH NEXT
FROM
	db_cursor INTO @database_name;

END CLOSE db_cursor;

DEALLOCATE db_cursor;

RAISERROR('', 0, 1) WITH NOWAIT;

SET
	@msg = 'Stored procedure completed.';

RAISERROR(@msg, 0, 1) WITH NOWAIT;

END;

GO
	/*
	 Modify the below execution of the stored procedure as follows:
	 @new_db - The name of the new destination database you want to create.
	 @dbs_list - A list of database names separated by a comma. No spaces allowed and must be a string.
	 */
	EXEC dbo.copy_data_to_new_database @new_db = 'new_db',
	@dbs_list = 'db1,db2,db3';

GO