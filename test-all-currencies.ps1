# Test all supported currencies to find which ones have payment methods enabled

$token = "SK_KWT_kucLvwUtO6axVK3apufp2Jmzsgh0OfpFULevJtXcfyfGMB1U6uPumLLpmzXacjB2"
$baseUrl = "https://api.myfatoorah.com"

Write-Host "`n=== Testing All Currencies for Payment Methods ===" -ForegroundColor Cyan

# All Gulf region currencies
$currencies = @(
    @{Code="KWD"; Name="Kuwaiti Dinar"},
    @{Code="SAR"; Name="Saudi Riyal"},
    @{Code="AED"; Name="UAE Dirham"},
    @{Code="BHD"; Name="Bahraini Dinar"},
    @{Code="QAR"; Name="Qatari Riyal"},
    @{Code="OMR"; Name="Omani Rial"},
    @{Code="JOD"; Name="Jordanian Dinar"},
    @{Code="EGP"; Name="Egyptian Pound"},
    @{Code="USD"; Name="US Dollar"},
    @{Code="EUR"; Name="Euro"},
    @{Code="GBP"; Name="British Pound"}
)

$headers = @{
    "Authorization" = "Bearer $token"
    "Content-Type" = "application/json"
}

$foundMethods = @()

foreach ($currency in $currencies) {
    Write-Host "`nTesting $($currency.Code) ($($currency.Name))..." -ForegroundColor Yellow

    $body = @{
        InvoiceAmount = 10.0
        CurrencyIso = $currency.Code
    } | ConvertTo-Json

    try {
        $response = Invoke-RestMethod -Uri "$baseUrl/v2/InitiatePayment" -Method Post -Headers $headers -Body $body

        $count = $response.Data.PaymentMethods.Count
        Write-Host "  Payment Methods: $count" -ForegroundColor $(if ($count -gt 0) { "Green" } else { "Red" })

        if ($count -gt 0) {
            $foundMethods += $currency.Code
            Write-Host "  Available Methods:" -ForegroundColor Green
            foreach ($method in $response.Data.PaymentMethods) {
                Write-Host "    - $($method.PaymentMethodEn) (ID: $($method.PaymentMethodId), Code: $($method.PaymentMethodCode))" -ForegroundColor White
            }
        }
    } catch {
        Write-Host "  ERROR: $($_.Exception.Message)" -ForegroundColor Red
    }

    Start-Sleep -Milliseconds 200
}

Write-Host "`n=== Summary ===" -ForegroundColor Cyan
if ($foundMethods.Count -gt 0) {
    Write-Host "Payment methods enabled for: $($foundMethods -join ', ')" -ForegroundColor Green
} else {
    Write-Host "NO payment methods found for ANY currency!" -ForegroundColor Red
    Write-Host "`nPossible Issues:" -ForegroundColor Yellow
    Write-Host "1. Payment methods not activated in portal" -ForegroundColor White
    Write-Host "2. Account not fully verified" -ForegroundColor White
    Write-Host "3. Using test token instead of production token" -ForegroundColor White
    Write-Host "4. Currency/country mismatch in portal settings" -ForegroundColor White
}
