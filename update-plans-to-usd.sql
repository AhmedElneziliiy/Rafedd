-- Update Subscription Plans to USD Pricing and Employee Limits
-- Plan 1: 99 SAR / 30 employees -> $50 USD / 30 employees
-- Plan 2: 199 SAR / 50 employees -> $100 USD / 100 employees
-- Plan 3: Remains at 0 (custom pricing) / 1000 employees

USE RafeddSystemDB;
GO

-- Update Plan 1 (المبتدأ - Beginner)
UPDATE SubscriptionPlans
SET PricePerMonth = 50.00,
    MaxEmployees = 30,
    Description = N'مثالي للشركات الصغيرة - حتى 30 موظف - تقارير يومية غير محدودة - تخطيط أسبوعي - لوحة تحكم أساسية - دعم عبر البريد الإلكتروني - تخزين 5GB - تحليل أداء بالذكاء الاصطناعي'
WHERE Id = 1;

-- Update Plan 2 (المحترف - Professional) - INCREASED TO 100 EMPLOYEES
UPDATE SubscriptionPlans
SET PricePerMonth = 100.00,
    MaxEmployees = 100,
    Description = N'للشركات المتوسطة - حتى 100 موظف - جميع مميزات المبتدأ - تقارير متقدمة ورسوم بيانية - تصدير PDF و Excel - دعم فني أولوية - تخزين 50GB - تخصيص التقارير - إشعارات فورية - تحليل شهري متقدم بالذكاء الاصطناعي'
WHERE Id = 2;

-- Plan 3 already at 0.00 and 1000 employees, no update needed

-- Verify the updates
SELECT
    Id,
    Name,
    PricePerMonth,
    MaxEmployees,
    IsActive,
    Description
FROM SubscriptionPlans
ORDER BY Id;

GO
