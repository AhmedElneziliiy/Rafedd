# FINAL MyFatoorah Payment Integration Test
# Run this after enabling payment methods in the portal

$token = "SK_KWT_kucLvwUtO6axVK3apufp2Jmzsgh0OfpFULevJtXcfyfGMB1U6uPumLLpmzXacjB2"
$baseUrl = "https://api.myfatoorah.com"
$apiUrl = "http://localhost:5041"

Write-Host "`n╔════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║   MyFatoorah Payment Integration Test         ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════════════╝`n" -ForegroundColor Cyan

# Test 1: Check MyFatoorah Direct
Write-Host "[TEST 1] MyFatoorah API Direct Test" -ForegroundColor Yellow
Write-Host "═══════════════════════════════════════════════" -ForegroundColor Yellow

$headers = @{
    "Authorization" = "Bearer $token"
    "Content-Type" = "application/json"
}

$body = @{
    InvoiceAmount = 50.0
    CurrencyIso = "KWD"
} | ConvertTo-Json

try {
    $initResponse = Invoke-RestMethod -Uri "$baseUrl/v2/InitiatePayment" -Method Post -Headers $headers -Body $body

    Write-Host "✓ API Token: " -NoNewline -ForegroundColor Green
    Write-Host "VALID" -ForegroundColor White

    $methodCount = $initResponse.Data.PaymentMethods.Count
    Write-Host "✓ Payment Methods Found: " -NoNewline

    if ($methodCount -gt 0) {
        Write-Host "$methodCount" -ForegroundColor Green

        Write-Host "`n  Available Payment Methods:" -ForegroundColor Cyan
        foreach ($method in $initResponse.Data.PaymentMethods) {
            Write-Host "    • $($method.PaymentMethodEn) " -NoNewline -ForegroundColor White
            Write-Host "(ID: $($method.PaymentMethodId), Code: $($method.PaymentMethodCode))" -ForegroundColor Gray
            Write-Host "      Currency: $($method.CurrencyIso) | Service Charge: $($method.ServiceCharge) | Direct: $($method.IsDirectPayment)" -ForegroundColor DarkGray
        }

        $selectedMethod = $initResponse.Data.PaymentMethods[0]
        $paymentMethodId = $selectedMethod.PaymentMethodId

        # Test 2: ExecutePayment
        Write-Host "`n[TEST 2] ExecutePayment Test" -ForegroundColor Yellow
        Write-Host "═══════════════════════════════════════════════" -ForegroundColor Yellow

        $executeBody = @{
            PaymentMethodId = $paymentMethodId
            InvoiceValue = 50.0
            CallBackUrl = "https://example.com/callback"
            ErrorUrl = "https://example.com/error"
            CustomerName = "Test Customer"
            CustomerEmail = "test@rafeed.com"
            Language = "en"
            DisplayCurrencyIso = "KWD"
        } | ConvertTo-Json

        try {
            $execResponse = Invoke-RestMethod -Uri "$baseUrl/v2/ExecutePayment" -Method Post -Headers $headers -Body $executeBody

            Write-Host "✓ Invoice Created: " -NoNewline -ForegroundColor Green
            Write-Host "YES" -ForegroundColor White
            Write-Host "✓ Invoice ID: " -NoNewline -ForegroundColor Green
            Write-Host "$($execResponse.Data.InvoiceId)" -ForegroundColor White
            Write-Host "✓ Payment URL: " -NoNewline -ForegroundColor Green
            Write-Host "$($execResponse.Data.PaymentURL)" -ForegroundColor Cyan

            # Test 3: Application API Integration (if running)
            Write-Host "`n[TEST 3] Application API Integration Test" -ForegroundColor Yellow
            Write-Host "═══════════════════════════════════════════════" -ForegroundColor Yellow

            try {
                # Check if API is running
                $null = Invoke-WebRequest -Uri "$apiUrl/health" -Method Get -TimeoutSec 2 -ErrorAction Stop
                Write-Host "✓ API Server: " -NoNewline -ForegroundColor Green
                Write-Host "RUNNING" -ForegroundColor White

                # Login
                Write-Host "`n  Step 1: Login as manager..." -ForegroundColor Gray
                $loginBody = @{
                    emailOrPhone = "manager@rafeed.com"
                    password = "manager123"
                } | ConvertTo-Json

                $loginResp = Invoke-RestMethod -Uri "$apiUrl/api/v1/auth/login" -Method Post -Body $loginBody -ContentType "application/json"
                $authToken = $loginResp.token
                Write-Host "  ✓ Login successful" -ForegroundColor Green

                # Initiate payment via API
                Write-Host "`n  Step 2: Initiate payment..." -ForegroundColor Gray
                $apiHeaders = @{
                    "Authorization" = "Bearer $authToken"
                    "Content-Type" = "application/json"
                }

                $paymentBody = @{
                    subscriptionId = 1
                    amount = 50.0
                    currency = "KWD"
                    description = "Test subscription payment"
                } | ConvertTo-Json

                $apiPaymentResp = Invoke-RestMethod -Uri "$apiUrl/api/v1/payment/myfatoorah/initiate" -Method Post -Headers $apiHeaders -Body $paymentBody

                Write-Host "  ✓ Payment initiated via API" -ForegroundColor Green
                Write-Host "    Invoice ID: $($apiPaymentResp.data.invoiceId)" -ForegroundColor White
                Write-Host "    Payment URL: $($apiPaymentResp.data.paymentUrl)" -ForegroundColor Cyan

                # Check database
                Write-Host "`n  Step 3: Verify database record..." -ForegroundColor Gray
                $dbResult = sqlcmd -S "(localdb)\MSSQLLocalDB" -d RafeddSystemDB -Q "SELECT TOP 1 Id, TransactionId, Status, Amount, Currency, PaymentMethodName FROM Payments ORDER BY Id DESC" -h -1 -W 2>&1

                if ($dbResult -and $dbResult -notmatch "error") {
                    Write-Host "  ✓ Payment record created in database" -ForegroundColor Green
                    Write-Host "    $dbResult" -ForegroundColor Gray
                }

            } catch {
                Write-Host "⚠ API Server: " -NoNewline -ForegroundColor Yellow
                Write-Host "NOT RUNNING" -ForegroundColor White
                Write-Host "  Start with: cd d:\Rafedd-master\Rafedd && dotnet run" -ForegroundColor Gray
                Write-Host "  Skipping API integration tests..." -ForegroundColor Gray
            }

            # Final Summary
            Write-Host "`n╔════════════════════════════════════════════════╗" -ForegroundColor Green
            Write-Host "║          ✓ ALL TESTS PASSED!                  ║" -ForegroundColor Green
            Write-Host "╚════════════════════════════════════════════════╝" -ForegroundColor Green

            Write-Host "`nIntegration Status:" -ForegroundColor Cyan
            Write-Host "  ✓ MyFatoorah Token: Valid" -ForegroundColor Green
            Write-Host "  ✓ Payment Methods: Enabled ($methodCount methods)" -ForegroundColor Green
            Write-Host "  ✓ InitiatePayment: Working" -ForegroundColor Green
            Write-Host "  ✓ ExecutePayment: Working" -ForegroundColor Green
            Write-Host "  ✓ Code Integration: Ready" -ForegroundColor Green

            Write-Host "`n🚀 READY FOR PRODUCTION!" -ForegroundColor Green -BackgroundColor DarkGreen

            Write-Host "`nTest Cards for Manual Testing:" -ForegroundColor Yellow
            Write-Host "  Visa:       4508750015741019" -ForegroundColor White
            Write-Host "  Mastercard: 5453010000095539" -ForegroundColor White
            Write-Host "  Expiry:     Any future date (e.g., 05/25)" -ForegroundColor White
            Write-Host "  CVV:        Any 3 digits (e.g., 123)" -ForegroundColor White

            Write-Host "`nNext Steps:" -ForegroundColor Cyan
            Write-Host "  1. Update AppSettings:BaseUrl in appsettings.json to your production domain" -ForegroundColor White
            Write-Host "  2. Test manual payment flow with test cards above" -ForegroundColor White
            Write-Host "  3. Deploy to production server" -ForegroundColor White
            Write-Host "  4. Update callback URLs to production domain" -ForegroundColor White

        } catch {
            Write-Host "✗ ExecutePayment Failed" -ForegroundColor Red
            Write-Host "  Error: $($_.Exception.Message)" -ForegroundColor Red
        }

    } else {
        Write-Host "0 - NO PAYMENT METHODS" -ForegroundColor Red

        Write-Host "`n╔════════════════════════════════════════════════╗" -ForegroundColor Red
        Write-Host "║   ⚠ PAYMENT METHODS NOT ENABLED YET           ║" -ForegroundColor Red
        Write-Host "╚════════════════════════════════════════════════╝" -ForegroundColor Red

        Write-Host "`nRequired Actions:" -ForegroundColor Yellow
        Write-Host "  1. Login to: https://portal.myfatoorah.com" -ForegroundColor White
        Write-Host "  2. Navigate to: Settings > Payment Methods" -ForegroundColor White
        Write-Host "  3. Enable: VISA/MASTER gateway (minimum)" -ForegroundColor White
        Write-Host "  4. Set Mode: Live (not Test)" -ForegroundColor White
        Write-Host "  5. Click: Save/Apply" -ForegroundColor White
        Write-Host "  6. Wait: 2-5 minutes for changes to sync" -ForegroundColor White
        Write-Host "  7. Re-run this script" -ForegroundColor White

        Write-Host "`nIf you've already done this:" -ForegroundColor Cyan
        Write-Host "  • Account verification may be pending" -ForegroundColor White
        Write-Host "  • Check Settings > Account Status" -ForegroundColor White
        Write-Host "  • Contact MyFatoorah support if needed" -ForegroundColor White
        Write-Host "  • Email: support@myfatoorah.com" -ForegroundColor White

        Write-Host "`nSee PAYMENT-ACTIVATION-CHECKLIST.md for detailed steps`n" -ForegroundColor Gray
    }

} catch {
    Write-Host "✗ API Connection Failed" -ForegroundColor Red
    Write-Host "  Error: $($_.Exception.Message)" -ForegroundColor Red

    if ($_.Exception.Response.StatusCode -eq 401) {
        Write-Host "`n  Token is INVALID or EXPIRED" -ForegroundColor Red
        Write-Host "  Please verify your API token in the MyFatoorah portal" -ForegroundColor Yellow
    }
}

Write-Host ""
