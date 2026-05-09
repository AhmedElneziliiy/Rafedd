[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

# Test All Gemini AI Endpoints
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "TESTING ALL GEMINI AI ENDPOINTS" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$baseUrl = "http://localhost:5041"

# Step 1: Authenticate
Write-Host "STEP 1: AUTHENTICATION" -ForegroundColor Yellow

$loginBody = @{
    emailOrPhone = "manager@rafeed.com"
    password = "manager123"
} | ConvertTo-Json

try {
    $loginResponse = Invoke-RestMethod -Uri "$baseUrl/api/v1/auth/login" -Method Post -Body $loginBody -ContentType "application/json"
    $token = $loginResponse.token
    Write-Host "SUCCESS - User logged in" -ForegroundColor Green
    Write-Host ""
} catch {
    Write-Host "FAILED - Cannot authenticate" -ForegroundColor Red
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

$headers = @{
    "Authorization" = "Bearer $token"
    "Content-Type" = "application/json"
}

# Test 1: Create Annual Target with AI Planning
Write-Host "TEST 1: Annual Target (AI generates 48-week plan)" -ForegroundColor Cyan

$annualTargetBody = @{
    targetYear = 2026
    totalTargetRevenue = 1000000.0
    description = "Revenue target for 2026 - AI Test"
} | ConvertTo-Json

try {
    $result = Invoke-RestMethod -Uri "$baseUrl/api/v1/manager/annual-targets" -Method Post -Headers $headers -Body $annualTargetBody -ErrorAction Stop

    if ($result.success) {
        Write-Host "SUCCESS" -ForegroundColor Green
        Write-Host "Annual Target ID: $($result.data.id)" -ForegroundColor White
        Write-Host "Target Revenue: $($result.data.totalTargetRevenue) SAR" -ForegroundColor White
        Write-Host "Monthly Plans: $($result.data.monthlyPlans.Count)" -ForegroundColor White

        $weeklyCount = 0
        foreach ($month in $result.data.monthlyPlans) {
            $weeklyCount += $month.weeklyPlans.Count
        }
        Write-Host "Weekly Plans (AI): $weeklyCount" -ForegroundColor Green

        # Store for later tests
        $global:annualTargetId = $result.data.id
        $global:monthlyPlanId = $result.data.monthlyPlans[0].id
        $global:weeklyPlanId = $result.data.monthlyPlans[0].weeklyPlans[0].id
    }
    Write-Host ""
} catch {
    Write-Host "FAILED" -ForegroundColor Red
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
    if ($_.ErrorDetails) {
        Write-Host "Details: $($_.ErrorDetails.Message)" -ForegroundColor Red
    }
    Write-Host ""
}

# Test 2: Create Task
Write-Host "TEST 2: Create Task (for AI analysis)" -ForegroundColor Cyan

if ($global:weeklyPlanId) {
    $taskBody = @{
        weeklyPlanId = $global:weeklyPlanId
        taskName = "Payment Integration Development"
        description = "Develop integrated payment system with MyFatoorah and complete testing"
        priority = "High"
        estimatedHours = 40
        dueDate = (Get-Date).AddDays(7).ToString("yyyy-MM-ddTHH:mm:ss")
    } | ConvertTo-Json

    try {
        $taskResult = Invoke-RestMethod -Uri "$baseUrl/api/v1/manager/tasks" -Method Post -Headers $headers -Body $taskBody -ErrorAction Stop

        if ($taskResult.success) {
            Write-Host "SUCCESS" -ForegroundColor Green
            Write-Host "Task ID: $($taskResult.data.id)" -ForegroundColor White
            Write-Host "Task Name: $($taskResult.data.taskName)" -ForegroundColor White

            $global:taskId = $taskResult.data.id
        }
        Write-Host ""
    } catch {
        Write-Host "FAILED" -ForegroundColor Red
        Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
        Write-Host ""
    }
}

# Test 3: Analyze Task with AI
Write-Host "TEST 3: Analyze Task (Gemini AI)" -ForegroundColor Cyan

if ($global:taskId) {
    try {
        $analysisResult = Invoke-RestMethod -Uri "$baseUrl/api/v1/manager/tasks/$global:taskId/analyze" -Method Post -Headers $headers -ErrorAction Stop

        if ($analysisResult.success) {
            Write-Host "SUCCESS - AI Analysis Complete" -ForegroundColor Green
            Write-Host "Complexity: $($analysisResult.data.complexity)" -ForegroundColor White
            Write-Host "Estimated Hours: $($analysisResult.data.estimatedHours)" -ForegroundColor White
            Write-Host "Risk Level: $($analysisResult.data.riskLevel)" -ForegroundColor White
            Write-Host "Has Recommendations: $($analysisResult.data.recommendations.Length -gt 0)" -ForegroundColor Cyan
        }
        Write-Host ""
    } catch {
        Write-Host "FAILED" -ForegroundColor Red
        Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
        if ($_.ErrorDetails) {
            Write-Host "Details: $($_.ErrorDetails.Message)" -ForegroundColor Red
        }
        Write-Host ""
    }
}

# Test 4: Batch Analyze Tasks
Write-Host "TEST 4: Batch Analyze Tasks" -ForegroundColor Cyan

if ($global:taskId) {
    $batchBody = @($global:taskId) | ConvertTo-Json

    try {
        $batchResult = Invoke-RestMethod -Uri "$baseUrl/api/v1/manager/tasks/analyze-batch" -Method Post -Headers $headers -Body $batchBody -ContentType "application/json" -ErrorAction Stop

        if ($batchResult.success) {
            Write-Host "SUCCESS" -ForegroundColor Green
            Write-Host "Tasks Analyzed: $($batchResult.data.Count)" -ForegroundColor White
        }
        Write-Host ""
    } catch {
        Write-Host "FAILED" -ForegroundColor Red
        Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
        Write-Host ""
    }
}

# Test 5: Weekly Performance Report with AI
Write-Host "TEST 5: Weekly Performance Report (AI)" -ForegroundColor Cyan

if ($global:weeklyPlanId) {
    try {
        $weeklyReportResult = Invoke-RestMethod -Uri "$baseUrl/api/v1/manager/performance-reports/$global:weeklyPlanId/generate" -Method Post -Headers $headers -ErrorAction Stop

        if ($weeklyReportResult.success) {
            Write-Host "SUCCESS - Weekly Report Generated" -ForegroundColor Green
            Write-Host "Week Number: $($weeklyReportResult.data.weekNumber)" -ForegroundColor White
            Write-Host "Performance Score: $($weeklyReportResult.data.performanceScore)%" -ForegroundColor White
            Write-Host "Has AI Insights: $($weeklyReportResult.data.insights.Length -gt 0)" -ForegroundColor Cyan
        }
        Write-Host ""
    } catch {
        Write-Host "FAILED" -ForegroundColor Red
        Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
        if ($_.ErrorDetails) {
            Write-Host "Details: $($_.ErrorDetails.Message)" -ForegroundColor Red
        }
        Write-Host ""
    }
}

# Test 6: Monthly Performance Report with AI
Write-Host "TEST 6: Monthly Performance Report (Advanced AI)" -ForegroundColor Cyan

if ($global:monthlyPlanId) {
    try {
        $monthlyReportResult = Invoke-RestMethod -Uri "$baseUrl/api/v1/manager/monthly-reports/$global:monthlyPlanId/generate" -Method Post -Headers $headers -ErrorAction Stop

        if ($monthlyReportResult.success) {
            Write-Host "SUCCESS - Monthly Report Generated" -ForegroundColor Green
            Write-Host "Month: $($monthlyReportResult.data.month)" -ForegroundColor White
            Write-Host "Overall Score: $($monthlyReportResult.data.overallScore)%" -ForegroundColor White
            Write-Host "Has AI Summary: $($monthlyReportResult.data.executiveSummary.Length -gt 0)" -ForegroundColor Cyan
        }
        Write-Host ""
    } catch {
        Write-Host "FAILED" -ForegroundColor Red
        Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
        if ($_.ErrorDetails) {
            Write-Host "Details: $($_.ErrorDetails.Message)" -ForegroundColor Red
        }
        Write-Host ""
    }
}

# Summary
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "TEST SUMMARY" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Gemini AI Features:" -ForegroundColor Yellow
Write-Host "1. Annual Planning (48-week generation)" -ForegroundColor White
Write-Host "2. Task Analysis (complexity, effort, risks)" -ForegroundColor White
Write-Host "3. Batch Task Analysis" -ForegroundColor White
Write-Host "4. Weekly Performance Reports" -ForegroundColor White
Write-Host "5. Monthly Performance Reports" -ForegroundColor White
Write-Host ""
Write-Host "API Key: AIzaSyDWHGeWYyjJOoEsX3vG6y3wHAunpklMGYA" -ForegroundColor White
Write-Host "Model: gemini-2.5-flash" -ForegroundColor White
Write-Host ""
