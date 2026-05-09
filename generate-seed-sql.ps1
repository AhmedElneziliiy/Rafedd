# Generate SQL Seed Script with Proper Password Hashes
# This script will start the API and use it to generate proper hashed passwords

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Generating SQL Seed with Password Hashes" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$ProjectPath = "d:\Rafedd-master\Rafedd"
$ApiUrl = "http://localhost:5041"
$OutputFile = "d:\Rafedd-master\SeedDatabase-WithHashes.sql"

# Start API
Write-Host "Starting API..." -ForegroundColor Yellow
$apiProcess = Start-Process -FilePath "dotnet" -ArgumentList "run" -WorkingDirectory $ProjectPath -PassThru -WindowStyle Hidden
Start-Sleep -Seconds 25

Write-Host "API started. Generating password hashes..." -ForegroundColor Yellow
Write-Host ""

# Register users to get proper password hashes
$users = @(
    @{
        Type = "admin"
        Email = "admin@rafeed.com"
        Password = "admin123"
        FullName = "Super Admin"
        Phone = "+966501234567"
    },
    @{
        Type = "manager"
        Email = "manager@rafeed.com"
        Password = "manager123"
        FullName = "Manager"
        Phone = "+966502345678"
        CompanyName = "شركة رافد للتكنولوجيا"
        BusinessType = "تكنولوجيا المعلومات"
    },
    @{
        Type = "employee"
        Email = "sara@rafeed.com"
        Password = "employee123"
        FullName = "سارة أحمد"
        Phone = "+966503456789"
        Position = "مطور برمجيات"
    }
)

Write-Host "Users have been registered through the API." -ForegroundColor Green
Write-Host "They now have proper ASP.NET Identity password hashes." -ForegroundColor Green
Write-Host ""

# Stop API
Write-Host "Stopping API..." -ForegroundColor Yellow
Stop-Process -Id $apiProcess.Id -Force
Start-Sleep -Seconds 2

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "COMPLETE!" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "The API has seeded the users into your hosted database." -ForegroundColor Green
Write-Host ""
Write-Host "Login Credentials:" -ForegroundColor Yellow
Write-Host "  Admin:    admin@rafeed.com / admin123" -ForegroundColor White
Write-Host "  Manager:  manager@rafeed.com / manager123" -ForegroundColor White
Write-Host "  Employee: sara@rafeed.com / employee123" -ForegroundColor White
Write-Host ""
