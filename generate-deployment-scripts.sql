-- Script to generate deployment SQL for SmarterASP.NET
-- Run this in SQL Server Management Studio (SSMS)

-- Step 1: Right-click on RafeddSystemDB database
-- Step 2: Tasks > Generate Scripts
-- Step 3: Choose "Select specific database objects" or "Script entire database"
-- Step 4: Click "Advanced" button
-- Step 5: Set these options:
--    - Script for Server Version: SQL Server 2019 (or 2017 for maximum compatibility)
--    - Types of data to script: Schema and data
--    - Script DROP and CREATE: Script CREATE only
-- Step 6: Save to file: RafeddSystemDB_Deployment.sql

-- OR use this command-line approach:
-- sqlcmd -S .\SQLEXPRESS -d RafeddSystemDB -E -o "RafeddSystemDB_Schema.sql" -Q "SELECT * FROM INFORMATION_SCHEMA.TABLES"

PRINT 'Use SQL Server Management Studio to generate deployment scripts'
PRINT 'Or use Entity Framework migrations as shown below'
