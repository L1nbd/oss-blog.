# ============================================
# Start Fake SMTP Server
# Usage: .\start-smtp.ps1
# ============================================

$ErrorActionPreference = "Stop"

$ProjectRoot = "C:\Users\34344\oss-blog"
$SmtpScript = Join-Path $ProjectRoot "scripts\fake-smtp-server.js"
$Port = 2525

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Fake SMTP Server - Start Script" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Check if port is already in use
$existing = Get-NetTCPConnection -LocalPort $Port -State Listen -ErrorAction SilentlyContinue
if ($existing) {
    Write-Host "Fake SMTP Server is already running (PID: $($existing.OwningProcess))" -ForegroundColor Green
    Write-Host "Port: $Port" -ForegroundColor Green
    Write-Host ""
    exit 0
}

# Check if script exists
if (-not (Test-Path $SmtpScript)) {
    Write-Host "Error: Fake SMTP server script not found: $SmtpScript" -ForegroundColor Red
    exit 1
}

Write-Host "Starting Fake SMTP Server..." -ForegroundColor Yellow
Write-Host "Port: $Port" -ForegroundColor Yellow
Write-Host "Mailbox: $ProjectRoot\runtime\mailbox" -ForegroundColor Yellow
Write-Host ""

# Start in new window
Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd '$ProjectRoot\scripts'; node fake-smtp-server.js" -WindowStyle Normal

Start-Sleep -Seconds 2

# Verify it started
$check = Get-NetTCPConnection -LocalPort $Port -State Listen -ErrorAction SilentlyContinue
if ($check) {
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "  Fake SMTP Server started successfully!" -ForegroundColor Green
    Write-Host "  PID: $($check.OwningProcess)" -ForegroundColor Green
    Write-Host "  Port: $Port" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Cyan
} else {
    Write-Host "Warning: Server may not have started correctly" -ForegroundColor Yellow
    Write-Host "Please check the new window for error messages" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "Keep this window open to receive emails." -ForegroundColor Yellow
Write-Host "Login links will be saved to: runtime\mailbox\latest-login-link.txt" -ForegroundColor Yellow
