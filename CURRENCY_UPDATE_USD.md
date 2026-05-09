# Subscription Plans Currency Update - USD

## Changes Made

Your subscription plans have been updated from **SAR (Saudi Riyals)** to **USD (US Dollars)**.

### New Pricing (USD)

| Plan | Previous (SAR) | New (USD) | Employees | Description |
|------|----------------|-----------|-----------|-------------|
| **المبتدأ (Beginner)** | 99.00 SAR | **$50.00** | 30 | Small companies plan |
| **المحترف (Professional)** | 199.00 SAR | **$100.00** | 50 | Medium companies plan |
| **المؤسسات (Enterprise)** | 0.00 (Custom) | **$0.00** (Custom) | 1000+ | Large companies - custom pricing |

---

## Files Modified

### 1. Subscription Plans Data
**File**: `d:\Rafedd-master\DAL\Data\DataSeed\SubscriptionPlans.json`
- Plan 1: 99.00 → **50.00**
- Plan 2: 199.00 → **100.00**

### 2. Test Script
**File**: `d:\Rafedd-master\test-payment.sh`
- Currency: "KWD" → **"USD"**
- Amount: 10.0 → **50.0** (testing with Beginner plan price)

### 3. Database Update Script
**File**: `d:\Rafedd-master\update-plans-to-usd.sql`
- Created SQL script to update existing database records

---

## How to Apply Changes

### Step 1: Update Database (Manual)
If you want to update the existing database immediately, run the SQL script:

```sql
-- Option 1: Using SQL Server Management Studio (SSMS)
-- Open update-plans-to-usd.sql and execute

-- Option 2: Using sqlcmd
sqlcmd -S .\SQLEXPRESS -d RafeddSystemDB -i update-plans-to-usd.sql
```

### Step 2: Restart API (Automatic Database Update)
The API will automatically reseed the subscription plans when it starts:

```bash
# Stop any running API
powershell -Command "Stop-Process -Name Rafedd -Force -ErrorAction SilentlyContinue"

# Start API (it will reseed with new USD prices)
cd d:\Rafedd-master\Rafedd
dotnet run
```

The `DataSeederService` will automatically update the plans to $50 and $100 on startup.

---

## Testing with USD

### Test Payment with New Pricing

```bash
# Run the updated test script
bash d:\Rafedd-master\test-payment.sh
```

This will test a payment of **$50 USD** for the Beginner plan.

### Manual API Test

```bash
# 1. Get auth token
curl -X POST "http://localhost:5041/api/v1/auth/login" \
  -H "Content-Type: application/json" \
  -d '{"emailOrPhone":"manager@rafeed.com","password":"manager123"}'

# 2. Initiate payment with USD
curl -X POST "http://localhost:5041/api/v1/payment/myfatoorah/initiate" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "subscriptionId": 1,
    "amount": 50.0,
    "currency": "USD",
    "paymentMethod": "myfatoorah",
    "description": "Beginner Plan - $50/month"
  }'
```

---

## Frontend Integration

### Updated Payment Request (USD)

```javascript
// Example: React/Vue/Angular
const initiatePayment = async (planId, planName) => {
  const planPrices = {
    1: 50.00,   // Beginner plan
    2: 100.00   // Professional plan
  };

  const response = await fetch('/api/v1/payment/myfatoorah/initiate', {
    method: 'POST',
    headers: {
      'Authorization': `Bearer ${token}`,
      'Content-Type': 'application/json'
    },
    body: JSON.stringify({
      subscriptionId: subscriptionId,
      amount: planPrices[planId],
      currency: 'USD',  // ← Changed to USD
      paymentMethod: 'myfatoorah',
      description: `${planName} - Monthly Subscription`
    })
  });

  const result = await response.json();
  if (result.success) {
    window.location.href = result.data.paymentUrl;
  }
};
```

---

## MyFatoorah USD Support

### Compatibility
- ✅ MyFatoorah test token (SK_KWT_...) **supports USD**
- ✅ USD is a globally accepted currency on MyFatoorah
- ✅ No changes needed to MyFatoorah configuration
- ✅ Test cards work with USD

### Currency Conversion
When customers pay:
- MyFatoorah will show the amount in **USD**
- Customer's bank may convert to their local currency
- Example: $50 USD ≈ 183.75 SAR (rate varies)

---

## Pricing Comparison

### Before (SAR):
- Beginner: 99 SAR/month (~$26 USD)
- Professional: 199 SAR/month (~$53 USD)

### After (USD):
- Beginner: **$50 USD/month** (~188 SAR)
- Professional: **$100 USD/month** (~376 SAR)

**Note**: This is a **price increase** when converted back to SAR. USD pricing is more standard for international SaaS products.

---

## Important Notes

### 1. Existing Subscriptions
- Existing active subscriptions will keep their current pricing
- New subscriptions will use the new USD pricing
- Renewals will use the new USD pricing

### 2. Payment Records
- Old payment records will remain in their original currency (KWD from tests)
- New payments will be recorded in USD
- The `Payments` table `Currency` column stores the currency used

### 3. Display in Frontend
Make sure your frontend displays prices in USD:

```html
<!-- Example pricing display -->
<div class="pricing-card">
  <h3>Beginner Plan</h3>
  <p class="price">$50<span>/month</span></p>
  <p>Up to 30 employees</p>
</div>

<div class="pricing-card">
  <h3>Professional Plan</h3>
  <p class="price">$100<span>/month</span></p>
  <p>Up to 50 employees</p>
</div>
```

### 4. Production MyFatoorah Account
When you register for production MyFatoorah:
- Specify USD as your primary currency
- Your bank account will receive USD (or converted to your bank's currency)
- Settlement will be in USD

---

## Database Schema

The `SubscriptionPlans` table stores prices as `decimal(18,2)`:

```sql
CREATE TABLE SubscriptionPlans (
    Id INT PRIMARY KEY,
    Name NVARCHAR(50),
    PricePerMonth DECIMAL(18,2),  -- Stores 50.00 or 100.00
    MaxEmployees INT,
    Description NVARCHAR(MAX),
    IsActive BIT
);
```

The `Payments` table includes a currency field:

```sql
CREATE TABLE Payments (
    Id INT PRIMARY KEY,
    Amount DECIMAL(18,2),          -- Amount in the specified currency
    Currency NVARCHAR(10),          -- "USD", "SAR", "KWD", etc.
    SubscriptionId INT,
    TransactionId NVARCHAR(450),
    Status NVARCHAR(50),
    -- ... other fields
);
```

---

## Next Steps

1. **Apply Changes**:
   ```bash
   # Restart API to apply new pricing
   cd d:\Rafedd-master\Rafedd
   dotnet run
   ```

2. **Test Payment**:
   ```bash
   # Test with $50 USD
   bash d:\Rafedd-master\test-payment.sh
   ```

3. **Update Frontend**:
   - Change pricing displays to show USD
   - Update payment initiation code to use "USD" currency
   - Update any hardcoded prices to $50 and $100

4. **Production**:
   - When registering MyFatoorah production account, specify USD
   - Ensure your business bank account can receive USD
   - Test with small real payment ($1 USD test)

---

## Reverting Changes

If you need to revert back to SAR:

1. Edit `SubscriptionPlans.json`:
   - Plan 1: 50.00 → 99.00
   - Plan 2: 100.00 → 199.00

2. Update test script:
   - Currency: "USD" → "SAR"
   - Amount: 50.0 → 99.0

3. Restart API to reseed

---

## Summary

✅ **Subscription plans updated to USD**
- Beginner: $50/month
- Professional: $100/month
- Enterprise: Custom pricing

✅ **Files updated**:
- SubscriptionPlans.json
- test-payment.sh
- Created update SQL script

✅ **Ready to test**:
- Restart API and run test script
- MyFatoorah supports USD
- No code changes needed

🎯 **Action Required**:
1. Restart API
2. Test payment with USD
3. Update frontend pricing displays
