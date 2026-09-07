# ============================================
# Ghost 博客系统一键启动脚本
# 用法：.\start.ps1
# ============================================

$ErrorActionPreference = "Stop"

# 配置
$ProjectRoot = "C:\Users\34344\oss-blog"
$RuntimeDir = Join-Path $ProjectRoot "runtime"
$GhostScript = Join-Path $RuntimeDir "current\index.js"
$Port = 2368

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Ghost 博客系统启动脚本" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# 检查端口是否被占用
Write-Host "[1/4] 检查端口 $Port ..." -ForegroundColor Yellow
$portInUse = Get-NetTCPConnection -LocalPort $Port -ErrorAction SilentlyContinue
if ($portInUse) {
    Write-Host "  端口 $Port 已被占用 (PID: $($portInUse.OwningProcess))" -ForegroundColor Red
    $choice = Read-Host "  是否终止该进程并继续? (y/N)"
    if ($choice -eq 'y' -or $choice -eq 'Y') {
        Stop-Process -Id $portInUse.OwningProcess -Force
        Start-Sleep -Seconds 2
        Write-Host "  进程已终止" -ForegroundColor Green
    } else {
        Write-Host "  启动取消" -ForegroundColor Red
        exit 1
    }
} else {
    Write-Host "  端口 $Port 空闲" -ForegroundColor Green
}

# 检查 Ghost 脚本是否存在
Write-Host "[2/4] 检查 Ghost 安装 ..." -ForegroundColor Yellow
if (-not (Test-Path $GhostScript)) {
    Write-Host "  错误：Ghost 脚本不存在: $GhostScript" -ForegroundColor Red
    Write-Host "  请先安装 Ghost" -ForegroundColor Red
    exit 1
}
Write-Host "  Ghost 脚本存在" -ForegroundColor Green

# 检查数据库是否存在
Write-Host "[3/4] 检查数据库 ..." -ForegroundColor Yellow
$dbPath = Join-Path $RuntimeDir "content\data\ghost.db"
if (Test-Path $dbPath) {
    Write-Host "  数据库存在" -ForegroundColor Green
} else {
    Write-Host "  警告：数据库不存在，首次启动将自动初始化" -ForegroundColor Yellow
}

# 启动 Ghost
Write-Host "[4/4] 启动 Ghost ..." -ForegroundColor Yellow
Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Ghost 正在启动..." -ForegroundColor Green
Write-Host "  前台地址: http://localhost:$Port/" -ForegroundColor Green
Write-Host "  管理端:   http://localhost:$Port/ghost/" -ForegroundColor Green
Write-Host "  按 Ctrl+C 停止服务" -ForegroundColor Yellow
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# 设置环境变量并启动
$env:NODE_ENV = "development"
Set-Location $RuntimeDir
node $GhostScript
