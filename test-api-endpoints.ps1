# Rafedd API Endpoint Testing Script
# Tests all endpoints required by frontend

$baseUrl = "http://localhost:5041/api/v1"
$results = @()

# Test helper function
function Test-Endpoint {
    param(
        [string]$Name,
        [string]$Method,
        [string]$Url,
        [string]$Token = "",
        [string]$Body = "",
        [string]$ExpectedField = "success"
    )

    Write-Host "`n========================================" -ForegroundColor Cyan
    Write-Host "Testing: $Name" -ForegroundColor Yellow
    Write-Host "URL: $Url" -ForegroundColor Gray

    try {
        $headers = @{
            "Content-Type" = "application/json"
        }

        if ($Token) {
            $headers["Authorization"] = "Bearer $Token"
        }

        $params = @{
            Uri = $Url
            Method = $Method
            Headers = $headers
            TimeoutSec = 10
        }

        if ($Body) {
            $params["Body"] = $Body
        }

        $response = Invoke-RestMethod @params -ErrorAction Stop

        if ($response.$ExpectedField) {
            Write-Host "[PASS] $Name" -ForegroundColor Green
            $script:results += [PSCustomObject]@{
                Test = $Name
                Status = "PASS"
                Response = ($response | ConvertTo-Json -Compress).Substring(0, [Math]::Min(100, ($response | ConvertTo-Json).Length))
            }
            return $response
        } else {
            Write-Host "[FAIL] $Name - Missing expected field: $ExpectedField" -ForegroundColor Red
            $script:results += [PSCustomObject]@{
                Test = $Name
                Status = "FAIL"
                Response = "Missing field: $ExpectedField"
            }
        }
    }
    catch {
        Write-Host "[ERROR] $Name - $($_.Exception.Message)" -ForegroundColor Red
        $script:results += [PSCustomObject]@{
            Test = $Name
            Status = "ERROR"
            Response = $_.Exception.Message
        }
    }
}

Write-Host "`n============================================" -ForegroundColor Magenta
Write-Host "RAFEDD API ENDPOINT TESTING" -ForegroundColor Magenta
Write-Host "============================================`n" -ForegroundColor Magenta

# ========== AUTHENTICATION TESTS ==========
Write-Host "`n>>> AUTHENTICATION ENDPOINTS <<<`n" -ForegroundColor Magenta

# Test 1: Manager Login
$loginResponse = Test-Endpoint `
    -Name "POST /auth/login - Manager" `
    -Method "POST" `
    -Url "$baseUrl/auth/login" `
    -Body '{"emailOrPhone":"manager@rafeed.com","password":"manager123"}'

$managerToken = $loginResponse.token

# Test 2: Employee Login
$empLoginResponse = Test-Endpoint `
    -Name "POST /auth/login - Employee" `
    -Method "POST" `
    -Url "$baseUrl/auth/login" `
    -Body '{"emailOrPhone":"sara@rafeed.com","password":"employee123"}'

$employeeToken = $empLoginResponse.token

# Test 3: Manager Registration
Test-Endpoint `
    -Name "POST /auth/register/manager" `
    -Method "POST" `
    -Url "$baseUrl/auth/register/manager" `
    -Body '{"fullName":"New Manager","email":"newmgr@test.com","password":"newmgr123","companyName":"New Co","businessType":"Tech","subscriptionPlanId":1}'

# ========== MANAGER ENDPOINTS ==========
Write-Host "`n>>> MANAGER ENDPOINTS <<<`n" -ForegroundColor Magenta

# Test 4: Manager Dashboard
Test-Endpoint `
    -Name "GET /manager/dashboard" `
    -Method "GET" `
    -Url "$baseUrl/manager/dashboard" `
    -Token $managerToken

# Test 5: Get Employees
Test-Endpoint `
    -Name "GET /manager/employees" `
    -Method "GET" `
    -Url "$baseUrl/manager/employees" `
    -Token $managerToken

# Test 6: Add Employee
$addEmpResponse = Test-Endpoint `
    -Name "POST /manager/employees" `
    -Method "POST" `
    -Url "$baseUrl/manager/employees" `
    -Token $managerToken `
    -Body '{"fullName":"New Employee","email":"newemp@test.com","position":"Developer"}'

# Test 7: Get Important Notes (Manager)
Test-Endpoint `
    -Name "GET /manager/important-notes" `
    -Method "GET" `
    -Url "$baseUrl/manager/important-notes" `
    -Token $managerToken

# Test 8: Get Manager Profile
Test-Endpoint `
    -Name "GET /manager/profile" `
    -Method "GET" `
    -Url "$baseUrl/manager/profile" `
    -Token $managerToken

# ========== EMPLOYEE ENDPOINTS ==========
Write-Host "`n>>> EMPLOYEE ENDPOINTS <<<`n" -ForegroundColor Magenta

# Test 9: Employee Dashboard
Test-Endpoint `
    -Name "GET /employee/dashboard" `
    -Method "GET" `
    -Url "$baseUrl/employee/dashboard" `
    -Token $employeeToken

# Test 10: Get Employee Important Notes
Test-Endpoint `
    -Name "GET /employee/important-notes" `
    -Method "GET" `
    -Url "$baseUrl/employee/important-notes" `
    -Token $employeeToken

# Test 11: Create Important Note
Test-Endpoint `
    -Name "POST /employee/important-notes" `
    -Method "POST" `
    -Url "$baseUrl/employee/important-notes" `
    -Token $employeeToken `
    -Body '{"title":"Test Note","content":"Test Content","weekNumber":4,"month":11,"year":2025}'

# ========== FILE UPLOAD ==========
Write-Host "`n>>> FILE UPLOAD ENDPOINT <<<`n" -ForegroundColor Magenta

# Note: File upload requires multipart/form-data, tested separately

# ========== SUMMARY ==========
Write-Host "`n============================================" -ForegroundColor Magenta
Write-Host "TEST SUMMARY" -ForegroundColor Magenta
Write-Host "============================================`n" -ForegroundColor Magenta

$passCount = ($results | Where-Object { $_.Status -eq "PASS" }).Count
$failCount = ($results | Where-Object { $_.Status -eq "FAIL" }).Count
$errorCount = ($results | Where-Object { $_.Status -eq "ERROR" }).Count
$total = $results.Count

Write-Host "Total Tests: $total" -ForegroundColor White
Write-Host "Passed: $passCount" -ForegroundColor Green
Write-Host "Failed: $failCount" -ForegroundColor Red
Write-Host "Errors: $errorCount" -ForegroundColor Yellow
Write-Host "`nPass Rate: $([Math]::Round(($passCount/$total)*100, 2))%" -ForegroundColor Cyan

# Export results
$results | Export-Csv -Path "d:\Rafedd-master\test-results.csv" -NoTypeInformation
Write-Host "`nDetailed results exported to: d:\Rafedd-master\test-results.csv" -ForegroundColor Gray

# Display failed/error tests
if ($failCount -gt 0 -or $errorCount -gt 0) {
    Write-Host "`n>>> FAILED/ERROR TESTS <<<`n" -ForegroundColor Red
    $results | Where-Object { $_.Status -ne "PASS" } | Format-Table -AutoSize
}
