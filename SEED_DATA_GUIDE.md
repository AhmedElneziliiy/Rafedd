# دليل Seed Data - بيانات الاختبار

## 📋 نظرة عامة

تم إنشاء نظام Seed Data يسمح لك بإنشاء بيانات اختبار بسرعة لتجربة الـ APIs. النظام يقرأ ملفات JSON من مجلد `DAL/Data/DataSeed` ويستخدمها لإنشاء بيانات في قاعدة البيانات.

## 📁 الملفات المتاحة

### 1. SubscriptionPlans.json
خطط الاشتراك المتاحة (مطابقة لموقع [رافد](https://rafeed.vercel.app/)):
- **المبتدأ**: $50/شهر - حتى 50 موظف - مثالي للشركات الصغيرة
- **المحترف**: $100/شهر - حتى 100 موظف - للشركات المتوسطة
- **المؤسسات**: حسب الطلب - موظفين غير محدود - للشركات الكبيرة

### 2. AdminUsers.json
مسؤولو النظام للاختبار:
- **admin@rafeed.com** / `admin123`

### 3. ManagerUsers.json
المديرون للاختبار مع الاشتراكات:
- **manager@rafeed.com** / `manager123` - شركة رافد للتكنولوجيا (خطة المحترف)

### 4. EmployeeUsers.json
الموظفون للاختبار:
- **sara@rafeed.com** / `employee123` - موظف لدى manager@rafeed.com

## 🚀 كيفية الاستخدام

### الطريقة السريعة: Seed All Data

```http
POST /api/admin/seed/all
Authorization: Bearer {AdminToken}
```

هذا سينفذ كل شيء تلقائياً:
1. ✅ Subscription Plans
2. ✅ Admin Users
3. ✅ Manager Users (مع الاشتراكات)
4. ✅ Employee Users

### الطريقة التفصيلية: Seed كل نوع على حدة

#### 1. Seed Subscription Plans فقط

```http
POST /api/admin/seed/subscription-plans
Authorization: Bearer {AdminToken}
```

**Response:**
```json
{
  "success": true,
  "message": "تم إنشاء Subscription Plans بنجاح",
  "data": null,
  "statusCode": 200
}
```

#### 2. Seed Admin Users فقط

```http
POST /api/admin/seed/admin-users
Authorization: Bearer {AdminToken}
```

**ملاحظة:** يجب تسجيل الدخول كـ Admin أولاً. إذا لم يكن لديك Admin، يمكنك إنشاؤه يدوياً عبر `POST /api/auth/register/admin` (يحتاج Admin موجود).

#### 3. Seed Manager Users فقط

```http
POST /api/admin/seed/manager-users
Authorization: Bearer {AdminToken}
```

**ما يحدث:**
- ✅ إنشاء Manager Users
- ✅ إنشاء اشتراكات لهم تلقائياً
- ✅ ربط الاشتراكات بالمديرين

#### 4. Seed Employee Users فقط

```http
POST /api/admin/seed/employee-users
Authorization: Bearer {AdminToken}
```

**ما يحدث:**
- ✅ إنشاء Employee Users
- ✅ ربطهم بالمديرين المحددين في `ManagerEmail`
- ✅ تحديث عدد الموظفين لكل مدير

## 📝 تسلسل التنفيذ الموصى به

### السيناريو الأول: البدء من الصفر

1. **إنشاء Admin يدوياً أولاً:**
   ```http
   POST /api/auth/register/admin
   Authorization: Bearer {ExistingAdminToken} # أو إنشاؤه مباشرة من الكود
   ```

2. **تسجيل الدخول كـ Admin:**
   ```http
   POST /api/auth/login
   {
     "email": "admin@rafedd.com",
     "password": "Admin123!@#"
   }
   ```

3. **Seed جميع البيانات:**
   ```http
   POST /api/admin/seed/all
   Authorization: Bearer {AdminToken}
   ```

### السيناريو الثاني: Seed تدريجي

```http
POST /api/admin/seed/subscription-plans
POST /api/admin/seed/admin-users
POST /api/admin/seed/manager-users
POST /api/admin/seed/employee-users
```

## 🔑 بيانات الدخول للاختبار

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

## ⚠️ ملاحظات مهمة

1. **التكرار:** إذا كان المستخدم موجود بالفعل (نفس البريد الإلكتروني)، لن يتم إنشاؤه مرة أخرى
2. **Subscription Plans:** إذا كانت الخطة موجودة (نفس ID أو الاسم)، سيتم تحديثها
3. **Manager Subscriptions:** يتم إنشاء الاشتراكات تلقائياً عند Seed Manager Users
4. **Employee Limits:** يتم التحقق من حدود الاشتراك قبل إضافة الموظفين
5. **Employee-Manager Link:** يجب أن يكون الـ Manager موجود قبل Seed Employee Users

## 🧪 أمثلة للاختبار

### 1. اختبار Login كـ Manager:
```http
POST /api/auth/login
{
  "email": "manager@rafeed.com",
  "password": "manager123"
}
```

### 2. اختبار إنشاء Annual Target:
```http
POST /api/manager/annual-targets
Authorization: Bearer {ManagerToken}
{
  "year": 2025,
  "targetDescription": "زيادة المبيعات بنسبة 50% وتحسين جودة المنتجات"
}
```

### 3. اختبار Dashboard:
```http
GET /api/manager/dashboard
Authorization: Bearer {ManagerToken}
```

## 📦 تعديل Seed Data

يمكنك تعديل ملفات JSON في `DAL/Data/DataSeed/` وإعادة تشغيل Seed APIs:

- **SubscriptionPlans.json** - تعديل أو إضافة خطط جديدة
- **AdminUsers.json** - إضافة مسؤولين جدد
- **ManagerUsers.json** - إضافة مديرين جدد
- **EmployeeUsers.json** - إضافة موظفين جدد

**ملاحظة:** بعد تعديل الملفات، قم بتشغيل Seed API المناسب مرة أخرى.

