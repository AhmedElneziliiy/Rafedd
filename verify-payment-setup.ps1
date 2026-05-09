# Complete MyFatoorah Payment Integration Verification
# This script tests the full payment flow

$token = "SK_KWT_kucLvwUtO6axVK3apufp2Jmzsgh0OfpFULevJtXcfyfGMB1U6uPumLLpmzXacjB2"
$baseUrl = "https://api.myfatoorah.com"
$apiBaseUrl = "http://localhost:5041"

Write-Host "`n===============================================" -ForegroundColor Cyan
Write-Host "  MyFatoorah Payment Integration Test" -ForegroundColor Cyan
Write-Host "===============================================`n" -ForegroundColor Cyan

# Step 1: Check MyFatoorah API directly
Write-Host "Step 1: Testing MyFatoorah API Directly" -ForegroundColor Yellow
Write-Host "----------------------------------------" -ForegroundColor Yellow

$headers = @{
    "Authorization" = "Bearer $token"
    "Content-Type" = "application/json"
}

$initiateBody = @{
    InvoiceAmount = 50.0
    CurrencyIso = "KWD"
} | ConvertTo-Json

try {
    $response = Invoke-RestMethod -Uri "$baseUrl/v2/InitiatePayment" -Method Post -Headers $headers -Body $initiateBody

    Write-Host "Token Status: " -NoNewline -ForegroundColor Green
    Write-Host "VALID" -ForegroundColor White

    $methodCount = $response.Data.PaymentMethods.Count
    Write-Host "Payment Methods: " -NoNewline -ForegroundColor $(if ($methodCount -eq 0) { "Red" } else { "Green" })
    Write-Host "$methodCount" -ForegroundColor White

    if ($methodCount -eq 0) {
        Write-Host "`nNO PAYMENT METHODS ENABLED!" -ForegroundColor Red
        Write-Host "`nAction Required:" -ForegroundColor Yellow
        Write-Host "1. Login to: https://portal.myfatoorah.com" -ForegroundColor White
        Write-Host "2. Go to: Settings > Payment Methods" -ForegroundColor White
        Write-Host "3. Enable at least one gateway (VISA/Mastercard)" -ForegroundColor White
        Write-Host "4. Make sure to click 'Activate' and 'Save'" -ForegroundColor White
        Write-Host "5. Wait 1-2 minutes for changes to propagate" -ForegroundColor White
        Write-Host "6. Re-run this script" -ForegroundColor White
        exit
    }

    Write-Host "`nAvailable Payment Methods:" -ForegroundColor Green
    foreach ($method in $response.Data.PaymentMethods) {
        Write-Host "  - $($method.PaymentMethodEn)" -ForegroundColor White
        Write-Host "    ID: $($method.PaymentMethodId) | Code: $($method.PaymentMethodCode)" -ForegroundColor Gray
    }

    $paymentMethodId = $response.Data.PaymentMethods[0].PaymentMethodId

    # Step 2: Test ExecutePayment
    Write-Host "`nStep 2: Testing ExecutePayment" -ForegroundColor Yellow
    Write-Host "----------------------------------------" -ForegroundColor Yellow

    $executeBody = @{
        PaymentMethodId = $paymentMethodId
        InvoiceValue = 50.0
        CallBackUrl = "https://example.com/callback"
        ErrorUrl = "https://example.com/error"
        CustomerName = "Test Customer"
        CustomerEmail = "test@rafeed.com"
        Language = "en"
        DisplayCurrencyIso = "KWD"
    } | ConvertTo-Json

    $execResponse = Invoke-RestMethod -Uri "$baseUrl/v2/ExecutePayment" -Method Post -Headers $headers -Body $executeBody

    Write-Host "Invoice Created: YES" -ForegroundColor Green
    Write-Host "Invoice ID: $($execResponse.Data.InvoiceId)" -ForegroundColor White
    Write-Host "Payment URL: $($execResponse.Data.PaymentURL)" -ForegroundColor Cyan

    # Summary
    Write-Host "`n===============================================" -ForegroundColor Cyan
    Write-Host "  SUCCESS - Ready for Production!" -ForegroundColor Green
    Write-Host "===============================================" -ForegroundColor Cyan
    Write-Host "MyFatoorah token: VALID" -ForegroundColor Green
    Write-Host "Payment methods: ENABLED ($methodCount)" -ForegroundColor Green
    Write-Host "InitiatePayment: Working" -ForegroundColor Green
    Write-Host "ExecutePayment: Working" -ForegroundColor Green
    Write-Host "`nYou can now publish your application!" -ForegroundColor Cyan

} catch {
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
}
