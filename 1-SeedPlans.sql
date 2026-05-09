-- ================================================================================
-- RAFEDD - SEED SUBSCRIPTION PLANS ONLY
-- ================================================================================
-- Run this script in SSMS on your hosted database
-- Database: db_ac210d_rafeddsystemdb
-- Server: SQL6033.site4now.net
-- ================================================================================

USE [db_ac210d_rafeddsystemdb];
GO

PRINT '========================================';
PRINT 'Seeding Subscription Plans...';
PRINT '========================================';
PRINT '';

-- Enable IDENTITY_INSERT to set explicit IDs
SET IDENTITY_INSERT [SubscriptionPlans] ON;

-- Seed Plan 1: المبتدأ (Starter)
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
    PRINT '✓ Plan 1 (المبتدأ) created - $50/month, 30 employees';
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
    PRINT '✓ Plan 1 (المبتدأ) updated - $50/month, 30 employees';
END

-- Seed Plan 2: المحترف (Professional)
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
    PRINT '✓ Plan 2 (المحترف) created - $100/month, 100 employees';
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
    PRINT '✓ Plan 2 (المحترف) updated - $100/month, 100 employees';
END

-- Seed Plan 3: المؤسسات (Enterprise)
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
    PRINT '✓ Plan 3 (المؤسسات) created - Custom pricing, 1000 employees';
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
    PRINT '✓ Plan 3 (المؤسسات) updated - Custom pricing, 1000 employees';
END

SET IDENTITY_INSERT [SubscriptionPlans] OFF;

PRINT '';
PRINT '========================================';
PRINT 'SUBSCRIPTION PLANS SEEDED SUCCESSFULLY!';
PRINT '========================================';
PRINT '';

-- Show what was created
SELECT
    Id,
    Name,
    PricePerMonth AS [Price/Month],
    MaxEmployees AS [Max Employees],
    IsActive AS [Active]
FROM [SubscriptionPlans]
ORDER BY Id;

PRINT '';
PRINT 'Next Step: Run the PowerShell script to create users:';
PRINT '  .\2-SeedUsers.ps1';
PRINT '';

GO
