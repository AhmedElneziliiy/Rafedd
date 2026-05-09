# Exception Handling & API Response Guide

## 📋 نظرة عامة

تم تطبيق نظام موحد لمعالجة الأخطاء والاستجابات في جميع الـ API Endpoints. كل استجابة ترجع `ApiResponse<T>` موحدة مع رسائل واضحة بالعربية.

---

## 🎯 ApiResponse Structure

### Generic ApiResponse<T>

```csharp
{
  "success": true/false,
  "message": "رسالة واضحة بالعربية",
  "data": { /* البيانات المطلوبة */ },
  "errors": [ /* قائمة الأخطاء (إن وجدت) */ ],
  "statusCode": 200/400/401/404/500
}
```

### Non-Generic ApiResponse

```csharp
{
  "success": true/false,
  "message": "رسالة واضحة بالعربية",
  "errors": [ /* قائمة الأخطاء (إن وجدت) */ ],
  "statusCode": 200/400/401/404/500
}
```

---

## ✅ Success Response Examples

### Success with Data

```json
{
  "success": true,
  "message": "تم إنشاء الهدف السنوي بنجاح. تم توليد الخطة الكاملة (48 أسبوع) باستخدام Gemini AI",
  "data": {
    "id": 1,
    "year": 2026,
    "targetDescription": "..."
  },
  "errors": [],
  "statusCode": 200
}
```

### Success without Data

```json
{
  "success": true,
  "message": "تم حذف المهمة بنجاح",
  "errors": [],
  "statusCode": 200
}
```

---

## ❌ Error Response Examples

### Bad Request (400)

```json
{
  "success": false,
  "message": "الهدف السنوي للعام 2026 موجود بالفعل",
  "errors": [],
  "statusCode": 400
}
```

### Unauthorized (401)

```json
{
  "success": false,
  "message": "البريد الإلكتروني أو كلمة المرور غير صحيحة",
  "errors": [],
  "statusCode": 401
}
```

### Not Found (404)

```json
{
  "success": false,
  "message": "الهدف السنوي للعام 2026 غير موجود",
  "errors": [],
  "statusCode": 404
}
```

### Validation Error (400) with Multiple Errors

```json
{
  "success": false,
  "message": "التحقق من صحة البيانات فشل",
  "errors": [
    "البريد الإلكتروني مطلوب",
    "كلمة المرور يجب أن تكون 8 أحرف على الأقل"
  ],
  "statusCode": 400
}
```

### Internal Server Error (500)

```json
{
  "success": false,
  "message": "حدث خطأ غير متوقع في الخادم. يرجى المحاولة مرة أخرى لاحقاً.",
  "errors": [],
  "statusCode": 500
}
```

---

## 🔧 Custom Exceptions

تم إنشاء Exceptions مخصصة بالعربية:

### 1. NotFoundException

```csharp
throw new NotFoundException("الهدف السنوي للعام 2026 غير موجود");
```

**Response:** 404 Not Found

---

### 2. BadRequestException

```csharp
throw new BadRequestException("الهدف السنوي موجود بالفعل");
```

**Response:** 400 Bad Request

```csharp
throw new BadRequestException("التحقق من صحة البيانات فشل", new List<string> 
{ 
    "البريد الإلكتروني مطلوب",
    "كلمة المرور يجب أن تكون 8 أحرف على الأقل"
});
```

**Response:** 400 Bad Request with Errors Array

---

### 3. UnauthorizedException

```csharp
throw new UnauthorizedException("البريد الإلكتروني أو كلمة المرور غير صحيحة");
```

**Response:** 401 Unauthorized

---

### 4. ForbiddenException

```csharp
throw new ForbiddenException("ليس لديك الصلاحية للوصول إلى هذا المورد");
```

**Response:** 403 Forbidden

---

### 5. ValidationException

```csharp
throw new ValidationException(new List<string> 
{
    "البريد الإلكتروني مطلوب",
    "كلمة المرور يجب أن تكون 8 أحرف على الأقل"
});
```

**Response:** 400 Bad Request with Errors Array

---

### 6. BusinessLogicException

```csharp
throw new BusinessLogicException("لا يمكن إضافة موظف جديد. تجاوز حد الاشتراك");
```

**Response:** 400 Bad Request

---

## 🛡️ Global Exception Handler

تم إضافة `GlobalExceptionHandlerMiddleware` الذي:

1. **يتعامل مع جميع Exceptions تلقائياً**
2. **يحول Exceptions إلى ApiResponse موحدة**
3. **يسجل الأخطاء في Logs**
4. **يرجع رسائل واضحة بالعربية**

### Exception Mapping

| Exception Type | Status Code | Response Message |
|---------------|-------------|------------------|
| `NotFoundException` | 404 | الرسالة المحددة |
| `BadRequestException` | 400 | الرسالة المحددة + Errors Array |
| `UnauthorizedException` | 401 | الرسالة المحددة |
| `ForbiddenException` | 403 | الرسالة المحددة |
| `ValidationException` | 400 | الرسالة المحددة + Errors Array |
| `BusinessLogicException` | 400 | الرسالة المحددة |
| `InvalidOperationException` | 400 | الرسالة المحددة |
| `UnauthorizedAccessException` | 401 | الرسالة المحددة |
| `Exception` (عام) | 500 | رسالة عامة |

---

## 📝 Usage in Controllers

### Success Response

```csharp
[HttpPost("annual-targets")]
public async Task<ActionResult<ApiResponse<AnnualTargetResponseDto>>> CreateAnnualTarget([FromBody] CreateAnnualTargetDto dto)
{
    var result = await _annualTargetService.CreateAnnualTargetAsync(managerUserId, dto);
    return Ok(ApiResponse<AnnualTargetResponseDto>.SuccessResponse(result, "تم إنشاء الهدف السنوي بنجاح"));
}
```

### Error Response (Throw Exception)

```csharp
[HttpGet("annual-targets/{year}")]
public async Task<ActionResult<ApiResponse<AnnualTargetResponseDto>>> GetAnnualTargetByYear(int year)
{
    var result = await _annualTargetService.GetAnnualTargetByYearAsync(managerUserId, year);
    
    if (result == null)
    {
        throw new NotFoundException($"الهدف السنوي للعام {year} غير موجود");
    }

    return Ok(ApiResponse<AnnualTargetResponseDto>.SuccessResponse(result));
}
```

### Handling Service Exceptions

```csharp
try
{
    var result = await _authService.RegisterAsync(registerDto);
    return Ok(ApiResponse<AuthResponseDto>.SuccessResponse(result, "تم التسجيل بنجاح"));
}
catch (InvalidOperationException ex)
{
    throw new BadRequestException(ex.Message);
}
```

**ملاحظة:** `GlobalExceptionHandler` سيتعامل مع Exception تلقائياً.

---

## 🎨 Response Status Codes

| Status Code | المعنى | متى يُستخدم |
|------------|--------|-------------|
| **200** | نجاح | العملية نجحت |
| **400** | طلب غير صحيح | بيانات خاطئة، تحقق فشل، منطق عمل |
| **401** | غير مصرح | Token غير صالح، بيانات دخول خاطئة |
| **403** | محظور | Role غير كافي |
| **404** | غير موجود | العنصر غير موجود في قاعدة البيانات |
| **500** | خطأ في الخادم | خطأ غير متوقع |

---

## 🔍 Frontend Integration

### Success Handling

```typescript
const response = await fetch('/api/manager/annual-targets', {
  method: 'POST',
  headers: { 'Content-Type': 'application/json', 'Authorization': `Bearer ${token}` },
  body: JSON.stringify(data)
});

const result = await response.json();

if (result.success) {
  console.log(result.message); // "تم إنشاء الهدف السنوي بنجاح"
  console.log(result.data); // البيانات
} else {
  console.error(result.message); // رسالة الخطأ
  if (result.errors && result.errors.length > 0) {
    result.errors.forEach(error => console.error(error));
  }
}
```

### Error Handling

```typescript
try {
  const response = await fetch('/api/manager/annual-targets/2026');
  const result = await response.json();
  
  if (!result.success) {
    // Handle error
    if (result.statusCode === 404) {
      // Show "not found" message
    } else if (result.statusCode === 401) {
      // Redirect to login
    } else {
      // Show error message
    }
  }
} catch (error) {
  // Network error
}
```

---

## ✅ Benefits

1. **رسائل واضحة بالعربية** - كل رسالة خطأ مفهومة
2. **استجابة موحدة** - نفس البنية لجميع الـ Endpoints
3. **معالجة تلقائية** - لا حاجة لـ try-catch في كل Controller
4. **سهولة التتبع** - جميع الأخطاء مسجلة في Logs
5. **Frontend Friendly** - سهولة التعامل مع الاستجابات في Frontend

---

## 📌 Best Practices

1. **استخدم Custom Exceptions** بدلاً من Exception العامة
2. **أضف رسائل واضحة بالعربية** في كل Exception
3. **استخدم ValidationException** للأخطاء المتعددة
4. **لا تستخدم try-catch** إلا إذا كنت تريد تغيير نوع Exception
5. **دع GlobalExceptionHandler** يتعامل مع الأخطاء تلقائياً

---

## ✅ الحالة

**جميع الـ Endpoints محدثة لاستخدام ApiResponse ✅**

**Global Exception Handler يعمل تلقائياً ✅**

**جميع Exceptions ترجع رسائل واضحة بالعربية ✅**

