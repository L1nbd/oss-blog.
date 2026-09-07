# ============================================
# Open Latest Member Login Link
# Usage: .\open-login.ps1
# ============================================

$ErrorActionPreference = "Stop"

# Configuration
$ProjectRoot = "C:\Users\34344\oss-blog"
$MailboxDir = Join-Path $ProjectRoot "runtime\mailbox"
$LinkFile = Join-Path $MailboxDir "latest-login-link.txt"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Open Latest Member Login Link" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Check if login link file exists
if (-not (Test-Path $LinkFile)) {
    Write-Host "Error: No login link found!" -ForegroundColor Red
    Write-Host ""
    Write-Host "Please follow these steps first:" -ForegroundColor Yellow
    Write-Host "  1. Make sure Ghost is running (.\start.ps1)"
    Write-Host "  2. Make sure fake SMTP server is running"
    Write-Host "  3. Go to http://localhost:2368/ and click Sign in"
    Write-Host "  4. Enter member email (e.g. zhangsan@example.com)"
    Write-Host "  5. Click Retry to send magic link email"
    Write-Host "  6. Run this script again to open the login link"
    Write-Host ""
    exit 1
}

# Read the login link
$loginLink = Get-Content $LinkFile -Raw
$loginLink = $loginLink.Trim()

if ([string]::IsNullOrWhiteSpace($loginLink)) {
    Write-Host "Error: Login link file is empty!" -ForegroundColor Red
    exit 1
}

Write-Host "Found login link:" -ForegroundColor Green
Write-Host $loginLink -ForegroundColor Cyan
Write-Host ""

# Copy to clipboard
try {
    Set-Clipboard -Value $loginLink
    Write-Host "Link copied to clipboard!" -ForegroundColor Green
} catch {
    Write-Host "Warning: Could not copy to clipboard" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "Opening in default browser..." -ForegroundColor Yellow

# Open in default browser
try {
    Start-Process $loginLink
    Write-Host "Browser opened successfully!" -ForegroundColor Green
} catch {
    Write-Host "Error: Could not open browser" -ForegroundColor Red
    Write-Host "Please manually copy and open the link above" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Done!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
