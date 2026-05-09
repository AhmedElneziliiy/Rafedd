# Test MyFatoorah Token in Both Environments

$token = "SK_KWT_kucLvwUtO6axVK3apufp2Jmzsgh0OfpFULevJtXcfyfGMB1U6uPumLLpmzXacjB2"

$environments = @(
    @{Name="TEST"; Url="https://apitest.myfatoorah.com"},
    @{Name="PRODUCTION"; Url="https://api.myfatoorah.com"}
)

Write-Host "`n================================================" -ForegroundColor Cyan
Write-Host "  MyFatoorah Environment Test" -ForegroundColor Cyan
Write-Host "================================================`n" -ForegroundColor Cyan

foreach ($env in $environments) {
    Write-Host "Testing: $($env.Name) Environment" -ForegroundColor Yellow
    Write-Host "URL: $($env.Url)" -ForegroundColor Gray
    Write-Host "------------------------------------------------" -ForegroundColor Gray

    $headers = @{
        "Authorization" = "Bearer $token"
        "Content-Type" = "application/json"
    }

    $body = @{
        InvoiceAmount = 50.0
        CurrencyIso = "KWD"
    } | ConvertTo-Json

    try {
        $response = Invoke-RestMethod -Uri "$($env.Url)/v2/InitiatePayment" -Method Post -Headers $headers -Body $body

        Write-Host "Token: " -NoNewline -ForegroundColor Green
        Write-Host "VALID" -ForegroundColor White

        $methodCount = $response.Data.PaymentMethods.Count
        Write-Host "Payment Methods: " -NoNewline
        if ($methodCount -gt 0) {
            Write-Host "$methodCount" -ForegroundColor Green

            Write-Host "`nAvailable Methods:" -ForegroundColor Cyan
            foreach ($method in $response.Data.PaymentMethods) {
                Write-Host "  - $($method.PaymentMethodEn) (ID: $($method.PaymentMethodId))" -ForegroundColor White
            }

            # Test ExecutePayment
            Write-Host "`nTesting ExecutePayment..." -ForegroundColor Yellow

            $paymentMethodId = $response.Data.PaymentMethods[0].PaymentMethodId
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

            $execResponse = Invoke-RestMethod -Uri "$($env.Url)/v2/ExecutePayment" -Method Post -Headers $headers -Body $executeBody

            Write-Host "ExecutePayment: " -NoNewline -ForegroundColor Green
            Write-Host "SUCCESS" -ForegroundColor White
            Write-Host "Invoice ID: $($execResponse.Data.InvoiceId)" -ForegroundColor Gray
            Write-Host "Payment URL: $($execResponse.Data.PaymentURL)" -ForegroundColor Cyan

            Write-Host "`n>>> $($env.Name) ENVIRONMENT IS WORKING! <<<" -ForegroundColor Green -BackgroundColor DarkGreen

        } else {
            Write-Host "0 (No methods enabled)" -ForegroundColor Yellow
        }

    } catch {
        if ($_.Exception.Response.StatusCode -eq 401) {
            Write-Host "Token: " -NoNewline -ForegroundColor Red
            Write-Host "INVALID for $($env.Name)" -ForegroundColor Red
        } else {
            Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
        }
    }

    Write-Host ""
}

Write-Host "================================================" -ForegroundColor Cyan
Write-Host "  Summary" -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan

Write-Host "`nYour token starts with: SK_KWT_..." -ForegroundColor White
Write-Host "This indicates: Kuwait Production Token" -ForegroundColor Yellow

Write-Host "`nFor TEST environment, you need:" -ForegroundColor Cyan
Write-Host "  1. A test-specific token (starts with something else)" -ForegroundColor White
Write-Host "  2. Or enable test mode in your MyFatoorah portal" -ForegroundColor White
Write-Host "  3. Check: https://portal.myfatoorah.com > Settings > API Keys" -ForegroundColor Gray

Write-Host "`nRecommendation:" -ForegroundColor Yellow
Write-Host "  - Use PRODUCTION environment for now" -ForegroundColor White
Write-Host "  - Enable payment methods in production portal" -ForegroundColor White
Write-Host "  - Test with real cards (they won't be charged without completing payment)" -ForegroundColor White

Write-Host ""
