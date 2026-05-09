# Rafedd API Compliance Report

## Frontend Documentation vs Backend Implementation

### ✅ GEMINI AI INTEGRATION POINTS

According to the frontend docs, Gemini should be used for:

1. **POST /api/manager/annual-plan/generate** (Line 155-165 in docs)
   - Generates annual plan from a single goal
   - Breaks down into monthly/weekly goals
   - **Input:** `{"goal": "string", "year": number}`
   - **Gemini Use:** Generate structured breakdown of annual goal into 12 monthly goals and weekly tasks

2. **POST /api/manager/monthly-reports/generate** (Line 260-269 in docs)
   - Generates monthly analysis using AI
   - **Input:** `{"goal": "string", "month": number, "year": number}`
   - **Gemini Use:** Analyze employee performance data and generate insights/recommendations

3. **GET /api/manager/monthly-reports** (Line 254-258 in docs)
   - Returns AI-generated monthly performance analysis
   - **Gemini Use:** Generate performance analysis from task completion data

---

## ROUTE MAPPING - What Needs to Change

### Current Backend Structure:
- `/api/v1/manager/*` - Manager endpoints (ManagerController)
- `/api/v1/employee/*` - Employee endpoints (EmployeeController)
- `/api/v1/admin/*` - Admin endpoints (AdminController)
- `/api/v1/users/*` - User management (UsersController)
- `/api/v1/tasks/*` - Task management (TasksController)
- `/api/v1/reports/*` - Reports (ReportsController)

### Frontend Expects:
- `/api/manager/*` - ALL manager endpoints
- `/api/employee/*` - ALL employee endpoints
- `/api/super-admin/*` - ALL admin endpoints

### SOLUTION: Add Route Aliases

We need to support BOTH:
1. Current routes (for internal consistency)
2. Frontend-expected routes (for compatibility)

---

## DETAILED ENDPOINT MAPPING

### 🔴 AUTHENTICATION - Needs Route Adjustment

| Frontend Expects | Current Backend | Action Needed |
|-----------------|-----------------|---------------|
| POST /api/auth/login | POST /api/v1/auth/login | ⚠️ Add alias without /v1 |
| POST /api/auth/register | POST /api/v1/auth/register/manager | ⚠️ Add alias |
| POST /api/auth/forgot-password | ❌ Missing | ❌ Create endpoint |

### 🟡 MANAGER ENDPOINTS - Need Route Aliases

| Frontend Expects | Current Backend | Status |
|-----------------|-----------------|--------|
| GET /api/manager/dashboard | GET /api/v1/manager/dashboard | ✅ Exists - needs /v1 removal |
| GET /api/manager/employees | GET /api/v1/users/employees | ⚠️ Different controller |
| POST /api/manager/employees | POST /api/v1/users/employees | ⚠️ Different controller |
| GET /api/manager/employees/:id | GET /api/v1/users/employees/:id | ⚠️ Different controller |
| PUT /api/manager/employees/:id | PUT /api/v1/users/employees/:id | ⚠️ Different controller |
| DELETE /api/manager/employees/:id | DELETE /api/v1/users/employees/:id | ⚠️ Different controller |
| GET /api/manager/annual-plan | GET /api/v1/manager/annual-targets | ⚠️ Different naming |
| POST /api/manager/annual-plan/generate | POST /api/v1/manager/annual-targets | ⚠️ **NEEDS GEMINI** |
| PUT /api/manager/annual-plan/goals/:goalId | - | ❌ Missing |
| DELETE /api/manager/annual-plan/goals/:goalId | - | ❌ Missing |
| GET /api/manager/weekly-tasks | GET /api/v1/manager/tasks | ⚠️ Different naming |
| POST /api/manager/weekly-tasks | POST /api/v1/manager/tasks | ⚠️ Different naming |
| PUT /api/manager/weekly-tasks/:id | PUT /api/v1/tasks/:id | ⚠️ Different controller |
| GET /api/manager/weekly-reports | GET /api/v1/manager/reports | ⚠️ Different naming |
| GET /api/manager/weekly-reports/:id | GET /api/v1/reports/weekly/:id | ⚠️ Different controller |
| GET /api/manager/daily-reports | GET /api/v1/reports/daily | ⚠️ Different controller |
| GET /api/manager/daily-reports/:id | GET /api/v1/reports/daily/:id | ⚠️ Different controller |
| GET /api/manager/suggestions | GET /api/v1/suggestions | ⚠️ Different controller |
| GET /api/manager/suggestions/:id | GET /api/v1/suggestions/:id | ⚠️ Different controller |
| PUT /api/manager/suggestions/:id/review | PUT /api/v1/suggestions/:id/review | ⚠️ Different controller |
| GET /api/manager/important-notes | GET /api/v1/manager/important-notes | ✅ Exists |
| GET /api/manager/monthly-reports | - | ❌ **NEEDS GEMINI** |
| POST /api/manager/monthly-reports/generate | - | ❌ **NEEDS GEMINI** |
| GET /api/manager/company | GET /api/v1/users/profile | ⚠️ Different naming |
| PUT /api/manager/company | - | ❌ Missing |
| PUT /api/manager/password | PUT /api/v1/users/change-password | ⚠️ Different controller |
| GET /api/manager/subscription | - | ❌ Missing |
| PUT /api/manager/subscription/auto-renew | - | ❌ Missing |

### 🟡 EMPLOYEE ENDPOINTS - Need Route Aliases

| Frontend Expects | Current Backend | Status |
|-----------------|-----------------|--------|
| GET /api/employee/dashboard | - | ❌ Missing |
| GET /api/employee/weekly-tasks | GET /api/v1/employee/tasks | ⚠️ Different naming |
| PUT /api/employee/weekly-tasks/:id/status | PUT /api/v1/tasks/:id | ⚠️ Different controller |
| POST /api/employee/weekly-report | POST /api/v1/reports/weekly | ⚠️ Different controller |
| POST /api/employee/daily-report | POST /api/v1/reports/daily | ⚠️ Different controller |
| GET /api/employee/suggestions | GET /api/v1/employee/suggestions | ⚠️ Verify exists |
| POST /api/employee/suggestions | POST /api/v1/suggestions | ⚠️ Different controller |
| GET /api/employee/important-notes | GET /api/v1/employee/important-notes | ✅ Exists |
| POST /api/employee/important-notes | POST /api/v1/employee/important-notes | ✅ Exists |
| PUT /api/employee/important-notes/:id | PUT /api/v1/employee/important-notes/:id | ✅ Exists |
| DELETE /api/employee/important-notes/:id | DELETE /api/v1/employee/important-notes/:id | ✅ Exists |
| GET /api/employee/profile | GET /api/v1/users/profile | ⚠️ Different controller |
| PUT /api/employee/password | PUT /api/v1/users/change-password | ⚠️ Different controller |

### 🟡 SUPER ADMIN ENDPOINTS - Need Route Aliases

| Frontend Expects | Current Backend | Status |
|-----------------|-----------------|--------|
| GET /api/super-admin/dashboard | GET /api/v1/admin/dashboard | ⚠️ Different naming |
| GET /api/super-admin/companies | GET /api/v1/admin/companies | ⚠️ Different naming |
| GET /api/super-admin/companies/:id | GET /api/v1/admin/companies/:id | ⚠️ Different naming |
| PUT /api/super-admin/companies/:id/password | PUT /api/v1/admin/companies/:id/change-password | ⚠️ Different naming |
| PUT /api/super-admin/companies/:id/status | PUT /api/v1/admin/companies/:id/toggle-active | ⚠️ Different naming |
| GET /api/super-admin/subscriptions | - | ❌ Missing |
| GET /api/super-admin/subscriptions/plans | GET /api/v1/subscriptions/plans | ⚠️ Different controller |

### ✅ FILE UPLOAD - Already Matches

| Frontend Expects | Current Backend | Status |
|-----------------|-----------------|--------|
| POST /api/upload | POST /api/v1/upload | ✅ Exists |

---

## IMPLEMENTATION PLAN

### Phase 1: Remove `/v1` from All Routes ✅ CRITICAL
Change all `[Route("api/v1/...")]` to `[Route("api/...")]`

### Phase 2: Add Manager Route Aliases
Create route attributes that match frontend expectations:
```csharp
[Route("api/manager/employees")]  // Frontend expects this
[Route("api/v1/users/employees")] // Keep for backward compatibility
```

### Phase 3: Implement Missing Endpoints
1. POST /api/auth/forgot-password
2. GET /api/employee/dashboard
3. PUT /api/manager/company
4. GET /api/manager/subscription
5. PUT /api/manager/subscription/auto-renew
6. GET /api/super-admin/subscriptions

### Phase 4: Implement Gemini AI Endpoints ⭐ HIGH PRIORITY
1. **POST /api/manager/annual-plan/generate**
   - Use Gemini to break down annual goal into 12 monthly + 48-52 weekly goals

2. **POST /api/manager/monthly-reports/generate**
   - Use Gemini to analyze employee task completion rates
   - Generate performance insights and recommendations

3. **GET /api/manager/monthly-reports**
   - Return AI-generated monthly analysis

---

## GEMINI INTEGRATION SPECIFICATION

### Endpoint 1: Generate Annual Plan
**Route:** POST /api/manager/annual-plan/generate

**Request:**
```json
{
  "goal": "زيادة الإيرادات بنسبة 30%",
  "year": 2025
}
```

**Gemini Prompt Template:**
```
You are a business planning assistant. Break down the following annual goal into a structured plan:

Annual Goal: {goal}
Year: {year}

Generate:
1. 12 monthly goals (one for each month)
2. For each month, generate 4-5 weekly goals
3. Each goal should be specific, measurable, and achievable

Return as JSON:
{
  "monthlyGoals": [
    {
      "month": 1,
      "description": "...",
      "weeklyGoals": [
        {"week": 1, "description": "..."},
        {"week": 2, "description": "..."}
      ]
    }
  ]
}
```

### Endpoint 2: Generate Monthly Performance Report
**Route:** POST /api/manager/monthly-reports/generate

**Request:**
```json
{
  "goal": "تحسين الأداء",
  "month": 11,
  "year": 2025
}
```

**Gemini Prompt Template:**
```
Analyze employee performance data and generate insights:

Performance Data:
- Employees: {employeeCount}
- Tasks Assigned: {totalTasks}
- Tasks Completed: {completedTasks}
- Completion Rate: {completionRate}%
- Employee Performance: {employeeStats}

Generate:
1. Overall performance summary
2. Top performers
3. Areas needing improvement
4. Actionable recommendations

Return as JSON with Arabic text for descriptions.
```

### Endpoint 3: Get Monthly Reports
**Route:** GET /api/manager/monthly-reports?month=11&year=2025

**Response Should Include:**
```json
{
  "success": true,
  "data": {
    "month": 11,
    "year": 2025,
    "employeeAnalysis": [...],
    "aiGeneratedInsights": "النص المولد من Gemini",
    "recommendations": [...]
  }
}
```

---

## FILES TO MODIFY

1. ✅ **All Controllers** - Remove `/v1` from routes
2. ⭐ **ManagerController.cs** - Add Gemini AI service injection
3. ⭐ **Create GeminiService.cs** - AI integration service
4. **UsersController.cs** - Add manager/employee route aliases
5. **AdminController.cs** - Rename to match super-admin routes
6. **AuthController.cs** - Add forgot-password endpoint

---

## NEXT STEPS

1. Create GeminiService for AI integration
2. Remove /v1 from all routes
3. Add route aliases for backward compatibility
4. Implement 3 Gemini-powered endpoints
5. Test all endpoints match frontend docs exactly
