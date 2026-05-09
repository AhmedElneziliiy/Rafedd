# Complete Payment Flow Test - Creates subscription then tests payment
$baseUrl = "http://localhost:5041/api/v1"

Write-Host "`n========== COMPLETE PAYMENT FLOW TEST ==========`n" -ForegroundColor Cyan

# Step 1: Login
Write-Host "[1] Manager Login..." -ForegroundColor Yellow
$loginBody = '{"emailOrPhone":"manager@rafeed.com","password":"manager123"}'
try {
    $login = Invoke-RestMethod -Uri "$baseUrl/auth/login" -Method POST -Body $loginBody -ContentType "application/json"
    $token = $login.token
    Write-Host "[OK] Logged in" -ForegroundColor Green
    Write-Host "    Has Active Subscription: $($login.subscriptionStatus.hasActiveSubscription)" -ForegroundColor Gray
} catch {
    Write-Host "[FAIL] Login failed" -ForegroundColor Red
    exit 1
}

# Step 2: Get or Create Subscription
Write-Host "`n[2] Getting/Creating Subscription..." -ForegroundColor Yellow
$headers = @{ Authorization = "Bearer $token" }
$subscriptionId = $null

try {
    $currentSub = Invoke-RestMethod -Uri "$baseUrl/subscriptions/current" -Method GET -Headers $headers -ErrorAction Stop
    $subscriptionId = $currentSub.data.id
    Write-Host "[OK] Found existing subscription" -ForegroundColor Green
    Write-Host "    Subscription ID: $subscriptionId" -ForegroundColor Gray
    Write-Host "    Plan: $($currentSub.data.planName)" -ForegroundColor Gray
    Write-Host "    Is Active: $($currentSub.data.isActive)" -ForegroundColor Gray
} catch {
    Write-Host "[INFO] No subscription found, creating new one..." -ForegroundColor Yellow

    # Get available plans
    $plans = Invoke-RestMethod -Uri "$baseUrl/subscriptions/plans" -Method GET
    $basicPlan = $plans.data | Where-Object { $_.name -eq "Basic" } | Select-Object -First 1

    # Create subscription
    $createSubBody = @{
        planId = $basicPlan.id
        autoRenew = $true
    } | ConvertTo-Json

    try {
        $newSub = Invoke-RestMethod -Uri "$baseUrl/subscriptions" -Method POST -Body $createSubBody -ContentType "application/json" -Headers $headers -ErrorAction Stop
        $subscriptionId = $newSub.data.id
        Write-Host "[OK] Subscription created" -ForegroundColor Green
        Write-Host "    Subscription ID: $subscriptionId" -ForegroundColor Gray
        Write-Host "    Plan: $($newSub.data.planName)" -ForegroundColor Gray
        Write-Host "    Is Active: $($newSub.data.isActive) (will activate after payment)" -ForegroundColor Gray
    } catch {
        if ($_.ErrorDetails.Message) {
            $error = $_.ErrorDetails.Message | ConvertFrom-Json
            Write-Host "[ERROR] $($error.message)" -ForegroundColor Red
        } else {
            Write-Host "[ERROR] $($_.Exception.Message)" -ForegroundColor Red
        }

        # Try to use an existing subscription by querying payment history
        Write-Host "[INFO] Checking payment history for subscription ID..." -ForegroundColor Yellow
        try {
            $payments = Invoke-RestMethod -Uri "$baseUrl/payment/manager/payments" -Method GET -Headers $headers
            if ($payments.data.Count -gt 0) {
                $subscriptionId = $payments.data[0].subscriptionId
                Write-Host "[OK] Found subscription ID from payment history: $subscriptionId" -ForegroundColor Green
            } else {
                Write-Host "[ERROR] No subscriptions found. Cannot proceed." -ForegroundColor Red
                exit 1
            }
        } catch {
            Write-Host "[ERROR] Cannot find or create subscription" -ForegroundColor Red
            exit 1
        }
    }
}

if (-not $subscriptionId) {
    Write-Host "[ERROR] No subscription ID available" -ForegroundColor Red
    exit 1
}

# Step 3: Initiate MyFatoorah Payment
Write-Host "`n[3] Initiating MyFatoorah Payment..." -ForegroundColor Yellow
$paymentBody = @{
    subscriptionId = $subscriptionId
    amount = 50.00
    currency = "SAR"
    paymentMethod = "myfatoorah"
    description = "Subscription payment - Basic Plan"
} | ConvertTo-Json

try {
    $payment = Invoke-RestMethod -Uri "$baseUrl/payment/myfatoorah/initiate" -Method POST -Body $paymentBody -ContentType "application/json" -Headers $headers -ErrorAction Stop

    Write-Host "`n[SUCCESS] Payment URL Generated!" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "Invoice ID: $($payment.data.invoiceId)" -ForegroundColor White
    Write-Host "Payment URL:" -ForegroundColor White
    Write-Host "$($payment.data.paymentUrl)" -ForegroundColor Cyan
    Write-Host "========================================`n" -ForegroundColor Cyan

    # Verify payment record
    Write-Host "[4] Verifying payment record..." -ForegroundColor Yellow
    Start-Sleep -Seconds 1
    $payments = Invoke-RestMethod -Uri "$baseUrl/payment/manager/payments" -Method GET -Headers $headers
    $thisPayment = $payments.data | Where-Object { $_.transactionId -eq $payment.data.invoiceId } | Select-Object -First 1

    if ($thisPayment) {
        Write-Host "[OK] Payment record created" -ForegroundColor Green
        Write-Host "    Status: $($thisPayment.status)" -ForegroundColor Gray
        Write-Host "    Method: $($thisPayment.paymentMethod)" -ForegroundColor Gray
    }

    # Instructions
    Write-Host "`n========================================" -ForegroundColor Cyan
    Write-Host "PAYMENT IS READY!" -ForegroundColor Yellow
    Write-Host "========================================`n" -ForegroundColor Cyan

    Write-Host "To complete the payment:" -ForegroundColor White
    Write-Host ""
    Write-Host "1. Copy this URL:" -ForegroundColor Yellow
    Write-Host "   $($payment.data.paymentUrl)" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "2. Open it in your browser" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "3. Use MyFatoorah test card:" -ForegroundColor Yellow
    Write-Host "   Card: 5123450000000008" -ForegroundColor Cyan
    Write-Host "   Expiry: 05/25" -ForegroundColor Cyan
    Write-Host "   CVV: 100" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "4. After payment, MyFatoorah will:" -ForegroundColor Yellow
    Write-Host "   - Call the callback endpoint" -ForegroundColor Gray
    Write-Host "   - System verifies payment" -ForegroundColor Gray
    Write-Host "   - Subscription gets activated automatically" -ForegroundColor Gray
    Write-Host ""
    Write-Host "5. Check subscription status:" -ForegroundColor Yellow
    Write-Host "   Invoke-RestMethod '$baseUrl/subscriptions/current' -Headers @{Authorization='Bearer $token'}" -ForegroundColor Cyan
    Write-Host "`n========================================`n" -ForegroundColor Cyan

    # Save details
    @{
        SubscriptionId = $subscriptionId
        InvoiceId = $payment.data.invoiceId
        PaymentUrl = $payment.data.paymentUrl
        Amount = 50.00
        Currency = "SAR"
        Token = $token
        Timestamp = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
    } | ConvertTo-Json | Out-File "d:\Rafedd-master\payment-details.json"

    Write-Host "[INFO] Payment details saved to: payment-details.json`n" -ForegroundColor Cyan

} catch {
    Write-Host "`n[ERROR] Payment initiation failed" -ForegroundColor Red

    if ($_.ErrorDetails.Message) {
        try {
            $error = $_.ErrorDetails.Message | ConvertFrom-Json
            Write-Host "Message: $($error.message)" -ForegroundColor Red
        } catch {
            Write-Host "Raw error: $($_.ErrorDetails.Message)" -ForegroundColor Red
        }
    }

    Write-Host "Exception: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "`nCheck API logs for details`n" -ForegroundColor Yellow
}

Write-Host "========== TEST COMPLETE ==========`n" -ForegroundColor Cyan
