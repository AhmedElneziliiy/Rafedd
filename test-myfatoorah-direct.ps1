# Test MyFatoorah SendPayment API directly
$token = "SK_KWT_vVZlnnAqu8jRByOWaRPNId4ShzEDNt256dvnjebuyzo52dXjAfRx2ixW5umjWSUx"
$baseUrl = "https://apitest.myfatoorah.com"

$headers = @{
    "Authorization" = "Bearer $token"
    "Content-Type" = "application/json"
}

# Minimal request based on MyFatoorah documentation
$body = @{
    InvoiceAmount = 10.0
    CurrencyIso = "KWD"
} | ConvertTo-Json

Write-Host "Testing with minimal fields..."
try {
    $response = Invoke-RestMethod -Uri "$baseUrl/v2/SendPayment" -Method Post -Headers $headers -Body $body
    $response | ConvertTo-Json -Depth 10
} catch {
    Write-Host "Error:" $_.Exception.Message
    if ($_.Exception.Response) {
        $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
        $responseBody = $reader.ReadToEnd()
        Write-Host "Response:" $responseBody
    }
}
