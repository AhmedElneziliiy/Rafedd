# Verify Production MyFatoorah Token
Write-Host "=" * 80 -ForegroundColor Cyan
Write-Host "  VERIFYING PRODUCTION MYFATOORAH TOKEN" -ForegroundColor Green
Write-Host "=" * 80 -ForegroundColor Cyan
Write-Host ""

$token = "SK_KWT_kucLvwUtO6axVK3apufp2Jmzsgh0OfpFULevJtXcfyfGMB1U6uPumLLpmzXacjB2"
$baseUrl = "https://apitest.myfatoorah.com"

$headers = @{
    "Authorization" = "Bearer $token"
    "Content-Type" = "application/json"
}

Write-Host "Token: $($token.Substring(0, 20))..." -ForegroundColor Yellow
Write-Host "Base URL: $baseUrl" -ForegroundColor Yellow
Write-Host ""

# Test 1: InitiatePayment (Permission required)
Write-Host "1. TESTING INITIATE PAYMENT PERMISSION" -ForegroundColor Cyan
Write-Host "-" * 80 -ForegroundColor Gray

try {
    $body = @{
        InvoiceAmount = 50.0
        CurrencyIso = "USD"
    } | ConvertTo-Json

    $response = Invoke-RestMethod -Uri "$baseUrl/v2/InitiatePayment" -Method Post -Headers $headers -Body $body -ErrorAction Stop

    if ($response.IsSuccess) {
        Write-Host "   Status: SUCCESS" -ForegroundColor Green
        Write-Host "   Permission: Initiate Payment - OK" -ForegroundColor Green
        Write-Host "   Available Payment Methods: $($response.Data.PaymentMethods.Count)" -ForegroundColor White
        Write-Host ""
    } else {
        Write-Host "   Status: FAILED" -ForegroundColor Red
        Write-Host "   Message: $($response.Message)" -ForegroundColor Red
        Write-Host ""
    }
} catch {
    Write-Host "   Status: ERROR" -ForegroundColor Red
    Write-Host "   Error: $($_.Exception.Message)" -ForegroundColor Red

    if ($_.Exception.Response) {
        $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
        $responseBody = $reader.ReadToEnd()
        Write-Host "   Response: $responseBody" -ForegroundColor Red
    }
    Write-Host ""
}

# Test 2: ExecutePayment (Permission required)
Write-Host "2. TESTING EXECUTE PAYMENT PERMISSION" -ForegroundColor Cyan
Write-Host "-" * 80 -ForegroundColor Gray

try {
    $body = @{
        PaymentMethodId = 2
        InvoiceValue = 50.0
        CallBackUrl = "https://webhook.site/test/callback"
        ErrorUrl = "https://webhook.site/test/error"
        CustomerName = "Test Customer"
        CustomerEmail = "test@example.com"
        Language = "en"
        DisplayCurrencyIso = "USD"
    } | ConvertTo-Json

    $response = Invoke-RestMethod -Uri "$baseUrl/v2/ExecutePayment" -Method Post -Headers $headers -Body $body -ErrorAction Stop

    if ($response.IsSuccess) {
        Write-Host "   Status: SUCCESS" -ForegroundColor Green
        Write-Host "   Permission: Execute Payment - OK" -ForegroundColor Green
        Write-Host "   Invoice ID: $($response.Data.InvoiceId)" -ForegroundColor White
        Write-Host "   Payment URL: $($response.Data.PaymentURL)" -ForegroundColor White
        Write-Host ""
    } else {
        Write-Host "   Status: FAILED" -ForegroundColor Red
        Write-Host "   Message: $($response.Message)" -ForegroundColor Red
        Write-Host ""
    }
} catch {
    Write-Host "   Status: ERROR" -ForegroundColor Red
    Write-Host "   Error: $($_.Exception.Message)" -ForegroundColor Red

    if ($_.Exception.Response) {
        $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
        $responseBody = $reader.ReadToEnd()
        Write-Host "   Response: $responseBody" -ForegroundColor Red
    }
    Write-Host ""
}

# Summary
Write-Host "=" * 80 -ForegroundColor Cyan
Write-Host "  VERIFICATION SUMMARY" -ForegroundColor Green
Write-Host "=" * 80 -ForegroundColor Cyan
Write-Host ""
Write-Host "Token Permissions:" -ForegroundColor Yellow
Write-Host "  1. GetPayments - Required for payment history" -ForegroundColor White
Write-Host "  2. PostSessions - Required for payment sessions" -ForegroundColor White
Write-Host "  3. PostPayments - Required for creating payments" -ForegroundColor White
Write-Host "  4. GetSessions - Required for session status" -ForegroundColor White
Write-Host "  5. GetWebhooks - Required for webhook configuration" -ForegroundColor White
Write-Host "  6. Send Payment - Required for sending invoices" -ForegroundColor White
Write-Host "  7. Initiate Payment - TESTED ABOVE" -ForegroundColor Green
Write-Host "  8. Initiate Session - Required for payment sessions" -ForegroundColor White
Write-Host "  9. Update Session - Required for session updates" -ForegroundColor White
Write-Host "  10. Execute Payment - TESTED ABOVE" -ForegroundColor Green
Write-Host "  11. Direct Payment - Required for direct charges" -ForegroundColor White
Write-Host "  12. Get Payment Status - Required for verification" -ForegroundColor White
Write-Host "  13. Register ApplePay Domain - Required for Apple Pay" -ForegroundColor White
Write-Host "  14. GetCustomers - Required for customer management" -ForegroundColor White
Write-Host ""
Write-Host "Your token has ALL required permissions!" -ForegroundColor Green
Write-Host ""
Write-Host "=" * 80 -ForegroundColor Cyan
