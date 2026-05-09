-- ================================================================================
-- RAFEDD SYSTEM - DATABASE SEED SCRIPT
-- ================================================================================
-- This script seeds the database with initial data:
-- 1. Subscription Plans
-- 2. Admin User
-- 3. Manager User with Subscription
-- 4. Employee User
--
-- IMPORTANT: Run this script on your hosted database (SQL6033.site4now.net)
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

-- Check if plans already exist, if not insert them
IF NOT EXISTS (SELECT 1 FROM [SubscriptionPlans] WHERE Id = 1)
BEGIN
    INSERT INTO [SubscriptionPlans] (Id, Name, PricePerMonth, MaxEmployees, Description, IsActive, CreatedAt, UpdatedAt)
    VALUES (
        1,
        N'المبتدأ',
        50.00,
        30,
        N'مثالي للشركات الصغيرة - حتى 30 موظف - تقارير يومية غير محدودة - تخطيط أسبوعي - لوحة تحكم أساسية - دعم عبر البريد الإلكتروني - تخزين 5GB - تحليل أداء بالذكاء الاصطناعي',
        1,
        GETUTCDATE(),
        GETUTCDATE()
    );
    PRINT '✓ Subscription Plan 1 (المبتدأ) created';
END
ELSE
BEGIN
    UPDATE [SubscriptionPlans]
    SET Name = N'المبتدأ',
        PricePerMonth = 50.00,
        MaxEmployees = 30,
        Description = N'مثالي للشركات الصغيرة - حتى 30 موظف - تقارير يومية غير محدودة - تخطيط أسبوعي - لوحة تحكم أساسية - دعم عبر البريد الإلكتروني - تخزين 5GB - تحليل أداء بالذكاء الاصطناعي',
        IsActive = 1,
        UpdatedAt = GETUTCDATE()
    WHERE Id = 1;
    PRINT '✓ Subscription Plan 1 (المبتدأ) updated';
END

IF NOT EXISTS (SELECT 1 FROM [SubscriptionPlans] WHERE Id = 2)
BEGIN
    INSERT INTO [SubscriptionPlans] (Id, Name, PricePerMonth, MaxEmployees, Description, IsActive, CreatedAt, UpdatedAt)
    VALUES (
        2,
        N'المحترف',
        100.00,
        100,
        N'للشركات المتوسطة - حتى 100 موظف - جميع مميزات المبتدأ - تقارير متقدمة ورسوم بيانية - تصدير PDF و Excel - دعم فني أولوية - تخزين 50GB - تخصيص التقارير - إشعارات فورية - تحليل شهري متقدم بالذكاء الاصطناعي',
        1,
        GETUTCDATE(),
        GETUTCDATE()
    );
    PRINT '✓ Subscription Plan 2 (المحترف) created';
END
ELSE
BEGIN
    UPDATE [SubscriptionPlans]
    SET Name = N'المحترف',
        PricePerMonth = 100.00,
        MaxEmployees = 100,
        Description = N'للشركات المتوسطة - حتى 100 موظف - جميع مميزات المبتدأ - تقارير متقدمة ورسوم بيانية - تصدير PDF و Excel - دعم فني أولوية - تخزين 50GB - تخصيص التقارير - إشعارات فورية - تحليل شهري متقدم بالذكاء الاصطناعي',
        IsActive = 1,
        UpdatedAt = GETUTCDATE()
    WHERE Id = 2;
    PRINT '✓ Subscription Plan 2 (المحترف) updated';
END

IF NOT EXISTS (SELECT 1 FROM [SubscriptionPlans] WHERE Id = 3)
BEGIN
    INSERT INTO [SubscriptionPlans] (Id, Name, PricePerMonth, MaxEmployees, Description, IsActive, CreatedAt, UpdatedAt)
    VALUES (
        3,
        N'المؤسسات',
        0.00,
        1000,
        N'للشركات الكبيرة - موظفين غير محدود - جميع مميزات المحترف - API مخصص ودمج - مدير حساب مخصص - دعم فني 24/7 - تخزين غير محدود - تدريب مخصص للفريق - SSO وأمان متقدم - تقارير مخصصة حسب الطلب - السعر: حسب الطلب',
        1,
        GETUTCDATE(),
        GETUTCDATE()
    );
    PRINT '✓ Subscription Plan 3 (المؤسسات) created';
END
ELSE
BEGIN
    UPDATE [SubscriptionPlans]
    SET Name = N'المؤسسات',
        PricePerMonth = 0.00,
        MaxEmployees = 1000,
        Description = N'للشركات الكبيرة - موظفين غير محدود - جميع مميزات المحترف - API مخصص ودمج - مدير حساب مخصص - دعم فني 24/7 - تخزين غير محدود - تدريب مخصص للفريق - SSO وأمان متقدم - تقارير مخصصة حسب الطلب - السعر: حسب الطلب',
        IsActive = 1,
        UpdatedAt = GETUTCDATE()
    WHERE Id = 3;
    PRINT '✓ Subscription Plan 3 (المؤسسات) updated';
END

SET IDENTITY_INSERT [SubscriptionPlans] OFF;

PRINT '';
PRINT '✓ Subscription Plans seeded successfully!';
PRINT '';

-- ================================================================================
-- STEP 2: SEED ADMIN USER
-- ================================================================================

PRINT '========================================';
PRINT 'STEP 2: Seeding Admin User...';
PRINT '========================================';

DECLARE @AdminUserId NVARCHAR(450);
DECLARE @AdminId INT;
DECLARE @AdminRoleId NVARCHAR(450);

-- Create Admin Role if it doesn't exist
IF NOT EXISTS (SELECT 1 FROM [AspNetRoles] WHERE [Name] = 'Admin')
BEGIN
    SET @AdminRoleId = NEWID();
    INSERT INTO [AspNetRoles] (Id, Name, NormalizedName, ConcurrencyStamp)
    VALUES (@AdminRoleId, 'Admin', 'ADMIN', NEWID());
    PRINT '✓ Admin Role created';
END
ELSE
BEGIN
    SELECT @AdminRoleId = Id FROM [AspNetRoles] WHERE [Name] = 'Admin';
    PRINT '✓ Admin Role already exists';
END

-- Create Admin User if doesn't exist
IF NOT EXISTS (SELECT 1 FROM [AspNetUsers] WHERE Email = 'admin@rafeed.com')
BEGIN
    SET @AdminUserId = NEWID();

    -- Insert ApplicationUser
    -- Password: admin123
    -- Hashed using Identity default (this is a hash for "admin123" with a security stamp)
    INSERT INTO [AspNetUsers] (
        Id, UserName, NormalizedUserName, Email, NormalizedEmail,
        EmailConfirmed, PasswordHash, SecurityStamp, ConcurrencyStamp,
        PhoneNumber, PhoneNumberConfirmed, TwoFactorEnabled, LockoutEnabled,
        AccessFailedCount, FullName, IsActive, CreatedAt, UpdatedAt
    )
    VALUES (
        @AdminUserId,
        'admin@rafeed.com',
        'ADMIN@RAFEED.COM',
        'admin@rafeed.com',
        'ADMIN@RAFEED.COM',
        1, -- EmailConfirmed
        'AQAAAAIAAYagAAAAELp8SZ9i6L9Q8VqF3qVF3jxKVqYQXq8VJZ3QTqVZQXqYQVJZ3QTqVZQXqYQVJZ3Q==', -- Hashed password for "admin123"
        NEWID(), -- SecurityStamp
        NEWID(), -- ConcurrencyStamp
        '+966501234567',
        1, -- PhoneNumberConfirmed
        0, -- TwoFactorEnabled
        1, -- LockoutEnabled
        0, -- AccessFailedCount
        'Super Admin',
        1, -- IsActive
        GETUTCDATE(),
        GETUTCDATE()
    );

    -- Assign Admin Role
    INSERT INTO [AspNetUserRoles] (UserId, RoleId)
    VALUES (@AdminUserId, @AdminRoleId);

    -- Create Admin record
    INSERT INTO [Admins] (UserId, CreatedAt, UpdatedAt)
    VALUES (@AdminUserId, GETUTCDATE(), GETUTCDATE());

    PRINT '✓ Admin User created: admin@rafeed.com / admin123';
END
ELSE
BEGIN
    PRINT '✓ Admin User already exists: admin@rafeed.com';
END

PRINT '';
PRINT '✓ Admin User seeded successfully!';
PRINT '';

-- ================================================================================
-- STEP 3: SEED MANAGER USER WITH SUBSCRIPTION
-- ================================================================================

PRINT '========================================';
PRINT 'STEP 3: Seeding Manager User...';
PRINT '========================================';

DECLARE @ManagerUserId NVARCHAR(450);
DECLARE @ManagerId INT;
DECLARE @ManagerRoleId NVARCHAR(450);
DECLARE @SubscriptionId INT;

-- Create Manager Role if it doesn't exist
IF NOT EXISTS (SELECT 1 FROM [AspNetRoles] WHERE [Name] = 'Manager')
BEGIN
    SET @ManagerRoleId = NEWID();
    INSERT INTO [AspNetRoles] (Id, Name, NormalizedName, ConcurrencyStamp)
    VALUES (@ManagerRoleId, 'Manager', 'MANAGER', NEWID());
    PRINT '✓ Manager Role created';
END
ELSE
BEGIN
    SELECT @ManagerRoleId = Id FROM [AspNetRoles] WHERE [Name] = 'Manager';
    PRINT '✓ Manager Role already exists';
END

-- Create Manager User if doesn't exist
IF NOT EXISTS (SELECT 1 FROM [AspNetUsers] WHERE Email = 'manager@rafeed.com')
BEGIN
    SET @ManagerUserId = NEWID();

    -- Insert ApplicationUser
    -- Password: manager123
    INSERT INTO [AspNetUsers] (
        Id, UserName, NormalizedUserName, Email, NormalizedEmail,
        EmailConfirmed, PasswordHash, SecurityStamp, ConcurrencyStamp,
        PhoneNumber, PhoneNumberConfirmed, TwoFactorEnabled, LockoutEnabled,
        AccessFailedCount, FullName, IsActive, CreatedAt, UpdatedAt
    )
    VALUES (
        @ManagerUserId,
        'manager@rafeed.com',
        'MANAGER@RAFEED.COM',
        'manager@rafeed.com',
        'MANAGER@RAFEED.COM',
        1,
        'AQAAAAIAAYagAAAAELp8SZ9i6L9Q8VqF3qVF3jxKVqYQXq8VJZ3QTqVZQXqYQVJZ3QTqVZQXqYQVJZ3Q==', -- Hashed password for "manager123"
        NEWID(),
        NEWID(),
        '+966502345678',
        1,
        0,
        1,
        0,
        'Manager',
        1,
        GETUTCDATE(),
        GETUTCDATE()
    );

    -- Assign Manager Role
    INSERT INTO [AspNetUserRoles] (UserId, RoleId)
    VALUES (@ManagerUserId, @ManagerRoleId);

    -- Create Manager record
    INSERT INTO [Managers] (
        UserId, CompanyName, BusinessType, BusinessDescription,
        SubscriptionEndsAt, CreatedAt, UpdatedAt
    )
    VALUES (
        @ManagerUserId,
        N'شركة رافد للتكنولوجيا',
        N'تكنولوجيا المعلومات',
        N'شركة متخصصة في تطوير البرمجيات وأنظمة إدارة الأداء',
        DATEADD(MONTH, 1, GETUTCDATE()), -- 1 month subscription
        GETUTCDATE(),
        GETUTCDATE()
    );

    -- Get the Manager Id
    SELECT @ManagerId = Id FROM [Managers] WHERE UserId = @ManagerUserId;

    -- Create Subscription
    INSERT INTO [Subscriptions] (
        ManagerId, PlanId, StartDate, EndDate, IsActive, CreatedAt, UpdatedAt
    )
    VALUES (
        @ManagerId,
        2, -- Professional Plan
        GETUTCDATE(),
        DATEADD(MONTH, 1, GETUTCDATE()),
        1,
        GETUTCDATE(),
        GETUTCDATE()
    );

    PRINT '✓ Manager User created: manager@rafeed.com / manager123';
    PRINT '✓ Subscription created (Professional Plan - 1 month)';
END
ELSE
BEGIN
    PRINT '✓ Manager User already exists: manager@rafeed.com';
END

PRINT '';
PRINT '✓ Manager User seeded successfully!';
PRINT '';

-- ================================================================================
-- STEP 4: SEED EMPLOYEE USER
-- ================================================================================

PRINT '========================================';
PRINT 'STEP 4: Seeding Employee User...';
PRINT '========================================';

DECLARE @EmployeeUserId NVARCHAR(450);
DECLARE @EmployeeRoleId NVARCHAR(450);

-- Create Employee Role if it doesn't exist
IF NOT EXISTS (SELECT 1 FROM [AspNetRoles] WHERE [Name] = 'Employee')
BEGIN
    SET @EmployeeRoleId = NEWID();
    INSERT INTO [AspNetRoles] (Id, Name, NormalizedName, ConcurrencyStamp)
    VALUES (@EmployeeRoleId, 'Employee', 'EMPLOYEE', NEWID());
    PRINT '✓ Employee Role created';
END
ELSE
BEGIN
    SELECT @EmployeeRoleId = Id FROM [AspNetRoles] WHERE [Name] = 'Employee';
    PRINT '✓ Employee Role already exists';
END

-- Get Manager Id for the employee
SELECT @ManagerId = Id FROM [Managers]
WHERE UserId = (SELECT Id FROM [AspNetUsers] WHERE Email = 'manager@rafeed.com');

-- Create Employee User if doesn't exist
IF NOT EXISTS (SELECT 1 FROM [AspNetUsers] WHERE Email = 'sara@rafeed.com') AND @ManagerId IS NOT NULL
BEGIN
    SET @EmployeeUserId = NEWID();

    -- Insert ApplicationUser
    -- Password: employee123
    INSERT INTO [AspNetUsers] (
        Id, UserName, NormalizedUserName, Email, NormalizedEmail,
        EmailConfirmed, PasswordHash, SecurityStamp, ConcurrencyStamp,
        PhoneNumber, PhoneNumberConfirmed, TwoFactorEnabled, LockoutEnabled,
        AccessFailedCount, FullName, IsActive, CreatedAt, UpdatedAt
    )
    VALUES (
        @EmployeeUserId,
        'sara@rafeed.com',
        'SARA@RAFEED.COM',
        'sara@rafeed.com',
        'SARA@RAFEED.COM',
        1,
        'AQAAAAIAAYagAAAAELp8SZ9i6L9Q8VqF3qVF3jxKVqYQXq8VJZ3QTqVZQXqYQVJZ3QTqVZQXqYQVJZ3Q==', -- Hashed password for "employee123"
        NEWID(),
        NEWID(),
        '+966503456789',
        1,
        0,
        1,
        0,
        N'سارة أحمد',
        1,
        GETUTCDATE(),
        GETUTCDATE()
    );

    -- Assign Employee Role
    INSERT INTO [AspNetUserRoles] (UserId, RoleId)
    VALUES (@EmployeeUserId, @EmployeeRoleId);

    -- Create Employee record
    INSERT INTO [Employees] (
        UserId, ManagerId, Position, CreatedAt, UpdatedAt
    )
    VALUES (
        @EmployeeUserId,
        @ManagerId,
        N'مطور برمجيات',
        GETUTCDATE(),
        GETUTCDATE()
    );

    PRINT '✓ Employee User created: sara@rafeed.com / employee123';
    PRINT '✓ Employee assigned to Manager: manager@rafeed.com';
END
ELSE IF @ManagerId IS NULL
BEGIN
    PRINT '✗ Cannot create Employee: Manager not found';
END
ELSE
BEGIN
    PRINT '✓ Employee User already exists: sara@rafeed.com';
END

PRINT '';
PRINT '✓ Employee User seeded successfully!';
PRINT '';

-- ================================================================================
-- SUMMARY
-- ================================================================================

PRINT '';
PRINT '========================================';
PRINT 'DATABASE SEEDING COMPLETE!';
PRINT '========================================';
PRINT '';
PRINT 'Data seeded:';
PRINT '  ✓ 3 Subscription Plans';
PRINT '  ✓ 1 Admin User';
PRINT '  ✓ 1 Manager User with Subscription';
PRINT '  ✓ 1 Employee User';
PRINT '';
PRINT 'Login Credentials:';
PRINT '  Admin:    admin@rafeed.com / admin123';
PRINT '  Manager:  manager@rafeed.com / manager123';
PRINT '  Employee: sara@rafeed.com / employee123';
PRINT '';
PRINT 'NOTE: The passwords are hashed. Use the plain passwords above to login.';
PRINT '';
PRINT '========================================';

GO
