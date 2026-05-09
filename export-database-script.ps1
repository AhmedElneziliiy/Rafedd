# Export Database Schema and Data for SmarterASP.NET Deployment
# This creates a SQL script compatible with older SQL Server versions

$ServerInstance = ".\SQLEXPRESS"
$Database = "RafeddSystemDB"
$OutputFile = "d:\Rafedd-master\RafeddSystemDB_Deployment.sql"

Write-Host "Exporting database schema and data..." -ForegroundColor Yellow

# Check if SQL Server PowerShell module is available
if (-not (Get-Module -ListAvailable -Name SqlServer)) {
    Write-Host "Installing SqlServer PowerShell module..." -ForegroundColor Yellow
    Install-Module -Name SqlServer -Scope CurrentUser -Force -AllowClobber
}

Import-Module SqlServer

try {
    # Load SQL Server Management Objects
    [System.Reflection.Assembly]::LoadWithPartialName('Microsoft.SqlServer.SMO') | Out-Null

    $Server = New-Object Microsoft.SqlServer.Management.Smo.Server($ServerInstance)
    $db = $Server.Databases[$Database]

    if ($null -eq $db) {
        Write-Host "Database not found: $Database" -ForegroundColor Red
        exit 1
    }

    Write-Host "Found database: $Database" -ForegroundColor Green

    # Set up scripting options for compatibility
    $scripter = New-Object Microsoft.SqlServer.Management.Smo.Scripter($Server)
    $scripter.Options.ScriptDrops = $false
    $scripter.Options.IncludeIfNotExists = $true
    $scripter.Options.ScriptSchema = $true
    $scripter.Options.ScriptData = $true
    $scripter.Options.ToFileOnly = $true
    $scripter.Options.FileName = $OutputFile
    $scripter.Options.Encoding = [System.Text.Encoding]::UTF8
    $scripter.Options.TargetServerVersion = [Microsoft.SqlServer.Management.Smo.SqlServerVersion]::Version150  # SQL Server 2019
    $scripter.Options.DriAll = $true  # Include all constraints
    $scripter.Options.Indexes = $true
    $scripter.Options.Triggers = $true

    Write-Host "Scripting database objects..." -ForegroundColor Yellow

    # Script tables
    $tables = $db.Tables | Where-Object { -not $_.IsSystemObject }
    $scripter.Script($tables)

    Write-Host "Database exported successfully to: $OutputFile" -ForegroundColor Green
    Write-Host "You can now upload this SQL file to SmarterASP.NET" -ForegroundColor Cyan

} catch {
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "`nAlternative: Use SQL Server Management Studio (SSMS)" -ForegroundColor Yellow
    Write-Host "1. Right-click database > Tasks > Generate Scripts" -ForegroundColor White
    Write-Host "2. Choose 'Script entire database'" -ForegroundColor White
    Write-Host "3. Advanced > Target Server Version: SQL Server 2019" -ForegroundColor White
    Write-Host "4. Advanced > Types of data to script: Schema and data" -ForegroundColor White
    Write-Host "5. Save to file" -ForegroundColor White
}
