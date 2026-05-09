-- Check Manager's Subscription Status
USE RafeddSystemDB;
GO

-- 1. Check if manager exists and has a subscription
SELECT
    m.Id AS ManagerId,
    m.CompanyName,
    u.Email,
    s.Id AS SubscriptionId,
    s.IsActive AS SubscriptionActive,
    s.StartDate,
    s.EndDate,
    sp.Name AS PlanName,
    sp.PricePerMonth,
    sp.MaxEmployees
FROM Managers m
INNER JOIN AspNetUsers u ON m.UserId = u.Id
LEFT JOIN Subscriptions s ON m.Id = s.ManagerId
LEFT JOIN SubscriptionPlans sp ON s.SubscriptionPlanId = sp.Id
WHERE u.Email = 'manager@rafeed.com';

-- If subscription doesn't exist or is inactive, run this to fix it:
-- (Only run if the above query shows NULL subscription or IsActive = 0)

/*
-- Get Manager ID
DECLARE @ManagerId INT;
SELECT @ManagerId = m.Id
FROM Managers m
INNER JOIN AspNetUsers u ON m.UserId = u.Id
WHERE u.Email = 'manager@rafeed.com';

-- Check if subscription already exists
IF EXISTS (SELECT 1 FROM Subscriptions WHERE ManagerId = @ManagerId)
BEGIN
    -- Update existing subscription to make it active
    UPDATE Subscriptions
    SET IsActive = 1,
        StartDate = GETDATE(),
        EndDate = DATEADD(MONTH, 12, GETDATE()),
        AutoRenew = 1,
        SubscriptionPlanId = 1  -- Plan 1 ($50 / 30 employees)
    WHERE ManagerId = @ManagerId;

    PRINT 'Subscription updated for manager';
END
ELSE
BEGIN
    -- Create new subscription
    INSERT INTO Subscriptions (ManagerId, SubscriptionPlanId, StartDate, EndDate, IsActive, AutoRenew)
    VALUES (@ManagerId, 1, GETDATE(), DATEADD(MONTH, 12, GETDATE()), 1, 1);

    PRINT 'New subscription created for manager';
END

-- Update Manager's SubscriptionEndsAt
UPDATE Managers
SET SubscriptionEndsAt = DATEADD(MONTH, 12, GETDATE()),
    SubscriptionId = (SELECT Id FROM Subscriptions WHERE ManagerId = @ManagerId)
WHERE Id = @ManagerId;

-- Verify the fix
SELECT
    m.Id AS ManagerId,
    m.CompanyName,
    u.Email,
    s.Id AS SubscriptionId,
    s.IsActive AS SubscriptionActive,
    s.StartDate,
    s.EndDate,
    sp.Name AS PlanName,
    sp.PricePerMonth,
    sp.MaxEmployees
FROM Managers m
INNER JOIN AspNetUsers u ON m.UserId = u.Id
LEFT JOIN Subscriptions s ON m.Id = s.ManagerId
LEFT JOIN SubscriptionPlans sp ON s.SubscriptionPlanId = sp.Id
WHERE u.Email = 'manager@rafeed.com';
*/
