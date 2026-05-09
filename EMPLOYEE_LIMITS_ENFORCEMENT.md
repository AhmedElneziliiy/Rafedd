# Employee Limits Enforcement - Complete Guide

## ✅ YES, Employee Limits ARE Enforced!

Your subscription plans have employee limits that are **strictly enforced** at multiple levels in the system.

---

## 📊 Current Plan Limits (Updated)

| Plan | Price (USD) | Max Employees | Status |
|------|-------------|---------------|--------|
| **المبتدأ (Beginner)** | $50/month | **30 employees** | ✅ Active |
| **المحترف (Professional)** | $100/month | **100 employees** | ✅ Active |
| **المؤسسات (Enterprise)** | Custom | **1000 employees** | ✅ Active |

---

## 🔒 How Employee Limits Are Enforced

### 1. **Employee Registration Blocked**

When a manager tries to add an employee beyond their limit:

**Endpoint**: `POST /api/v1/auth/register/employee`

**Validation Code** ([AuthService.cs:143-153](BLL/Service/AuthService.cs#L143-L153)):
```csharp
// Check if manager can add more employees
var canAddEmployee = await _subscriptionService.CheckEmployeeLimitAsync(managerUserId, 1);

if (!canAddEmployee)
{
    var subscription = await _subscriptionService.GetActiveSubscriptionAsync(managerUserId);
    var maxEmployees = subscription?.MaxEmployees ?? 0;
    var currentCount = await _employeeRepository.GetEmployeeCountByManagerAsync(managerUserId);

    throw new InvalidOperationException(
        $"تم الوصول للحد الأقصى من الموظفين المسموح به ({maxEmployees}). الحالي: {currentCount}");
    // Translation: "Maximum allowed employees limit reached ({maxEmployees}). Current: {currentCount}"
}
```

**Error Response**:
```json
{
  "success": false,
  "message": "تم الوصول للحد الأقصى من الموظفين المسموح به (30). الحالي: 30",
  "statusCode": 400
}
```

### 2. **Real-time Employee Count**

The system counts active employees directly from the database (no cached values):

**Method** ([EmployeeRepository.cs:37-41](DAL/Repositories/RepositoryClasses/EmployeeRepository.cs#L37-L41)):
```csharp
public async Task<int> GetEmployeeCountByManagerAsync(string managerUserId)
{
    return await _dbSet
        .CountAsync(e => e.ManagerUserId == managerUserId && e.IsActive);
}
```

**Important**: Only counts **active** employees (IsActive = true)

### 3. **Plan Downgrade Protection**

When downgrading to a cheaper plan, the system prevents it if current employees exceed the new limit:

**Validation** ([SubscriptionService.cs:120-129](BLL/Service/SubscriptionService.cs#L120-L129)):
```csharp
if (newPlan.MaxEmployees < currentSubscription.Plan!.MaxEmployees)
{
    var employeeCount = await _employeeRepository.GetEmployeeCountByManagerAsync(managerUserId);

    if (employeeCount > newPlan.MaxEmployees)
    {
        throw new InvalidOperationException(
            $"Cannot downgrade: Manager has {employeeCount} employees, but new plan allows only {newPlan.MaxEmployees}");
    }
}
```

**Example**:
- Current Plan: Professional ($100) - 100 employees
- Current Employees: 75
- Trying to downgrade to: Beginner ($50) - 30 employees
- **Result**: ❌ BLOCKED - "Cannot downgrade: Manager has 75 employees, but new plan allows only 30"

### 4. **Subscription Required for Employee Creation**

**Authorization** ([AuthController.cs:42](Rafedd/Controllers/AuthController.cs#L42)):
```csharp
[Authorize(Roles = "Manager")]
[RequireActiveSubscription]  // ← Requires active, non-expired subscription
public async Task<IActionResult> RegisterEmployee([FromBody] CreateEmployeeDto dto)
```

The `RequireActiveSubscription` attribute blocks the request if:
- No active subscription exists
- Subscription is expired
- Returns HTTP 402 (Payment Required)

---

## 📡 API Endpoints for Employee Limits

### Check if Employees Can Be Added

**Endpoint**: `POST /api/v1/subscriptions/check-employee-limit`

**Request**:
```json
{
  "requestedCount": 5
}
```

**Response (Allowed)**:
```json
{
  "success": true,
  "data": {
    "allowed": true,
    "currentCount": 25,
    "maxEmployees": 30,
    "remaining": 5,
    "message": "يمكنك إضافة 5 موظفين" // "You can add 5 employees"
  }
}
```

**Response (Not Allowed)**:
```json
{
  "success": false,
  "data": {
    "allowed": false,
    "currentCount": 30,
    "maxEmployees": 30,
    "remaining": 0,
    "message": "تم الوصول للحد الأقصى من الموظفين"
  }
}
```

### Get Subscription Status

**Endpoint**: `GET /api/v1/subscriptions/status`

**Response**:
```json
{
  "success": true,
  "data": {
    "isActive": true,
    "planName": "المحترف",
    "currentEmployeeCount": 45,
    "maxEmployees": 100,
    "canAddEmployees": true,
    "subscriptionEndsAt": "2026-01-29T20:32:50",
    "daysRemaining": 25
  }
}
```

---

## 🎯 Example Scenarios

### Scenario 1: Manager with Beginner Plan ($50)

- **Max Employees**: 30
- **Current Employees**: 28
- **Action**: Try to add 1 employee
- **Result**: ✅ **ALLOWED** (28 + 1 = 29 ≤ 30)

### Scenario 2: Manager with Beginner Plan ($50)

- **Max Employees**: 30
- **Current Employees**: 30
- **Action**: Try to add 1 employee
- **Result**: ❌ **BLOCKED**
- **Error**: "تم الوصول للحد الأقصى من الموظفين المسموح به (30). الحالي: 30"

### Scenario 3: Manager with Professional Plan ($100)

- **Max Employees**: 100
- **Current Employees**: 95
- **Action**: Try to add 10 employees (bulk import)
- **Result**: ❌ **BLOCKED** (95 + 10 = 105 > 100)

### Scenario 4: Upgrade from Beginner to Professional

- **Current Plan**: Beginner - 30 employees
- **Current Employees**: 30
- **Action**: Upgrade to Professional plan
- **Result**: ✅ **ALLOWED**
- **New Limit**: 100 employees
- **Can Now Add**: 70 more employees

### Scenario 5: Downgrade from Professional to Beginner

- **Current Plan**: Professional - 100 employees
- **Current Employees**: 45
- **Action**: Downgrade to Beginner plan
- **Result**: ❌ **BLOCKED**
- **Error**: "Cannot downgrade: Manager has 45 employees, but new plan allows only 30"

---

## 💻 Frontend Implementation

### Display Current vs Max Employees

```javascript
// Example: React component
function EmployeeDashboard({ subscription }) {
  const { currentEmployeeCount, maxEmployees } = subscription;
  const percentage = (currentEmployeeCount / maxEmployees) * 100;
  const canAddMore = currentEmployeeCount < maxEmployees;

  return (
    <div className="employee-limit-card">
      <h3>Employee Usage</h3>
      <p className="count">
        {currentEmployeeCount} / {maxEmployees} employees
      </p>

      <div className="progress-bar">
        <div
          className="progress-fill"
          style={{ width: `${percentage}%` }}
        />
      </div>

      {!canAddMore && (
        <div className="warning">
          ⚠️ You've reached your employee limit.
          <a href="/upgrade">Upgrade plan</a> to add more.
        </div>
      )}

      {canAddMore && (
        <p className="remaining">
          You can add {maxEmployees - currentEmployeeCount} more employees
        </p>
      )}
    </div>
  );
}
```

### Check Before Adding Employee

```javascript
async function addEmployee(employeeData) {
  // 1. Check limit first (optional - backend will validate anyway)
  const checkResponse = await fetch('/api/v1/subscriptions/check-employee-limit', {
    method: 'POST',
    headers: {
      'Authorization': `Bearer ${token}`,
      'Content-Type': 'application/json'
    },
    body: JSON.stringify({ requestedCount: 1 })
  });

  const checkResult = await checkResponse.json();

  if (!checkResult.data.allowed) {
    alert(checkResult.data.message);
    return;
  }

  // 2. Proceed with registration
  const response = await fetch('/api/v1/auth/register/employee', {
    method: 'POST',
    headers: {
      'Authorization': `Bearer ${token}`,
      'Content-Type': 'application/json'
    },
    body: JSON.stringify(employeeData)
  });

  if (!response.ok) {
    const error = await response.json();
    if (error.message.includes('الحد الأقصى')) {
      // Employee limit reached
      showUpgradeDialog();
    }
  }
}
```

### Bulk Employee Import with Limit Check

```javascript
async function bulkImportEmployees(employeeList) {
  const count = employeeList.length;

  // Check if all can be added
  const checkResponse = await fetch('/api/v1/subscriptions/check-employee-limit', {
    method: 'POST',
    headers: {
      'Authorization': `Bearer ${token}`,
      'Content-Type': 'application/json'
    },
    body: JSON.stringify({ requestedCount: count })
  });

  const result = await checkResponse.json();

  if (!result.data.allowed) {
    const message = `
      Cannot import ${count} employees.
      Current: ${result.data.currentCount}
      Max: ${result.data.maxEmployees}
      Available: ${result.data.remaining}

      Please upgrade your plan or reduce the number of employees.
    `;
    alert(message);
    return;
  }

  // Proceed with bulk import...
}
```

---

## 🔄 Plan Upgrade Flow

When a manager needs more employees:

### Option 1: Self-Service Upgrade

1. Manager tries to add employee → **Blocked**
2. System shows: "Employee limit reached (30/30)"
3. Button: "Upgrade to Professional Plan"
4. Redirect to payment page
5. Pay $100 for Professional plan
6. Subscription upgraded automatically
7. New limit: 100 employees ✅

### Option 2: Proactive Upgrade

1. Manager views dashboard
2. Sees: "25/30 employees (83% used)"
3. Warning: "Approaching limit! Upgrade for more employees"
4. Click "View Plans"
5. Compare plans and upgrade

---

## 📊 Database Structure

### SubscriptionPlans Table

```sql
CREATE TABLE SubscriptionPlans (
    Id INT PRIMARY KEY,
    Name NVARCHAR(50),
    PricePerMonth DECIMAL(18,2),
    MaxEmployees INT,              -- Employee limit enforced here
    Description NVARCHAR(MAX),
    IsActive BIT
);

-- Current data:
-- Id=1: $50, MaxEmployees=30
-- Id=2: $100, MaxEmployees=100
-- Id=3: $0 (custom), MaxEmployees=1000
```

### Employees Table

```sql
CREATE TABLE Employees (
    Id INT PRIMARY KEY,
    ManagerUserId NVARCHAR(450),   -- Links to manager
    UserId NVARCHAR(450),          -- Links to ApplicationUser
    IsActive BIT,                  -- Only active employees count
    -- ... other fields
);

-- Count query:
SELECT COUNT(*)
FROM Employees
WHERE ManagerUserId = @managerId
  AND IsActive = 1;
```

---

## ⚙️ Configuration

### Seed Data (SubscriptionPlans.json)

```json
[
  {
    "id": 1,
    "name": "المبتدأ",
    "pricePerMonth": 50.00,
    "maxEmployees": 30,
    "isActive": true
  },
  {
    "id": 2,
    "name": "المحترف",
    "pricePerMonth": 100.00,
    "maxEmployees": 100,
    "isActive": true
  },
  {
    "id": 3,
    "name": "المؤسسات",
    "pricePerMonth": 0.00,
    "maxEmployees": 1000,
    "isActive": true
  }
]
```

---

## 🧪 Testing Employee Limits

### Test Case 1: Add Employee Within Limit

```bash
# Assuming manager has 25/30 employees
curl -X POST "http://localhost:5041/api/v1/auth/register/employee" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "fullName": "John Doe",
    "email": "john@example.com",
    "phoneNumber": "+1234567890",
    "password": "Password123!",
    "position": "Developer"
  }'

# Expected: 201 Created
# Response: { "success": true, "data": { employee details } }
```

### Test Case 2: Add Employee at Limit

```bash
# Assuming manager has 30/30 employees
curl -X POST "http://localhost:5041/api/v1/auth/register/employee" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "fullName": "Jane Doe",
    "email": "jane@example.com",
    "phoneNumber": "+1234567891",
    "password": "Password123!",
    "position": "Manager"
  }'

# Expected: 400 Bad Request
# Response: {
#   "success": false,
#   "message": "تم الوصول للحد الأقصى من الموظفين المسموح به (30). الحالي: 30"
# }
```

### Test Case 3: Check Employee Limit

```bash
curl -X POST "http://localhost:5041/api/v1/subscriptions/check-employee-limit" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{ "requestedCount": 5 }'

# Response shows if 5 employees can be added
```

---

## 📋 Summary

✅ **Employee limits ARE enforced** at multiple levels:
- Database-level counting (real-time, no cached values)
- API validation before employee creation
- Plan downgrade protection
- Active subscription requirement
- Clear error messages in Arabic

✅ **Current limits**:
- Beginner Plan ($50): **30 employees**
- Professional Plan ($100): **100 employees**
- Enterprise Plan (Custom): **1000 employees**

✅ **Frontend should**:
- Display current vs max employees
- Show warnings when approaching limit
- Offer upgrade path when limit reached
- Pre-validate before bulk imports

✅ **API handles everything automatically** - no manual intervention needed!
