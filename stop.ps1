# ============================================
# Ghost Blog System - Stop Script
# Usage: .\stop.ps1
# ============================================

$ErrorActionPreference = "Stop"

# Configuration
$Port = 2368

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Ghost Blog System - Stop Script" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Find processes using the port
Write-Host "[1/3] Finding processes using port $Port ..." -ForegroundColor Yellow
$connections = Get-NetTCPConnection -LocalPort $Port -ErrorAction SilentlyContinue

if (-not $connections) {
    Write-Host "  Port $Port is not in use, Ghost may not be running" -ForegroundColor Yellow
    exit 0
}

$pids = $connections | Select-Object -ExpandProperty OwningProcess -Unique
Write-Host "  Found $($pids.Count) process(es) using port $Port" -ForegroundColor Green

# Show process info
Write-Host "[2/3] Process info:" -ForegroundColor Yellow
foreach ($procId in $pids) {
    $process = Get-Process -Id $procId -ErrorAction SilentlyContinue
    if ($process) {
        Write-Host "  PID: $procId, Name: $($process.ProcessName), StartTime: $($process.StartTime)" -ForegroundColor White
    }
}

# Kill processes
Write-Host "[3/3] Killing processes ..." -ForegroundColor Yellow
foreach ($procId in $pids) {
    try {
        Stop-Process -Id $procId -Force -ErrorAction Stop
        Write-Host "  Process $procId killed" -ForegroundColor Green
    } catch {
        Write-Host "  Failed to kill process ${procId}: $($_.Exception.Message)" -ForegroundColor Red
    }
}

Start-Sleep -Seconds 2

# Verify port is released
$stillInUse = Get-NetTCPConnection -LocalPort $Port -ErrorAction SilentlyContinue
if ($stillInUse) {
    Write-Host ""
    Write-Host "  Warning: Port $Port is still in use" -ForegroundColor Red
} else {
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "  Ghost stopped successfully" -ForegroundColor Green
    Write-Host "  Port $Port released" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Cyan
}
