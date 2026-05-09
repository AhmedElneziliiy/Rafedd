-- =============================================
-- Database Setup Script for RafeddDB_Dev
-- Run this script in SQL Server Management Studio
-- =============================================

-- Create the database if it doesn't exist
IF NOT EXISTS (SELECT * FROM sys.databases WHERE name = 'RafeddDB_Dev')
BEGIN
    CREATE DATABASE RafeddDB_Dev;
    PRINT 'Database "RafeddDB_Dev" created successfully.';
END
ELSE
BEGIN
    PRINT 'Database "RafeddDB_Dev" already exists.';
END
GO

-- Use the database
USE RafeddDB_Dev;
GO

-- Get current Windows user and grant permissions
DECLARE @currentUser NVARCHAR(128) = SYSTEM_USER;
DECLARE @sql NVARCHAR(MAX);

PRINT 'Current user: ' + @currentUser;

-- Create login if it doesn't exist (for Windows Authentication)
IF NOT EXISTS (SELECT * FROM sys.server_principals WHERE name = @currentUser)
BEGIN
    SET @sql = N'CREATE LOGIN [' + @currentUser + '] FROM WINDOWS;';
    EXEC sp_executesql @sql;
    PRINT 'Login created for: ' + @currentUser;
END
ELSE
BEGIN
    PRINT 'Login already exists for: ' + @currentUser;
END
GO

-- Grant database access
USE RafeddDB_Dev;
GO

DECLARE @currentUser NVARCHAR(128) = SYSTEM_USER;
DECLARE @sql NVARCHAR(MAX);

IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = @currentUser)
BEGIN
    SET @sql = N'CREATE USER [' + @currentUser + '] FOR LOGIN [' + @currentUser + '];';
    EXEC sp_executesql @sql;
    
    SET @sql = N'ALTER ROLE db_owner ADD MEMBER [' + @currentUser + '];';
    EXEC sp_executesql @sql;
    
    PRINT 'User created and granted db_owner role: ' + @currentUser;
END
ELSE
BEGIN
    PRINT 'User already exists: ' + @currentUser;
    
    -- Ensure user is in db_owner role
    SET @sql = N'ALTER ROLE db_owner ADD MEMBER [' + @currentUser + '];';
    BEGIN TRY
        EXEC sp_executesql @sql;
        PRINT 'User added to db_owner role (if not already member): ' + @currentUser;
    END TRY
    BEGIN CATCH
        PRINT 'User is already in db_owner role: ' + @currentUser;
    END CATCH
END
GO

PRINT 'Database setup completed successfully!';
PRINT 'Next steps:';
PRINT '1. Run migrations: cd DAL && dotnet ef database update --startup-project ../Rafedd';
PRINT '2. Start the application to verify connection.';
GO

