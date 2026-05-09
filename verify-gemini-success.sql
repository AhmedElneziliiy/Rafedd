-- Verify Gemini AI Successfully Created Plans
USE RafeddSystemDB;
GO

-- Check Annual Target created
SELECT
    'Annual Target' AS Type,
    Id,
    Year,
    TargetDescription,
    CreatedAt
FROM AnnualTargets
WHERE Year = 2026
ORDER BY CreatedAt DESC;

-- Check Monthly Plans created by Gemini
SELECT
    'Monthly Plans' AS Type,
    Id,
    Month,
    Year,
    MonthlyGoal,
    AnnualTargetId
FROM MonthlyPlans
WHERE AnnualTargetId IN (SELECT Id FROM AnnualTargets WHERE Year = 2026)
ORDER BY Month;

-- Check Weekly Plans created by Gemini
SELECT
    'Weekly Plans' AS Type,
    COUNT(*) AS TotalWeeklyPlans,
    MIN(WeekNumber) AS FirstWeek,
    MAX(WeekNumber) AS LastWeek
FROM WeeklyPlans
WHERE MonthlyPlanId IN (
    SELECT Id FROM MonthlyPlans
    WHERE AnnualTargetId IN (SELECT Id FROM AnnualTargets WHERE Year = 2026)
);

-- Show sample weekly goals
SELECT TOP 10
    wp.WeekNumber,
    mp.Month,
    wp.WeeklyGoal,
    wp.WeekStartDate,
    wp.WeekEndDate
FROM WeeklyPlans wp
INNER JOIN MonthlyPlans mp ON wp.MonthlyPlanId = mp.Id
WHERE mp.AnnualTargetId IN (SELECT Id FROM AnnualTargets WHERE Year = 2026)
ORDER BY wp.WeekNumber;
