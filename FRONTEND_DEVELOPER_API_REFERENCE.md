# Rafedd API - Frontend Developer Reference

**Base URL (Development):** `http://localhost:5041/api/v1`
**Base URL (Production):** `https://your-domain.com/api/v1`

**Authentication:** JWT Bearer Token
**Date Format:** ISO 8601 (UTC)
**Response Language:** Arabic

---

## 📋 Table of Contents

1. [Overview](#overview)
2. [Authentication](#authentication)
3. [Manager Endpoints](#manager-endpoints)
4. [Employee Endpoints](#employee-endpoints)
5. [Payment Endpoints](#payment-endpoints)
6. [Response Structure](#response-structure)
7. [Error Handling](#error-handling)
8. [Integration Notes](#integration-notes)

---

## Overview

### Common Response Format

All endpoints return this structure:

```json
{
  "success": boolean,
  "message": "string (Arabic message)",
  "data": object | array | null,
  "errors": ["string array"],
  "statusCode": number
}
```

### HTTP Status Codes

| Code | Meaning |
|------|---------|
| 200 | Success |
| 400 | Bad Request (validation error) |
| 401 | Unauthorized (missing/invalid token) |
| 402 | Payment Required (no active subscription) |
| 403 | Forbidden (insufficient permissions) |
| 404 | Not Found |
| 500 | Server Error |

---

## Authentication

### How to Include Auth Token

Add to request headers:
```
Authorization: Bearer {your_jwt_token}
```

### 1. Register Manager

**POST** `/auth/register/manager`

**No Auth Required**

**Body:**
```json
{
  "fullName": "string (required)",
  "email": "string (required, valid email)",
  "password": "string (required, min 8 chars, must contain digit)",
  "phoneNumber": "string (optional)",
  "companyName": "string (required)",
  "businessType": "string (optional)",
  "businessDescription": "string (optional)"
}
```

**Response:**
```json
{
  "success": true,
  "message": "تم إنشاء حساب المدير بنجاح",
  "data": {
    "userId": "guid",
    "fullName": "أحمد علي",
    "email": "ahmed@example.com",
    "role": "Manager",
    "token": "eyJhbGc...",
    "hasActiveSubscription": false,
    "subscriptionEndsAt": null,
    "maxEmployees": null,
    "currentEmployeeCount": 0
  }
}
```

---

### 2. Login

**POST** `/auth/login`

**No Auth Required**

**Body:**
```json
{
  "email": "string",
  "password": "string"
}
```

**Response (Manager):**
```json
{
  "success": true,
  "message": "تم تسجيل الدخول بنجاح",
  "data": {
    "userId": "guid",
    "fullName": "أحمد علي",
    "email": "ahmed@example.com",
    "role": "Manager",
    "token": "eyJhbGc...",
    "hasActiveSubscription": true,
    "subscriptionEndsAt": "2025-12-31T23:59:59Z",
    "subscriptionPlanId": 1,
    "subscriptionPlanName": "المبتدأ",
    "maxEmployees": 30,
    "currentEmployeeCount": 5,
    "daysRemaining": 27
  }
}
```

**Frontend Action:**
- Store `token` securely
- Check `hasActiveSubscription`
- If `false`, show subscription prompt
- If `daysRemaining < 7`, show renewal warning

---

### 3. Register Employee

**POST** `/auth/register/employee`

**Auth Required:** Manager
**Subscription Required:** Yes

**Body:**
```json
{
  "fullName": "string (required)",
  "email": "string (required)",
  "password": "string (required, min 8 chars)",
  "phoneNumber": "string (optional)",
  "position": "string (optional)",
  "salary": number (optional)
}
```

**Response:**
```json
{
  "success": true,
  "message": "تم إنشاء حساب الموظف بنجاح",
  "data": {
    "userId": "guid",
    "fullName": "محمد أحمد",
    "email": "mohammed@example.com",
    "role": "Employee",
    "token": "eyJhbGc..."
  }
}
```

**If No Subscription (402):**
```json
{
  "success": false,
  "message": "يتطلب الوصول إلى هذه الميزة اشتراك نشط",
  "statusCode": 402
}
```

---

## Manager Endpoints

All require **Manager/Admin** role + JWT token.

### 1. Get Dashboard

**GET** `/manager/dashboard`

**Auth Required:** Yes

**Response:**
```json
{
  "success": true,
  "data": {
    "currentYear": 2025,
    "currentMonth": 12,
    "currentWeek": 1,
    "currentWeekInfo": {
      "weekNumber": 1,
      "weekStartDate": "2025-12-01T00:00:00",
      "weekEndDate": "2025-12-07T00:00:00",
      "achievementPercentage": 75.5,
      "isCurrentWeek": true,
      "tasksCount": 10,
      "completedTasksCount": 8,
      "reportsCount": 8
    },
    "monthWeeks": [
      {
        "weekNumber": 1,
        "achievementPercentage": 75.5,
        "tasksCount": 10
      },
      {
        "weekNumber": 2,
        "achievementPercentage": null,
        "tasksCount": 0
      }
      // weeks 3, 4...
    ],
    "totalEmployees": 15,
    "companyName": "شركة التقنية",
    "currentAnnualTarget": {
      "id": 1,
      "year": 2025,
      "targetDescription": "زيادة المبيعات 50%"
    }
  }
}
```

**Frontend Display:**
- Show current week progress
- Display monthly calendar view
- Show annual target summary

---

### 2. Create Annual Target

**POST** `/manager/annual-targets`

**Auth Required:** Yes
**Subscription Required:** Yes

**Body:**
```json
{
  "year": 2025,
  "targetDescription": "زيادة المبيعات بنسبة 50% وتحسين الجودة"
}
```

**Response:**
```json
{
  "success": true,
  "message": "تم إنشاء الهدف السنوي بنجاح. تم توليد الخطة الكاملة (48 أسبوع) باستخدام Gemini AI",
  "data": {
    "id": 1,
    "year": 2025,
    "targetDescription": "زيادة المبيعات 50%",
    "monthlyPlans": [
      {
        "id": 1,
        "month": 1,
        "monthlyGoal": "تحقيق مبيعات 100 ألف ريال",
        "weeklyPlans": [
          {
            "id": 1,
            "weekNumber": 1,
            "weeklyGoal": "التركيز على العملاء الجدد",
            "weekStartDate": "2025-01-01T00:00:00",
            "weekEndDate": "2025-01-07T00:00:00"
          }
          // 3 more weeks...
        ]
      }
      // 11 more months...
    ]
  }
}
```

**Note:** AI generates 12 monthly plans with 4 weekly plans each (48 weeks total). Takes 10-15 seconds.

---

### 3. Get Annual Target

**GET** `/manager/annual-targets/{year}`

**Auth Required:** Yes

**URL Params:**
- `year` (integer): e.g., 2025

**Example:** `/manager/annual-targets/2025`

**Response:** Same as Create Annual Target response

**404 Response:**
```json
{
  "success": false,
  "message": "الهدف السنوي للعام 2025 غير موجود",
  "statusCode": 404
}
```

---

### 4. Get All Annual Targets

**GET** `/manager/annual-targets`

**Auth Required:** Yes

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "year": 2025,
      "targetDescription": "...",
      "monthlyPlans": [...]
    },
    {
      "id": 2,
      "year": 2024,
      "targetDescription": "...",
      "monthlyPlans": [...]
    }
  ]
}
```

---

### 5. Create Task

**POST** `/manager/tasks`

**Auth Required:** Yes
**Subscription Required:** Yes

**Body:**
```json
{
  "title": "string (required, max 200)",
  "description": "string (optional)",
  "deadline": "2025-12-10T23:59:59Z (optional)",
  "year": 2025,
  "month": 12,
  "weekNumber": 1,
  "assignedToEmployeeIds": [1, 2, 3]
}
```

**Response:**
```json
{
  "success": true,
  "message": "تم إنشاء المهمة بنجاح",
  "data": {
    "id": 1,
    "title": "إعداد تقرير المبيعات",
    "description": "تحليل أداء ديسمبر",
    "deadline": "2025-12-10T23:59:59Z",
    "isCompleted": false,
    "year": 2025,
    "month": 12,
    "weekNumber": 1,
    "assignedEmployees": [
      {
        "employeeId": 1,
        "employeeName": "أحمد محمد",
        "email": "ahmed@example.com"
      }
    ]
  }
}
```

---

### 6. Get Tasks by Week

**GET** `/manager/tasks`

**Auth Required:** Yes

**Query Params:**
- `year` (integer, required)
- `month` (integer, required, 1-12)
- `weekNumber` (integer, required, 1-4)

**Example:** `/manager/tasks?year=2025&month=12&weekNumber=1`

**Response:**
```json
{
  "success": true,
  "message": "تم الحصول على مهام الأسبوع 1 من الشهر 12 بنجاح",
  "data": [
    {
      "id": 1,
      "title": "إعداد التقرير",
      "description": "...",
      "deadline": "2025-12-10T23:59:59Z",
      "isCompleted": true,
      "completedAt": "2025-12-05T14:30:00Z",
      "assignedEmployees": [
        {
          "employeeId": 1,
          "employeeName": "أحمد محمد"
        }
      ],
      "reports": [
        {
          "id": 1,
          "reportText": "تم الإنجاز بنجاح",
          "submittedAt": "2025-12-05T14:00:00Z",
          "employeeName": "أحمد محمد"
        }
      ]
    }
  ]
}
```

---

### 7. Delete Task

**DELETE** `/manager/tasks/{taskId}`

**Auth Required:** Yes
**Subscription Required:** Yes

**URL Params:**
- `taskId` (integer)

**Example:** `/manager/tasks/5`

**Response:**
```json
{
  "success": true,
  "message": "تم حذف المهمة بنجاح"
}
```

---

### 8. Get Reports by Week

**GET** `/manager/reports`

**Auth Required:** Yes

**Query Params:**
- `year` (integer, required)
- `month` (integer, required)
- `weekNumber` (integer, required)

**Example:** `/manager/reports?year=2025&month=12&weekNumber=1`

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "taskId": 1,
      "taskTitle": "إعداد التقرير",
      "reportText": "تم إنجاز المهمة بنجاح...",
      "submittedAt": "2025-12-05T14:00:00Z",
      "employeeId": 1,
      "employeeName": "أحمد محمد",
      "employeeEmail": "ahmed@example.com"
    }
  ]
}
```

---

### 9. Generate Weekly Performance Report

**POST** `/manager/performance-reports/{weeklyPlanId}/generate`

**Auth Required:** Yes
**Subscription Required:** Yes

**URL Params:**
- `weeklyPlanId` (integer): Get from annual target's weekly plans

**Response:**
```json
{
  "success": true,
  "message": "تم توليد تقرير الأداء بنجاح باستخدام Gemini AI",
  "data": {
    "id": 1,
    "weeklyPlanId": 1,
    "year": 2025,
    "month": 12,
    "weekNumber": 1,
    "weeklyGoal": "التركيز على العملاء الجدد",
    "achievementPercentage": 85.5,
    "summary": "أداء ممتاز هذا الأسبوع مع تحقيق معظم الأهداف",
    "strengths": [
      "التزام الفريق بالمواعيد",
      "جودة عالية في التقارير",
      "تعاون فعال"
    ],
    "weaknesses": [
      "تأخر بسيط في بعض المهام",
      "حاجة لمزيد من التواصل"
    ],
    "recommendations": [
      "الاستمرار في نفس الوتيرة",
      "تحسين التواصل الداخلي",
      "التركيز على الأولويات"
    ],
    "generatedAt": "2025-12-08T10:00:00Z"
  }
}
```

**Note:** AI analysis takes 5-10 seconds. Show loading indicator.

---

### 10. Get Weekly Performance Report

**GET** `/manager/performance-reports/{weeklyPlanId}`

**Auth Required:** Yes

**Response:** Same as Generate endpoint (without generating new report)

---

### 11. Get Performance Reports by Year

**GET** `/manager/performance-reports`

**Auth Required:** Yes

**Query Params:**
- `year` (integer, required)

**Example:** `/manager/performance-reports?year=2025`

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "weeklyPlanId": 1,
      "year": 2025,
      "month": 1,
      "weekNumber": 1,
      "achievementPercentage": 85.5,
      "generatedAt": "2025-01-08T10:00:00Z"
    }
    // ... up to 48 weekly reports
  ]
}
```

---

### 12. Generate Monthly Performance Report

**POST** `/manager/monthly-reports/{monthlyPlanId}/generate`

**Auth Required:** Yes
**Subscription Required:** Yes

**URL Params:**
- `monthlyPlanId` (integer): Get from annual target's monthly plans

**Response:**
```json
{
  "success": true,
  "message": "تم توليد تقرير الأداء الشهري بنجاح باستخدام Gemini AI",
  "data": {
    "id": 1,
    "monthlyPlanId": 1,
    "month": 12,
    "year": 2025,
    "monthlyGoal": "تحقيق مبيعات 100 ألف ريال",
    "achievementPercentage": 78.5,
    "totalTasks": 40,
    "completedTasks": 32,
    "summary": "أداء جيد خلال الشهر مع تحسن تدريجي عبر الأسابيع الأربعة",
    "strengths": [
      "تحسن مستمر في الأداء",
      "التزام عالي من الفريق",
      "تحقيق الأهداف الرئيسية"
    ],
    "weaknesses": [
      "انخفاض في الأسبوع الثاني",
      "بعض التحديات في التواصل"
    ],
    "recommendations": [
      "تحسين التخطيط للشهر القادم",
      "تعزيز آليات المتابعة",
      "تقديم دعم إضافي للفريق"
    ],
    "weeklyProgress": [
      {
        "weekNumber": 1,
        "achievementPercentage": 75.0
      },
      {
        "weekNumber": 2,
        "achievementPercentage": 70.0
      },
      {
        "weekNumber": 3,
        "achievementPercentage": 82.0
      },
      {
        "weekNumber": 4,
        "achievementPercentage": 87.0
      }
    ],
    "generatedAt": "2025-12-31T10:00:00Z"
  }
}
```

**Note:**
- Re-analyzes ALL 4 weeks of data using AI
- Takes 10-15 seconds
- Shows comprehensive monthly insights

---

### 13. Get Monthly Performance Report

**GET** `/manager/monthly-reports/{monthlyPlanId}`

**Auth Required:** Yes

**Response:** Same as Generate endpoint

---

### 14. Get Monthly Reports by Year

**GET** `/manager/monthly-reports`

**Auth Required:** Yes

**Query Params:**
- `year` (integer, required)

**Example:** `/manager/monthly-reports?year=2025`

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "monthlyPlanId": 1,
      "month": 1,
      "year": 2025,
      "achievementPercentage": 78.5,
      "generatedAt": "2025-01-31T10:00:00Z"
    }
    // ... up to 12 monthly reports
  ]
}
```

---

### 15. Analyze Task (AI)

**POST** `/manager/tasks/{taskId}/analyze`

**Auth Required:** Yes
**Subscription Required:** Yes

**URL Params:**
- `taskId` (integer)

**Response:**
```json
{
  "success": true,
  "message": "تم تحليل المهمة بنجاح باستخدام Gemini AI",
  "data": {
    "taskId": 1,
    "taskTitle": "إعداد التقرير",
    "analysis": "المهمة تم إنجازها بشكل ممتاز...",
    "suggestedImprovements": [
      "إضافة المزيد من التفاصيل",
      "تحسين التنسيق"
    ],
    "analyzedAt": "2025-12-04T10:00:00Z"
  }
}
```

---

### 16. Analyze Batch Tasks (AI)

**POST** `/manager/tasks/analyze-batch`

**Auth Required:** Yes
**Subscription Required:** Yes

**Body:** Array of task IDs
```json
[1, 2, 3, 4, 5]
```

**Response:**
```json
{
  "success": true,
  "message": "تم تحليل 5 مهمة بنجاح باستخدام Gemini AI",
  "data": [
    {
      "taskId": 1,
      "analysis": "...",
      "suggestedImprovements": ["..."]
    }
    // ... rest of tasks
  ]
}
```

---

## Employee Endpoints

All require **Employee** role + JWT token.

### 1. Get My Tasks

**GET** `/employee/tasks`

**Auth Required:** Yes (Employee)

**Query Params:**
- `year` (integer, required)
- `month` (integer, required)
- `weekNumber` (integer, required)

**Example:** `/employee/tasks?year=2025&month=12&weekNumber=1`

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "title": "إعداد تقرير المبيعات",
      "description": "تحليل أداء ديسمبر",
      "deadline": "2025-12-10T23:59:59Z",
      "isCompleted": false,
      "year": 2025,
      "month": 12,
      "weekNumber": 1,
      "createdByManager": "أحمد المدير",
      "myReport": null
    }
  ]
}
```

---

### 2. Submit Task Report

**POST** `/employee/tasks/{taskId}/report`

**Auth Required:** Yes (Employee)

**URL Params:**
- `taskId` (integer)

**Body:**
```json
{
  "reportText": "string (required, min 10 characters)"
}
```

**Example Body:**
```json
{
  "reportText": "تم إنجاز المهمة بنجاح. قمت بتحليل جميع البيانات المطلوبة وإعداد التقرير الشامل."
}
```

**Response:**
```json
{
  "success": true,
  "message": "تم إرسال التقرير بنجاح",
  "data": {
    "id": 1,
    "taskId": 1,
    "taskTitle": "إعداد تقرير المبيعات",
    "reportText": "تم إنجاز المهمة بنجاح...",
    "submittedAt": "2025-12-05T14:00:00Z",
    "employeeName": "محمد أحمد"
  }
}
```

---

### 3. Get My Reports

**GET** `/employee/reports`

**Auth Required:** Yes (Employee)

**Query Params:**
- `year` (integer, required)
- `month` (integer, required)
- `weekNumber` (integer, required)

**Example:** `/employee/reports?year=2025&month=12&weekNumber=1`

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "taskId": 1,
      "taskTitle": "إعداد التقرير",
      "reportText": "تم الإنجاز بنجاح",
      "submittedAt": "2025-12-05T14:00:00Z"
    }
  ]
}
```

---

## Payment Endpoints

### 1. Get Subscription Plans

**GET** `/payment/subscription-plans`

**No Auth Required**

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "name": "المبتدأ",
      "description": "مثالي للشركات الصغيرة - حتى 30 موظف",
      "pricePerMonth": 99.00,
      "maxEmployees": 30,
      "isActive": true,
      "features": [
        "إدارة حتى 30 موظف",
        "تخطيط سنوي ذكي بالذكاء الاصطناعي",
        "تقارير أداء أسبوعية وشهرية",
        "تحليل ذكي للمهام",
        "لوحة تحكم شاملة"
      ]
    },
    {
      "id": 2,
      "name": "المحترف",
      "description": "للشركات المتوسطة - حتى 50 موظف",
      "pricePerMonth": 199.00,
      "maxEmployees": 50,
      "isActive": true,
      "features": [
        "إدارة حتى 50 موظف",
        "جميع مزايا الخطة المبتدئة",
        "دعم فني ذو أولوية",
        "تقارير متقدمة"
      ]
    }
  ]
}
```

**Frontend Display:**
- Show as pricing cards
- Highlight current plan if subscribed
- Show "اشترك الآن" button for each

---

### 2. Initiate Payment

**POST** `/payment/initiate`

**Auth Required:** Yes (Manager)

**Body:**
```json
{
  "subscriptionPlanId": 1,
  "durationMonths": 1
}
```

**Response:**
```json
{
  "success": true,
  "message": "تم إنشاء رابط الدفع بنجاح",
  "data": {
    "paymentUrl": "https://payment-gateway.com/pay/xxx",
    "invoiceId": 12345,
    "amount": 99.00,
    "currency": "SAR"
  }
}
```

**Frontend Action:**
- Redirect user to `paymentUrl`
- Gateway will redirect back after payment
- Check subscription status on return

---

## Response Structure

### Success Response
```json
{
  "success": true,
  "message": "Success message in Arabic",
  "data": { /* actual data */ },
  "errors": [],
  "statusCode": 200
}
```

### Error Response
```json
{
  "success": false,
  "message": "Error message in Arabic",
  "data": null,
  "errors": [
    "Detailed error 1",
    "Detailed error 2"
  ],
  "statusCode": 400
}
```

---

## Error Handling

### 401 - Unauthorized
```json
{
  "success": false,
  "message": "Unauthorized",
  "statusCode": 401
}
```

**Frontend Action:** Redirect to login page, clear stored token

---

### 402 - Payment Required
```json
{
  "success": false,
  "message": "يتطلب الوصول إلى هذه الميزة اشتراك نشط",
  "statusCode": 402
}
```

**Frontend Action:** Show subscription modal/page

---

### 404 - Not Found
```json
{
  "success": false,
  "message": "المورد غير موجود",
  "statusCode": 404
}
```

**Frontend Action:** Show "not found" message

---

### 400 - Validation Error
```json
{
  "success": false,
  "message": "خطأ في البيانات المدخلة",
  "errors": [
    "البريد الإلكتروني مطلوب",
    "كلمة المرور يجب أن تحتوي على 8 أحرف على الأقل"
  ],
  "statusCode": 400
}
```

**Frontend Action:** Show errors under form fields

---

## Integration Notes

### 1. Token Management

```javascript
// Store token after login
localStorage.setItem('authToken', data.token);

// Include in requests
const headers = {
  'Authorization': `Bearer ${localStorage.getItem('authToken')}`,
  'Content-Type': 'application/json'
};

// Clear on logout/401
localStorage.removeItem('authToken');
```

---

### 2. Subscription Status

After login, check `hasActiveSubscription`:

```javascript
if (!loginResponse.data.hasActiveSubscription) {
  // Show subscription required modal
  showSubscriptionModal();
}

if (loginResponse.data.daysRemaining < 7) {
  // Show renewal warning
  showRenewalWarning(loginResponse.data.daysRemaining);
}
```

---

### 3. Handle 402 Responses

```javascript
async function apiCall(url, options) {
  const response = await fetch(url, options);
  const data = await response.json();

  if (response.status === 402) {
    // Show subscription required
    showSubscriptionModal();
    return null;
  }

  if (response.status === 401) {
    // Redirect to login
    redirectToLogin();
    return null;
  }

  return data;
}
```

---

### 4. Date Formatting

All dates are UTC ISO 8601:

```javascript
// Convert to local display
const date = new Date(utcDateString);
const localDate = date.toLocaleDateString('ar-SA');
const localTime = date.toLocaleTimeString('ar-SA');
```

---

### 5. Loading States

For AI operations (takes 5-15 seconds):

```javascript
setLoading(true);
try {
  const result = await generatePerformanceReport(weeklyPlanId);
  // Show success
} catch (error) {
  // Show error
} finally {
  setLoading(false);
}
```

---

### 6. Feature Access Control

```javascript
function canAccessFeature(user) {
  if (user.role === 'Admin') return true;
  if (user.role === 'Employee') return true; // Limited features
  if (user.role === 'Manager' && user.hasActiveSubscription) return true;
  return false;
}
```

---

## Testing Credentials

### Manager (No Subscription)
```
Email: testmanager@example.com
Password: Test1234
```

### Manager (With Subscription)
```
Create new account and complete payment
```

### Employee
```
Create via manager account
```

---

## Background Jobs

These run automatically (no frontend action needed):

| Job | Schedule | Purpose |
|-----|----------|---------|
| Weekly Reports | Sunday 11 PM | Auto-generate weekly reports |
| Monthly Reports | 1st of month 1 AM | Auto-generate monthly reports |
| Subscription Check | Daily 9 AM | Check expirations, deactivate expired |

**Timezone:** Arab Standard Time (UTC+3)

---

## Hangfire Dashboard

**URL:** `http://localhost:5041/hangfire`
**Access:** Development only
**Purpose:** Monitor background jobs

---

## Quick Reference

### Subscription Flow
1. Manager registers → Account active, no subscription
2. Manager can login → See limited dashboard
3. Try to create task → Get 402 error
4. Go to subscription page → Select plan
5. Initiate payment → Redirect to gateway
6. Complete payment → Subscription activated
7. Full access granted

### Weekly Workflow
1. Manager creates annual target → AI generates 48 weeks
2. Manager creates tasks for current week
3. Employees view tasks → Submit reports
4. Week ends → Generate performance report (manual or auto)
5. View AI analysis and insights

### Monthly Workflow
1. Month ends → All 4 weeks completed
2. Generate monthly report (manual or auto)
3. AI re-analyzes all 4 weeks
4. View comprehensive monthly insights

---

## Support & Questions

For API issues or clarifications, contact the backend team.

**API Version:** v1
**Last Updated:** December 4, 2025
**Framework:** ASP.NET Core 8.0
**Database:** SQL Server
**AI:** Google Gemini
