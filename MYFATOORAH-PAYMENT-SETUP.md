# MyFatoorah Payment Gateway Setup Guide

## Current Status ✅

### API Token Status
- **Token**: `SK_KWT_kucLvwUtO6axVK3apufp2Jmzsgh0OfpFULevJtXcfyfGMB1U6uPumLLpmzXacjB2`
- **Status**: ✅ **VALID** - Token authenticates successfully
- **Environment**: Production (`https://api.myfatoorah.com`)
- **Country**: Kuwait (KWT)

### API Configuration
```json
{
  "MyFatoorah": {
    "ApiToken": "SK_KWT_kucLvwUtO6axVK3apufp2Jmzsgh0OfpFULevJtXcfyfGMB1U6uPumLLpmzXacjB2",
    "BaseUrl": "https://api.myfatoorah.com"
  }
}
```

## ⚠️ Required Action: Enable Payment Methods

### Issue
The `InitiatePayment` API returns **ZERO payment methods** because no payment gateways are enabled in your MyFatoorah portal account.

### Solution Steps

1. **Login to MyFatoorah Portal**
   - URL: https://portal.myfatoorah.com
   - Use your account credentials

2. **Navigate to Payment Methods Settings**
   - Go to: **Settings** → **Payment Methods**
   - Or: **Dashboard** → **Configuration** → **Payment Gateways**

3. **Enable Payment Gateways**
   - Recommended: Enable **VISA/Mastercard** (most common)
   - Optional: Enable other methods (KNET, Apple Pay, etc.)
   - Configure each gateway's settings
   - Save changes

4. **Verify Activation**
   - Run the test script: `powershell -ExecutionPolicy Bypass -File "d:\Rafedd-master\test-payment-full.ps1"`
   - Should now show available payment methods

## Database Structure

### PaymentMethods Table
**Purpose**: Stores customer credit card details (NOT MyFatoorah gateways)

| Column | Type | Description |
|--------|------|-------------|
| Id | int | Primary key |
| UserId | nvarchar(450) | User who owns this payment method |
| Type | nvarchar(50) | Payment type (e.g., "card") |
| Brand | nvarchar(50) | Card brand (e.g., "visa", "mastercard") |
| Last4 | nvarchar(4) | Last 4 digits of card number |
| ExpMonth | int | Card expiration month |
| ExpYear | int | Card expiration year |
| HolderName | nvarchar(200) | Cardholder name |
| IsDefault | bit | Is this the default payment method |
| CreatedAt | datetime2 | Record creation timestamp |
| UpdatedAt | datetime2 | Last update timestamp |

### Payments Table
**Purpose**: Stores payment transactions

| Column | Type | Description |
|--------|------|-------------|
| Id | int | Primary key |
| UserId | nvarchar | User making payment |
| SubscriptionId | int | Related subscription |
| InvoiceId | int | Related invoice |
| Amount | decimal | Payment amount |
| Currency | nvarchar | Currency code (USD, KWD, SAR, etc.) |
| Status | nvarchar | Payment status (Pending, Completed, Failed, Refunded) |
| Type | nvarchar | Payment type |
| PaymentMethodId | int | FK to PaymentMethods (nullable) |
| PaymentMethodName | nvarchar | Gateway used (stripe, myfatoorah, paytabs) |
| TransactionId | nvarchar | Gateway transaction/invoice ID |
| PaidAt | datetime2 | When payment completed |
| CreatedAt | datetime2 | Record creation timestamp |

## MyFatoorah API Endpoints

### 1. InitiatePayment
**Purpose**: Get available payment methods and calculate service charges

**Endpoint**: `POST /v2/InitiatePayment`

**Request**:
```json
{
  "InvoiceAmount": 50.0,
  "CurrencyIso": "USD"
}
```

**Response**:
```json
{
  "IsSuccess": true,
  "Message": "Initiated Successfully!",
  "Data": {
    "PaymentMethods": [
      {
        "PaymentMethodId": 2,
        "PaymentMethodEn": "VISA/MASTER",
        "PaymentMethodAr": "فيزا/ماستر",
        "PaymentMethodCode": "vm",
        "IsDirectPayment": true,
        "ServiceCharge": 0.0,
        "TotalAmount": 50.0,
        "CurrencyIso": "USD",
        "ImageUrl": "https://...",
        "IsEmbeddedSupported": true
      }
    ]
  }
}
```

### 2. ExecutePayment
**Purpose**: Create payment invoice and get payment URL

**Endpoint**: `POST /v2/ExecutePayment`

**Request**:
```json
{
  "PaymentMethodId": 2,
  "InvoiceValue": 50.0,
  "CallBackUrl": "https://yourdomain.com/api/v1/payment/myfatoorah/callback",
  "ErrorUrl": "https://yourdomain.com/api/v1/payment/myfatoorah/error",
  "CustomerName": "Customer Name",
  "CustomerEmail": "customer@example.com",
  "Language": "en",
  "DisplayCurrencyIso": "USD"
}
```

**Response**:
```json
{
  "IsSuccess": true,
  "Data": {
    "InvoiceId": 12345,
    "PaymentURL": "https://portal.myfatoorah.com/en/v2/payinvoice?invoiceKey=..."
  }
}
```

### 3. GetPaymentStatus
**Purpose**: Verify payment status

**Endpoint**: `POST /v2/GetPaymentStatus`

**Request**:
```json
{
  "Key": "12345",
  "KeyType": "InvoiceId"
}
```

**Response**:
```json
{
  "IsSuccess": true,
  "Data": {
    "InvoiceId": 12345,
    "InvoiceStatus": "Paid",
    "InvoiceValue": 50.0,
    "CustomerName": "Customer Name",
    "CustomerEmail": "customer@example.com"
  }
}
```

## Code Implementation

### PaymentService.cs
File: `d:\Rafedd-master\BLL\Service\PaymentService.cs`

**InitiateMyFatoorahPaymentAsync** (Lines 167-301):
- Calls `InitiatePayment` to get available payment methods
- Calls `ExecutePayment` to create invoice
- Creates Payment record in database with status "Pending"
- Returns payment URL for customer redirect

**HandleMyFatoorahCallbackAsync** (Lines 303-380):
- Receives callback from MyFatoorah after payment
- Verifies payment status using `GetPaymentStatus`
- Updates Payment record status (Completed/Failed)
- Activates/extends subscription on success

### PaymentController.cs
File: `d:\Rafedd-master\Rafedd\Controllers\PaymentController.cs`

**POST /api/v1/payment/myfatoorah/initiate** (Lines 89-104):
- Initiates MyFatoorah payment
- Requires Manager/Admin role
- Returns payment URL for redirect

**GET/POST /api/v1/payment/myfatoorah/callback** (Lines 107-148):
- Handles MyFatoorah callback
- Public endpoint (AllowAnonymous)
- Redirects to success/error pages

## Test Scripts

### test-payment-full.ps1
Comprehensive test script that:
1. Tests InitiatePayment endpoint
2. Checks available payment methods
3. Tests ExecutePayment (if methods available)
4. Verifies endpoint access

**Run**:
```powershell
powershell -ExecutionPolicy Bypass -File "d:\Rafedd-master\test-payment-full.ps1"
```

## References

- **MyFatoorah Documentation**: https://docs.myfatoorah.com
- **InitiatePayment API**: https://docs.myfatoorah.com/docs/initiate-payment
- **ExecutePayment API**: https://docs.myfatoorah.com/docs/execute-payment
- **Payment Methods**: https://docs.myfatoorah.com/docs/payment-methods
- **MyFatoorah Portal**: https://portal.myfatoorah.com

## Summary

✅ **Working**:
- API token is valid
- Production URL configured correctly
- Code implementation is correct
- InitiatePayment endpoint responds successfully

⚠️ **Action Required**:
- Enable payment methods in MyFatoorah portal
- At least one payment gateway must be activated (VISA/Mastercard recommended)

🔧 **Configuration**:
- File: `d:\Rafedd-master\Rafedd\appsettings.json`
- BaseUrl: `https://api.myfatoorah.com`
- CallbackUrl must be public HTTPS URL (not localhost)
