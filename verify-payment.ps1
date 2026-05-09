# Verify Payment Status with MyFatoorah
$token = "SK_KWT_vVZlnnAqu8jRByOWaRPNId4ShzEDNt256dvnjebuyzo52dXjAfRx2ixW5umjWSUx"
$baseUrl = "https://apitest.myfatoorah.com"
$invoiceId = "6343262"

$headers = @{
    "Authorization" = "Bearer $token"
    "Content-Type" = "application/json"
}

Write-Host "Checking payment status for Invoice ID: $invoiceId" -ForegroundColor Cyan
Write-Host ""

try {
    # MyFatoorah GetPaymentStatus endpoint
    $body = @{
        Key = $invoiceId
        KeyType = "InvoiceId"
    } | ConvertTo-Json

    $response = Invoke-RestMethod -Uri "$baseUrl/v2/GetPaymentStatus" -Method Post -Headers $headers -Body $body

    if ($response.IsSuccess) {
        $data = $response.Data

        Write-Host "Payment Status: " -NoNewline
        switch ($data.InvoiceStatus) {
            "Paid" { Write-Host "PAID (Success!)" -ForegroundColor Green }
            "Pending" { Write-Host "PENDING" -ForegroundColor Yellow }
            "Failed" { Write-Host "FAILED" -ForegroundColor Red }
            "Expired" { Write-Host "EXPIRED" -ForegroundColor Red }
            default { Write-Host $data.InvoiceStatus -ForegroundColor Yellow }
        }

        Write-Host ""
        Write-Host "Invoice Details:" -ForegroundColor Cyan
        Write-Host "  Invoice ID: $($data.InvoiceId)"
        Write-Host "  Invoice Reference: $($data.CustomerReference)"
        Write-Host "  Amount: $($data.InvoiceValue) $($data.CurrencyIso)"
        Write-Host "  Created: $($data.CreatedDate)"

        if ($data.InvoiceTransactions -and $data.InvoiceTransactions.Count -gt 0) {
            Write-Host ""
            Write-Host "Transaction Details:" -ForegroundColor Cyan
            $transaction = $data.InvoiceTransactions[0]
            Write-Host "  Transaction ID: $($transaction.TransactionId)"
            Write-Host "  Payment Gateway: $($transaction.PaymentGateway)"
            Write-Host "  Transaction Status: $($transaction.TransactionStatus)"
            Write-Host "  Transaction Date: $($transaction.TransactionDate)"
            Write-Host "  Authorization ID: $($transaction.AuthorizationId)"
            Write-Host "  Track ID: $($transaction.TrackId)"
        }

        Write-Host ""
        Write-Host "Full Response:" -ForegroundColor Cyan
        $response | ConvertTo-Json -Depth 10

    } else {
        Write-Host "Error: $($response.Message)" -ForegroundColor Red
        $response | ConvertTo-Json -Depth 10
    }

} catch {
    Write-Host "Error checking payment status:" -ForegroundColor Red
    Write-Host $_.Exception.Message
    if ($_.Exception.Response) {
        $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
        $responseBody = $reader.ReadToEnd()
        Write-Host "Response:" $responseBody
    }
}
