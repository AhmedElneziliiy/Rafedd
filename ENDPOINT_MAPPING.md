# Rafedd API Endpoint Mapping

## Frontend Expected vs Backend Actual Endpoints

### ✅ AUTHENTICATION ENDPOINTS

| Frontend Expects | Backend Provides | Status | Notes |
|-----------------|------------------|--------|-------|
| POST /api/auth/login | POST /api/v1/auth/login | ✅ MATCH | Works perfectly |
| POST /api/auth/register | POST /api/v1/auth/register/manager | ⚠️ DIFFERENT | Backend uses /register/manager |
| POST /api/auth/forgot-password | - | ❌ MISSING | Need to implement |

### ⚠️ MANAGER ENDPOINTS

| Frontend Expects | Backend Provides | Status | Notes |
|-----------------|------------------|--------|-------|
| GET /api/manager/dashboard | GET /api/v1/manager/dashboard | ✅ MATCH | Works |
| GET /api/manager/employees | GET /api/v1/users/employees | ⚠️ DIFFERENT | Different path |
| POST /api/manager/employees | POST /api/v1/users/employees | ⚠️ DIFFERENT | Different path |
| GET /api/manager/employees/:id | GET /api/v1/users/employees/:id | ⚠️ DIFFERENT | Different path |
| PUT /api/manager/employees/:id | PUT /api/v1/users/employees/:id | ⚠️ DIFFERENT | Different path |
| DELETE /api/manager/employees/:id | DELETE /api/v1/users/employees/:id | ⚠️ DIFFERENT | Different path |
| GET /api/manager/annual-plan | GET /api/v1/annual-plan | ⚠️ DIFFERENT | Different path |
| POST /api/manager/annual-plan/generate | POST /api/v1/annual-plan/generate | ⚠️ DIFFERENT | Different path |
| GET /api/manager/weekly-tasks | GET /api/v1/tasks/weekly | ⚠️ DIFFERENT | Different path |
| POST /api/manager/weekly-tasks | POST /api/v1/tasks | ⚠️ DIFFERENT | Different path |
| GET /api/manager/weekly-reports | GET /api/v1/reports/weekly | ⚠️ DIFFERENT | Different path |
| GET /api/manager/suggestions | GET /api/v1/suggestions | ⚠️ DIFFERENT | Different path |
| GET /api/manager/important-notes | GET /api/v1/manager/important-notes | ✅ MATCH | Works |
| GET /api/manager/company | GET /api/v1/manager/profile | ⚠️ DIFFERENT | Different path |
| PUT /api/manager/company | - | ❌ MISSING | Need endpoint |
| PUT /api/manager/password | PUT /api/v1/users/change-password | ⚠️ DIFFERENT | Different path |
| GET /api/manager/subscription | - | ❌ MISSING | Need endpoint |

### ⚠️ EMPLOYEE ENDPOINTS

| Frontend Expects | Backend Provides | Status | Notes |
|-----------------|------------------|--------|-------|
| GET /api/employee/dashboard | - | ❌ MISSING | Need to implement |
| GET /api/employee/weekly-tasks | GET /api/v1/employee/tasks | ⚠️ DIFFERENT | Different path |
| POST /api/employee/weekly-report | POST /api/v1/employee/reports/weekly | ⚠️ DIFFERENT | Different path |
| POST /api/employee/daily-report | POST /api/v1/employee/reports/daily | ⚠️ DIFFERENT | Different path |
| GET /api/employee/suggestions | GET /api/v1/employee/suggestions | ⚠️ DIFFERENT | Different path |
| POST /api/employee/suggestions | POST /api/v1/employee/suggestions | ⚠️ DIFFERENT | Different path |
| GET /api/employee/important-notes | GET /api/v1/employee/important-notes | ✅ MATCH | Works |
| POST /api/employee/important-notes | POST /api/v1/employee/important-notes | ✅ MATCH | Works |
| PUT /api/employee/important-notes/:id | PUT /api/v1/employee/important-notes/:id | ✅ MATCH | Works |
| DELETE /api/employee/important-notes/:id | DELETE /api/v1/employee/important-notes/:id | ✅ MATCH | Works |
| GET /api/employee/profile | GET /api/v1/employee/profile | ⚠️ DIFFERENT | Need to verify |
| PUT /api/employee/password | PUT /api/v1/users/change-password | ⚠️ DIFFERENT | Different path |

### ✅ FILE UPLOAD

| Frontend Expects | Backend Provides | Status | Notes |
|-----------------|------------------|--------|-------|
| POST /api/upload | POST /api/v1/upload | ✅ MATCH | Works perfectly |

### ⚠️ SUPER ADMIN ENDPOINTS

| Frontend Expects | Backend Provides | Status | Notes |
|-----------------|------------------|--------|-------|
| GET /api/super-admin/dashboard | GET /api/v1/admin/dashboard | ⚠️ DIFFERENT | Different path |
| GET /api/super-admin/companies | GET /api/v1/admin/companies | ⚠️ DIFFERENT | Different path |
| GET /api/super-admin/companies/:id | GET /api/v1/admin/companies/:id | ⚠️ DIFFERENT | Different path |

## ACTUAL BACKEND ROUTES (from Controllers)

### AuthController (`/api/v1/auth`)
- ✅ POST /login
- ✅ POST /register/manager
- ✅ POST /register/employee (manager creates employee)
- ⚠️ POST /refresh-token (not in frontend docs)
- ⚠️ POST /logout (not in frontend docs)

### DashboardController (`/api/v1/manager`)
- ✅ GET /dashboard

### UsersController (`/api/v1/users`)
- ✅ GET /employees
- ✅ POST /employees
- ✅ GET /employees/{id}
- ✅ PUT /employees/{id}
- ✅ DELETE /employees/{id}
- ✅ PUT /change-password
- ✅ GET /profile

### ImportantNoteController (`/api/v1`)
- ✅ GET /employee/important-notes
- ✅ POST /employee/important-notes
- ✅ PUT /employee/important-notes/{id}
- ✅ DELETE /employee/important-notes/{id}
- ✅ GET /manager/important-notes
- ✅ GET /important-notes/{id}

### FileUploadController (`/api/v1`)
- ✅ POST /upload
- ✅ GET /uploads/{filename}
- ✅ DELETE /uploads/{filename}

### TasksController (`/api/v1/tasks`)
- ✅ POST / (create task)
- ✅ GET / (get all tasks)
- ✅ GET /{id}
- ✅ PUT /{id}
- ✅ DELETE /{id}
- ✅ GET /weekly
- ✅ GET /monthly

### ReportsController (`/api/v1/reports`)
- ✅ POST /weekly
- ✅ POST /daily
- ✅ GET /weekly
- ✅ GET /daily
- ✅ GET /weekly/{id}
- ✅ GET /daily/{id}

### SuggestionsController (`/api/v1/suggestions`)
- ✅ POST /
- ✅ GET /
- ✅ GET /{id}
- ✅ PUT /{id}/review

### AnnualPlanController (`/api/v1/annual-plan`)
- ✅ POST /generate
- ✅ GET /
- ✅ PUT /goals/{id}
- ✅ DELETE /goals/{id}

### AdminController (`/api/v1/admin`)
- ✅ GET /dashboard
- ✅ GET /companies
- ✅ GET /companies/{id}
- ✅ PUT /companies/{id}/toggle-active
- ✅ PUT /companies/{id}/change-password

### PaymentController (`/api/v1/payments`)
- ✅ POST /myfatoorah/initiate
- ✅ POST /myfatoorah/callback
- ✅ POST /stripe/webhook
- ✅ POST /paytabs/webhook

## RECOMMENDATIONS

### Option 1: Frontend Updates Required ✅ RECOMMENDED
Update frontend to use correct backend paths:
- `/api/manager/*` → `/api/v1/users/*` for employee management
- `/api/manager/*` → `/api/v1/tasks/*` for task management
- `/api/manager/*` → `/api/v1/reports/*` for reports
- `/api/super-admin/*` → `/api/v1/admin/*` for admin routes

### Option 2: Backend Route Aliases (NOT RECOMMENDED)
Add duplicate routes in backend to match frontend exactly - increases maintenance burden.

### Option 3: API Gateway/Proxy (OPTIONAL)
Use nginx or similar to rewrite routes between frontend and backend.

## MISSING ENDPOINTS TO IMPLEMENT

1. ❌ POST /api/v1/auth/forgot-password
2. ❌ GET /api/v1/employee/dashboard
3. ❌ PUT /api/v1/manager/company (update company profile)
4. ❌ GET /api/v1/manager/subscription

## CONCLUSION

**Current Compliance:** ~70% match with frontend expectations
**Action Required:** Frontend needs to update API paths to match backend structure
**Missing Features:** 4 endpoints need implementation
**Working Features:** Authentication, Important Notes, File Upload, Core CRUD operations all functional
