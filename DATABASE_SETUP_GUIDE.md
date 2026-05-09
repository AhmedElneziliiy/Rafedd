# Database Setup Guide

## Problem
The application cannot connect to the database `RafeddDB_Dev` with error:
```
Cannot open database "RafeddDB_Dev" requested by the login. The login failed.
Login failed for user 'DESKTOP-KOGV4EJ\Rashed'.
```

## Solution Options

### Option 1: Create the Database Manually (Recommended)

#### Step 1: Open SQL Server Management Studio (SSMS)
1. Open SQL Server Management Studio
2. Connect to your SQL Server instance (usually `localhost` or `.`)

#### Step 2: Create the Database
Run the following SQL script:

```sql
-- Create the database
IF NOT EXISTS (SELECT * FROM sys.databases WHERE name = 'RafeddDB_Dev')
BEGIN
    CREATE DATABASE RafeddDB_Dev;
END
GO

-- Grant permissions to your Windows user
USE RafeddDB_Dev;
GO

-- Create login if it doesn't exist (replace with your actual Windows user)
IF NOT EXISTS (SELECT * FROM sys.server_principals WHERE name = 'DESKTOP-KOGV4EJ\Rashed')
BEGIN
    CREATE LOGIN [DESKTOP-KOGV4EJ\Rashed] FROM WINDOWS;
END
GO

-- Grant database access
IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'DESKTOP-KOGV4EJ\Rashed')
BEGIN
    CREATE USER [DESKTOP-KOGV4EJ\Rashed] FOR LOGIN [DESKTOP-KOGV4EJ\Rashed];
    ALTER ROLE db_owner ADD MEMBER [DESKTOP-KOGV4EJ\Rashed];
END
GO
```

#### Step 3: Run Entity Framework Migrations
After creating the database, run the migrations to create all tables:

```powershell
# Navigate to the DAL project directory
cd DAL

# Add migration (if you haven't already)
dotnet ef migrations add MakePaidAtNullable --startup-project ../Rafedd

# Update the database
dotnet ef database update --startup-project ../Rafedd
```

### Option 2: Use SQL Server Authentication Instead

If Windows Authentication is not working, you can use SQL Server Authentication:

#### Step 1: Update Connection String in `appsettings.Development.json`

```json
{
  "ConnectionStrings": {
    "DefaultConnection": "Server=.;Database=RafeddDB_Dev;User Id=sa;Password=YourPassword;TrustServerCertificate=true"
  }
}
```

Replace `sa` and `YourPassword` with your SQL Server credentials.

#### Step 2: Ensure SQL Server Authentication is Enabled
1. Open SQL Server Management Studio
2. Right-click on your server instance → Properties
3. Go to Security → Enable "SQL Server and Windows Authentication mode"
4. Restart SQL Server service

### Option 3: Use Command Line (PowerShell)

Run this PowerShell script to create the database:

```powershell
# Replace with your SQL Server instance name (use "localhost" or "." for default instance)
$serverInstance = "."
$databaseName = "RafeddDB_Dev"
$windowsUser = "DESKTOP-KOGV4EJ\Rashed"

# SQL command to create database and grant permissions
$sqlCommand = @"
IF NOT EXISTS (SELECT * FROM sys.databases WHERE name = '$databaseName')
BEGIN
    CREATE DATABASE $databaseName;
END
GO

USE $databaseName;
GO

IF NOT EXISTS (SELECT * FROM sys.server_principals WHERE name = '$windowsUser')
BEGIN
    CREATE LOGIN [$windowsUser] FROM WINDOWS;
END
GO

IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = '$windowsUser')
BEGIN
    CREATE USER [$windowsUser] FOR LOGIN [$windowsUser];
    ALTER ROLE db_owner ADD MEMBER [$windowsUser];
END
GO
"@

# Execute using sqlcmd (if installed)
# sqlcmd -S $serverInstance -Q $sqlCommand

Write-Host "Database setup script generated. Run it in SSMS or sqlcmd."
Write-Host "SQL Command:"
Write-Host $sqlCommand
```

### Option 4: Change Database Name

If you want to use a different database name, update `appsettings.Development.json`:

```json
{
  "ConnectionStrings": {
    "DefaultConnection": "Server=.;Database=RafeddDB;Trusted_Connection=true;TrustServerCertificate=true"
  }
}
```

Then run migrations to create the database automatically.

## Verify Connection

After setting up the database, test the connection:

1. **Using SSMS**: Try connecting to `RafeddDB_Dev` with your Windows account
2. **Using the Application**: Run the application and check if it connects successfully
3. **Using dotnet ef**: Try running migrations to verify connection

## Common Issues

### Issue 1: "Login failed for user"
**Solution**: Ensure your Windows user has permission to access SQL Server. Run:
```sql
CREATE LOGIN [DESKTOP-KOGV4EJ\Rashed] FROM WINDOWS;
```

### Issue 2: "Cannot open database"
**Solution**: The database doesn't exist. Create it using one of the options above.

### Issue 3: "Database does not exist"
**Solution**: Check if the database name in the connection string matches the actual database name.

### Issue 4: SQL Server not running
**Solution**: 
1. Open Services (services.msc)
2. Find "SQL Server (MSSQLSERVER)" or your named instance
3. Ensure it's running and set to "Automatic" startup

## Quick Fix Script

For the fastest setup, run this in SSMS connected to your SQL Server:

```sql
-- Create database
IF NOT EXISTS (SELECT * FROM sys.databases WHERE name = 'RafeddDB_Dev')
    CREATE DATABASE RafeddDB_Dev;
GO

-- Grant full access to current Windows user
USE RafeddDB_Dev;
GO

DECLARE @currentUser NVARCHAR(128) = SYSTEM_USER;
DECLARE @sql NVARCHAR(MAX);

SET @sql = N'IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = ''' + @currentUser + ''')
BEGIN
    CREATE USER [' + @currentUser + '] FOR LOGIN [' + @currentUser + '];
    ALTER ROLE db_owner ADD MEMBER [' + @currentUser + '];
END';

EXEC sp_executesql @sql;
GO
```

This will automatically grant permissions to the current Windows user running SSMS.

