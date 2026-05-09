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

    Write-Host "`n=== MyFatoorah Payment Methods ===" -ForegroundColor Green
    Write-Host "Total Payment Methods: $($response.Data.PaymentMethods.Count)" -ForegroundColor Yellow

    foreach ($method in $response.Data.PaymentMethods) {
        Write-Host "`nPayment Method: $($method.PaymentMethodEn)" -ForegroundColor Cyan
        Write-Host "  ID: $($method.PaymentMethodId)"
        Write-Host "  Arabic Name: $($method.PaymentMethodAr)"
        Write-Host "  Currency: $($method.CurrencyIso)"
        Write-Host "  Payment Type: $($method.PaymentType)"
        Write-Host "  Is Direct Payment: $($method.IsDirectPayment)"
    }

    Write-Host "`n=== Full JSON Response ===" -ForegroundColor Green
    $response | ConvertTo-Json -Depth 10

} catch {
    Write-Host "ERROR: $($_.Exception.Message)" -ForegroundColor Red
    if ($_.Exception.Response) {
        $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
        $responseBody = $reader.ReadToEnd()
        Write-Host "Response: $responseBody"
    }
}
