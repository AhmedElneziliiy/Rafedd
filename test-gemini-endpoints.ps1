# Test All Gemini AI Endpoints
Write-Host "=" * 100 -ForegroundColor Cyan
Write-Host "  TESTING ALL GEMINI AI ENDPOINTS" -ForegroundColor Green
Write-Host "=" * 100 -ForegroundColor Cyan
Write-Host ""

$baseUrl = "http://localhost:5041"

# Step 1: Authenticate
Write-Host "STEP 1: AUTHENTICATION" -ForegroundColor Yellow
Write-Host "-" * 100 -ForegroundColor Gray

$loginBody = @{
    emailOrPhone = "manager@rafeed.com"
    password = "manager123"
} | ConvertTo-Json

try {
    $loginResponse = Invoke-RestMethod -Uri "$baseUrl/api/v1/auth/login" -Method Post -Body $loginBody -ContentType "application/json"
    $token = $loginResponse.token
    Write-Host "   Status: SUCCESS" -ForegroundColor Green
    Write-Host "   User: $($loginResponse.user.fullName)" -ForegroundColor White
    Write-Host "   Email: $($loginResponse.user.email)" -ForegroundColor White
    Write-Host ""
} catch {
    Write-Host "   Status: FAILED" -ForegroundColor Red
    Write-Host "   Error: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host ""
    exit 1
}

$headers = @{
    "Authorization" = "Bearer $token"
    "Content-Type" = "application/json"
}

# Test 1: Create Annual Target with AI Planning
Write-Host "TEST 1: CREATE ANNUAL TARGET (AI Planning - 48 Weeks)" -ForegroundColor Cyan
Write-Host "-" * 100 -ForegroundColor Gray
Write-Host "Endpoint: POST /api/v1/manager/annual-targets" -ForegroundColor White
Write-Host "AI Feature: Generates complete 48-week plan using Gemini AI" -ForegroundColor White
Write-Host ""

$annualTargetBody = @{
    targetYear = 2026
    totalTargetRevenue = 1000000.0
    description = "هدف الإيرادات لعام 2026 - اختبار AI"
} | ConvertTo-Json

try {
    $result = Invoke-RestMethod -Uri "$baseUrl/api/v1/manager/annual-targets" -Method Post -Headers $headers -Body $annualTargetBody

    if ($result.success) {
        Write-Host "   Status: SUCCESS" -ForegroundColor Green
        Write-Host "   Message: $($result.message)" -ForegroundColor Green
        Write-Host "   Annual Target ID: $($result.data.id)" -ForegroundColor White
        Write-Host "   Target Revenue: $($result.data.totalTargetRevenue) SAR" -ForegroundColor White
        Write-Host "   Year: $($result.data.targetYear)" -ForegroundColor White
        Write-Host "   Monthly Plans Generated: $($result.data.monthlyPlans.Count)" -ForegroundColor White

        $weeklyCount = 0
        foreach ($month in $result.data.monthlyPlans) {
            $weeklyCount += $month.weeklyPlans.Count
        }
        Write-Host "   Weekly Plans Generated: $weeklyCount (AI-powered)" -ForegroundColor Green
        Write-Host ""
    } else {
        Write-Host "   Status: FAILED" -ForegroundColor Red
        Write-Host "   Message: $($result.message)" -ForegroundColor Red
        Write-Host ""
    }

    # Store for later tests
    $annualTargetId = $result.data.id
    $monthlyPlanId = $result.data.monthlyPlans[0].id
    $weeklyPlanId = $result.data.monthlyPlans[0].weeklyPlans[0].id

} catch {
    Write-Host "   Status: ERROR" -ForegroundColor Red
    Write-Host "   Error: $($_.Exception.Message)" -ForegroundColor Red

    if ($_.ErrorDetails) {
        Write-Host "   Details: $($_.ErrorDetails.Message)" -ForegroundColor Red
    }
    Write-Host ""
}

# Test 2: Create Task (will be used for AI analysis)
Write-Host "TEST 2: CREATE TASK (For AI Analysis)" -ForegroundColor Cyan
Write-Host "-" * 100 -ForegroundColor Gray
Write-Host "Endpoint: POST /api/v1/manager/tasks" -ForegroundColor White
Write-Host ""

if ($weeklyPlanId) {
    $taskBody = @{
        weeklyPlanId = $weeklyPlanId
        taskName = "تطوير ميزة الدفع الإلكتروني"
        description = "تطوير نظام الدفع المتكامل مع MyFatoorah والاختبار الكامل"
        priority = "High"
        estimatedHours = 40
        dueDate = (Get-Date).AddDays(7).ToString("yyyy-MM-ddTHH:mm:ss")
    } | ConvertTo-Json

    try {
        $taskResult = Invoke-RestMethod -Uri "$baseUrl/api/v1/manager/tasks" -Method Post -Headers $headers -Body $taskBody

        if ($taskResult.success) {
            Write-Host "   Status: SUCCESS" -ForegroundColor Green
            Write-Host "   Task ID: $($taskResult.data.id)" -ForegroundColor White
            Write-Host "   Task Name: $($taskResult.data.taskName)" -ForegroundColor White
            Write-Host "   Priority: $($taskResult.data.priority)" -ForegroundColor White
            Write-Host ""

            $taskId = $taskResult.data.id
        } else {
            Write-Host "   Status: FAILED" -ForegroundColor Red
            Write-Host "   Message: $($taskResult.message)" -ForegroundColor Red
            Write-Host ""
        }
    } catch {
        Write-Host "   Status: ERROR" -ForegroundColor Red
        Write-Host "   Error: $($_.Exception.Message)" -ForegroundColor Red
        Write-Host ""
    }
} else {
    Write-Host "   Status: SKIPPED (No weekly plan available)" -ForegroundColor Yellow
    Write-Host ""
}

# Test 3: Analyze Single Task with AI
Write-Host "TEST 3: ANALYZE TASK (Gemini AI Analysis)" -ForegroundColor Cyan
Write-Host "-" * 100 -ForegroundColor Gray
Write-Host "Endpoint: POST /api/v1/manager/tasks/{taskId}/analyze" -ForegroundColor White
Write-Host "AI Feature: Analyzes task complexity, estimates effort, suggests improvements" -ForegroundColor White
Write-Host ""

if ($taskId) {
    try {
        $analysisResult = Invoke-RestMethod -Uri "$baseUrl/api/v1/manager/tasks/$taskId/analyze" -Method Post -Headers $headers

        if ($analysisResult.success) {
            Write-Host "   Status: SUCCESS" -ForegroundColor Green
            Write-Host "   Message: $($analysisResult.message)" -ForegroundColor Green
            Write-Host ""
            Write-Host "   AI Analysis Results:" -ForegroundColor Yellow
            Write-Host "   Task: $($analysisResult.data.taskName)" -ForegroundColor White
            Write-Host "   Complexity: $($analysisResult.data.complexity)" -ForegroundColor White
            Write-Host "   Estimated Hours: $($analysisResult.data.estimatedHours)" -ForegroundColor White
            Write-Host "   Risk Level: $($analysisResult.data.riskLevel)" -ForegroundColor White
            Write-Host "   Recommendations: $($analysisResult.data.recommendations)" -ForegroundColor Cyan
            Write-Host "   Alternative Approaches: $($analysisResult.data.alternativeApproaches)" -ForegroundColor Cyan
            Write-Host ""
        } else {
            Write-Host "   Status: FAILED" -ForegroundColor Red
            Write-Host "   Message: $($analysisResult.message)" -ForegroundColor Red
            Write-Host ""
        }
    } catch {
        Write-Host "   Status: ERROR" -ForegroundColor Red
        Write-Host "   Error: $($_.Exception.Message)" -ForegroundColor Red

        if ($_.ErrorDetails) {
            Write-Host "   Details: $($_.ErrorDetails.Message)" -ForegroundColor Red
        }
        Write-Host ""
    }
} else {
    Write-Host "   Status: SKIPPED (No task available)" -ForegroundColor Yellow
    Write-Host ""
}

# Test 4: Batch Analyze Tasks
Write-Host "TEST 4: BATCH ANALYZE TASKS (Multiple Tasks at Once)" -ForegroundColor Cyan
Write-Host "-" * 100 -ForegroundColor Gray
Write-Host "Endpoint: POST /api/v1/manager/tasks/analyze-batch" -ForegroundColor White
Write-Host "AI Feature: Analyzes multiple tasks simultaneously" -ForegroundColor White
Write-Host ""

if ($taskId) {
    $batchBody = @($taskId) | ConvertTo-Json

    try {
        $batchResult = Invoke-RestMethod -Uri "$baseUrl/api/v1/manager/tasks/analyze-batch" -Method Post -Headers $headers -Body $batchBody -ContentType "application/json"

        if ($batchResult.success) {
            Write-Host "   Status: SUCCESS" -ForegroundColor Green
            Write-Host "   Message: $($batchResult.message)" -ForegroundColor Green
            Write-Host "   Tasks Analyzed: $($batchResult.data.Count)" -ForegroundColor White
            Write-Host ""

            foreach ($analysis in $batchResult.data) {
                Write-Host "   Task: $($analysis.taskName)" -ForegroundColor Cyan
                Write-Host "      Complexity: $($analysis.complexity)" -ForegroundColor White
                Write-Host "      Estimated Hours: $($analysis.estimatedHours)" -ForegroundColor White
                Write-Host ""
            }
        } else {
            Write-Host "   Status: FAILED" -ForegroundColor Red
            Write-Host "   Message: $($batchResult.message)" -ForegroundColor Red
            Write-Host ""
        }
    } catch {
        Write-Host "   Status: ERROR" -ForegroundColor Red
        Write-Host "   Error: $($_.Exception.Message)" -ForegroundColor Red
        Write-Host ""
    }
} else {
    Write-Host "   Status: SKIPPED (No tasks available)" -ForegroundColor Yellow
    Write-Host ""
}

# Test 5: Generate Weekly Performance Report with AI
Write-Host "TEST 5: GENERATE WEEKLY PERFORMANCE REPORT (AI Analysis)" -ForegroundColor Cyan
Write-Host "-" * 100 -ForegroundColor Gray
Write-Host "Endpoint: POST /api/v1/manager/performance-reports/{weeklyPlanId}/generate" -ForegroundColor White
Write-Host "AI Feature: Analyzes weekly performance and provides insights" -ForegroundColor White
Write-Host ""

if ($weeklyPlanId) {
    try {
        $weeklyReportResult = Invoke-RestMethod -Uri "$baseUrl/api/v1/manager/performance-reports/$weeklyPlanId/generate" -Method Post -Headers $headers

        if ($weeklyReportResult.success) {
            Write-Host "   Status: SUCCESS" -ForegroundColor Green
            Write-Host "   Message: $($weeklyReportResult.message)" -ForegroundColor Green
            Write-Host ""
            Write-Host "   Weekly Performance Report:" -ForegroundColor Yellow
            Write-Host "   Week Number: $($weeklyReportResult.data.weekNumber)" -ForegroundColor White
            Write-Host "   Performance Score: $($weeklyReportResult.data.performanceScore)%" -ForegroundColor White
            Write-Host "   Tasks Completed: $($weeklyReportResult.data.tasksCompleted)" -ForegroundColor White
            Write-Host "   AI Insights: $($weeklyReportResult.data.insights)" -ForegroundColor Cyan
            Write-Host "   Recommendations: $($weeklyReportResult.data.recommendations)" -ForegroundColor Cyan
            Write-Host ""
        } else {
            Write-Host "   Status: FAILED" -ForegroundColor Red
            Write-Host "   Message: $($weeklyReportResult.message)" -ForegroundColor Red
            Write-Host ""
        }
    } catch {
        Write-Host "   Status: ERROR" -ForegroundColor Red
        Write-Host "   Error: $($_.Exception.Message)" -ForegroundColor Red

        if ($_.ErrorDetails) {
            Write-Host "   Details: $($_.ErrorDetails.Message)" -ForegroundColor Red
        }
        Write-Host ""
    }
} else {
    Write-Host "   Status: SKIPPED (No weekly plan available)" -ForegroundColor Yellow
    Write-Host ""
}

# Test 6: Generate Monthly Performance Report with AI
Write-Host "TEST 6: GENERATE MONTHLY PERFORMANCE REPORT (Advanced AI Analysis)" -ForegroundColor Cyan
Write-Host "-" * 100 -ForegroundColor Gray
Write-Host "Endpoint: POST /api/v1/manager/monthly-reports/{monthlyPlanId}/generate" -ForegroundColor White
Write-Host "AI Feature: Comprehensive monthly analysis with trends and predictions" -ForegroundColor White
Write-Host ""

if ($monthlyPlanId) {
    try {
        $monthlyReportResult = Invoke-RestMethod -Uri "$baseUrl/api/v1/manager/monthly-reports/$monthlyPlanId/generate" -Method Post -Headers $headers

        if ($monthlyReportResult.success) {
            Write-Host "   Status: SUCCESS" -ForegroundColor Green
            Write-Host "   Message: $($monthlyReportResult.message)" -ForegroundColor Green
            Write-Host ""
            Write-Host "   Monthly Performance Report:" -ForegroundColor Yellow
            Write-Host "   Month: $($monthlyReportResult.data.month)" -ForegroundColor White
            Write-Host "   Overall Score: $($monthlyReportResult.data.overallScore)%" -ForegroundColor White
            Write-Host "   Revenue Achievement: $($monthlyReportResult.data.revenueAchievement)%" -ForegroundColor White
            Write-Host "   AI Executive Summary: $($monthlyReportResult.data.executiveSummary)" -ForegroundColor Cyan
            Write-Host "   Key Insights: $($monthlyReportResult.data.keyInsights)" -ForegroundColor Cyan
            Write-Host "   Recommendations: $($monthlyReportResult.data.recommendations)" -ForegroundColor Cyan
            Write-Host "   Trend Analysis: $($monthlyReportResult.data.trendAnalysis)" -ForegroundColor Cyan
            Write-Host ""
        } else {
            Write-Host "   Status: FAILED" -ForegroundColor Red
            Write-Host "   Message: $($monthlyReportResult.message)" -ForegroundColor Red
            Write-Host ""
        }
    } catch {
        Write-Host "   Status: ERROR" -ForegroundColor Red
        Write-Host "   Error: $($_.Exception.Message)" -ForegroundColor Red

        if ($_.ErrorDetails) {
            Write-Host "   Details: $($_.ErrorDetails.Message)" -ForegroundColor Red
        }
        Write-Host ""
    }
} else {
    Write-Host "   Status: SKIPPED (No monthly plan available)" -ForegroundColor Yellow
    Write-Host ""
}

# Final Summary
Write-Host "=" * 100 -ForegroundColor Cyan
Write-Host "  GEMINI AI ENDPOINTS TEST SUMMARY" -ForegroundColor Green
Write-Host "=" * 100 -ForegroundColor Cyan
Write-Host ""
Write-Host "Gemini AI Features Tested:" -ForegroundColor Yellow
Write-Host ""
Write-Host "  1. Annual Target Planning" -ForegroundColor White
Write-Host "     - Generates complete 48-week plan automatically" -ForegroundColor Gray
Write-Host "     - Creates monthly and weekly breakdowns" -ForegroundColor Gray
Write-Host "     - Distributes revenue targets intelligently" -ForegroundColor Gray
Write-Host ""
Write-Host "  2. Task Analysis" -ForegroundColor White
Write-Host "     - Analyzes task complexity" -ForegroundColor Gray
Write-Host "     - Estimates effort required" -ForegroundColor Gray
Write-Host "     - Identifies risks" -ForegroundColor Gray
Write-Host "     - Provides recommendations" -ForegroundColor Gray
Write-Host "     - Suggests alternative approaches" -ForegroundColor Gray
Write-Host ""
Write-Host "  3. Batch Task Analysis" -ForegroundColor White
Write-Host "     - Analyzes multiple tasks simultaneously" -ForegroundColor Gray
Write-Host "     - Efficient bulk processing" -ForegroundColor Gray
Write-Host ""
Write-Host "  4. Weekly Performance Reports" -ForegroundColor White
Write-Host "     - Analyzes week's performance" -ForegroundColor Gray
Write-Host "     - Provides actionable insights" -ForegroundColor Gray
Write-Host "     - Suggests improvements" -ForegroundColor Gray
Write-Host ""
Write-Host "  5. Monthly Performance Reports" -ForegroundColor White
Write-Host "     - Comprehensive monthly analysis" -ForegroundColor Gray
Write-Host "     - Trend identification" -ForegroundColor Gray
Write-Host "     - Executive summaries" -ForegroundColor Gray
Write-Host "     - Strategic recommendations" -ForegroundColor Gray
Write-Host "     - Future predictions" -ForegroundColor Gray
Write-Host ""
Write-Host "Gemini API Configuration:" -ForegroundColor Yellow
Write-Host "  API Key: AIzaSyDWHGeWYyjJOoEsX3vG6y3wHAunpklMGYA" -ForegroundColor White
Write-Host "  Model: gemini-2.5-flash" -ForegroundColor White
Write-Host "  Status: Configured in appsettings.json" -ForegroundColor Green
Write-Host ""
Write-Host "=" * 100 -ForegroundColor Cyan
