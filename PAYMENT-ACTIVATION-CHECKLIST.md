# MyFatoorah Payment Methods Activation Checklist

## Current Status
- ✅ **API Token**: VALID and working
- ✅ **Environment**: Production (`https://api.myfatoorah.com`)
- ❌ **Payment Methods**: Not showing up (0 methods for all currencies tested)

## Token Information
- **Token**: `SK_KWT_kucLvwUtO6axVK3apufp2Jmzsgh0OfpFULevJtXcfyfGMB1U6uPumLLpmzXacjB2`
- **Prefix**: `SK_KWT_` indicates Kuwait Production key
- **Type**: Server Key (production)

## Step-by-Step Activation Guide

### Step 1: Verify You're in the Correct Portal
1. Login to: **https://portal.myfatoorah.com**
2. Check the URL - make sure it's NOT:
   - ❌ `apitest.myfatoorah.com` (test environment)
   - ❌ `demo.myfatoorah.com` (demo environment)
3. Verify your account country is **Kuwait** (matches your SK_KWT token)

### Step 2: Navigate to Payment Methods
Once logged in, look for one of these navigation paths:

**Option A - Settings Menu:**
1. Click **"Settings"** in the main menu
2. Find **"Payment Methods"** or **"Payment Gateways"**
3. Click to view available gateways

**Option B - Configuration Menu:**
1. Click **"Configuration"** or **"Setup"**
2. Look for **"Payment Gateways"** or **"Payment Methods"**

**Option C - Dashboard:**
1. Some portals have a **"Payment Gateways"** card directly on the dashboard

### Step 3: Enable Payment Gateways

For each gateway you want to use (at minimum, enable one):

#### VISA/Mastercard (Recommended - Most Common)
- [ ] Find "VISA/MASTER" or "Credit Cards" gateway
- [ ] Click **"Activate"** or **"Enable"** button
- [ ] Set mode to **"Live"** (NOT "Test" or "Sandbox")
- [ ] Configure any required settings (usually minimal for VISA/Master)
- [ ] Click **"Save"** or **"Apply Changes"**

#### KNET (Kuwait Local Payment)
- [ ] Find "KNET" gateway
- [ ] Click **"Activate"**
- [ ] Set to **"Live"** mode
- [ ] Save changes

#### Other Gateways (Optional)
- [ ] Apple Pay
- [ ] Samsung Pay
- [ ] STC Pay
- [ ] Benefit (Bahrain)
- [ ] Mada (Saudi Arabia)

### Step 4: Verify Gateway Configuration

After enabling, check these settings:

1. **Status Column**: Should show "Active" or "Enabled" (NOT "Inactive" or "Pending")
2. **Mode**: Should be "Live" or "Production" (NOT "Test")
3. **Currency**: Should include KWD (or the currency you're using)
4. **Region**: Should match your account region (Kuwait)

### Step 5: Account Verification Requirements

Some accounts require verification before gateways activate:

- [ ] **Business Verification**: Company documents uploaded and approved
- [ ] **Bank Account**: Bank details verified
- [ ] **KYC (Know Your Customer)**: Identity documents approved
- [ ] **Contract Signed**: Agreement with MyFatoorah signed
- [ ] **Fees Configured**: Payment processing fees set up

**Check if verification is pending:**
1. Look for a banner or notification saying "Pending Verification"
2. Go to **"Settings" → "Account"** or **"Profile"**
3. Check **"Verification Status"** or **"Account Status"**

### Step 6: Wait for Changes to Propagate
- After saving changes, wait **2-5 minutes**
- MyFatoorah needs time to sync configuration changes
- Don't test immediately after saving

### Step 7: Test Again
Run the verification script:
```powershell
powershell -ExecutionPolicy Bypass -File "d:\Rafedd-master\verify-payment-setup.ps1"
```

## Common Issues and Solutions

### Issue 1: "Settings" Menu Not Visible
**Solution**: Your user account may not have admin permissions
- Contact the account owner
- Request admin access to configure payment gateways

### Issue 2: Gateways Show "Pending" Status
**Cause**: Business verification not complete
**Solution**:
1. Go to **Settings → Verification** or **Account → Verification**
2. Upload required documents (Commercial License, Bank Certificate, etc.)
3. Wait for MyFatoorah support to approve (usually 1-3 business days)

### Issue 3: Can't Find "Payment Methods" Section
**Solution**: Different portal versions have different layouts
- Try searching in the portal (usually a search box in top navigation)
- Check under: **Configuration**, **Setup**, **Merchant Settings**, **Gateway Settings**
- Contact MyFatoorah support if still can't find it

### Issue 4: Gateways Available but Not Showing in API
**Cause**: Gateway enabled but not configured for API usage
**Solution**:
1. For each gateway, look for an **"API Settings"** or **"Integration Settings"** section
2. Make sure **"Enable for API"** is checked
3. Verify the gateway is set to "Live" mode for production API key

### Issue 5: Only Test Gateways Available
**Cause**: Using production key but account is in test mode
**Solution**:
1. Go to **Settings → Account Mode** or **Configuration → Environment**
2. Switch from "Test Mode" to "Live Mode" or "Production Mode"
3. This may require additional verification steps

### Issue 6: Wrong Country/Region
**Cause**: Your account is set to a different country than Kuwait
**Solution**:
- Your token starts with `SK_KWT_` (Kuwait)
- Make sure your portal account is also set to Kuwait region
- If not, you may need to:
  - Switch region (if supported)
  - Or create a new Kuwait account
  - Or get a new API key that matches your account region

## Expected API Response (When Working)

When payment methods are properly enabled, `InitiatePayment` should return:

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
        "CurrencyIso": "KWD",
        "IsEmbeddedSupported": true
      }
    ]
  }
}
```

## Contact MyFatoorah Support

If you've checked everything and still no payment methods:

**MyFatoorah Support:**
- Email: support@myfatoorah.com
- Phone: Check portal footer for phone number
- Live Chat: Usually available in portal bottom-right corner

**What to tell them:**
1. "I have a production API key (`SK_KWT_...`) that authenticates successfully"
2. "InitiatePayment returns 0 payment methods for all currencies"
3. "I need help enabling payment gateways in my portal"
4. "Please verify my account is fully activated and gateways are enabled"

**Information they may ask for:**
- Your account email
- Company name
- API key (first few characters: SK_KWT_kuc...)
- Account ID or Merchant ID

## Quick Diagnostic

Run this to see exactly what MyFatoorah API returns:
```powershell
$token = "SK_KWT_kucLvwUtO6axVK3apufp2Jmzsgh0OfpFULevJtXcfyfGMB1U6uPumLLpmzXacjB2"
$headers = @{"Authorization" = "Bearer $token"; "Content-Type" = "application/json"}
$body = @{InvoiceAmount = 50.0; CurrencyIso = "KWD"} | ConvertTo-Json
Invoke-RestMethod -Uri "https://api.myfatoorah.com/v2/InitiatePayment" -Method Post -Headers $headers -Body $body | ConvertTo-Json -Depth 10
```

This will show the full response including any error messages or additional fields.

## Next Steps

1. ✅ Login to https://portal.myfatoorah.com
2. ✅ Find Payment Methods/Gateways section
3. ✅ Enable at least one gateway (VISA/MASTER recommended)
4. ✅ Set to "Live" mode
5. ✅ Save changes
6. ✅ Wait 2-5 minutes
7. ✅ Run: `powershell -ExecutionPolicy Bypass -File "d:\Rafedd-master\verify-payment-setup.ps1"`
8. ✅ If still not working, contact MyFatoorah support

## Files for Testing

After payment methods are enabled, use these scripts:

1. **verify-payment-setup.ps1** - Quick verification of payment methods
2. **test-payment-full.ps1** - Full payment flow test
3. **test-all-currencies.ps1** - Test multiple currencies

Once payment methods show up, we can proceed to test the full integration with your API!
