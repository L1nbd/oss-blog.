# ============================================
# Ghost 博客系统一键停止脚本
# 用法：.\stop.ps1
# ============================================

$ErrorActionPreference = "Stop"

# 配置
$Port = 2368

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Ghost 博客系统停止脚本" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# 查找占用端口的进程
Write-Host "[1/3] 查找占用端口 $Port 的进程 ..." -ForegroundColor Yellow
$connections = Get-NetTCPConnection -LocalPort $Port -ErrorAction SilentlyContinue

if (-not $connections) {
    Write-Host "  端口 $Port 未被占用，Ghost 可能未运行" -ForegroundColor Yellow
    exit 0
}

$pids = $connections | Select-Object -ExpandProperty OwningProcess -Unique
Write-Host "  找到 $($pids.Count) 个进程占用端口 $Port" -ForegroundColor Green

# 显示进程信息
Write-Host "[2/3] 进程信息:" -ForegroundColor Yellow
foreach ($pid in $pids) {
    $process = Get-Process -Id $pid -ErrorAction SilentlyContinue
    if ($process) {
        Write-Host "  PID: $pid, 名称: $($process.ProcessName), 启动时间: $($process.StartTime)" -ForegroundColor White
    }
}

# 终止进程
Write-Host "[3/3] 终止进程 ..." -ForegroundColor Yellow
foreach ($pid in $pids) {
    try {
        Stop-Process -Id $pid -Force -ErrorAction Stop
        Write-Host "  进程 $pid 已终止" -ForegroundColor Green
    } catch {
        Write-Host "  终止进程 $pid 失败: $($_.Exception.Message)" -ForegroundColor Red
    }
}

Start-Sleep -Seconds 2

# 验证端口已释放
$stillInUse = Get-NetTCPConnection -LocalPort $Port -ErrorAction SilentlyContinue
if ($stillInUse) {
    Write-Host ""
    Write-Host "  警告：端口 $Port 仍被占用" -ForegroundColor Red
} else {
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "  Ghost 已成功停止" -ForegroundColor Green
    Write-Host "  端口 $Port 已释放" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Cyan
}
