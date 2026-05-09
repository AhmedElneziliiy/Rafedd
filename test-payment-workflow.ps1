# Rafedd Payment Integration Testing Script
# Tests the complete payment workflow including subscription plans and payment initiation

$baseUrl = "http://localhost:5041/api/v1"
$results = @()

function Write-TestHeader {
    param([string]$Title)
    Write-Host "`n============================================" -ForegroundColor Cyan
    Write-Host $Title -ForegroundColor Yellow
    Write-Host "============================================" -ForegroundColor Cyan
}

function Write-TestStep {
    param([string]$Step)
    Write-Host "`n>> $Step" -ForegroundColor Magenta
}

function Write-Success {
    param([string]$Message)
    Write-Host "[✓] $Message" -ForegroundColor Green
}

function Write-Failure {
    param([string]$Message)
    Write-Host "[✗] $Message" -ForegroundColor Red
}

function Write-Info {
    param([string]$Message)
    Write-Host "[i] $Message" -ForegroundColor Cyan
}

function Test-Endpoint {
    param(
        [string]$Name,
        [string]$Method,
        [string]$Url,
        [string]$Token = "",
        [string]$Body = "",
        [int]$ExpectedStatus = 200
    )

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

        $response = Invoke-RestMethod @params -ErrorAction Stop -StatusCodeVariable statusCode

        if ($statusCode -eq $ExpectedStatus) {
            Write-Success "$Name - Status: $statusCode"
            $script:results += [PSCustomObject]@{
                Test = $Name
                Status = "PASS"
                StatusCode = $statusCode
                Response = ($response | ConvertTo-Json -Compress)
            }
            return $response
        } else {
            Write-Failure "$Name - Unexpected status: $statusCode (expected: $ExpectedStatus)"
            $script:results += [PSCustomObject]@{
                Test = $Name
                Status = "FAIL"
                StatusCode = $statusCode
                Response = "Unexpected status code"
            }
        }
    }
    catch {
        $statusCode = $_.Exception.Response.StatusCode.value__
        Write-Failure "$Name - Error: $($_.Exception.Message) (Status: $statusCode)"
        $script:results += [PSCustomObject]@{
            Test = $Name
            Status = "ERROR"
            StatusCode = $statusCode
            Response = $_.Exception.Message
        }
    }
}

Write-TestHeader "RAFEDD PAYMENT INTEGRATION TEST"

# ==========================================================================
# STEP 1: Test Subscription Plans Retrieval (No Auth Required)
# ==========================================================================
Write-TestStep "Step 1: Testing Subscription Plans Endpoint"
Write-Info "Testing GET /api/v1/subscriptions/plans (Public Endpoint)"

$plansResponse = Test-Endpoint `
    -Name "Get Subscription Plans" `
    -Method "GET" `
    -Url "$baseUrl/subscriptions/plans"

if ($plansResponse -and $plansResponse.data) {
    Write-Success "Retrieved $($plansResponse.data.Count) subscription plans"

    foreach ($plan in $plansResponse.data) {
        Write-Info "  Plan ID: $($plan.id) | Name: $($plan.name) | Price: $($plan.pricePerMonth) SAR | Max Employees: $($plan.maxEmployees)"
    }

    # Store first available plan for testing
    $testPlanId = $plansResponse.data[0].id
    $testPlanPrice = $plansResponse.data[0].pricePerMonth
    Write-Info "Using Plan ID $testPlanId ($($plansResponse.data[0].name)) for payment tests"
} else {
    Write-Failure "Failed to retrieve subscription plans"
    exit 1
}

# ==========================================================================
# STEP 2: Manager Authentication
# ==========================================================================
Write-TestStep "Step 2: Manager Authentication"
Write-Info "Testing POST /api/v1/auth/login"

$loginResponse = Test-Endpoint `
    -Name "Manager Login" `
    -Method "POST" `
    -Url "$baseUrl/auth/login" `
    -Body '{"emailOrPhone":"manager@rafeed.com","password":"manager123"}'

if ($loginResponse -and $loginResponse.token) {
    $managerToken = $loginResponse.token
    Write-Success "Manager authenticated successfully"
    Write-Info "Token: $($managerToken.Substring(0, 20))..."

    # Display subscription status from login response
    if ($loginResponse.subscriptionStatus) {
        Write-Info "Subscription Status:"
        Write-Info "  Is Active: $($loginResponse.subscriptionStatus.isActive)"
        Write-Info "  Has Active Subscription: $($loginResponse.subscriptionStatus.hasActiveSubscription)"
        if ($loginResponse.subscriptionStatus.currentPlan) {
            Write-Info "  Current Plan: $($loginResponse.subscriptionStatus.currentPlan.name)"
            Write-Info "  Subscription Ends: $($loginResponse.subscriptionStatus.subscriptionEndsAt)"
        }
    }
} else {
    Write-Failure "Manager authentication failed"
    exit 1
}

# ==========================================================================
# STEP 3: Get Current Subscription
# ==========================================================================
Write-TestStep "Step 3: Testing Current Subscription Retrieval"
Write-Info "Testing GET /api/v1/subscriptions/current"

$currentSubResponse = Test-Endpoint `
    -Name "Get Current Subscription" `
    -Method "GET" `
    -Url "$baseUrl/subscriptions/current" `
    -Token $managerToken

if ($currentSubResponse -and $currentSubResponse.data) {
    Write-Success "Current subscription retrieved"
    $currentSubscriptionId = $currentSubResponse.data.id
    Write-Info "  Subscription ID: $currentSubscriptionId"
    Write-Info "  Plan: $($currentSubResponse.data.planName)"
    Write-Info "  Status: $(if ($currentSubResponse.data.isActive) { 'Active' } else { 'Inactive' })"
    Write-Info "  Start Date: $($currentSubResponse.data.startDate)"
    Write-Info "  End Date: $($currentSubResponse.data.endDate)"
} else {
    Write-Info "No active subscription found (expected for new managers)"
    $currentSubscriptionId = $null
}

# ==========================================================================
# STEP 4: Create Subscription (if not exists)
# ==========================================================================
Write-TestStep "Step 4: Testing Subscription Creation"

if (-not $currentSubscriptionId) {
    Write-Info "Testing POST /api/v1/subscriptions"

    $createSubBody = @{
        planId = $testPlanId
        autoRenew = $true
    } | ConvertTo-Json

    $createSubResponse = Test-Endpoint `
        -Name "Create Subscription" `
        -Method "POST" `
        -Url "$baseUrl/subscriptions" `
        -Token $managerToken `
        -Body $createSubBody

    if ($createSubResponse -and $createSubResponse.data) {
        $currentSubscriptionId = $createSubResponse.data.id
        Write-Success "Subscription created successfully"
        Write-Info "  New Subscription ID: $currentSubscriptionId"
    } else {
        Write-Failure "Failed to create subscription"
        exit 1
    }
} else {
    Write-Info "Subscription already exists (ID: $currentSubscriptionId), skipping creation"
}

# ==========================================================================
# STEP 5: Test Payment Initiation - MyFatoorah
# ==========================================================================
Write-TestStep "Step 5: Testing MyFatoorah Payment Initiation"
Write-Info "Testing POST /api/v1/payment/myfatoorah/initiate"

$myFatoorahBody = @{
    subscriptionId = $currentSubscriptionId
    amount = $testPlanPrice
    currency = "SAR"
    paymentMethod = "myfatoorah"
    description = "Subscription payment - Test"
} | ConvertTo-Json

$myFatoorahResponse = Test-Endpoint `
    -Name "MyFatoorah Payment Initiation" `
    -Method "POST" `
    -Url "$baseUrl/payment/myfatoorah/initiate" `
    -Token $managerToken `
    -Body $myFatoorahBody

if ($myFatoorahResponse -and $myFatoorahResponse.data) {
    Write-Success "MyFatoorah payment initiated"
    Write-Info "  Payment URL: $($myFatoorahResponse.data.paymentUrl)"
    Write-Info "  Invoice ID: $($myFatoorahResponse.data.invoiceId)"
    Write-Info "  Invoice Ref: $($myFatoorahResponse.data.invoiceRef)"

    $myFatoorahInvoiceId = $myFatoorahResponse.data.invoiceId
} else {
    Write-Failure "MyFatoorah payment initiation failed"
}

# ==========================================================================
# STEP 6: Test Payment Initiation - Stripe
# ==========================================================================
Write-TestStep "Step 6: Testing Stripe Payment Initiation"
Write-Info "Testing POST /api/v1/payment/stripe/create-intent"

$stripeBody = @{
    subscriptionId = $currentSubscriptionId
    amount = $testPlanPrice
    currency = "SAR"
    paymentMethod = "stripe"
    description = "Subscription payment - Test"
} | ConvertTo-Json

$stripeResponse = Test-Endpoint `
    -Name "Stripe Payment Intent Creation" `
    -Method "POST" `
    -Url "$baseUrl/payment/stripe/create-intent" `
    -Token $managerToken `
    -Body $stripeBody

if ($stripeResponse -and $stripeResponse.data) {
    Write-Success "Stripe payment intent created"
    Write-Info "  Client Secret: $($stripeResponse.data.clientSecret.Substring(0, 20))..."
    Write-Info "  Payment Intent ID: $($stripeResponse.data.paymentIntentId)"

    $stripePaymentIntentId = $stripeResponse.data.paymentIntentId
} else {
    Write-Failure "Stripe payment intent creation failed"
}

# ==========================================================================
# STEP 7: Test Payment Initiation - PayTabs
# ==========================================================================
Write-TestStep "Step 7: Testing PayTabs Payment Initiation"
Write-Info "Testing POST /api/v1/payment/paytabs/initiate"

$payTabsBody = @{
    subscriptionId = $currentSubscriptionId
    amount = $testPlanPrice
    currency = "SAR"
    paymentMethod = "paytabs"
    description = "Subscription payment - Test"
} | ConvertTo-Json

$payTabsResponse = Test-Endpoint `
    -Name "PayTabs Payment Initiation" `
    -Method "POST" `
    -Url "$baseUrl/payment/paytabs/initiate" `
    -Token $managerToken `
    -Body $payTabsBody

if ($payTabsResponse -and $payTabsResponse.data) {
    Write-Success "PayTabs payment initiated"
    Write-Info "  Payment URL: $($payTabsResponse.data.paymentUrl)"
    Write-Info "  Transaction Ref: $($payTabsResponse.data.transactionRef)"

    $payTabsTransactionRef = $payTabsResponse.data.transactionRef
} else {
    Write-Failure "PayTabs payment initiation failed"
}

# ==========================================================================
# STEP 8: Get Payment History
# ==========================================================================
Write-TestStep "Step 8: Testing Payment History Retrieval"
Write-Info "Testing GET /api/v1/payment/manager/payments"

$paymentHistoryResponse = Test-Endpoint `
    -Name "Get Manager Payments" `
    -Method "GET" `
    -Url "$baseUrl/payment/manager/payments" `
    -Token $managerToken

if ($paymentHistoryResponse -and $paymentHistoryResponse.data) {
    Write-Success "Retrieved payment history"
    Write-Info "  Total Payments: $($paymentHistoryResponse.data.Count)"

    foreach ($payment in $paymentHistoryResponse.data) {
        Write-Info "  Payment ID: $($payment.id) | Amount: $($payment.amount) $($payment.currency) | Status: $($payment.status) | Method: $($payment.paymentMethod)"
    }
} else {
    Write-Info "No payment history found"
}

# ==========================================================================
# STEP 9: Verify Payment Status (if payment was created)
# ==========================================================================
if ($myFatoorahInvoiceId) {
    Write-TestStep "Step 9: Testing Payment Verification"
    Write-Info "Testing POST /api/v1/payment/verify/{transactionId}"

    $verifyResponse = Test-Endpoint `
        -Name "Verify Payment Status" `
        -Method "POST" `
        -Url "$baseUrl/payment/verify/$myFatoorahInvoiceId" `
        -Token $managerToken

    if ($verifyResponse) {
        Write-Success "Payment verification completed"
        Write-Info "  Verified: $($verifyResponse.data.verified)"
    } else {
        Write-Info "Payment verification returned negative (expected for test payments)"
    }
}

# ==========================================================================
# TEST SUMMARY
# ==========================================================================
Write-TestHeader "TEST SUMMARY"

$passCount = ($results | Where-Object { $_.Status -eq "PASS" }).Count
$failCount = ($results | Where-Object { $_.Status -eq "FAIL" }).Count
$errorCount = ($results | Where-Object { $_.Status -eq "ERROR" }).Count
$total = $results.Count

Write-Host "`nTotal Tests: $total" -ForegroundColor White
Write-Host "Passed: $passCount" -ForegroundColor Green
Write-Host "Failed: $failCount" -ForegroundColor Red
Write-Host "Errors: $errorCount" -ForegroundColor Yellow
Write-Host "`nPass Rate: $([Math]::Round(($passCount/$total)*100, 2))%" -ForegroundColor Cyan

# Export detailed results
$results | Export-Csv -Path "d:\Rafedd-master\payment-test-results.csv" -NoTypeInformation
Write-Info "`nDetailed results exported to: d:\Rafedd-master\payment-test-results.csv"

# Display failed/error tests
if ($failCount -gt 0 -or $errorCount -gt 0) {
    Write-Host "`n--- FAILED/ERROR TESTS ---`n" -ForegroundColor Red
    $results | Where-Object { $_.Status -ne "PASS" } | Format-Table -AutoSize
}

# ==========================================================================
# PAYMENT WORKFLOW DOCUMENTATION
# ==========================================================================
Write-TestHeader "PAYMENT WORKFLOW SUMMARY"

Write-Host "`nCOMPLETE PAYMENT WORKFLOW:" -ForegroundColor White
Write-Host "==========================" -ForegroundColor White
Write-Host ""
Write-Host "1. SUBSCRIPTION PLANS" -ForegroundColor Yellow
Write-Host "   - Endpoint: GET /api/v1/subscriptions/plans"
Write-Host "   - Auth: None (Public)"
Write-Host "   - Returns: List of available subscription plans with pricing"
Write-Host ""
Write-Host "2. MANAGER REGISTRATION/LOGIN" -ForegroundColor Yellow
Write-Host "   - Endpoint: POST /api/v1/auth/login"
Write-Host "   - Returns: JWT token + subscription status"
Write-Host ""
Write-Host "3. CREATE SUBSCRIPTION" -ForegroundColor Yellow
Write-Host "   - Endpoint: POST /api/v1/subscriptions"
Write-Host "   - Auth: Manager Token"
Write-Host "   - Body: planId and autoRenew parameters"
Write-Host ""
Write-Host "4. INITIATE PAYMENT (Choose One Gateway)" -ForegroundColor Yellow
Write-Host "   A. MyFatoorah: POST /api/v1/payment/myfatoorah/initiate"
Write-Host "   B. Stripe: POST /api/v1/payment/stripe/create-intent"
Write-Host "   C. PayTabs: POST /api/v1/payment/paytabs/initiate"
Write-Host ""
Write-Host "5. PAYMENT CALLBACK (Automatic)" -ForegroundColor Yellow
Write-Host "   - System verifies payment and activates subscription"
Write-Host ""
Write-Host "6. SUBSCRIPTION ACTIVATION (Automatic)" -ForegroundColor Yellow
Write-Host "   - Payment status set to Completed"
Write-Host "   - Subscription activated and extended by 1 month"
Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
