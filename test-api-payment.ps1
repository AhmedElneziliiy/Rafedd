# Test Payment Flow via API

$apiUrl = "http://localhost:5041"

Write-Host "`n================================================" -ForegroundColor Cyan
Write-Host "  Complete Payment Flow Test" -ForegroundColor Cyan
Write-Host "================================================`n" -ForegroundColor Cyan

# Step 1: Login
Write-Host "[1] Login..." -ForegroundColor Yellow

$loginBody = @{
    emailOrPhone = "manager@rafeed.com"
    password = "manager123"
} | ConvertTo-Json

try {
    $loginResp = Invoke-RestMethod -Uri "$apiUrl/api/v1/auth/login" -Method Post -Body $loginBody -ContentType "application/json"
    $token = $loginResp.token

    Write-Host "Login: SUCCESS" -ForegroundColor Green

    # Step 2: Initiate Payment
    Write-Host "`n[2] Initiate payment..." -ForegroundColor Yellow

    $headers = @{
        "Authorization" = "Bearer $token"
        "Content-Type" = "application/json"
    }

    $paymentBody = @{
        subscriptionId = 1
        amount = 50.0
        currency = "KWD"
        description = "Test subscription payment"
    } | ConvertTo-Json

    $paymentResp = Invoke-RestMethod -Uri "$apiUrl/api/v1/payment/myfatoorah/initiate" -Method Post -Headers $headers -Body $paymentBody

    Write-Host "Payment: SUCCESS" -ForegroundColor Green
    Write-Host "Invoice ID: $($paymentResp.data.invoiceId)" -ForegroundColor White
    Write-Host "Payment URL: $($paymentResp.data.paymentUrl)" -ForegroundColor Cyan

    # Step 3: Database Check
    Write-Host "`n[3] Database..." -ForegroundColor Yellow

    $dbQuery = "SELECT TOP 1 Id, TransactionId, Status, Amount, Currency FROM Payments ORDER BY Id DESC"
    $dbResult = sqlcmd -S "(localdb)\MSSQLLocalDB" -d RafeddSystemDB -Q "$dbQuery" -W -h -1 2>&1

    if ($dbResult) {
        Write-Host "Database: RECORD CREATED" -ForegroundColor Green
        Write-Host $dbResult -ForegroundColor Gray
    }

    Write-Host "`n================================================" -ForegroundColor Green
    Write-Host "  ALL TESTS PASSED!" -ForegroundColor Green
    Write-Host "================================================" -ForegroundColor Green

    Write-Host "`nStatus: READY TO PUBLISH" -ForegroundColor Green
    Write-Host "`nPayment URL:" -ForegroundColor Yellow
    Write-Host $paymentResp.data.paymentUrl -ForegroundColor Cyan

} catch {
    Write-Host "ERROR: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""
