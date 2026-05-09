$token = "SK_KWT_kucLvwUtO6axVK3apufp2Jmzsgh0OfpFULevJtXcfyfGMB1U6uPumLLpmzXacjB2"

$currencies = @("USD", "KWD", "SAR", "AED", "BHD", "QAR", "OMR")

foreach ($currency in $currencies) {
    Write-Host "`n=== Testing $currency ===" -ForegroundColor Cyan

    $headers = @{
        "Authorization" = "Bearer $token"
        "Content-Type" = "application/json"
    }

    $body = @{
        InvoiceAmount = 50.0
        CurrencyIso = $currency
    } | ConvertTo-Json

    try {
        $response = Invoke-RestMethod -Uri "https://api.myfatoorah.com/v2/InitiatePayment" -Method Post -Headers $headers -Body $body

        $count = $response.Data.PaymentMethods.Count
        Write-Host "Payment Methods: $count" -ForegroundColor $(if ($count -eq 0) { "Red" } else { "Green" })

        if ($count -gt 0) {
            foreach ($method in $response.Data.PaymentMethods) {
                Write-Host "  - $($method.PaymentMethodEn) (ID: $($method.PaymentMethodId), Type: $($method.PaymentMethodCode))"
            }
        }
    } catch {
        Write-Host "ERROR: $($_.Exception.Message)" -ForegroundColor Red
    }
}
