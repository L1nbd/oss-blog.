# ============================================
# Ghost Blog System - Start Script
# Usage: .\start.ps1
# ============================================

$ErrorActionPreference = "Stop"

# Configuration
$ProjectRoot = "C:\Users\34344\oss-blog"
$RuntimeDir = Join-Path $ProjectRoot "runtime"
$GhostScript = Join-Path $RuntimeDir "current\index.js"
$Port = 2368

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Ghost Blog System - Start Script" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Check if port is in use
Write-Host "[1/4] Checking port $Port ..." -ForegroundColor Yellow
$portInUse = Get-NetTCPConnection -LocalPort $Port -ErrorAction SilentlyContinue
if ($portInUse) {
    Write-Host "  Port $Port is in use (PID: $($portInUse.OwningProcess))" -ForegroundColor Red
    $choice = Read-Host "  Kill this process and continue? (y/N)"
    if ($choice -eq 'y' -or $choice -eq 'Y') {
        Stop-Process -Id $portInUse.OwningProcess -Force
        Start-Sleep -Seconds 2
        Write-Host "  Process killed" -ForegroundColor Green
    } else {
        Write-Host "  Start cancelled" -ForegroundColor Red
        exit 1
    }
} else {
    Write-Host "  Port $Port is free" -ForegroundColor Green
}

# Check if Ghost script exists
Write-Host "[2/4] Checking Ghost installation ..." -ForegroundColor Yellow
if (-not (Test-Path $GhostScript)) {
    Write-Host "  Error: Ghost script not found: $GhostScript" -ForegroundColor Red
    Write-Host "  Please install Ghost first" -ForegroundColor Red
    exit 1
}
Write-Host "  Ghost script found" -ForegroundColor Green

# Check if database exists
Write-Host "[3/4] Checking database ..." -ForegroundColor Yellow
$dbPath = Join-Path $RuntimeDir "content\data\ghost.db"
if (Test-Path $dbPath) {
    Write-Host "  Database exists" -ForegroundColor Green
} else {
    Write-Host "  Warning: Database not found, will auto-initialize on first start" -ForegroundColor Yellow
}

# Start Ghost
Write-Host "[4/4] Starting Ghost ..." -ForegroundColor Yellow
Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Ghost is starting..." -ForegroundColor Green
Write-Host "  Frontend: http://localhost:$Port/" -ForegroundColor Green
Write-Host "  Admin:    http://localhost:$Port/ghost/" -ForegroundColor Green
Write-Host "  Press Ctrl+C to stop" -ForegroundColor Yellow
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Set environment and start
$env:NODE_ENV = "development"
Set-Location $RuntimeDir
node $GhostScript
