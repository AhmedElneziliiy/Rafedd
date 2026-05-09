# Simple Payment Integration Test
$baseUrl = "http://localhost:5041/api/v1"

Write-Host "`n========== PAYMENT INTEGRATION TEST ==========`n" -ForegroundColor Cyan

# Step 1: Get Subscription Plans
Write-Host "[1] Testing GET /subscriptions/plans..." -ForegroundColor Yellow
try {
    $plans = Invoke-RestMethod -Uri "$baseUrl/subscriptions/plans" -Method GET
    Write-Host "[OK] Retrieved $($plans.data.Count) plans" -ForegroundColor Green
    foreach ($plan in $plans.data) {
        Write-Host "    Plan: $($plan.name) - $($plan.pricePerMonth) SAR - Max: $($plan.maxEmployees) employees" -ForegroundColor Gray
    }
    $testPlanId = $plans.data[0].id
    $testAmount = $plans.data[0].pricePerMonth
} catch {
    Write-Host "[FAIL] $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# Step 2: Manager Login
Write-Host "`n[2] Testing POST /auth/login..." -ForegroundColor Yellow
try {
    $loginBody = @{ emailOrPhone = "manager@rafeed.com"; password = "manager123" } | ConvertTo-Json
    $login = Invoke-RestMethod -Uri "$baseUrl/auth/login" -Method POST -Body $loginBody -ContentType "application/json"
    Write-Host "[OK] Manager logged in successfully" -ForegroundColor Green
    Write-Host "    Has Active Subscription: $($login.subscriptionStatus.hasActiveSubscription)" -ForegroundColor Gray
    $token = $login.token
} catch {
    Write-Host "[FAIL] $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# Step 3: Get Current Subscription
Write-Host "`n[3] Testing GET /subscriptions/current..." -ForegroundColor Yellow
try {
    $headers = @{ Authorization = "Bearer $token" }
    $currentSub = Invoke-RestMethod -Uri "$baseUrl/subscriptions/current" -Method GET -Headers $headers
    Write-Host "[OK] Current subscription retrieved" -ForegroundColor Green
    Write-Host "    Subscription ID: $($currentSub.data.id)" -ForegroundColor Gray
    Write-Host "    Plan: $($currentSub.data.planName)" -ForegroundColor Gray
    Write-Host "    Active: $($currentSub.data.isActive)" -ForegroundColor Gray
    Write-Host "    End Date: $($currentSub.data.endDate)" -ForegroundColor Gray
    $subscriptionId = $currentSub.data.id
} catch {
    Write-Host "[INFO] No active subscription found" -ForegroundColor Yellow
    $subscriptionId = $null
}

# Step 4: Create Subscription if needed
if (-not $subscriptionId) {
    Write-Host "`n[4] Testing POST /subscriptions..." -ForegroundColor Yellow
    try {
        $headers = @{ Authorization = "Bearer $token" }
        $createSubBody = @{ planId = $testPlanId; autoRenew = $true } | ConvertTo-Json
        $newSub = Invoke-RestMethod -Uri "$baseUrl/subscriptions" -Method POST -Body $createSubBody -ContentType "application/json" -Headers $headers
        Write-Host "[OK] Subscription created" -ForegroundColor Green
        Write-Host "    Subscription ID: $($newSub.data.id)" -ForegroundColor Gray
        $subscriptionId = $newSub.data.id
    } catch {
        Write-Host "[FAIL] $($_.Exception.Message)" -ForegroundColor Red
        exit 1
    }
} else {
    Write-Host "`n[4] Subscription already exists (ID: $subscriptionId)" -ForegroundColor Yellow
}

# Step 5: Test MyFatoorah Payment Initiation
Write-Host "`n[5] Testing POST /payment/myfatoorah/initiate..." -ForegroundColor Yellow
try {
    $headers = @{ Authorization = "Bearer $token" }
    $paymentBody = @{
        subscriptionId = $subscriptionId
        amount = $testAmount
        currency = "SAR"
        paymentMethod = "myfatoorah"
        description = "Test payment"
    } | ConvertTo-Json
    $myfatoorah = Invoke-RestMethod -Uri "$baseUrl/payment/myfatoorah/initiate" -Method POST -Body $paymentBody -ContentType "application/json" -Headers $headers
    Write-Host "[OK] MyFatoorah payment initiated" -ForegroundColor Green
    Write-Host "    Payment URL: $($myfatoorah.data.paymentUrl)" -ForegroundColor Gray
    Write-Host "    Invoice ID: $($myfatoorah.data.invoiceId)" -ForegroundColor Gray
} catch {
    Write-Host "[INFO] MyFatoorah: $($_.Exception.Message)" -ForegroundColor Yellow
}

# Step 6: Test Stripe Payment Intent
Write-Host "`n[6] Testing POST /payment/stripe/create-intent..." -ForegroundColor Yellow
try {
    $headers = @{ Authorization = "Bearer $token" }
    $paymentBody = @{
        subscriptionId = $subscriptionId
        amount = $testAmount
        currency = "SAR"
        paymentMethod = "stripe"
        description = "Test payment"
    } | ConvertTo-Json
    $stripe = Invoke-RestMethod -Uri "$baseUrl/payment/stripe/create-intent" -Method POST -Body $paymentBody -ContentType "application/json" -Headers $headers
    Write-Host "[OK] Stripe payment intent created" -ForegroundColor Green
    Write-Host "    Payment Intent ID: $($stripe.data.paymentIntentId)" -ForegroundColor Gray
} catch {
    Write-Host "[INFO] Stripe: $($_.Exception.Message)" -ForegroundColor Yellow
}

# Step 7: Test PayTabs Payment
Write-Host "`n[7] Testing POST /payment/paytabs/initiate..." -ForegroundColor Yellow
try {
    $headers = @{ Authorization = "Bearer $token" }
    $paymentBody = @{
        subscriptionId = $subscriptionId
        amount = $testAmount
        currency = "SAR"
        paymentMethod = "paytabs"
        description = "Test payment"
    } | ConvertTo-Json
    $paytabs = Invoke-RestMethod -Uri "$baseUrl/payment/paytabs/initiate" -Method POST -Body $paymentBody -ContentType "application/json" -Headers $headers
    Write-Host "[OK] PayTabs payment initiated" -ForegroundColor Green
    Write-Host "    Payment URL: $($paytabs.data.paymentUrl)" -ForegroundColor Gray
} catch {
    Write-Host "[INFO] PayTabs: $($_.Exception.Message)" -ForegroundColor Yellow
}

# Step 8: Get Payment History
Write-Host "`n[8] Testing GET /payment/manager/payments..." -ForegroundColor Yellow
try {
    $headers = @{ Authorization = "Bearer $token" }
    $payments = Invoke-RestMethod -Uri "$baseUrl/payment/manager/payments" -Method GET -Headers $headers
    Write-Host "[OK] Payment history retrieved" -ForegroundColor Green
    Write-Host "    Total Payments: $($payments.data.Count)" -ForegroundColor Gray
    foreach ($payment in $payments.data | Select-Object -First 3) {
        Write-Host "    Payment: ID=$($payment.id) | Amount=$($payment.amount) $($payment.currency) | Status=$($payment.status) | Method=$($payment.paymentMethod)" -ForegroundColor Gray
    }
} catch {
    Write-Host "[INFO] $($_.Exception.Message)" -ForegroundColor Yellow
}

Write-Host "`n========== TEST COMPLETE ==========`n" -ForegroundColor Cyan
