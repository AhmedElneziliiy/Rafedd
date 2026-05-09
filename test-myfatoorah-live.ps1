# Live MyFatoorah Payment Test with Demo Token
$baseUrl = "http://localhost:5041/api/v1"

Write-Host "`n========== MYFATOORAH LIVE PAYMENT TEST ==========`n" -ForegroundColor Cyan

# Step 1: Login
Write-Host "[1] Logging in as manager..." -ForegroundColor Yellow
$loginBody = '{"emailOrPhone":"manager@rafeed.com","password":"manager123"}'
try {
    $login = Invoke-RestMethod -Uri "$baseUrl/auth/login" -Method POST -Body $loginBody -ContentType "application/json"
    $token = $login.token
    Write-Host "[OK] Logged in successfully" -ForegroundColor Green
} catch {
    Write-Host "[FAIL] Login failed: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# Step 2: Get subscription (or use test subscription ID)
Write-Host "`n[2] Getting subscription..." -ForegroundColor Yellow
$headers = @{ Authorization = "Bearer $token" }
try {
    $currentSub = Invoke-RestMethod -Uri "$baseUrl/subscriptions/current" -Method GET -Headers $headers -ErrorAction Stop
    $subscriptionId = $currentSub.data.id
    Write-Host "[OK] Using existing subscription ID: $subscriptionId" -ForegroundColor Green
} catch {
    Write-Host "[INFO] No active subscription, using test subscription ID: 1" -ForegroundColor Yellow
    $subscriptionId = 1
}

# Step 3: Initiate MyFatoorah Payment
Write-Host "`n[3] Initiating MyFatoorah payment..." -ForegroundColor Yellow
$paymentBody = @{
    subscriptionId = $subscriptionId
    amount = 50.00
    currency = "SAR"
    paymentMethod = "myfatoorah"
    description = "Test subscription payment"
} | ConvertTo-Json

Write-Host "Request body:" -ForegroundColor Gray
Write-Host $paymentBody -ForegroundColor Gray

try {
    $payment = Invoke-RestMethod -Uri "$baseUrl/payment/myfatoorah/initiate" -Method POST -Body $paymentBody -ContentType "application/json" -Headers $headers -ErrorAction Stop

    Write-Host "`n[SUCCESS] MyFatoorah payment initiated!" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "Payment URL: $($payment.data.paymentUrl)" -ForegroundColor Yellow
    Write-Host "Invoice ID: $($payment.data.invoiceId)" -ForegroundColor Yellow
    Write-Host "Invoice Ref: $($payment.data.invoiceRef)" -ForegroundColor Yellow
    Write-Host "========================================" -ForegroundColor Cyan

    # Step 4: Verify payment record was created
    Write-Host "`n[4] Verifying payment record in database..." -ForegroundColor Yellow
    Start-Sleep -Seconds 1

    $payments = Invoke-RestMethod -Uri "$baseUrl/payment/manager/payments" -Method GET -Headers $headers
    $latestPayment = $payments.data | Where-Object { $_.transactionId -eq $payment.data.invoiceId } | Select-Object -First 1

    if ($latestPayment) {
        Write-Host "[OK] Payment record created in database" -ForegroundColor Green
        Write-Host "    Payment ID: $($latestPayment.id)" -ForegroundColor Gray
        Write-Host "    Transaction ID: $($latestPayment.transactionId)" -ForegroundColor Gray
        Write-Host "    Amount: $($latestPayment.amount) $($latestPayment.currency)" -ForegroundColor Gray
        Write-Host "    Status: $($latestPayment.status)" -ForegroundColor Gray
        Write-Host "    Payment Method: $($latestPayment.paymentMethod)" -ForegroundColor Gray
    } else {
        Write-Host "[WARN] Payment record not found yet" -ForegroundColor Yellow
    }

    # Instructions for completing payment
    Write-Host "`n========================================" -ForegroundColor Cyan
    Write-Host "NEXT STEPS TO COMPLETE PAYMENT:" -ForegroundColor Yellow
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "1. Open this URL in your browser:" -ForegroundColor White
    Write-Host "   $($payment.data.paymentUrl)" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "2. Use MyFatoorah test card:" -ForegroundColor White
    Write-Host "   Card Number: 5123450000000008" -ForegroundColor Cyan
    Write-Host "   Expiry: 05/25" -ForegroundColor Cyan
    Write-Host "   CVV: 100" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "3. Complete the payment on MyFatoorah" -ForegroundColor White
    Write-Host ""
    Write-Host "4. MyFatoorah will call the callback:" -ForegroundColor White
    Write-Host "   $baseUrl/payment/myfatoorah/callback" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "5. System will automatically:" -ForegroundColor White
    Write-Host "   - Verify payment with MyFatoorah API" -ForegroundColor Gray
    Write-Host "   - Update Payment.Status to 'Completed'" -ForegroundColor Gray
    Write-Host "   - Set Subscription.IsActive to true" -ForegroundColor Gray
    Write-Host "   - Extend Subscription.EndDate by 1 month" -ForegroundColor Gray
    Write-Host ""
    Write-Host "6. Check subscription status after payment:" -ForegroundColor White
    Write-Host "   GET $baseUrl/subscriptions/current" -ForegroundColor Cyan
    Write-Host "========================================`n" -ForegroundColor Cyan

    # Save payment info for reference
    $paymentInfo = @{
        PaymentUrl = $payment.data.paymentUrl
        InvoiceId = $payment.data.invoiceId
        SubscriptionId = $subscriptionId
        Amount = 50.00
        Currency = "SAR"
        TestCard = "5123450000000008"
        TestExpiry = "05/25"
        TestCVV = "100"
        Timestamp = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
    }

    $paymentInfo | ConvertTo-Json | Out-File "d:\Rafedd-master\last-payment-test.json"
    Write-Host "[INFO] Payment details saved to: d:\Rafedd-master\last-payment-test.json" -ForegroundColor Cyan

} catch {
    Write-Host "`n[ERROR] Payment initiation failed" -ForegroundColor Red

    if ($_.ErrorDetails.Message) {
        try {
            $errorDetail = $_.ErrorDetails.Message | ConvertFrom-Json
            Write-Host "Error message: $($errorDetail.message)" -ForegroundColor Red
            if ($errorDetail.errors) {
                Write-Host "Errors:" -ForegroundColor Red
                $errorDetail.errors | ForEach-Object { Write-Host "  - $_" -ForegroundColor Red }
            }
        } catch {
            Write-Host "Raw error: $($_.ErrorDetails.Message)" -ForegroundColor Red
        }
    } else {
        Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
    }

    Write-Host "`nTroubleshooting:" -ForegroundColor Yellow
    Write-Host "1. Check if API is running on $baseUrl" -ForegroundColor Gray
    Write-Host "2. Verify MyFatoorah API token in appsettings.json" -ForegroundColor Gray
    Write-Host "3. Check subscription ID exists in database" -ForegroundColor Gray
    Write-Host "4. Review API logs for detailed error" -ForegroundColor Gray
}

Write-Host "`n========== TEST COMPLETE ==========`n" -ForegroundColor Cyan
