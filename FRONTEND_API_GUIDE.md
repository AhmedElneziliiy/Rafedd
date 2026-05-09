# دليل API للمطورين - Frontend Integration Guide

## 📋 نظرة عامة

هذا الدليل يحتوي على جميع الـ APIs المتاحة للفرونت إند مع أمثلة كاملة للطلبات والاستجابات.

**Base URL:** `https://your-api-domain.com/api`

**Response Format:** جميع الـ APIs تستخدم `ApiResponse<T>` wrapper موحد:

```typescript
interface ApiResponse<T> {
  success: boolean;
  message: string;
  data?: T;
  errors?: string[];
  statusCode: number;
}
```

---

## 🔐 Authentication APIs

### 1. تسجيل دخول (Login)

**Endpoint:** `POST /api/auth/login`

**Headers:** لا يحتاج

**Request Body:**
```json
{
  "email": "admin@rafeed.com",
  "password": "admin123"
}
```

**Response (200 OK):**
```json
{
  "success": true,
  "message": "تم تسجيل الدخول بنجاح",
  "data": {
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "refreshToken": "refresh_token_here",
    "userId": "user_id_here",
    "email": "admin@rafeed.com",
    "fullName": "Super Admin",
    "role": "Admin",
    "expiresIn": 3600
  },
  "statusCode": 200
}
```

**Error Response (401):**
```json
{
  "success": false,
  "message": "البريد الإلكتروني أو كلمة المرور غير صحيحة",
  "statusCode": 401
}
```

---

### 2. تسجيل Manager (Register Manager)

**Endpoint:** `POST /api/auth/register/manager`

**Headers:** لا يحتاج

**Request Body:**
```json
{
  "fullName": "أحمد المدير",
  "email": "ahmed.manager@example.com",
  "password": "SecurePassword123!",
  "companyName": "شركة التقنية",
  "businessType": "تكنولوجيا المعلومات",
  "businessDescription": "شركة متخصصة في تطوير البرمجيات",
  "subscriptionPlanId": 1
}
```

**Response (200 OK):**
```json
{
  "success": true,
  "message": "تم تسجيل المدير بنجاح وتم إنشاء الاشتراك",
  "data": {
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "userId": "user_id_here",
    "email": "ahmed.manager@example.com",
    "fullName": "أحمد المدير",
    "role": "Manager"
  },
  "statusCode": 200
}
```

---

### 3. تسجيل Employee (Register Employee)

**Endpoint:** `POST /api/auth/register/employee`

**Headers:** 
```
Authorization: Bearer {ManagerToken}
```

**Request Body:**
```json
{
  "fullName": "سارة أحمد",
  "email": "sara@example.com",
  "password": "SecurePassword123!",
  "position": "مطور برمجيات"
}
```

**Response (200 OK):**
```json
{
  "success": true,
  "message": "تم تسجيل الموظف بنجاح",
  "data": {
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "userId": "user_id_here",
    "email": "sara@example.com",
    "fullName": "سارة أحمد",
    "role": "Employee"
  },
  "statusCode": 200
}
```

**Error Response (403):**
```json
{
  "success": false,
  "message": "تم الوصول إلى الحد الأقصى لعدد الموظفين في خطة الاشتراك الخاصة بك",
  "statusCode": 403
}
```

---

### 4. التحقق من Token (Validate Token)

**Endpoint:** `POST /api/auth/validate-token`

**Headers:**
```
Authorization: Bearer {Token}
```

**Response (200 OK):**
```json
{
  "success": true,
  "message": "Token صالح",
  "data": null,
  "statusCode": 200
}
```

---

## 👨‍💼 Manager APIs

**Base Route:** `/api/manager`

**Headers المطلوبة:**
```
Authorization: Bearer {ManagerToken}
```

### 1. إنشاء هدف سنوي (Create Annual Target)

**Endpoint:** `POST /api/manager/annual-targets`

**Request Body:**
```json
{
  "year": 2025,
  "targetDescription": "زيادة المبيعات بنسبة 50% وتحسين جودة المنتجات"
}
```

**Response (200 OK):**
```json
{
  "success": true,
  "message": "تم إنشاء الهدف السنوي بنجاح. تم توليد الخطة الكاملة (48 أسبوع) باستخدام Gemini AI",
  "data": {
    "id": 1,
    "year": 2025,
    "targetDescription": "زيادة المبيعات بنسبة 50%...",
    "monthlyPlans": [
      {
        "id": 1,
        "month": 1,
        "monthDescription": "بداية العام - التركيز على التخطيط...",
        "weeklyPlans": [
          {
            "id": 1,
            "weekNumber": 1,
            "weekDescription": "الأسبوع الأول - إعداد الخطط...",
            "tasks": []
          }
        ]
      }
    ]
  },
  "statusCode": 200
}
```

---

### 2. الحصول على لوحة التحكم (Dashboard)

**Endpoint:** `GET /api/manager/dashboard`

**Response (200 OK):**
```json
{
  "success": true,
  "message": "تم الحصول على لوحة التحكم بنجاح",
  "data": {
    "totalEmployees": 24,
    "activeEmployees": 22,
    "completedTasks": 156,
    "pendingTasks": 12,
    "totalReports": 87,
    "performancePercentage": 87.5,
    "recentReports": [],
    "upcomingDeadlines": []
  },
  "statusCode": 200
}
```

---

### 3. إنشاء مهمة (Create Task)

**Endpoint:** `POST /api/manager/tasks`

**Request Body:**
```json
{
  "employeeUserId": "employee_user_id",
  "title": "تطوير ميزة جديدة",
  "description": "تطوير ميزة إدارة المستخدمين",
  "year": 2025,
  "month": 1,
  "weekNumber": 1,
  "dueDate": "2025-01-31T00:00:00Z",
  "priority": "High"
}
```

**Response (200 OK):**
```json
{
  "success": true,
  "message": "تم إنشاء المهمة بنجاح",
  "data": {
    "id": 1,
    "title": "تطوير ميزة جديدة",
    "description": "تطوير ميزة إدارة المستخدمين",
    "status": "Pending",
    "priority": "High",
    "dueDate": "2025-01-31T00:00:00Z"
  },
  "statusCode": 200
}
```

---

### 4. الحصول على مهام أسبوع (Get Tasks by Week)

**Endpoint:** `GET /api/manager/tasks?year=2025&month=1&weekNumber=1`

**Response (200 OK):**
```json
{
  "success": true,
  "message": "تم الحصول على مهام الأسبوع 1 من الشهر 1 بنجاح",
  "data": [
    {
      "id": 1,
      "title": "تطوير ميزة جديدة",
      "status": "Completed",
      "priority": "High"
    }
  ],
  "statusCode": 200
}
```

---

### 5. الحصول على تقارير الأسبوع (Get Reports by Week)

**Endpoint:** `GET /api/manager/reports?year=2025&month=1&weekNumber=1`

**Response (200 OK):**
```json
{
  "success": true,
  "message": "تم الحصول على تقارير الأسبوع 1 من الشهر 1 بنجاح",
  "data": [
    {
      "id": 1,
      "taskId": 1,
      "reportDate": "2025-01-15T00:00:00Z",
      "content": "تم إكمال المهمة بنجاح",
      "employeeFullName": "سارة أحمد"
    }
  ],
  "statusCode": 200
}
```

---

## 👷 Employee APIs

**Base Route:** `/api/employee`

**Headers المطلوبة:**
```
Authorization: Bearer {EmployeeToken}
```

### 1. الحصول على مهامي (Get My Tasks)

**Endpoint:** `GET /api/employee/tasks`

**Response (200 OK):**
```json
{
  "success": true,
  "message": "تم الحصول على المهام بنجاح",
  "data": [
    {
      "id": 1,
      "title": "تطوير ميزة جديدة",
      "description": "تطوير ميزة إدارة المستخدمين",
      "status": "Pending",
      "priority": "High",
      "dueDate": "2025-01-31T00:00:00Z"
    }
  ],
  "statusCode": 200
}
```

---

### 2. إكمال مهمة (Complete Task)

**Endpoint:** `PUT /api/employee/tasks/{taskId}/complete`

**Response (200 OK):**
```json
{
  "success": true,
  "message": "تم تحديث حالة المهمة إلى مكتملة بنجاح",
  "data": {
    "id": 1,
    "status": "Completed",
    "completedAt": "2025-01-15T10:30:00Z"
  },
  "statusCode": 200
}
```

---

### 3. إنشاء تقرير (Create Report)

**Endpoint:** `POST /api/employee/reports`

**Request Body:**
```json
{
  "taskId": 1,
  "content": "تم إكمال المهمة بنجاح. تم تطوير جميع الميزات المطلوبة.",
  "reportDate": "2025-01-15T00:00:00Z"
}
```

**Response (200 OK):**
```json
{
  "success": true,
  "message": "تم إنشاء التقرير بنجاح",
  "data": {
    "id": 1,
    "taskId": 1,
    "content": "تم إكمال المهمة بنجاح...",
    "reportDate": "2025-01-15T00:00:00Z"
  },
  "statusCode": 200
}
```

---

## 💳 Subscription APIs

**Base Route:** `/api/subscription`

**Headers المطلوبة (للعمليات المحمية):**
```
Authorization: Bearer {ManagerToken}
```

### 1. الحصول على الخطط المتاحة (Get Available Plans)

**Endpoint:** `GET /api/subscription/plans`

**Headers:** لا يحتاج (Public)

**Response (200 OK):**
```json
{
  "success": true,
  "message": "تم الحصول على الخطط المتاحة بنجاح",
  "data": [
    {
      "id": 1,
      "name": "المبتدأ",
      "pricePerMonth": 50.00,
      "maxEmployees": 50,
      "description": "مثالي للشركات الصغيرة - حتى 50 موظف..."
    },
    {
      "id": 2,
      "name": "المحترف",
      "pricePerMonth": 100.00,
      "maxEmployees": 100,
      "description": "للشركات المتوسطة - حتى 100 موظف..."
    },
    {
      "id": 3,
      "name": "المؤسسات",
      "pricePerMonth": 0.00,
      "maxEmployees": 1000,
      "description": "للشركات الكبيرة - موظفين غير محدود..."
    }
  ],
  "statusCode": 200
}
```

---

### 2. الحصول على الاشتراك النشط (Get Active Subscription)

**Endpoint:** `GET /api/subscription/active`

**Response (200 OK):**
```json
{
  "success": true,
  "message": "تم الحصول على الاشتراك النشط بنجاح",
  "data": {
    "id": 1,
    "subscriptionPlanId": 2,
    "planName": "المحترف",
    "status": "Active",
    "startDate": "2025-01-01T00:00:00Z",
    "endDate": "2025-02-01T00:00:00Z",
    "currentEmployeeCount": 24,
    "maxEmployees": 100
  },
  "statusCode": 200
}
```

---

### 3. التحقق من حد الموظفين (Check Employee Limit)

**Endpoint:** `POST /api/subscription/check-employee-limit`

**Request Body:**
```json
{
  "requestedCount": 1
}
```

**Response (200 OK):**
```json
{
  "success": true,
  "message": "يمكن إضافة 1 موظف/موظفين",
  "data": {
    "allowed": true
  },
  "statusCode": 200
}
```

---

## 💰 Payment APIs

**Base Route:** `/api/payment`

### 1. بدء دفع My Fatoorah (Initiate My Fatoorah Payment)

**Endpoint:** `POST /api/payment/myfatoorah/initiate`

**Headers:**
```
Authorization: Bearer {ManagerToken}
```

**Request Body:**
```json
{
  "subscriptionId": 1,
  "amount": 100.00,
  "currency": "USD",
  "description": "دفع اشتراك شهري"
}
```

**Response (200 OK):**
```json
{
  "success": true,
  "message": "تم بدء عملية الدفع بنجاح",
  "data": {
    "paymentUrl": "https://myfatoorah.com/payment/...",
    "invoiceId": "invoice_id_here",
    "transactionId": "transaction_id_here"
  },
  "statusCode": 200
}
```

---

### 2. الحصول على مدفوعات المدير (Get Manager Payments)

**Endpoint:** `GET /api/payment/manager/payments`

**Headers:**
```
Authorization: Bearer {ManagerToken}
```

**Response (200 OK):**
```json
{
  "success": true,
  "message": "تم الحصول على مدفوعات المدير بنجاح",
  "data": [
    {
      "id": 1,
      "transactionId": "transaction_id_here",
      "amount": 100.00,
      "currency": "USD",
      "status": "Completed",
      "paymentGateway": "MyFatoorah",
      "paidAt": "2025-01-15T10:30:00Z"
    }
  ],
  "statusCode": 200
}
```

---

## 🔧 Admin APIs

**Base Route:** `/api/admin`

**Headers المطلوبة:**
```
Authorization: Bearer {AdminToken}
```

### 1. Seed جميع البيانات (Seed All Data)

**Endpoint:** `POST /api/admin/seed/all`

**Response (200 OK):**
```json
{
  "success": true,
  "message": "تم Seed جميع البيانات بنجاح",
  "data": {
    "subscriptionPlans": true,
    "adminUsers": true,
    "managerUsers": true,
    "employeeUsers": true
  },
  "statusCode": 200
}
```

---

### 2. Seed Subscription Plans فقط

**Endpoint:** `POST /api/admin/seed/subscription-plans`

**Response (200 OK):**
```json
{
  "success": true,
  "message": "تم Seed Subscription Plans بنجاح",
  "data": null,
  "statusCode": 200
}
```

---

## 📊 بيانات الدخول للاختبار

بعد Seed Data، يمكنك استخدام هذه البيانات:

### Admin:
- **Email:** `admin@rafeed.com`
- **Password:** `admin123`

### Manager:
- **Email:** `manager@rafeed.com`
- **Password:** `manager123`

### Employee:
- **Email:** `sara@rafeed.com`
- **Password:** `employee123`

---

## ⚠️ ملاحظات مهمة للفرونت إند

### 1. Authentication
- جميع الـ APIs المحمية تحتاج `Authorization: Bearer {Token}` في الـ Headers
- الـ Token ينتهي صلاحيته بعد فترة (عادة 1 ساعة)
- استخدم `/api/auth/validate-token` للتحقق من صلاحية الـ Token قبل الطلبات

### 2. Error Handling
جميع الأخطاء تأتي بنفس التنسيق:
```json
{
  "success": false,
  "message": "رسالة الخطأ بالعربية",
  "errors": ["خطأ 1", "خطأ 2"],
  "statusCode": 400
}
```

### 3. HTTP Status Codes
- **200 OK:** العملية نجحت
- **400 Bad Request:** خطأ في البيانات المرسلة
- **401 Unauthorized:** غير مصرح (Token غير صالح)
- **403 Forbidden:** غير مصرح (لا تملك الصلاحيات)
- **404 Not Found:** العنصر غير موجود
- **500 Internal Server Error:** خطأ في السيرفر

### 4. Date Format
جميع التواريخ بصيغة ISO 8601: `2025-01-15T10:30:00Z`

### 5. Pagination
(سيتم إضافتها لاحقاً إذا لزم الأمر)

---

## 📝 أمثلة استخدام (JavaScript/TypeScript)

### Login Example:
```typescript
const login = async (email: string, password: string) => {
  const response = await fetch('/api/auth/login', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({ email, password }),
  });
  
  const data: ApiResponse<AuthResponseDto> = await response.json();
  
  if (data.success && data.data) {
    // Save token
    localStorage.setItem('token', data.data.token);
    return data.data;
  } else {
    throw new Error(data.message);
  }
};
```

### Protected API Call Example:
```typescript
const getDashboard = async () => {
  const token = localStorage.getItem('token');
  
  const response = await fetch('/api/manager/dashboard', {
    method: 'GET',
    headers: {
      'Authorization': `Bearer ${token}`,
      'Content-Type': 'application/json',
    },
  });
  
  const data: ApiResponse<ManagerDashboardDto> = await response.json();
  
  if (data.success && data.data) {
    return data.data;
  } else {
    throw new Error(data.message);
  }
};
```

---

## 🔗 روابط مفيدة

- [API Documentation](./API_DOCUMENTATION.md) - الوثائق الكاملة
- [Payment Integration Guide](./PAYMENT_INTEGRATION_GUIDE.md) - دليل تكامل الدفع
- [Exception Handling Guide](./EXCEPTION_HANDLING_GUIDE.md) - دليل معالجة الأخطاء

