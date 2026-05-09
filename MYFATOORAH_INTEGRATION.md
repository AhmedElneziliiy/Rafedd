# My Fatoorah Integration Guide - فريقي (Fariqi)

## ✅ تم إضافة My Fatoorah Integration

My Fatoorah هي بوابة دفع إلكترونية متكاملة شائعة جداً في منطقة الشرق الأوسط، خاصة في:
- 🇸🇦 السعودية
- 🇦🇪 الإمارات
- 🇪🇬 مصر
- 🇰🇼 الكويت
- 🌍 باقي دول الخليج

---

## 🔧 التكوين المطلوب

### 1. My Fatoorah Configuration

في `appsettings.json`:
```json
{
  "MyFatoorah": {
    "ApiToken": "YOUR_MYFATOORAH_API_TOKEN_HERE",
    "BaseUrl": "https://apitest.myfatoorah.com"
  },
  "AppSettings": {
    "BaseUrl": "https://yourdomain.com"
  }
}
```

### 2. الحصول على My Fatoorah API Token

1. **سجل في My Fatoorah:**
   - اذهب إلى [My Fatoorah](https://www.myfatoorah.com)
   - سجل حساب جديد أو سجل دخول

2. **الحصول على API Token:**
   - اذهب إلى Dashboard
   - اختر "API Settings" أو "Settings" → "API"
   - انسخ **API Token** (يبدأ عادة بـ `rLtt6JWvbUHDDhsZnfpAhpYk4...`)

3. **اختيار البيئة:**
   - **Test Environment:** `https://apitest.myfatoorah.com`
   - **Live Environment:** `https://api.myfatoorah.com`

---

## 📝 API Endpoints

### 1. Initiate My Fatoorah Payment

```http
POST /api/payment/myfatoorah/initiate
Authorization: Bearer {token}
Content-Type: application/json

{
  "subscriptionId": 1,
  "amount": 50.00,
  "currency": "SAR",
  "paymentMethod": "myfatoorah",
  "description": "Monthly subscription payment"
}
```

**Response:**
```json
{
  "paymentUrl": "https://myfatoorah.com/pay/...",
  "invoiceId": "12345",
  "invoiceRef": "SUB-20250101-ABCD"
}
```

### 2. My Fatoorah Callback

```http
GET /api/payment/myfatoorah/callback?paymentId=xxx&invoiceId=12345
```

**يتم استدعاؤه تلقائياً من My Fatoorah بعد الدفع**

---

## 🔄 سير العمل (Payment Flow)

### My Fatoorah Payment Flow

```
1. Frontend → POST /api/payment/myfatoorah/initiate
   {
     "subscriptionId": 1,
     "amount": 50.00,
     "currency": "SAR",
     "paymentMethod": "myfatoorah"
   }

2. Backend → Create Invoice in My Fatoorah
   → Store payment record (Status: "Pending")
   → Return { paymentUrl: "...", invoiceId: "..." }

3. Frontend → Redirect user to paymentUrl

4. User → Pays on My Fatoorah page
   - Supports: Cards, Mada, KNET, Meeza, Digital Wallets
   - Full Arabic interface

5. My Fatoorah → Redirects to CallbackUrl
   GET /api/payment/myfatoorah/callback?invoiceId=12345

6. Backend → Verify payment with My Fatoorah API
   → Update payment status to "Completed"
   → Activate subscription
   → Extend subscription end date
   → Redirect to success page
```

---

## 💳 وسائل الدفع المدعومة في My Fatoorah

My Fatoorah تدعم:

### بطاقات الائتمان والخصم:
- ✅ Visa
- ✅ Mastercard
- ✅ American Express

### وسائل الدفع المحلية:
- ✅ **Mada** (السعودية)
- ✅ **KNET** (الكويت)
- ✅ **Meeza** (مصر)
- ✅ **Benefit** (البحرين)

### المحافظ الرقمية:
- ✅ Apple Pay
- ✅ Google Pay
- ✅ Samsung Pay

---

## 📊 مثال كامل

### Step 1: إنشاء اشتراك

```http
POST /api/subscription/create
Authorization: Bearer {manager_token}
Content-Type: application/json

{
  "subscriptionPlanId": 1
}
```

**Response:**
```json
{
  "id": 1,
  "planName": "Basic",
  "planPrice": 50.00,
  "maxEmployees": 30,
  "isActive": false
}
```

### Step 2: بدء عملية الدفع

```http
POST /api/payment/myfatoorah/initiate
Authorization: Bearer {manager_token}
Content-Type: application/json

{
  "subscriptionId": 1,
  "amount": 50.00,
  "currency": "SAR",
  "paymentMethod": "myfatoorah",
  "description": "Monthly subscription - Basic Plan"
}
```

**Response:**
```json
{
  "paymentUrl": "https://apitest.myfatoorah.com/paypage?id=abc123",
  "invoiceId": "12345678",
  "invoiceRef": "SUB-20250101-ABCD"
}
```

### Step 3: توجيه المستخدم للدفع

```javascript
// Frontend code
const response = await fetch('/api/payment/myfatoorah/initiate', {
  method: 'POST',
  headers: {
    'Authorization': `Bearer ${token}`,
    'Content-Type': 'application/json'
  },
  body: JSON.stringify({
    subscriptionId: 1,
    amount: 50.00,
    currency: 'SAR',
    paymentMethod: 'myfatoorah'
  })
});

const data = await response.json();
window.location.href = data.paymentUrl; // Redirect to My Fatoorah
```

### Step 4: بعد الدفع

My Fatoorah سيقوم بـ:
- ✅ إرسال callback إلى `/api/payment/myfatoorah/callback`
- ✅ النظام يتحقق من الدفع
- ✅ تفعيل الاشتراك تلقائياً
- ✅ توجيه المستخدم إلى صفحة النجاح

---

## 🔒 الأمان

- ✅ **API Token Authentication** - جميع الطلبات محمية بـ Bearer Token
- ✅ **Payment Verification** - التحقق من حالة الدفع مع My Fatoorah API
- ✅ **Transaction ID Tracking** - تتبع جميع المعاملات
- ✅ **Callback Validation** - التحقق من صحة Callback قبل المعالجة

---

## 🌍 العملات المدعومة

My Fatoorah تدعم العملات التالية:
- **SAR** - الريال السعودي
- **AED** - الدرهم الإماراتي
- **EGP** - الجنيه المصري
- **KWD** - الدينار الكويتي
- **USD** - الدولار الأمريكي
- **EUR** - اليورو
- **GBP** - الجنيه الإسترليني

---

## 📋 ملاحظات مهمة

1. **Test vs Production:**
   - Test: `https://apitest.myfatoorah.com`
   - Production: `https://api.myfatoorah.com`

2. **Invoice Expiry:**
   - الفاتورة تنتهي بعد 24 ساعة إذا لم يتم الدفع
   - يمكن تخصيص المدة في `ExpiryDate`

3. **Callback URLs:**
   - تأكد من أن `CallBackUrl` و `ErrorUrl` متاحة ويمكن الوصول إليها
   - في Production، يجب أن تكون HTTPS

4. **Payment Status:**
   - `Pending` - في انتظار الدفع
   - `Completed` - تم الدفع بنجاح
   - `Failed` - فشل الدفع

---

## ✅ الميزات المُضافة

- ✅ **Initiate Payment** - بدء عملية دفع My Fatoorah
- ✅ **Payment Callback** - معالجة Callback من My Fatoorah
- ✅ **Payment Verification** - التحقق من حالة الدفع
- ✅ **Automatic Subscription Activation** - تفعيل الاشتراك تلقائياً
- ✅ **Full Arabic Support** - دعم كامل للغة العربية
- ✅ **Multiple Payment Methods** - دعم جميع وسائل الدفع المحلية

---

## 🚀 جاهز للاستخدام!

My Fatoorah Integration تم إضافته بنجاح وجاهز للاستخدام! 🎉

**المشروع الآن يدعم:**
- ✅ Stripe (للدول الغربية)
- ✅ My Fatoorah (للمنطقة العربية) ⭐ NEW
- ✅ PayTabs (اختياري)

**المشروع الآن 100% جاهز للإنتاج! 🚀**

