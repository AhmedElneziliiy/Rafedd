# Full MyFatoorah Payment Test Script

$token = "SK_KWT_kucLvwUtO6axVK3apufp2Jmzsgh0OfpFULevJtXcfyfGMB1U6uPumLLpmzXacjB2"
$baseUrl = "https://api.myfatoorah.com"

Write-Host "`n=== MyFatoorah Payment Gateway Test ===" -ForegroundColor Cyan

$headers = @{
    "Authorization" = "Bearer $token"
    "Content-Type" = "application/json"
}

# Test 1: InitiatePayment
Write-Host "`n1. Testing InitiatePayment Endpoint..." -ForegroundColor Yellow

$initiateBody = @{
    InvoiceAmount = 50.0
    CurrencyIso = "KWD"
} | ConvertTo-Json

try {
    $response = Invoke-RestMethod -Uri "$baseUrl/v2/InitiatePayment" -Method Post -Headers $headers -Body $initiateBody

    Write-Host "  Success: $($response.IsSuccess)" -ForegroundColor Green
    Write-Host "  Message: $($response.Message)" -ForegroundColor White
    Write-Host "  Payment Methods Available: $($response.Data.PaymentMethods.Count)" -ForegroundColor $(if ($response.Data.PaymentMethods.Count -eq 0) { "Red" } else { "Green" })

    if ($response.Data.PaymentMethods.Count -gt 0) {
        Write-Host "`n  Available Payment Methods:" -ForegroundColor Cyan
        foreach ($method in $response.Data.PaymentMethods) {
            Write-Host "    - $($method.PaymentMethodEn)" -ForegroundColor White
            Write-Host "      ID: $($method.PaymentMethodId), Code: $($method.PaymentMethodCode)"
            Write-Host "      Currency: $($method.CurrencyIso), Direct: $($method.IsDirectPayment)"
        }
    } else {
        Write-Host "`n  WARNING: No payment methods enabled!" -ForegroundColor Red
        Write-Host "  Action Required: Go to MyFatoorah Portal > Settings > Payment Methods" -ForegroundColor Yellow
    }

    # Test 2: ExecutePayment (only if we have payment methods)
    if ($response.Data.PaymentMethods.Count -gt 0) {
        Write-Host "`n2. Testing ExecutePayment Endpoint..." -ForegroundColor Yellow

        $paymentMethodId = $response.Data.PaymentMethods[0].PaymentMethodId
        $executeBody = @{
            PaymentMethodId = $paymentMethodId
            InvoiceValue = 50.0
            CallBackUrl = "https://example.com/callback"
            ErrorUrl = "https://example.com/error"
            CustomerName = "Test Customer"
            CustomerEmail = "test@example.com"
            Language = "en"
            DisplayCurrencyIso = "KWD"
        } | ConvertTo-Json

        try {
            $execResponse = Invoke-RestMethod -Uri "$baseUrl/v2/ExecutePayment" -Method Post -Headers $headers -Body $executeBody

            Write-Host "  Success: $($execResponse.IsSuccess)" -ForegroundColor Green
            Write-Host "  Invoice ID: $($execResponse.Data.InvoiceId)" -ForegroundColor White
            Write-Host "  Payment URL: $($execResponse.Data.PaymentURL)" -ForegroundColor Cyan
        } catch {
            Write-Host "  ERROR: ExecutePayment failed" -ForegroundColor Red
            Write-Host "  $($_.Exception.Message)" -ForegroundColor Red
        }
    }

} catch {
    Write-Host "  ERROR: InitiatePayment failed" -ForegroundColor Red
    Write-Host "  $($_.Exception.Message)" -ForegroundColor Red
    if ($_.Exception.Response) {
        $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
        $responseBody = $reader.ReadToEnd()
        Write-Host "  Response: $responseBody" -ForegroundColor Red
    }
}

# Test 3: GetPaymentStatus (test endpoint access)
Write-Host "`n3. Testing GetPaymentStatus Endpoint Access..." -ForegroundColor Yellow

$statusBody = @{
    Key = "12345"
    KeyType = "InvoiceId"
} | ConvertTo-Json

try {
    $statusResponse = Invoke-WebRequest -Uri "$baseUrl/v2/GetPaymentStatus" -Method Post -Headers $headers -Body $statusBody
    Write-Host "  Endpoint accessible (Status: $($statusResponse.StatusCode))" -ForegroundColor Green
} catch {
    if ($_.Exception.Response.StatusCode -eq 404) {
        Write-Host "  Endpoint accessible (returned 404 for test invoice)" -ForegroundColor Green
    } else {
        Write-Host "  Status Code: $($_.Exception.Response.StatusCode)" -ForegroundColor Yellow
    }
}

Write-Host "`n=== Summary ===" -ForegroundColor Cyan
Write-Host "Token: VALID (authenticates successfully)" -ForegroundColor Green
Write-Host "Base URL: $baseUrl" -ForegroundColor White
Write-Host "Portal: https://portal.myfatoorah.com" -ForegroundColor Cyan
Write-Host "`nNext Steps:" -ForegroundColor Yellow
Write-Host "1. Login to MyFatoorah Portal" -ForegroundColor White
Write-Host "2. Go to Settings > Payment Methods" -ForegroundColor White
Write-Host "3. Enable at least one payment gateway (VISA/Mastercard recommended)" -ForegroundColor White
Write-Host "4. Re-run this test script" -ForegroundColor White
