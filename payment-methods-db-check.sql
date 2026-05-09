-- Payment Methods Database Structure Check
-- This table stores CUSTOMER credit cards/payment methods, NOT MyFatoorah gateways

USE RafeddSystemDB;
GO

-- 1. Table Structure
PRINT '=== PaymentMethods Table Structure ==='
SELECT
    COLUMN_NAME AS 'Column',
    DATA_TYPE AS 'Type',
    CHARACTER_MAXIMUM_LENGTH AS 'Length',
    IS_NULLABLE AS 'Nullable',
    COLUMN_DEFAULT AS 'Default'
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'PaymentMethods'
ORDER BY ORDINAL_POSITION;

-- 2. Current Data
PRINT ''
PRINT '=== PaymentMethods Table Data ==='
SELECT COUNT(*) AS 'Total Records' FROM PaymentMethods;

SELECT TOP 10
    Id,
    UserId,
    Type,
    Brand,
    Last4,
    IsDefault,
    CreatedAt
FROM PaymentMethods
ORDER BY CreatedAt DESC;

-- 3. Payments Table with PaymentMethods
PRINT ''
PRINT '=== Payments Table Structure ==='
SELECT
    COLUMN_NAME AS 'Column',
    DATA_TYPE AS 'Type',
    IS_NULLABLE AS 'Nullable'
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'Payments'
ORDER BY ORDINAL_POSITION;

-- 4. Recent Payments
PRINT ''
PRINT '=== Recent Payments ==='
SELECT COUNT(*) AS 'Total Payments' FROM Payments;

SELECT TOP 10
    Id,
    Amount,
    Currency,
    Status,
    PaymentMethodName,
    TransactionId,
    PaidAt,
    CreatedAt
FROM Payments
ORDER BY CreatedAt DESC;

-- 5. Foreign Key Relationships
PRINT ''
PRINT '=== PaymentMethods Foreign Keys ==='
SELECT
    fk.name AS 'FK Name',
    OBJECT_NAME(fk.parent_object_id) AS 'From Table',
    COL_NAME(fc.parent_object_id, fc.parent_column_id) AS 'From Column',
    OBJECT_NAME(fk.referenced_object_id) AS 'To Table',
    COL_NAME(fc.referenced_object_id, fc.referenced_column_id) AS 'To Column'
FROM sys.foreign_keys AS fk
INNER JOIN sys.foreign_key_columns AS fc
    ON fk.object_id = fc.constraint_object_id
WHERE OBJECT_NAME(fk.parent_object_id) = 'PaymentMethods'
   OR OBJECT_NAME(fk.referenced_object_id) = 'PaymentMethods';
