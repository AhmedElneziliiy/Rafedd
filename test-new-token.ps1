# Test New MyFatoorah Token
$newToken = "SK_KWT_vVZlnnAqu8jRByOWaRPNId4ShzEDNt256dvnjebuyzo52dXjAfRx2ixW5umjWSUx"
$oldToken = "SK_KWT_kucLvwUtO6axVK3apufp2Jmzsgh0OfpFULevJtXcfyfGMB1U6uPumLLpmzXacjB2"
$baseUrl = "https://api.myfatoorah.com"

Write-Host "`n===============================================" -ForegroundColor Cyan
Write-Host "  Testing New MyFatoorah Token" -ForegroundColor Cyan
Write-Host "===============================================`n" -ForegroundColor Cyan

# Test both tokens
$tokens = @(
    @{Name="NEW TOKEN"; Token=$newToken},
    @{Name="OLD TOKEN"; Token=$oldToken}
)

foreach ($t in $tokens) {
    Write-Host "Testing: $($t.Name)" -ForegroundColor Yellow
    Write-Host "Token: $($t.Token.Substring(0, 20))..." -ForegroundColor Gray
    Write-Host "----------------------------------------" -ForegroundColor Yellow

    $headers = @{
        "Authorization" = "Bearer $($t.Token)"
        "Content-Type" = "application/json"
    }

    $body = @{
        InvoiceAmount = 50.0
        CurrencyIso = "KWD"
    } | ConvertTo-Json

    try {
        $response = Invoke-RestMethod -Uri "$baseUrl/v2/InitiatePayment" -Method Post -Headers $headers -Body $body

        Write-Host "Status: " -NoNewline -ForegroundColor Green
        Write-Host "VALID" -ForegroundColor White

        $methodCount = $response.Data.PaymentMethods.Count
        Write-Host "Payment Methods: " -NoNewline
        if ($methodCount -gt 0) {
            Write-Host "$methodCount" -ForegroundColor Green

            Write-Host "`nAvailable Payment Methods:" -ForegroundColor Green
            foreach ($method in $response.Data.PaymentMethods) {
                Write-Host "  $($method.PaymentMethodEn)" -ForegroundColor White
                Write-Host "    ID: $($method.PaymentMethodId) | Code: $($method.PaymentMethodCode) | Currency: $($method.CurrencyIso)" -ForegroundColor Gray
                Write-Host "    Direct Payment: $($method.IsDirectPayment) | Service Charge: $($method.ServiceCharge)" -ForegroundColor Gray
            }

            # Test ExecutePayment with first method
            Write-Host "`nTesting ExecutePayment..." -ForegroundColor Cyan
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

            try {
                $execResponse = Invoke-RestMethod -Uri "$baseUrl/v2/ExecutePayment" -Method Post -Headers $headers -Body $executeBody

                Write-Host "ExecutePayment: " -NoNewline -ForegroundColor Green
                Write-Host "SUCCESS" -ForegroundColor White
                Write-Host "  Invoice ID: $($execResponse.Data.InvoiceId)" -ForegroundColor Gray
                Write-Host "  Payment URL: $($execResponse.Data.PaymentURL)" -ForegroundColor Cyan

            } catch {
                Write-Host "ExecutePayment: " -NoNewline -ForegroundColor Red
                Write-Host "FAILED - $($_.Exception.Message)" -ForegroundColor Red
            }

        } else {
            Write-Host "0 (NO METHODS ENABLED)" -ForegroundColor Red
        }

        Write-Host "`nFull Response:" -ForegroundColor Gray
        $response | ConvertTo-Json -Depth 10

    } catch {
        Write-Host "Status: " -NoNewline -ForegroundColor Red
        Write-Host "INVALID or ERROR" -ForegroundColor Red
        Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red

        if ($_.Exception.Response) {
            $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
            $responseBody = $reader.ReadToEnd()
            Write-Host "Response: $responseBody" -ForegroundColor Red
        }
    }

    Write-Host "`n" -ForegroundColor Gray
}

Write-Host "===============================================" -ForegroundColor Cyan
Write-Host "  Test Complete" -ForegroundColor Cyan
Write-Host "===============================================`n" -ForegroundColor Cyan
