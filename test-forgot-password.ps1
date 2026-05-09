# ================================================================================
# TEST FORGOT PASSWORD FEATURE
# ================================================================================

Write-Host "================================================================================" -ForegroundColor Cyan
Write-Host "RAFEDD - Test Forgot Password Feature" -ForegroundColor Cyan
Write-Host "================================================================================" -ForegroundColor Cyan
Write-Host ""

$ApiUrl = "http://localhost:5041"
$TestEmail = "manager@rafeed.com"
$NewPassword = "newpassword123"

Write-Host "[INFO] Testing forgot password flow for: $TestEmail" -ForegroundColor Yellow
Write-Host ""

# Step 1: Request Password Reset Token
Write-Host "[STEP 1] Requesting password reset token..." -ForegroundColor Yellow

$forgotPasswordRequest = @{
    email = $TestEmail
} | ConvertTo-Json

try {
    $forgotResponse = Invoke-RestMethod -Uri "$ApiUrl/api/v1/auth/forgot-password" -Method POST -Body $forgotPasswordRequest -ContentType "application/json" -ErrorAction Stop

    Write-Host "[SUCCESS] Password reset token generated!" -ForegroundColor Green
    Write-Host "Response:" -ForegroundColor Gray
    Write-Host ($forgotResponse | ConvertTo-Json -Depth 3) -ForegroundColor White

    $resetToken = $forgotResponse.data.resetToken
    Write-Host ""
    Write-Host "Reset Token: $($resetToken.Substring(0, [Math]::Min(50, $resetToken.Length)))..." -ForegroundColor Cyan

} catch {
    Write-Host "[ERROR] Failed to request password reset" -ForegroundColor Red
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
    if ($_.ErrorDetails.Message) {
        $errorDetail = $_.ErrorDetails.Message | ConvertFrom-Json
        Write-Host "Details: $($errorDetail.error)" -ForegroundColor Red
    }
    exit 1
}

Write-Host ""
Start-Sleep -Seconds 2

# Step 2: Reset Password with Token
Write-Host "[STEP 2] Resetting password with token..." -ForegroundColor Yellow

$resetPasswordRequest = @{
    email = $TestEmail
    resetToken = $resetToken
    newPassword = $NewPassword
    confirmPassword = $NewPassword
} | ConvertTo-Json

try {
    $resetResponse = Invoke-RestMethod -Uri "$ApiUrl/api/v1/auth/reset-password" -Method POST -Body $resetPasswordRequest -ContentType "application/json" -ErrorAction Stop

    Write-Host "[SUCCESS] Password reset successful!" -ForegroundColor Green
    Write-Host "Response:" -ForegroundColor Gray
    Write-Host ($resetResponse | ConvertTo-Json -Depth 3) -ForegroundColor White

} catch {
    Write-Host "[ERROR] Failed to reset password" -ForegroundColor Red
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
    if ($_.ErrorDetails.Message) {
        $errorDetail = $_.ErrorDetails.Message | ConvertFrom-Json
        Write-Host "Details: $($errorDetail.error)" -ForegroundColor Red
    }
    exit 1
}

Write-Host ""
Start-Sleep -Seconds 2

# Step 3: Test Login with New Password
Write-Host "[STEP 3] Testing login with new password..." -ForegroundColor Yellow

$loginRequest = @{
    emailOrPhone = $TestEmail
    password = $NewPassword
} | ConvertTo-Json

try {
    $loginResponse = Invoke-RestMethod -Uri "$ApiUrl/api/v1/auth/login" -Method POST -Body $loginRequest -ContentType "application/json" -ErrorAction Stop

    Write-Host "[SUCCESS] Login successful with new password!" -ForegroundColor Green
    Write-Host "User: $($loginResponse.user.fullName)" -ForegroundColor Gray
    Write-Host "Email: $($loginResponse.user.email)" -ForegroundColor Gray
    Write-Host "Token: $($loginResponse.token.Substring(0, 20))..." -ForegroundColor Gray

} catch {
    Write-Host "[ERROR] Failed to login with new password" -ForegroundColor Red
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
    if ($_.ErrorDetails.Message) {
        $errorDetail = $_.ErrorDetails.Message | ConvertFrom-Json
        Write-Host "Details: $($errorDetail.error)" -ForegroundColor Red
    }
    exit 1
}

Write-Host ""
Write-Host "================================================================================" -ForegroundColor Cyan
Write-Host "ALL TESTS PASSED!" -ForegroundColor Green
Write-Host "================================================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Forgot Password Feature Status:" -ForegroundColor Yellow
Write-Host "  [OK] Request reset token" -ForegroundColor Green
Write-Host "  [OK] Reset password with token" -ForegroundColor Green
Write-Host "  [OK] Login with new password" -ForegroundColor Green
Write-Host ""
Write-Host "NOTE: Reset the password back to 'manager123' if needed" -ForegroundColor Yellow
Write-Host ""
