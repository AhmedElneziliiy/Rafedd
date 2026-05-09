# Direct Payment Test - Tests payment with existing subscription
$baseUrl = "http://localhost:5041/api/v1"

Write-Host "`n========== DIRECT PAYMENT TEST ==========`n" -ForegroundColor Cyan

# Login as manager
Write-Host "[1] Logging in as manager..." -ForegroundColor Yellow
$loginBody = '{"emailOrPhone":"manager@rafeed.com","password":"manager123"}'
$login = Invoke-RestMethod -Uri "$baseUrl/auth/login" -Method POST -Body $loginBody -ContentType "application/json"
$token = $login.token
Write-Host "[OK] Logged in" -ForegroundColor Green

# Get subscription plans
Write-Host "`n[2] Getting subscription plans..." -ForegroundColor Yellow
$plans = Invoke-RestMethod -Uri "$baseUrl/subscriptions/plans" -Method GET
$testPlan = $plans.data | Where-Object { $_.name -eq "Basic" } | Select-Object -First 1
Write-Host "[OK] Using plan: $($testPlan.name) - $($testPlan.pricePerMonth) SAR" -ForegroundColor Green

# Try to get current subscription
Write-Host "`n[3] Checking for existing subscription..." -ForegroundColor Yellow
$headers = @{ Authorization = "Bearer $token" }
try {
    $currentSub = Invoke-RestMethod -Uri "$baseUrl/subscriptions/current" -Method GET -Headers $headers -ErrorAction Stop
    $subscriptionId = $currentSub.data.id
    Write-Host "[OK] Found existing subscription ID: $subscriptionId" -ForegroundColor Green
} catch {
    Write-Host "[INFO] No subscription found, will use a test subscription ID" -ForegroundColor Yellow
    # For testing, we'll use subscription ID 1 (assuming it exists from seeding)
    $subscriptionId = 1
}

# Test MyFatoorah Payment
Write-Host "`n[4] Testing MyFatoorah payment initiation..." -ForegroundColor Yellow
$paymentBody = @{
    subscriptionId = $subscriptionId
    amount = [decimal]$testPlan.pricePerMonth
    currency = "SAR"
    paymentMethod = "myfatoorah"
    description = "Test payment for subscription"
} | ConvertTo-Json

Write-Host "Payment body: $paymentBody" -ForegroundColor Gray

try {
    $myfatoorah = Invoke-RestMethod -Uri "$baseUrl/payment/myfatoorah/initiate" -Method POST -Body $paymentBody -ContentType "application/json" -Headers $headers -ErrorAction Stop
    Write-Host "[OK] MyFatoorah payment initiated successfully" -ForegroundColor Green
    Write-Host "    Invoice ID: $($myfatoorah.data.invoiceId)" -ForegroundColor Gray
    Write-Host "    Payment URL: $($myfatoorah.data.paymentUrl)" -ForegroundColor Gray
    Write-Host "`n    TO COMPLETE PAYMENT: Navigate to the payment URL above" -ForegroundColor Yellow

    $invoiceId = $myfatoorah.data.invoiceId

    # Get payment history to verify payment was created
    Write-Host "`n[5] Verifying payment record was created..." -ForegroundColor Yellow
    $payments = Invoke-RestMethod -Uri "$baseUrl/payment/manager/payments" -Method GET -Headers $headers
    $latestPayment = $payments.data | Where-Object { $_.transactionId -eq $invoiceId } | Select-Object -First 1

    if ($latestPayment) {
        Write-Host "[OK] Payment record found" -ForegroundColor Green
        Write-Host "    Payment ID: $($latestPayment.id)" -ForegroundColor Gray
        Write-Host "    Transaction ID: $($latestPayment.transactionId)" -ForegroundColor Gray
        Write-Host "    Amount: $($latestPayment.amount) $($latestPayment.currency)" -ForegroundColor Gray
        Write-Host "    Status: $($latestPayment.status)" -ForegroundColor Gray
        Write-Host "    Method: $($latestPayment.paymentMethod)" -ForegroundColor Gray
    } else {
        Write-Host "[WARN] Payment record not found in payment history" -ForegroundColor Yellow
    }

} catch {
    $errorDetail = $_.ErrorDetails.Message | ConvertFrom-Json
    Write-Host "[ERROR] MyFatoorah payment failed" -ForegroundColor Red
    Write-Host "    Error: $($errorDetail.message)" -ForegroundColor Red
}

# Test Stripe Payment
Write-Host "`n[6] Testing Stripe payment initiation..." -ForegroundColor Yellow
$paymentBody = @{
    subscriptionId = $subscriptionId
    amount = [decimal]$testPlan.pricePerMonth
    currency = "SAR"
    paymentMethod = "stripe"
    description = "Test payment for subscription"
} | ConvertTo-Json

try {
    $stripe = Invoke-RestMethod -Uri "$baseUrl/payment/stripe/create-intent" -Method POST -Body $paymentBody -ContentType "application/json" -Headers $headers -ErrorAction Stop
    Write-Host "[OK] Stripe payment intent created" -ForegroundColor Green
    Write-Host "    Payment Intent ID: $($stripe.data.paymentIntentId)" -ForegroundColor Gray
    Write-Host "    Client Secret: $($stripe.data.clientSecret.Substring(0,30))..." -ForegroundColor Gray
    Write-Host "`n    TO COMPLETE PAYMENT: Use Stripe.js with the client secret" -ForegroundColor Yellow
} catch {
    $errorDetail = $_.ErrorDetails.Message | ConvertFrom-Json
    Write-Host "[INFO] Stripe payment: $($errorDetail.message)" -ForegroundColor Yellow
}

# Display payment workflow
Write-Host "`n========== PAYMENT WORKFLOW EXPLAINED ==========`n" -ForegroundColor Cyan
Write-Host "1. SUBSCRIPTION CREATION" -ForegroundColor Yellow
Write-Host "   Manager registers and creates a subscription (IsActive = false)`n"

Write-Host "2. PAYMENT INITIATION" -ForegroundColor Yellow
Write-Host "   - Call POST /payment/myfatoorah/initiate (or stripe/paytabs)"
Write-Host "   - System creates Payment record with Status='Pending'"
Write-Host "   - Returns payment URL and invoice/transaction ID`n"

Write-Host "3. USER COMPLETES PAYMENT" -ForegroundColor Yellow
Write-Host "   - User is redirected to payment gateway (MyFatoorah/Stripe/PayTabs)"
Write-Host "   - User enters payment details and completes payment`n"

Write-Host "4. PAYMENT CALLBACK" -ForegroundColor Yellow
Write-Host "   - Gateway calls callback URL: /payment/myfatoorah/callback?invoiceId=XXX"
Write-Host "   - System verifies payment with gateway API"
Write-Host "   - If successful, calls HandleSuccessfulPaymentAsync()`n"

Write-Host "5. SUBSCRIPTION ACTIVATION (Automatic)" -ForegroundColor Yellow
Write-Host "   - Payment.Status set to 'Completed'"
Write-Host "   - Payment.PaidAt set to current time"
Write-Host "   - Subscription.IsActive set to true"
Write-Host "   - Subscription.EndDate extended by 1 month"
Write-Host "   - Manager.SubscriptionEndsAt updated`n"

Write-Host "6. ACCESS GRANTED" -ForegroundColor Yellow
Write-Host "   - Manager can now access all features"
Write-Host "   - RequireActiveSubscription filter allows access`n"

Write-Host "TESTING NOTES:" -ForegroundColor Cyan
Write-Host "- Payment gateways require valid API credentials"
Write-Host "- In test mode, use gateway test cards/accounts"
Write-Host "- Callbacks require publicly accessible URL or ngrok"
Write-Host "- For development, you can manually call HandleSuccessfulPaymentAsync"
Write-Host ""

Write-Host "========================================`n" -ForegroundColor Cyan
