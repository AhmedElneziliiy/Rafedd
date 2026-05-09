# Deployment Guide to SmarterASP.NET

## Problem
Your database backup is from SQL Server 2025, but SmarterASP.NET uses an older version, causing compatibility issues.

## Solution: Use Entity Framework Migrations (BEST METHOD)

Your application already uses Entity Framework with migrations. This is the **recommended** way to deploy databases to any hosting provider.

### Step 1: Update Connection String for Production

In your published `appsettings.json`, change the connection string to SmarterASP.NET's database:

```json
{
  "ConnectionStrings": {
    "DefaultConnection": "Server=YOUR_SMARTERASP_SERVER;Database=YOUR_DATABASE_NAME;User Id=YOUR_USERNAME;Password=YOUR_PASSWORD;TrustServerCertificate=True;MultipleActiveResultSets=true"
  }
}
```

Get these values from SmarterASP.NET control panel under **Database > MS SQL**.

### Step 2: Deploy Application to SmarterASP.NET

1. Publish your application:
   ```bash
   cd d:\Rafedd-master\Rafedd
   dotnet publish -c Release -o d:\Rafedd-master\publish
   ```

2. Upload the `publish` folder contents to SmarterASP.NET via FTP

### Step 3: Run Migrations on First Launch

Your application is configured to run migrations automatically on startup (if you have this in `Program.cs`).

**OR** run migrations manually after publishing:

```bash
cd d:\Rafedd-master\Rafedd
dotnet ef database update --connection "Server=YOUR_SERVER;Database=YOUR_DB;User Id=USER;Password=PASS;TrustServerCertificate=True"
```

### Step 4: Seed Initial Data (If Needed)

If you need to add initial data (admin user, subscription plans, etc.), create a seeding script:

```bash
cd d:\Rafedd-master
sqlcmd -S YOUR_SMARTERASP_SERVER -U YOUR_USERNAME -P YOUR_PASSWORD -d YOUR_DATABASE -i seed-data.sql
```

---

## Alternative: Export Data Only (if EF migrations don't work)

If you need to manually export data:

### Option A: Use SQL Server Management Studio (SSM)

1. Install SSMS if you don't have it: https://aka.ms/ssmsfullsetup
2. Connect to `.\SQLEXPRESS`
3. Right-click `RafeddSystemDB` > **Tasks** > **Generate Scripts**
4. Choose **"Script entire database and all database objects"**
5. Click **Next** > **Advanced** button
6. Set these options:
   - **Script for Server Version**: SQL Server 2019 (or 2017 for max compatibility)
   - **Types of data to script**: **Schema and data**
   - **Script USE DATABASE**: False
7. Click **OK** > **Next** > Save to file
8. Upload the generated SQL file to SmarterASP.NET and run it

### Option B: Export Data as INSERT Statements

For each table with data you need:

```sql
-- Run this in SSMS on your local database
-- Replace TableName with your actual table names

-- For AspNetUsers
SELECT 'INSERT INTO AspNetUsers (Id, Email, UserName, ...) VALUES (' +
  QUOTENAME(Id, '''') + ',' +
  QUOTENAME(Email, '''') + ',' +
  ...
  + ');'
FROM AspNetUsers;

-- Repeat for other tables:
-- Managers, Employees, Subscriptions, SubscriptionPlans, etc.
```

### Option C: Use BCP Utility (Bulk Copy)

Export data to CSV files:

```bash
# Export data from each table
bcp "SELECT * FROM RafeddSystemDB.dbo.AspNetUsers" queryout "AspNetUsers.csv" -c -S .\SQLEXPRESS -T
bcp "SELECT * FROM RafeddSystemDB.dbo.Managers" queryout "Managers.csv" -c -S .\SQLEXPRESS -T
# ... repeat for all tables
```

Then import on SmarterASP.NET (contact their support for bulk import options).

---

## Recommended Approach Summary

1. **BEST**: Use Entity Framework migrations (automatic database creation)
2. **GOOD**: Use SSMS to generate SQL Server 2019-compatible scripts
3. **LAST RESORT**: Export/import data manually table by table

## Important Notes

- Make sure to update `appsettings.json` with SmarterASP.NET database credentials
- Update `AppSettings:BaseUrl` to your actual domain
- Keep test/production MyFatoorah tokens separate
- Test on SmarterASP.NET staging environment first if available

## What's Already Configured

Your application is ready to deploy:
- ✅ Entity Framework migrations exist
- ✅ Connection string in appsettings.json
- ✅ Database models defined
- ✅ MyFatoorah integration working (test environment)
- ✅ Gemini AI integration working

Just update the connection string and publish!
