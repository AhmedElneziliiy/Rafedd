# Check Available Payment Methods in MyFatoorah Production
$token = "SK_KWT_kucLvwUtO6axVK3apufp2Jmzsgh0OfpFULevJtXcfyfGMB1U6uPumLLpmzXacjB2"

$headers = @{
    "Authorization" = "Bearer $token"
    "Content-Type" = "application/json"
}

$body = @{
    InvoiceAmount = 50.0
    CurrencyIso = "USD"
} | ConvertTo-Json

try {
    $response = Invoke-RestMethod -Uri "https://api.myfatoorah.com/v2/InitiatePayment" -Method Post -Headers $headers -Body $body

    Write-Host "SUCCESS! Token is working in production!" -ForegroundColor Green
    Write-Host ""

    if ($response.IsSuccess) {
        Write-Host "Response IsSuccess: True" -ForegroundColor Green
        Write-Host "Available Payment Methods Count: $($response.Data.PaymentMethods.Count)" -ForegroundColor Yellow
        Write-Host ""

        if ($response.Data.PaymentMethods.Count -gt 0) {
            $response.Data.PaymentMethods | ForEach-Object {
                Write-Host "  ID: $($_.PaymentMethodId)" -ForegroundColor Cyan
                Write-Host "  Name: $($_.PaymentMethodEn)" -ForegroundColor White
                Write-Host "  Direct Payment: $($_.IsDirectPayment)" -ForegroundColor White
                Write-Host "  Currency: $($_.CurrencyIso)" -ForegroundColor White
                Write-Host ""
            }
        } else {
            Write-Host "No payment methods available!" -ForegroundColor Red
        }
    } else {
        Write-Host "Response IsSuccess: False" -ForegroundColor Red
        Write-Host "Message: $($response.Message)" -ForegroundColor Red
    }

} catch {
    Write-Host "ERROR:" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red

    if ($_.ErrorDetails) {
        Write-Host "Details: $($_.ErrorDetails.Message)" -ForegroundColor Red
    }
}
