# Comprehensive API Testing - ACTUAL Backend Routes
$baseUrl = "http://localhost:5041/api/v1"
$results = @()

function Test-API {
    param($Name, $Method, $Url, $Token = "", $Body = "")

    Write-Host "`n[$Method] $Url" -ForegroundColor Cyan
    try {
        $headers = @{"Content-Type" = "application/json"}
        if ($Token) { $headers["Authorization"] = "Bearer $Token" }

        $params = @{Uri = $Url; Method = $Method; Headers = $headers; TimeoutSec = 10}
        if ($Body) { $params["Body"] = $Body }

        $response = Invoke-RestMethod @params -ErrorAction Stop
        Write-Host "✅ PASS" -ForegroundColor Green
        $script:results += @{Test=$Name; Status="PASS"}
        return $response
    }
    catch {
        Write-Host "❌ FAIL: $($_.Exception.Message)" -ForegroundColor Red
        $script:results += @{Test=$Name; Status="FAIL"; Error=$_.Exception.Message}
        return $null
    }
}

Write-Host "`n=== RAFEDD API COMPREHENSIVE TEST ===" -ForegroundColor Magenta

# LOGIN
Write-Host "`n>>> AUTHENTICATION <<<" -ForegroundColor Yellow
$mgr = Test-API "Manager Login" "POST" "$baseUrl/auth/login" "" '{"emailOrPhone":"manager@rafeed.com","password":"manager123"}'
$emp = Test-API "Employee Login" "POST" "$baseUrl/auth/login" "" '{"emailOrPhone":"sara@rafeed.com","password":"employee123"}'
$adm = Test-API "Admin Login" "POST" "$baseUrl/auth/login" "" '{"emailOrPhone":"admin@rafeed.com","password":"admin123"}'

$mgrToken = $mgr.token
$empToken = $emp.token
$admToken = $adm.token

# MANAGER ENDPOINTS
Write-Host "`n>>> MANAGER FEATURES <<<" -ForegroundColor Yellow
Test-API "Manager Dashboard" "GET" "$baseUrl/manager/dashboard" $mgrToken
Test-API "Get Manager Profile" "GET" "$baseUrl/users/profile" $mgrToken

# EMPLOYEE MANAGEMENT (via UsersController)
Write-Host "`n>>> EMPLOYEE MANAGEMENT <<<" -ForegroundColor Yellow
Test-API "List Employees" "GET" "$baseUrl/users/employees" $mgrToken
Test-API "Get Employee Details" "GET" "$baseUrl/users/employees/f569b519-f059-4ba5-97b5-ed18a9765748" $mgrToken

# TASKS
Write-Host "`n>>> TASK MANAGEMENT <<<" -ForegroundColor Yellow
Test-API "Get Weekly Tasks" "GET" "$baseUrl/tasks/weekly?month=11&year=2025" $mgrToken
Test-API "Get All Tasks" "GET" "$baseUrl/tasks" $mgrToken

# REPORTS
Write-Host "`n>>> REPORTS <<<" -ForegroundColor Yellow
Test-API "Get Weekly Reports" "GET" "$baseUrl/reports/weekly" $mgrToken
Test-API "Get Daily Reports" "GET" "$baseUrl/reports/daily" $mgrToken

# SUGGESTIONS
Write-Host "`n>>> SUGGESTIONS <<<" -ForegroundColor Yellow
Test-API "Get Suggestions" "GET" "$baseUrl/suggestions" $mgrToken
Test-API "Employee - Get Own Suggestions" "GET" "$baseUrl/employee/suggestions" $empToken

# IMPORTANT NOTES
Write-Host "`n>>> IMPORTANT NOTES <<<" -ForegroundColor Yellow
Test-API "Manager - Get Notes" "GET" "$baseUrl/manager/important-notes" $mgrToken
Test-API "Employee - Get Notes" "GET" "$baseUrl/employee/important-notes" $empToken
$note = Test-API "Employee - Create Note" "POST" "$baseUrl/employee/important-notes" $empToken '{"title":"API Test Note","content":"Testing from PowerShell","weekNumber":4,"month":11,"year":2025}'
if ($note) {
    Test-API "Employee - Get Note by ID" "GET" "$baseUrl/important-notes/$($note.data.id)" $empToken
    Test-API "Employee - Update Note" "PUT" "$baseUrl/employee/important-notes/$($note.data.id)" $empToken '{"title":"Updated Note","content":"Updated content","weekNumber":4,"month":11,"year":2025}'
    Test-API "Employee - Delete Note" "DELETE" "$baseUrl/employee/important-notes/$($note.data.id)" $empToken
}

# ANNUAL PLAN
Write-Host "`n>>> ANNUAL PLAN <<<" -ForegroundColor Yellow
Test-API "Get Annual Plan" "GET" "$baseUrl/annual-plan?year=2025" $mgrToken
$plan = Test-API "Generate Annual Plan" "POST" "$baseUrl/annual-plan/generate" $mgrToken '{"goal":"Increase revenue by 50%","year":2025}'

# EMPLOYEE FEATURES
Write-Host "`n>>> EMPLOYEE FEATURES <<<" -ForegroundColor Yellow
Test-API "Employee - Get Tasks" "GET" "$baseUrl/employee/tasks" $empToken
Test-API "Employee - Get Profile" "GET" "$baseUrl/users/profile" $empToken

# ADMIN FEATURES
Write-Host "`n>>> ADMIN FEATURES <<<" -ForegroundColor Yellow
Test-API "Admin Dashboard" "GET" "$baseUrl/admin/dashboard" $admToken
Test-API "Get All Companies" "GET" "$baseUrl/admin/companies" $admToken

# FILE UPLOAD (already tested, just verify)
Write-Host "`n>>> FILE OPERATIONS <<<" -ForegroundColor Yellow
Write-Host "File upload endpoint: POST $baseUrl/upload (multipart/form-data)" -ForegroundColor Gray
Write-Host "File download endpoint: GET $baseUrl/uploads/{filename}" -ForegroundColor Gray

# SUMMARY
Write-Host "`n=== TEST SUMMARY ===" -ForegroundColor Magenta
$passed = ($results | Where-Object { $_.Status -eq "PASS" }).Count
$failed = ($results | Where-Object { $_.Status -eq "FAIL" }).Count
$total = $results.Count

Write-Host "Total: $total | Passed: $passed | Failed: $failed" -ForegroundColor White
Write-Host "Success Rate: $([Math]::Round(($passed/$total)*100, 2))%" -ForegroundColor Cyan

if ($failed -gt 0) {
    Write-Host "`n>>> FAILED TESTS <<<" -ForegroundColor Red
    $results | Where-Object { $_.Status -eq "FAIL" } | ForEach-Object {
        Write-Host "❌ $($_.Test): $($_.Error)" -ForegroundColor Red
    }
}

# Export detailed results
$results | Export-Csv "d:\Rafedd-master\test-results-complete.csv" -NoTypeInformation
Write-Host "`nDetailed results: d:\Rafedd-master\test-results-complete.csv" -ForegroundColor Gray
