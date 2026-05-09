-- ================================================================================
-- RAFEDD SYSTEM - DATABASE SEED SCRIPT (CORRECTED VERSION)
-- ================================================================================
-- IMPORTANT: This script creates users with TEMPORARY passwords that you MUST
-- change through the ASP.NET Identity system for proper password hashing.
--
-- After running this script, you need to either:
-- 1. Use the API to set proper passwords via password reset, OR
-- 2. Login through the app (which will validate and rehash the password)
--
-- Database: db_ac210d_rafeddsystemdb
-- ================================================================================

USE [db_ac210d_rafeddsystemdb];
GO

-- ================================================================================
-- STEP 1: SEED SUBSCRIPTION PLANS
-- ================================================================================

PRINT '========================================';
PRINT 'STEP 1: Seeding Subscription Plans...';
PRINT '========================================';

SET IDENTITY_INSERT [SubscriptionPlans] ON;

MERGE INTO [SubscriptionPlans] AS Target
USING (VALUES
    (1, N'المبتدأ', 50.00, 30, N'مثالي للشركات الصغيرة - حتى 30 موظف - تقارير يومية غير محدودة - تخطيط أسبوعي - لوحة تحكم أساسية - دعم عبر البريد الإلكتروني - تخزين 5GB - تحليل أداء بالذكاء الاصطناعي', 1),
    (2, N'المحترف', 100.00, 100, N'للشركات المتوسطة - حتى 100 موظف - جميع مميزات المبتدأ - تقارير متقدمة ورسوم بيانية - تصدير PDF و Excel - دعم فني أولوية - تخزين 50GB - تخصيص التقارير - إشعارات فورية - تحليل شهري متقدم بالذكاء الاصطناعي', 1),
    (3, N'المؤسسات', 0.00, 1000, N'للشركات الكبيرة - موظفين غير محدود - جميع مميزات المحترف - API مخصص ودمج - مدير حساب مخصص - دعم فني 24/7 - تخزين غير محدود - تدريب مخصص للفريق - SSO وأمان متقدم - تقارير مخصصة حسب الطلب - السعر: حسب الطلب', 1)
) AS Source (Id, Name, PricePerMonth, MaxEmployees, Description, IsActive)
ON Target.Id = Source.Id
WHEN MATCHED THEN
    UPDATE SET
        Name = Source.Name,
        PricePerMonth = Source.PricePerMonth,
        MaxEmployees = Source.MaxEmployees,
        Description = Source.Description,
        IsActive = Source.IsActive,
        UpdatedAt = GETUTCDATE()
WHEN NOT MATCHED THEN
    INSERT (Id, Name, PricePerMonth, MaxEmployees, Description, IsActive, CreatedAt, UpdatedAt)
    VALUES (Source.Id, Source.Name, Source.PricePerMonth, Source.MaxEmployees, Source.Description, Source.IsActive, GETUTCDATE(), GETUTCDATE());

SET IDENTITY_INSERT [SubscriptionPlans] OFF;

PRINT '✓ 3 Subscription Plans seeded';
PRINT '';

-- ================================================================================
-- STEP 2: CREATE ROLES
-- ================================================================================

PRINT '========================================';
PRINT 'STEP 2: Creating Roles...';
PRINT '========================================';

DECLARE @AdminRoleId NVARCHAR(450) = NEWID();
DECLARE @ManagerRoleId NVARCHAR(450) = NEWID();
DECLARE @EmployeeRoleId NVARCHAR(450) = NEWID();

-- Admin Role
IF NOT EXISTS (SELECT 1 FROM [AspNetRoles] WHERE [Name] = 'Admin')
BEGIN
    INSERT INTO [AspNetRoles] (Id, Name, NormalizedName, ConcurrencyStamp)
    VALUES (@AdminRoleId, 'Admin', 'ADMIN', NEWID());
    PRINT '✓ Admin Role created';
END
ELSE
BEGIN
    SELECT @AdminRoleId = Id FROM [AspNetRoles] WHERE [Name] = 'Admin';
    PRINT '✓ Admin Role exists';
END

-- Manager Role
IF NOT EXISTS (SELECT 1 FROM [AspNetRoles] WHERE [Name] = 'Manager')
BEGIN
    INSERT INTO [AspNetRoles] (Id, Name, NormalizedName, ConcurrencyStamp)
    VALUES (@ManagerRoleId, 'Manager', 'MANAGER', NEWID());
    PRINT '✓ Manager Role created';
END
ELSE
BEGIN
    SELECT @ManagerRoleId = Id FROM [AspNetRoles] WHERE [Name] = 'Manager';
    PRINT '✓ Manager Role exists';
END

-- Employee Role
IF NOT EXISTS (SELECT 1 FROM [AspNetRoles] WHERE [Name] = 'Employee')
BEGIN
    INSERT INTO [AspNetRoles] (Id, Name, NormalizedName, ConcurrencyStamp)
    VALUES (@EmployeeRoleId, 'Employee', 'EMPLOYEE', NEWID());
    PRINT '✓ Employee Role created';
END
ELSE
BEGIN
    SELECT @EmployeeRoleId = Id FROM [AspNetRoles] WHERE [Name] = 'Employee';
    PRINT '✓ Employee Role exists';
END

PRINT '';

-- ================================================================================
-- NOTE ABOUT PASSWORDS
-- ================================================================================
-- ASP.NET Identity uses a specific password hashing algorithm (PBKDF2) that
-- cannot be easily replicated in SQL. The hash format is:
-- V3:<PRF>:<IterationCount>:<SaltSize>:<Salt>:<Subkey>
--
-- Instead of creating invalid hashes, we'll create users with a flag that
-- requires password reset on first login, OR you can use the API to create
-- these users properly.
-- ================================================================================

PRINT '========================================';
PRINT 'IMPORTANT: MANUAL STEPS REQUIRED';
PRINT '========================================';
PRINT '';
PRINT 'The subscription plans have been created successfully.';
PRINT 'However, users cannot be created directly via SQL with proper password hashing.';
PRINT '';
PRINT 'You have 2 options:';
PRINT '';
PRINT 'OPTION 1 (RECOMMENDED): Use the API seed endpoints';
PRINT '  1. Start your API: dotnet run';
PRINT '  2. Run PowerShell script: .\seed-data-via-api.ps1';
PRINT '';
PRINT 'OPTION 2: Create users manually through API';
PRINT '  1. POST /api/v1/auth/register-admin for admin';
PRINT '  2. POST /api/v1/auth/register (with Manager role) for manager';
PRINT '  3. POST /api/v1/auth/register (with Employee role) for employee';
PRINT '';
PRINT '========================================';
PRINT '';

GO

-- ================================================================================
-- VERIFICATION QUERIES
-- ================================================================================

PRINT '';
PRINT '========================================';
PRINT 'DATABASE STATUS';
PRINT '========================================';
PRINT '';

SELECT COUNT(*) AS [Subscription Plans] FROM [SubscriptionPlans];
SELECT COUNT(*) AS [Roles] FROM [AspNetRoles];
SELECT COUNT(*) AS [Users] FROM [AspNetUsers];
SELECT COUNT(*) AS [Admins] FROM [Admins];
SELECT COUNT(*) AS [Managers] FROM [Managers];
SELECT COUNT(*) AS [Employees] FROM [Employees];
SELECT COUNT(*) AS [Subscriptions] FROM [Subscriptions];

PRINT '';
PRINT '✓ Subscription Plans table populated';
PRINT '';

GO
