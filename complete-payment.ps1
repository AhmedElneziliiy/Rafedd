# Simulate MyFatoorah callback to complete the payment
$invoiceId = "6343262"
$paymentId = "07076343262319464973"

Write-Host "Simulating MyFatoorah callback to complete payment..." -ForegroundColor Cyan
Write-Host "Invoice ID: $invoiceId" -ForegroundColor Yellow
Write-Host "Payment ID: $paymentId" -ForegroundColor Yellow
Write-Host ""

# Make sure API is running
try {
    $healthCheck = Invoke-RestMethod -Uri "http://localhost:5041/api/health" -ErrorAction Stop
    Write-Host "✓ API is running" -ForegroundColor Green
} catch {
    Write-Host "✗ API is not running. Please start the API first:" -ForegroundColor Red
    Write-Host "  cd d:\Rafedd-master\Rafedd" -ForegroundColor Yellow
    Write-Host "  dotnet run" -ForegroundColor Yellow
    exit 1
}

Write-Host ""

# Call the callback endpoint
try {
    $callbackUrl = "http://localhost:5041/api/v1/payment/myfatoorah/callback?paymentId=$paymentId" + [char]38 + "invoiceId=$invoiceId"

    Write-Host "Calling callback endpoint..." -ForegroundColor Cyan
    $response = Invoke-WebRequest -Uri $callbackUrl -Method Post -MaximumRedirection 0 -ErrorAction SilentlyContinue

    if ($response.StatusCode -eq 302 -or $response.StatusCode -eq 301) {
        Write-Host "Checkmark Callback processed successfully!" -ForegroundColor Green
        Write-Host "  Redirected to: $($response.Headers.Location)" -ForegroundColor Yellow
    }
    else {
        Write-Host "Response Status: $($response.StatusCode)" -ForegroundColor Yellow
        Write-Host $response.Content
    }
}
catch {
    if ($_.Exception.Response.StatusCode -eq 'Redirect' -or $_.Exception.Response.StatusCode -eq 'Found') {
        Write-Host "Checkmark Callback processed successfully!" -ForegroundColor Green
        $location = $_.Exception.Response.Headers.Location
        if ($location) {
            Write-Host "  Redirected to: $location" -ForegroundColor Yellow
        }
    }
    else {
        Write-Host "Error calling callback:" -ForegroundColor Red
        Write-Host $_.Exception.Message
    }
}

Write-Host ""
Write-Host "Checking payment status in database..." -ForegroundColor Cyan

# Get auth token
try {
    $loginBody = @{
        emailOrPhone = "manager@rafeed.com"
        password = "manager123"
    } | ConvertTo-Json

    $loginResponse = Invoke-RestMethod -Uri "http://localhost:5041/api/v1/auth/login" -Method Post -Body $loginBody -ContentType "application/json"
    $token = $loginResponse.token

    Write-Host "✓ Authenticated successfully" -ForegroundColor Green
    Write-Host ""

    # Check subscription status
    $headers = @{
        "Authorization" = "Bearer $token"
    }

    Write-Host "Checking subscription status..." -ForegroundColor Cyan
    $subscription = Invoke-RestMethod -Uri "http://localhost:5041/api/v1/subscription/my-subscription" -Method Get -Headers $headers -ErrorAction SilentlyContinue

    if ($subscription) {
        Write-Host "Subscription Details:" -ForegroundColor Green
        $subscription | ConvertTo-Json -Depth 5
    }

} catch {
    Write-Host "Could not retrieve subscription details" -ForegroundColor Yellow
    Write-Host $_.Exception.Message
}

Write-Host ""
Write-Host "Payment completion process finished!" -ForegroundColor Green
