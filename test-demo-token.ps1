# Test MyFatoorah Demo/Test Token
# Using official MyFatoorah demo token for testing

$demoToken = "rLtt6JWvbUHDDhsZnfpAhpYk4dxYDQkbcPTyGaKp2TYqQgG7FGZ5Th_WD53Oq8Ebz6A53njUoo1w3pjU1D4vs_ZMqFiz_j0urb_BH9Oq9VZoKFoJEDAbRZepGcQanImyYrry7Kt6MnMdgfG5jn4HngWoRdKduNNyP4kzcp3mRv7x00ahkm9LAK7ZRieg7k1PDAnBIOG3EyVSJ5kK4WLMvYr7sCwHbHcu4A5WwelxYK0GMJy37bNAarSJDFQsJ2ZvJjvMDmfWwDVFEVe_5tOomfVNt6bOg9mexbGjMrnHBnKnZR1vQbBtQieDlQepzTZMuQrSuKn-t5XZM7V6fCW7oP-uXGX-sMOajeX65JOf6XVpk29DP6ro8WTAflCDANC193yof8-f5_EYY-3hXhJj7RBXmizDpneEQDSaSz5sFk0sV5qPcARJ9zGG73vuGFyenjPPmtDtXtpx35A-BVcOSBYVIWe9kndG3nclfefjKEuZ3m4jL9Gg1h2JBvmXSMYiZtp9MR5I6pvbvylU_PP5xJFSjVTIz7IQSjcVGO41npnwIxRXNRxFOdIUHn0tjQ-7LwvEcTXyPsHXcMD8WtgBh-wxR8aKX7WPSsT1O8d8reb2aR7K3rkV3K82K_0OgawImEpwSvp9MNKynEAJQS6ZHe_J_l77652xwPNxMRTMASk1ZsJL"
$testBaseUrl = "https://apitest.myfatoorah.com"

Write-Host "`n╔════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║   MyFatoorah TEST Environment Test            ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════════════╝`n" -ForegroundColor Cyan

Write-Host "Environment: TEST (apitest.myfatoorah.com)" -ForegroundColor Yellow
Write-Host "Token: Demo Token from MyFatoorah Docs`n" -ForegroundColor Yellow

$headers = @{
    "Authorization" = "Bearer $demoToken"
    "Content-Type" = "application/json"
}

# Test with different currencies
$currencies = @("KWD", "SAR", "USD")

foreach ($currency in $currencies) {
    Write-Host "Testing Currency: $currency" -ForegroundColor Cyan
    Write-Host "─────────────────────────────────────────────" -ForegroundColor Gray

    $body = @{
        InvoiceAmount = 50.0
        CurrencyIso = $currency
    } | ConvertTo-Json

    try {
        $response = Invoke-RestMethod -Uri "$testBaseUrl/v2/InitiatePayment" -Method Post -Headers $headers -Body $body

        Write-Host "  ✓ Token: " -NoNewline -ForegroundColor Green
        Write-Host "VALID" -ForegroundColor White

        $methodCount = $response.Data.PaymentMethods.Count
        Write-Host "  ✓ Payment Methods: " -NoNewline
        if ($methodCount -gt 0) {
            Write-Host "$methodCount" -ForegroundColor Green

            Write-Host "`n  Available Methods:" -ForegroundColor White
            foreach ($method in $response.Data.PaymentMethods) {
                Write-Host "    • $($method.PaymentMethodEn) " -NoNewline -ForegroundColor White
                Write-Host "(ID: $($method.PaymentMethodId))" -ForegroundColor Gray
                Write-Host "      Currency: $($method.CurrencyIso) | Charge: $($method.ServiceCharge) | Direct: $($method.IsDirectPayment)" -ForegroundColor DarkGray
            }

            # Test ExecutePayment with first method
            $paymentMethodId = $response.Data.PaymentMethods[0].PaymentMethodId

            Write-Host "`n  Testing ExecutePayment..." -ForegroundColor Yellow
            $executeBody = @{
                PaymentMethodId = $paymentMethodId
                InvoiceValue = 50.0
                CallBackUrl = "https://example.com/callback"
                ErrorUrl = "https://example.com/error"
                CustomerName = "Test Customer"
                CustomerEmail = "test@rafeed.com"
                Language = "en"
                DisplayCurrencyIso = $currency
            } | ConvertTo-Json

            try {
                $execResponse = Invoke-RestMethod -Uri "$testBaseUrl/v2/ExecutePayment" -Method Post -Headers $headers -Body $executeBody

                Write-Host "  ✓ ExecutePayment: " -NoNewline -ForegroundColor Green
                Write-Host "SUCCESS" -ForegroundColor White
                Write-Host "    Invoice ID: $($execResponse.Data.InvoiceId)" -ForegroundColor Gray
                Write-Host "    Payment URL: $($execResponse.Data.PaymentURL)" -ForegroundColor Cyan

                Write-Host "`n  ════════════════════════════════════════════" -ForegroundColor Green
                Write-Host "  ✓ $currency - FULL PAYMENT FLOW WORKING!" -ForegroundColor Green
                Write-Host "  ════════════════════════════════════════════`n" -ForegroundColor Green

                break  # Success! No need to test other currencies

            } catch {
                Write-Host "  ✗ ExecutePayment Failed" -ForegroundColor Red
                Write-Host "    $($_.Exception.Message)" -ForegroundColor Red
            }

        } else {
            Write-Host "0 (No methods for $currency)" -ForegroundColor Yellow
        }

    } catch {
        Write-Host "  ✗ InitiatePayment Failed" -ForegroundColor Red
        Write-Host "    Error: $($_.Exception.Message)" -ForegroundColor Red
    }

    Write-Host ""
}

Write-Host "╔════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║   Test Environment Summary                     ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════════════╝" -ForegroundColor Cyan

Write-Host "`nConfiguration Updated:" -ForegroundColor Green
Write-Host "  ✓ BaseUrl: https://apitest.myfatoorah.com" -ForegroundColor White
Write-Host "  ✓ ApiToken: Demo token from docs" -ForegroundColor White
Write-Host "  ✓ File: d:\Rafedd-master\Rafedd\appsettings.json" -ForegroundColor Gray

Write-Host "`nTest Cards:" -ForegroundColor Yellow
Write-Host "  Visa:       4508750015741019" -ForegroundColor White
Write-Host "  Mastercard: 5453010000095539" -ForegroundColor White
Write-Host "  Expiry:     Any future date (05/25)" -ForegroundColor White
Write-Host "  CVV:        Any 3 digits (123)" -ForegroundColor White

Write-Host "`nNext Steps:" -ForegroundColor Cyan
Write-Host "  1. Start the API: cd d:\Rafedd-master\Rafedd && dotnet run" -ForegroundColor White
Write-Host "  2. Test full integration via your API endpoints" -ForegroundColor White
Write-Host "  3. When ready for production, switch back to production token" -ForegroundColor White

Write-Host ""
