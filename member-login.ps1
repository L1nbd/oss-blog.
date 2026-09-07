# ============================================
# One-Click Member Login
# Usage: .\member-login.ps1 [email]
# Example: .\member-login.ps1 zhangsan@example.com
# ============================================

param(
    [string]$Email = "zhangsan@example.com"
)

$ErrorActionPreference = "Stop"

$ProjectRoot = "C:\Users\34344\oss-blog"
$LinkFile = Join-Path $ProjectRoot "runtime\mailbox\latest-login-link.txt"
$GhostUrl = "http://localhost:2368"
$SmtpPort = 2525

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  One-Click Member Login" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Email: $Email" -ForegroundColor Yellow
Write-Host ""

# Step 1: Check if Ghost is running
Write-Host "[1/5] Checking Ghost status..." -ForegroundColor Yellow
$ghostRunning = Get-NetTCPConnection -LocalPort 2368 -State Listen -ErrorAction SilentlyContinue
if (-not $ghostRunning) {
    Write-Host "Error: Ghost is not running!" -ForegroundColor Red
    Write-Host "Please run .\start.ps1 first" -ForegroundColor Yellow
    exit 1
}
Write-Host "  Ghost is running" -ForegroundColor Green

# Step 2: Check if Fake SMTP is running
Write-Host "[2/5] Checking Fake SMTP status..." -ForegroundColor Yellow
$smtpRunning = Get-NetTCPConnection -LocalPort $SmtpPort -State Listen -ErrorAction SilentlyContinue
if (-not $smtpRunning) {
    Write-Host "  Fake SMTP not running, starting it..." -ForegroundColor Yellow
    & "$ProjectRoot\start-smtp.ps1"
    Start-Sleep -Seconds 3
    $smtpRunning = Get-NetTCPConnection -LocalPort $SmtpPort -State Listen -ErrorAction SilentlyContinue
    if (-not $smtpRunning) {
        Write-Host "Error: Failed to start Fake SMTP" -ForegroundColor Red
        exit 1
    }
}
Write-Host "  Fake SMTP is running" -ForegroundColor Green

# Step 3: Remove old link file
Write-Host "[3/5] Sending magic link email..." -ForegroundColor Yellow
if (Test-Path $LinkFile) {
    Remove-Item $LinkFile -Force
}

# Send magic link via Ghost API (using curl with temp JSON file)
$jsonBody = @{email = $Email} | ConvertTo-Json -Compress
$jsonFile = [System.IO.Path]::GetTempFileName()
$respFile = [System.IO.Path]::GetTempFileName()
$codeFile = [System.IO.Path]::GetTempFileName()
try {
    [System.IO.File]::WriteAllText($jsonFile, $jsonBody, [System.Text.Encoding]::UTF8)
    & curl.exe -s -o $respFile -w "`%{http_code}" -X POST "$GhostUrl/members/api/send-magic-link/" -H "Content-Type: application/json" --data-binary "@$jsonFile" | Out-File -FilePath $codeFile -Encoding ascii
    $statusCode = (Get-Content $codeFile -Raw).Trim()
    if ($statusCode -eq "201" -or $statusCode -eq "200") {
        Write-Host "  Magic link request sent successfully (HTTP $statusCode)" -ForegroundColor Green
    } else {
        $response = Get-Content $respFile -Raw -ErrorAction SilentlyContinue
        Write-Host "Error: Failed to send magic link (HTTP $statusCode)" -ForegroundColor Red
        if ($response) { Write-Host $response -ForegroundColor Red }
        exit 1
    }
} catch {
    Write-Host "Error: Failed to send magic link" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    exit 1
} finally {
    Remove-Item $jsonFile -Force -ErrorAction SilentlyContinue
    Remove-Item $respFile -Force -ErrorAction SilentlyContinue
    Remove-Item $codeFile -Force -ErrorAction SilentlyContinue
}

# Step 4: Wait for email and extract link
Write-Host "[4/5] Waiting for email (max 15 seconds)..." -ForegroundColor Yellow
$link = $null
for ($i = 0; $i -lt 15; $i++) {
    Start-Sleep -Seconds 1
    if (Test-Path $LinkFile) {
        $link = Get-Content $LinkFile -Raw
        $link = $link.Trim()
        if (-not [string]::IsNullOrWhiteSpace($link)) {
            Write-Host "  Login link received!" -ForegroundColor Green
            break
        }
    }
    Write-Host "  Waiting... ($($i+1)/15)" -ForegroundColor Gray
}

if ([string]::IsNullOrWhiteSpace($link)) {
    Write-Host "Error: Timeout waiting for login link" -ForegroundColor Red
    Write-Host "Please check the Fake SMTP window for errors" -ForegroundColor Yellow
    exit 1
}

# Step 5: Open browser
Write-Host "[5/5] Opening login link in browser..." -ForegroundColor Yellow
Write-Host ""
Write-Host "Login link:" -ForegroundColor Cyan
Write-Host $link -ForegroundColor Cyan
Write-Host ""

# Copy to clipboard
try {
    Set-Clipboard -Value $link
    Write-Host "Link copied to clipboard!" -ForegroundColor Green
} catch {
    Write-Host "Warning: Could not copy to clipboard" -ForegroundColor Yellow
}

# Open in default browser
try {
    Start-Process $link
    Write-Host "Browser opened successfully!" -ForegroundColor Green
} catch {
    Write-Host "Error: Could not open browser" -ForegroundColor Red
    Write-Host "Please manually copy and open the link above" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Login successful!" -ForegroundColor Green
Write-Host "  You are now logged in as: $Email" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
