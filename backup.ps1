# ============================================
# Ghost 数据库备份脚本
# 用法：.\backup.ps1
# ============================================

$ErrorActionPreference = "Stop"

# 配置
$ProjectRoot = "C:\Users\34344\oss-blog"
$RuntimeDir = Join-Path $ProjectRoot "runtime"
$DbPath = Join-Path $RuntimeDir "content\data\ghost.db"
$BackupDir = Join-Path $ProjectRoot "backups"
$Port = 2368

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Ghost 数据库备份脚本" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# 检查数据库是否存在
Write-Host "[1/4] 检查数据库 ..." -ForegroundColor Yellow
if (-not (Test-Path $DbPath)) {
    Write-Host "  错误：数据库文件不存在: $DbPath" -ForegroundColor Red
    exit 1
}
$dbSize = (Get-Item $DbPath).Length / 1KB
Write-Host "  数据库存在，大小: $([math]::Round($dbSize, 2)) KB" -ForegroundColor Green

# 检查 Ghost 是否在运行
Write-Host "[2/4] 检查 Ghost 运行状态 ..." -ForegroundColor Yellow
$ghostRunning = Get-NetTCPConnection -LocalPort $Port -ErrorAction SilentlyContinue
if ($ghostRunning) {
    Write-Host "  警告：Ghost 正在运行，数据库可能被锁定" -ForegroundColor Yellow
    $choice = Read-Host "  是否继续备份? (建议先停止 Ghost) (y/N)"
    if ($choice -ne 'y' -and $choice -ne 'Y') {
        Write-Host "  备份取消" -ForegroundColor Red
        exit 0
    }
} else {
    Write-Host "  Ghost 未运行，可以安全备份" -ForegroundColor Green
}

# 创建备份目录
Write-Host "[3/4] 创建备份目录 ..." -ForegroundColor Yellow
if (-not (Test-Path $BackupDir)) {
    New-Item -ItemType Directory -Path $BackupDir -Force | Out-Null
    Write-Host "  备份目录已创建: $BackupDir" -ForegroundColor Green
} else {
    Write-Host "  备份目录已存在" -ForegroundColor Green
}

# 执行备份
Write-Host "[4/4] 执行备份 ..." -ForegroundColor Yellow
$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
$backupFile = Join-Path $BackupDir "ghost-$timestamp.db"

try {
    Copy-Item -Path $DbPath -Destination $backupFile -Force
    $backupSize = (Get-Item $backupFile).Length / 1KB
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "  备份成功！" -ForegroundColor Green
    Write-Host "  备份文件: $backupFile" -ForegroundColor Green
    Write-Host "  备份大小: $([math]::Round($backupSize, 2)) KB" -ForegroundColor Green
    Write-Host "  备份时间: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Cyan
} catch {
    Write-Host "  备份失败: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# 列出所有备份
Write-Host ""
Write-Host "现有备份文件:" -ForegroundColor Yellow
Get-ChildItem $BackupDir -Filter "*.db" | Sort-Object LastWriteTime -Descending | Select-Object -First 5 | ForEach-Object {
    Write-Host "  $($_.Name) - $([math]::Round($_.Length/1KB, 2)) KB - $($_.LastWriteTime)" -ForegroundColor White
}
