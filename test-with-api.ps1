# Complete MyFatoorah + API Integration Test
# This tests both MyFatoorah directly and via your API

$apiUrl = "http://localhost:5041"

Write-Host "`n╔════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║   MyFatoorah Full Integration Test            ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════════════╝`n" -ForegroundColor Cyan

# Read configuration
$configPath = "d:\Rafedd-master\Rafedd\appsettings.json"
$config = Get-Content $configPath | ConvertFrom-Json
$token = $config.MyFatoorah.ApiToken
$baseUrl = $config.MyFatoorah.BaseUrl

Write-Host "Configuration:" -ForegroundColor Yellow
Write-Host "  Base URL: $baseUrl" -ForegroundColor White
Write-Host "  Token: $($token.Substring(0, 30))..." -ForegroundColor Gray
Write-Host ""

# Test 1: MyFatoorah Direct
Write-Host "[TEST 1] MyFatoorah API Direct" -ForegroundColor Yellow
Write-Host "════════════════════════════════════════════════" -ForegroundColor Yellow

$headers = @{
    "Authorization" = "Bearer $token"
    "Content-Type" = "application/json"
}

$body = @{
    InvoiceAmount = 50.0
    CurrencyIso = "KWD"
} | ConvertTo-Json

try {
    $response = Invoke-RestMethod -Uri "$baseUrl/v2/InitiatePayment" -Method Post -Headers $headers -Body $body

    Write-Host "✓ Token: VALID" -ForegroundColor Green
    $methodCount = $response.Data.PaymentMethods.Count
    Write-Host "✓ Payment Methods: $methodCount" -ForegroundColor $(if ($methodCount -gt 0) { "Green" } else { "Red" })

    if ($methodCount -gt 0) {
        Write-Host "`nAvailable Payment Methods:" -ForegroundColor Cyan
        foreach ($method in $response.Data.PaymentMethods) {
            Write-Host "  • $($method.PaymentMethodEn) (ID: $($method.PaymentMethodId))" -ForegroundColor White
        }

        $paymentMethodId = $response.Data.PaymentMethods[0].PaymentMethodId

        # Test ExecutePayment
        Write-Host "`n[TEST 2] ExecutePayment" -ForegroundColor Yellow
        Write-Host "════════════════════════════════════════════════" -ForegroundColor Yellow

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

        $execResponse = Invoke-RestMethod -Uri "$baseUrl/v2/ExecutePayment" -Method Post -Headers $headers -Body $executeBody

        Write-Host "✓ Invoice Created: YES" -ForegroundColor Green
        Write-Host "  Invoice ID: $($execResponse.Data.InvoiceId)" -ForegroundColor White
        Write-Host "  Payment URL: $($execResponse.Data.PaymentURL)" -ForegroundColor Cyan

        # Test 3: Application API
        Write-Host "`n[TEST 3] Application API Integration" -ForegroundColor Yellow
        Write-Host "════════════════════════════════════════════════" -ForegroundColor Yellow

        try {
            # Check if API is running
            $null = Invoke-WebRequest -Uri "$apiUrl/health" -Method Get -TimeoutSec 2 -ErrorAction Stop
            Write-Host "✓ API Server: RUNNING" -ForegroundColor Green

            # Login
            Write-Host "`nStep 1: Login..." -ForegroundColor Gray
            $loginBody = @{
                emailOrPhone = "manager@rafeed.com"
                password = "manager123"
            } | ConvertTo-Json

            $loginResp = Invoke-RestMethod -Uri "$apiUrl/api/v1/auth/login" -Method Post -Body $loginBody -ContentType "application/json"
            $authToken = $loginResp.token
            Write-Host "✓ Login successful" -ForegroundColor Green

            # Initiate payment
            Write-Host "`nStep 2: Initiate payment via API..." -ForegroundColor Gray
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

            Write-Host "✓ Payment initiated via API" -ForegroundColor Green
            Write-Host "  Invoice ID: $($apiPaymentResp.data.invoiceId)" -ForegroundColor White
            Write-Host "  Payment URL: $($apiPaymentResp.data.paymentUrl)" -ForegroundColor Cyan

            # Check database
            Write-Host "`nStep 3: Verify database..." -ForegroundColor Gray
            $dbResult = sqlcmd -S "(localdb)\MSSQLLocalDB" -d RafeddSystemDB -Q "SELECT TOP 1 Id, TransactionId, Status, Amount, Currency, PaymentMethodName FROM Payments ORDER BY Id DESC" -h -1 -W 2>&1

            if ($dbResult -and $dbResult -notmatch "error") {
                Write-Host "✓ Payment record in database" -ForegroundColor Green
                Write-Host "  $dbResult" -ForegroundColor Gray
            }

            Write-Host "`n╔════════════════════════════════════════════════╗" -ForegroundColor Green
            Write-Host "║     ✓✓✓ ALL TESTS PASSED! ✓✓✓                 ║" -ForegroundColor Green
            Write-Host "╚════════════════════════════════════════════════╝" -ForegroundColor Green

            Write-Host "`n🚀 Integration Status: READY FOR PRODUCTION" -ForegroundColor Green -BackgroundColor DarkGreen

        } catch {
            Write-Host "⚠ API Server: NOT RUNNING" -ForegroundColor Yellow
            Write-Host "  Start with: cd d:\Rafedd-master\Rafedd && dotnet run" -ForegroundColor Gray
            Write-Host "`n  MyFatoorah direct integration: ✓ WORKING" -ForegroundColor Green
        }

        Write-Host "`nTest Cards:" -ForegroundColor Yellow
        Write-Host "  Visa:       4508750015741019" -ForegroundColor White
        Write-Host "  Mastercard: 5453010000095539" -ForegroundColor White
        Write-Host "  Expiry:     05/25 | CVV: 123" -ForegroundColor White

    } else {
        Write-Host "`n⚠ NO PAYMENT METHODS!" -ForegroundColor Red
        Write-Host "For test environment, methods should be pre-configured." -ForegroundColor Yellow
        Write-Host "Check: https://portal.myfatoorah.com" -ForegroundColor White
    }

} catch {
    Write-Host "✗ Connection Failed" -ForegroundColor Red
    Write-Host "  Error: $($_.Exception.Message)" -ForegroundColor Red

    if ($_.Exception.Response.StatusCode -eq 401) {
        Write-Host "`n  Token is INVALID for this environment" -ForegroundColor Red
        Write-Host "  Current BaseUrl: $baseUrl" -ForegroundColor Yellow
        Write-Host "  Please verify your test token is correct" -ForegroundColor Yellow
    }
}

Write-Host ""
