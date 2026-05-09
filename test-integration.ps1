# MyFatoorah Integration Test

$apiUrl = "http://localhost:5041"

Write-Host "`n================================================" -ForegroundColor Cyan
Write-Host "  MyFatoorah Integration Test" -ForegroundColor Cyan
Write-Host "================================================`n" -ForegroundColor Cyan

# Read configuration
$configPath = "d:\Rafedd-master\Rafedd\appsettings.json"
$config = Get-Content $configPath | ConvertFrom-Json
$token = $config.MyFatoorah.ApiToken
$baseUrl = $config.MyFatoorah.BaseUrl

Write-Host "Configuration:" -ForegroundColor Yellow
Write-Host "  Base URL: $baseUrl" -ForegroundColor White
Write-Host "  Token: $($token.Substring(0, 30))..." -ForegroundColor Gray
Write-Host ""

# Test MyFatoorah Direct
Write-Host "[1] Testing MyFatoorah API..." -ForegroundColor Yellow

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

    Write-Host "Token Status: VALID" -ForegroundColor Green
    $methodCount = $response.Data.PaymentMethods.Count
    Write-Host "Payment Methods: $methodCount" -ForegroundColor $(if ($methodCount -gt 0) { "Green" } else { "Red" })

    if ($methodCount -gt 0) {
        Write-Host "`nAvailable Methods:" -ForegroundColor Cyan
        foreach ($method in $response.Data.PaymentMethods) {
            Write-Host "  - $($method.PaymentMethodEn) (ID: $($method.PaymentMethodId))" -ForegroundColor White
        }

        $paymentMethodId = $response.Data.PaymentMethods[0].PaymentMethodId

        # Test ExecutePayment
        Write-Host "`n[2] Testing ExecutePayment..." -ForegroundColor Yellow

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

        Write-Host "Invoice Created: YES" -ForegroundColor Green
        Write-Host "Invoice ID: $($execResponse.Data.InvoiceId)" -ForegroundColor White
        Write-Host "Payment URL: $($execResponse.Data.PaymentURL)" -ForegroundColor Cyan

        Write-Host "`n================================================" -ForegroundColor Green
        Write-Host "  SUCCESS - MyFatoorah Working!" -ForegroundColor Green
        Write-Host "================================================" -ForegroundColor Green

        Write-Host "`nTest Cards:" -ForegroundColor Yellow
        Write-Host "  Visa:       4508750015741019" -ForegroundColor White
        Write-Host "  Mastercard: 5453010000095539" -ForegroundColor White
        Write-Host "  Expiry:     05/25 | CVV: 123" -ForegroundColor White

        Write-Host "`nNext: Start API to test full integration" -ForegroundColor Cyan
        Write-Host "  cd d:\Rafedd-master\Rafedd" -ForegroundColor Gray
        Write-Host "  dotnet run" -ForegroundColor Gray

    } else {
        Write-Host "`nNO PAYMENT METHODS" -ForegroundColor Red
    }

} catch {
    Write-Host "ERROR: $($_.Exception.Message)" -ForegroundColor Red

    if ($_.Exception.Response.StatusCode -eq 401) {
        Write-Host "`nToken is INVALID" -ForegroundColor Red
    }
}

Write-Host ""
