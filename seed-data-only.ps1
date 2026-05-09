# Quick Seed Script (API must be running already)
# Run this if your API is already running and you just want to seed data

Write-Host "================================================================================" -ForegroundColor Cyan
Write-Host "RAFEDD - Quick Data Seeder" -ForegroundColor Cyan
Write-Host "================================================================================" -ForegroundColor Cyan
Write-Host ""

$ApiUrl = "http://localhost:5041"

# Login as admin
Write-Host "[STEP 1] Logging in as Admin..." -ForegroundColor Yellow

$loginBody = @{
    emailOrPhone = "admin@rafedd.com"
    password = "Admin123!@#"
} | ConvertTo-Json

try {
    $loginResponse = Invoke-RestMethod -Uri "$ApiUrl/api/v1/auth/login" -Method POST -Body $loginBody -ContentType "application/json" -ErrorAction Stop
    $adminToken = $loginResponse.token
    Write-Host "[SUCCESS] Logged in!" -ForegroundColor Green
    Write-Host ""
} catch {
    Write-Host "[ERROR] Could not login. Make sure:" -ForegroundColor Red
    Write-Host "  1. API is running on $ApiUrl" -ForegroundColor Yellow
    Write-Host "  2. Admin user exists (admin@rafedd.com / Admin123!@#)" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

$headers = @{
    "Authorization" = "Bearer $adminToken"
    "Content-Type" = "application/json"
}

# Seed All Data at Once
Write-Host "[STEP 2] Seeding All Data..." -ForegroundColor Yellow

try {
    $response = Invoke-RestMethod -Uri "$ApiUrl/api/v1/admin/seed/all" -Method POST -Headers $headers -ErrorAction Stop
    Write-Host "[SUCCESS] All data seeded!" -ForegroundColor Green
    Write-Host "Message: $($response.message)" -ForegroundColor White
} catch {
    Write-Host "[ERROR] Seeding failed: $($_.Exception.Message)" -ForegroundColor Red
    if ($_.ErrorDetails.Message) {
        $errorDetail = $_.ErrorDetails.Message | ConvertFrom-Json
        Write-Host "Details: $($errorDetail.error)" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "================================================================================" -ForegroundColor Cyan
Write-Host "DONE!" -ForegroundColor Cyan
Write-Host "================================================================================" -ForegroundColor Cyan
