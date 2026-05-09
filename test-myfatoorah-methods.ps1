# Test MyFatoorah GetPaymentMethods API
$token = "SK_KWT_vVZlnnAqu8jRByOWaRPNId4ShzEDNt256dvnjebuyzo52dXjAfRx2ixW5umjWSUx"
$baseUrl = "https://apitest.myfatoorah.com"

$headers = @{
    "Authorization" = "Bearer $token"
    "Content-Type" = "application/json"
}

# Test if the token is valid by calling InitiatePayment first
$body = @{
    InvoiceAmount = 10.0
    CurrencyIso = "KWD"
} | ConvertTo-Json

Write-Host "Testing InitiatePayment..."
try {
    $response = Invoke-RestMethod -Uri "$baseUrl/v2/InitiatePayment" -Method Post -Headers $headers -Body $body
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
