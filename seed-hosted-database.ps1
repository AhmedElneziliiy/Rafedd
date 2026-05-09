# Seed Hosted Database Script
# This script will:
# 1. Run migrations on the hosted database
# 2. Start the API server
# 3. Create an admin user (if needed)
# 4. Run all data seeders

Write-Host "================================================================================" -ForegroundColor Cyan
Write-Host "RAFEDD - Hosted Database Seeder" -ForegroundColor Cyan
Write-Host "================================================================================" -ForegroundColor Cyan
Write-Host ""

# Configuration
$ProjectPath = "d:\Rafedd-master\Rafedd"
$ApiUrl = "http://localhost:5041"

# Step 1: Apply Migrations to Hosted Database
Write-Host "[STEP 1] Applying Migrations to Hosted Database..." -ForegroundColor Yellow
Write-Host "Connection: SQL6033.site4now.net -> db_ac210d_rafeddsystemdb" -ForegroundColor Gray
Write-Host ""

Set-Location $ProjectPath

try {
    dotnet ef database update --project ..\DAL\DAL.csproj --startup-project . --context ApplicationDbContext
    Write-Host "[SUCCESS] Migrations applied successfully!" -ForegroundColor Green
    Write-Host ""
} catch {
    Write-Host "[ERROR] Failed to apply migrations: $_" -ForegroundColor Red
    Write-Host "You may need to run this in Package Manager Console instead:" -ForegroundColor Yellow
    Write-Host "  Update-Database" -ForegroundColor Yellow
    Write-Host ""
    Read-Host "Press Enter to continue anyway or Ctrl+C to exit"
}

# Step 2: Start API Server
Write-Host "[STEP 2] Starting API Server..." -ForegroundColor Yellow
Write-Host ""

$apiProcess = Start-Process -FilePath "dotnet" -ArgumentList "run" -WorkingDirectory $ProjectPath -PassThru -WindowStyle Normal

Write-Host "Waiting for API to start (30 seconds)..." -ForegroundColor Gray
Start-Sleep -Seconds 30

# Test if API is running
try {
    $testResponse = Invoke-WebRequest -Uri "$ApiUrl/swagger" -Method GET -TimeoutSec 5 -ErrorAction Stop
    Write-Host "[SUCCESS] API is running!" -ForegroundColor Green
} catch {
    Write-Host "[WARNING] Could not confirm API is running. Continuing anyway..." -ForegroundColor Yellow
}
Write-Host ""

# Step 3: Create First Admin User (to get token for seeding)
Write-Host "[STEP 3] Checking for Admin User..." -ForegroundColor Yellow
Write-Host ""

# Try to login with default admin credentials from DataSeed
$loginBody = @{
    emailOrPhone = "admin@rafedd.com"
    password = "Admin123!@#"
} | ConvertTo-Json

try {
    $loginResponse = Invoke-RestMethod -Uri "$ApiUrl/api/v1/auth/login" -Method POST -Body $loginBody -ContentType "application/json" -ErrorAction Stop
    $adminToken = $loginResponse.token
    Write-Host "[SUCCESS] Logged in as admin@rafedd.com" -ForegroundColor Green
    Write-Host "Token: $($adminToken.Substring(0,20))..." -ForegroundColor Gray
} catch {
    Write-Host "[INFO] Admin user doesn't exist yet. Will be created during seeding." -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Creating first admin user via direct registration..." -ForegroundColor Yellow

    # Register first admin user
    $registerBody = @{
        fullName = "System Admin"
        email = "admin@rafedd.com"
        password = "Admin123!@#"
        phoneNumber = "+96512345678"
    } | ConvertTo-Json

    try {
        $registerResponse = Invoke-RestMethod -Uri "$ApiUrl/api/v1/auth/register-admin" -Method POST -Body $registerBody -ContentType "application/json" -ErrorAction Stop
        Write-Host "[SUCCESS] Admin user created!" -ForegroundColor Green

        # Login again
        $loginResponse = Invoke-RestMethod -Uri "$ApiUrl/api/v1/auth/login" -Method POST -Body $loginBody -ContentType "application/json"
        $adminToken = $loginResponse.token
        Write-Host "Token: $($adminToken.Substring(0,20))..." -ForegroundColor Gray
    } catch {
        Write-Host "[ERROR] Failed to create admin user: $($_.Exception.Message)" -ForegroundColor Red
        Write-Host ""
        Write-Host "Please create an admin user manually first:" -ForegroundColor Yellow
        Write-Host "POST $ApiUrl/api/v1/auth/register-admin" -ForegroundColor Yellow
        Write-Host ""
        Stop-Process -Id $apiProcess.Id -Force
        exit 1
    }
}

Write-Host ""

# Step 4: Seed Subscription Plans
Write-Host "[STEP 4] Seeding Subscription Plans..." -ForegroundColor Yellow

$headers = @{
    "Authorization" = "Bearer $adminToken"
    "Content-Type" = "application/json"
}

try {
    $response = Invoke-RestMethod -Uri "$ApiUrl/api/v1/admin/seed/subscription-plans" -Method POST -Headers $headers -ErrorAction Stop
    Write-Host "[SUCCESS] $($response.message)" -ForegroundColor Green
} catch {
    Write-Host "[ERROR] Failed: $($_.Exception.Message)" -ForegroundColor Red
    if ($_.ErrorDetails.Message) {
        $errorDetail = $_.ErrorDetails.Message | ConvertFrom-Json
        Write-Host "Details: $($errorDetail.error)" -ForegroundColor Red
    }
}
Write-Host ""

# Step 5: Seed Admin Users
Write-Host "[STEP 5] Seeding Admin Users..." -ForegroundColor Yellow

try {
    $response = Invoke-RestMethod -Uri "$ApiUrl/api/v1/admin/seed/admin-users" -Method POST -Headers $headers -ErrorAction Stop
    Write-Host "[SUCCESS] $($response.message)" -ForegroundColor Green
} catch {
    Write-Host "[ERROR] Failed: $($_.Exception.Message)" -ForegroundColor Red
    if ($_.ErrorDetails.Message) {
        $errorDetail = $_.ErrorDetails.Message | ConvertFrom-Json
        Write-Host "Details: $($errorDetail.error)" -ForegroundColor Red
    }
}
Write-Host ""

# Step 6: Seed Manager Users
Write-Host "[STEP 6] Seeding Manager Users (with subscriptions)..." -ForegroundColor Yellow

try {
    $response = Invoke-RestMethod -Uri "$ApiUrl/api/v1/admin/seed/manager-users" -Method POST -Headers $headers -ErrorAction Stop
    Write-Host "[SUCCESS] $($response.message)" -ForegroundColor Green
} catch {
    Write-Host "[ERROR] Failed: $($_.Exception.Message)" -ForegroundColor Red
    if ($_.ErrorDetails.Message) {
        $errorDetail = $_.ErrorDetails.Message | ConvertFrom-Json
        Write-Host "Details: $($errorDetail.error)" -ForegroundColor Red
    }
}
Write-Host ""

# Step 7: Seed Employee Users
Write-Host "[STEP 7] Seeding Employee Users..." -ForegroundColor Yellow

try {
    $response = Invoke-RestMethod -Uri "$ApiUrl/api/v1/admin/seed/employee-users" -Method POST -Headers $headers -ErrorAction Stop
    Write-Host "[SUCCESS] $($response.message)" -ForegroundColor Green
} catch {
    Write-Host "[ERROR] Failed: $($_.Exception.Message)" -ForegroundColor Red
    if ($_.ErrorDetails.Message) {
        $errorDetail = $_.ErrorDetails.Message | ConvertFrom-Json
        Write-Host "Details: $($errorDetail.error)" -ForegroundColor Red
    }
}
Write-Host ""

# Summary
Write-Host "================================================================================" -ForegroundColor Cyan
Write-Host "SEEDING COMPLETE!" -ForegroundColor Cyan
Write-Host "================================================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Your hosted database has been seeded with:" -ForegroundColor Green
Write-Host "  - Subscription Plans (3 plans)" -ForegroundColor White
Write-Host "  - Admin Users (admin@rafedd.com / Admin123!@#)" -ForegroundColor White
Write-Host "  - Manager Users (3 managers with subscriptions)" -ForegroundColor White
Write-Host "  - Employee Users (5 employees)" -ForegroundColor White
Write-Host ""
Write-Host "Test Credentials:" -ForegroundColor Yellow
Write-Host "  Admin: admin@rafedd.com / Admin123!@#" -ForegroundColor White
Write-Host "  Manager: manager1@test.com / Manager123!@#" -ForegroundColor White
Write-Host "  Employee: employee1@test.com / Employee123!@#" -ForegroundColor White
Write-Host ""
Write-Host "API is still running. Press Ctrl+C in the API window to stop it." -ForegroundColor Gray
Write-Host ""

Read-Host "Press Enter to exit (API will keep running)"
