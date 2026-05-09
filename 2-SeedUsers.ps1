# ================================================================================
# RAFEDD - SEED USERS VIA API
# ================================================================================
# This script creates users through the API to ensure proper password hashing
# Run this AFTER running 1-SeedPlans.sql in SSMS
# ================================================================================

Write-Host "================================================================================" -ForegroundColor Cyan
Write-Host "RAFEDD - Seed Users via API" -ForegroundColor Cyan
Write-Host "================================================================================" -ForegroundColor Cyan
Write-Host ""

$ProjectPath = "d:\Rafedd-master\Rafedd"
$ApiUrl = "http://localhost:5041"

# Step 1: Start API
Write-Host "[STEP 1] Starting API Server..." -ForegroundColor Yellow
Write-Host ""

$apiProcess = Start-Process -FilePath "dotnet" -ArgumentList "run" -WorkingDirectory $ProjectPath -PassThru -WindowStyle Normal

Write-Host "Waiting 30 seconds for API to start..." -ForegroundColor Gray
Start-Sleep -Seconds 30

# Test API
try {
    Invoke-WebRequest -Uri "$ApiUrl/swagger" -Method GET -TimeoutSec 5 -ErrorAction Stop | Out-Null
    Write-Host "[SUCCESS] API is running!" -ForegroundColor Green
} catch {
    Write-Host "[WARNING] Could not confirm API status. Continuing..." -ForegroundColor Yellow
}

Write-Host ""

# Step 2: Create Admin User
Write-Host "[STEP 2] Creating Admin User..." -ForegroundColor Yellow
Write-Host ""

$adminRegister = @{
    fullName = "Super Admin"
    email = "admin@rafeed.com"
    password = "admin123"
    phoneNumber = "+966501234567"
} | ConvertTo-Json

try {
    $response = Invoke-RestMethod -Uri "$ApiUrl/api/v1/auth/register" -Method POST -Body $adminRegister -ContentType "application/json" -ErrorAction Stop
    Write-Host "[SUCCESS] Admin created: admin@rafeed.com / admin123" -ForegroundColor Green
    $adminToken = $response.token
} catch {
    Write-Host "[INFO] Admin may already exist or registration failed" -ForegroundColor Yellow
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Gray

    # Try to login instead
    Write-Host "Attempting to login..." -ForegroundColor Gray
    $loginBody = @{
        emailOrPhone = "admin@rafeed.com"
        password = "admin123"
    } | ConvertTo-Json

    try {
        $loginResponse = Invoke-RestMethod -Uri "$ApiUrl/api/v1/auth/login" -Method POST -Body $loginBody -ContentType "application/json"
        $adminToken = $loginResponse.token
        Write-Host "[SUCCESS] Logged in as existing admin" -ForegroundColor Green
    } catch {
        Write-Host "[ERROR] Could not create or login as admin" -ForegroundColor Red
        Write-Host ""
        Write-Host "Please create admin manually first, then re-run this script" -ForegroundColor Yellow
        Stop-Process -Id $apiProcess.Id -Force
        exit 1
    }
}

Write-Host ""

# Step 3: Assign Admin Role (if needed)
Write-Host "[STEP 3] Ensuring Admin has Admin role..." -ForegroundColor Yellow

if ($adminToken) {
    $headers = @{
        "Authorization" = "Bearer $adminToken"
        "Content-Type" = "application/json"
    }

    # Check if we can access admin endpoints
    try {
        $testAdmin = Invoke-RestMethod -Uri "$ApiUrl/api/v1/admin/dashboard" -Method GET -Headers $headers -ErrorAction Stop
        Write-Host "[SUCCESS] Admin role confirmed" -ForegroundColor Green
    } catch {
        Write-Host "[WARNING] Admin might not have admin role assigned" -ForegroundColor Yellow
        Write-Host "You may need to assign the Admin role manually in the database" -ForegroundColor Yellow
    }
}

Write-Host ""

# Step 4: Create Manager User
Write-Host "[STEP 4] Creating Manager User..." -ForegroundColor Yellow

$managerRegister = @{
    fullName = "Manager"
    email = "manager@rafeed.com"
    password = "manager123"
    phoneNumber = "+966502345678"
    companyName = "شركة رافد للتكنولوجيا"
    businessType = "تكنولوجيا المعلومات"
    businessDescription = "شركة متخصصة في تطوير البرمجيات وأنظمة إدارة الأداء"
    subscriptionPlanId = 2
} | ConvertTo-Json

try {
    $response = Invoke-RestMethod -Uri "$ApiUrl/api/v1/auth/register" -Method POST -Body $managerRegister -ContentType "application/json" -ErrorAction Stop
    Write-Host "[SUCCESS] Manager created: manager@rafeed.com / manager123" -ForegroundColor Green
    Write-Host "  Company: شركة رافد للتكنولوجيا" -ForegroundColor Gray
    Write-Host "  Plan: Professional ($100/month)" -ForegroundColor Gray
} catch {
    Write-Host "[INFO] Manager may already exist" -ForegroundColor Yellow
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Gray
}

Write-Host ""

# Step 5: Get Manager ID for Employee creation
Write-Host "[STEP 5] Getting Manager ID..." -ForegroundColor Yellow

# Login as manager to get token
$managerLogin = @{
    emailOrPhone = "manager@rafeed.com"
    password = "manager123"
} | ConvertTo-Json

try {
    $managerLoginResponse = Invoke-RestMethod -Uri "$ApiUrl/api/v1/auth/login" -Method POST -Body $managerLogin -ContentType "application/json" -ErrorAction Stop
    $managerToken = $managerLoginResponse.token
    Write-Host "[SUCCESS] Manager login successful" -ForegroundColor Green
} catch {
    Write-Host "[WARNING] Could not login as manager" -ForegroundColor Yellow
    $managerToken = $null
}

Write-Host ""

# Step 6: Create Employee User
Write-Host "[STEP 6] Creating Employee User..." -ForegroundColor Yellow

if ($managerToken) {
    $managerHeaders = @{
        "Authorization" = "Bearer $managerToken"
        "Content-Type" = "application/json"
    }

    $employeeRegister = @{
        fullName = "سارة أحمد"
        email = "sara@rafeed.com"
        password = "employee123"
        phoneNumber = "+966503456789"
        position = "مطور برمجيات"
    } | ConvertTo-Json

    try {
        # Use manager's endpoint to create employee
        $response = Invoke-RestMethod -Uri "$ApiUrl/api/v1/manager/employees" -Method POST -Body $employeeRegister -Headers $managerHeaders -ErrorAction Stop
        Write-Host "[SUCCESS] Employee created: sara@rafeed.com / employee123" -ForegroundColor Green
        Write-Host "  Position: مطور برمجيات" -ForegroundColor Gray
        Write-Host "  Manager: manager@rafeed.com" -ForegroundColor Gray
    } catch {
        Write-Host "[INFO] Employee may already exist or endpoint not available" -ForegroundColor Yellow
        Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Gray

        # Try alternative registration
        Write-Host "Trying alternative registration..." -ForegroundColor Gray
        $employeeAltRegister = @{
            fullName = "سارة أحمد"
            email = "sara@rafeed.com"
            password = "employee123"
            phoneNumber = "+966503456789"
        } | ConvertTo-Json

        try {
            $response = Invoke-RestMethod -Uri "$ApiUrl/api/v1/auth/register" -Method POST -Body $employeeAltRegister -ContentType "application/json"
            Write-Host "[SUCCESS] Employee created via auth/register" -ForegroundColor Green
        } catch {
            Write-Host "[WARNING] Could not create employee" -ForegroundColor Yellow
        }
    }
} else {
    Write-Host "[SKIP] Cannot create employee without manager token" -ForegroundColor Yellow
}

Write-Host ""

# Summary
Write-Host "================================================================================" -ForegroundColor Cyan
Write-Host "SEEDING COMPLETE!" -ForegroundColor Cyan
Write-Host "================================================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Test Credentials:" -ForegroundColor Yellow
Write-Host ""
Write-Host "  Admin:" -ForegroundColor White
Write-Host "    Email:    admin@rafeed.com" -ForegroundColor Gray
Write-Host "    Password: admin123" -ForegroundColor Gray
Write-Host ""
Write-Host "  Manager:" -ForegroundColor White
Write-Host "    Email:    manager@rafeed.com" -ForegroundColor Gray
Write-Host "    Password: manager123" -ForegroundColor Gray
Write-Host "    Company:  شركة رافد للتكنولوجيا" -ForegroundColor Gray
Write-Host "    Plan:     Professional ($100/month)" -ForegroundColor Gray
Write-Host ""
Write-Host "  Employee:" -ForegroundColor White
Write-Host "    Email:    sara@rafeed.com" -ForegroundColor Gray
Write-Host "    Password: employee123" -ForegroundColor Gray
Write-Host "    Position: مطور برمجيات" -ForegroundColor Gray
Write-Host ""
Write-Host "API is still running in the background." -ForegroundColor Gray
Write-Host "Close the API window when done testing." -ForegroundColor Gray
Write-Host ""

Read-Host "Press Enter to exit (API will keep running)"
