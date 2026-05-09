# Simple Test - Get Exact Error
$loginBody = @{emailOrPhone="manager@rafeed.com"; password="manager123"} | ConvertTo-Json
$loginResp = Invoke-RestMethod -Uri "http://localhost:5041/api/v1/auth/login" -Method Post -Body $loginBody -ContentType "application/json"
$token = $loginResp.token

$headers = @{Authorization="Bearer $token"; "Content-Type"="application/json"}
$body = @{Year=2026; TargetDescription="Annual revenue target for 2026 - Testing Gemini AI automatic 48-week plan generation"} | ConvertTo-Json

try {
    $result = Invoke-WebRequest -Uri "http://localhost:5041/api/v1/manager/annual-targets" -Method Post -Headers $headers -Body $body
    Write-Host "SUCCESS!"
    Write-Host $result.Content | ConvertFrom-Json | ConvertTo-Json -Depth 10
} catch {
    Write-Host "Status Code: $($_.Exception.Response.StatusCode.value__)"
    Write-Host "Status Description: $($_.Exception.Response.StatusDescription)"

    $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
    $responseBody = $reader.ReadToEnd()
    Write-Host "Response Body:"
    Write-Host $responseBody
}
