# Test SmarterASP.NET Database Connection

$connectionString = "Data Source=SQL6033.site4now.net;Initial Catalog=db_ac210d_rafeddsystemdb;User Id=db_ac210d_rafeddsystemdb_admin;Password=Pass@123;TrustServerCertificate=True"

Write-Host "Testing connection to SmarterASP.NET database..." -ForegroundColor Yellow

try {
    # Load SQL Client
    Add-Type -AssemblyName System.Data

    # Create connection
    $connection = New-Object System.Data.SqlClient.SqlConnection($connectionString)

    # Try to open
    $connection.Open()

    Write-Host "SUCCESS! Connected to SmarterASP.NET database" -ForegroundColor Green

    # Test query
    $command = $connection.CreateCommand()
    $command.CommandText = "SELECT @@VERSION"
    $reader = $command.ExecuteReader()

    if ($reader.Read()) {
        Write-Host "`nSQL Server Version:" -ForegroundColor Cyan
        Write-Host $reader.GetString(0) -ForegroundColor White
    }

    $reader.Close()
    $connection.Close()

    Write-Host "`nConnection string is correct!" -ForegroundColor Green
    Write-Host "You can now run Update-Database in Package Manager Console" -ForegroundColor Cyan

} catch {
    Write-Host "FAILED to connect" -ForegroundColor Red
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "`nPossible issues:" -ForegroundColor Yellow
    Write-Host "1. Firewall blocking connection" -ForegroundColor White
    Write-Host "2. Wrong username/password" -ForegroundColor White
    Write-Host "3. Database server not accessible" -ForegroundColor White
    Write-Host "4. IP not whitelisted in SmarterASP control panel" -ForegroundColor White
}
