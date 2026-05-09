# MyFatoorah Support - How to Collect Information

MyFatoorah support (Islam Mohamed) has requested the following information:

1. ✅ The API URL you sent the request to
2. ✅ The complete JSON request you sent to MyFatoorah
3. ✅ The JSON response returned from MyFatoorah

## Quick Steps to Get This Information

### Step 1: Start Your API Server

```bash
cd d:\Rafedd-master\Rafedd
dotnet run
```

**Keep this terminal window open** - you'll need to see the logs!

### Step 2: Run the Diagnostic Script (In a NEW Terminal)

```bash
cd d:\Rafedd-master
python diagnose-myfatoorah.py
```

### Step 3: Look at Your API Server Logs

In the **first terminal** (where dotnet run is running), you'll see logs like this:

```
=== MyFatoorah InitiatePayment API Call ===
API URL: https://api.myfatoorah.com/v2/InitiatePayment
Request JSON: {"InvoiceAmount":50.0,"CurrencyIso":"KWD"}
Response Status: 200
Response JSON: {"IsSuccess":true,"Message":"Success","Data":{...}}

=== MyFatoorah ExecutePayment API Call ===
API URL: https://api.myfatoorah.com/v2/ExecutePayment
Request JSON: {"PaymentMethodId":2,"InvoiceValue":50.0,"CallBackUrl":"...","ErrorUrl":"...","CustomerName":"...","CustomerEmail":"...","Language":"en","DisplayCurrencyIso":"KWD"}
Response Status: 200
Response JSON: {"IsSuccess":true,"Message":"Success","Data":{...}}
```

### Step 4: Copy and Send to MyFatoorah Support

**Copy the entire section** between the `===` marks and send it to Islam Mohamed.

## Current Configuration

Check your [appsettings.json](d:\Rafedd-master\Rafedd\appsettings.json):

```json
"MyFatoorah": {
  "ApiToken": "SK_KWT_kucLvwUtO6axVK3apufp2Jmzsgh0OfpFULevJtXcfyfGMB1U6uPumLLpmzXacjB2",
  "BaseUrl": "https://api.myfatoorah.com"
}
```

**Environment**: PRODUCTION
**Token**: Production token (SK_KWT_kuc...)

---

## Email Template for MyFatoorah Support

```
Dear Islam Mohamed,

Thank you for your assistance. Here is the requested information:

**Issue**: [Describe what's happening - e.g., "Getting 0 payment methods available" or "Payment initiation failing"]

**1. API URLs we are calling:**
[Copy from logs - will show both InitiatePayment and ExecutePayment URLs]

**2. Complete JSON Request sent to MyFatoorah:**
[Copy the "Request JSON" from logs]

**3. JSON Response returned from MyFatoorah:**
[Copy the "Response JSON" from logs]

**Configuration:**
- Environment: Production
- Base URL: https://api.myfatoorah.com
- API Token: SK_KWT_kucLvwUtO6axVK3apufp2Jmzsgh0OfpFULevJtXcfyfGMB1U6uPumLLpmzXacjB2

Please let me know what could be causing this issue.

Best regards,
Khaled
```

---

## Troubleshooting

### If you don't see the logs:

1. Make sure you're running in **Development** environment:
   ```bash
   $env:ASPNETCORE_ENVIRONMENT="Development"
   dotnet run
   ```

2. The logs are enabled by default in the code (just updated)

### If the diagnostic script fails:

Check that:
- API is running on port 5041
- You have a Manager account with email: manager@rafeed.com, password: manager123
- Subscription with ID 1 exists in the database

---

## What MyFatoorah Will Check

Based on the information you provide, MyFatoorah support will verify:

1. ✅ Your API token is valid and active
2. ✅ Your account has payment methods enabled
3. ✅ The request format is correct
4. ✅ Your account permissions are properly set up
5. ✅ Any issues with your MyFatoorah portal configuration

---

## Files Modified

I've updated the following files to help you collect this information:

1. [PaymentService.cs](d:\Rafedd-master\BLL\Service\PaymentService.cs) - Added detailed logging for all MyFatoorah API calls
2. [diagnose-myfatoorah.py](d:\Rafedd-master\diagnose-myfatoorah.py) - New diagnostic script to test the integration

The logging is now automatically enabled. Just run the API and make a payment request!
