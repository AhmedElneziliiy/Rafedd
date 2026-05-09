# Check Available Payment Methods with KWD Currency
$token = "SK_KWT_kucLvwUtO6axVK3apufp2Jmzsgh0OfpFULevJtXcfyfGMB1U6uPumLLpmzXacjB2"

$headers = @{
    "Authorization" = "Bearer $token"
    "Content-Type" = "application/json"
}

Write-Host "Testing different currencies..." -ForegroundColor Yellow
Write-Host ""

$currencies = @("KWD", "USD", "SAR")

foreach ($currency in $currencies) {
    Write-Host "Testing $currency..." -ForegroundColor Cyan

    $body = @{
        InvoiceAmount = 50.0
        CurrencyIso = $currency
    } | ConvertTo-Json

    try {
        $response = Invoke-RestMethod -Uri "https://api.myfatoorah.com/v2/InitiatePayment" -Method Post -Headers $headers -Body $body

        if ($response.IsSuccess) {
            $count = $response.Data.PaymentMethods.Count
            Write-Host "  Payment Methods: $count" -ForegroundColor $(if ($count -gt 0) { "Green" } else { "Red" })

            if ($count -gt 0) {
                $response.Data.PaymentMethods | ForEach-Object {
                    Write-Host "    ID: $($_.PaymentMethodId) - $($_.PaymentMethodEn)" -ForegroundColor White
                }
            }
        } else {
            Write-Host "  Error: $($response.Message)" -ForegroundColor Red
        }
    } catch {
        Write-Host "  Error: $($_.Exception.Message)" -ForegroundColor Red
    }

    Write-Host ""
}
