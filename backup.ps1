# ============================================
# Ghost Database Backup Script
# Usage: .\backup.ps1
# ============================================

$ErrorActionPreference = "Stop"

# Configuration
$ProjectRoot = "C:\Users\34344\oss-blog"
$RuntimeDir = Join-Path $ProjectRoot "runtime"
$DbPath = Join-Path $RuntimeDir "content\data\ghost.db"
$BackupDir = Join-Path $ProjectRoot "backups"
$Port = 2368

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Ghost Database Backup Script" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Check if database exists
Write-Host "[1/4] Checking database ..." -ForegroundColor Yellow
if (-not (Test-Path $DbPath)) {
    Write-Host "  Error: Database file not found: $DbPath" -ForegroundColor Red
    exit 1
}
$dbSize = (Get-Item $DbPath).Length / 1KB
Write-Host "  Database found, size: $([math]::Round($dbSize, 2)) KB" -ForegroundColor Green

# Check if Ghost is running
Write-Host "[2/4] Checking Ghost status ..." -ForegroundColor Yellow
$ghostRunning = Get-NetTCPConnection -LocalPort $Port -ErrorAction SilentlyContinue
if ($ghostRunning) {
    Write-Host "  Warning: Ghost is running, database may be locked" -ForegroundColor Yellow
    $choice = Read-Host "  Continue backup? (Recommended to stop Ghost first) (y/N)"
    if ($choice -ne 'y' -and $choice -ne 'Y') {
        Write-Host "  Backup cancelled" -ForegroundColor Red
        exit 0
    }
} else {
    Write-Host "  Ghost is not running, safe to backup" -ForegroundColor Green
}

# Create backup directory
Write-Host "[3/4] Creating backup directory ..." -ForegroundColor Yellow
if (-not (Test-Path $BackupDir)) {
    New-Item -ItemType Directory -Path $BackupDir -Force | Out-Null
    Write-Host "  Backup directory created: $BackupDir" -ForegroundColor Green
} else {
    Write-Host "  Backup directory exists" -ForegroundColor Green
}

# Execute backup
Write-Host "[4/4] Executing backup ..." -ForegroundColor Yellow
$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
$backupFile = Join-Path $BackupDir "ghost-$timestamp.db"

try {
    Copy-Item -Path $DbPath -Destination $backupFile -Force
    $backupSize = (Get-Item $backupFile).Length / 1KB
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "  Backup successful!" -ForegroundColor Green
    Write-Host "  Backup file: $backupFile" -ForegroundColor Green
    Write-Host "  Backup size: $([math]::Round($backupSize, 2)) KB" -ForegroundColor Green
    Write-Host "  Backup time: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Cyan
} catch {
    Write-Host "  Backup failed: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# List all backups
Write-Host ""
Write-Host "Existing backups:" -ForegroundColor Yellow
Get-ChildItem $BackupDir -Filter "*.db" | Sort-Object LastWriteTime -Descending | Select-Object -First 5 | ForEach-Object {
    Write-Host "  $($_.Name) - $([math]::Round($_.Length/1KB, 2)) KB - $($_.LastWriteTime)" -ForegroundColor White
}
