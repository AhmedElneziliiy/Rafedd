# Test MyFatoorah ExecutePayment API
$token = "SK_KWT_vVZlnnAqu8jRByOWaRPNId4ShzEDNt256dvnjebuyzo52dXjAfRx2ixW5umjWSUx"
$baseUrl = "https://apitest.myfatoorah.com"

$headers = @{
    "Authorization" = "Bearer $token"
    "Content-Type" = "application/json"
}

# Execute payment with VISA/MASTER (PaymentMethodId = 2)
$body = @{
    PaymentMethodId = 2
    InvoiceValue = 10.0
    CallBackUrl = "https://webhook.site/8a3c4e5f-9b7d-4c2a-a1e6-3f8d9c2b1a0e/api/v1/payment/myfatoorah/callback"
    ErrorUrl = "https://webhook.site/8a3c4e5f-9b7d-4c2a-a1e6-3f8d9c2b1a0e/api/v1/payment/myfatoorah/error"
    CustomerName = "Manager"
    CustomerEmail = "manager@rafeed.com"
    Language = "en"
    DisplayCurrencyIso = "KWD"
} | ConvertTo-Json

Write-Host "Testing ExecutePayment with VISA/MASTER..."
try {
    $response = Invoke-RestMethod -Uri "$baseUrl/v2/ExecutePayment" -Method Post -Headers $headers -Body $body
    Write-Host "Success!"
    $response | ConvertTo-Json -Depth 10
} catch {
    Write-Host "Error:" $_.Exception.Message
    if ($_.Exception.Response) {
        $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
        $responseBody = $reader.ReadToEnd()
        Write-Host "Response:" $responseBody
    }
}
