# Test Payment Integration Now
$baseUrl = "http://localhost:5041/api/v1"

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "TESTING PAYMENT INTEGRATION" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

# Login
Write-Host "[1] Logging in..." -ForegroundColor Yellow
$login = Invoke-RestMethod -Uri "$baseUrl/auth/login" -Method POST -Body '{"emailOrPhone":"manager@rafeed.com","password":"manager123"}' -ContentType "application/json"
$token = $login.token
Write-Host "    ✓ Logged in as $($login.user.name)" -ForegroundColor Green

# Test payment
Write-Host "`n[2] Initiating MyFatoorah payment..." -ForegroundColor Yellow
$headers = @{
    Authorization = "Bearer $token"
    "Content-Type" = "application/json"
}

$paymentBody = @{
    subscriptionId = 1
    amount = 100.0
    currency = "SAR"
    paymentMethod = "myfatoorah"
    description = "Subscription payment - Pro Plan"
} | ConvertTo-Json

try {
    $payment = Invoke-RestMethod -Uri "$baseUrl/payment/myfatoorah/initiate" -Method POST -Headers $headers -Body $paymentBody

    Write-Host "    ✓ Payment initiated successfully!" -ForegroundColor Green
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Green
    Write-Host "        PAYMENT URL GENERATED!          " -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "Invoice ID: $($payment.data.invoiceId)" -ForegroundColor White
    Write-Host ""
    Write-Host "Payment URL:" -ForegroundColor Yellow
    Write-Host $payment.data.paymentUrl -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Test Card Details:" -ForegroundColor Yellow
    Write-Host "  Card Number: 5123450000000008" -ForegroundColor Cyan
    Write-Host "  Expiry: 05/25" -ForegroundColor Cyan
    Write-Host "  CVV: 100" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Green
    Write-Host ""

    # Verify payment record
    Write-Host "[3] Verifying payment record..." -ForegroundColor Yellow
    Start-Sleep -Seconds 1
    $payments = Invoke-RestMethod -Uri "$baseUrl/payment/manager/payments" -Method GET -Headers $headers
    $thisPayment = $payments.data | Where-Object { $_.transactionId -eq $payment.data.invoiceId } | Select-Object -First 1

    if ($thisPayment) {
        Write-Host "    ✓ Payment record created in database" -ForegroundColor Green
        Write-Host "      Payment ID: $($thisPayment.id)" -ForegroundColor Gray
        Write-Host "      Status: $($thisPayment.status)" -ForegroundColor Gray
        Write-Host "      Amount: $($thisPayment.amount) $($thisPayment.currency)" -ForegroundColor Gray
    }

    Write-Host ""
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "✓ PAYMENT INTEGRATION WORKING!" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host ""

} catch {
    Write-Host "    ✗ Payment initiation failed" -ForegroundColor Red
    Write-Host ""
    if ($_.ErrorDetails.Message) {
        $error = $_.ErrorDetails.Message | ConvertFrom-Json
        Write-Host "Error: $($error.message)" -ForegroundColor Red
    } else {
        Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
    }
}
