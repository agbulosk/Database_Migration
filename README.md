# Database_Migration
SQL Server script that creates a stored procedure and uses cursors to copy data from multiple databases into a destination database in the same SQL Server instance.

## Getting Started
1. Download and execute the Generate sample databases.sql file in SSMS.
2. Download and execute the main SQL script file in the src folder.
3. Done! You should see all the tables from the 3 sample databases copied to the destination database.

## Limitations

The main SQL script does not copy any keys, constraints, etc. from the source databases into the destination database. This script soley demonstrates on how to copy data from multiple databases into a destination database. Also, this script only copies data within the same SQL Server instance and not across different SQL Server instances.