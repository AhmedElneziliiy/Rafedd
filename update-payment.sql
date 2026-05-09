-- Update payment status to Completed
UPDATE Payments
SET Status = 'Completed',
    PaidAt = '2025-12-04 23:05:37'
WHERE TransactionId = '6343262';

-- Check updated payment
SELECT * FROM Payments WHERE TransactionId = '6343262';

-- Get subscription details
SELECT s.*, sp.Name as PlanName, sp.PricePerMonth
FROM Subscriptions s
INNER JOIN SubscriptionPlans sp ON s.SubscriptionPlanId = sp.Id
WHERE s.Id = 1;

-- Activate the subscription
UPDATE Subscriptions
SET IsActive = 1,
    StartDate = GETDATE(),
    EndDate = DATEADD(MONTH, 1, GETDATE())
WHERE Id = 1;

-- Check updated subscription
SELECT s.*, sp.Name as PlanName, sp.PricePerMonth
FROM Subscriptions s
INNER JOIN SubscriptionPlans sp ON s.SubscriptionPlanId = sp.Id
WHERE s.Id = 1;
