# API Documentation - فريقي (Fariqi)

## 📋 جدول المحتويات

1. [API Response Format](#api-response-format)
2. [Exception Handling](#exception-handling)
3. [Authentication Endpoints](#authentication-endpoints)
4. [Manager Endpoints](#manager-endpoints)
5. [Employee Endpoints](#employee-endpoints)
6. [Admin Endpoints](#admin-endpoints)
7. [Payment Endpoints](#payment-endpoints)
8. [Subscription Endpoints](#subscription-endpoints)

---

## 📦 API Response Format

جميع الـ Endpoints ترجع استجابة موحدة في شكل `ApiResponse<T>`:

### Success Response

```json
{
  "success": true,
  "message": "تمت العملية بنجاح",
  "data": { /* البيانات المطلوبة */ },
  "errors": [],
  "statusCode": 200
}
```

### Error Response

```json
{
  "success": false,
  "message": "رسالة الخطأ بالعربية",
  "data": null,
  "errors": [ /* قائمة الأخطاء (إن وجدت) */ ],
  "statusCode": 400/401/404/500
}
```

---

## ⚠️ Exception Handling

النظام يستخدم **Global Exception Handler** لمعالجة جميع الأخطاء تلقائياً.

### Response Status Codes

- **200 OK**: العملية نجحت
- **400 Bad Request**: بيانات غير صحيحة أو منطق عمل
- **401 Unauthorized**: غير مصرح (Token غير صالح)
- **403 Forbidden**: Role غير كافي
- **404 Not Found**: العنصر غير موجود
- **500 Internal Server Error**: خطأ في الخادم

جميع رسائل الخطأ بالعربية وواضحة للفرونت.

---

---

## 🔐 Authentication Endpoints

**Base URL:** `/api/auth`

### 1. Register - تسجيل مستخدم جديد

**Endpoint:** `POST /api/auth/register`

**الوصف:** تسجيل مستخدم جديد في النظام (Manager, Employee, أو Admin)

**Authentication:** ❌ غير مطلوب

**Request Body:**
```json
{
  "fullName": "أحمد محمد",
  "email": "ahmed@example.com",
  "password": "Password123",
  "role": "Manager",
  "companyName": "شركة التقنية",
  "businessType": "تكنولوجيا المعلومات",
  "businessDescription": "شركة متخصصة في تطوير البرمجيات"
}
```

**Parameters:**
- `fullName` (required): الاسم الكامل
- `email` (required): البريد الإلكتروني
- `password` (required): كلمة المرور (8 أحرف على الأقل)
- `role` (required): الدور (Admin, Manager, Employee)
- `companyName` (optional): اسم الشركة (مطلوب للـ Manager)
- `businessType` (optional): نوع النشاط (مطلوب للـ Manager)
- `businessDescription` (optional): وصف النشاط
- `managerUserId` (optional): معرف المدير (مطلوب للـ Employee)

**Response (200 OK):**
```json
{
  "success": true,
  "message": "تم التسجيل بنجاح",
  "data": {
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "refreshToken": "guid-here",
    "expiresAt": "2025-11-21T12:00:00Z",
    "user": {
      "id": "user-id-123",
      "fullName": "أحمد محمد",
      "email": "ahmed@example.com",
      "role": "Manager"
    }
  },
  "errors": [],
  "statusCode": 200
}
```

**Error Response (400 Bad Request):**
```json
{
  "success": false,
  "message": "المستخدم موجود بالفعل",
  "data": null,
  "errors": [],
  "statusCode": 400
}
```

---

### 2. Login - تسجيل الدخول

**Endpoint:** `POST /api/auth/login`

**الوصف:** تسجيل دخول المستخدم والحصول على JWT Token

**Authentication:** ❌ غير مطلوب

**Request Body:**
```json
{
  "email": "ahmed@example.com",
  "password": "Password123"
}
```

**Response (200 OK):**
```json
{
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "refreshToken": "guid-here",
  "expiresAt": "2025-11-21T12:00:00Z",
  "user": {
    "id": "user-id-123",
    "fullName": "أحمد محمد",
    "email": "ahmed@example.com",
    "role": "Manager"
  }
}
```

**Error Responses:**
- `401 Unauthorized`: البريد الإلكتروني أو كلمة المرور غير صحيحة
- `500 Internal Server Error`: خطأ في الخادم

---

### 3. Validate Token - التحقق من صحة Token

**Endpoint:** `POST /api/auth/validate-token`

**الوصف:** التحقق من صحة JWT Token

**Authentication:** ✅ مطلوب (Bearer Token)

**Headers:**
```
Authorization: Bearer {token}
```

**Response (200 OK):**
```json
{
  "valid": true
}
```

**Error Responses:**
- `401 Unauthorized`: Token غير صالح أو منتهي الصلاحية
- `500 Internal Server Error`: خطأ في الخادم

---

## 👔 Manager Endpoints

**Base URL:** `/api/manager`

**Authentication:** ✅ مطلوب (Manager أو Admin)

**Headers:**
```
Authorization: Bearer {token}
```

---

### Annual Targets - الأهداف السنوية

#### 1. Create Annual Target - إنشاء هدف سنوي

**Endpoint:** `POST /api/manager/annual-targets`

**الوصف:** إنشاء هدف سنوي جديد. النظام يستدعي Gemini AI تلقائياً لتوليد خطة كاملة (12 شهر × 4 أسابيع = 48 أسبوع)

**Request Body:**
```json
{
  "year": 2026,
  "targetDescription": "زيادة مبيعاتنا بنسبة 40% خلال العام 2026 من خلال توسيع السوق المحلية وإطلاق منتج جديد"
}
```

**ما يحدث بالضبط:**
1. النظام يحفظ الهدف السنوي
2. يستدعي Gemini AI مع الهدف بالعربية
3. Gemini AI يولد 12 خطة شهرية
4. كل شهر يحتوي على 4 أسابيع (48 أسبوع إجمالي)
5. النظام يحسب تواريخ الأسابيع بدقة (WeekStartDate, WeekEndDate)
6. يحفظ كل شيء في قاعدة البيانات

**Response (200 OK):**
```json
{
  "id": 1,
  "year": 2026,
  "targetDescription": "زيادة مبيعاتنا بنسبة 40%...",
  "createdAt": "2025-11-20T10:00:00Z",
  "monthlyPlans": [
    {
      "id": 1,
      "month": 1,
      "monthlyGoal": "تحليل السوق المحلية وتحديد الفرص",
      "weeklyPlans": [
        {
          "id": 1,
          "weekNumber": 1,
          "weeklyGoal": "إجراء دراسة السوق الأساسية",
          "weekStartDate": "2026-01-01T00:00:00Z",
          "weekEndDate": "2026-01-07T23:59:59Z",
          "achievementPercentage": null
        }
        // ... 3 أسابيع أخرى
      ]
    }
    // ... 11 شهر آخر
  ]
}
```

**Error Responses:**
- `400 Bad Request`: الهدف للعام موجود بالفعل أو بيانات غير صحيحة
- `500 Internal Server Error`: خطأ في Gemini AI أو الخادم

---

#### 2. Get Annual Target by Year - الحصول على هدف سنوي

**Endpoint:** `GET /api/manager/annual-targets/{year}`

**الوصف:** الحصول على الهدف السنوي لعام محدد مع جميع الخطط الشهرية والأسبوعية

**Parameters:**
- `year` (path): السنة (مثال: 2026)

**Response (200 OK):**
```json
{
  "id": 1,
  "year": 2026,
  "targetDescription": "زيادة مبيعاتنا بنسبة 40%...",
  "createdAt": "2025-11-20T10:00:00Z",
  "monthlyPlans": [ /* ... */ ]
}
```

**Error Responses:**
- `404 Not Found`: الهدف للعام غير موجود
- `500 Internal Server Error`: خطأ في الخادم

---

#### 3. Get All Annual Targets - جميع الأهداف السنوية

**Endpoint:** `GET /api/manager/annual-targets`

**الوصف:** الحصول على جميع الأهداف السنوية للمدير مرتبة حسب السنة (الأحدث أولاً)

**Response (200 OK):**
```json
[
  {
    "id": 2,
    "year": 2027,
    "targetDescription": "...",
    "createdAt": "2025-11-20T10:00:00Z",
    "monthlyPlans": [ /* ... */ ]
  },
  {
    "id": 1,
    "year": 2026,
    "targetDescription": "...",
    "createdAt": "2025-11-20T10:00:00Z",
    "monthlyPlans": [ /* ... */ ]
  }
]
```

---

### Dashboard - لوحة التحكم

#### 4. Get Manager Dashboard - لوحة تحكم المدير

**Endpoint:** `GET /api/manager/dashboard`

**الوصف:** الحصول على بيانات Dashboard للمدير (الشهر الحالي، 4 أسابيع، إحصائيات)

**Response (200 OK):**
```json
{
  "currentYear": 2026,
  "currentMonth": 1,
  "currentWeek": 2,
  "currentWeekInfo": {
    "weekNumber": 2,
    "weekStartDate": "2026-01-08T00:00:00Z",
    "weekEndDate": "2026-01-14T23:59:59Z",
    "achievementPercentage": 75.5,
    "isCurrentWeek": true,
    "tasksCount": 15,
    "completedTasksCount": 11,
    "reportsCount": 8
  },
  "monthWeeks": [
    {
      "weekNumber": 1,
      "weekStartDate": "2026-01-01T00:00:00Z",
      "weekEndDate": "2026-01-07T23:59:59Z",
      "achievementPercentage": 80.0,
      "isCurrentWeek": false,
      "tasksCount": 12,
      "completedTasksCount": 10,
      "reportsCount": 9
    },
    {
      "weekNumber": 2,
      "weekStartDate": "2026-01-08T00:00:00Z",
      "weekEndDate": "2026-01-14T23:59:59Z",
      "achievementPercentage": 75.5,
      "isCurrentWeek": true,
      "tasksCount": 15,
      "completedTasksCount": 11,
      "reportsCount": 8
    }
    // ... أسبوعين آخرين
  ],
  "totalEmployees": 25,
  "activeSubscriptions": 1,
  "companyName": "شركة التقنية",
  "currentAnnualTarget": {
    "id": 1,
    "year": 2026,
    "targetDescription": "زيادة مبيعاتنا بنسبة 40%..."
  }
}
```

---

### Tasks - المهام

#### 5. Create Task - إنشاء مهمة

**Endpoint:** `POST /api/manager/tasks`

**الوصف:** إنشاء مهمة أسبوعية جديدة (فردية أو جماعية)

**Request Body:**
```json
{
  "title": "تحليل السوق المحلية",
  "description": "تحليل احتياجات السوق المحلية للمنتج الجديد",
  "deadline": "2026-01-07T23:59:59Z",
  "year": 2026,
  "month": 1,
  "weekNumber": 1,
  "assignedToEmployeeId": 5
}
```

**Parameters:**
- `title` (required): عنوان المهمة
- `description` (optional): وصف المهمة
- `deadline` (optional): تاريخ الاستحقاق
- `year` (required): السنة
- `month` (required): الشهر (1-12)
- `weekNumber` (required): رقم الأسبوع (1-4)
- `assignedToEmployeeId` (optional): معرف الموظف (null للمهام الجماعية)

**Response (200 OK):**
```json
{
  "id": 1,
  "title": "تحليل السوق المحلية",
  "description": "تحليل احتياجات السوق المحلية للمنتج الجديد",
  "createdAt": "2025-11-20T10:00:00Z",
  "deadline": "2026-01-07T23:59:59Z",
  "year": 2026,
  "month": 1,
  "weekNumber": 1,
  "assignedToEmployeeId": 5,
  "assignedToEmployeeName": "محمد أحمد",
  "isCompleted": false,
  "completedAt": null,
  "reportsCount": 0
}
```

**Error Responses:**
- `400 Bad Request`: الموظف غير موجود أو غير مخصص لهذا المدير
- `500 Internal Server Error`: خطأ في الخادم

---

#### 6. Get Tasks by Week - المهام حسب الأسبوع

**Endpoint:** `GET /api/manager/tasks?year=2026&month=1&weekNumber=1`

**الوصف:** الحصول على جميع المهام لأسبوع محدد

**Query Parameters:**
- `year` (required): السنة
- `month` (required): الشهر (1-12)
- `weekNumber` (required): رقم الأسبوع (1-4)

**Response (200 OK):**
```json
[
  {
    "id": 1,
    "title": "تحليل السوق المحلية",
    "description": "...",
    "createdAt": "2025-11-20T10:00:00Z",
    "deadline": "2026-01-07T23:59:59Z",
    "year": 2026,
    "month": 1,
    "weekNumber": 1,
    "assignedToEmployeeId": 5,
    "assignedToEmployeeName": "محمد أحمد",
    "isCompleted": false,
    "reportsCount": 2
  }
  // ... مهام أخرى
]
```

---

#### 7. Delete Task - حذف مهمة

**Endpoint:** `DELETE /api/manager/tasks/{taskId}`

**الوصف:** حذف مهمة (فقط المدير الذي أنشأها)

**Parameters:**
- `taskId` (path): معرف المهمة

**Response (204 No Content):** نجاح

**Error Responses:**
- `404 Not Found`: المهمة غير موجودة
- `500 Internal Server Error`: خطأ في الخادم

---

### Reports - التقارير

#### 8. Get Reports by Week - التقارير حسب الأسبوع

**Endpoint:** `GET /api/manager/reports?year=2026&month=1&weekNumber=1`

**الوصف:** الحصول على جميع تقارير الموظفين لأسبوع محدد

**Query Parameters:**
- `year` (required): السنة
- `month` (required): الشهر (1-12)
- `weekNumber` (required): رقم الأسبوع (1-4)

**Response (200 OK):**
```json
[
  {
    "id": 1,
    "taskItemId": 1,
    "taskTitle": "تحليل السوق المحلية",
    "employeeId": 5,
    "employeeName": "محمد أحمد",
    "reportText": "تم إكمال تحليل السوق المحلية. النتائج: 60% من العملاء مهتمون بالمنتج الجديد.",
    "submittedAt": "2026-01-05T14:30:00Z"
  }
  // ... تقارير أخرى
]
```

---

### Performance Reports - تقارير الأداء

#### 9. Get Performance Report - الحصول على تقرير الأداء

**Endpoint:** `GET /api/manager/performance-reports/{weeklyPlanId}`

**الوصف:** الحصول على تقرير الأداء الأسبوعي (إذا كان موجوداً)

**Parameters:**
- `weeklyPlanId` (path): معرف الخطة الأسبوعية

**Response (200 OK):**
```json
{
  "id": 1,
  "weeklyPlanId": 1,
  "weekNumber": 1,
  "weekStartDate": "2026-01-01T00:00:00Z",
  "weekEndDate": "2026-01-07T23:59:59Z",
  "achievementPercentage": 75.5,
  "summary": "أظهر الفريق أداءً جيداً هذا الأسبوع مع إنجاز 75.5% من الأهداف المخطط لها...",
  "strengths": [
    "التزام الموظفين بالمواعيد النهائية",
    "جودة التقارير المقدمة"
  ],
  "weaknesses": [
    "بعض المهام تأخرت في الإنجاز",
    "الحاجة لتحسين التواصل بين الفريق"
  ],
  "recommendations": [
    "توزيع المهام بشكل أكثر توازناً",
    "عقد اجتماعات أسبوعية للتواصل"
  ],
  "generatedAt": "2026-01-08T00:00:00Z"
}
```

**Error Responses:**
- `404 Not Found`: التقرير غير موجود
- `500 Internal Server Error`: خطأ في الخادم

---

#### 10. Generate Performance Report - توليد تقرير الأداء

**Endpoint:** `POST /api/manager/performance-reports/{weeklyPlanId}/generate`

**الوصف:** توليد تقرير أداء أسبوعي جديد باستخدام Gemini AI. يجمع جميع تقارير الموظفين ويحللها

**ما يحدث بالضبط:**
1. النظام يجمع جميع تقارير الموظفين للأسبوع
2. يجمع بيانات المهام (المكتملة وغير المكتملة)
3. يرسل كل البيانات إلى Gemini AI
4. Gemini AI يحلل الأداء ويولد:
   - نسبة الإنجاز (0-100%)
   - ملخص شامل بالعربية
   - نقاط القوة
   - نقاط الضعف
   - توصيات للتحسين
5. يحفظ التقرير في قاعدة البيانات

**Parameters:**
- `weeklyPlanId` (path): معرف الخطة الأسبوعية

**Response (200 OK):**
```json
{
  "id": 1,
  "weeklyPlanId": 1,
  "achievementPercentage": 75.5,
  "summary": "...",
  "strengths": [ /* ... */ ],
  "weaknesses": [ /* ... */ ],
  "recommendations": [ /* ... */ ],
  "generatedAt": "2026-01-08T00:00:00Z"
}
```

**Error Responses:**
- `400 Bad Request`: الخطة الأسبوعية غير موجودة
- `500 Internal Server Error`: خطأ في Gemini AI أو الخادم

---

#### 11. Get Performance Reports by Year - تقارير الأداء للعام

**Endpoint:** `GET /api/manager/performance-reports?year=2026`

**الوصف:** الحصول على جميع تقارير الأداء لعام محدد

**Query Parameters:**
- `year` (required): السنة

**Response (200 OK):**
```json
[
  {
    "id": 1,
    "weeklyPlanId": 1,
    "weekNumber": 1,
    "achievementPercentage": 75.5,
    "summary": "...",
    "generatedAt": "2026-01-08T00:00:00Z"
  }
  // ... تقارير أخرى
]
```

---

## 👤 Employee Endpoints

**Base URL:** `/api/employee`

**Authentication:** ✅ مطلوب (Employee, Manager, أو Admin)

**Headers:**
```
Authorization: Bearer {token}
```

---

### Tasks - المهام

#### 12. Get My Tasks - المهام المخصصة لي

**Endpoint:** `GET /api/employee/tasks`

**الوصف:** الحصول على جميع المهام المخصصة للموظف

**Response (200 OK):**
```json
[
  {
    "id": 1,
    "title": "تحليل السوق المحلية",
    "description": "...",
    "createdAt": "2025-11-20T10:00:00Z",
    "deadline": "2026-01-07T23:59:59Z",
    "year": 2026,
    "month": 1,
    "weekNumber": 1,
    "assignedToEmployeeId": 5,
    "isCompleted": false,
    "completedAt": null,
    "reportsCount": 2
  }
  // ... مهام أخرى
]
```

---

#### 13. Complete Task - إكمال مهمة

**Endpoint:** `PUT /api/employee/tasks/{taskId}/complete`

**الوصف:** تحديث حالة المهمة إلى "مكتملة"

**Parameters:**
- `taskId` (path): معرف المهمة

**Response (200 OK):**
```json
{
  "id": 1,
  "title": "تحليل السوق المحلية",
  "isCompleted": true,
  "completedAt": "2026-01-05T14:30:00Z"
  // ... باقي البيانات
}
```

---

#### 14. Mark Task Incomplete - إلغاء إكمال مهمة

**Endpoint:** `PUT /api/employee/tasks/{taskId}/incomplete`

**الوصف:** تحديث حالة المهمة إلى "غير مكتملة"

**Parameters:**
- `taskId` (path): معرف المهمة

**Response (200 OK):**
```json
{
  "id": 1,
  "title": "تحليل السوق المحلية",
  "isCompleted": false,
  "completedAt": null
  // ... باقي البيانات
}
```

---

### Reports - التقارير

#### 15. Create Task Report - إنشاء تقرير للمهمة

**Endpoint:** `POST /api/employee/reports`

**الوصف:** إنشاء تقرير عن مهمة معينة

**Request Body:**
```json
{
  "taskItemId": 1,
  "reportText": "تم إكمال تحليل السوق المحلية. النتائج: 60% من العملاء مهتمون بالمنتج الجديد. تم تحديد 3 فرص رئيسية للتوسع."
}
```

**Parameters:**
- `taskItemId` (required): معرف المهمة
- `reportText` (required): نص التقرير (بالعربية)

**Response (200 OK):**
```json
{
  "id": 1,
  "taskItemId": 1,
  "taskTitle": "تحليل السوق المحلية",
  "employeeId": 5,
  "employeeName": "محمد أحمد",
  "reportText": "تم إكمال تحليل السوق المحلية...",
  "submittedAt": "2026-01-05T14:30:00Z"
}
```

**Error Responses:**
- `400 Bad Request`: المهمة غير موجودة
- `401 Unauthorized`: الموظف غير مخصص لهذه المهمة
- `500 Internal Server Error`: خطأ في الخادم

---

#### 16. Get Task Reports - تقارير المهمة

**Endpoint:** `GET /api/employee/tasks/{taskId}/reports`

**الوصف:** الحصول على جميع التقارير لمهمة معينة

**Parameters:**
- `taskId` (path): معرف المهمة

**Response (200 OK):**
```json
[
  {
    "id": 1,
    "taskItemId": 1,
    "taskTitle": "تحليل السوق المحلية",
    "employeeId": 5,
    "employeeName": "محمد أحمد",
    "reportText": "...",
    "submittedAt": "2026-01-05T14:30:00Z"
  }
  // ... تقارير أخرى
]
```

---

## 👨‍💼 Admin Endpoints

**Base URL:** `/api/admin`

**Authentication:** ✅ مطلوب (Admin فقط)

**Headers:**
```
Authorization: Bearer {token}
```

---

### Statistics - الإحصائيات

#### 17. Get Subscription Statistics - إحصائيات الاشتراكات

**Endpoint:** `GET /api/admin/subscriptions/stats`

**الوصف:** الحصول على إحصائيات شاملة عن الاشتراكات

**Response (200 OK):**
```json
{
  "totalSubscriptions": 150,
  "activeSubscriptions": 120,
  "totalManagers": 120,
  "totalEmployees": 2500,
  "totalUsers": 2620,
  "planStatistics": [
    {
      "planName": "Basic",
      "count": 80
    },
    {
      "planName": "Pro",
      "count": 40
    }
  ]
}
```

---

#### 18. Get Revenue Statistics - إحصائيات الإيرادات

**Endpoint:** `GET /api/admin/revenue/stats`

**الوصف:** الحصول على إحصائيات الإيرادات

**Response (200 OK):**
```json
{
  "totalRevenue": 50000.00,
  "monthlyRevenue": 5000.00,
  "paymentStatistics": [
    {
      "status": "Completed",
      "count": 200,
      "totalAmount": 50000.00
    },
    {
      "status": "Pending",
      "count": 10,
      "totalAmount": 500.00
    },
    {
      "status": "Failed",
      "count": 5,
      "totalAmount": 250.00
    }
  ]
}
```

---

### User Activity - نشاط المستخدمين

#### 19. Get User Activity - نشاط المستخدمين

**Endpoint:** `GET /api/admin/activity?page=1&pageSize=50`

**الوصف:** الحصول على سجل نشاط المستخدمين (مع Pagination)

**Query Parameters:**
- `page` (optional): رقم الصفحة (افتراضي: 1)
- `pageSize` (optional): عدد العناصر في الصفحة (افتراضي: 50)

**Response (200 OK):**
```json
{
  "activities": [
    {
      "id": 1,
      "userName": "أحمد محمد",
      "userEmail": "ahmed@example.com",
      "actionType": "Login",
      "description": "User logged in",
      "timestamp": "2025-11-20T10:00:00Z"
    }
    // ... أنشطة أخرى
  ],
  "totalCount": 5000,
  "page": 1,
  "pageSize": 50,
  "totalPages": 100
}
```

---

### Subscriptions Management - إدارة الاشتراكات

#### 20. Get All Subscriptions - جميع الاشتراكات

**Endpoint:** `GET /api/admin/subscriptions?page=1&pageSize=50&isActive=true`

**الوصف:** الحصول على جميع الاشتراكات (مع Pagination و Filtering)

**Query Parameters:**
- `page` (optional): رقم الصفحة (افتراضي: 1)
- `pageSize` (optional): عدد العناصر في الصفحة (افتراضي: 50)
- `isActive` (optional): فلتر حسب الحالة (true/false/null للكل)

**Response (200 OK):**
```json
{
  "subscriptions": [
    {
      "id": 1,
      "managerName": "أحمد محمد",
      "managerEmail": "ahmed@example.com",
      "companyName": "شركة التقنية",
      "planName": "Basic",
      "planPrice": 50.00,
      "maxEmployees": 30,
      "isActive": true,
      "startDate": "2025-11-01T00:00:00Z",
      "endDate": "2025-12-01T00:00:00Z",
      "autoRenew": true
    }
    // ... اشتراكات أخرى
  ],
  "totalCount": 150,
  "page": 1,
  "pageSize": 50,
  "totalPages": 3
}
```

---

### Payments Management - إدارة المدفوعات

#### 21. Get All Payments - جميع المدفوعات

**Endpoint:** `GET /api/admin/payments?page=1&pageSize=50&status=Completed`

**الوصف:** الحصول على جميع المدفوعات (مع Pagination و Filtering)

**Query Parameters:**
- `page` (optional): رقم الصفحة (افتراضي: 1)
- `pageSize` (optional): عدد العناصر في الصفحة (افتراضي: 50)
- `status` (optional): فلتر حسب الحالة (Completed, Pending, Failed, Refunded)

**Response (200 OK):**
```json
{
  "payments": [
    {
      "id": 1,
      "transactionId": "pay_1234567890",
      "managerName": "أحمد محمد",
      "managerEmail": "ahmed@example.com",
      "amount": 50.00,
      "currency": "SAR",
      "status": "Completed",
      "paymentMethod": "myfatoorah",
      "paidAt": "2025-11-20T10:00:00Z"
    }
    // ... مدفوعات أخرى
  ],
  "totalCount": 200,
  "page": 1,
  "pageSize": 50,
  "totalPages": 4
}
```

---

## 💳 Payment Endpoints

**Base URL:** `/api/payment`

---

### Stripe Payment

#### 22. Create Stripe Payment Intent - إنشاء Stripe Payment Intent

**Endpoint:** `POST /api/payment/stripe/create-intent`

**الوصف:** إنشاء Payment Intent في Stripe لبدء عملية الدفع

**Authentication:** ✅ مطلوب (Manager أو Admin)

**Request Body:**
```json
{
  "subscriptionId": 1,
  "amount": 50.00,
  "currency": "USD",
  "paymentMethod": "stripe",
  "description": "Monthly subscription payment"
}
```

**Response (200 OK):**
```json
{
  "clientSecret": "pi_1234567890_secret_...",
  "paymentIntentId": "pi_1234567890",
  "transactionId": "pi_1234567890"
}
```

**ما يحدث:**
1. إنشاء Payment Intent في Stripe
2. حفظ سجل الدفعة في قاعدة البيانات (Status: "Pending")
3. إرجاع `clientSecret` للاستخدام في Frontend مع Stripe.js

---

#### 23. Stripe Webhook - معالجة Stripe Webhook

**Endpoint:** `POST /api/payment/stripe/webhook`

**الوصف:** معالجة Webhook من Stripe (يتم استدعاؤه تلقائياً من Stripe)

**Authentication:** ❌ غير مطلوب (Stripe يرسل Webhook)

**Headers:**
```
Stripe-Signature: t=1234567890,v1=...
```

**ما يحدث:**
- عند `payment_intent.succeeded`: تفعيل الاشتراك تلقائياً
- عند `payment_intent.payment_failed`: تحديث حالة الدفعة إلى "Failed"
- عند `charge.refunded`: تحديث حالة الدفعة إلى "Refunded"

**Response (200 OK):**
```json
{
  "received": true
}
```

---

### My Fatoorah Payment

#### 24. Initiate My Fatoorah Payment - بدء دفع My Fatoorah

**Endpoint:** `POST /api/payment/myfatoorah/initiate`

**الوصف:** بدء عملية دفع My Fatoorah (للمنطقة العربية)

**Authentication:** ✅ مطلوب (Manager أو Admin)

**Request Body:**
```json
{
  "subscriptionId": 1,
  "amount": 50.00,
  "currency": "SAR",
  "paymentMethod": "myfatoorah",
  "description": "Monthly subscription payment"
}
```

**Response (200 OK):**
```json
{
  "paymentUrl": "https://apitest.myfatoorah.com/paypage?id=abc123",
  "invoiceId": "12345678",
  "invoiceRef": "SUB-20250101-ABCD"
}
```

**ما يحدث:**
1. إنشاء Invoice في My Fatoorah
2. حفظ سجل الدفعة في قاعدة البيانات (Status: "Pending")
3. إرجاع `paymentUrl` لتوجيه المستخدم إليه

---

#### 25. My Fatoorah Callback - معالجة My Fatoorah Callback

**Endpoint:** `GET /api/payment/myfatoorah/callback?paymentId=xxx&invoiceId=12345`

**الوصف:** معالجة Callback من My Fatoorah بعد الدفع

**Authentication:** ❌ غير مطلوب (My Fatoorah يرسل Callback)

**Query Parameters:**
- `invoiceId` (required): معرف الفاتورة
- `paymentId` (optional): معرف الدفعة

**ما يحدث:**
1. التحقق من حالة الدفع مع My Fatoorah API
2. إذا كان الدفع ناجحاً: تفعيل الاشتراك تلقائياً
3. توجيه المستخدم إلى صفحة النجاح أو الفشل

**Response:** Redirect إلى `/payment/success` أو `/payment/failed`

---

### Payment Management

#### 26. Get Payment by Transaction ID - الحصول على دفعة

**Endpoint:** `GET /api/payment/{transactionId}`

**الوصف:** الحصول على تفاصيل دفعة معينة

**Authentication:** ✅ مطلوب (Manager أو Admin)

**Parameters:**
- `transactionId` (path): معرف المعاملة

**Response (200 OK):**
```json
{
  "id": 1,
  "subscriptionId": 1,
  "amount": 50.00,
  "currency": "SAR",
  "status": "Completed",
  "transactionId": "12345678",
  "paymentMethod": "myfatoorah",
  "paidAt": "2025-11-20T10:00:00Z"
}
```

---

#### 27. Get Manager Payments - مدفوعات المدير

**Endpoint:** `GET /api/payment/manager/payments`

**الوصف:** الحصول على جميع مدفوعات المدير

**Authentication:** ✅ مطلوب (Manager أو Admin)

**Response (200 OK):**
```json
[
  {
    "id": 1,
    "subscriptionId": 1,
    "amount": 50.00,
    "currency": "SAR",
    "status": "Completed",
    "transactionId": "12345678",
    "paymentMethod": "myfatoorah",
    "paidAt": "2025-11-20T10:00:00Z"
  }
  // ... مدفوعات أخرى
]
```

---

#### 28. Verify Payment Status - التحقق من حالة الدفعة

**Endpoint:** `POST /api/payment/verify/{transactionId}`

**الوصف:** التحقق من حالة الدفعة مع Payment Gateway

**Authentication:** ✅ مطلوب (Manager أو Admin)

**Parameters:**
- `transactionId` (path): معرف المعاملة

**Response (200 OK):**
```json
{
  "verified": true,
  "message": "Payment verified successfully"
}
```

**Error Responses:**
- `400 Bad Request`: الدفعة غير موجودة أو فشل التحقق

---

## 📦 Subscription Endpoints

**Base URL:** `/api/subscription`

**Authentication:** ✅ مطلوب (Manager أو Admin)

**Headers:**
```
Authorization: Bearer {token}
```

---

#### 29. Get Available Plans - الخطط المتاحة

**Endpoint:** `GET /api/subscription/plans`

**الوصف:** الحصول على جميع خطط الاشتراك المتاحة

**Authentication:** ❌ غير مطلوب (عام)

**Response (200 OK):**
```json
[
  {
    "id": 1,
    "name": "Basic",
    "pricePerMonth": 50.00,
    "maxEmployees": 30,
    "description": "حتى 30 موظف - جميع المميزات الأساسية"
  },
  {
    "id": 2,
    "name": "Pro",
    "pricePerMonth": 100.00,
    "maxEmployees": 100,
    "description": "حتى 100 موظف - تقارير متقدمة ودعم أولوية"
  }
]
```

---

#### 30. Create Subscription - إنشاء اشتراك

**Endpoint:** `POST /api/subscription/create`

**الوصف:** إنشاء اشتراك جديد (سيتم تفعيله بعد الدفع)

**Request Body:**
```json
{
  "subscriptionPlanId": 1
}
```

**Response (200 OK):**
```json
{
  "id": 1,
  "managerId": 1,
  "subscriptionPlanId": 1,
  "planName": "Basic",
  "planPrice": 50.00,
  "maxEmployees": 30,
  "startDate": "2025-11-20T10:00:00Z",
  "endDate": "2025-12-20T10:00:00Z",
  "isActive": false,
  "autoRenew": true
}
```

**ملاحظة:** الاشتراك يُنشأ بحالة `isActive: false` وسيتم تفعيله تلقائياً بعد الدفع الناجح.

---

#### 31. Get Active Subscription - الاشتراك النشط

**Endpoint:** `GET /api/subscription/active`

**الوصف:** الحصول على الاشتراك النشط للمدير

**Response (200 OK):**
```json
{
  "id": 1,
  "managerId": 1,
  "subscriptionPlanId": 1,
  "planName": "Basic",
  "planPrice": 50.00,
  "maxEmployees": 30,
  "startDate": "2025-11-20T10:00:00Z",
  "endDate": "2025-12-20T10:00:00Z",
  "isActive": true,
  "autoRenew": true
}
```

**Error Responses:**
- `404 Not Found`: لا يوجد اشتراك نشط

---

#### 32. Upgrade Subscription - ترقية الاشتراك

**Endpoint:** `POST /api/subscription/upgrade`

**الوصف:** ترقية الاشتراك إلى خطة أعلى

**Request Body:**
```json
{
  "newPlanId": 2
}
```

**ما يحدث:**
1. فحص عدد الموظفين الحالي
2. إذا كان العدد أكبر من حد الخطة الجديدة → خطأ
3. إذا كان العدد أقل أو مساوي → تحديث الاشتراك

**Response (200 OK):**
```json
{
  "id": 1,
  "subscriptionPlanId": 2,
  "planName": "Pro",
  "planPrice": 100.00,
  "maxEmployees": 100,
  "isActive": true
}
```

**Error Responses:**
- `400 Bad Request`: لا يمكن الترقية (عدد الموظفين أكبر من الحد الجديد)

---

#### 33. Cancel Subscription - إلغاء الاشتراك

**Endpoint:** `POST /api/subscription/cancel`

**الوصف:** إلغاء الاشتراك (إيقاف التجديد التلقائي)

**Response (200 OK):**
```json
{
  "message": "Subscription cancelled successfully"
}
```

**ما يحدث:**
- تحديث `AutoRenew = false`
- تحديث `IsActive = false`
- تحديد `SubscriptionEndsAt = الآن`

---

#### 34. Check Employee Limit - فحص حد الموظفين

**Endpoint:** `POST /api/subscription/check-employee-limit`

**الوصف:** فحص إذا كان يمكن إضافة عدد معين من الموظفين

**Request Body:**
```json
{
  "requestedCount": 5
}
```

**Response (200 OK):**
```json
{
  "allowed": true
}
```

**ما يحدث:**
- فحص عدد الموظفين الحالي
- فحص حد الاشتراك
- إرجاع `true` إذا كان `currentCount + requestedCount <= maxEmployees`

---

## 🔒 Authentication & Authorization

### JWT Token Structure

جميع الـ Endpoints (ما عدا Register, Login, Webhooks) تحتاج JWT Token في Header:

```
Authorization: Bearer {token}
```

### Token Claims

الـ Token يحتوي على:
- `NameIdentifier`: User ID
- `Name`: Full Name
- `Email`: Email Address
- `Role`: User Role (Admin, Manager, Employee)

### Role-Based Access

- **Admin:** يمكنه الوصول لجميع الـ Endpoints
- **Manager:** يمكنه الوصول لـ Manager و Employee و Payment و Subscription Endpoints
- **Employee:** يمكنه الوصول لـ Employee Endpoints فقط

---

## 📊 Response Status Codes

- `200 OK`: نجاح العملية
- `201 Created`: تم إنشاء العنصر بنجاح
- `204 No Content`: نجاح بدون محتوى (مثل Delete)
- `400 Bad Request`: بيانات غير صحيحة
- `401 Unauthorized`: غير مصرح (Token غير صالح)
- `403 Forbidden`: غير مصرح (Role غير كافي)
- `404 Not Found`: العنصر غير موجود
- `500 Internal Server Error`: خطأ في الخادم

---

## 🚀 Base URL

**Development:**
```
https://localhost:5001
http://localhost:5000
```

**Production:**
```
https://api.fariqi.com
```

---

## 📝 ملاحظات مهمة

1. **جميع التواريخ:** بصيغة UTC (ISO 8601)
2. **اللغة:** جميع النصوص بالعربية
3. **Pagination:** جميع قوائم البيانات تدعم Pagination
4. **Error Handling:** جميع الأخطاء تُرجع رسالة واضحة بالعربية
5. **Rate Limiting:** (سيتم إضافته لاحقاً)

---

## ✅ الحالة

**جميع الـ Endpoints جاهزة ومُختبرة ✅**

**المشروع 100% جاهز للاستخدام! 🎉**

