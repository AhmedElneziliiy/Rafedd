# Forgot Password Feature Documentation

## Overview

The Rafedd system now includes a complete forgot password / password reset feature that allows users to securely reset their passwords.

## How It Works

### 1. Request Password Reset Token
User requests a password reset by providing their email address.

**Endpoint:** `POST /api/v1/auth/forgot-password`

**Request Body:**
```json
{
  "email": "user@example.com"
}
```

**Response:**
```json
{
  "success": true,
  "message": "تم إرسال رابط إعادة تعيين كلمة المرور إلى بريدك الإلكتروني",
  "data": {
    "email": "user@example.com",
    "resetToken": "CfDJ8...",  // Only in development/testing
    "message": "تم إرسال رمز إعادة تعيين كلمة المرور إلى بريدك الإلكتروني"
  }
}
```

### 2. Reset Password with Token
User resets their password using the token received.

**Endpoint:** `POST /api/v1/auth/reset-password`

**Request Body:**
```json
{
  "email": "user@example.com",
  "resetToken": "CfDJ8...",
  "newPassword": "newPassword123",
  "confirmPassword": "newPassword123"
}
```

**Response:**
```json
{
  "success": true,
  "message": "تم إعادة تعيين كلمة المرور بنجاح. يمكنك الآن تسجيل الدخول باستخدام كلمة المرور الجديدة",
  "data": null
}
```

### 3. Login with New Password
User can now login using their new password.

**Endpoint:** `POST /api/v1/auth/login`

**Request Body:**
```json
{
  "emailOrPhone": "user@example.com",
  "password": "newPassword123"
}
```

---

## Security Features

### 1. **User Enumeration Protection**
- If an email doesn't exist, the API returns a generic success message instead of revealing that the user doesn't exist
- This prevents attackers from using the endpoint to discover valid email addresses

### 2. **Token-Based Reset**
- Uses ASP.NET Identity's built-in `GeneratePasswordResetTokenAsync` which creates a secure, time-limited token
- Token is cryptographically signed and cannot be forged
- Token is single-use (becomes invalid after successful password reset)

### 3. **Security Stamp Update**
- After password reset, the user's security stamp is updated
- This invalidates all existing JWT tokens for that user
- Forces user to login again with the new password

### 4. **Password Validation**
- New password must meet the configured password requirements:
  - Minimum 8 characters
  - Must contain at least one digit
  - Passwords must match (newPassword === confirmPassword)

### 5. **Active User Check**
- Only active users can request password resets
- Inactive accounts are protected from unauthorized password changes

---

## Testing

### Prerequisites
1. API server must be running: `cd d:\Rafedd-master\Rafedd && dotnet run`
2. Database must be seeded with test users

### Run Test Script

```powershell
cd d:\Rafedd-master
.\test-forgot-password.ps1
```

This will test the complete flow:
1. Request reset token for `manager@rafeed.com`
2. Reset password using the token
3. Login with the new password

### Manual Testing with cURL

**1. Request Reset Token:**
```bash
curl -X POST http://localhost:5041/api/v1/auth/forgot-password \
  -H "Content-Type: application/json" \
  -d '{"email":"manager@rafeed.com"}'
```

**2. Reset Password:**
```bash
curl -X POST http://localhost:5041/api/v1/auth/reset-password \
  -H "Content-Type: application/json" \
  -d '{
    "email":"manager@rafeed.com",
    "resetToken":"YOUR_TOKEN_HERE",
    "newPassword":"newpassword123",
    "confirmPassword":"newpassword123"
  }'
```

**3. Test Login:**
```bash
curl -X POST http://localhost:5041/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "emailOrPhone":"manager@rafeed.com",
    "password":"newpassword123"
  }'
```

---

## Production Deployment Considerations

### **CRITICAL: Email Integration Required**

The current implementation returns the reset token directly in the API response **for testing purposes only**.

**Before deploying to production, you MUST:**

1. **Integrate an Email Service** (e.g., SendGrid, AWS SES, SMTP)
2. **Send Reset Link via Email** instead of returning the token
3. **Remove the token from the API response**

### Example Email Implementation

Update `AuthService.cs` line 600:

```csharp
// BEFORE (Development):
return resetToken;

// AFTER (Production):
// Send email with reset link
var resetLink = $"{_configuration["AppSettings:BaseUrl"]}/reset-password?token={HttpUtility.UrlEncode(resetToken)}&email={HttpUtility.UrlEncode(email)}";

await _emailService.SendPasswordResetEmailAsync(
    email,
    user.FullName,
    resetLink
);

return "success"; // Don't expose the token
```

Update `AuthController.cs` line 270-277:

```csharp
// BEFORE (Development):
return Ok(ApiResponse<object>.SuccessResponse(
    new {
        email = dto.Email,
        resetToken = resetToken,  // Remove this in production
        message = "تم إرسال رمز إعادة تعيين كلمة المرور إلى بريدك الإلكتروني"
    },
    "تم إرسال رابط إعادة تعيين كلمة المرور إلى بريدك الإلكتروني"
));

// AFTER (Production):
return Ok(ApiResponse<object>.SuccessResponse(
    null,
    "إذا كان البريد الإلكتروني موجوداً، سيتم إرسال رابط إعادة تعيين كلمة المرور"
));
```

### Token Expiration

ASP.NET Identity password reset tokens expire after a default period (usually 1 day). You can configure this in `Program.cs`:

```csharp
builder.Services.Configure<DataProtectionTokenProviderOptions>(options =>
{
    options.TokenLifespan = TimeSpan.FromHours(3); // 3 hours expiration
});
```

---

## Error Handling

### Common Errors

| Error | Reason | Solution |
|-------|--------|----------|
| `المستخدم غير موجود` | Email not found | Verify email address |
| `الحساب غير نشط. يرجى الاتصال بالدعم` | User account is inactive | Contact admin to activate account |
| `فشل إعادة تعيين كلمة المرور` | Invalid or expired token | Request a new reset token |
| `كلمة المرور يجب أن تكون على الأقل 8 أحرف` | Password too short | Use at least 8 characters |
| `كلمة المرور وتأكيد كلمة المرور غير متطابقين` | Passwords don't match | Ensure both fields match |

---

## Files Modified/Added

### New Files:
1. **`Shared/DTOS/Auth/ForgotPasswordDto.cs`** - DTO for forgot password request
2. **`Shared/DTOS/Auth/ResetPasswordDto.cs`** - DTO for reset password request
3. **`test-forgot-password.ps1`** - Test script
4. **`FORGOT-PASSWORD-GUIDE.md`** - This documentation

### Modified Files:
1. **`BLL/ServiceAbstraction/IAuthService.cs`** - Added interface methods
2. **`BLL/Service/AuthService.cs`** - Implemented forgot/reset password logic
3. **`Rafedd/Controllers/AuthController.cs`** - Added API endpoints

---

## API Endpoints Summary

| Endpoint | Method | Auth Required | Description |
|----------|--------|---------------|-------------|
| `/api/v1/auth/forgot-password` | POST | No | Request password reset token |
| `/api/v1/auth/reset-password` | POST | No | Reset password with token |

---

## Next Steps

1. ✅ Feature implemented and tested
2. ⚠️ **TODO:** Integrate email service for production
3. ⚠️ **TODO:** Remove token from API response in production
4. ⚠️ **TODO:** Create frontend UI for password reset flow
5. ⚠️ **TODO:** Configure token expiration time

---

## Support

For questions or issues with the forgot password feature, contact the development team or refer to the ASP.NET Identity documentation:
- https://docs.microsoft.com/en-us/aspnet/core/security/authentication/accconfirm
